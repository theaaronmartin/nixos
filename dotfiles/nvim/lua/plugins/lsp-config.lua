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
                ensure_installed = { 'lua_ls', 'biome', 'yamlls', 'ts_ls', 'omnisharp', 'clangd'  }
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
        },
        config = function()
            local capabilities = require('cmp_nvim_lsp').default_capabilities()
            local lspconfig = require('lspconfig')
            lspconfig.lua_ls.setup({
                capabilities = capabilities
            })
            lspconfig.ts_ls.setup({
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
            lspconfig.omnisharp.setup({
                capabilities = capabilities,
                cmd = { "omnisharp", "--languageserver", "--hostPID", tostring(vim.fn.getpid()) },
            })
            lspconfig.clangd.setup({
                capabilities = capabilities,
                cmd = { "clangd", "--background-index" },
            })
            vim.keymap.set('n', 'K', vim.lsp.buf.hover, {})
            vim.keymap.set('n', 'gd', vim.lsp.buf.definition, {})
            vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, {})
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
