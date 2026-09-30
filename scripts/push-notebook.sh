#!/bin/sh
# Copy a notebook to the phone's Livebook folder over SSH, then reopen it in Livebook.
# The phone's SSH has no SFTP, so the file travels base64-encoded inside an Elixir expression.
#
#   scripts/push-notebook.sh priv/samples/13_synth.livemd [host]
set -eu

file=$1
host=${2:-nerves.local}
dest=/data/livebook/notebooks/$(basename "$file")

sum=$(ssh "$host" "File.write!(\"$dest\", Base.decode64!(\"$(base64 < "$file" | tr -d '\n')\")); \
:crypto.hash(:sha256, File.read!(\"$dest\")) |> Base.encode16(case: :lower)" | tr -d '"')

# Compared as strings: macOS shasum and GNU sha256sum format their output differently.
[ "$sum" = "$(shasum -a 256 "$file" | cut -d' ' -f1)" ] || { echo "checksum mismatch: $dest" >&2; exit 1; }
echo "pushed $dest"
