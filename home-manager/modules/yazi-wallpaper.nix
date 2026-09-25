{ pkgs, ... }:

let
  set-wallpaper = pkgs.writeShellScriptBin "yazi-set-wallpaper" ''
    set -euo pipefail

    MPVPAPER=${pkgs.mpvpaper}/bin/mpvpaper
    AWWW=${pkgs.awww}/bin/awww
    SYSTEMCTL=${pkgs.systemd}/bin/systemctl
    SYSTEMD_RUN=${pkgs.systemd}/bin/systemd-run
    FLOCK=${pkgs.util-linux}/bin/flock

    file="''${1:?usage: yazi-set-wallpaper FILE}"
    file="$(readlink -f -- "$file" 2>/dev/null || realpath -- "$file")"
    [[ -f "$file" ]] || { echo "yazi-set-wallpaper: не файл: $file" >&2; exit 1; }
    [[ -r "$file" ]] || { echo "yazi-set-wallpaper: нет доступа: $file" >&2; exit 1; }

    [[ -n "''${XDG_RUNTIME_DIR:-}" && -d "$XDG_RUNTIME_DIR" ]] || { echo "yazi-set-wallpaper: XDG_RUNTIME_DIR не установлен" >&2; exit 1; }
    RUNTIME="$XDG_RUNTIME_DIR"
    CACHE_DIR="''${XDG_CACHE_HOME:-$HOME/.cache}"
    STATE_FILE="$CACHE_DIR/wallpaper-state"
    mkdir -p "$CACHE_DIR"

    # быстрый выход если те же обои уже стоят и бэкенд жив
    if [[ -f "$STATE_FILE" ]]; then
      last="$(cat "$STATE_FILE" 2>/dev/null || true)"
      if [[ "$last" == "$file" ]]; then
        ext_lc="''${file##*.}"; ext_lc="''${ext_lc,,}"
        case "$ext_lc" in
          mp4|webm|mkv|mov|m4v|avi)
            $SYSTEMCTL --user is-active --quiet mpvpaper.service 2>/dev/null && exit 0
            ;;
          *)
            $SYSTEMCTL --user is-active --quiet awww-daemon.service 2>/dev/null && $AWWW query >/dev/null 2>&1 && exit 0
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

    save_state() {
      printf '%s\n' "$file" > "$STATE_FILE.tmp" && mv -f "$STATE_FILE.tmp" "$STATE_FILE"
    }

    # глушит mpvpaper через systemd cgroup — гарантированно, без pgrep/pkill циклов
    stop_mpvpaper() {
      $SYSTEMCTL --user stop mpvpaper.service 2>/dev/null || true
      # fallback если кто-то запустил руками без systemd-run
      ${pkgs.procps}/bin/pkill -x mpvpaper 2>/dev/null || true
      # ждём до 600мс пока cgroup опустеет
      for _ in {1..30}; do
        $SYSTEMCTL --user is-active --quiet mpvpaper.service 2>/dev/null || break
        sleep 0.02
      done
      # если завис — добиваем
      if $SYSTEMCTL --user is-active --quiet mpvpaper.service 2>/dev/null; then
        $SYSTEMCTL --user kill -s KILL mpvpaper.service 2>/dev/null || true
        sleep 0.05
      fi
    }

    if (( is_video )); then
      $SYSTEMCTL --user stop awww-daemon.service 2>/dev/null || true
      stop_mpvpaper
      $SYSTEMD_RUN --user --unit=mpvpaper --collect \
        --property=Restart=no \
        --property=SuccessAction=none \
        -- $MPVPAPER -o "no-audio loop-file=inf hwdec=auto" '*' "$file" \
        </dev/null >"$RUNTIME/mpvpaper.log" 2>&1
    else
      stop_mpvpaper
      $SYSTEMCTL --user start awww-daemon.service 2>/dev/null || true

      ok=0
      for _ in {1..100}; do
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
      mgr.sort_by = "natural";
      mgr.show_hidden = true;
      mgr.show_symlink = true;
      preview.image_filter = "lanczos3";
      preview.image_quality = 75;
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
