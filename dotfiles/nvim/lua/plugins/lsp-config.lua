return {
    {
        'williamboman/mason.nvim',
            config = function()
                require('mason').setup()
            end
    },
    {
        'williamboman/mason-lspconfig.nvim',
        config = function()
            require('mason-lspconfig').setup({
                ensure_installed = { }
            })
        end
    },
    {
        'neovim/nvim-lspconfig',
        commit = 'dbdb80d',
        dependencies = {
            {
                "folke/lazydev.nvim",
                ft = "lua",
                opts = {
                  library = {
                    { path = "${3rd}/luv/library", words = { "vim%.uv" } },
                  },
                },
            },
            'hrsh7th/cmp-nvim-lsp',
        },
        config = function()
            local capabilities = require('cmp_nvim_lsp').default_capabilities()
            local lspconfig = require('lspconfig')

            -- Debug: Print available LSP servers
            vim.notify("Setting up LSP servers...", vim.log.levels.INFO)

            lspconfig.lua_ls.setup({
                capabilities = capabilities
            })
            lspconfig.tsserver.setup({
                capabilities = function()
                    local caps = vim.deepcopy(capabilities)
                    caps.textDocument.codeActionProvider = false
                    caps.textDocument.codeAction = {
                        dynamicRegistration = false
                    }
                    return caps
                end
            })
            lspconfig.biome.setup({
                capabilities = capabilities
            })
            lspconfig.yamlls.setup({
                capabilities = capabilities
            })
            lspconfig.clangd.setup({
                capabilities = capabilities,
                cmd = { "clangd", "--background-index" },
            })

            -- Add nil (Nix LSP) if available
            pcall(function()
                lspconfig.nil_ls.setup({
                    capabilities = capabilities
                })
            end)

            vim.keymap.set('n', 'K', vim.lsp.buf.hover, {})
            vim.keymap.set('n', 'gd', vim.lsp.buf.definition, {})
            vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, {})
            vim.keymap.set('n', '<leader>ld', ':LspDebug<CR>', { desc = '[L]SP [D]ebug' })

            -- Debug command to check LSP status
            vim.api.nvim_create_user_command('LspDebug', function()
                local clients = vim.lsp.get_active_clients()
                if #clients == 0 then
                    print("No active LSP clients")
                else
                    print("Active LSP clients:")
                    for _, client in ipairs(clients) do
                        print("  - " .. client.name)
                    end
                end
            end, {})
        end
    },
    {
        "antosha417/nvim-lsp-file-operations",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "stevearc/oil.nvim",
            "nvim-neo-tree/neo-tree.nvim",
        },
        config = function()
            require("lsp-file-operations").setup({
                debug = false,
            })
        end,
    },
}
