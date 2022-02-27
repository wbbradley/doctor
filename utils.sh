#!/usr/bin/env bash
# MacOS does not come with realpath.
case "$(uname)" in
  Darwin)
    # MacOS lacks realpath. Use Perl.
    realpath() {
      dirname="$(perl -e 'use Cwd "abs_path"; print abs_path(shift)' "$1")"
      echo "$dirname"
    }
    ;;
esac

on-macos() {
  [[ "$(uname)" = "Darwin" ]]
}

on-macos-m1() {
  on-macos && [[ "$(uname -m)" = "arm64" ]]
}

on-linux() {
  [[ "$(uname)" = "Linux" ]]
}

use-color() {
  [[ -z "$CI" ]]
}

fg6() {
  # Convert 8 8-bit decimal colors {r, g, b} into 6-cube color.
  # Prints ANSI escape code for the given fg color.
  fg_r="$(( $1 * 6/255 ))"
  fg_g="$(( $2 * 6/255 ))"
  fg_b="$(( $3 * 6/255 ))"
  fg_color="$(( 16 + fg_r * 36 + fg_g * 6 + fg_b ))"
  printf "\001\033[38;5;%sm\002" "$fg_color"
}

reset-color() {
  printf "\001\033[0m\002"
}

fgprint() {
  if use-color; then
    fg6 "$1" "$2" "$3"
    printf "%s" "$4"
    reset-color
  else
    printf "%s" "$4"
  fi
}

print-level() {
  level=$1
  case "$level" in
    info)
      fgprint 135 235 244 "$level"
      return
      ;;
    note)
      fgprint 255 165 0 "$level"
      return
      ;;
    warn)
      fgprint 247 147 26 "$level"
      return
      ;;
    error)
      fgprint 228 0 0 "$level"
      return
      ;;
  esac
  # Fallback
  printf "%s" "$level"
}

log() {
  level="$1"
  shift
  scriptname="$(basename "$0")"
  fgprint 0 167 195 "$scriptname"
  printf ": "
  print-level "$level"
  [[ -n "$VERBOSE$CI" ]] && {
    delim=" ["
    for (( i=${#FUNCNAME[@]} - 2; i > 1; i-- )); do
      printf "%s%s" "$delim" "${FUNCNAME[$i]}"
      delim="»"
    done
    [[ "$delim" != " [" ]] && printf ']'
  }
  printf ": %s\n" "$*"
}

inform() {
  log info "$@"
}

die() {
  log error "$@" >&2
  exit 1
}

error() {
  log error "$@" >&2
}

warn() {
  log warn "$@" >&2
}

note() {
  log note "$@"
}
# vim: ft=bash
