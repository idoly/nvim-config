vim.cmd("packadd nvim-tree.lua")

require("nvim-tree").setup({
  git = {
    enable = false,
  },
  renderer = {
    icons = {
      show = {
        file = false,
        folder = false,
        folder_arrow = true,
        git = false,
      },
      glyphs = {
        folder = {
          arrow_closed = ">",
          arrow_open = "v",
        },

      },
    },
  },
})
