return {
    'nvimdev/dashboard-nvim',
    event = 'VimEnter',
    config = function()
        require('dashboard').setup {
            theme = 'doom',
            config = {
                header = {
'',
' ███▄    █    ▓█████     ▒█████      ██▒   █▓    ██▓    ███▄ ▄███▓',
' ██ ▀█   █    ▓█   ▀    ▒██▒  ██▒   ▓██░   █▒   ▓██▒   ▓██▒▀█▀ ██▒',
'▓██  ▀█ ██▒   ▒███      ▒██░  ██▒    ▓██  █▒░   ▒██▒   ▓██    ▓██░',
'▓██▒  ▐▌██▒   ▒▓█  ▄    ▒██   ██░     ▒██ █░░   ░██░   ▒██    ▒██ ',
'▒██░   ▓██░   ░▒████▒   ░ ████▓▒░      ▒▀█░     ░██░   ▒██▒   ░██▒',
'░ ▒░   ▒ ▒    ░░ ▒░ ░   ░ ▒░▒░▒░       ░ ▐░     ░▓     ░ ▒░   ░  ░',
'░ ░░   ░ ▒░    ░ ░  ░     ░ ▒ ▒░       ░ ░░      ▒ ░   ░  ░      ░',
'   ░   ░ ░       ░      ░ ░ ░ ▒          ░░      ▒ ░   ░      ░   ',
'         ░       ░  ░       ░ ░           ░      ░            ░   ',
'                                         ░                        ',
''
                },
                center = {
                  {
                    icon = ' ',
                    icon_hl = 'Title',
                    desc = 'New File',
                    desc_hl = 'String',
                    key = 'b N',
                    keymap = 'SPC',
                    key_hl = 'Number',
                    key_format = ' %s', -- remove default surrounding `[]`
                    action = 'lua print(1)'
                  },
                  {
                    icon = '󰈞 ',
                    icon_hl = 'Title',
                    desc = 'Find File',
                    desc_hl = 'String',
                    key = 'SPC',
                    keymap = 'SPC',
                    key_hl = 'Number',
                    key_format = ' %s', -- remove default surrounding `[]`
                    action = 'lua print(2)'
                  },
                  {
                    icon = ' ',
                    desc = 'Open Project',
                    key = 'f p',
                    keymap = 'SPC',
                    key_format = ' %s', -- remove default surrounding `[]`
                    action = 'lua print(3)'
                  },
                },
                footer = {
                    '',
                    'Loaded ' .. require("lazy").stats().loaded .. ' / ' .. require("lazy").stats().count .. ' plugins',
                    ''
                }
              }
        }
    end,
    dependencies = { {'nvim-tree/nvim-web-devicons'}}
}
