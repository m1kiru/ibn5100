{
  description = "makiru's ibn5100 conf";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    anidesk.url = "path:./anidesk";
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

  outputs = { self, nixpkgs, chaotic, anidesk, zen-browser, freesmlauncher, home-manager,... } @ inputs: {
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
              zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
            ];
          })
          # zen-browser module

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
              extraSpecialArgs = { inherit inputs; }; #If you want access to inputs in your home.nix
              users.makiru = ./home.nix; 
            };
          }
          #home-manager module
        ];
      };
    };
  };
}
