project-info.json: pom.xml
	mvn org.nixos.mvn2nix:mvn2nix-maven-plugin:mvn2nix
#	sed -i 's/\[2\.15\.0\,3\.0\.0)/2\.15\.0/g' $@

build: project-info.json
	nix build .\#maven-repository

build-2: project-info.json
	nix build .\#maven-repository-2

matsim: project-info.json
	nix build .\#monty-matsim

matsim-2: project-info.json
	nix build .\#monty-matsim-2

distclean:
	rm matsim-example-project-0.0.1-SNAPSHOT.jar
	rm -r target

