{ pkgs, ... }:

{
  programs.wezterm = {
    enable = true;
    package = pkgs.wezterm;

    extraConfig = ''
      local wezterm = require 'wezterm'
      local config = wezterm.config_builder()

      config.color_schemes = {
        ['ibn5100'] = {
          ansi = {
            "#555555",
            "#FF0000",
            "#00FF00",
            "#AA5500",
            "#0000FF",
            "#AA00AA",
            "#00AAAA",
            "#FFFFFF",
          },
          brights = {
            "#555555",
            "#FF0000",
            "#00FF00",
            "#AA5500",
            "#0000FF",
            "#AA00AA",
            "#00AAAA",
            "#FFFFFF",
          },
          background = "#000000",
          cursor_bg = "#FFFFFF",
          cursor_fg = "#000000",
          cursor_border = "#000000",
          foreground = "#FFFFFF",
          selection_bg = "#FFFFFF",
          selection_fg = "#000000",
        },
      }

      config.color_scheme = 'ibn5100'
      config.window_background_opacity = 0.5
      config.hide_tab_bar_if_only_one_tab = true
      config.font = wezterm.font("IBM Plex Mono")
      config.window_close_confirmation = 'NeverPrompt'
      return config
    '';
  };
}
