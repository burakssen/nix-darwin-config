{
  config,
  pkgs,
  ...
}:
{
  home = {
    username = "burakssen";
    homeDirectory = pkgs.lib.mkForce "/Users/burakssen";
    stateVersion = "23.05";

    packages = with pkgs; [
      git
      btop
      fzf
      bat
      ripgrep
      jq
      coreutils
      wget
      eza
    ];
  };

  programs = {
    home-manager.enable = true;

    zsh = {
      enable = true;
      autosuggestion.enable = true;
      enableCompletion = true;

      oh-my-zsh = {
        enable = true;
        plugins = [
          "git"
          "docker"
          "macos"
          "sudo"
        ];
        theme = "bira";
      };

      initContent = ''
        # Any additional custom zsh configuration can go here
        export PATH=$HOME/.local/bin:$PATH
        export ZSH_CUSTOM=$ZSH/custom
      '';

      # Set aliases
      shellAliases = {
        ls = "eza --icons=auto";
        update-system = "darwin-rebuild switch --flake ~/.config/nix#burakssen";
        edit-system = "code ~/.config/nix/flake.nix ~/.config/nix/home.nix";
        gs = "git status";
      };
    };

    neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
    };

    git = {
      enable = true;
      userName = "burakssen";
      userEmail = "buraksen7@hotmail.com";
    };

    vscode = {
      enable = true;
      package = pkgs.vscode;
      profiles.default = {
        extensions = with pkgs.vscode-extensions; [
          visualstudioexptteam.vscodeintellicode
          visualstudioexptteam.intellicode-api-usage-examples
          ziglang.vscode-zig
          jnoortheen.nix-ide
          catppuccin.catppuccin-vsc-icons
          github.github-vscode-theme
        ];
        userSettings = {
          "editor.formatOnSave" = true;

          "editor.fontFamily" = "'JetbrainsMono Nerd Font'";
          "editor.fontLigatures" = true;

          "workbench.iconTheme" = "catppuccin-mocha";
          "workbench.colorTheme" = "GitHub Dark Default";
        };
      };
    };
  };
}
