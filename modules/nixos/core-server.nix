{
	lib,
	pkgs,
	...
}: {
	#  NixOS's core configuration suitable for all my machines

	boot.loader.systemd-boot.configurationLimit = lib.mkDefault 10;

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
  nixpkgs.config.allowUnfree = lib.mkDefault true;

  # 时区
  time.timeZone = "Asia/Shanghai";

  # Select internationalisation properties.
  i18n.defaultLocale = "zh_CN.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  # };
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "zh_CN.UTF-8";
    LC_IDENTIFICATION = "zh_CN.UTF-8";
    LC_MEASUREMENT = "zh_CN.UTF-8";
    LC_MONETARY = "zh_CN.UTF-8";
    LC_NAME = "zh_CN.UTF-8";
    LC_NUMERIC = "zh_CN.UTF-8";
    LC_PAPER = "zh_CN.UTF-8";
    LC_TELEPHONE = "zh_CN.UTF-8";
    LC_TIME = "zh_CN.UTF-8";
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ 1701 9001 ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = lib.mkDefault false;

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
		settings = {
      X11Forwarding = true;
      PermitRootLogin = "no"; # disable root login
      PasswordAuthentication = false; # disable password login
    };
    openFirewall = true;
  };

  services = {
		power-profiles-daemon = {
			enable = true;
		};
		upower.enable = true;
    mysql = {
      package = pkgs.mariadb;
      enable = true;
    };
    vsftpd = {
      enable = true;
      anonymousUser = true;
    };
  };

	environment.systemPackages = with pkgs; [
    helix
		wget
		curl
		tldr
		readline
		git
		aria2
		man-pages
	];

	environment.variables.EDITOR = "hx";
}