{
  autoPatchelfHook,
  cacert,
  fetchurl,
  lib,
  makeWrapper,
  stdenv,
  versionCheckHook,
  writableTmpDirAsHomeHook,
  zlib,
}:
let
  sources = builtins.fromJSON (builtins.readFile ./sources.json);
  source =
    sources.platforms.${stdenv.hostPlatform.system} or (throw "executor: unsupported system ${stdenv.hostPlatform.system}");
  runtimeTarget =
    {
      x86_64-linux = "linux-x64";
      aarch64-linux = "linux-arm64";
    }
    .${stdenv.hostPlatform.system};
in
stdenv.mkDerivation {
  pname = "executor";
  inherit (source) version;
  src = fetchurl { inherit (source) url hash; };

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];
  buildInputs = [
    stdenv.cc.cc.lib
    zlib
  ];
  # The Bun executable contains the application after its ELF sections.
  dontStrip = true;

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/libexec/executor"
    cp -a . "$out/libexec/executor/"
    # npm dependencies include prebuilds for other operating systems and architectures.
    find "$out/libexec/executor/runtime/node_modules" -type d -name prebuilds | while read -r prebuilds; do
      find "$prebuilds" -mindepth 1 -maxdepth 1 ! -name ${runtimeTarget} -exec rm -r {} +
    done
    makeWrapper "$out/libexec/executor/executor" "$out/bin/executor" \
      --set EXECUTOR_NO_UPDATE_CHECK 1 \
      --set EXECUTOR_DISABLE_ANALYTICS 1 \
      --set OTEL_SDK_DISABLED true \
      --set-default NODE_EXTRA_CA_CERTS "${cacert}/etc/ssl/certs/ca-bundle.crt"
    runHook postInstall
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [
    versionCheckHook
    writableTmpDirAsHomeHook
  ];
  versionCheckProgram = "${placeholder "out"}/bin/executor";
  versionCheckProgramArg = "--version";

  meta = {
    description = "Local integration gateway for AI agents";
    homepage = "https://executor.sh";
    license = lib.licenses.mit;
    mainProgram = "executor";
    platforms = builtins.attrNames sources.platforms;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
