return {
    'nvim-neo-tree/neo-tree.nvim',
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    config = function()
	vim.keymap.set('n', '<leader><leader>', ':Neotree float toggle<CR>', {})
        require('neo-tree').setup({
            filesystem = {
                filtered_items = {
                    visible = false,
                    hide_dotfiles = false,
                    hide_gitignored = false,
                    hide_hidden = false,
                    hide_by_name = {
                        "node_modules"
                    },
                    always_show = {
                        ".gitignored",
                    },
                    always_show_by_pattern = {
                        ".env*",
                    },
                },
            },
        })
    end
}
