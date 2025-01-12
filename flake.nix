{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "nixpkgs/nixos-unstable";
  };
  
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        # mvn2nix plugin
        maven-repository = (pkgs.buildMaven ./project-info.json).repo;
        
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

        # double invocation
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
          outputHash = "sha256-URq6vNUlF5tttDUeZ97o8IPMZgRMA17MpHmZdeV4wDw=";
        };

        matsim-2 = pkgs.stdenv.mkDerivation rec {
          pname = "matsim-example-project";
          version = "0.1.0-SNAPSHOT";
          
          src = ./.;
          buildInputs = with pkgs; [ maven jre ];
          nativeBuildInputs = with pkgs; [ makeWrapper ];
          
          buildPhase = ''
          echo "Using repository ${maven-repository-2}"
          mvn --offline -Dmaven.repo.local=${maven-repository-2} package;
          # mvn --offline -Dmaven.repo.local=${maven-repository-2} install;
          '';

          # installPhase = ''
          # install -Dm644 target/${pname}-${version}.jar $out/share/java
          # '';
          
          installPhase = ''
          mkdir -pv $out/share/java $out/bin
          install -Dm644 target/${pname}-${version}.jar $out/share/java
          makeWrapper ${pkgs.jre}/bin/java $out/bin/${pname} \
                      --add-flags "-cp $out/share/java/${pname}-${version}.jar"
          '';

          
          # installPhase = ''
   				#  mkdir -p $out/bin
   				
   				#  classpath=$(find ${maven-repository-2} -name "*.jar" -printf ':%h/%f');
   				#  #install -Dm644 target/${pname}-${version}.jar $out/share/java
   				
   				#  echo "====================="
   				#  echo $(ls)
   				#  echo $(ls target)
   				
   				#  install -Dm644 target/${pname}-${version}.jar $out/share/java
   				#  # create a wrapper that will automatically set the classpath
   				#  # this should be the paths from the dependency derivation
   				#  makeWrapper ${pkgs.jre}/bin/java $out/bin/${pname} \
   				#        --add-flags "-classpath $out/share/java/${pname}-${version}.jar:''${classpath#:}" \
   				#        --add-flags "Main"
   				# ''; 
          
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
  
