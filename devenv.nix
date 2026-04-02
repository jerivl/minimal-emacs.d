{ self, pkgs, lib, config, inputs, ... }:
let
  #############
  # Derivations
  #############
  
  emacs-majutsu = pkgs.stdenv.mkDerivation {
    name = "majutsu";
  
    src = pkgs.fetchFromGitHub {
      owner = "0WD0";
      repo = "majutsu";
      rev = "40d0f01d1f538266541b741afb03236064980de8";
      sha256 = "sha256-Xjd2LidVZqZXbQtAqiKr15q+/3XNNie/TSEPQADnz08=";
    };
  
    buildInputs = with pkgs; [
      emacs
      emacsPackages.magit-section
      emacsPackages.magit
      emacsPackages.with-editor
    ];
  
    buildPhase = ''
      # This is modified from stdenv buildPhase. foundMakefile is used in stdenv checkPhase.
      if [[ ! ( -z "''${makeFlags-}" && -z "''${makefile:-}" && ! ( -e Makefile || -e makefile || -e GNUmakefile ) ) ]]; then
        foundMakefile=1
      fi
  
      emacs -l package -f package-initialize \
        --eval "(setq byte-compile-debug "t")" \
        --eval "(setq byte-compile-error-on-warn "nil")" \
        -L . --batch -f batch-byte-compile *.el
  
    '';
  
    installPhase = ''
      LISPDIR=$out/share/emacs/site-lisp
      install -d $LISPDIR
      install *.el *.elc $LISPDIR
    '';
  };
  
  aicommit2 = pkgs.stdenv.mkDerivation (finalAttrs: {
    pname = "aicommit2";
    version = "v2.4.28";
    src = pkgs.fetchurl {
      url = "https://github.com/tak-bro/aicommit2/archive/refs/tags/v2.4.28.tar.gz";
      sha256 = "sha256-WH9ChUDolbIx7w+CynRYJjVH9YWB6T3dantyWRwHfMs=";
    };
  
    pnpmDeps = pkgs.fetchPnpmDeps {
      inherit (finalAttrs) pname version src;
      fetcherVersion = 3;
      hash = "sha256-Yb0zczxetZ/O64suykJHziidkFxdhMntQcCq1jOuK6Q=";
    };
  
    nativeBuildInputs = [
      pkgs.nodejs
      pkgs.pnpm
      pkgs.pnpm.configHook
    ];
    buildInputs = [pkgs.nodejs];
  
    buildPhase = ''
      runHook preBuild
      sed -i 's/"version": "0.0.0-semantic-release"/"version": "v2.4.28"/' package.json
      pnpm build
      runHook postBuild
    '';
  
    installPhase = ''
      runHook preInstall
  
      mkdir -p $out/{bin,lib/aicommit2}
      cp -r {dist,node_modules} $out/lib/aicommit2
  
      ln -s $out/lib/aicommit2/dist/cli.mjs $out/bin/aicommit2
      ln -s $out/lib/aicommit2/dist/cli.mjs $out/bin/aic2
  
      runHook postInstall
    '';
  });
  ##########
  # Emacs
  ##########
    emacs-bundle = (pkgs.emacsPackagesFor pkgs.emacs).emacsWithPackages
    (epkgs: [emacs-majutsu] ++ (with epkgs; [
      aggressive-indent
      apheleia
      buffer-terminator
      cape
      catppuccin-theme
      clipetty
      consult
      corfu
      corfu-terminal 
      diff-hl 
      doom-modeline 
      eat 
      eglot
      eglot-booster
      elisp-refs
      embark
      embark-consult
      envrc 
      flycheck
      flyover
      free-keys 
      helpful
      highlight-defined
      indent-control
      kind-icon
      kirigami
      magit 
      magit-section 
      marginalia
      markdown-mode
      meow
      orderless
      org
      org-auto-tangle
      page-break-lines
      parinfer-rust-mode
      puni
      show-eol 
      stripspace
      tempel
      tempel-collection 
      treemacs
      treesit-auto
      undo-fu
      undo-fu-session
      vertico
      vundo 
      which-key
      with-editor       
    ]));

  emacs-configured = pkgs.writeShellApplication {
    name = "emacs";
    runtimeInputs = [ emacs-bundle ];
    text = ''
      emacs -Q --load ${config}/rolling/config.el "$@"
    '';
  };
  
  url = https://raw.githubusercontent.com/jerivl/minimal-emacs.d;
  name = "config.el";
  config = (pkgs.writeTextDir "/rolling/${name}")
    ( builtins.readFile (
    pkgs.concatTextFile {
      inherit name;
      files = [
        (builtins.fetchurl { url = "${url}/refs/heads/update/lexical-binding"; })
        (pkgs.writeText "pre-pre-early-init.el" ''
          (setq user-emacs-directory "${self.outPath}")
          (setq parinfer-rust-library "${pkgs.parinfer-rust-emacs}/lib/libparinfer_rust.so")
        '')
        #(builtins.fetchurl { url = "${url}/refs/heads/main/pre-early-init.el"; })
        (builtins.fetchurl { url = "${url}/refs/heads/update/early-init.el";})
        #(builtins.fetchurl { url = "${url}/refs/heads/main/post-early-init.el"; })
        #(builtins.fetchurl { url = "${url}/refs/heads/main/pre-init.el"; })
        (builtins.fetchurl { url = "${url}/refs/heads/update/init.el";})
        (builtins.fetchurl { url = "${url}/refs/heads/update/post-init.el";})
        (pkgs.writeText "post-post-init.el" ''
          (require 'majutsu)
        '')    
      ];
    })
  );

in 
{

  
  packages = [ emacs-configured ] ++ (with pkgs; [
    aicommit2
    cocogitto
    emacs-lsp-booster
    jq
    #jujutsu
    koji
    parinfer-rust-emacs
    git
  ]) ++ (with (import inputs.nixpkgs-unstable { }); [ jujutsu ]);
  
  overlays = [
    (import (builtins.fetchTarball {
      url = "https://github.com/nix-community/emacs-overlay/archive/master.tar.gz";
    }))
  ];

  env.GREET = "minimal-emacs.decoupled";
  scripts.hello.exec = ''
    echo Hello from $GREET
  '';

  # This script should automatically complete first time setup
  scripts.first-setup-check.exec = ''
    var="$(cat .copier-answers.yml | grep -e 'vcs')" 
    if [ ! -d ".git" ]; then
      if [[ $var == *"jj"* ]]; then
        jj git init --colocate
      else
        git init -b main
      fi
    fi
  '';

  scripts.acs.exec = ''
    aicommit2 -asiy --output json | jq -r '.subject + "\n\n" + .body'
  '';
  
  scripts."jj describe".exec = ''
    jj describe -m "$(aicommit2 -asiy --output json | jq -r '.subject + "\n\n" + .body')" --editor
  '';
  enterShell = ''
    first-setup-check
    hello
  '';

}
