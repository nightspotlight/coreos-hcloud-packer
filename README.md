# coreos-hcloud-packer

Packer scripts for building a [Fedora CoreOS](https://fedoraproject.org/coreos/) server image in [Hetzner Cloud](https://www.hetzner.com/cloud/).

## Prerequisites

1. Set environment variable `HCLOUD_TOKEN` prior to running Packer.

## Upgrading

Provide new values for variables `coreos_version` and paste corresponding SHA256 checksum in `coreos_checksum` (as found in stream JSON).

## Authors

* Roman Eremeev (@nightspotlight)

## License

This work is licensed under the MIT License – see [LICENSE](LICENSE) file for details.
