# nvim-config

Neovim 配置，使用原生 package 管理插件。

## 系统与依赖

- Debian 13（trixie），Linux x86_64
- Neovim 0.12.6
- Zig 0.17.0，使用 `zig cc` 编译 Treesitter 解析器
- tree-sitter CLI 0.27.2
- Git、Bash、Python 3、curl、tar、gzip

## 目录

```text
~/.config/nvim/
├── init.lua
├── lua/
│   ├── options.lua
│   ├── keymaps.lua
│   └── plugins/
│       ├── tree.lua
│       └── treesitter.lua
├── bin/
│   └── treesitter-cc
└── scripts/
    ├── install-neovim.sh
    ├── install-plugins.sh
    └── install-treesitter.sh
```

## 安装

```bash
git clone https://github.com/idoly/nvim-config.git ~/.config/nvim
cd ~/.config/nvim

# 已有 Neovim 0.12+ 可跳过
sudo apt-get install --no-install-recommends curl
bash scripts/install-neovim.sh

bash scripts/install-plugins.sh
bash scripts/install-treesitter.sh
```

`install-neovim.sh` 安装官方最新稳定版，直接覆盖系统 Neovim，不备份，保留用户配置。APT 的版本记录不会同步更新。

`install-plugins.sh` 安装固定版本的 nvim-tree.lua 和 nvim-treesitter。

`install-treesitter.sh` 使用 Zig，补齐缺少的依赖，安装并验证指定解析器，成功后清理下载文件。不安装 GCC，启动 Neovim 时不自动下载。

## nvim-tree

启用 Git 集成，使用普通字符显示状态，不需要 Nerd Font，其余选项尽量保持默认。

| 快捷键 | 功能 |
| --- | --- |
| `空格 e` | 开关 nvim-tree |
| `空格 f` | 定位当前文件 |
| `Enter` | 打开文件或展开目录 |
| `a` | 新建 |
| `r` | 重命名 |
| `d` | 删除 |
| `R` | 刷新 |
| `g?` | 帮助 |

Git 状态：`M` 未暂存、`S` 已暂存、`U` 冲突、`R` 重命名、`?` 未跟踪、`D` 删除、`!` 忽略。

## nvim-treesitter

仅启用语法高亮。支持 Java、Zig、HTML、CSS、JavaScript/JSX、TypeScript/TSX、Markdown、XML、JSON。

```vim
:checkhealth nvim-treesitter
:TSUpdate
```
