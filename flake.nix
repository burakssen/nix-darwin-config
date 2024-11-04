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
        # List packages installed in system profile. To search by name, run:
        # $ nix-env -qaP | grep wget

        nixpkgs.config.allowUnfree = true;
        environment.systemPackages = [
          pkgs.neovim
          pkgs.docker
          pkgs.mkalias
          pkgs.cmake
        ];

        fonts.packages = [
          (pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
        ];

        environment.systemPath = [ "/opt/homebrew/bin" ];

        homebrew = {
          enable = true;
          brews = [
            "mas"
            "gh"
            "wget"
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
            "${builtins.toString /Users/burakssen/.config/nix/casks/quitme.rb}"
          ];
          masApps = {
            "WhatsApp" = 310633997;
            "Telegram" = 747648890;
            "Xcode" = 497799835;
            "Microsoft Word" = 462054704;
            "Microsoft Excel" = 462058435;
            "Microsoft PowerPoint" = 462062816;
            "AdGuard" = 1440147259;
            "Slack" = 803453959;
          };
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

        # Auto upgrade nix package and the daemon service.
        services.nix-daemon.enable = true;
        
        # Necessary for using flakes on this system.
        nix.settings.experimental-features = "nix-command flakes";

        # Set Git commit hash for darwin-version.
        system.configurationRevision = self.rev or self.dirtyRev or null;

        # Used for backwards compatibility, please read the changelog before changing.
        system.stateVersion = 5;

        # The platform the configuration will be used on.
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
      # Expose the package set, including overlays, for convenience.
      darwinPackages = self.darwinConfigurations."burakssen".pkgs;
    };
}