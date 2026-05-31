{
	description = "NordVPN package and NixOS module";

	inputs =
	{
		nixpkgs =
		{
			url = "github:nixos/nixpkgs/nixos-unstable";
		};
	};

	outputs = { self, nixpkgs }:
	let
		lib = nixpkgs.lib;
		systems = [ "x86_64-linux" ];
		forAllSystems = f:
		lib.genAttrs systems (system:
			f
			(
				import nixpkgs
				{
					inherit system;
				}
			)
		);
	in
	{
		overlays =
		{
			default = final: prev:
			{
				nordvpn-custom = args:
					prev.callPackage ./pkgs/nordvpn.nix args;
			};
		};
		packages = forAllSystems (pkgs: {
			default = pkgs.callPackage ./pkgs/nordvpn.nix { };
			nordvpn = pkgs.callPackage ./pkgs/nordvpn.nix { };
		});
		nixosModules =
		{
			default = import ./modules/nordvpn.nix;
		};
	};
}
