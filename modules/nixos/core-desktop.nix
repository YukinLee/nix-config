{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
   ./core-server.nix 
  ];

  nixpkgs.config.allowUnfree = lib.mkForce true;

  environment.shells = with pkgs; [
    bash
    nushell
    zsh
  ];
  
  users.defaultUserShell = pkgs.zsh;

  environment.systemPackages = with pkgs; [
    (python311.withPackages (ps:
      with ps; [
        ipython
        pandas
        requests
      ]
    ))
    cmake
    gnumake
    vte
    unzip
    direnv
    nix-direnv
    proxychains-ng
  ];

  programs = {
    kdeconnect.enable = true;
    adb.enable = true;
    zsh.enable = true;
    xwayland.enable = true;
    ssh.startAgent = true;
  };


  # Enable sound.
  sound.enable = true;

  # Solve the poping/craking sound out from loudspeaker
  hardware.pulseaudio = {
    enable = true;
    package = pkgs.pulseaudioFull;
    daemon.config = {
      "default-sample-rate" = 48000;
      "alternate-sample-rate" = 48000;
    };
    # extraConfig = "load-module module-udev-detect tsched=0";
  };

  hardware.bluetooth.enable = true;
  # services.blueman.enable = true;

  services = {
    printing.enable = true;
    flatpak.enable = true;

    dbus.packages = [pkgs.gcr];
    geoclue2.enable = true;

    udev.packages = with pkgs; [
      platformio
      openocd
    ];
  };

  xdg.portal = {
    enable = true;
    # Sets environment variable NIXOS_XDG_OPEN_USE_PORTAL to 1
    # This will make xdg-open use the portal to open programs,
    # which resolves bugs involving programs opening inside FHS envs or with unexpected env vars set from wrappers.
    # xdg-open is used by almost all programs to open a unknown file/uri
    # alacritty as an example, it use xdg-open as default, but you can also custom this behavior
    # and vscode has open like `External Uri Openers`
    xdgOpenUsePortal = false;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk # for gtk
      # xdg-desktop-portal-kde  # for kde
    ];
  };
  
  # 中文字体
  fonts = {
    enableDefaultPackages = false;
    fontDir.enable = true;
    
    packages = with pkgs; [
      font-awesome
      
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      noto-fonts-extra

      source-sans  
      source-serif
      source-han-sans # 思源黑体
      source-han-serif # 思源宋体

      (nerdfonts.override { fonts = ["FiraCode" "JetBrainsMono" "Hack"]; })
    ];

    fontconfig.defaultFonts = {
      serif = ["source han serif" "Noto Color Emoji"];
      sansSerif = ["source han sans" "Noto Color Emoji"];
      monospace = ["JetBrainsMono Nerd Font" "Noto Color Emoji"];
      emoji = ["Noto Color Emoji"];
    };
  };

  security.sudo.wheelNeedsPassword = false;

  documentation.dev.enable = true;

  environment.variables = {
    _JAVA_AWT_WM_NONREPARENTING = "1";
    TZ = "${config.time.timeZone}";
  };

  environment.sessionVariables = {
    GTK_IM_MODULE="fcitx";
    QT_IM_MODULE="fcitx";
    XMODIFIERS="@im=fcitx";
  };

}
