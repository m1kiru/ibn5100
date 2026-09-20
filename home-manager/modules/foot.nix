{ pkgs, ... }:

{
  programs.foot = {
    enable = true;
    package = pkgs.foot;

    settings = {
      main = {
        font = "IBM Plex Mono:size=11";
        pad = "0x0";
      };

      colors = {
        # background / foreground — как в kitty.nix / alacritty.nix
        alpha = "0.5";
        background = "000000";
        foreground = "ffffff";

        # курсор — в foot цвет курсора в секции [colors], не [cursor]
        cursor = "000000 ffffff";

        selection-foreground = "000000";
        selection-background = "ffffff";

        # normal palette
        regular0 = "555555"; # black
        regular1 = "ff0000"; # red
        regular2 = "00ff00"; # green
        regular3 = "aa5500"; # yellow
        regular4 = "0000ff"; # blue
        regular5 = "aa00aa"; # magenta
        regular6 = "00aaaa"; # cyan
        regular7 = "ffffff"; # white

        # bright palette — дублирует normal как в kitty.nix
        bright0 = "555555";
        bright1 = "ff0000";
        bright2 = "00ff00";
        bright3 = "aa5500";
        bright4 = "0000ff";
        bright5 = "aa00aa";
        bright6 = "00aaaa";
        bright7 = "ffffff";

        # url/search — аналог url_color в kitty.nix
        urls = "ff0000";
      };
    };
  };
}
