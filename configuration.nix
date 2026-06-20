# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # NixEspecially
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
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
  # IOS
  services.usbmuxd.enable = true;
  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_zen;
  # Dynamically linked executables
  networking.hostName = "ibn5100"; # Define your hostname.

  # Configure network connections interactively with nmcli or nmtui.
  networking.networkmanager.enable = true;

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
  i18n.extraLocales = ["ja_JP.UTF-8/UTF-8"];
  
  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true; # use xkb.options in tty.
  };

  # X11 & nvidia sect
  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;
  services.xserver = { 
    enable = true;
    videoDrivers = [ "nvidia" ];
  };
  hardware.nvidia = {
    open = false;
    modesetting.enable = true; 
  };
  services.lact.enable = true;
  # Gaming sect
  programs.steam = {
  enable = true;
  dedicatedServer.openFirewall = true;
  };
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "steam"
    "steam-unwrapped"
  ];
  # Gnome sect
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;
  services.gnome.core-apps.enable = false;
  services.gnome.core-developer-tools.enable = false; 
  services.gnome.games.enable = false;
  environment.gnome.excludePackages = with pkgs; [ gnome-tour gnome-user-docs];
  
  # Configure keymap in X11
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
  
  # NixSpecialSettings sect
  nixpkgs.config.allowUnfree = true;



  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.makiru = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager"]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [ ];
  };
  # programs.firefox.enable = true;
  # Hamachi
  services.zerotierone = {
    enable = true;
  };

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  
  environment.systemPackages = with pkgs; [
    wget
    google-chrome
    gnome-tweaks
    alacritty
    nautilus
    clementine 
    libimobiledevice
    ifuse
    gnome-text-editor
    git
    protonup-qt
    fastfetch
    nftables
    lact
    btop
    gamemode
    appeditor
    vlc
    # Unstable
    discord
    android-studio
    ayugram-desktop
    amnezia-vpn
    vscodium
    code-cursor
    v2rayn
    lmstudio
    qbittorrent
  ];

  environment.variables = {
    "__GL_SHADER_DISK_CACHE_SIZE" = "12000000000";
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
    QT_QPA_PLATFORMTHEME = "qt5ct";
  };
  # Strawberry fix
  environment.sessionVariables.XDG_DATA_DIRS = [ "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}" "${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}" ];
  # Flatpak
  #services.flatpak.enable = true;
  # V2ray
  #services.v2rayn.enable = true;
  #anidesk, hiddify
  
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      glib
      nspr
      nss
      dbus
      atk
      cups
      cairo
      gtk3
      pango
      libx11
      libxcomposite
      libxdamage
      libxext
      libxfixes
      libxrandr
      libgbm
      expat
      libxcb
      libxkbcommon
      alsa-lib-with-plugins
      libGL
    ];
  };
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
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.11"; # Did you read the comment?

}

