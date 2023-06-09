{ lib, stdenv, hostPlatform, buildPackages
, fetchFromGitHub
, bc, bison, dtc, flex
, openssl
}:

let
  defconfig =
    let
      modifier = lib.optionalString hostPlatform.is32bit "_32b";
    in
      "rpi_4${modifier}_defconfig";

  makeTargets = filesToInstall;

  filesToInstall = [ "u-boot" "u-boot.bin" ];

in
stdenv.mkDerivation rec {
  name = "u-boot";

  src = fetchFromGitHub {
    owner = "u-boot";
    repo = "u-boot";
    rev = "v2023.04";
    sha256 = "sha256-k4CgiG6rOdgex+YxMRXqyJF7NFqAN9R+UKc3Y/+7jV0=";
  };

  # src = builtins.fetchGit {
  #   url = "https://gitlab.com/coliasgroup/icecap/u-boot.git";
  #   rev = "6e73588b00397be29e2b91d279062e9372dc8092"; # branch icecap
  # };

  depsBuildBuild = [
    buildPackages.stdenv.cc
  ];

  nativeBuildInputs = [
    bc bison dtc flex
    openssl
  ];

  hardeningDisable = [ "all" ];

  patchPhase = ''
    patchShebangs tools
  '';

  configurePhase = ''
    make ${defconfig}
  '';

  makeFlags = [
    "DTC=dtc"
    "CROSS_COMPILE=${stdenv.cc.targetPrefix}"
  ] ++ makeTargets;

  installPhase = ''
    mkdir $out
    cp ${lib.concatStringsSep " " filesToInstall} $out
  '';

  dontStrip = true;
}