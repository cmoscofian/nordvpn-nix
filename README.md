# NordVPN client flake

A Nix flake providing:

- A packaged version of the official **NordVPN** Linux CLI.
- A NixOS module for running the **nordvpnd** daemon as a systemd service.

The package downloads the official *NordVPN* Debian package, patches it for Nix,
and runs the daemon inside an FHS environment so it can locate the filesystem
layout expected by the upstream application.

## Installation

Add the flake as an input.

```nix
{
	inputs = {
		nordvpn-nix.url = "github:cmoscofian/nordvpn-nix";
	};
}
```

Import the NixOS module.

```nix
{
	imports = [
		inputs.nordvpn-nix.nixosModules.default
	];
}
```

Enable the service.

```nix
{
	custom.services.nordvpn = {
		enable = true;
	};
}
```

Rebuild your system.

```bash
sudo nixos-rebuild switch --flake path#hostname
```

## Configuration

The module exposes the following options.

```nix
custom.services.nordvpn = {
	enable = true;

	# Optional
	version = "5.0.0";
	hash = "sha256-F7/5WAAGaX3IJ3v/psp9cyWGs7kn2XOiCSN2Q6zeRAY=";
};
```

### Options

| Option      | Description                          | Default    |
|-------------|--------------------------------------|------------|
| **enable**  | Enable the NordVPN daemon            | `false`    |
| **version** | NordVPN Debian package version       | `5.0.0`    |
| **hash**    | SHA256 hash of the downloaded `.deb` | see module |

## Usage

After rebuilding, the daemon should start automatically.

Check its status:

```bash
systemctl status nordvpn
```

The CLI is available as:

```bash
nordvpn
```

Typical first-time setup:

```bash
nordvpn login
nordvpn connect
```

Consult the official **NordVPN** documentation for authentication methods and
supported commands.

## Updating NordVPN

The package version can be updated without modifying the package itself.

Simply override the module options:

```nix
custom.services.nordvpn = {
  enable = true;

  version = "5.3.0";
  hash = "<new hash>";
};
```

Alternatively, change the defaults inside `modules/nordvpn.nix`.

The latest versions available can be found [here](https://repo.nordvpn.com/deb/nordvpn/debian/pool/main/n/nordvpn/).

### Obtaining the new hash

When updating to a new version:

1. Change the version.
2. Build the system.

Nix will fail with the expected hash and print the correct value.

Copy that hash into your configuration.

## Updating flake inputs

To update the pinned version of `nixpkgs`:

```bash
nix flake update
```

or update only `nixpkgs`:

```bash
nix flake lock --update-input nixpkgs
```

## Overlay

The flake also exports an overlay.

```nix
{
	nixpkgs.overlays = [
		inputs.nordvpn-nix.overlays.default
	];
}
```

The package can then be accessed as:

```nix
pkgs.nordvpn-custom { }
```
