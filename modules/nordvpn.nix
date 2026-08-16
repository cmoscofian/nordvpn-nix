{ config, lib, pkgs, ... }:
let
	cfg = config.custom.services.nordvpn;
	nordVpnPkg = pkgs.callPackage ../pkgs/nordvpn.nix
	{
		inherit (cfg) version;
		inherit (cfg) hash;
	};
in
{
	options.custom.services.nordvpn =
	{
		enable = lib.mkEnableOption "NordVPN daemon";

		version = lib.mkOption
		{
			type = lib.types.str;
			default = "5.3.0";
			description = "NordVPN package version.";
		};

		hash = lib.mkOption
		{
			type = lib.types.str;
			default = "sha256-NM3qcqdclwDChblQ7S7Jasru1NYHATo6vRg2ZzH4wzQ=";
			description = "Hash of the NordVPN .deb package.";
		};
	};

	config = lib.mkIf cfg.enable
	{
		networking =
		{
			firewall =
			{
				checkReversePath = false;
			};
		};

		environment =
		{
			systemPackages = [ nordVpnPkg ];
		};

		users =
		{
			groups =
			{
				nordvpn = { };
			};
		};

		systemd =
		{
			services =
			{
				nordvpn =
				{
					description = "NordVPN daemon";

					wantedBy = [ "multi-user.target" ];
					after = [ "network-online.target" ];
					wants = [ "network-online.target" ];

					serviceConfig = {
						ExecStart = "${nordVpnPkg}/bin/nordvpnd";
						ExecStartPre = pkgs.writeShellScript "nordvpn-start" ''
							mkdir -m 700 -p /var/lib/nordvpn
							if [ -z "$(ls -A /var/lib/nordvpn)" ]; then
							cp -r ${nordVpnPkg}/var/lib/nordvpn/* /var/lib/nordvpn
							fi
						'';
						NonBlocking = true;
						KillMode = "process";
						Restart = "on-failure";
						RestartSec = 5;
						RuntimeDirectory = "nordvpn";
						RuntimeDirectoryMode = "0750";
						Group = "nordvpn";
					};
				};
			};
		};
	};
}
