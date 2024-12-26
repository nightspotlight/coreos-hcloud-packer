variable "coreos_stream" {
  type    = string
  default = "stable"
}

variable "coreos_version" {
  type    = string
  default = "41.20241122.3.0"
}

variable "coreos_checksum" {
  description = "SHA256 hash of the compressed image"
  type        = object({ aarch64 = string, x86_64 = string })
  # https://builds.coreos.fedoraproject.org/streams/stable.json;
  # JQ: '.architectures.aarch64.artifacts.metal.formats."raw.xz".disk.sha256'
  default = {
    aarch64 = "ecbe8dfd6081e828c8e89f816d21c8f91ab4bd1c1e717d2238ae9dd43286b5a7"
    x86_64  = "a0ca4edb6850c0d04c36eb5832abadbd611e2a2466c6def9058c761f4602b49e"
  }
}
