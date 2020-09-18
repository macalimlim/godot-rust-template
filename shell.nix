with import <nixpkgs> {
  config.android_sdk.accept_license = true;
};

stdenv.mkDerivation {
  name = "{{project-name}}";
  nativeBuildInputs = [
    cacert
    emacs
    godot
    jdk
    nix
    openssl
    pkgconfig
    sccache
  ];
  buildInputs = [
    alsaLib
    clang
    glibc_multi
    libGL
    libpulseaudio
    xorg.libX11
    xorg.libXcursor
    xorg.libXi
    xorg.libXinerama
    xorg.libXrandr
    xorg.libXrender
    zlib
  ];
  shellHook = ''
    export PATH=$HOME/.rustup/toolchains/stable-x86_64-unknown-linux-gnu/bin:$PATH
  '';

  # Set Environment Variables
  EDITOR = "emacs";
  LD_LIBRARY_PATH = builtins.concatStringsSep ":"  [
    "${alsaLib}/lib/"
    "${libGL}/lib/"
    "${libpulseaudio}/lib/"
    "${xorg.libX11}/lib/"
    "${xorg.libXcursor}/lib/"
    "${xorg.libXi}/lib/"
    "${xorg.libXinerama}/lib/"
    "${xorg.libXrandr}/lib/"
    "${xorg.libXrender}/lib/"
    "${zlib}/lib/"
  ];
  LIBCLANG_PATH = "${llvmPackages.libclang}/lib";
  RUST_BACKTRACE = 1;
  RUSTC_WRAPPER = "${sccache}/bin/sccache";
}
