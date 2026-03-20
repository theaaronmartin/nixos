return {
    {
        'mfussenegger/nvim-lint',
        event = { 'BufReadPre', 'BufNewFile' },
        config = function()
            local lint = require 'lint'
            lint.linters_by_ft = {
                markdown = { 'vale' },
                json = { 'biome' },
                javascript = { 'biome' },
                typescript = { 'biome' },
                yaml = { 'yamllint' },
                c = { 'cpplint' },
                cpp = { 'cpplint' }
            }
        end,
    },
}
