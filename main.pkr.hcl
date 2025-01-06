locals {
  build_architectures = {
    "x86_64"  = "cx22"
    "aarch64" = "cax11"
  }
  build_timestamp_utc = formatdate("YYYYMMDDhhmmss", timestamp())
  build_labels = {
    "terraform"       = "false"
    "packer"          = "true"
    "build_timestamp" = local.build_timestamp_utc
    "os_family"       = "fedora"
    "os_flavor"       = "coreos"
    "os_version"      = var.coreos_version
    "coreos_stream"   = var.coreos_stream
  }
}

source "hcloud" "rescue" {
  location = "fsn1"
  image    = "ubuntu-24.04" # doesn't really matter as we're booting into rescue mode anyway
  rescue   = "linux64"

  ssh_username            = "root"
  temporary_key_pair_type = "ed25519"
  public_ipv6_disabled    = true
}

build {
  name = "coreos"

  dynamic "source" {
    for_each = local.build_architectures
    labels   = ["hcloud.rescue"]

    content {
      name = source.key

      server_name = "packer-coreos-${replace(source.key, "_", "-")}-${local.build_timestamp_utc}"
      server_type = source.value
      server_labels = merge(local.build_labels, {
        os_arch    = source.key
        build_name = "packer-coreos-${replace(source.key, "_", "-")}-${local.build_timestamp_utc}"
      })
      ssh_keys_labels = merge(local.build_labels, {
        os_arch    = source.key
        build_name = "packer-coreos-${replace(source.key, "_", "-")}-${local.build_timestamp_utc}"
      })
      snapshot_name = "coreos-${source.key}-${local.build_timestamp_utc}"
      snapshot_labels = merge(local.build_labels, {
        os_arch = source.key
      })
    }
  }

  provisioner "shell" {
    env = {
      COREOS_DL_URL = "https://builds.coreos.fedoraproject.org/prod/streams/${var.coreos_stream}/builds/${var.coreos_version}/${source.name}/fedora-coreos-${var.coreos_version}-metal.${source.name}.raw.xz"
    }
    inline_shebang = "/bin/bash -e"
    inline = [
      "set -u -o pipefail",
      "curl -sfSL -o coreos.raw.xz \"$COREOS_DL_URL\"",
      "echo '${var.coreos_checksum[source.name]}  coreos.raw.xz' | sha256sum -c -",
      "unxz -c coreos.raw.xz | dd of=/dev/sda",
      "mount -v /dev/sda3 /mnt",                                                                               # sda3 = boot
      "sed -i 's/ignition.platform.id=metal/ignition.platform.id=hetzner/' /mnt/loader/entries/ostree-1.conf", # FIXME boots to blank screen after grub menu
      "umount -v /mnt",
      "sync",
    ]
  }

  post-processor "manifest" {
    output     = "packer-manifest-${source.name}.json"
    strip_path = true
    custom_data = merge(local.build_labels, {
      os_arch = source.name
    })
  }
}
