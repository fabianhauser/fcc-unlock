{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
  };

  outputs =
    { self, nixpkgs, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in
    {
      packages.${system}.default = pkgs.stdenv.mkDerivation {
        name = "fcc-unlock";
        src = ./src;
        buildInputs = with pkgs; [
          coreutils
          gcc
        ];

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
