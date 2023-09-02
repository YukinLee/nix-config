{
	pkgs,
	config,
	lib,
	...
}: {
  # 语言支持和输入法
  #i18n.defaultLocale = "zh_CN.UTF-8";
  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5 = {
      addons = with pkgs; [
				fcitx5-rime
				fcitx5-configtool
				fcitx5-chinese-addons
				fcitx5-gtk
			];
      # enableRimeData = true;
    };
  };

}
