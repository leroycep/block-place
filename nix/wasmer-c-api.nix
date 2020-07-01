{ sources ? import ./sources.nix }:

let
  pkgs = import sources.nixpkgs {};
in
pkgs.rustPlatform.buildRustPackage rec {
  pname = sources.wasmer.repo;
  version = sources.wasmer.version;

  src = sources.wasmer;

  cargoSha256 = "1my06ap4bigd88igibn73fkc8shjqvnmz25ns75z9apjj35qjv50";

  nativeBuildInputs = with pkgs; [ cmake pkg-config ];

  LIBCLANG_PATH = "${pkgs.llvmPackages.libclang}/lib";

  buildAndTestSubdir = "lib/runtime-c-api";

  cargoBuildFlags = [
    "--no-default-features"
    "--features" "cranelift-backend"
  ];

  checkPhase = "";

  postInstall = ''
    mkdir -p $out/include
    mkdir -p $out/lib
    mkdir -p $out/lib/pkgconfig
    cp target/release/libwasmer_runtime_c_api.so $out/lib/libwasmer.so
    cp target/release/libwasmer_runtime_c_api.a $out/lib/libwasmer.a
    find target/release/build -name "wasmer.h*" -exec cp {} $out/include ';'
    cp LICENSE $out/LICENSE
    cp lib/runtime-c-api/doc/index.md $out/README.md

    cat ${./wasmer.pc} \
      | sed "s%TEMPLATE_PREFIX%$out%g" \
      | sed "s%TEMPLATE_NAME%${pname}%g" \
      | sed "s%TEMPLATE_VERSION%${version}%g" \
      > $out/lib/pkgconfig/${pname}.pc
  '';

}

