vim.cmd("packadd nvim-tree.lua")

require("nvim-tree").setup({
  git = {
    enable = true,
  },
  renderer = {
    icons = {
      show = {
        file = false,
        folder = false,
        folder_arrow = true,
        git = true,
      },
      glyphs = {
        folder = {
          arrow_closed = ">",
          arrow_open = "v",
        },
        git = {
          unstaged = "M",
          staged = "S",
          unmerged = "U",
          renamed = "R",
          untracked = "?",
          deleted = "D",
          ignored = "!",
        },
      },
    },
  },
})
