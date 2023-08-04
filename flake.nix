{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "nixpkgs/nixos-unstable";
  };
  
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        maven-repository = pkgs.callPackage ./build-maven-repository.nix { };

        maven-repository-2 = pkgs.stdenv.mkDerivation {
          name = "maven-repository";
          buildInputs = [ pkgs.maven ];
          src = ./.; # or fetchFromGitHub, cleanSourceWith, etc
          buildPhase = ''
          mvn package -Dmaven.repo.local=$out
          '';

          # keep only *.{pom,jar,sha1,nbm} and delete all ephemeral files
          # with lastModified timestamps inside
          installPhase = ''
          find $out -type f \
          -name \*.lastUpdated -or \
          -name resolver-status.properties -or \
          -name _remote.repositories \
          -delete
          '';

          # don't do any fixup
          dontFixup = true;
          outputHashAlgo = "sha256";
          outputHashMode = "recursive";
          # replace this with the correct SHA256
          # outputHash = pkgs.lib.fakeSha256;
          outputHash = "sha256-X3dO/jW1c9hMfQKRFYFDFpbGK+TGBAWpNtv+kPJ5KDw=";
        };

        matsim = pkgs.stdenv.mkDerivation rec {
          pname = "matsim-example-project";
          version = "0.0.1-SNAPSHOT";
          
          src = ./.;
          buildInputs = [ pkgs.maven ];
          
          buildPhase = ''
          echo "Using repository ${maven-repository}"
          mvn --offline -Dmaven.repo.local=${maven-repository} package;
          '';

          installPhase = ''
          install -Dm644 target/${pname}-${version}.jar $out/share/java
          '';
        };
                                       
        matsim-2 = pkgs.stdenv.mkDerivation rec {
          pname = "matsim";
          version = "0.1.0";
          
          src = ./.;
          buildInputs = [ pkgs.maven ];
          
          buildPhase = ''
          echo "Using repository ${maven-repository-2}"
          mvn --offline -Dmaven.repo.local=${maven-repository-2} package;
          '';

          installPhase = ''
          install -Dm644 target/${pname}-${version}.jar $out/share/java
          '';
        };
        
      in rec {        
        packages.default = packages.matsim;
        packages.matsim = matsim;
        packages.matsim-2 = matsim-2;
        packages.maven-repository = maven-repository;
        packages.maven-repository-2 = maven-repository-2;
        
        devShell =  pkgs.mkShell {
          buildInputs = [
            pkgs.maven
            pkgs.jre
          ]; 
        };        
      }
    );
}
  
