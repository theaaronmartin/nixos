-- return {
--     {
--         "gokhangeyik/notesidian.nvim",
--         lazy = true,
--         dependencies = {
--             "MeanderingProgrammer/render-markdown.nvim",
--         },
--         opts = {
--             notes_root = "~/Notes/",
--             daily_notes_path = "Dailies/",
--             template_path = "Templates/",
--             date_format = "%Y-%m-%d",
--             todo_list_prefix = "Personal",
--             todo_template = "TodoList.md",
--             note_template = "Note.md",
--             snacks_picker = false,
--             win_style = "float",
--             vim.keymap.set('n', '<leader>nd', function() require('notesidian').create_daily_note() end, { desc = 'Create or edit daily note (Today)' }),
--             vim.keymap.set('n', '<leader>ny', function() require('notesidian').create_daily_note(-1) end, { desc = 'Create or edit daily note (Yesterday)' }),
--             vim.keymap.set('n', '<leader>nt', function() require('notesidian').create_daily_note(1) end, { desc = 'Create or edit daily note (Tomorrow)' }),
--             vim.keymap.set('n', '<leader>nl', function() require('notesidian').create_todo_list() end, { desc = 'Create or edit Todo List' }),
--             vim.keymap.set('n', '<leader>nc', function() require('notesidian').toggle_checkbox() end, { desc = 'Toggle Checkbox' }),
--             vim.keymap.set('n', '<leader>nf', function() require('notesidian').find_notes() end, { desc = 'Search Notes' })
--         },
--     }
-- }

vim.api.nvim_create_autocmd("FileType", {
    pattern = "markdown",
    callback = function()
        vim.opt_local.conceallevel = 2
    end,
})

return {
    "epwalsh/obsidian.nvim",
    version = "*", -- use latest release instead of latest commit
    lazy = true,
    ft = "markdown",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-telescope/telescope.nvim", -- For searching
        "nvim-treesitter/nvim-treesitter",
    },
    opts = {
        workspaces = {
            {
                name = "vault",
                path = "~/notes", -- Match your Git clone path
            },
        },
        -- Settings for GrapheneOS/GitJournal compatibility
        notes_subdir = "inbox",
        new_notes_location = "notes_subdir",

        -- Ensure Neovim generates IDs that GitJournal likes (human-readable)
        note_id_func = function(title)
            if title ~= nil then
                return title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
            else
                return tostring(os.time())
            end
        end,

        -- Preferred frontmatter for Obsidian/GitJournal overlap
        disable_frontmatter = false,
        templates = {
            subdir = "templates",
            date_format = "%Y-%m-%d",
            time_format = "%H:%M",
        },
        ui = {
            enable = false,        -- set to false to disable all UI features and the warning
            update_debounce = 200, -- update delay (milliseconds)
            -- This is the magic part:
            checkboxes = {
                [" "] = { char = "󰄱", hl_group = "ObsidianTodo" },
                ["x"] = { char = "", hl_group = "ObsidianDone" },
            },
        },
    },
}
