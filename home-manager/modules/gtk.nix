{ pkgs, ... }:

{
  gtk = {
    enable = true;

    # Единая настройка тёмной темы для GTK3/GTK4 (libadwaita apps)
    colorScheme = "dark";

    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };

    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };

    cursorTheme = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
      size = 24;
    };

    font = {
      name = "Sans";
      size = 11;
    };

    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };

    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };
  };

  # Указывает Qt/иным приложениям и порталам, что предпочтителен тёмный режим
  home.sessionVariables = {
    GTK_THEME = "Adwaita:dark";
  };
}
