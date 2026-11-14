#!/usr/bin/env bash
# Linux x86_64: replace system Neovim, without backing up or changing user config.
set -euo pipefail
[[ $(uname -s) == Linux && $(uname -m) == x86_64 ]] || {
  echo 'This installer supports Linux x86_64 only.' >&2; exit 1;
}
command -v curl >/dev/null
command -v python3 >/dev/null
cache="${XDG_CACHE_HOME:-$HOME/.cache}/nvim-config/downloads"
mkdir -p "$cache"
work=$(mktemp -d)
trap 'rm -rf -- "$work"' EXIT
curl -fL --retry 5 --retry-all-errors --connect-timeout 20 --max-time 120 \
  https://api.github.com/repos/neovim/neovim/releases/latest -o "$work/release.json"
mapfile -t release < <(python3 - "$work/release.json" <<'PY'
import json, sys
r = json.load(open(sys.argv[1]))
a = next(a for a in r['assets'] if a['name'] == 'nvim-linux-x86_64.tar.gz')
print(r['tag_name'])
print(a['browser_download_url'])
PY
)
[[ ${#release[@]} == 2 ]]
archive="$cache/nvim-linux-x86_64-${release[0]}.tar.gz"
curl -fL -C - --retry 5 --retry-all-errors --retry-delay 3 \
  --connect-timeout 20 --speed-limit 512 --speed-time 60 --max-time 900 \
  "${release[1]}" -o "$archive"
python3 - "$work/release.json" "$archive" <<'PY'
import hashlib, json, sys
from pathlib import Path
r = json.loads(Path(sys.argv[1]).read_text())
a = next(a for a in r['assets'] if a['name'] == 'nvim-linux-x86_64.tar.gz')
data = Path(sys.argv[2]).read_bytes()
assert len(data) == a['size'], 'Incomplete download'
assert a.get('digest') == 'sha256:' + hashlib.sha256(data).hexdigest(), 'Checksum mismatch'
PY
tar -xzf "$archive" -C "$work"
src="$work/nvim-linux-x86_64"
"$src/bin/nvim" --version
printf '\nWill overwrite /usr/bin/nvim, /usr/share/nvim, /usr/lib/nvim (no backup).\n'
read -r -p 'Continue? [y/N] ' answer
[[ $answer == y || $answer == Y ]] || exit 1
sudo -v
# Stop using Neovim before replacing its runtime files.
sudo rm -rf -- /usr/share/nvim /usr/lib/nvim
sudo cp -a "$src/share/nvim" /usr/share/nvim
sudo cp -a "$src/lib/nvim" /usr/lib/nvim
sudo chown -R root:root /usr/share/nvim /usr/lib/nvim
sudo install -m 755 "$src/bin/nvim" /usr/bin/nvim
sudo install -m 644 "$src/share/man/man1/nvim.1" /usr/share/man/man1/nvim.1
/usr/bin/nvim --headless -u NONE '+lua assert(vim.fn.isdirectory(vim.env.VIMRUNTIME) == 1); print(vim.env.VIMRUNTIME)' +qa
/usr/bin/nvim --version
rm -f -- "$archive"
printf '\nSystem Neovim updated. User configuration unchanged.\n'
