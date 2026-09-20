{ pkgs, ... }:

{
  services.mako = {
    enable = true;
    package = pkgs.mako;

    settings = {
      font = "IBM Plex Mono 11";

      width = 350;
      height = 150;
      margin = "14";
      padding = "10";

      border-size = 2;
      border-radius = 0;

      background-color = "#000000B3"; 
      border-color = "#FFFFFF";
      text-color = "#FFFFFF";
      progress-color = "over #FFFFFF";

      default-timeout = 5000;
      ignore-timeout = false;

      layer = "top";
      anchor = "top-center";

      icons = true;
      max-icon-size = 48;

      "urgency=low" = {
        border-color = "#555555";
        default-timeout = 3000;
      };

      "urgency=critical" = {
        border-color = "#FF0000";
        default-timeout = 0; # критичные уведомления не скрываются сами
      };
    };
  };
}
