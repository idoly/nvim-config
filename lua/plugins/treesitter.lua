-- Scope the Zig compiler selection to Neovim and its child processes.
if vim.fn.executable("zig") == 1 then
  vim.env.CC = vim.fn.stdpath("config") .. "/bin/treesitter-cc"
end

vim.cmd("packadd nvim-treesitter")

-- Only enable highlighting when a parser is already installed. No downloads.
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("UserTreesitterHighlight", { clear = true }),
  callback = function(event)
    pcall(vim.treesitter.start, event.buf)
  end,
})
