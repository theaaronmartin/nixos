return {
  'nvim-lualine/lualine.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  config = function()
    -- Define the color palette for the theme
    local colors = {
      bg          = '#1d1727',
      fg          = '#ffffff',
      purple      = '#b36ae2',
      dark_purple = '#43355a',
      pink        = '#Eb345C',
      grey        = '#5f4c80',
      black       = '#000000'
    }

    -- Define the Lualine theme table
    local functional_purple_theme = {
      normal = {
        a = { fg = colors.black, bg = colors.purple, gui = 'bold' },
        b = { fg = colors.fg, bg = colors.dark_purple },
        c = { fg = colors.fg, bg = colors.bg }
      },
      insert = {
        a = { fg = colors.black, bg = colors.pink, gui = 'bold' },
        b = { fg = colors.fg, bg = colors.dark_purple }
      },
      visual = {
        a = { fg = colors.black, bg = colors.fg, gui = 'bold' },
        b = { fg = colors.purple, bg = colors.dark_purple }
      },
      replace = {
        a = { fg = colors.black, bg = colors.pink, gui = 'bold' }
      },
      command = {
        a = { fg = colors.black, bg = colors.fg, gui = 'bold' }
      },
      inactive = {
        a = { fg = colors.fg, bg = colors.bg, gui = 'bold' },
        b = { fg = colors.grey, bg = colors.bg },
        c = { fg = colors.grey, bg = colors.bg }
      }
    }

    -- Lualine setup
    require('lualine').setup({
      options = {
        -- Replace 'auto' with the theme table you defined above
        theme = functional_purple_theme,
        component_separators = { left = '', right = ''},
        section_separators = { left = '', right = ''},
      },
      sections = {
        lualine_a = {'mode'},
        lualine_b = {'branch', 'diff', 'diagnostics'},
        lualine_c = {'filename'},
        lualine_x = {'encoding', 'fileformat', 'filetype'},
        lualine_y = {'progress'},
        lualine_z = {'location'}
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {'filename'},
        lualine_x = {'location'},
        lualine_y = {},
        lualine_z = {}
      },
    })
  end
}
