#! /bin/bash

################################################################################
#
# TL; DR
# This script rename filename.flac to
#   <ARTIST> - TITLE.flac
#
# Usage:
#   rename-flac [filename]
#
# Dependencies:
#   - metaflac (Flac)
#   - unaccent
#
################################################################################


SOURCE=$1
new_dir=./FlacRename

while IFS= read -d '' -r ITEM
do
  
  mkdir -p "${new_dir}"
  
  echo "$ITEM"

  ARTIST="$(metaflac --show-tag=ARTIST "$ITEM" | cut -d= -f2 | unaccent utf8)"
  TITLE="$(metaflac --show-tag=TITLE "$ITEM" | cut -d= -f2 | unaccent utf8)"

  new_name="${ARTIST} - ${TITLE}.flac"
    
    echo "" | mv "$ITEM" "${new_dir}/${new_name}"



done< <(find "$SOURCE" \( -iname '*.flac' \) -print0)