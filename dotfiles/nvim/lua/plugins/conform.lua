return {
    'stevearc/conform.nvim',
    opts = {
        notify_on_error = false,
        format_on_save = function(bufnr)
            local disable_filetypes = { c = true, cpp = true }
            local ft = vim.bo[bufnr].filetype
            if disable_filetypes[ft] then
                return nil
            elseif ft == 'nix' then
                return {
                    timeout_ms = 500,
                    lsp_format = 'never',
                }
            else
                return {
                    timeout_ms = 500,
                    lsp_format = 'fallback',
                }
            end
        end,
        formatters_by_ft = {
            lua = { 'stylua' },
            nix = { 'nixpkgs_fmt' },
            javascript = { 'biome', stop_after_first = true },
            typescript = { 'biome', stop_after_first = true },
            yaml = { 'yamlfmt' },
            c = { 'clang_format' },
            cpp = { 'clang_format' },
        },
        formatters = {
            yamlfmt = {
                args = {
                    '--formatter',
                    'retain_line_breaks_single=true',
                    'trim_trailing_whitespace=true'
                }
            }
        }
    },
}
