{
  description = "glowz @ nix — TEST flake using ncs-nix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ncs = {
      url = "github:glowwz/ncs-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    quickshell = {
      url = "git+https://git.outfoxxed.me/quickshell/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zsh-fzf-tab                  = { url = "github:Aloxaf/fzf-tab";                         flake = false; };
    zsh-autosuggestions          = { url = "github:zsh-users/zsh-autosuggestions";           flake = false; };
    zsh-syntax-highlighting      = { url = "github:zsh-users/zsh-syntax-highlighting";       flake = false; };
    zsh-history-substring-search = { url = "github:zsh-users/zsh-history-substring-search"; flake = false; };

    helium.url = "github:schembriaiden/helium-browser-nix-flake";

    _0fetch = {
      url = "github:peachey2k2/0fetch";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ncs, quickshell, ... }@inputs: {
    nixosConfigurations.nix = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        ./configuration.nix
        ncs.nixosModules.default
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = { inherit inputs; };
          home-manager.users.glowz = import ./home.nix;
        }
      ];
    };
  };
}
