{ stdenv, fetchFromGitHub, pkgconfig, automake, autoconf, libtool,
  gettext, which, xorg, libX11, libXext, libXinerama, libXpm, libXft,
  libXau, libXdmcp, libXmu, libpng, libjpeg, expat, xproto, xextproto,
  xineramaproto, librsvg, freetype, fontconfig }:

stdenv.mkDerivation rec {
  name = "jwm-${version}";
  version = "1651";
  
  src = fetchFromGitHub {
    owner = "joewing";
    repo = "jwm";
    rev = "s${version}";
    sha256 = "097wqipg1h7h19a5bqdx7iq60fkjrx2niwsgg1f8cfz106yhbp6q";
  };

  nativeBuildInputs = [ pkgconfig automake autoconf libtool gettext which ];

  buildInputs = [ libX11 libXext libXinerama libXpm libXft xorg.libXrender
    libXau libXdmcp libXmu libpng libjpeg expat xproto xextproto xineramaproto
    librsvg freetype fontconfig ];

  enableParallelBuilding = true;

  preConfigure = "./autogen.sh";

  meta = {
    homepage = http://joewing.net/projects/jwm/;
    description = "Joe's Window Manager is a light-weight X11 window manager";
    license = stdenv.lib.licenses.gpl2;
    platforms   = stdenv.lib.platforms.unix;
    maintainers = [ stdenv.lib.maintainers.romildo ];
  };
}
