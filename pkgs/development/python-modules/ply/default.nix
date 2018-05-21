{ stdenv, buildPythonPackage, fetchPypi }:

buildPythonPackage rec {
  name = "${pname}-${version}";
  version = "3.11";
  pname = "ply";

  src = fetchPypi {
	inherit pname version;
  };

  # Tests require extra dependencies
  doCheck = false;

  meta = with stdenv.lib; {
	homepage = http://www.dabeaz.com/ply/;
	description = " lex and yacc parsing tools for Python";
	license = licenses.bsd3;
  };
}
