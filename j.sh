#!/usr/bin/env zsh

__J_CONFIG_DIR="$HOME/.j"
__J_DB="$__J_CONFIG_DIR/db"
__J_DB_TMP="$__J_CONFIG_DIR/db_tmp"

function j() {
  [ -z "$1" ] || [ "$1" = "-h" ] || [ "$1" = "--help" ] && j_show_usage && return

  local match="$(cat "$__J_DB" | fzf --filter "$1" | head -1)"

  # The new database format includes a count prefix.
  if echo "$match" | grep -Eq "^\d+"
  then
    match="$(sed -E 's/^[^ ]+ //' <(<<<$match))"
  fi

  [ -z "$match" ] && j_show_missing && return

  if [ ! -d "$match" ]
  then
    j_remove_entry "$match"

    grep -Eq "^(\d+ )?$(j_escape $match)\$" "$__J_DB" || j "$1" && return
  fi

  cd "$match"
}

function j_chpwd() {
  count="$(grep -E "^\d+ $(pwd)$" "$__J_DB" | awk '{print $1}')"

  if [ -z "$count" ]
  then
    # This is the first time the directory has been visited.
    echo "1 $(pwd)" >> "$__J_DB"
  else
    sed -i '' "s|^$count $(pwd)\$|$(expr $count + 1) $(pwd)|g" "$__J_DB"
  fi

  sort -r -u --version-sort "$__J_DB" > "$__J_DB_TMP"
  cat "$__J_DB_TMP" > "$__J_DB"
}

function j_escape() {
  echo "$(sed 's/[^^]/[&]/g; s/\^/\\^/g' <(<<<$1))"
}

function j_remove_entry() {
  sed -i '' -E "\|^([0-9]+ )?$(j_escape $1)\$|d" "$__J_DB"
}

function j_show_missing() {
  echo "No matching directories found.\n"
}

function j_show_usage() {
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

# Initialize the zsh array for registering `chpwd` hooks.
declare -gaU chpwd_functions

# Register the `chpwd` hook to listen for directory changes.
chpwd_functions+=j_chpwd

# Make sure the database files exist.
[ ! -d "$__J_CONFIG_DIR" ] && mkdir -p "$__J_CONFIG_DIR"
[ ! -f "$__J_DB" ] && touch "$__J_DB"

# Convert existing entries to the new format (include counts).
sed -i '' -E '/^[0-9]+ /! s/^(.*)$/1 \1/g' "$__J_DB"
