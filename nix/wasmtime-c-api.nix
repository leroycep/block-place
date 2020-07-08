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
    rev = "bef1b87be0d5655f2b36a7a9f8d71cbf06fe2898";
    sha256 = "0g03gyf05vk2ziqndjc3igw1f00raif7lxzrsxpma9k4pcwa5wg2";
    fetchSubmodules = true;
  };

  cargoSha256 = "0si9mjl83l4qffh4qr0zl4q5k7ns9kwg6m0y42nqnxf43z0lg75c";

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
