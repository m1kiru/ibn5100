{ pkgs, lib, ... }:

{
  xdg.portal = {
    enable = true;

    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk    # FileChooser, Settings и др.
      xdg-desktop-portal-wlr    # ScreenCast/Screenshot для wlroots-компоузеров (niri, sway, ...)
    ];

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
