# nvim-config

Neovim 配置，使用原生 package 管理 nvim-tree.lua、nvim-treesitter。

## 环境

Debian 13 x86_64 · Neovim 0.12.6 · Zig 0.17.0 · tree-sitter CLI 0.27.2

依赖：Git、Bash、Python 3、curl、tar、gzip。解析器使用 `zig cc` 编译。

## 安装

```bash
git clone https://github.com/idoly/nvim-config.git ~/.config/nvim
cd ~/.config/nvim

# 已有 Neovim 0.12+ 可跳过此步骤
sudo apt-get install --no-install-recommends curl
bash scripts/install-neovim.sh

bash scripts/install-plugins.sh
```

`install-neovim.sh` 覆盖系统 Neovim，不备份，APT 版本记录不变。

## 配置

```text
init.lua
lua/
├── options.lua
├── keymaps.lua
└── plugins/
    ├── tree.lua
    └── treesitter.lua
bin/treesitter-cc
scripts/
├── install-neovim.sh
└── install-plugins.sh
```

## nvim-tree

- `空格 e`：开关；`空格 f`：定位当前文件。
- 窗口内：`Enter` 打开，`a` 新建，`r` 重命名，`d` 删除，`R` 刷新，`g?` 帮助。

## nvim-treesitter

语法高亮：Java、Zig、HTML、CSS、JS/JSX、TS/TSX、Markdown、XML、JSON。

检查：`:checkhealth nvim-treesitter`；更新解析器：`:TSUpdate`。
