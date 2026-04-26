return {
    {
        'MeanderingProgrammer/render-markdown.nvim',
        dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
        ---@module 'render-markdown'
        ---@type render.md.UserConfig
        opts = {
            checkbox = {
                enabled = true,
                unchecked = { char = '󰄱', scope_highlight = '@markup.list.unchecked' },
                checked = { char = '', scope_highlight = '@markup.list.checked' },
            },
            -- This helps prevent the "jitter" when moving the cursor over a line
            anti_conceal = { enabled = true },
        },
    }
}
