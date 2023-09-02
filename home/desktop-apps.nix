{pkgs, nurpkgs, ...}: let
  nur = import nurpkgs {
    inherit pkgs;
    nurpkgs = pkgs;
  };
in {
  home.packages = with pkgs; [
    goldendict
    calibre
    anki-bin
    foliate
    zulip
    slack
    discord
    zotero
    obsidian
    nur.repos.linyinfeng.icalingua-plus-plus
    nur.repos.YisuiMilena.hmcl-bin
    nur.repos.linyinfeng.clash-for-windows
    wpsoffice-cn
    buttercup-desktop
    mathpix-snipping-tool
    vlc
    tdesktop # telegram
    mpv
    citra-canary
  ];

  programs = {
  # source code: https://github.com/nix-community/home-manager/blob/master/modules/programs/chromium.nix
  google-chrome = {
    enable = true;
     commandLineArgs = [
      # make it use GTK_IM_MODULE if it runs with Gtk4, so fcitx5 can work with it.
      # (only supported by chromium/chrome at this time, not electron)
      "--gtk-version=4"
      # make it use text-input-v1, which works for kwin 5.27 and weston
      # "--enable-wayland-ime"
      # enable hardware acceleration - vulkan api
      # "--enable-features=Vulkan"
    ];
  };
  firefox = {
    enable = true;
    enableGnomeExtensions = false;
    package = pkgs.firefox-wayland; # firefox with wayland support
  };
  };
}