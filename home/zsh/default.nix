{config, lib, pkgs, ...}: {
  

  programs.zsh = let
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
}