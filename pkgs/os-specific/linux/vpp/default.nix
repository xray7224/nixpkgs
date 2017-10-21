{ stdenv, fetchgit, git, curl, autoconf, automake, ccache,
  libtool, apr, libconfuse, chrpath, pkgconfig,
  nasm, numactl, python3, libffi, openssl, jdk,
  yacc,
  # use nix dpdk package instead of statically linking
  dpdk,
  autoreconfHook }:

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

  nativeBuildInputs = [ autoconf automake ccache libtool pkgconfig yacc curl jdk git autoreconfHook ];
  buildInputs = [ python3 dpdk ];

  sourceRoot = "vpp/src";

  #preBuild = "make bootstrap";
  #buildFlags = [ "build" ];

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
