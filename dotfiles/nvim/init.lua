local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)


-- Load your options and keymaps
require('vim-options')
require('keymaps')

local terminal = require("terminal")

vim.keymap.set('n', '<leader>tt', terminal.toggle_floating, {
  noremap = true,
  silent = true,
  desc = 'Toggle floating terminal',
})

vim.keymap.set('n', '<leader>tn', terminal.open_new, {
  noremap = true,
  silent = true,
  desc = 'Open new floating terminal',
})

require("lazy").setup({
  spec = {
    { import = "plugins" },
  },
})

-- Load the theme
vim.cmd("colorscheme functional-purple")
vim.api.nvim_set_hl(0, "Normal", { bg = "none" }) -- Make background transparent
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
