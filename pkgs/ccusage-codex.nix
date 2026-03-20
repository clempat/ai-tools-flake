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
  pname = "ccusage-codex";
  version = "18.0.5";
  url = "https://registry.npmjs.org/@ccusage/codex/-/codex-18.0.5.tgz";
  hash = "sha256-q4tHdc7sIz8qao47BgYqLzEDJUbsUn4MzoHxp1NyzPI=";
  nodejs = nodejs_20;
  description = "Usage analysis tool for OpenAI Codex";
  homepage = "https://github.com/ryoppippi/ccusage";
}
