{ lib, stdenv, fetchFromGitHub, xcodebuild, darwin }:
let
  inherit (darwin.apple_sdk.frameworks) CoreAudio;
in
stdenv.mkDerivation rec {
  pname = "BlackHole";
  version = "v0.2.10";
  src = fetchFromGitHub {
    owner = "ExistentialAudio";
    repo = "BlackHole";
    rev = "refs/tags/${version}";
    sha256 = "sha256:0dyfz11vfdzwxzyi60yzkg68k3g0vj9mfgj1yqgz9q7vlgx3ngvy";
  };
  buildInputs = [
    xcodebuild
    CoreAudio
  ];
  buildPhase = ''
    xcodebuild build
  '';
  installPhase = ''
    mkdir -p $out/Library/Audio/Plug-Ins/HAL
    mv BlackHole-*/Build/Products/*/*.driver $out/Library/Audio/Plug-Ins/HAL/BlackHole2ch.driver
  '';
  meta = with lib; {
    description = "MacOS virtual audio driver that allows applications to pass audio to other applications";
    homepage = "https://github.com/ExistentialAudio/BlackHole";
    license = licenses.gpl3;
    platforms = platforms.darwin;
    maintainers = [ ];
  };
}
