{ lib, pkgs, ... }:
let
  version = "0.1.55";
  src = pkgs.fetchurl {
    url = "https://github.com/Maks1mio/anixapp/releases/download/v${version}/anixapp_${version}_amd64.deb";
    hash = "sha256-05zyEEVxCCt/JfMDhZhbKI5k71ecn3MtBhNi47xSBxY=";
  };
  anixappPkg = pkgs.stdenv.mkDerivation {
    pname = "anixapp";
    inherit version src;

    nativeBuildInputs = with pkgs; [ dpkg autoPatchelfHook makeWrapper ];

    buildInputs = with pkgs; [
      gtk3 nss alsa-lib at-spi2-atk at-spi2-core cups dbus
      expat libdrm libxkbcommon mesa nspr vulkan-loader
      pango cairo libxcomposite libxdamage libxfixes libxrandr
      libxcb libx11 libxext libXScrnSaver libXtst
      libnotify libsecret
      libxshmfence
      gsettings-desktop-schemas gtk3
    ];

    dontWrapGApps = true;

    unpackPhase = ''
      dpkg-deb --fsys-tarfile $src | tar -xvf - > /dev/null
    '';

    installPhase = ''
      mkdir -p $out
      cp -r opt $out/opt
      cp -r usr/share $out/share
      mkdir -p $out/share
      chmod +x $out/opt/AnixApp/anixapp
      mkdir -p $out/bin
      makeWrapper $out/opt/AnixApp/anixapp $out/bin/anixapp \
        --add-flags "--no-sandbox" \
        --add-flags "--enable-unsafe-webgpu" \
        --add-flags "--ozone-platform-hint=auto" \
        --prefix LD_LIBRARY_PATH : "${pkgs.vulkan-loader}/lib" \
        --prefix XDG_DATA_DIRS : "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}" \
        --prefix XDG_DATA_DIRS : "${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}" \
        --set GDK_BACKEND "wayland,x11" \
        --set NVD_BACKEND "direct" \
        --set VK_ICD_FILENAMES "/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.json"
      substituteInPlace $out/share/applications/anixapp.desktop \
        --replace-fail "/opt/AnixApp/anixapp" "$out/bin/anixapp"
      echo "StartupNotify=false" >> $out/share/applications/anixapp.desktop
    '';

    meta = with lib; {
      description = "Быстрый клиент для просмотра аниме на базе Anixart API";
      homepage = "https://github.com/Maks1mio/anixapp";
      license = licenses.mit;
      platforms = [ "x86_64-linux" ];
      mainProgram = "anixapp";
    };
  };
in
{
  environment.systemPackages = [ anixappPkg ];
}
