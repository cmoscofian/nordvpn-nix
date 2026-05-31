{
	autoPatchelfHook,
	buildFHSEnv,
	cacert,
	dpkg,
	fetchurl,
	iproute2,
	iptables,
	lib,
	libcap_ng,
	libidn2,
	libnl,
	libxml2,
	procps,
	sqlite,
	stdenv,
	sysctl,
	wireguard-tools,
	zlib,

	version ? "5.0.0",
	hash ? "sha256-F7/5WAAGaX3IJ3v/psp9cyWGs7kn2XOiCSN2Q6zeRAY=",
}:
let
	pname = "nordvpn";
	nordVPNBase = stdenv.mkDerivation
	{
		inherit pname;
		inherit version;

		src = fetchurl
		{
			url = "https://repo.nordvpn.com/deb/nordvpn/debian/pool/main/n/nordvpn/nordvpn_${version}_amd64.deb";
			inherit hash;
		};

		buildInputs =
		[
			libcap_ng
			libidn2
			libnl
			libxml2
			sqlite
		];

		nativeBuildInputs =
		[
			autoPatchelfHook
			dpkg
			stdenv.cc.cc.lib
		];

		dontConfigure = true;
		dontBuild = true;

		unpackPhase = ''
			runHook preUnpack

			dpkg --extract $src .

			runHook postUnpack
		'';

		installPhase = ''
			runHook preInstall

			mkdir -p $out
			mv usr/* $out/
			mv var/ $out/
			mv etc/ $out/

			runHook postInstall
		'';
	};

	nordVPNfhs = buildFHSEnv
	{
		name = "nordvpnd";
		runScript = "nordvpnd";
		targetPkgs = pkgs:
		[
			cacert
			iproute2
			iptables
			libcap_ng
			libidn2
			libnl
			libxml2
			nordVPNBase
			procps
			sqlite
			sysctl
			wireguard-tools
			zlib
		];
	};
in
stdenv.mkDerivation
{
	inherit pname;
	inherit version;

	dontUnpack = true;
	dontConfigure = true;
	dontBuild = true;

	installPhase = ''
		runHook preInstall

		mkdir -p $out/bin $out/share
		ln -s ${nordVPNBase}/bin/nordvpn $out/bin
		ln -s ${nordVPNfhs}/bin/nordvpnd $out/bin
		ln -s ${nordVPNBase}/share/* $out/share/
		ln -s ${nordVPNBase}/var $out/

		runHook postInstall
	'';

	meta = with lib;
	{
		description = "CLI client for NordVPN";
		homepage = "https://www.nordvpn.com";
		license = licenses.unfreeRedistributable;
		platforms = [ "x86_64-linux" ];
	};
}
