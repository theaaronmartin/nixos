return {
    {
        "gokhangeyik/notesidian.nvim",
        lazy = true,
        dependencies = {
            "MeanderingProgrammer/render-markdown.nvim",
        },
        opts = {
            notes_root = "~/Notes/",
            daily_notes_path = "Dailies/",
            template_path = "Templates/",
            date_format = "%Y-%m-%d",
            todo_list_prefix = "Personal",
            todo_template = "TodoList.md",
            note_template = "Note.md",
            snacks_picker = false,
            win_style = "float",
            vim.keymap.set('n', '<leader>nd', function() require('notesidian').create_daily_note() end, { desc = 'Create or edit daily note (Today)' }),
            vim.keymap.set('n', '<leader>ny', function() require('notesidian').create_daily_note(-1) end, { desc = 'Create or edit daily note (Yesterday)' }),
            vim.keymap.set('n', '<leader>nt', function() require('notesidian').create_daily_note(1) end, { desc = 'Create or edit daily note (Tomorrow)' }),
            vim.keymap.set('n', '<leader>nl', function() require('notesidian').create_todo_list() end, { desc = 'Create or edit Todo List' }),
            vim.keymap.set('n', '<leader>nc', function() require('notesidian').toggle_checkbox() end, { desc = 'Toggle Checkbox' }),
            vim.keymap.set('n', '<leader>nf', function() require('notesidian').find_notes() end, { desc = 'Search Notes' })
        },
    }
}
