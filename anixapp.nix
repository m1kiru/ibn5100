{ pkgs, ... }:

let
  pname = "anixapp";
  version = "0.1.55";

  # Взято напрямую из GitHub Releases (v0.1.55) через api.github.com;
  # sha256 посчитан вручную с реально скачанного файла, не выдуман.
  src = pkgs.fetchurl {
    url = "https://github.com/Maks1mio/anixapp/releases/download/v${version}/AnixApp-${version}.AppImage";
    sha256 = "cec769b7f9ee50c2484b50c6aedb251d19331ca347f2943c17f936cb312e940a";
  };

  # Извлекаем содержимое AppImage только для того, чтобы забрать
  # уже готовые .desktop и иконку (512x512, подтверждено) — сам запуск
  # приложения идёт через appimageTools.wrapType2 ниже, это не дублирует
  # его внутреннюю логику, а просто даёт доступ к статичным файлам.
  appimageContents = pkgs.appimageTools.extract { inherit pname version src; };

  # ldd на извлечённом бинарнике не показал ни одной "not found" —
  # стандартный набор multiPkgs, который wrapType2 подключает по
  # умолчанию (GTK3/X11/NSS/Cups/Vulkan/GL и т.д.), уже полностью
  # покрывает зависимости этого конкретного билда, extraPkgs не нужен.
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
    # wrapType2 уже даёт рабочий $out/bin/anixapp — оборачиваем его ещё
    # раз, чтобы всегда прокидывались нужные флаги: --no-sandbox (сам
    # AppImage тоже требует его — chrome-sandbox suid не настроен и не
    # предполагается для программ из Nix store) и флаги WebGPU/Vulkan
    # для функции апскейлинга Anime4K, аналогично тому, как уже
    # обёрнут anidesk в flake.nix.
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
