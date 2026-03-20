return {
  'stevearc/conform.nvim',
  opts = {
      notify_on_error = false,
      format_on_save = function(bufnr)
          local disable_filetypes = { c = true, cpp = true }
          if disable_filetypes[vim.bo[bufnr].filetype] then
              return nil
          else
              return {
                  timeout_ms = 500,
                  lsp_format = 'fallback',
              }
          end
      end,
      formatters_by_ft = {
          lua = { 'stylua' },
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
