-- Set globals before loading plugins.
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("options")
require("plugins.tree")
require("plugins.treesitter")
require("keymaps")
