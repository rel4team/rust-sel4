{ lib, stdenv, buildPackages
, writeText, emptyFile
, mkShell
, defaultRustToolchain
, defaultRustTargetInfo
, bareMetalRustTargetInfo
, libclangPath
, sources
, dummyCapDLSpec, serializeCapDLSpec
, seL4RustEnvVars
, worldConfig
, seL4ForBoot
}:

let
  kernelLoaderConfigEnvVars = lib.optionalAttrs (!worldConfig.isCorePlatform && worldConfig.kernelLoaderConfig != null) {
    SEL4_KERNEL_LOADER_CONFIG = writeText "loader-config.json" (builtins.toJSON worldConfig.kernelLoaderConfig);
  };

  capdlEnvVars = lib.optionalAttrs (!worldConfig.isCorePlatform) {
    CAPDL_SPEC_FILE = serializeCapDLSpec { inherit (dummyCapDLSpec.passthru) spec; };
    CAPDL_FILL_DIR = dummyCapDLSpec.passthru.fill;
  };

in
mkShell (seL4RustEnvVars // kernelLoaderConfigEnvVars // capdlEnvVars // {
  # TODO
  RUST_SEL4_TARGET = defaultRustTargetInfo.name;

  RUST_BARE_METAL_TARGET = bareMetalRustTargetInfo.name;

  HOST_CARGO_FLAGS = lib.concatStringsSep " " [
    "-Z" "build-std=core,alloc,compiler_builtins"
    "-Z" "build-std-features=compiler-builtins-mem"
  ];

  LIBCLANG_PATH = libclangPath;

  hardeningDisable = [ "all" ];

  nativeBuildInputs = [
    defaultRustToolchain
  ];

  depsBuildBuild = [
    buildPackages.stdenv.cc
  ];

  shellHook = ''
    # abbreviation
    export h=$HOST_CARGO_FLAGS
  '';
})
