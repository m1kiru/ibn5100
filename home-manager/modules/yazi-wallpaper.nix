{ pkgs, ... }:

let
  set-wallpaper = pkgs.writeShellScriptBin "yazi-set-wallpaper" ''
    set -euo pipefail

    PGREP=${pkgs.procps}/bin/pgrep
    PKILL=${pkgs.procps}/bin/pkill
    FLOCK=${pkgs.util-linux}/bin/flock
    SETSID=${pkgs.util-linux}/bin/setsid
    MPVPAPER=${pkgs.mpvpaper}/bin/mpvpaper
    AWWW=${pkgs.awww}/bin/awww
    SYSTEMCTL=${pkgs.systemd}/bin/systemctl

    file="''${1:?usage: yazi-set-wallpaper FILE}"
    file="$(readlink -f -- "$file" 2>/dev/null || realpath -- "$file")"
    [[ -f "$file" ]] || { echo "yazi-set-wallpaper: не файл: $file" >&2; exit 1; }
    [[ -r "$file" ]] || { echo "yazi-set-wallpaper: нет доступа: $file" >&2; exit 1; }

    if [[ -z "''${XDG_RUNTIME_DIR:-}" || ! -d "$XDG_RUNTIME_DIR" ]]; then
      echo "yazi-set-wallpaper: XDG_RUNTIME_DIR не установлен" >&2
      exit 1
    fi
    RUNTIME="$XDG_RUNTIME_DIR"
    CACHE_DIR="''${XDG_CACHE_HOME:-$HOME/.cache}"
    STATE_FILE="$CACHE_DIR/wallpaper-state"
    mkdir -p "$CACHE_DIR"

    # быстрый выход если те же обои уже стоят
    if [[ -f "$STATE_FILE" ]]; then
      last="$(cat "$STATE_FILE" 2>/dev/null || true)"
      if [[ "$last" == "$file" ]]; then
        ext_lc="''${file##*.}"; ext_lc="''${ext_lc,,}"
        case "$ext_lc" in
          mp4|webm|mkv|mov|m4v|avi)
            $PGREP -x mpvpaper >/dev/null 2>&1 && exit 0
            ;;
          *)
            $PGREP -x awww-daemon >/dev/null 2>&1 && exit 0
            ;;
        esac
      fi
    fi

    exec 9>"$RUNTIME/yazi-set-wallpaper.lock"
    trap 'exec 9>&-' EXIT
    $FLOCK -n 9 || { echo "yazi-set-wallpaper: уже выполняется" >&2; exit 0; }

    ext="''${file##*.}"
    ext="''${ext,,}"

    is_video=0
    case "$ext" in mp4|webm|mkv|mov|m4v|avi) is_video=1 ;; esac

    stop_backend() {
      $PGREP -x "$1" >/dev/null 2>&1 || return 0
      $PKILL -x -TERM "$1" 2>/dev/null || true
      # ждём до 0.4с с шагом 20мс — в 2.5 раза быстрее
      for ((i=0;i<20;i++)); do
        $PGREP -x "$1" >/dev/null 2>&1 || return 0
        sleep 0.02
      done
      $PKILL -x -KILL "$1" 2>/dev/null || true
      for ((i=0;i<10;i++)); do
        $PGREP -x "$1" >/dev/null 2>&1 || return 0
        sleep 0.02
      done
      echo "yazi-set-wallpaper: не удалось остановить $1" >&2
      return 1
    }

    save_state() {
      printf '%s\n' "$file" > "$STATE_FILE.tmp" && mv -f "$STATE_FILE.tmp" "$STATE_FILE"
    }

    if (( is_video )); then
      # видео: останавливаем awww-daemon через systemd (без автоперезапуска), глушим старый mpvpaper
      $SYSTEMCTL --user stop awww-daemon.service 2>/dev/null || true
      $PGREP -x mpvpaper >/dev/null 2>&1 && stop_backend mpvpaper
      $SETSID $MPVPAPER -o "no-audio loop-file=inf hwdec=auto" '*' "$file" </dev/null >"$RUNTIME/mpvpaper.log" 2>&1 &
      disown 2>/dev/null || true
    else
      # картинка: глушим mpvpaper, стартуем awww-daemon через systemd
      $PGREP -x mpvpaper >/dev/null 2>&1 && stop_backend mpvpaper
      $SYSTEMCTL --user start awww-daemon.service 2>/dev/null || true

      # ждём готовности демона
      ok=0
      for ((i=0;i<100;i++)); do
        if $AWWW query >/dev/null 2>&1; then ok=1; break; fi
        sleep 0.02
      done
      if (( ! ok )); then
        echo "yazi-set-wallpaper: awww-daemon не доступен после 2с ожидания" >&2
        exit 1
      fi
      $AWWW img "$file" --transition-type simple --transition-duration 0.06
    fi

    save_state
  '';

  restore-wallpaper = pkgs.writeShellScriptBin "restore-wallpaper" ''
    set -euo pipefail
    CACHE_DIR="''${XDG_CACHE_HOME:-$HOME/.cache}"
    STATE_FILE="$CACHE_DIR/wallpaper-state"
    [[ -f "$STATE_FILE" ]] || exit 0
    file="$(cat "$STATE_FILE" 2>/dev/null || true)"
    # trim
    file="''${file%%[$'\n\r']*}"
    [[ -n "$file" && -f "$file" ]] || exit 0
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

  # systemd держит awww-daemon живым — быстрее и стабильнее ручного setsid
  systemd.user.services.awww-daemon = {
    Unit = {
      Description = "awww wallpaper daemon";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.awww}/bin/awww-daemon";
      Restart = "on-failure";
      RestartSec = "500ms";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

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
