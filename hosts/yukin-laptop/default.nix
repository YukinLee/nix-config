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
      ../../modules/nixos/core-desktop.nix
      ../../modules/nixos/libvirt.nix
  ];

  boot = {
    # kernelPackages = pkgs.linuxKernel.packages.linux_6_1;
    kernelPackages = pkgs.linuxPackagesFor (pkgs.linux_6_1.override {
      argsOverride = rec {
        src = pkgs.fetchurl {
          url = "mirror://kernel/linux/kernel/v6.x/linux-${version}.tar.xz";
          sha256 = "sha256-yeoUIxykym44gqkzmow8QU5MkVGdPlCvaCL0fpkFeg8=";
        };
        version = "6.1.49";
        modDirVersion = "6.1.49";
      };
    });
    kernelPatches = [
      {
        name = "intel-hdmi";
        patch = ./intel-hdmi.patch;
      }
    ];
    # kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = [ 
      "i915.force_probe=46a6"
      "i915.enable_dc=0"
      "i915.enable_guc=2"
    ];
    extraModprobeConfig = ''
      options snd-hda-intel dmic_detect=0
    '';
    blacklistedKernelModules =[ "snd_soc_skl" ];
    initrd.availableKernelModules = [
      "i915"
      "nvidia" "nvidia_drm" "nvidia_modeset" "nvidia_uvm"
    ];
  };

  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
    extraPackages = with pkgs; [
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
      vaapiIntel         # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
      vaapiVdpau
      libvdpau-va-gl
    ];      
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
      # efiSysMountPoint = "/boot/EFI";
    };
    systemd-boot.enable = true;
  };
  boot.supportedFilesystems = [ "ntfs" "ext4" "btrfs" "exfat" ];
  boot.binfmt.emulatedSystems = ["aarch64-linux" "riscv64-linux"];

  networking = {
    hostName = "yukin";
    wireless.enable = false;

    networkmanager.enable = true;

    enableIPv6 = false;

    useDHCP = false;
    #networking.interfaces.enp0s20f0u1.useDHCP = true;

    # Configure network proxy if necessary
    # [[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[TEMPORALY TURN OFF FOR PROXY OVERLOAD]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]
    proxy.default = "http://127.0.0.1:7890";
  };

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

  #specialisation = {
    #nvsyncmode.configuration = {
    #  system.nixos.tags = [ "syncmode" ];
      hardware.nvidia = {
        package = config.boot.kernelPackages.nvidiaPackages.stable;
        modesetting.enable = true;
        open = false;
        powerManagement = {
          enable = true;
        #   finegrained = true;
        };
        nvidiaSettings = false;
        # nvidiaPersistenced = true;
        forceFullCompositionPipeline = true;
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
    #};
  #};

  hardware.deviceTree.enable = true;

  # [VirtualBox]
  # virtualisation.virtualbox.host.enable = true;
  # users.extraGroups.vboxusers.members = [ "user-with-access-to-virtualbox" ];
  # virtualisation.virtualbox.host.enableExtensionPack = true;

  nixpkgs.config.permittedInsecurePackages = [
    "qtwebkit-5.212.0-alpha4"
  ];


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


  # 桌面系统不用费心配置网络，直接交给 NetworkManager 管理
  programs.nm-applet.enable = true;

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
    gtk2
    gtk3
    gtk4
    sof-firmware
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



  # 双系统改为本地时间保持同步（不推荐了）
  # time.hardwareClockInLocalTime = true;
  # 把 Windows 时间改成 UTC 就不需要这个配置了

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?

  users.users = {
    yukin = {
      createHome = true;
      description = "L. Yukin";
      extraGroups = [ "networkmanager" "wheel" "vboxusers" "uinput" "adbusers" ];
      # home = "/home/yukin";
      group = "yukin";
      isNormalUser = true;
    };
  };
}
