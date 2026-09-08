{ pkgs, lib, ... }:

{
  xdg.portal = {
    enable = true;

    # Устанавливаем нужные бэкенды-реализации
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk    # FileChooser, Settings и др.
      xdg-desktop-portal-wlr    # ScreenCast/Screenshot для wlroots-компоузеров (niri, sway, ...)
      # xdg-desktop-portal-gnome  # можно убрать вовсе, если не нужен Nautilus/GNOME-специфика
    ];

    # Явно назначаем бэкенд для КАЖДОГО интерфейса —
    # так gtk не "перебивается" молча зависшим gnome-порталом
    config = {
      common = {
        default = [ "gtk" ];
      };

      niri = {
        default = lib.mkForce [ "gtk" ];
        "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
        "org.freedesktop.impl.portal.ScreenCast" = [ "wlr" ];
        "org.freedesktop.impl.portal.Screenshot" = [ "wlr" ];
        "org.freedesktop.impl.portal.Notification" = [ "gtk" ];
        "org.freedesktop.impl.portal.Settings" = [ "gtk" ];
      };
    };
  };
}
