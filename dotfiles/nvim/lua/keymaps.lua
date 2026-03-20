vim.g.mapleader = ' '

vim.keymap.set('i', '<C-v>', '<C-r>+', { desc = "Paste from system clipboard" })

vim.keymap.set('n', '<leader>fs', ':w<CR>', { desc = '[f]ile [s]ave' })
vim.keymap.set('n', '<leader>ps', ':wa<CR>', { desc = '[p]roject [s]ave (all buffers)' })
vim.keymap.set('n', '<leader>q', ':q<CR>', { desc = '[q]uit' })
vim.keymap.set('n', '<leader>pwq', ':wqa!<CR>', { desc = '[p]roject [q]uit with saving' })
vim.keymap.set('n', '<leader>pqq', ':qa!<CR>', { desc = '[p]roject [q]uit without saving' })
vim.keymap.set('n', '<leader>bn', ':enew<CR>', { desc = '[b]uffer [n]ew' })
vim.keymap.set('n', '<leader>bd', ':bnext | bdelete #<CR>', { desc = '[b]uffer [d]elete' })
vim.keymap.set('n', '<leader>bad', ':%bd|e#|bd#<CR>', { desc = '[b]uffer [a]ll [d]elete' })

vim.keymap.set('v', '<M-Down>', ":m '>+1<CR>gv=gv", { desc = 'Move selected text down' })
vim.keymap.set('v', '<M-Up>', ":m '<-2<CR>gv=gv", { desc = 'Move selected text up' })

vim.keymap.set('n', '<C-d>', '<C-d>zz', { desc = 'Scroll down and center' })
vim.keymap.set('n', '<C-u>', '<C-u>zz', { desc = 'Scroll up and center' })
vim.keymap.set('n', 'n', 'nzzzv', { desc = 'Search next and center' })
vim.keymap.set('n', 'N', 'Nzzzv', { desc = 'Search previous and center' })

vim.keymap.set('x', '<leader>p', '\'_dP', { desc = '[p]aste over selection' })

vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc = "Search and replace word under cursor" })
