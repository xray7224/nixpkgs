{ stdenv, fetchgit, git, curl, autoconf, automake, ccache,
  libtool, apr, libconfuse, chrpath, pkgconfig,
  nasm, numactl, python3, libffi, openssl, jdk,
  yacc }:

let version = "17.07"; in

stdenv.mkDerivation rec {
  name = "vpp-${version}";

  src = fetchgit {
    url = "https://gerrit.fd.io/r/vpp";
    rev = "refs/tags/v${version}";
    sha256 = "1kjfhp5zyy6l29dzqz4frgxm672aib0x57j9cbfhi1g4h6992pw3";
    # Next two needed for post unpack steps below
    deepClone = true;
    leaveDotGit = true;
  };

  # there are build errors if git isn't configured like this
  # see https://wiki.fd.io/view/VPP/Pulling,_Building,_Running,_Hacking_and_Pushing_VPP_Code#Bootstrap_errors
  #preUnpack = "git config --global core.autocrlf input";

  #postUnpack = "cd vpp; make dist;"; # cd ..; tar tvJf vpp/build-root/vpp-latest.tar.xz";
  #setSourceRoot = "export sourceRoot='vpp-${version}'";

  #preConfigure = "make dist"

  # port GCC7 patches from newer VPP
  #patches = [ ./gcc7-1.patch ./gcc7-2.patch ];

  # patch up a warning from -Wmaybe-uninitialized
  #patches = [ ./warning.patch ];

  nativeBuildInputs = [ autoconf automake ccache libtool pkgconfig yacc curl jdk git ];
  buildInputs = [ python3 ];

  preBuild = "make bootstrap";
  buildFlags = [ "build" ];

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
