{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "nixpkgs/nixos-unstable";
  };
  
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        # maven-repository = pkgs.callPackage ./build-maven-repository.nix { };
        maven-repository = (pkgs.buildMaven ./project-info.json).repo;

        matsim = pkgs.stdenv.mkDerivation rec {
          pname = "matsim-example-project";
          version = "0.0.1-SNAPSHOT";
          
          src = ./.;
          buildInputs = [ pkgs.maven ];
          
          buildPhase = ''
          echo "--------------------"
          echo "Using repository ${maven-repository}"
          mvn --offline -Dmaven.repo.local=${maven-repository} package;
          # mvn -Dmaven.repo.local=${maven-repository} package;
          '';

          installPhase = ''
          install -Dm644 target/${pname}-${version}.jar $out/share/java
          '';
        };

      in rec {        
        packages.default = packages.matsim;
        packages.matsim = matsim;
        packages.maven-repository = maven-repository;
        
        devShell =  pkgs.mkShell {
          buildInputs = with pkgs; [
            maven
            jre
            fx
          ]; 
        };        
      }
    );
}
  
