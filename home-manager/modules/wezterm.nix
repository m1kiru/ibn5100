{ pkgs, lib, ... }:

{
  programs.wezterm = {
    enable = true;
    package = pkgs.wezterm;
    colorSchemes = {
      ibn5100 = {
        ansi = [
          "#555555"
          "#FF0000"
          "#00FF00"
          "#AA5500"
          "#0000FF"
          "#AA00AA"
          "#00AAAA"
          "#FFFFFF"
        ];
        brights = [
          "#555555"
          "#FF0000"
          "#00FF00"
          "#AA5500"
          "#0000FF"
          "#AA00AA"
          "#00AAAA"
          "#FFFFFF"
        ];
        background = "rgba(0, 0, 0, 0.5)";
        cursor_bg = "#FFFFFF";
        cursor_fg = "#000000";
        cursor_border = "#000000";
        foreground = "#FFFFFF";
        selection_bg = "#FFFFFF";
        selection_fg = "#000000";
      };
    };
    settings = {
      color_scheme = "ibn5100";
      hide_tab_bar_if_only_one_tab = true;
      font = lib.generators.mkLuaInline ''wezterm.font("IBM Plex Mono")'';
      
    };
  };
}
