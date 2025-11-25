{ lib, python3Packages, fetchFromGitHub }:

python3Packages.buildPythonApplication rec {
  pname = "specify-cli";
  version = "0.0.22";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "github";
    repo = "spec-kit";
    rev =
      "f205fa3b58ab3a409bf0432dbafc9d2713b4b9bb"; # latest main as of 2025-01-19
    hash = "sha256-h4QPGg7KilfxzkWf1Hrk4bkveapKRkbzeEhioxdx1do=";
  };

  build-system = with python3Packages; [ hatchling ];

  dependencies = with python3Packages; [
    typer
    rich
    httpx
    platformdirs
    readchar
    truststore
  ];

  # No tests in repository
  doCheck = false;

  # truststore 0.10.1 in nixpkgs works fine despite >=0.10.4 requirement
  dontCheckRuntimeDeps = true;

  pythonImportsCheck = [ "specify_cli" ];

  meta = {
    description = "Specify CLI - tool for Spec-Driven Development";
    homepage = "https://github.com/github/spec-kit";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "specify";
  };
}
