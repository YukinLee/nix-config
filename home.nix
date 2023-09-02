{ config, pkgs, nurpkgs, username, ... }:

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

  programs.home-manager.enable = true;

  services.lorri.enable = true;

  manual.manpages.enable = false;
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
    homeDirectory = "/home/{username}";
    homestateVersion = "22.11";
  };

  home.packages = with pkgs;
    [
      p7zip
      ripgrep
      # nheko
      git
      tdesktop
      anki-bin
      # direnv
      xkb-switch
      firefox
      vivaldi
      microsoft-edge
      vlc
      wpsoffice-cn
      buttercup-desktop
      mathpix-snipping-tool
      citra-canary
      jupyter
      foliate
      zulip
      slack
      discord
      emacs
      nur.repos.linyinfeng.icalingua-plus-plus
      nur.repos.YisuiMilena.hmcl-bin
      nur.repos.linyinfeng.clash-for-windows
      # nur.repos.linyinfeng.wemeet
      # nur.repos.xddxdd.baidupcs-go
      #nur.repos.uniquepointer.riscv64-linux-gnu-toolchain
      wllvm
      xterm
      zotero
      obsidian
      helix
      mpv
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

  programs.tmux = {
    enable = true;
    clock24 = true;
    keyMode = "vi";
    extraConfig = ''
      set -g default-terminal "tmux-256color" # 256 colors
      set -ga terminal-overrides ",*:Tc"      # true color

      # remap prefix from 'C-b' to 'C-a'
      unbind C-b
      set-option -g prefix C-a
      bind-key C-a send-prefix

      # reload config file (change file location to your the tmux.conf you want to use)
      bind r source-file ~/.config/.tmux/tmux.conf

      # split panes using | and -
      bind | split-window -h
      bind - split-window -v
      unbind '"'
      unbind %

      # switch panes using Alt-arrow without prefix
      bind -n M-Left select-pane -L
      bind -n M-Right select-pane -R
      bind -n M-Up select-pane -U
      bind -n M-Down select-pane -D

      # Enable mouse mode (tmux 2.1 and above)
      set -g mouse on

      set -g status-style bg=default          # transparent status bar
      # show hint when pressing prefix, https://stackoverflow.com/a/15308651/
      set -g status-right ' #{?client_prefix,#[reverse]<Prefix>#[noreverse] ,}"#{=21:pane_title}" %H:%M %d-%b-%y'
    '';
  };

  programs.zsh =
    let
      home = "";
    in
    {
      enable = true;
      dotDir = ".config/zsh";
      shellAliases = {
        ll = "ls -l";
        update = "sudo nixos-rebuild switch";
        okular = "Exec=/usr/bin/env QT_QPA_PLATFORM=xcb okular";
        vim = "nvim";
        cat = "bat";
      };

      # [Zplug]
      zplug = {
        enable = true;
        plugins = [
          {
            name = "romkatv/powerlevel10k";
            tags = [ as:theme depth:1 dir:$HOME/.config/zsh/custom/themes/powerlevel10k ];
          }
          {
            name = "zsh-users/zsh-completions";
            tags = [ as:plugin dir:$HOME/.config/zsh/custom/plugins/zsh-completions ];
          }
        ];
      };

      # TO APPLY .bashrc FIRST
      initExtraFirst = ''
                  export NIX_HOME_CONFIG=$HOME/.config/nixpkgs/home.nix
        	        export NEMU_HOME=/home/yukin/code/ics2021/nemu
                  export AM_HOME=/home/yukin/code/ics2021/abstract-machine

                  bindkey "^[[1;5C" forward-word
                  bindkey "^[[1;5D" backward-word
        		      bindkey '^H' backward-kill-word
                  bindkey -r '^a'

                  if [ -z "$__ETC_PROFILE_DONE" ]; then
                        . /etc/profile
                  fi

                  command_not_found_handle() {
                          local p='/nix/store/mk2gk14y1gswz7y8z7fsby1s8x9xc0di-command-not-found/bin/command-not-found'
                          if [ -x "$p" ] && [ -f '/nix/var/nix/profiles/per-user/root/channels/nixos/programs.sqlite' ]; then
                            # Run the helper program.
                            "$p" "$@"
                            # Retry the command if we just installed it.
                            if [ $? = 126 ]; then
                              "$@"
                            else
                              return 127
                            fi
                          else
                            echo "$1: command not found" >&2
                            return 127
                          fi
                  }
      '';
      initExtra = ''
        eval "$(direnv hook zsh)"
      '';

      localVariables = {
        POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD = true;
      };

      enableAutosuggestions = true;
      enableSyntaxHighlighting = true;
      enableCompletion = true;
      enableVteIntegration = true;
      defaultKeymap = "emacs";

      # [oh-my-zsh]
      oh-my-zsh = {
        enable = true;

        # Specify the default directory for searching Themes and Plugins
        custom = "$HOME/.config/zsh/custom";

        plugins = [
          "git"
          "direnv"
          "dirhistory"
          "zsh-completions"
          "z"
        ];
        theme = "powerlevel10k/powerlevel10k";
        extraConfig = ''
          source $HOME/.config/zsh/.p10k.zsh
        '';
      };
    };


  programs.vscode = {
    enable = true;
    package = pkgs.vscode;
    extensions = with pkgs.vscode-extensions; [
      vscodevim.vim
      # asvetliakov.vscode-neovim
      alefragnani.project-manager
      ms-python.python
      ms-pyright.pyright
      spywhere.guides
      eamodio.gitlens
      adpyke.codesnap
      ms-toolsai.jupyter
      mhutchie.git-graph
      redhat.vscode-yaml
      eugleo.magic-racket
      ibm.output-colorizer
      ritwickdey.liveserver
      file-icons.file-icons
      gruntfuggly.todo-tree
      alefragnani.bookmarks
      esbenp.prettier-vscode
      dbaeumer.vscode-eslint
      codezombiech.gitignore
      james-yu.latex-workshop
      yzhang.markdown-all-in-one
      ms-vsliveshare.vsliveshare
      arrterian.nix-env-selector
      ms-vscode.cpptools
      chenglou92.rescript-vscode
      llvm-vs-code-extensions.vscode-clangd
      ocamllabs.ocaml-platform
    ];
    # ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
    #   {
    #     name = "rescript-vscode";
    #     publisher = "chenglou92";
    #     version = "1.12.0";
    #     sha256 = "sha256-3zNYORpH7YS5uhBBaxrisrUHhRLKM6C+Z1ZjoqLVsks=";
    #   }
    # ];
  };

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
