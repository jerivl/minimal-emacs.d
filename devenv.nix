{ pkgs, lib, config, inputs, ... }:
let
  buildInputs = with pkgs; [
    stdenv.cc.cc
    libuv
    zlib
  ];
  emacs-majutsu = pkgs.stdenv.mkDerivation {
    name = "majutsu";
  
    src = pkgs.fetchurl {
      url = "https://github.com/0WD0/majutsu/archive/refs/tags/v0.6.0.tar.gz";
      sha256 = "sha256-cIOZJQTuHhgpMwDo1nFvAadmxHtiwK9p9xfUNtRtCgE=";
    };
  
    buildInputs = with pkgs; [
      emacs
      emacsPackages.magit-section
      emacsPackages.magit
      emacsPackages.with-editor
    ];
    nativeBuildInputs = buildInputs;
  
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
  
  emacs-pre-early-init = '' 
    (setq user-emacs-directory "${config.git.root}")
  '';
  emacs-early-init = builtins.readFile "${config.git.root}/early-init.el";
  emacs-post-early-init = "";
  emacs-pre-init = "";
  emacs-init = builtins.readFile "${config.git.root}/init.el";
  emacs-post-init = (builtins.readFile "${config.git.root}/post-init.el") + ''
    (use-package magit :ensure t)
    (use-package magit-section :ensure t)
    (use-package with-editor :ensure t)
    (require 'majutsu)
  '';
  emacs-config = lib.strings.concatLines [
    emacs-pre-early-init
    emacs-early-init
    emacs-post-early-init
    emacs-pre-init
    emacs-init
    emacs-post-init
  ];
  emacs-configured = pkgs.emacsWithPackagesFromUsePackage {
    config = emacs-config;
    defaultInitFile = true;
    package = pkgs.emacs;
    extraEmacsPackages = epkgs: (with epkgs; [
      jinx
      eat
      vterm
      # unsure if I should move lsp bridge here
    ])
    ++ [ emacs-majutsu ];
  };
  
in 
{
  env.GREET = "minimal-emacs.d";

  packages = with pkgs; [
    git
    jq
    jujutsu
    
    cocogitto
    koji
    aicommit2
    emacs-lsp-booster
    ty
  ]
  ++ [ emacs-configured ]
  
  ;  
  git-hooks = {
    enable = true;
    hooks = {
    };
  };
  treefmt = {
    enable = true;
    config.programs = {
    };
  };
  overlays = [
    (import (builtins.fetchTarball {
      url = "https://github.com/nix-community/emacs-overlay/archive/master.tar.gz";
    }))
  ];    
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
  

  # https://devenv.sh/basics/
  enterShell = ''
    first-setup-check
    hello
  '';

  enterTest = ''
    echo "Running tests"
    git --version | grep --color=auto "${pkgs.git.version}"
  '';

  # https://devenv.sh/git-hooks/
  # git-hooks.hooks.shellcheck.enable = true;

  # See full reference at https://devenv.sh/reference/options/
}
