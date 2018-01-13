{ stdenv, fetchgit, git, autoconf, automake, curl,
  libtool, pkgconfig, python, pythonPackages, libffi,
  nasm, numactl, openjdk, boost, file,
  # FIXME: these are needed if python/java APIs are enabled
  # jdk,
  openssl,
  yacc, autoreconfHook, ensureNewerSourcesHook }:

let version = "17.10"; in

stdenv.mkDerivation rec {
  name = "vpp-${version}";

  src = fetchgit {
    url = "https://gerrit.fd.io/r/vpp";
    # When released, change to use the tag.
    rev = "refs/tags/v${version}";
    #branchName= "stable/1801";
  };

  # Create the version file manually.
  preBuild = ''
    cat > src/vpp/app/version.h <<EOF
    #define VPP_BUILD_DATE "Thu Jan 01 00:00:01 UTC 1970"
    #define VPP_BUILD_USER "$(whoami)"
    #define VPP_BUILD_HOST "nix"
    #define VPP_BUILD_TOPDIR ""
    #define VPP_BUILD_VER "${version}"
    EOF
  '';

  # git needed to create version.h
  nativeBuildInputs = [
    autoconf automake libtool pkgconfig yacc openssl git
    curl pythonPackages.setuptools nasm numactl
    boost file
    # Needed to build Python API (zip 1980 issue)
    (ensureNewerSourcesHook { year = "1980"; })
  ];

  buildInputs = [ python openjdk openssl ];

  sourceRoot = "vpp";

  # Needed to build API libraries
  dontDisableStatic = true;

  #makeFlags = [ "PLATFORM=vpp TAG=vpp" ];

  patches = [];

  NIX_CFLAGS_COMPILE = "-march=corei7 -mtune=corei7-avx";
  SSL_CERT_FILE = "/etc/ssl/certs/ca-bundle.crt";

  buildFlags = [ "build-release" ];

  installPhase = ''
    echo "Installing to $out"
    mkdir $out

    # Copy across header files we need. Ugh.
    mkdir -p $out/include/vlibsocket
    cp -r src/vlibsocket/* $out/include/vlibsocket/

    # Change to where we've build VPP and DPDK
    cd build-root/install-vpp-native

    # Install VPP.
    cp -r vpp/* $out/

    # Install DPDK
    cp -r dpdk/* $out/

    # Copy the openssl library.
    echo "openssl.out:"
    ls ${openssl.out}

    echo
    echo "openssl.out:/lib"
    ls ${openssl.out}/lib


    cp ${openssl.out}/lib/libcrypto.so.1.0.0 $out/lib64/libcrypto.so.1.0.0
  '';
  postInstall = "cd ../..";

  dontInstallCheck = true;

  # Fix up RPATH since TMPDIR seems to end up in it for some reason
  preFixup=''
    patchelf --set-rpath "$out/lib" "$out"/bin/vpp
    patchelf --set-rpath "$out/lib" "$out"/bin/vppapigen
    patchelf --set-rpath "$out/lib" "$out"/bin/vppctl
    patchelf --set-rpath "$out/lib" "$out"/bin/vpp_api_test
    patchelf --set-rpath "$out/lib" "$out"/bin/vpp_json_test
    patchelf --set-rpath "$out/lib" "$out"/bin/vpp_get_metrics
    patchelf --set-rpath "$out/lib" "$out"/bin/vpp_restart
    patchelf --set-rpath "$out/lib" "$out"/bin/svmtool
    patchelf --set-rpath "$out/lib" "$out"/bin/svmdbtool
    patchelf --set-rpath "$out/lib" "$out"/bin/elftool
    patchelf --set-rpath "$out/lib64" "$out/lib64/libvatplugin.so.0.0.0"
    patchelf --set-rpath "$out/lib64" "$out/lib64/libvlibmemory.so.0.0.0"
    patchelf --set-rpath "$out/lib64" "$out/lib64/libvlib.so.0.0.0"
    patchelf --set-rpath "$out/lib64" "$out/lib64/libvapiclient.so.0.0.0"
    patchelf --set-rpath "$out/lib64" "$out/lib64/libsvm.so.0.0.0"
    patchelf --set-rpath "$out/lib64" "$out/lib64/libvppcom.so.0.0.0"
    patchelf --set-rpath "$out/lib64" "$out/lib64/libsvmdb.so.0.0.0"
    patchelf --set-rpath "$out/lib64" "$out/lib64/libvlibmemoryclient.so.0.0.0"
    patchelf --set-rpath "$out/lib64" "$out/lib64/libvnet.so.0.0.0"
    patchelf --set-rpath "$out/lib64" "$out/lib64/libvlibsocket.so.0.0.0"
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
