{ config, lib, pkgs, ... }:
{
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
}
