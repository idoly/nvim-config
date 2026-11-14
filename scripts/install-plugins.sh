#!/usr/bin/env bash
set -euo pipefail
root="${XDG_DATA_HOME:-$HOME/.local/share}/nvim/site/pack/plugins/start"
mkdir -p "$root"
install_plugin() {
  local owner=$1 name=$2
  if [[ -e "$root/$name" ]]; then
    echo "$name already installed"
    return
  fi
  git clone --depth 1 "https://github.com/$owner/$name.git" "$root/$name"
}
install_plugin nvim-tree nvim-tree.lua
install_plugin nvim-treesitter nvim-treesitter
