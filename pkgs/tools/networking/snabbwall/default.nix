{ stdenv, lib, fetchFromGitHub, bash, makeWrapper, git, mariadb, diffutils, which, coreutils, procps, nettools, ndpi }:

stdenv.mkDerivation rec {
  name = "snabbwall-${version}";
  version = "0.4";

  src = fetchFromGitHub {
    owner = "aperezdc";
    repo = "snabb";
    rev = "snabbwall-v${version}";
    sha256 = "0x605gzl7rkhj60w1c3qv81lvrmk5a58hqhq0s2s41imwa63gw66";
  };

  buildInputs = [ makeWrapper ];

  patchPhase = ''
    patchShebangs .

    # some hardcodeism
    for f in $(find src/program/snabbnfv/ -type f); do
      substituteInPlace $f --replace "/bin/bash" "${bash}/bin/bash"
    done

    # We need a way to pass $PATH to the scripts
    sed -i '2iexport PATH=${stdenv.lib.makeBinPath [ git mariadb which procps coreutils ]}' src/program/snabbnfv/neutron_sync_master/neutron_sync_master.sh.inc
    sed -i '2iexport PATH=${stdenv.lib.makeBinPath [ git coreutils diffutils nettools ]}' src/program/snabbnfv/neutron_sync_agent/neutron_sync_agent.sh.inc
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp src/snabb $out/bin
  '';

  postFixup =''
    wrapProgram $out/bin/snabb --prefix LD_LIBRARY_PATH : "${ndpi}/lib"
  '';

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    homepage = https://www.snabbwall.org;
    description = "Layer 7 firewall on the Snabb toolkit";
    longDescription = ''
      Snabbwall is a layer 7 (application-level) firewall suite built
      on top of the Snabb networking toolkit.
    '';
    platforms = [ "x86_64-linux" ];
    license = licenses.asl20;
    maintainers = [ maintainers.takikawa ];
  };
}

