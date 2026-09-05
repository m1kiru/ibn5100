{ config, pkgs, ... }:

{
  imports = [ ./home-manager/modules ];
  home.stateVersion = "26.11";
}
