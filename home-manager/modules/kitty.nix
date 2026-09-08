{ pkgs, ... }:

{
  programs.kitty = {
    enable = true;
    package = pkgs.kitty;

    font = {
      name = "IBM Plex Mono";
      size = 11;
    };

    settings = {
      # Цвета — соответствуют alacritty.nix (чёрный фон, белый текст)
      background = "#000000";
      foreground = "#FFFFFF";

      cursor_text_color = "#000000";
      cursor = "#FFFFFF";

      selection_foreground = "#000000";
      selection_background = "#FFFFFF";

      # normal palette — как в alacritty.nix
      color0 = "#555555"; # black
      color1 = "#FF0000"; # red
      color2 = "#00FF00"; # green
      color3 = "#AA5500"; # yellow
      color4 = "#0000FF"; # blue
      color5 = "#AA00AA"; # magenta
      color6 = "#00AAAA"; # cyan
      color7 = "#FFFFFF"; # white

      # bright palette не был задан отдельно в alacritty.nix,
      # дублируем normal, чтобы избежать несоответствия
      color8 = "#555555";
      color9 = "#FF0000";
      color10 = "#00FF00";
      color11 = "#AA5500";
      color12 = "#0000FF";
      color13 = "#AA00AA";
      color14 = "#00AAAA";
      color15 = "#FFFFFF";

      # Прозрачность — аналог window.opacity = 0.5 в alacritty.nix
      background_opacity = "0.5";

      # Отступы окна — аналог window.padding.x/y = 0
      window_padding_width = 0;

      # Поиск (search.matches / search.focused_match в alacritty не имеют
      # прямого аналога в kitty — здесь используется url-цвет как ближайший эквивалент)
      url_color = "#FF0000";
      confirm_os_window_close = 0;
    };
  };
}
