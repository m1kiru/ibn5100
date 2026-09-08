{ config, lib, pkgs, ... }:

let
  nvidiaLegacy580Free = pkgs.linuxPackages_cachyos.nvidiaPackages.legacy_580.overrideAttrs (old: {
    meta = old.meta // { license = lib.licenses.mit; };
  });
in
{
  imports =
    [
      ./hardware-configuration.nix
      ./modules
    ];
  # Zram
  zramSwap = {
    enable = true;
    priority = 100;
    algorithm = "lz4";
    memoryPercent = 50;
  };
  # GRUB
  boot.loader = {
    grub = {
      enable = true;
      device = "nodev";
      efiSupport = true;
    #  useOSProber = true;
    };
    efi.canTouchEfiVariables = true;
  };
  # Bash
  programs.bash = {
    shellAliases = {
      lla = "ls -al";
      rebuild = "sudo nixos-rebuild switch";     
      grep = "grep --color";
    };
  };
  # Flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  #nix.settings.accept-flake-config = false;
  # Allow unfree pkgs
  #nixpkgs.config.allowUnfree = true;
  #};
  # nix-ld
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      icu
    ];
  };
  # Mount ntfs drives
  fileSystems =
    let
      ntfs-drives = [
  	"/media/games"
        "/media/forgames"
        "/media/fordocs"
      ];
    in
    lib.genAttrs ntfs-drives (path: {
      options = [
        "uid=1000"
        "nofail"
      ];
    });
  # Kernel
  boot.kernelPackages = pkgs.linuxPackages_cachyos;
  # Define your hostname.
  networking.hostName = "ibn5100";
  # niri
  programs.niri.enable = true;
  security.polkit.enable = true; # polkit
  # Ly login mnger
  services.displayManager.ly.enable = true;
  # Configure network connections interactively with nmcli or nmtui.
  networking.networkmanager = {
    enable = true;
    wifi = {
      scanRandMacAddress = true;
      macAddress = "random";
    };
  };
  # VPN
  #programs.amnezia-vpn.enable = true;
  programs.throne = {
    enable = true;
    tunMode.enable = true;
  };
  # nftables
  networking.nftables.enable = true;
  # cloudflare warp
  services.cloudflare-warp.enable = true;
  # Set your time zone.
  time.timeZone = "Asia/Yekaterinburg";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "ru_RU.UTF-8";
  # Optionally
  i18n.extraLocaleSettings = {
    LC_ALL = "ru_RU.UTF-8";
  };
  # Extra locales to use
  #i18n.extraLocales = ["ja_JP.UTF-8/UTF-8"];

  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true; # use xkb.options in tty.
  };
  # Bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = false;
  };
  # X11 & nvidia sect
  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;
  services.xserver = {
    enable = true;
    videoDrivers = lib.mkDefault [ "nvidia" ];
  };
  hardware.nvidia = {
    open = false;
    modesetting.enable = true;
    package = nvidiaLegacy580Free;
    videoAcceleration = true;
    nvidiaSettings = false;
  };
  # Steam
  programs.steam = {
    enable = true;
    dedicatedServer.openFirewall = true;
    extraCompatPackages = [ pkgs.proton-cachyos_x86_64_v3 ];
  };
  programs.gamemode.enable = true; 
  programs.gamescope = {
    enable = true;
    enableWsi = true;
    capSysNice = false;
  }; 
  # web.io.vision
  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ATTR{idVendor}=="0c45", ATTR{idProduct}=="fefe", MODE="0666"
    SUBSYSTEM=="usb", ATTR{idVendor}=="0c45", ATTR{idProduct}=="8009", MODE="0666"
    KERNEL=="hidraw*", ATTRS{idVendor}=="0c45", ATTRS{idProduct}=="fefe", MODE="0666"
    KERNEL=="hidraw*", ATTRS{idVendor}=="0c45", ATTRS{idProduct}=="8009", MODE="0666"
'';
  # X11 keyboard
  services.xserver.xkb.layout = "us,ru";
  services.xserver.xkb.options = "grp:win_space_toogle";
  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.makiru = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [ ];
  };
  
  # Fonts
  fonts = {
    packages = with pkgs; [
      ibm-plex
      font-awesome_7
  ];
     fontconfig = {
        defaultFonts = {
          serif = ["IBM Plex Serif"];
          sansSerif = ["IBM Plex Sans"];
          monospace = ["IBM Plex Mono"];
        };
     };
  };
  environment.systemPackages = with pkgs; [
    wget
    clementine
    git
    ayugram-desktop
    qbittorrent
    libsForQt5.qt5ct
    calc
    pavucontrol
    playerctl
    unzip
    unrar
    _7zip-zstd
    xwayland-satellite
    libayatana-appindicator
    libxcursor
    xcursor-themes
    adwaita-icon-theme
    adwaita-icon-theme-legacy
    gnome-themes-extra
    nvidia-vaapi-driver
    zed-editor-fhs
    protonplus
    progress
    imv
    mpv
    ffmpeg
    yt-dlp
    android-file-transfer
    wl-clipboard
    ncdu
    tree
    nicotine-plus
    hydralauncher
    gamemode
    mangohud
    winetricks
    sl
    fastfetch
    cava
    proton-cachyos_x86_64_v3
    python3
    wineWow64Packages.stable
    qdiskinfo
    rpcs3
    localsend
    (nvidiaLegacy580Free.settings.overrideAttrs (old: {
      meta = old.meta // { license = lib.licenses.mit; };
    }))
  ];
  # /environment
  environment.variables = {
    __GL_SHADER_DISK_CACHE_SIZE = "12000000000";
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
    XCURSOR_SIZE = "24";
    NVD_BACKEND = "direct";
    LIBVA_DRIVER_NAME = "nvidia";
    MOZ_DISABLE_RDD_SANDBOX = "1";
    ZED_ALLOW_ROOT= "true";
  };

  # AppImage
  #programs.appimage.enable = true;
  #programs.appimage.binfmt = true;
  # Flatpak
  services.flatpak.enable = true;
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };
  # List services that you want to enable:
  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [
    53317
  ];
  networking.firewall.allowedUDPPorts = [
    53317
  ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  system = {
    stateVersion = "26.05";
    activationScripts.protonCachyosCompatTool = {
      text = ''
        mkdir -p /home/makiru/.local/share/Steam/compatibilitytools.d
        rm -rf /home/makiru/.local/share/Steam/compatibilitytools.d/proton-cachyos
        cp -rL ${pkgs.proton-cachyos_x86_64_v3}/bin /home/makiru/.local/share/Steam/compatibilitytools.d/proton-cachyos
        chown -R makiru:users /home/makiru/.local/share/Steam/compatibilitytools.d/proton-cachyos
        '';
      deps = [];
      };
  };
}
