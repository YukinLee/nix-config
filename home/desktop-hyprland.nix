{ config, lib, pkgs, nurpkgs, username, ... }:

let
  # androidSdkModule = import ((builtins.fetchGit {
    # url = "https://github.com/tadfisher/android-nixpkgs.git";
    # ref = "main";  # Or "stable", "beta", "preview", "canary"
  # }) + "/hm-module.nix");
  nur = import nurpkgs {
    inherit pkgs;
    nurpkgs = pkgs;
  };
in
{
  # imports = [ androidSdkModule ];
  imports = [
    ./tools.nix #done
    ./system-tools.nix #done
    ./desktop-apps.nix #done
    ./vscode.nix #done
    ./helix.nix #done
    ./neovim.nix
    ./tmux.nix #done
    ./fcitx5 #done
    ./zsh #done
  ];


  # home.sessionVariables.NIXOS_OZONE_WL = "1";

  # android-sdk.path = "${config.home.homeDirectory}/Android/Sdk";
  # android-sdk.packages = sdkPkgs: with sdkPkgs; [
  #   build-tools-31-0-0
  #   cmdline-tools-latest
  #   emulator
  #   platforms-android-31
  #   sources-android-31
  # ];

  # Desktop Entries Configuration
  # xdg.desktopEntries = {
  #   okular = {
  #     exec = "Exec=/usr/bin/env QT_QPA_PLATFORM=xcb okular %U";
  #   };
  # };

  home = {
    username = username;
    homeDirectory = lib.mkForce "/home/${username}";
    stateVersion = "22.11";
  };

  programs.home-manager.enable = true;

  home.packages = with pkgs;
    [
      microsoft-edge
      jupyter
      emacs
      #nur.repos.uniquepointer.riscv64-linux-gnu-toolchain
      wllvm
    ]
    ++
    [ clang
      clang-tools
      nil
      llvm
      llvm-manpages
      # llvmPackages.bintools
      nixpkgs-fmt
    ];

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [
    "qtwebkit-5.212.0-alpha4"
  ];


  programs.neovim = {
    enable = true;
    package = pkgs.neovim-unwrapped;
    extraConfig = '''';
  };

  programs.java = {
    enable = true;
    package = pkgs.jdk17;
  };

  programs.git = {
    enable = true;
    userEmail = "lysanleo347@outlook.com";
    userName = "Lysanleo";
    extraConfig = {
      core = {
        editor = "nvim";
      };
    };
  };
}
