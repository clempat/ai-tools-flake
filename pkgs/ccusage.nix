{
  lib,
  stdenvNoCC,
  fetchurl,
  makeWrapper,
  nodejs_20,
}:

let
  mkNpmPackage = import ./lib/mkNpmPackage.nix { inherit lib stdenvNoCC fetchurl makeWrapper; };
in
mkNpmPackage {
  pname = "ccusage";
  version = "18.0.5";
  url = "https://registry.npmjs.org/ccusage/-/ccusage-18.0.5.tgz";
  hash = "sha256-Co9+jFDk4WmefrDnJvladjjYk+XHhYYEKNKb9MbrkU8=";
  nodejs = nodejs_20;
  description = "Usage analysis tool for Claude Code";
  homepage = "https://github.com/ryoppippi/ccusage";
}
