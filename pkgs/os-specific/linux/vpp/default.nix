{ stdenv, bash, fetchgit, git, autoconf, automake, curl,
  libtool, pkgconfig, python, pythonPackages, libffi,
  nasm, numactl, openjdk, boost, file,
  # FIXME: these are needed if python/java APIs are enabled
  # jdk,
  openssl,
  yacc, autoreconfHook, ensureNewerSourcesHook }:

let version = "18.04";
    revision = "7866c4595b65"; in

stdenv.mkDerivation rec {
  name = "vpp-${version}-${revision}";

  src = fetchgit {
    url = "https://gerrit.fd.io/r/vpp";
    rev = "${revision}";
  };

  # git needed to create version.h
  nativeBuildInputs = [
    autoconf automake libtool pkgconfig yacc openssl git
    curl pythonPackages.setuptools nasm numactl
    boost file
    # Needed to build Python API (zip 1980 issue)
    (ensureNewerSourcesHook { year = "1980"; })
  ];

  buildInputs = [ python openjdk openssl ];

  # Needed to build API libraries
  dontDisableStatic = true;

  postPatch = ''
    patchShebangs .
    substituteInPlace build-root/Makefile --replace /bin/bash ${bash}/bin/bash
    substituteInPlace dpdk/Makefile --replace /bin/bash ${bash}/bin/bash

    # Look for plugins in $out.
    substituteInPlace src/vat/plugin.c --replace /usr/lib $out/lib
    substituteInPlace src/vpp/api/plugin.c --replace /usr/lib $out/lib
    substituteInPlace src/vpp/vnet/main.c --replace /usr/lib $out/lib

    # Create the version file manually.
    cat > src/vpp/app/version.h <<EOF
    #define VPP_BUILD_DATE "Thu Jan 01 00:00:01 UTC 1970"
    #define VPP_BUILD_USER "nix"
    #define VPP_BUILD_HOST "nix"
    #define VPP_BUILD_TOPDIR ""
    #define VPP_BUILD_VER "${version}-${revision}"
    EOF
  '';

  buildPhase = ''
    # The arch_lib_dir line makes it so we always configure and
    # install to "lib" and never "lib64".

    make build-release arch_lib_dir=lib
  '';

  NIX_CFLAGS_COMPILE = "-march=corei7 -mtune=corei7-avx";
  SSL_CERT_FILE = "/etc/ssl/certs/ca-bundle.crt";

  installPhase = ''
    echo "Installing to $out"
    mkdir $out

    # Install DPDK and VPP.
    for subdir in dpdk vpp; do
      echo "Installing $subdir..."
      cp -r build-root/install-vpp-native/$subdir/* $out/
    done

    # Copy across missing header files; ugh.
    mkdir -p $out/include/vlibsocket
    cp -r src/vlibsocket/*.h $out/include/vlibsocket/

    # Replace rpath.
    build_rpath=$(pwd)/build-root/install-vpp-native/vpp/lib
    for f in $(find $out/bin -type f -print) $(find $out/lib -name '*.so*' -print); do
      patchelf --set-rpath \
         $(patchelf --print-rpath $f | sed -e s,$build_rpath,$out/lib,) \
         $f
      patchelf --shrink-rpath $f
    done
  '';

  dontInstallCheck = true;

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
