#!/usr/bin/env zsh

__J_CONFIG_DIR="$HOME/.j"
__J_DB="$__J_CONFIG_DIR/db"
__J_DB_TMP="$__J_CONFIG_DIR/db_tmp"

function j() {
  [ -z "$1" ] || [ "$1" = "-h" ] || [ "$1" = "--help" ] && show_usage && return

  local match="$(cat "$__J_DB" | fzf --filter "$1" | head -1)"

  [ -z "$match" ] && show_missing && return

  cd "$match"
}

function j_chpwd() {
  echo "`pwd`" >> "$__J_DB"
  sort -u "$__J_DB" > "$__J_DB_TMP"
  cat "$__J_DB_TMP" > "$__J_DB"
}

function show_missing() {
  echo "No matching directories found.\n"
}

function show_usage() {
  cat << USAGE
Usage: j [-h] [--help] <pattern>

Quickly navigate your filesystem with the power of fzf.

Options

  -h, --help  View options and examples

Examples

  j -h
  j somedir
  j ../relative/path/to/dir

USAGE
}

# initialize the zsh array for registering `chpwd` hooks
declare -gaU chpwd_functions

# register a custom `chpwd` hook
chpwd_functions+=j_chpwd

# make sure our database exists
[ ! -d "$__J_CONFIG_DIR" ] && mkdir -p "$__J_CONFIG_DIR"
[ ! -f "$__J_DB" ] && touch "$__J_DB"
