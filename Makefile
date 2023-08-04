project-info.json: pom.xml
	mvn org.nixos.mvn2nix:mvn2nix-maven-plugin:mvn2nix

maven-repository: project-info.json
	nix build .\#$@

maven-repository-2: project-info.json
	nix build .\#$@

matsim: maven-repository
	nix build .\#$@

matsim-2: maven-repository-2
	nix build .\#$@

distclean:
	rm matsim-example-project-0.0.1-SNAPSHOT.jar
	rm -r target
