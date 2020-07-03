{ sources ? import ./sources.nix }:

let
  pkgs = import sources.nixpkgs {};
in
pkgs.rustPlatform.buildRustPackage rec {
  pname = "wasmtime";
  version = "dev";

  src = pkgs.fetchFromGitHub {
    owner = "bytecodealliance";
    repo = "${pname}";
    rev = "3fa3ff2ecebe596df07f3e3dd5d5c1d2ea3514ab";
    sha256 = "15kxbd33ck4x0z0wpwfb0n0c893pv8lbs43vfs0i62rnybgcxkl9";
    fetchSubmodules = true;
  };

  cargoSha256 = "12nkyv6dbcsvc0csc6rp8fym8adw5rbc3sl7q3s9sviqcrgwy7yn";

  nativeBuildInputs = with pkgs; [ python cmake clang ];
  buildInputs = [ pkgs.llvmPackages.libclang ] ++
   pkgs.lib.optionals pkgs.stdenv.isDarwin [ pkgs.darwin.apple_sdk.frameworks.Security ];
  LIBCLANG_PATH = "${pkgs.llvmPackages.libclang}/lib";

  doCheck = false;

  cargoBuildFlags = ["-p" "wasmtime-c-api"];

  postInstall = ''
    mkdir -p $out/include
    cp crates/c-api/include/wasmtime.h $out/include/wasmtime.h
    cp crates/c-api/include/wasi.h $out/include/wasi.h
    cp crates/c-api/wasm-c-api/include/wasm.h $out/include/wasm.h

    mkdir -p $out/lib/pkgconfig
    cat ${./wasmtime.pc} \
      | sed "s%TEMPLATE_PREFIX%$out%g" \
      | sed "s%TEMPLATE_NAME%${pname}%g" \
      | sed "s%TEMPLATE_VERSION%${version}%g" \
      > $out/lib/pkgconfig/${pname}.pc
  '';

  meta = with pkgs.lib; {
    description = "Standalone JIT-style runtime for WebAssembly, using Cranelift";
    homepage = "https://github.com/CraneStation/wasmtime";
    license = licenses.asl20;
    maintainers = [ maintainers.matthewbauer ];
    platforms = platforms.unix;
  };
}
