{ pkgs, lib, ... }:

{
  qt = {
    enable = true;
    platformTheme.name = "qtct";
    style.name = "adwaita-dark"; # можно сменить на "fusion", см. примечание в чате

    # Нативная опция home-manager: пишет прямо в ~/.config/qt5ct/qt5ct.conf
    # Списки транслируются в CSV-строку автоматически, шрифты — в кавычках как есть.
    qt5ctSettings = {
      Appearance = {
        color_scheme_path = "/home/makiru/.config/qt5ct/colors/mono.conf";
        custom_palette = true;
        standard_dialogs = "gtk3";
        style = "Fusion";
      };
      Fonts = {
        fixed = ''"IBM Plex Serif,10,-1,5,50,0,0,0,0,0,Regular"'';
        general = ''"IBM Plex Sans,10,-1,5,50,0,0,0,0,0,Regular"'';
      };
      Interface = {
        activate_item_on_single_click = 1;
        buttonbox_layout = 0;
        cursor_flash_time = 1000;
        dialog_buttons_have_icons = 1;
        double_click_interval = 400;
        keyboard_scheme = 2;
        menus_have_icons = true;
        show_shortcuts_in_context_menus = true;
        toolbutton_style = 4;
        underline_shortcut = 1;
        wheel_scroll_lines = 3;
      };
      Troubleshooting = {
        force_raster_widgets = 1;
      };
    };
  };

  home.packages = with pkgs; [
    libsForQt5.qt5ct
    qt6Packages.qt6ct
  ];

  # Файл цветовой схемы, на который ссылается color_scheme_path выше.
  # Это отдельный файл (не покрывается qt5ctSettings), поэтому кладём его
  # вручную через xdg.configFile.
  xdg.configFile."qt5ct/colors/mono.conf".text = ''
    [ColorScheme]
    active_colors=#ffffff, #000000, #ffffff, #ffffff, #000000, #000000, #ffffff, #ffffff, #ffffff, #000000, #000000, #000000, #ffffff, #000000, #ffffff, #ffffff, #000000, #000000, #000000, #ffffff, #aaaaaa
    inactive_colors=#aaaaaa, #000000, #ffffff, #ffffff, #000000, #000000, #aaaaaa, #ffffff, #aaaaaa, #000000, #000000, #000000, #aaaaaa, #000000, #aaaaaa, #aaaaaa, #000000, #000000, #000000, #ffffff, #777777
    disabled_colors=#555555, #000000, #333333, #222222, #000000, #000000, #555555, #888888, #555555, #000000, #000000, #000000, #333333, #555555, #555555, #444444, #000000, #000000, #000000, #555555, #444444
  '';
}
