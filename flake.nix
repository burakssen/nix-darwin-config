{
  description = "Burakssen Darwin system flake";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew }:
    let
      configuration = { pkgs, config, ... }: {
        nixpkgs.config.allowUnfree = true;

        environment.systemPackages = [
          pkgs.neovim
          pkgs.docker
          pkgs.mkalias
          pkgs.cmake
          pkgs.oh-my-zsh
          pkgs.home-manager
        ];

        programs.zsh = {
          enable = true;  
        };

        fonts.packages = [
          (pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
        ];
        
        environment.systemPath = [ "/opt/homebrew/bin" "~/.local/bin" ];
        
        homebrew = {
          enable = true;
          brews = [
            "mas"
            "gh"
            "wget"
            "docker-compose"
            "tree"
            "btop"
            "llvm"
            "node"
            "curl"
            "grep"
            "aria2"
            "ffmpeg"
            "git"
            "fzf"
            "yt-dlp"
          ];
          casks = [
            "iina"
            "the-unarchiver"
            "docker"
            "visual-studio-code"
            "raycast"
            "fork"
            "iterm2"
            "pgadmin4"
            "intellidock"
            "mos"
            "jordanbaird-ice"
            "spotify"
            "clion"
            "zed"
            "zen-browser"
            "datagrip"
            "microsoft-teams"
            "zoom"
            "sf-symbols"
            "appcleaner"
            "quitme"
            "artixgamelauncher"
            "ani-cli"
            "surfshark"
            "grandperspective"
            "postman"
            "orbstack"
          ];

          masApps = {
            "Amphetamine" = 937984704;
            "WhatsApp" = 310633997;
            "Telegram" = 747648890;
            "Slack" = 803453959;
            "Xcode" = 497799835;
            "Microsoft Word" = 462054704;
            "Microsoft Excel" = 462058435;
            "Microsoft PowerPoint" = 462062816;
            "AdGuard for Safari" = 1440147259;
          };

          taps = [
            "burakssen/cask"
          ];
       
          onActivation = {
            autoUpdate = true;
            cleanup = "zap";
            upgrade = true;
          };
        };
        system.activationScripts.applications.text = let
          env = pkgs.buildEnv {
            name = "system-applications";
            paths = config.environment.systemPackages;
            pathsToLink = "/Applications";
          };
        in
          pkgs.lib.mkForce ''
            # Set up applications.
            echo "setting up /Applications..." >&2
            rm -rf /Applications/Nix\ Apps
            mkdir -p /Applications/Nix\ Apps
            find ${env}/Applications -maxdepth 1 -type l -exec readlink '{}' + |
            while read src; do
              app_name=$(basename "$src")
              echo "copying $src" >&2
              ${pkgs.mkalias}/bin/mkalias "$src" "/Applications/Nix Apps/$app_name"
            done
          '';

        services.nix-daemon.enable = true;
        nix.settings.experimental-features = "nix-command flakes";
        system.configurationRevision = self.rev or self.dirtyRev or null;
        system.stateVersion = 5;
        nixpkgs.hostPlatform = "aarch64-darwin";
      };
    in
    {
      darwinConfigurations."burakssen" = nix-darwin.lib.darwinSystem {
        modules = [
          configuration
          nix-homebrew.darwinModules.nix-homebrew
          {
            nix-homebrew = {
              enable = true;
              enableRosetta = true;
              user = "burakssen";
              autoMigrate = true;
            };
          }
        ];
      };
      darwinPackages = self.darwinConfigurations."burakssen".pkgs;
    };
}