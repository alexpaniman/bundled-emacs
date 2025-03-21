{
  description = "Paracl programming language.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    emacs-overlay.url = "github:nix-community/emacs-overlay";
  };

  outputs = { self, nixpkgs, flake-utils, emacs-overlay }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ emacs-overlay.overlay ];
        };

        emacs = pkgs.emacsWithPackagesFromUsePackage {
          config = ./init.el;
          defaultInitFile = true;

          package = pkgs.emacs-git;
          alwaysEnsure = true;
        };

        fonts = pkgs.stdenv.mkDerivation {
          name = "panimacs-fonts";

          buildInputs = [
            pkgs.fira-code
            pkgs.fira-sans
            pkgs.noto-fonts-color-emoji
          ];

          unpackPhase = "true";
          buildPhase = ''
            mkdir -p "$out/fonts/"{truetype,opentype}
            find ${pkgs.fira-code}/share/fonts -type f -name "*.ttf" -exec cp {} "$out/fonts/truetype" \;
            find ${pkgs.fira-sans}/share/fonts -type f -name "*.otf" -exec cp {} "$out/fonts/opentype" \;
            find ${pkgs.noto-fonts-emoji}/share/fonts -type f -name "*.ttf" -exec cp {} "$out/fonts/truetype" \;
          '';
        };
      in
      {
        packages = {
          default = pkgs.stdenv.mkDerivation {
            pname = "panimacs";
            version = "1.0.0";

            meta.mainProgram = "panimacs";

            src = ./.;

            buildInputs = [ emacs pkgs.git ];
            nativeBuildInputs = [ pkgs.makeWrapper ];

            installPhase = ''
              mkdir -pv "$out/share/.emacs.d" "$out/bin"

              cp -v "$src/init.el" "$out/share/.emacs.d"

              makeWrapper ${emacs}/bin/emacs $out/bin/panimacs     \
                --add-flags "--init-directory=$out/share/.emacs.d/" \
                --set XDG_DATA_HOME ${fonts} \
                --set PATH ${pkgs.git}/bin/
            '';
          };
        };
      }
    );
}
