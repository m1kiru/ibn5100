{ pkgs, ... }:

let
  set-wallpaper = pkgs.writeShellScriptBin "yazi-set-wallpaper" ''
    set -euo pipefail

    file="$1"
    ext="''${file##*.}"
    ext_lower=$(echo "$ext" | tr '[:upper:]' '[:lower:]')

    # Останавливаем предыдущий видео-бэкенд в любом случае — иначе он
    # останется висеть на layer-surface поверх/под новой статичной картинкой
    ${pkgs.procps}/bin/pkill mpvpaper 2>/dev/null || true
    sleep 0.1

    case "$ext_lower" in
      mp4|webm|mkv|mov)
        # Видео — через mpvpaper, без звука, зациклено
        nohup ${pkgs.mpvpaper}/bin/mpvpaper -o "no-audio loop-file=inf hwdec=auto" '*' "$file" \
          >/tmp/mpvpaper.log 2>&1 &
        disown
        ;;
      gif)
        # GIF — awww умеет анимации нативно
        if ! ${pkgs.awww}/bin/awww query >/dev/null 2>&1; then
          ${pkgs.awww}/bin/awww-daemon &
          sleep 0.5
        fi
        ${pkgs.awww}/bin/awww img "$file" --transition-type grow --transition-duration 0.4
        ;;
      *)
        # Статичные картинки — через awww
        if ! ${pkgs.awww}/bin/awww query >/dev/null 2>&1; then
          ${pkgs.awww}/bin/awww-daemon &
          sleep 0.5
        fi
        ${pkgs.awww}/bin/awww img "$file" --transition-type grow --transition-duration 0.4
        ;;
    esac
  '';
in
{
  home.packages = [
    set-wallpaper
    pkgs.awww
    pkgs.mpvpaper
  ];

  programs.yazi = {
    enable = true;
    package = pkgs.yazi;

    settings = {
      mgr = {
        sort_by = "natural";
        show_hidden = true;
        show_symlink = true;
      };
      preview = {
        image_filter = "lanczos3";
        image_quality = 75;
      };
    };

    keymap = {
      mgr.prepend_keymap = [
        {
          on = [ "w" ];
          run = "shell 'yazi-set-wallpaper \"$1\"' --confirm";
          desc = "Set hovered file as wallpaper";
        }
      ];
    };
  };
}
