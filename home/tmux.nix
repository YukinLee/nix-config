{
  config,
  pkgs,
  ...
}: {
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
}
