#!/usr/bin/env bash
set -euo pipefail
# Pin plugin source revisions. Re-running does not reset local changes.
root="${XDG_DATA_HOME:-$HOME/.local/share}/nvim/site/pack/plugins/start"
mkdir -p "$root"
install_plugin() {
  local name=$1 revision=$2
  if [[ -e "$root/$name" ]]; then
    [[ $(git -C "$root/$name" rev-parse HEAD) == "$revision" ]] || {
      echo "$root/$name differs from pinned revision; refusing to overwrite." >&2
      return 1
    }
    echo "$name already installed"
    return
  fi
  git init "$root/$name"
  git -C "$root/$name" remote add origin "https://github.com/$3/$name.git"
  git -C "$root/$name" fetch --depth 1 origin "$revision"
  git -C "$root/$name" checkout --detach FETCH_HEAD
}
install_plugin nvim-tree.lua 5cc8d425c2bf3c09041a2db3cfff6197e2dce34d nvim-tree
install_plugin nvim-treesitter 04f17886f75416dfdc25374c950a52c63f0e98fe nvim-treesitter
