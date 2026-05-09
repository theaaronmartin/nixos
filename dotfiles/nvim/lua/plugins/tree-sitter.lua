return {
    {
        'nvim-treesitter/nvim-treesitter',
        branch = 'master',
        lazy = false,
        build = ':TSUpdate',
        config = function()
            require('nvim-treesitter.configs').setup({
                ensure_installed = {
                    'gleam',
                    'lua',
                    'javascript',
                    'typescript',
                    'markdown',
                    'yaml',
                },
                highlight = {
                    enable = true,
                },
                indent = {
                    enable = true,
                },
            })
        end
    }
}
