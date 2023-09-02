#  Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ... }: let
    nvidia-offload = pkgs.writeShellScriptBin "nvidia-offload" ''
      export __NV_PRIME_RENDER_OFFLOAD=1
      export __GLX_VENDOR_LIBRARY_NAME=nvidia
      export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
      exec "$@"
      export __VK_LAYER_NV_optimus=NVIDIA_only
    '';
in rec {
  imports = [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
  ];
  
  nix.settings = {
    auto-optimise-store = true;
    substituters = lib.mkForce [
      "https://mirror.sjtu.edu.cn/nix-channels/store"
      "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
    ];
    trusted-users = [ "@wheel" ];
    experimental-features = [ "nix-command" "flakes" ];
  };

  # Configuration of Nixpkgs
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config = {
    permittedInsecurePackages = [
	    "qtwebkit-5.212.0-alpha4"
    ];

    packageOverrides = pkgs: {
      # nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
      #   inherit pkgs;
      # };
      # myRepo = import (builtins.fetchTarball "https://github.com/Lysanleo/lysanleo-nixpkgs/NUR/archive/master.tar.gz") {
      #   inherit pkgs;
      # };
      # unstable = import <nixos-unstable> { 
      #   config = { allowUnfree = true; }; 
      #   inherit pkgs;
      # };
    };
  };

  # nixpkgs.overlays = [ (self: super: {
  #   libsForQt5.okular = self.libsForQt5.okular.overrideAttrs (oldAttrs: {
  #   postInstall = (oldAttrs.postInstall or "") + ''
  #     substituteInPlace $out/share/applications/slack.desktop \
  #       --replace InitialPreference=3 InitialPreference=1 \
  #       --replace "okular %U" "/usr/bin/env QT_QPA_PLATFORM=xcb okular %U"
  #   '';
  # });})];

  boot = {
    # kernelPackages = pkgs.unstable.linuxKernel.packages.linux_6_1;
    kernelPackages = pkgs.linuxPackages_latest;
    # kernelParams = [ "i915.force_probe=46a6" ];
  };


  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.extraModprobeConfig = ''
    options snd-hda-intel dmic_detect=0
  '';
  boot.blacklistedKernelModules =[ "snd_soc_skl" ];

  # networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  hardware.bluetooth.enable = true;

  # ExtraRules for AnnePro2D
  services.udev.extraRules = ''
    KERNEL=="uinput", MODE="0660", GROUP="uinput", OPTIONS+="static_node=uinput"
    SUBSYSTEM=="input", GROUP="input", MODE="0666"
    # For ANNE PRO 2
    SUBSYSTEM=="usb", ATTRS{idVendor}=="04d9", ATTRS{idProduct}=="8008",MODE="0666", GROUP="plugdev"
    KERNEL=="hidraw*", ATTRS{idVendor}=="04d9", ATTRS{idProduct}=="8008",MODE="0666", GROUP="plugdev"
    
    SUBSYSTEM=="usb", ATTRS{idVendor}=="04d9", ATTRS{idProduct}=="8009",MODE="0666", GROUP="plugdev"
    KERNEL=="hidraw*", ATTRS{idVendor}=="04d9", ATTRS{idProduct}=="8009",MODE="0666", GROUP="plugdev"
    
    SUBSYSTEM=="usb", ATTRS{idVendor}=="04d9", ATTRS{idProduct}=="a292",MODE="0666", GROUP="plugdev"
    KERNEL=="hidraw*", ATTRS{idVendor}=="04d9", ATTRS{idProduct}=="a292",MODE="0666", GROUP="plugdev"
    
    SUBSYSTEM=="usb", ATTRS{idVendor}=="04d9", ATTRS{idProduct}=="a293",MODE="0666", GROUP="plugdev"
    KERNEL=="hidraw*", ATTRS{idVendor}=="04d9", ATTRS{idProduct}=="a293",MODE="0666", GROUP="plugdev"
    
    # ble
    KERNELS=="*:000D:F0E0.*" SUBSYSTEMS=="hid" DRIVERS=="hid-generic", MODE="0666", GROUP="plugdev"
  '';

  specialisation = {
    nvsyncmode.configuration = {
      system.nixos.tags = [ "syncmode" ];
      hardware.nvidia = {
        open = false;
        modesetting.enable = true;
        # powerManagement = {
        #   enable = true;
        #   finegrained = true;
        # };
        nvidiaSettings = false;
        nvidiaPersistenced = true;
        forceFullCompositionPipeline = true;
        package = config.boot.kernelPackages.nvidiaPackages.stable;
        prime = {
          sync.enable = true;
          # offload.enableOffloadCmd = true;
          intelBusId = "PCI:0:2:0";
          nvidiaBusId = "PCI:1:0:0";
        };
      };
      services.xserver = {
        videoDrivers = ["nvidia"];
        # deviceSection = ''
        #   Option "DRI" "2"
        #   Option "TearFree" "true"
        # '';
      };
    };
  };

  hardware.opengl.enable = true;
  hardware.deviceTree.enable = true;

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

  environment.variables = {
    _JAVA_AWT_WM_NONREPARENTING = "1";
  };
  environment.sessionVariables = {
    GTK_IM_MODULE="fcitx";
    QT_IM_MODULE="fcitx";
    XMODIFIERS="@im=fcitx";
  };
  # environment.sessionVariables.NIXOS_OZONE_WL = "1";

  documentation.dev.enable = true;

  # systemd.services.nix-daemon.environment = { http_proxy = "http://127.0.0.1:8889"; };

  # Set your time zone.
  # time.timeZone = "Europe/Amsterdam";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  #networking.interfaces.enp0s20f0u1.useDHCP = true;

  # [VirtualBox]
  # virtualisation.virtualbox.host.enable = true;
  # users.extraGroups.vboxusers.members = [ "user-with-access-to-virtualbox" ];
  # virtualisation.virtualbox.host.enableExtensionPack = true;

  # Configure network proxy if necessary
  # [[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[TEMPORALY TURN OFF FOR PROXY OVERLOAD]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]
  networking.proxy.default = "http://127.0.0.1:7890";

  # Select internationalisation properties.
  i18n.defaultLocale = "zh_CN.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  # };

  services = {
    mysql = {
      package = pkgs.mariadb;
      enable = true;
    };
    vsftpd = {
      enable = true;
      anonymousUser = true;
    };
  };

  services.xserver = {
    # Enable the X11 windowing system.
    enable = true;
    displayManager.sddm.enable = true;
    # displayManager.sddm.enableHidpi = true;

    desktopManager.plasma5.enable = true;
    desktopManager.plasma5.useQtScaling = true;

    # Enable touchpad support (enabled default in most desktopManager).
    libinput.enable = true;
    ## Switch Caps and Control
    # xkbOptions = "ctrl:swapcaps";
  };

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
  };

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 1701 9001 ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # 桌面系统不用费心配置网络，直接交给 NetworkManager 管理
  networking.networkmanager.enable = true;
  programs.nm-applet.enable = true;

  programs = {
    kdeconnect.enable = true;
    adb.enable = true;
    zsh.enable = true;
    xwayland.enable = true;
  };

  programs.proxychains = {
    enable = true;
    proxies = {
      myproxy = {
        type = "socks4";
        host = "127.0.0.1";
        port = 7890;
        enable = true;
      };
    };
  };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };

  # Enable the GNOME Desktop Environment.
  # services.xserver.displayManager.gdm.enable = true;
  # services.xserver.desktopManager.gnome.enable = true;
  # # services.gnome.gnome-browser-connector.enable = true;
  # services.gnome.tracker.enable = false;
  # services.gnome.tracker-miners.enable = false;
  # programs.dconf.enable = true;


  # Configure keymap in X11
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  # users.users.jane = {
  #   isNormalUser = true;
  #   extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  # };

  # List packages installed in system profile. To search, run:
  # $ nix search wget

  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    goldendict
    tldr
    readline
    vte
    cmake
    gnumake
    unzip
    gtk2
    gtk3
    gtk4
    pkgs.proxychains-ng
    sof-firmware
    man-pages
    direnv
    nix-direnv
    pylint
    rime-data
    libsForQt5.okular
    libsForQt5.kde-gtk-config
    libsForQt5.ark
  ] ++ [
    # gnome.gnome-tweaks
    # gnome.adwaita-icon-theme
    # gnome.gnome-settings-daemon
    # gnome.gnome-terminal
    # gnomeExtensions.appindicator
    # gnomeExtensions.customize-ibus
    # gnomeExtensions.surf
  ] ++ [
    # jetbrains.idea-community
    # mysql
    # google-chrome
    # chrome-gnome-shell
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:
  # 支持 NTFS 格式 
  boot.supportedFilesystems = [ "ntfs" ];

  # 时区
  time.timeZone = "Asia/Shanghai";

  # 双系统改为本地时间保持同步（不推荐了）
  # time.hardwareClockInLocalTime = true;
  # 把 Windows 时间改成 UTC 就不需要这个配置了

  # 语言支持和输入法
  #i18n.defaultLocale = "zh_CN.UTF-8";
  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5 = {
      addons = with pkgs; [ fcitx5-rime ];
      # enableRimeData = true;
    };
  };

  # 中文字体
  fonts = {
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk
      hack-font
      fira-code
      sarasa-gothic
      (nerdfonts.override { fonts = ["FiraCode" "JetBrainsMono" "Hack"]; })
    ];
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?

  security.sudo.wheelNeedsPassword = false;
  security.pam.services.yukin.enableKwallet = false;

  users.defaultUserShell = pkgs.zsh;
  users.users = {
    yukin = {
      createHome = true;
      description = "L. Yukin";
      extraGroups = [ "networkmanager" "wheel" "vboxusers" "uinput" "adbusers" ];
      home = "/home/yukin";
      group = "yukin";
      isNormalUser = true;
    };
  };
}
