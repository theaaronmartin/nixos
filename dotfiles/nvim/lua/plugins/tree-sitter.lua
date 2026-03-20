return {
    {
        'nvim-treesitter/nvim-treesitter',
        branch = 'master',
        lazy = false,
        build = ':TSUpdate',
        config = function()
            ensure_installed = {
                'lua',
                'javascript',
                'typescript',
                'markdown',
                'yaml',
            }
            highlight = {
                enable = true
            }
            indent = {
                enable = true
            }
        end
    }
}
