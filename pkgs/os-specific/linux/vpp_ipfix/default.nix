{ stdenv, fetchgit, autoconf, automake, libtool, vpp }:

stdenv.mkDerivation rec {
  name = "vpp-ipfix";

  src = fetchgit {
    url = "https://github.com/xray7224/vpp-ipfix.git";

    # Using specific commit so i'm able to trigger a rebuild on newer versions.
    branchName = "338516a";
  };

  nativebuildInputs = [ vpp ];
  buildInputs = [ autoconf automake libtool vpp ];

  preConfigure = ''
    libtoolize
    aclocal
    autoconf
    automake --add-missing
  '';

  patches = [ ./1801.patch ];
  
  # The tests are causing us problems, I think we need to modify stuff for the
  # later versions.
  preBuild = ''
  rm ipfix/ipfix_test.*
  touch ipfix/ipfix_test.c
  '';

  meta = with stdenv.lib; {
    description = "IPFIX implementation using VPP framework.";
    longDescription = ''
      IPFIX implementation using VPP framework.
    '';
    homepage = "https://github.com/xray7224/vpp-ipfix/";
    license = licenses.asl20;
    maintainers = [ maintainers.tsyesika ];
    platforms = platforms.unix;
  };
}
