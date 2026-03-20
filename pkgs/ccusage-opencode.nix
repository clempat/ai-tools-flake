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
  pname = "ccusage-opencode";
  version = "18.0.5";
  url = "https://registry.npmjs.org/@ccusage/opencode/-/opencode-18.0.5.tgz";
  hash = "sha256-5bgHdd2Xd52zcBtVKcEKyd5Vd78pLaPmyFBPm2Sq+Ko=";
  nodejs = nodejs_20;
  description = "Usage analysis tool for OpenCode";
  homepage = "https://github.com/ryoppippi/ccusage";
}
