#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
current_system="$(nix eval --impure --raw --expr builtins.currentSystem)"
shopt -s nullglob

github_api() {
    local endpoint="$1"
    {
        if [[ -n ${GITHUB_TOKEN:-} ]]; then
            printf 'header = "Authorization: Bearer %s"\n' "$GITHUB_TOKEN"
        fi
    } | curl --config - -fsSL \
        -H "Accept: application/vnd.github+json" \
        -H "X-GitHub-Api-Version: 2022-11-28" \
        "https://api.github.com/$endpoint"
}

update_github_release() {
    local package="$1" config="$2" sources="$3"
    local repository asset_name asset_pattern release asset version url digest hash temporary

    # Literal assets remain backward-compatible. Versioned filenames can use
    # assetPatterns instead; exactly one selector and one asset must match.
    jq --exit-status --arg system "$current_system" '
        .type == "github-release"
        and (.repository | type == "string" and test("^[^/]+/[^/]+$"))
        and (has("tagPattern") | not)
        and (
            [(.assets[$system] // null), (.assetPatterns[$system] // null)]
            | map(select(. != null))
            | length == 1 and all(.[]; type == "string" and length > 0)
        )
    ' "$config" >/dev/null || {
        echo "Invalid stable-release configuration for $package on $current_system" >&2
        return 1
    }

    repository="$(jq --raw-output .repository "$config")"
    asset_name="$(jq --raw-output --arg system "$current_system" '.assets[$system] // empty' "$config")"
    asset_pattern="$(jq --raw-output --arg system "$current_system" '.assetPatterns[$system] // empty' "$config")"
    release="$(github_api "repos/$repository/releases/latest")"

    jq --exit-status '.draft == false and .prerelease == false' <<<"$release" >/dev/null || {
        echo "Refusing a draft or prerelease for $package" >&2
        return 1
    }
    asset="$(
        jq --exit-status --compact-output --arg name "$asset_name" --arg pattern "$asset_pattern" '
            [.assets[] | select(
                if $pattern != "" then (.name | test($pattern)) else .name == $name end
            )]
            | if length == 1 then .[0] else error("Expected exactly one matching release asset") end
        ' <<<"$release"
    )"

    version="$(jq --raw-output '.tag_name | sub("^v"; "")' <<<"$release")"
    url="$(jq --raw-output .browser_download_url <<<"$asset")"
    digest="$(jq --raw-output '.digest // empty' <<<"$asset")"
    if [[ $digest == sha256:* ]]; then
        hash="$(nix hash convert --hash-algo sha256 --to sri "${digest#sha256:}")"
    else
        hash="$(nix store prefetch-file --json "$url" | jq --raw-output .hash)"
    fi

    temporary="$(mktemp "$sources.XXXXXX")"
    if ! jq --indent 4 \
        --arg system "$current_system" --arg version "$version" --arg url "$url" --arg hash "$hash" \
        '.platforms[$system] = { version: $version, url: $url, hash: $hash }' \
        "$sources" >"$temporary"; then
        rm -f "$temporary"
        return 1
    fi
    mv "$temporary" "$sources"
}

update_package() {
    local package="$1" config="$root/packages/$1/update.json" sources="$root/packages/$1/sources.json"
    if [[ ! -f $config || ! -f $sources ]]; then
        echo "Missing update configuration or sources for: $package" >&2
        return 1
    fi
    case "$(jq --raw-output '.type // empty' "$config")" in
    github-release) update_github_release "$package" "$config" "$sources" ;;
    *)
        echo "Unsupported update type for: $package" >&2
        return 1
        ;;
    esac
    echo "Building $package..."
    nix build "path:$root#$package" --no-link
}

if (($# > 0)); then
    for package in "$@"; do update_package "$package"; done
else
    for config in "$root"/packages/*/update.json; do
        update_package "$(basename "$(dirname "$config")")"
    done
fi
