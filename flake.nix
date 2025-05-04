{
  description = "burakssen darwin system flake";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew, home-manager, nix-vscode-extensions }:
    let
      configuration = { pkgs, config, ... }: {
        nixpkgs.config.allowUnfree = true;
        
        environment.systemPackages = [
          pkgs.neovim
          pkgs.mkalias
          pkgs.vscode
          pkgs.docker
          pkgs.docker-compose
          pkgs.ctop
          pkgs.nixfmt-rfc-style
        ];

        homebrew = {
          enable = true;
          casks = [
            "jordanbaird-ice"
            "iina"
            "the-unarchiver"
            "ghostty"
            "microsoft-teams"
            "intellidock"
            "raycast"
            "clion"
            "miniconda"
            "surfshark"
          ];
          brews = [
            "gh"
            "mas"
            "zig"
          ];
          masApps = {
            "WhatsApp" = 310633997;
            "Telegram" = 747648890;
            "Microsoft Word" = 462054704;
            "Microsoft PowerPoint" = 462062816;
            "Microsoft Excel" = 462058435;
            "AdGuard For Safari" = 1440147259;
          };
          onActivation.cleanup = "zap";
        };

        fonts.packages = [
          pkgs.nerd-fonts.jetbrains-mono
        ];

        nix.settings.experimental-features = "nix-command flakes";
        system.configurationRevision = self.rev or self.dirtyRev or null;
        system.stateVersion = 6;
        nixpkgs.hostPlatform = "aarch64-darwin";
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
          find ${env}/Applications -maxdepth 1 -type l | while read -r src; do
            app_name=$(basename "$src")
            echo "copying $src" >&2
            ${pkgs.mkalias}/bin/mkalias "$src" "/Applications/Nix Apps/$app_name"
          done
        '';
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
            };
          }
          home-manager.darwinModules.home-manager {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = ".backup";
            home-manager.users.burakssen = import ./home.nix;
          }
        ];
      };
      darwinPackages = self.darwinConfigurations."burakssen".pkgs;
    };
}