#!/usr/bin/env bash

set -e -o pipefail

input_fp="$(realpath "${1?Path to bu file missing}")"
dn="$(dirname "${input_fp}")"
bn="$(basename "${input_fp}")"
podman run -i --rm --security-opt label=disable \
  -v "$dn":/pwd -w /pwd quay.io/coreos/butane:release \
  --pretty --strict "$bn" > "${TMPDIR:-/tmp}/config.ign"
mv "${TMPDIR:-/tmp}/config.ign" "$dn/config.ign"
