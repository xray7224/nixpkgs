{ stdenv, fetchgit, git, curl, autoconf, automake, ccache,
  libtool, apr, libconfuse, chrpath, pkgconfig,
  nasm, numactl, python27, libffi, openssl, jdk,
  yacc,
  # use nix dpdk package instead of statically linking
  dpdk,
  autoreconfHook
  }:

let version = "17.07"; in

stdenv.mkDerivation rec {
  name = "vpp-${version}";

  src = fetchgit {
    url = "https://gerrit.fd.io/r/vpp";
    rev = "refs/tags/v${version}";
    sha256 = "1kjfhp5zyy6l29dzqz4frgxm672aib0x57j9cbfhi1g4h6992pw3";
    # Next two needed for version information extraction
    deepClone = true;
    leaveDotGit = true;
  };

  # git needed to create version.h
  nativeBuildInputs = [ autoconf automake libtool pkgconfig yacc openssl git autoreconfHook ];
  buildInputs = [ python27 dpdk ];

  sourceRoot = "vpp/src";

  # Needed to build DPDk plugin with --static to avoid linking issues with Nix's DPDK
  patches = [ ./static.patch ];

  configureFlags = [ "--disable-papi" "--disable-japi" ];

  NIX_CFLAGS_COMPILE = "-march=corei7 -mtune=corei7-avx";

  # Fix up RPATH since TMPDIR seems to end up in it for some reason
  preFixup=''
    patchelf --set-rpath "$out/lib" "$out"/bin/vppapigen
  '';

  meta = with stdenv.lib; {
    description = "Vector packet processing";
    longDescription = ''
      Vector packet processing
    '';
    homepage = https://fd.io/;
    license = licenses.asl20;
    maintainers = [ maintainers.takikawa ];
    platforms = platforms.unix;
  };
}
