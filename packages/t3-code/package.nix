{
  appimageTools,
  asar,
  fetchurl,
  lib,
  makeWrapper,
  nodejs,
  stdenv,
  systemd,
}:
let
  sources = builtins.fromJSON (builtins.readFile ./sources.json);
  source =
    sources.platforms.${stdenv.hostPlatform.system} or (throw "t3-code: unsupported system ${stdenv.hostPlatform.system}");
  src = fetchurl { inherit (source) url hash; };
  appimageContents = appimageTools.extract {
    pname = "t3-code";
    inherit (source) version;
    inherit src;
    postExtract = ''
      ${lib.getExe nodejs} ${./patch-codex-cwd.mjs} \
          ${asar}/lib/node_modules/@electron/asar "$out/resources"
    '';
  };
in
appimageTools.wrapAppImage {
  pname = "t3-code";
  inherit (source) version;
  inherit src;
  contents = appimageContents;
  nativeBuildInputs = [ makeWrapper ];

  extraInstallCommands = ''
    install -Dm444 ${appimageContents}/t3code.desktop "$out/share/applications/t3-code.desktop"
    substituteInPlace "$out/share/applications/t3-code.desktop" \
        --replace-fail "Exec=AppRun %U" "Exec=t3-code %U"
    cp -r ${appimageContents}/usr/share/icons "$out/share/icons"

    mv "$out/bin/t3-code" "$out/bin/.t3-code-unwrapped"
    makeWrapper ${systemd}/bin/systemd-inhibit "$out/bin/t3-code" \
      --set T3CODE_DISABLE_AUTO_UPDATE 1 \
      --add-flags '--what=sleep --mode=block --who="T3 Code" --why="T3 Code is open"' \
      --add-flags "$out/bin/.t3-code-unwrapped"
  '';

  meta = {
    description = "Web GUI for coding agents";
    homepage = "https://github.com/pingdotgg/t3code";
    license = lib.licenses.mit;
    mainProgram = "t3-code";
    platforms = builtins.attrNames sources.platforms;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
