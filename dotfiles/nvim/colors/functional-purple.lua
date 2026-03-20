-- Set the theme name
vim.g.colors_name = "functional-purple"

-- Define the color palette from the JSON file
local c = {
  bg = "#1d1727",
  fg = "#ffffff",
  alt_bg = "#181321",
  selection = "#Eb345C",
  line_highlight = "#261f34",
  comment = "#5f4c80",
  purple = "#b36ae2",
  pink = "#Eb345C",
  red = "#F07171",
  orange = "#EF7C2A",
  blue = "#9287EB",
  green = "#89EB9A",
  grey = "#a6a6a6",
  yellow = "#D8FF00",
  cursor_grey = "#4d3d67",
  gutter_fg = "#9886b7",
  border = "#302641",
}

-- Define a function to set the highlight groups
local function set_highlights()
  -- Helper function to set highlights
  local function s(group, styles)
    vim.api.nvim_set_hl(0, group, styles)
  end

  -- EDITOR
  s("Normal", { fg = c.fg, bg = c.bg })
  s("NormalFloat", { bg = c.alt_bg })
  s("SignColumn", { bg = c.bg })
  s("MsgArea", { fg = c.fg, bg = c.bg })
  s("ModeMsg", { fg = c.fg, bold = true })
  s("Visual", { bg = c.yellow, fg = c.bg })
  s("VisualNOS", { bg = c.yellow, fg = c.bg })
  s("CursorLine", { bg = c.line_highlight })
  s("CursorLineNr", { fg = c.gutter_fg, bg = c.line_highlight })
  s("LineNr", { fg = c.cursor_grey, bg = c.bg })
  s("Pmenu", { fg = c.fg, bg = c.alt_bg })
  s("PmenuSel", { fg = c.bg, bg = c.purple, bold = true })
  s("PmenuThumb", { bg = c.comment })
  s("PmenuSbar", { bg = c.line_highlight })
  s("WildMenu", { fg = c.bg, bg = c.purple })
  s("VertSplit", { fg = c.border, bg = c.bg })
  s("Folded", { fg = c.comment, bg = c.line_highlight })
  s("Title", { fg = c.purple, bold = true })
  s("TabLine", { fg = c.comment, bg = c.alt_bg })
  s("TabLineFill", { bg = c.alt_bg })
  s("TabLineSel", { fg = c.pink, bg = c.bg, bold = true })
  s("Directory", { fg = c.purple })
  s("Cursor", { bg = c.yellow, fg = c.yellow })

  -- SYNTAX
  s("Comment", { fg = c.comment, italic = true })
  s("String", { fg = c.pink })
  s("Character", { fg = c.pink })
  s("Number", { fg = c.purple })
  s("Boolean", { fg = c.purple })
  s("Float", { fg = c.purple })
  s("Keyword", { fg = c.purple, italic = true })
  s("Operator", { fg = c.purple })
  s("Conditional", { fg = c.purple })
  s("Repeat", { fg = c.purple })
  s("Label", { fg = c.purple })
  s("Statement", { fg = c.purple })
  s("Function", { fg = c.purple })
  s("Method", { fg = c.green })
  s("Identifier", { fg = c.fg })
  s("Constant", { fg = c.purple })
  s("Type", { fg = c.purple })
  s("PreProc", { fg = c.purple })
  s("Special", { fg = c.purple })
  s("Delimiter", { fg = c.grey })
  s("Punctuation", { fg = c.grey })
  s("Error", { fg = c.red, bg = c.bg, bold = true })
  s("Todo", { fg = c.bg, bg = c.orange, bold = true })
  s("@parameter", { fg = c.pink })
  s("@property", { fg = c.pink, italic = true })

  -- GIT
  s("DiffAdd", { fg = c.green, bg = "#78BD65" })
  s("DiffChange", { fg = c.orange, bg = "#EB4D5C" })
  s("DiffDelete", { fg = c.red, bg = "#F07171" })
  s("DiffText", { fg = c.bg, bg = c.blue })

  -- LSP DIAGNOSTICS
  s("DiagnosticError", { fg = c.red })
  s("DiagnosticWarn", { fg = c.orange })
  s("DiagnosticInfo", { fg = c.blue })
  s("DiagnosticHint", { fg = c.green })

  -- NEO-TREE
  s("NeoTreeNormal", { fg = c.fg, bg = c.alt_bg })
  s("NeoTreeNormalNC", { fg = c.fg, bg = c.alt_bg })
  s("NeoTreeRootName", { fg = c.pink, bold = true })
  s("NeoTreeGitModified", { fg = c.pink })
  s("NeoTreeGitAdded", { fg = c.green })
  s("NeoTreeGitDeleted", { fg = c.red })
  s("NeoTreeFileName", { fg = c.fg })

  -- LSP SEMANTIC HIGHLIGHTS
  s("@lsp.type.namespace", { fg = c.fg })
  s("@lsp.type.struct", { fg = c.purple })
  s("@lsp.type.class", { fg = c.purple })
  s("@lsp.type.interface", { fg = c.grey })
  s("@lsp.type.parameter", { fg = c.pink })
  s("@lsp.type.variable", { fg = c.fg })
  s("@lsp.type.property", { fg = c.blue, italic = true })
  -- For variables that are properties of `self` or `this`
  s("@lsp.mod.self", { fg = c.blue })
  s("@function.call", { fg = c.purple })
  s("@lsp.type.method", { fg = c.purple })
end

-- Apply the highlights
set_highlights()
