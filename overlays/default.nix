{ inputs, ... }:
final: prev:
let
  packageJson = builtins.fromJSON
    (builtins.readFile "${inputs.opencode}/packages/opencode/package.json");
in {
  # Override opencode to use latest version from flake input
  # opencode = prev.opencode.overrideAttrs (old: {
  #   version = packageJson.version;
  #   src = inputs.opencode;
  #   patches = [];  # Disable patches from old version
  #
  #   node_modules = old.node_modules.overrideAttrs {
  #     version = packageJson.version;
  #     src = inputs.opencode;
  #     outputHash = "sha256-F7OzOlXa8K+bQc6Enkx1+zWXl4dinnuAVuZ+rY3Brzk=";
  #   };
  # });
}
