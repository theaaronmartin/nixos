-- vim-options.lua
--
-- This file contains general settings for Neovim
vim.opt.guicursor = "n-v-c:block-Cursor,i-r:block-Cursor-blinkon100-blinkoff50"

-- Set shell to PowerShell
vim.opt.shell = "pwsh.exe"
vim.opt.shellcmdflag = "-NoProfile -NonInteractive -Command"

vim.opt.swapfile = false            -- Disable swap files

-- Enable 24-bit RGB colors in the terminal
vim.opt.termguicolors = true

-- Use the system clipboard for all yank/delete/paste operations
vim.opt.clipboard = 'unnamedplus'

-- UI and Editor Behavior
vim.opt.wrap = false              -- Do not wrap lines
vim.wo.number = true              -- Show line numbers in the current window
vim.opt.hlsearch = false          -- Don't highlight all search matches
vim.opt.incsearch = true          -- Show search matches as you type
vim.opt.updatetime = 300          -- Faster updates for plugins (default is 4000ms)

-- Indentation
vim.opt.expandtab = true          -- Use spaces instead of tabs
vim.opt.tabstop = 4               -- A tab character is 4 spaces wide
vim.opt.shiftwidth = 4            -- Indent by 4 spaces
vim.opt.softtabstop = 4           -- Backspace over 4 spaces at a time
vim.opt.smarttab = true           -- Be smart about tabs at the start of a line


-- Configure Neovim's built-in diagnostics
vim.diagnostic.config({
    virtual_text = false,
    virtual_lines = {
        current_line = true
    },
})

-- Legacy Python support for older plugins (optional)
-- Only needed if you have a plugin that requires the 'pynvim' package.
-- vim.g.python3_host_prog = 'C:/Users/Aaron/AppData/Local/Programs/Python/Python313/python.exe'
