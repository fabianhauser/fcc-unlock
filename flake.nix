{
  inputs = { nixos-stable.url = "github:NixOS/nixpkgs/nixos-22.11"; };

  outputs = { self, nixos-stable, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixos-stable { inherit system; };
    in {
      # Executed by `nix flake check`
      checks."<system>"."<name>" = derivation;
      # Executed by `nix build .#<name>`
      packages."<system>"."<name>" = derivation;
      # Executed by `nix build .`
      packages.${system}.default = pkgs.stdenv.mkDerivation {
        name = "fcc-unlock";

        # Source Code
        # See: https://nixos.org/nixpkgs/manual/#ssec-unpack-phase
        src = ./src;

        # Dependencies
        # See: https://nixos.org/nixpkgs/manual/#ssec-stdenv-dependencies
        buildInputs = with pkgs; [ coreutils gcc ];

        # Build Phases
        # See: https://nixos.org/nixpkgs/manual/#sec-stdenv-phases
        configurePhase = ''
          declare -xp
          sed -e "s#LIBDIR#$out/lib#" "$src/fcc-unlock.c" > fcc-unlock-patched.c
        '';
        buildPhase = ''
          gcc -ldl fcc-unlock-patched.c -o ./fcc-unlock
        '';
        installPhase = ''
          mkdir -p "$out/bin" "$out/lib"
          cp ./mbim2sar.so "$out/lib"
          cp ./fcc-unlock "$out/bin/"
          rm fcc-unlock-patched.c
        '';
      };
    };
}
