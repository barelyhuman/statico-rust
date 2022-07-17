{
  cargo2nix ? builtins.fetchGit {
    url = https://github.com/cargo2nix/cargo2nix;
    rev = "4bbd3137ff1422ef3565748eae33efe6e2ffbf39";
  }
}:

let 
  cargo2nixOverlay = import "${cargo2nix}/overlay";
  pkgs = import <nixpkgs> {
    overlays = [ cargo2nixOverlay ];
  };
  cargo2nixDef = import "${cargo2nix}/default.nix" {};

in pkgs.mkShell {
  nativeBuildInputs = [
      pkgs.libiconv pkgs.openssl pkgs.rustup pkgs.gcc ];
  shellHook=''
  rustup install stable
  cargo install cargo-zigbuild
  '';
  buildInputs = with pkgs; [ rustfmt clippy ];
  RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";
}