locals {
  #build_timestamp = timestamp() # bad, doesn't return unix timestamp (https://github.com/hashicorp/packer/issues/11945)
  build_timestamp_utc = formatdate("YYYYMMDDhhmmss", timestamp())
  build_name          = "packer-coreos-${local.build_timestamp_utc}"
  build_labels = {
    "terraform"       = "false"
    "packer"          = "true"
    "build_timestamp" = local.build_timestamp_utc
    "os_family"       = "fedora"
    "os_flavor"       = "coreos"
    "os_arch"         = var.coreos_arch
    "os_version"      = var.coreos_version
    "coreos_stream"   = var.coreos_stream
  }
  snapshot_name       = "coreos-${var.coreos_version}-${local.build_timestamp_utc}"
  snapshot_labels     = local.build_labels
  coreos_download_url = "https://builds.coreos.fedoraproject.org/prod/streams/${var.coreos_stream}/builds/${var.coreos_version}/${var.coreos_arch}/fedora-coreos-${var.coreos_version}-metal.${var.coreos_arch}.raw.xz"
  coreos_filename     = basename(local.coreos_download_url)
}

source "hcloud" "rescue" {
  server_name = local.build_name
  server_type = "cax11"
  location    = "fsn1"
  image       = "ubuntu-24.04" # doesn't really matter as we're booting into rescue mode anyway
  rescue      = "linux64"

  ssh_username            = "root"
  temporary_key_pair_type = "ed25519"
  public_ipv6_disabled    = true

  server_labels   = local.build_labels
  ssh_keys_labels = local.build_labels
  snapshot_name   = local.snapshot_name
  snapshot_labels = local.snapshot_labels
}

build {
  name = "coreos-aarch64"

  sources = ["source.hcloud.rescue"]

  provisioner "shell" {
    inline_shebang = "/bin/bash -e"
    inline = [
      "set -o pipefail",
      "curl -sfSL -o \"${local.coreos_filename}\" \"${local.coreos_download_url}\"",
      "echo '${var.coreos_checksum}  ${local.coreos_filename}' | sha256sum -c -",
      "unxz -c \"${local.coreos_filename}\" | dd of=/dev/sda",
      "mount -v /dev/sda3 /mnt", # sda3 = boot
      "mkdir -vp /mnt/ignition",
    ]
  }

  provisioner "file" {
    source      = "${path.root}/files/ignition/config.ign"
    destination = "/tmp/config.ign"
  }

  provisioner "shell" {
    inline_shebang = "/bin/bash -e"
    inline = [
      "set -o pipefail",
      "mv -v /tmp/config.ign /mnt/ignition/",
      #"sed -i 's/ignition.platform.id=metal/ignition.platform.id=hetzner/' /mnt/loader/entries/ostree-1.conf", # FIXME boots to blank screen after grub menu
      "umount -v /mnt",
      "sync",
    ]
  }
}
