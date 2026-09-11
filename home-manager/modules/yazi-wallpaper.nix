{ pkgs, ... }:

let
  set-wallpaper = pkgs.writeShellScriptBin "yazi-set-wallpaper" ''
    set -euo pipefail

    file="$(readlink -f "$1")"
    ext_lower="''${file##*.}"
    ext_lower="''${ext_lower,,}"

    STATE_FILE="$HOME/.cache/wallpaper-state"
    mkdir -p "$(dirname "$STATE_FILE")"

    kill_backend() {
      local name="$1"
      ${pkgs.procps}/bin/pkill -TERM "$name" 2>/dev/null || true

      local i
      for i in {1..10}; do
        ${pkgs.procps}/bin/pgrep "$name" >/dev/null 2>&1 || break
        sleep 0.05
      done

      if ${pkgs.procps}/bin/pgrep "$name" >/dev/null 2>&1; then
        ${pkgs.procps}/bin/pkill -KILL "$name" 2>/dev/null || true
        sleep 0.1
      fi
    }

    kill_backend mpvpaper
    kill_backend awww-daemon

    sleep 0.2
    rm -f "''${XDG_RUNTIME_DIR:-/tmp}/awww.sock" 2>/dev/null || true

    case "$ext_lower" in
      mp4|webm|mkv|mov)
        setsid ${pkgs.mpvpaper}/bin/mpvpaper \
          -o "no-audio loop-file=inf hwdec=auto" \
          '*' "$file" </dev/null >/tmp/mpvpaper.log 2>&1 &
        ;;
      *)
        setsid ${pkgs.awww}/bin/awww-daemon \
          </dev/null >/tmp/awww-daemon.log 2>&1 &

        ready=0
        for i in {1..50}; do
          if ${pkgs.awww}/bin/awww query >/dev/null 2>&1; then
            ready=1
            break
          fi
          sleep 0.1
        done

        if [ "$ready" -ne 1 ]; then
          echo "awww-daemon failed to become ready" >&2
          exit 1
        fi

        ${pkgs.awww}/bin/awww img "$file" \
          --transition-type grow \
          --transition-duration 0.4
        ;;
    esac

    echo "$file" > "$STATE_FILE"
  '';

  restore-wallpaper = pkgs.writeShellScriptBin "restore-wallpaper" ''
    set -euo pipefail
    STATE_FILE="$HOME/.cache/wallpaper-state"
    [ -f "$STATE_FILE" ] || exit 0
    file="$(cat "$STATE_FILE")"
    [ -f "$file" ] || exit 0
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

    keymap.mgr.prepend_keymap = [
      {
        on = [ "p" ];
        run = "shell --confirm -- yazi-set-wallpaper %h";
        desc = "Set hovered file as wallpaper";
      }
    ];
  };
}
