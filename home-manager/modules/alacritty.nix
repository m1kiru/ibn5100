{
  programs.alacritty = {
    enable = true;
    settings = {
      colors = {
        primary.background = "#000000";
        primary.foreground="#FFFFFF";
        cursor = {
          text="#000000";
          cursor="#FFFFFF";
        };
        normal.black="#555555";
        normal.red="#FF0000";
        normal.green="#00FF00";
        normal.yellow="#AA5500";
        normal.blue="#0000FF";
        normal.magenta="#AA00AA";
        normal.cyan="#00AAAA";
        normal.white="#FFFFFF";
        search.matches = {
          foreground="#FF0000";
          background="#000000";
        };
        search.focused_match = {
          foreground="#FF0000";
          background="#FFFFFF";
        };
        transparent_background_colors = true;
        selection = {
          text = "#000000";
          background = "#FFFFFF";
        };
      };
      font = {
        normal={
          family = "IBM Plex Mono";
          style="Regular";
        };
        bold={
          family = "IBM Plex Mono";
          style="Bold";
        };
        italic={
          family = "IBM Plex Mono";
          style="Italic";
        };
        bold_italic = {
          family = "IBM Plex Mono";
          style="Bold Italic";
        };
      };
      window = {
        padding = {
          x = 0;
          y = 0;
        };
        opacity=0.5;
      };
    };
  };
}
