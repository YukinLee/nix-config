{
  description = "Poolo's NixOS Flake";

  # Overriding nix's own settings
  nixConfig = {
    experimental-features = [ "nix-command" "flakes" ];
    substituters = [
      # replace official cache with a mirror located in China
      "https://mirrors.ustc.edu.cn/nix-channels/store"
      "https://mirror.sjtu.edu.cn/nix-channels/store"
      "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
      "https://cache.nixos.org/"
    ];
    # nix community's cache server
    extra-substituters = [
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  inputs = {
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-23.05";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nurpkgs.url = "github:nix-community/NUR";
    hyprland.url = "github:hyprwm/Hyprland/v0.28.0";
    anyrun = {
      url = "github:Kirottu/anyrun";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ { 
    self, 
    nixpkgs-stable, 
    nixpkgs,
    home-manager, 
    nurpkgs, 
    ... 
  }: let
    username = "yukin";
    x64_system = "x86_64-linux";
    system = x64_system;
    nixosSystem = import ./lib/nixosSystem.nix;
    # modules for yukin with kde
    yukin_laptop_kde = {
      nixos-modules = [
        nurpkgs.nixosModules.nur
        ./hosts/yukin-laptop
        ./modules/nixos/plasma.nix
      ];
      home-module = import ./home/desktop-plasma.nix;
    };
    # modules for yukin with hyprland
    yukin_laptop_hyprland = {
      nixos-modules = [
        nurpkgs.nixosModules.nur
        ./hosts/yukin-laptop
        ./modules/nixos/hyprland.nix
      ];
      home-module = import ./home/desktop-hyprland.nix;
    };
  in {
    nixosConfigurations = let
      specialArgs = {
        inherit username;
        pkgs = import nixpkgs {
          system = x64_system;
          config.allowUnfree = true;
          config.permittedInsecurePackages = [
            "qtwebkit-5.212.0-alpha4"
          ];
        };
      } // inputs;        
      base_args = {
        inherit home-manager system specialArgs;
      };
      stable_args = base_args // {inherit nixpkgs-stable;};
      unstable_args = base_args // {nixpkgs = nixpkgs;};
    in {
      # The arguments of nixosSystem is seperated into modules and args.
      yukin_kde = nixosSystem (yukin_laptop_kde // unstable_args);
      yukin_hyprland = nixosSystem (yukin_laptop_hyprland // unstable_args);
      # sudo nixos-rebuild switch --flake .#yukin-laptop
      yukin-laptop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs; # 将 inputs 中的参数传入所有子模块
        home-manager.useGlobalPkgs = true;
        modules = [           # NixOS config's Nix Module
          ./configuration.nix
          nurpkgs.nixosModules.nur
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            home-manager.extraSpecialArgs = inputs;
            home-manager.users.yukin = import ./home.nix;
          }
        ];
      };
    };
  };
}
