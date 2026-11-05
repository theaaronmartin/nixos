-- nvim-treesitter `main` branch. The old `master` branch is archived and breaks
-- on Neovim 0.12: its query directives expect one node per capture, 0.12 passes
-- a list, and markdown code-fence injections crashed render-markdown.
--
-- `main` only installs parsers and queries; highlighting and indentation are
-- switched on per buffer below. Building parsers needs the tree-sitter CLI,
-- which modules/hm-dev.nix puts on Neovim's PATH (programs.neovim.extraPackages).
local parsers = {
    'gleam',
    'javascript',
    'lua',
    'markdown',
    'markdown_inline', -- render-markdown needs it alongside markdown
    'typescript',
    'yaml',
}

return {
    {
        'nvim-treesitter/nvim-treesitter',
        branch = 'main',
        lazy = false, -- main does not support lazy-loading
        build = ':TSUpdate',
        config = function()
            require('nvim-treesitter').install(parsers) -- no-op once installed

            vim.api.nvim_create_autocmd('FileType', {
                group = vim.api.nvim_create_augroup('user-treesitter', { clear = true }),
                callback = function(args)
                    -- Same scope as master's `highlight.enable`: every filetype
                    -- that has a parser. Filetypes without one fail quietly here.
                    if not pcall(vim.treesitter.start, args.buf) then
                        return
                    end
                    -- Same scope as master's `indent.enable`: only languages
                    -- that ship an indents query.
                    local lang = vim.treesitter.language.get_lang(args.match)
                    if lang and vim.treesitter.query.get(lang, 'indents') then
                        vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                    end
                end,
            })
        end,
    },
}
