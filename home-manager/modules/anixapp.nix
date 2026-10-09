{ pkgs, ... }:

let
  pname = "anixapp";
  version = "0.1.60";

  src = pkgs.fetchurl {
    url = "https://github.com/Maks1mio/anixapp/releases/download/v${version}/AnixApp-${version}.AppImage";
    sha256 = "de8f3cd85fc30458ecc4426641fb02cd2a128e96b534a16564d456978e598bc8";
  };


  appimageContents = pkgs.appimageTools.extract { inherit pname version src; };


  anixapp-unwrapped = pkgs.appimageTools.wrapType2 {
    inherit pname version src;

    extraInstallCommands = ''
      install -Dm444 ${appimageContents}/anixapp.desktop \
        $out/share/applications/anixapp.desktop
      install -Dm444 ${appimageContents}/anixapp.png \
        $out/share/icons/hicolor/512x512/apps/anixapp.png

      substituteInPlace $out/share/applications/anixapp.desktop \
        --replace-fail 'Exec=AppRun --no-sandbox %U' 'Exec=${pname} %U'
    '';
  };
in
{
  home.packages = [
    (pkgs.symlinkJoin {
      name = "anixapp";
      paths = [ anixapp-unwrapped ];
      buildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/${pname} \
          --add-flags "--no-sandbox" \
          --add-flags "--enable-unsafe-webgpu" \
          --add-flags "--ozone-platform=wayland" \
          --add-flags "--enable-features=Vulkan,VulkanFromANGLE" \
          --add-flags "--use-angle=vulkan"
      '';
    })
  ];
}
