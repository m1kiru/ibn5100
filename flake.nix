{
  description = "makiru's ibn5100 conf";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    fetch = { 
      url = "github:areofyl/fetch";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    anidesk.url = "path:/media/games/anidesk";
    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    freesmlauncher = {
      url = "github:FreesmTeam/FreesmLauncher";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, chaotic, anidesk, zen-browser, freesmlauncher, fetch, home-manager,... } @ inputs: {
    nixosConfigurations = {
      ibn5100 = nixpkgs.lib.nixosSystem {
        #system = "x86_64-linux";
        modules = [
          nixpkgs.nixosModules.readOnlyPkgs

          ./configuration.nix

          {
            nixpkgs.pkgs = import nixpkgs {
              system = "x86_64-linux";
              config = { allowUnfree = true; };
              overlays = [ chaotic.overlays.cache-friendly ];
            };
            chaotic.nyx.overlay.enable = false;
          }          
          chaotic.nixosModules.default

          # anidesk module
          ({ pkgs, ... }: {
            environment.systemPackages = [
              (anidesk.packages.x86_64-linux.default.overrideAttrs (old: {
                nativeBuildInputs = (old.nativeBuildInputs or []) ++ [ pkgs.makeWrapper ];
                postInstall = (old.postInstall or "") + ''
                  wrapProgram $out/bin/anidesk \
                    --add-flags "--no-sandbox " \
                    --add-flags "--enable-unsafe-webgpu" \
                    --add-flags "--ozone-platform=x11" \
                    --add-flags "--use-angle=vulkan" \
                    --add-flags "--enable-features=Vulkan,VulkanFromANGLE"
                '';
              }))
            ];
          })
          # anidesk module

          # zen-browser module
          ({ pkgs, ... }: {
            environment.systemPackages = [
              (pkgs.symlinkJoin {
                name = "zen-browser-with-ffmpeg";
                paths = [ zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default ];
                buildInputs = [ pkgs.makeWrapper ];
                postBuild = ''
                  wrapProgram $out/bin/zen \
                    --prefix LD_LIBRARY_PATH : "${pkgs.ffmpeg-full.lib}/lib"
                '';
              })
            ];
          })
          # zen-browser module
          
          # fetch module
          ({ pkgs, ... }: {
            environment.systemPackages = [
              fetch.packages.${pkgs.stdenv.hostPlatform.system}.default
            ];
          })
          # fetch module
          
          # freesm module
          ({ pkgs, ... }: {
            environment.systemPackages = [
              freesmlauncher.packages.${pkgs.stdenv.hostPlatform.system}.freesmlauncher
            ];
            nix.settings = {
              substituters = [
                "https://freesmlauncher.cachix.org"
              ];
              trusted-public-keys = [
                "freesmlauncher.cachix.org-1:Jcp5Q9wiLL+EDv8Mh7c6L9xGk+lXr7/otpKxMOuBuDs="
              ];
            };
          })
          # freesm module
          
          #home-manager module
          home-manager.nixosModules.default
          {
          home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = { inherit inputs; };
              users.makiru = ./home.nix; 
            };
          }
          #home-manager module
        ];
      };
    };
  };
}
