{ pkgs, ... }:

{
  programs.waybar = {
    enable = true;
    package = pkgs.waybar;

    settings = {
      mainBar = {
        # "layer": "top",
        # "position": "bottom",
        height = 30;
        # width = 1280;
        # spacing = 4;

        modules-left = [ "niri/workspaces" ];
        modules-center = [ "niri/window" ];
        modules-right = [
          "tray"
          "pulseaudio"
          "network"
          "niri/language"
          "clock"
        ];

        tray = {
          icon-size = 15;
          spacing = 15;
        };

        clock = {
          # timezone = "Asia/Yekaterinburg";
          format = "{:%H:%M:%S %Y.%m.%d}";
          tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
          interval = 1;
          # format-alt = "{:%Y-%m-%d}";
        };

        network = {
          # interface = "wlp2*";
          format-wifi = "{essid} ({signalStrength}%) ";
          format-ethernet = "{ipaddr}/{cidr} 󰊗";
          tooltip-format = "{ifname} via {gwaddr} 󰊗";
          format-linked = "{ifname} (No IP) 󰊗";
          format-disconnected = "Disconnected ⚠";
          format-alt = "{ifname}: {ipaddr}/{cidr}";
        };

        pulseaudio = {
          # scroll-step = 10;
          format = "{volume}% {icon} {format_source}";
          format-bluetooth = "{volume}% {icon} {format_source}";
          format-bluetooth-muted = "󰅶 {icon} {format_source}";
          format-muted = "󰅶 {format_source}";
          format-source = "{volume}% ";
          format-source-muted = "";
          format-icons = {
            headphone = "";
            hands-free = "󰂑";
            headset = "󰂑";
            phone = "";
            portable = "";
            car = "";
            default = ["" "" ""];
          };
          on-click = "pavucontrol";
        };
      };
    };

    style = ''
      * {
          /* `otf-font-awesome` is required to be installed for icons */
          font-family: FontAwesome_7, IBM Plex Mono;
          font-size: 15px;
      }
      /*:root {
          --main-color: rgba(0, 0, 0, 1.0);
          --font-color: rgb(255 ,255, 255);
      }*/
      window#waybar {
          background-color: rgba(0, 0, 0, 0.5);
          color: #ffffff;
          transition-property: background-color;
          transition-duration: 0.5s;
      }

      window#waybar.termite {
          background-color: #3f3f3f;
      }

      button {
          box-shadow: inset 0 -3px transparent;
          border: none;
          border-radius: 0;
      }

      button:hover {
          background: inherit;
          /*box-shadow: inset 0 -3px #ffffff;*/
      }

      #pulseaudio:hover {
          background-color: rgba(0, 0, 0, 0);
          color: white;
      }

      #workspaces button {
          padding: 0 5px;
          background-color: transparent;
          color: #ffffff;
      }

      #workspaces button:hover {
          background: white;
          color: black;
      }

      #workspaces button.focused,
      #workspaces button.active {
          background-color: #ffffff;
          color: #000000;
          /*box-shadow: inset 0 -3px #ffffff;*/
      }

      #workspaces button.visible,
      #workspaces button.persistent,
      #workspaces button.inactive {
          background-color: #ffffff;
      }

      #clock,
      #network,
      #pulseaudio,
      #wireplumber,
      #tray {
          padding: 0 10px;
          color: #ffffff;
      }

      #window,
      #workspaces {
          margin: 0 4px;
      }

      .modules-left > widget:first-child > #workspaces {
          margin-left: 0;
      }

      .modules-right > widget:last-child > #workspaces {
          margin-right: 0;
      }

      #clock {
          background-color: rgba(0, 0, 0, 0);
      }

      @keyframes blink {
          to {
              background-color: #ffffff;
              color: #000000;
          }
      }

      label:focus {
          background-color: #000000;
      }

      #network {
          background-color: rgba(0, 0, 0, 0);
          color: rgba(256, 256, 256, 1);
      }

      #network.disconnected {
          background-color: #f53c3c;
      }

      #pulseaudio {
          background-color: rgba(0, 0, 0, 0);
          color: rgba(256, 256, 256, 1);
      }

      #pulseaudio.muted {
          background-color: #90b1b1;
          color: #2a5c45;
      }

      #wireplumber {
          background-color: #fff0f5;
          color: #000000;
      }

      #wireplumber.muted {
          background-color: #f53c3c;
      }

      #tray {
          background-color: rgba(0, 0, 0, 0);
      }

      #tray > .passive {
          -gtk-icon-effect: dim;
      }

      #tray > .needs-attention {
          -gtk-icon-effect: highlight;
          background-color: #eb4d4b;
      }

      #language {
          background: none;
          color: white;
          padding: 0 5px;
          margin: 0 5px;
          min-width: 20px;
      }

      #privacy {
          padding: 0;
      }

      #privacy-item {
          padding: 0 5px;
          color: white;
      }

      #privacy-item.screenshare {
          background-color: #cf5700;
      }

      #privacy-item.audio-in {
          background-color: #1ca000;
      }

      #privacy-item.audio-out {
          background-color: #0069d4;
      }
    '';
  };
}
