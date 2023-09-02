{pkgs, ...}: {
  home.packages = with pkgs; [
    p7zip
    ripgrep
    xkb-switch
    xterm
  ];

  services.lorri.enable = true;
}