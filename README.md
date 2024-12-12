# coreos-hcloud-packer

Packer scripts for building a [Fedora CoreOS](https://fedoraproject.org/coreos/) server image in [Hetzner Cloud](https://www.hetzner.com/cloud/).

## Prerequisites

1. Set environment variable `HCLOUD_TOKEN` prior to running Packer.

## Upgrading

Provide new values for variables `coreos_version` and paste corresponding SHA256 checksum in `coreos_checksum` (as found in stream JSON).

## TODO

1. Fix boot freeze when setting kernel argument `ignition.platform.id=hetzner`.

1. Fix loading SSH authorized_keys file from metadata server.

1. Automate Ignition file generation with Butane. Possibly using GitHub Actions.

    The commands are:

    ```sh
    podman pull quay.io/coreos/butane:release
    podman run -i --rm --security-opt label=disable \
      -v "$PWD":/pwd -w /pwd quay.io/coreos/butane:release \
      --pretty --strict config.bu > config.ign
    ```

## Authors

* Roman Eremeev (@nightspotlight)

## License

This work is licensed under the MIT License – see [LICENSE](LICENSE) file for details.
