{ pkgs, ... }:

let
  set-wallpaper = pkgs.writeShellScriptBin "yazi-set-wallpaper" ''
    set -euo pipefail

    file="$1"
    ext="''${file##*.}"
    ext_lower=$(echo "$ext" | tr '[:upper:]' '[:lower:]')

    STATE_FILE="$HOME/.cache/wallpaper-state"
    mkdir -p "$(dirname "$STATE_FILE")"

    # Останавливаем оба бэкенда безусловно — иначе они могут конфликтовать
    # за один и тот же layer-surface (например, оставшийся awww-daemon
    # поверх нового видео от mpvpaper, или наоборот).
    ${pkgs.procps}/bin/pkill mpvpaper 2>/dev/null || true
    ${pkgs.procps}/bin/pkill awww-daemon 2>/dev/null || true
    sleep 0.2

    case "$ext_lower" in
      mp4|webm|mkv|mov)
        # Видео — через mpvpaper, без звука, зациклено
        nohup ${pkgs.mpvpaper}/bin/mpvpaper -o "no-audio loop-file=inf hwdec=auto" '*' "$file" \
          >/tmp/mpvpaper.log 2>&1 &
        disown
        ;;
      gif)
        # GIF — awww умеет анимации нативно
        ${pkgs.awww}/bin/awww-daemon &
        sleep 0.5
        ${pkgs.awww}/bin/awww img "$file" --transition-type grow --transition-duration 0.4
        ;;
      *)
        # Статичные картинки — через awww
        ${pkgs.awww}/bin/awww-daemon &
        sleep 0.5
        ${pkgs.awww}/bin/awww img "$file" --transition-type grow --transition-duration 0.4
        ;;
    esac

    # Сохраняем путь и тип для восстановления при следующем входе в сессию
    echo "$file" > "$STATE_FILE"
  '';

  restore-wallpaper = pkgs.writeShellScriptBin "restore-wallpaper" ''
    set -euo pipefail

    STATE_FILE="$HOME/.cache/wallpaper-state"

    if [ ! -f "$STATE_FILE" ]; then
      exit 0
    fi

    file=$(cat "$STATE_FILE")

    if [ ! -f "$file" ]; then
      exit 0
    fi

    exec ${set-wallpaper}/bin/yazi-set-wallpaper "$file"
  '';
in
{
  home.packages = [
    set-wallpaper
    restore-wallpaper
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
          run = "shell --confirm -- yazi-set-wallpaper %h";
          desc = "Set hovered file as wallpaper";
        }
      ];
    };
  };
}
