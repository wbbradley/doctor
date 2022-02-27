#!/usr/bin/env bash
# shellcheck disable=SC2034
#
# Instance of doctor dependencies.
#

declare -a IGNORE_DEPS
IGNORE_DEPS=( )

# The top-level list of dependencies/tweaks for development. Take care in changing the
# order of these dependencies.
DEPS=(
)

#
# Utility Functions
#
missing() {
  ! command -v "$1" 1>/dev/null
}

is-broken-dep() {
  dep=$1
  if declare -F | grep " broken-$dep$" >/dev/null; then
    "broken-$dep"
  else
    missing "$dep"
  fi
}

