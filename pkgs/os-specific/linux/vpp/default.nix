{ stdenv, fetchgit, git, autoconf, automake,
  libtool, pkgconfig, python, pythonPackages, libffi,
  # FIXME: these are needed if python/java APIs are enabled
  # jdk,
  openssl,
  yacc, autoreconfHook, ensureNewerSourcesHook,
  # use nix dpdk package (default build downloads a dpdk)
  dpdk }:

let version = "17.07"; in

stdenv.mkDerivation rec {
  name = "vpp-${version}";

  src = fetchgit {
    url = "https://gerrit.fd.io/r/vpp";
    rev = "refs/tags/v${version}";
    sha256 = "0llvn9h5yizdjwdb0f4z7sw27c8qyqw9iqkwwmmvzqrmwcar6dng";
  };

  preBuild = ''
    cat > vpp/app/version.h <<EOF
    #define VPP_BUILD_DATE "Thu Jan 01 00:00:01 UTC 1970"
    #define VPP_BUILD_USER "$(whoami)"
    #define VPP_BUILD_HOST "nix"
    #define VPP_BUILD_TOPDIR ""
    #define VPP_BUILD_VER "${version}"
    EOF
  '';

  # git needed to create version.h
  nativeBuildInputs = [ autoconf automake libtool pkgconfig yacc openssl git
                        autoreconfHook pythonPackages.setuptools
                        # Needed to build Python API (zip 1980 issue)
                        (ensureNewerSourcesHook { year = "1980"; }) ];
  buildInputs = [ python dpdk ];

  sourceRoot = "vpp/src";

  # Needed to build API libraries
  dontDisableStatic = true;

  patches = [ # Needed to build DPDk plugin with --static to avoid linking issues with Nix's DPDK
              ./static.patch ];

  # The java APIs caused build problems so don't build them for now
  configureFlags = [ "--disable-japi" ];

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
