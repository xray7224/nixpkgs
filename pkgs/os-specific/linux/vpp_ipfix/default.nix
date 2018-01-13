{ stdenv, fetchgit, autoconf, automake, libtool, vpp }:

stdenv.mkDerivation rec {
  name = "vpp-ipfix";

  src = fetchgit {
    url = "https://github.com/xray7224/vpp-ipfix.git";
  };

  nativebuildInputs = [ vpp ];
  buildInputs = [ autoconf automake libtool vpp ];

  preConfigure = ''
    libtoolize
    aclocal
    autoconf
    automake --add-missing
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
