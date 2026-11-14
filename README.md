# nvim-config

轻量、模块化的 Neovim 配置，使用原生 package 管理，仅包含文件树与 Treesitter。无插件管理器、无 Nerd Font 要求，启动时不下载依赖或解析器。

## 环境

- Neovim **0.12+**；当前验证版本：0.12.6。
- Linux x86_64（安装脚本当前支持的平台），Bash、Git、Python 3、tar、gzip。
- Zig 已安装且在 PATH 中；当前验证版本：0.17.0。
- Treesitter 需要 curl、tree-sitter CLI ≥ 0.26.1；脚本仅在缺少时补装，CLI 下载版本为 0.27.2。
- 系统安装步骤需要 sudo；curl 缺失时使用 Debian/Ubuntu 的 apt-get。

## 目录

```text
~/.config/nvim/
├── init.lua                     # 入口、leader、禁用 netrw
├── lua/
│   ├── options.lua              # 编辑器选项
│   ├── keymaps.lua              # 全局快捷键
│   └── plugins/
│       ├── tree.lua             # 文件树唯一的 setup() 调用
│       └── treesitter.lua       # Zig 编译器环境与已安装解析器高亮
├── bin/
│   └── treesitter-cc            # Zig C 编译包装器，适配 Rust 风格 target
└── scripts/
    ├── install-neovim.sh         # 可选：直接覆盖系统 Neovim，不备份
    ├── install-plugins.sh        # 安装固定版本插件源码
    └── install-treesitter.sh     # 最小依赖、指定解析器、验证与缓存清理
```

配置与脚本提交到 Git。插件、解析器、构建缓存不提交：

- 插件：`${XDG_DATA_HOME:-~/.local/share}/nvim/site/pack/plugins/start/`
- 解析器及 queries：Neovim 默认 data/site 目录。
- 本项目安装下载缓存：`${XDG_CACHE_HOME:-~/.cache}/nvim-config/`
- Treesitter 构建源码缓存由插件管理，安装脚本不清理无关数据。

## 安装

以下假定使用默认配置目录；已有配置请先自行迁移，勿直接覆盖。

```bash
git clone https://github.com/idoly/nvim-config.git ~/.config/nvim
cd ~/.config/nvim
```

### 1. Neovim（已有 0.12+ 可跳过）

先确保 curl 可用：

```bash
sudo apt-get install --no-install-recommends curl
bash scripts/install-neovim.sh
```

脚本获取官方最新稳定版，支持断点续传、网络错误重试和 SHA256 校验。
确认后直接替换 `/usr/bin/nvim`、`/usr/share/nvim`、`/usr/lib/nvim` 及 man page，**不备份**，不安装到 `/opt` 或用户 bin，保留用户配置。

**警告：这是手动覆盖，不更新 APT 版本记录；APT 后续更新/重装可能覆盖它。执行前关闭 Neovim，不在不熟悉的系统上盲目运行。**

### 2. 插件源码

```bash
bash scripts/install-plugins.sh
```

仅安装 nvim-tree.lua 和 nvim-treesitter，固定提交版本保证可复现。重复执行会跳过相同版本，不会重置已有的不同版本或本地修改。不需要 nvim-web-devicons。

若下载中断导致不完整的插件目录，请检查后删除该目录，再重新执行。脚本不会擅自删除已有目录。

### 3. Treesitter 依赖和语言

确保 Zig 已在 PATH，然后执行：

```bash
bash scripts/install-treesitter.sh
```

此步骤：

1. 用 `zig cc` 实际编译并加载测试共享库。
2. 缺少 curl 时，仅安装 curl 及必需运行库；不安装 GCC、libc6-dev、build-essential、C++、Make 或 LLVM。
3. 检查 tree-sitter CLI 版本；必要时下载官方 Linux x86_64 二进制并校验 SHA256，安装到 `/usr/local/bin/tree-sitter`。
4. 补齐以下解析器，最多 2 个并发，最多 3 轮重试：
   `java zig html css javascript typescript tsx markdown markdown_inline xml json`。
5. 验证解析器和高亮 queries；仅成功后删除本脚本下载的压缩包。失败保留 CLI 下载进度，修复网络后重跑即可。

JSX 由 JavaScript 及相关 queries 支持；插件可能自动补装必需依赖，如 XML 的 `dtd`、`ecma` / `jsx` / `html_tags` queries，这不是安装所有语言。

已可用的解析器会跳过（包括 Neovim 自带解析器），本脚本不是强制更新命令。不自动卸载系统包、不运行 apt autoremove。

**正常启动 Neovim 不执行任何安装。** 后续确实需要新语言时可手动 `:TSInstall <语言>`。

## 使用

在项目目录运行 `nvim`。

| 快捷键 | 功能 |
| --- | --- |
| `空格 e` | 开关文件树 |
| `空格 f` | 在文件树中定位当前文件 |
| `Ctrl+w h` / `Ctrl+w l` | 切换左右窗口 |

文件树内：`Enter` 打开文件/展开目录，`a` 新建（以 `/` 结尾创建目录），`r` 重命名，`d` 删除，`R` 刷新，`g?` 查看帮助。

文件树只定制 Git 状态和 ASCII 图标，其余尽量使用默认值；不依赖 Nerd Font。目录箭头为 `>` / `v`：

| 标记 | Git 状态 |
| --- | --- |
| M | 未暂存修改 |
| S | 已暂存变更 |
| U | 合并冲突 |
| R | 重命名 |
| ? | 未跟踪 |
| D | 删除 |
| ! | 被忽略（文件树按大写 `I` 切换显示） |

Git 标记需要当前目录在 Git 仓库内。无需额外 Git 插件。

编辑器启用行号、真彩色、智能大小写搜索和两空格缩进。Treesitter 只开启已安装解析器的高亮，不额外配置折叠、缩进或结构化选择。

## 验证与维护

```bash
for script in scripts/*.sh bin/treesitter-cc; do bash -n "$script" || break; done
nvim --headless '+lua assert(vim.fn.exists(":NvimTreeToggle") == 2); assert(vim.fn.exists(":TSInstall") == 2); print("config OK")' +qa
```

在 Neovim 中用 `:checkhealth nvim-treesitter` 检查环境；有需要时手动 `:TSUpdate` 更新解析器。更新插件时应同时审阅兼容性、更新固定提交，并按需运行 `:TSUpdate`。

`bin/treesitter-cc` 将 `x86_64-unknown-linux-gnu` 等 Rust 风格目标名转换为 Zig 接受的 `x86_64-linux-gnu`。编译器选择仅作用于 Neovim 及其子进程，不修改全局 CC。

GitHub 若出现 SSL EOF，一般是网络中断，不要禁用证书校验；安装脚本支持重试和 CLI 断点续传，解析器安装失败可重跑。只有看到 `All requested parsers verified` 和最后完成提示，才表示整套安装成功。
