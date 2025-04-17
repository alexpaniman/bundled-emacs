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

            buildInputs = [
              emacs
              pkgs.git
            ];

            nativeBuildInputs = [ pkgs.makeWrapper ];

            installPhase = ''
              mkdir -pv "$out/share/.emacs.d" "$out/share/.emacs.d/tree-sitter" "$out/bin"

              cp -v "$src/init.el" "$out/share/.emacs.d"

              ln -sv ${pkgs.tree-sitter-grammars.tree-sitter-bash}/parser "$out/share/.emacs.d/tree-sitter/libtree-sitter-bash.so"
              ln -sv ${pkgs.tree-sitter-grammars.tree-sitter-beancount}/parser "$out/share/.emacs.d/tree-sitter/libtree-sitter-beancount.so"
              ln -sv ${pkgs.tree-sitter-grammars.tree-sitter-bibtex}/parser "$out/share/.emacs.d/tree-sitter/libtree-sitter-bibtex.so"
              ln -sv ${pkgs.tree-sitter-grammars.tree-sitter-bitbake}/parser "$out/share/.emacs.d/tree-sitter/libtree-sitter-bitbake.so"
              ln -sv ${pkgs.tree-sitter-grammars.tree-sitter-bqn}/parser "$out/share/.emacs.d/tree-sitter/libtree-sitter-bqn.so"
              ln -sv ${pkgs.tree-sitter-grammars.tree-sitter-c}/parser "$out/share/.emacs.d/tree-sitter/libtree-sitter-c.so"
              ln -sv ${pkgs.tree-sitter-grammars.tree-sitter-c-sharp}/parser "$out/share/.emacs.d/tree-sitter/libtree-sitter-c-sharp.so"
              ln -sv ${pkgs.tree-sitter-grammars.tree-sitter-clojure}/parser "$out/share/.emacs.d/tree-sitter/libtree-sitter-clojure.so"
              ln -sv ${pkgs.tree-sitter-grammars.tree-sitter-cmake}/parser "$out/share/.emacs.d/tree-sitter/libtree-sitter-cmake.so"
              ln -sv ${pkgs.tree-sitter-grammars.tree-sitter-comment}/parser "$out/share/.emacs.d/tree-sitter/libtree-sitter-comment.so"
              ln -sv ${pkgs.tree-sitter-grammars.tree-sitter-commonlisp}/parser "$out/share/.emacs.d/tree-sitter/libtree-sitter-commonlisp.so"
              ln -sv ${pkgs.tree-sitter-grammars.tree-sitter-cpp}/parser "$out/share/.emacs.d/tree-sitter/libtree-sitter-cpp.so"
              ln -sv ${pkgs.tree-sitter-grammars.tree-sitter-css}/parser "$out/share/.emacs.d/tree-sitter/libtree-sitter-css.so"
              ln -sv ${pkgs.tree-sitter-grammars.tree-sitter-cuda}/parser "$out/share/.emacs.d/tree-sitter/libtree-sitter-cuda.so"
              ln -sv ${pkgs.tree-sitter-grammars.tree-sitter-cue}/parser "$out/share/.emacs.d/tree-sitter/libtree-sitter-cue.so"
              ln -sv ${pkgs.tree-sitter-grammars.tree-sitter-dart}/parser "$out/share/.emacs.d/tree-sitter/libtree-sitter-dart.so"
              ln -sv ${pkgs.tree-sitter-grammars.tree-sitter-devicetree}/parser "$out/share/.emacs.d/tree-sitter/libtree-sitter-devicetree.so"
              ln -sv ${pkgs.tree-sitter-grammars.tree-sitter-dockerfile}/parser "$out/share/.emacs.d/tree-sitter/libtree-sitter-dockerfile.so"
              ln -sv ${pkgs.tree-sitter-grammars.tree-sitter-dot}/parser "$out/share/.emacs.d/tree-sitter/libtree-sitter-dot.so"
              ln -sv ${pkgs.tree-sitter-grammars.tree-sitter-earthfile}/parser "$out/share/.emacs.d/tree-sitter/libtree-sitter-earthfile.so"
              ln -sv ${pkgs.tree-sitter-grammars.tree-sitter-eex}/parser "$out/share/.emacs.d/tree-sitter/libtree-sitter-eex.so"
              ln -sv ${pkgs.tree-sitter-grammars.tree-sitter-elisp}/parser "$out/share/.emacs.d/tree-sitter/libtree-sitter-elisp.so"
              ln -sv ${pkgs.tree-sitter-grammars.tree-sitter-elixir}/parser "$out/share/.emacs.d/tree-sitter/libtree-sitter-elixir.so"
              ln -sv ${pkgs.tree-sitter-grammars.tree-sitter-elm}/parser "$out/share/.emacs.d/tree-sitter/libtree-sitter-elm.so"
              ln -sv ${pkgs.tree-sitter-grammars.tree-sitter-embedded-template}/parser "$out/share/.emacs.d/tree-sitter/libtree-sitter-embedded-template.so"
              ln -sv ${pkgs.tree-sitter-grammars.tree-sitter-erlang}/parser "$out/share/.emacs.d/tree-sitter/libtree-sitter-erlang.so"
              ln -sv ${pkgs.tree-sitter-grammars.tree-sitter-fennel}/parser "$out/share/.emacs.d/tree-sitter/libtree-sitter-fennel.so"
              ln -sv ${pkgs.tree-sitter-grammars.tree-sitter-fish}/parser "$out/share/.emacs.d/tree-sitter/libtree-sitter-fish.so"
              ln -sv ${pkgs.tree-sitter-grammars.tree-sitter-fortran}/parser "$out/share/.emacs.d/tree-sitter/libtree-sitter-fortran.so"
              ln -sv ${pkgs.tree-sitter-grammars.tree-sitter-gdscript}/parser "$out/share/.emacs.d/tree-sitter/libtree-sitter-gdscript.so"
              ln -sv ${pkgs.tree-sitter-grammars.tree-sitter-gleam}/parser "$out/share/.emacs.d/tree-sitter/libtree-sitter-gleam.so"
              ln -sv ${pkgs.tree-sitter-grammars.tree-sitter-glimmer}/parser "$out/share/.emacs.d/tree-sitter/libtree-sitter-glimmer.so"
              ln -sv ${pkgs.tree-sitter-grammars.tree-sitter-glsl}/parser "$out/share/.emacs.d/tree-sitter/libtree-sitter-glsl.so"
              ln -sv ${pkgs.tree-sitter-grammars.tree-sitter-go}/parser "$out/share/.emacs.d/tree-sitter/libtree-sitter-go.so"
              ln -sv ${pkgs.tree-sitter-grammars.tree-sitter-godot-resource}/parser "$out/share/.emacs.d/tree-sitter/libtree-sitter-godot-resource.so"
              ln -sv ${pkgs.tree-sitter-grammars.tree-sitter-gomod}/parser "$out/share/.emacs.d/tree-sitter/libtree-sitter-gomod.so"
              ln -sv ${pkgs.tree-sitter-grammars.tree-sitter-gowork}/parser "$out/share/.emacs.d/tree-sitter/libtree-sitter-gowork.so"
              ln -sv ${pkgs.tree-sitter-grammars.tree-sitter-graphql}/parser "$out/share/.emacs.d/tree-sitter/libtree-sitter-graphql.so"
              ln -sv ${pkgs.tree-sitter-grammars.tree-sitter-haskell}/parser "$out/share/.emacs.d/tree-sitter/libtree-sitter-haskell.so"
              ln -sv ${pkgs.tree-sitter-grammars.tree-sitter-hcl}/parser "$out/share/.emacs.d/tree-sitter/libtree-sitter-hcl.so"
              ln -sv ${pkgs.tree-sitter-grammars.tree-sitter-heex}/parser "$out/share/.emacs.d/tree-sitter/libtree-sitter-heex.so"
              ln -sv ${pkgs.tree-sitter-grammars.tree-sitter-hjson}/parser "$out/share/.emacs.d/tree-sitter/libtree-sitter-hjson.so"
              ln -sv ${pkgs.tree-sitter-grammars.tree-sitter-html}/parser "$out/share/.emacs.d/tree-sitter/libtree-sitter-html.so"
              ln -sv ${pkgs.tree-sitter-grammars.tree-sitter-http}/parser "$out/share/.emacs.d/tree-sitter/libtree-sitter-http.so"
              ln -sv ${pkgs.tree-sitter-grammars.tree-sitter-janet-simple}/parser "$out/share/.emacs.d/tree-sitter/libtree-sitter-janet-simple.so"
              ln -sv ${pkgs.tree-sitter-grammars.tree-sitter-java}/parser "$out/share/.emacs.d/tree-sitter/libtree-sitter-java.so"
              ln -sv ${pkgs.tree-sitter-grammars.tree-sitter-javascript}/parser "$out/share/.emacs.d/tree-sitter/libtree-sitter-javascript.so"
              ln -sv ${pkgs.tree-sitter-grammars.tree-sitter-jsdoc}/parser "$out/share/.emacs.d/tree-sitter/libtree-sitter-jsdoc.so"
              ln -sv ${pkgs.tree-sitter-grammars.tree-sitter-json}/parser "$out/share/.emacs.d/tree-sitter/libtree-sitter-json.so"
              ln -sv ${pkgs.tree-sitter-grammars.tree-sitter-json5}/parser "$out/share/.emacs.d/tree-sitter/libtree-sitter-json5.so"
              ln -sv ${pkgs.tree-sitter-grammars.tree-sitter-jsonnet}/parser "$out/share/.emacs.d/tree-sitter/libtree-sitter-jsonnet.so"
              ln -sv ${pkgs.tree-sitter-grammars.tree-sitter-julia}/parser "$out/share/.emacs.d/tree-sitter/libtree-sitter-julia.so"
              ln -sv ${pkgs.tree-sitter-grammars.tree-sitter-just}/parser "$out/share/.emacs.d/tree-sitter/libtree-sitter-just.so"
              ln -sv ${pkgs.tree-sitter-grammars.tree-sitter-koka}/parser "$out/share/.emacs.d/tree-sitter/libtree-sitter-koka.so"
              ln -sv ${pkgs.tree-sitter-grammars.tree-sitter-kotlin}/parser "$out/share/.emacs.d/tree-sitter/libtree-sitter-kotlin.so"
              ln -sv ${pkgs.tree-sitter-grammars.tree-sitter-latex}/parser "$out/share/.emacs.d/tree-sitter/libtree-sitter-latex.so"
              ln -sv ${pkgs.tree-sitter-grammars.tree-sitter-ledger}/parser "$out/share/.emacs.d/tree-sitter/libtree-sitter-ledger.so"
              ln -sv ${pkgs.tree-sitter-grammars.tree-sitter-llvm}/parser "$out/share/.emacs.d/tree-sitter/libtree-sitter-llvm.so"
              ln -sv ${pkgs.tree-sitter-grammars.tree-sitter-lua}/parser "$out/share/.emacs.d/tree-sitter/libtree-sitter-lua.so"
              ln -sv ${pkgs.tree-sitter-grammars.tree-sitter-make}/parser "$out/share/.emacs.d/tree-sitter/libtree-sitter-make.so"
              ln -sv ${pkgs.tree-sitter-grammars.tree-sitter-markdown}/parser "$out/share/.emacs.d/tree-sitter/libtree-sitter-markdown.so"
              ln -sv ${pkgs.tree-sitter-grammars.tree-sitter-markdown-inline}/parser "$out/share/.emacs.d/tree-sitter/libtree-sitter-markdown-inline.so"
              ln -sv ${pkgs.tree-sitter-grammars.tree-sitter-nickel}/parser "$out/share/.emacs.d/tree-sitter/libtree-sitter-nickel.so"
              ln -sv ${pkgs.tree-sitter-grammars.tree-sitter-nix}/parser "$out/share/.emacs.d/tree-sitter/libtree-sitter-nix.so"
              ln -sv ${pkgs.tree-sitter-grammars.tree-sitter-norg}/parser "$out/share/.emacs.d/tree-sitter/libtree-sitter-norg.so"
              ln -sv ${pkgs.tree-sitter-grammars.tree-sitter-norg-meta}/parser "$out/share/.emacs.d/tree-sitter/libtree-sitter-norg-meta.so"
              ln -sv ${pkgs.tree-sitter-grammars.tree-sitter-nu}/parser "$out/share/.emacs.d/tree-sitter/libtree-sitter-nu.so"
              ln -sv ${pkgs.tree-sitter-grammars.tree-sitter-ocaml}/parser "$out/share/.emacs.d/tree-sitter/libtree-sitter-ocaml.so"
              ln -sv ${pkgs.tree-sitter-grammars.tree-sitter-ocaml-interface}/parser "$out/share/.emacs.d/tree-sitter/libtree-sitter-ocaml-interface.so"
              ln -sv ${pkgs.tree-sitter-grammars.tree-sitter-org-nvim}/parser "$out/share/.emacs.d/tree-sitter/libtree-sitter-org-nvim.so"
              ln -sv ${pkgs.tree-sitter-grammars.tree-sitter-perl}/parser "$out/share/.emacs.d/tree-sitter/libtree-sitter-perl.so"
              ln -sv ${pkgs.tree-sitter-grammars.tree-sitter-pgn}/parser "$out/share/.emacs.d/tree-sitter/libtree-sitter-pgn.so"
              ln -sv ${pkgs.tree-sitter-grammars.tree-sitter-php}/parser "$out/share/.emacs.d/tree-sitter/libtree-sitter-php.so"
              ln -sv ${pkgs.tree-sitter-grammars.tree-sitter-pioasm}/parser "$out/share/.emacs.d/tree-sitter/libtree-sitter-pioasm.so"
              ln -sv ${pkgs.tree-sitter-grammars.tree-sitter-prisma}/parser "$out/share/.emacs.d/tree-sitter/libtree-sitter-prisma.so"
              ln -sv ${pkgs.tree-sitter-grammars.tree-sitter-proto}/parser "$out/share/.emacs.d/tree-sitter/libtree-sitter-proto.so"
              ln -sv ${pkgs.tree-sitter-grammars.tree-sitter-pug}/parser "$out/share/.emacs.d/tree-sitter/libtree-sitter-pug.so"
              ln -sv ${pkgs.tree-sitter-grammars.tree-sitter-python}/parser "$out/share/.emacs.d/tree-sitter/libtree-sitter-python.so"
              ln -sv ${pkgs.tree-sitter-grammars.tree-sitter-ql}/parser "$out/share/.emacs.d/tree-sitter/libtree-sitter-ql.so"
              ln -sv ${pkgs.tree-sitter-grammars.tree-sitter-ql-dbscheme}/parser "$out/share/.emacs.d/tree-sitter/libtree-sitter-ql-dbscheme.so"
              ln -sv ${pkgs.tree-sitter-grammars.tree-sitter-query}/parser "$out/share/.emacs.d/tree-sitter/libtree-sitter-query.so"
              ln -sv ${pkgs.tree-sitter-grammars.tree-sitter-r}/parser "$out/share/.emacs.d/tree-sitter/libtree-sitter-r.so"
              ln -sv ${pkgs.tree-sitter-grammars.tree-sitter-regex}/parser "$out/share/.emacs.d/tree-sitter/libtree-sitter-regex.so"
              ln -sv ${pkgs.tree-sitter-grammars.tree-sitter-rego}/parser "$out/share/.emacs.d/tree-sitter/libtree-sitter-rego.so"
              ln -sv ${pkgs.tree-sitter-grammars.tree-sitter-river}/parser "$out/share/.emacs.d/tree-sitter/libtree-sitter-river.so"
              ln -sv ${pkgs.tree-sitter-grammars.tree-sitter-rst}/parser "$out/share/.emacs.d/tree-sitter/libtree-sitter-rst.so"
              ln -sv ${pkgs.tree-sitter-grammars.tree-sitter-ruby}/parser "$out/share/.emacs.d/tree-sitter/libtree-sitter-ruby.so"
              ln -sv ${pkgs.tree-sitter-grammars.tree-sitter-rust}/parser "$out/share/.emacs.d/tree-sitter/libtree-sitter-rust.so"
              ln -sv ${pkgs.tree-sitter-grammars.tree-sitter-scala}/parser "$out/share/.emacs.d/tree-sitter/libtree-sitter-scala.so"
              ln -sv ${pkgs.tree-sitter-grammars.tree-sitter-scheme}/parser "$out/share/.emacs.d/tree-sitter/libtree-sitter-scheme.so"
              ln -sv ${pkgs.tree-sitter-grammars.tree-sitter-scss}/parser "$out/share/.emacs.d/tree-sitter/libtree-sitter-scss.so"
              ln -sv ${pkgs.tree-sitter-grammars.tree-sitter-smithy}/parser "$out/share/.emacs.d/tree-sitter/libtree-sitter-smithy.so"
              ln -sv ${pkgs.tree-sitter-grammars.tree-sitter-solidity}/parser "$out/share/.emacs.d/tree-sitter/libtree-sitter-solidity.so"
              ln -sv ${pkgs.tree-sitter-grammars.tree-sitter-sparql}/parser "$out/share/.emacs.d/tree-sitter/libtree-sitter-sparql.so"
              ln -sv ${pkgs.tree-sitter-grammars.tree-sitter-sql}/parser "$out/share/.emacs.d/tree-sitter/libtree-sitter-sql.so"
              ln -sv ${pkgs.tree-sitter-grammars.tree-sitter-supercollider}/parser "$out/share/.emacs.d/tree-sitter/libtree-sitter-supercollider.so"
              ln -sv ${pkgs.tree-sitter-grammars.tree-sitter-surface}/parser "$out/share/.emacs.d/tree-sitter/libtree-sitter-surface.so"
              ln -sv ${pkgs.tree-sitter-grammars.tree-sitter-svelte}/parser "$out/share/.emacs.d/tree-sitter/libtree-sitter-svelte.so"
              ln -sv ${pkgs.tree-sitter-grammars.tree-sitter-talon}/parser "$out/share/.emacs.d/tree-sitter/libtree-sitter-talon.so"
              ln -sv ${pkgs.tree-sitter-grammars.tree-sitter-templ}/parser "$out/share/.emacs.d/tree-sitter/libtree-sitter-templ.so"
              ln -sv ${pkgs.tree-sitter-grammars.tree-sitter-tiger}/parser "$out/share/.emacs.d/tree-sitter/libtree-sitter-tiger.so"
              ln -sv ${pkgs.tree-sitter-grammars.tree-sitter-tlaplus}/parser "$out/share/.emacs.d/tree-sitter/libtree-sitter-tlaplus.so"
              ln -sv ${pkgs.tree-sitter-grammars.tree-sitter-toml}/parser "$out/share/.emacs.d/tree-sitter/libtree-sitter-toml.so"
              ln -sv ${pkgs.tree-sitter-grammars.tree-sitter-tsq}/parser "$out/share/.emacs.d/tree-sitter/libtree-sitter-tsq.so"
              ln -sv ${pkgs.tree-sitter-grammars.tree-sitter-tsx}/parser "$out/share/.emacs.d/tree-sitter/libtree-sitter-tsx.so"
              ln -sv ${pkgs.tree-sitter-grammars.tree-sitter-turtle}/parser "$out/share/.emacs.d/tree-sitter/libtree-sitter-turtle.so"
              ln -sv ${pkgs.tree-sitter-grammars.tree-sitter-typescript}/parser "$out/share/.emacs.d/tree-sitter/libtree-sitter-typescript.so"
              ln -sv ${pkgs.tree-sitter-grammars.tree-sitter-typst}/parser "$out/share/.emacs.d/tree-sitter/libtree-sitter-typst.so"
              ln -sv ${pkgs.tree-sitter-grammars.tree-sitter-uiua}/parser "$out/share/.emacs.d/tree-sitter/libtree-sitter-uiua.so"
              ln -sv ${pkgs.tree-sitter-grammars.tree-sitter-verilog}/parser "$out/share/.emacs.d/tree-sitter/libtree-sitter-verilog.so"
              ln -sv ${pkgs.tree-sitter-grammars.tree-sitter-vim}/parser "$out/share/.emacs.d/tree-sitter/libtree-sitter-vim.so"
              ln -sv ${pkgs.tree-sitter-grammars.tree-sitter-vue}/parser "$out/share/.emacs.d/tree-sitter/libtree-sitter-vue.so"
              ln -sv ${pkgs.tree-sitter-grammars.tree-sitter-wgsl}/parser "$out/share/.emacs.d/tree-sitter/libtree-sitter-wgsl.so"
              ln -sv ${pkgs.tree-sitter-grammars.tree-sitter-wing}/parser "$out/share/.emacs.d/tree-sitter/libtree-sitter-wing.so"
              ln -sv ${pkgs.tree-sitter-grammars.tree-sitter-yaml}/parser "$out/share/.emacs.d/tree-sitter/libtree-sitter-yaml.so"
              ln -sv ${pkgs.tree-sitter-grammars.tree-sitter-yang}/parser "$out/share/.emacs.d/tree-sitter/libtree-sitter-yang.so"
              ln -sv ${pkgs.tree-sitter-grammars.tree-sitter-zig}/parser "$out/share/.emacs.d/tree-sitter/libtree-sitter-zig.so"

              makeWrapper ${emacs}/bin/emacs $out/bin/panimacs \
                --add-flags "--init-directory=$out/share/.emacs.d/" \
                --set XDG_DATA_HOME ${fonts}

              makeWrapper ${emacs}/bin/emacsclient $out/bin/panimacsclient \
                --set XDG_DATA_HOME ${fonts}
            '';
          };
        };
      }
    );
}
