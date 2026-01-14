{ lib, buildGoModule, fetchFromGitHub, installShellFiles }:

buildGoModule rec {
  pname = "beads";
  version = "0.30.3";

  src = fetchFromGitHub {
    owner = "steveyegge";
    repo = "beads";
    rev = "v${version}";
    hash = "sha256-8XPYE01UPaeMORz4uTNX/CNYLk0R510Jnb0RZLaew5k=";
  };

  vendorHash = "sha256-Gyj/Vs3IEWPwqzfNoNBSL4VFifEhjnltlr1AROwGPc4=";

  subPackages = [ "cmd/bd" ];

  # Tests require git which isn't available in build sandbox
  doCheck = false;

  nativeBuildInputs = [ installShellFiles ];

  ldflags = [ "-s" "-w" "-X main.version=${version}" ];

  postInstall = ''
    # Rename binary from 'bd' to 'bd' (Go module name matches desired output)
    mv $out/bin/bd $out/bin/bd || true

    # Install shell completions if available
    if [ -f $out/bin/bd ]; then
      installShellCompletion --cmd bd \
        --bash <($out/bin/bd completion bash 2>/dev/null || true) \
        --fish <($out/bin/bd completion fish 2>/dev/null || true) \
        --zsh <($out/bin/bd completion zsh 2>/dev/null || true)
    fi
  '';

  meta = {
    description = "Beads - A memory upgrade for your coding agent";
    homepage = "https://github.com/steveyegge/beads";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "bd";
  };
}
