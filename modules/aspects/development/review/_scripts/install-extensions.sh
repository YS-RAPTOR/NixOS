export XDG_CONFIG_HOME="$1"
shift
extensions="$XDG_CONFIG_HOME/hunk/extensions"
mkdir -p "$extensions"

install_example() (
    name="$1"
    # Stage the copy so a failed dependency install is retried next activation.
    staging="$(mktemp -d "$extensions/.$name.XXXXXX")"
    trap 'rm -rf "$staging"' EXIT
    cp -R "$HUNK_EXAMPLES_SOURCE/$name/." "$staging/"
    chmod -R u+w "$staging"
    if [[ -f "$staging/package.json" ]]; then
        cd "$staging"
        bun install --production --ignore-scripts
    fi
    mv "$staging" "$extensions/$name"
)

for source in "$@"; do
    if [[ ! $source =~ ^([A-Za-z0-9_.-]+)/([A-Za-z0-9][A-Za-z0-9_-]*)(@.+)?$ ]]; then
        echo "Invalid Hunk extension source: $source (expected owner/repository[@ref] or examples/name)" >&2
        exit 1
    fi
    name="${BASH_REMATCH[2]}"
    if [[ $source == examples/* && $source != "examples/$name" ]]; then
        echo "Example extensions use the pinned Hunk input, not a separate @ref: $source" >&2
        exit 1
    fi

    # Preserve both managed installs and manually installed copies/symlinks.
    if [[ -e "$extensions/installed/$name" || -L "$extensions/installed/$name" ||
        -e "$extensions/$name" || -L "$extensions/$name" ]]; then
        continue
    fi

    case "$source" in
    examples/*) install_example "$name" ;;
    *) hunk extension install "$source" --yes ;;
    esac
done
