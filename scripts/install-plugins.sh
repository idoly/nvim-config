#!/usr/bin/env bash
# Explicit one-time setup. Neovim startup never invokes this script.
set -euo pipefail
config=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
cache="${XDG_CACHE_HOME:-$HOME/.cache}/nvim-config"
[[ $(uname -s) == Linux && $(uname -m) == x86_64 ]] || {
  echo 'This installer supports Linux x86_64 only.' >&2; exit 1;
}
command -v zig >/dev/null || { echo 'zig is required' >&2; exit 1; }
command -v nvim >/dev/null
command -v python3 >/dev/null
command -v git >/dev/null
chmod +x "$config/bin/treesitter-cc"
export CC="$config/bin/treesitter-cc"
work=$(mktemp -d)
trap 'rm -rf -- "$work"' EXIT

# Verify the existing compiler before installing anything.
printf 'int test(void) { return 42; }\n' > "$work/test.c"
"$CC" -shared -fPIC "$work/test.c" -o "$work/test.so"
python3 - "$work/test.so" <<'PY'
import ctypes, sys
assert ctypes.CDLL(sys.argv[1]).test() == 42
PY

# No GCC, libc6-dev, build-essential, C++, or Make needed with Zig.
if ! command -v curl >/dev/null; then
  sudo apt-get install --no-install-recommends -y curl
fi

if ! command -v tree-sitter >/dev/null || ! python3 - <<'PY'
import re, subprocess, sys
version = subprocess.check_output(['tree-sitter', '--version'], text=True)
match = re.search(r'(\d+)\.(\d+)\.(\d+)', version)
sys.exit(0 if match and tuple(map(int, match.groups())) >= (0, 26, 1) else 1)
PY
then
  mkdir -p "$cache/downloads"
  archive="$cache/downloads/tree-sitter-linux-x64-v0.27.2.gz"
  curl -fL --retry 5 --retry-all-errors --connect-timeout 20 --max-time 120 \
    https://api.github.com/repos/tree-sitter/tree-sitter/releases/tags/v0.27.2 \
    -o "$work/release.json"
  # Preserve partial downloads if the connection drops or this script exits.
  curl -fL -C - --retry 5 --retry-all-errors --retry-delay 3 \
    --connect-timeout 20 --speed-limit 512 --speed-time 60 --max-time 900 \
    https://github.com/tree-sitter/tree-sitter/releases/download/v0.27.2/tree-sitter-linux-x64.gz \
    -o "$archive"
  python3 - "$work" "$archive" <<'PY'
import hashlib, json, sys
from pathlib import Path
work = Path(sys.argv[1])
release = json.loads((work / 'release.json').read_text())
asset = next(a for a in release['assets'] if a['name'] == 'tree-sitter-linux-x64.gz')
data = Path(sys.argv[2]).read_bytes()
assert len(data) == asset['size'], 'Incomplete download'
assert asset.get('digest') == 'sha256:' + hashlib.sha256(data).hexdigest(), 'Checksum mismatch'
PY
  gzip -dc "$archive" > "$work/tree-sitter"
  sudo install -m 755 "$work/tree-sitter" /usr/local/bin/tree-sitter
fi

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

cat > "$work/parsers.lua" <<'LUA'
local languages = {
  "java", "zig", "html", "css", "javascript", "typescript", "tsx",
  "markdown", "markdown_inline", "xml", "json",
}
local ok, err = pcall(function()
  for attempt = 1, 3 do
    local missing = {}
    for _, lang in ipairs(languages) do
      local loaded, available = pcall(vim.treesitter.language.add, lang)
      if not loaded or not available then
        table.insert(missing, lang)
      end
    end
    if #missing == 0 then break end
    print("Parser installation attempt " .. attempt .. "/3")
    require("nvim-treesitter").install(missing, { max_jobs = 2 }):wait(1200000)
  end
  for _, lang in ipairs(languages) do
    assert(vim.treesitter.language.add(lang), "Missing parser: " .. lang)
    assert(vim.treesitter.query.get(lang, "highlights"), "Missing highlights: " .. lang)
  end
end)
if not ok then
  vim.api.nvim_err_writeln(tostring(err))
  vim.cmd("cquit 1")
else
  print("All requested parsers verified")
  vim.cmd("qa")
end
LUA
nvim --headless -u "$config/init.lua" -l "$work/parsers.lua"

# Only remove this installer's download, not unrelated caches or system packages.
rm -f -- "$cache/downloads/tree-sitter-linux-x64-v0.27.2.gz"
printf '\nDone: plugins installed, parsers verified, download cleaned.\n'
