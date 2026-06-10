{ lib, stdenv, libusb1, pkg-config }:

stdenv.mkDerivation {
  pname = "xvcd-pico";
  version = "0.1";

  src = ../daemon;

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ libusb1 ];

  buildPhase = ''
    runHook preBuild
    $CC -O2 -o xvcd-pico xvcpico.c $(pkg-config --cflags --libs libusb-1.0)
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 xvcd-pico $out/bin/xvcd-pico
    runHook postInstall
  '';

  meta = with lib; {
    description = "Host-side Xilinx Virtual Cable daemon for the xvc-pico JTAG probe";
    homepage = "https://github.com/kholia/xvc-pico";
    license = licenses.cc0;
    mainProgram = "xvcd-pico";
    platforms = platforms.linux;
  };
}
