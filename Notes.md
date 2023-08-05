

Following:

https://ryantm.github.io/nixpkgs/languages-frameworks/maven/

https://nixos.wiki/wiki/Java


Steps

## Maven build
```
nix develop
mvn install # succeeds 
```

## Nix build

```
rm -r ~/.m2 # trying to stay clean
```


```
mvn org.nixos.mvn2nix:mvn2nix-maven-plugin:mvn2nix

```



## Discourse message

Hello, this is a call for assistance in getting a Java Maven project to build under Nix. The approach taken follows that described here:

https://ryantm.github.io/nixpkgs/languages-frameworks/maven/

The project in question is the agent based transport simulator MATSim example project, which I have forked and to which I have added a flake and a Makefile if you wish to ahve a hands-on look.

https://github.com/jademackay/matsim-example-project


