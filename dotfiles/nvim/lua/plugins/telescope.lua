return {
    {
        'nvim-telescope/telescope.nvim',
        tag = '0.1.8',
        dependencies = {
            'nvim-lua/plenary.nvim',
            'nvim-telescope/telescope-ui-select.nvim',
        },
        config = function()
            local telescope = require('telescope')
            local builtin = require('telescope.builtin')

            telescope.setup({
                pickers = {
                    live_grep = {
                        hidden = true,
                        no_ignore = true,
                        file_ignore_patterns = {
                            'node_modules',
                            '%.git\\',
                            '.venv',
                            'test-results',
                            'playwright-report'
                        },
                        additional_args = function()
                            return { "-uu" }
                        end,
                        attach_mappings = function(_, map)
                            map("i", "<C-f>", require('telescope.actions').to_fuzzy_refine)
                            return true
                        end,
                    },
                    find_files = {
                        no_ignore = true,
                        hidden = true,
                        file_ignore_patterns = {
                            "%.git\\",
                            "node_modules",
                            "test-results",
                            "playwright-report",
                            ".venv",
                        },
                    buffers = {
                        sort_mru = true
                    }
                },
                extensions = {
                    ['ui-select'] = {
                        require('telescope.themes').get_dropdown {}
                    }
                }
            }
        })

            telescope.load_extension('ui-select')

            vim.keymap.set('n', '<leader>.', function()
                builtin.find_files({ hidden = true })
            end, { desc = 'Telescope find files' })
            vim.keymap.set('n', '<leader>fg', function()
                builtin.live_grep({ no_ignore = true, hidden = true })
            end, { desc = 'Telescope live grep' })
            vim.keymap.set('n', '<leader>,', function()
                builtin.buffers({ sort_mru = true })
            end, { desc = 'Telescope buffers' })
            vim.keymap.set('n', '<leader>fb', ':Telescope file_browser hidden=true<CR>', {desc = "Telescope File Browser"})
        end
    },
}
