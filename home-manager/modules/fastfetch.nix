{
  programs.fastfetch = {
    enable = true;
    settings = {
      modules = [
        "title"
        "separator"
        "os"
        "host"
    	"kernel"
   	"uptime"
        "packages"
	"shell"
        "display"
  	"de"
 	"wm"
        "wmtheme"
        "theme"
        "icons"
    	"font"
        "cursor"
        "terminal"
        "terminalfont"
        "cpu"
        "gpu"
        "memory"
        "swap"
        "disk"
        "locale"
        "break"
        "colors"
      ];
    };
  };
}
