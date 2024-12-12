variable "coreos_arch" {
  type    = string
  default = "aarch64"
}

variable "coreos_stream" {
  type    = string
  default = "stable"
}

variable "coreos_version" {
  type    = string
  default = "41.20241109.3.0"
}

variable "coreos_checksum" {
  description = "SHA256 hash of the compressed image"
  type        = string
  # https://builds.coreos.fedoraproject.org/streams/stable.json;
  # JQ: '.architectures.aarch64.artifacts.metal.formats."raw.xz".disk.sha256'
  default = "be42fcbe76843875ccc97b2e6423e60632ba17a3eac177ff3cfe1d1ad5760aaa"
}
