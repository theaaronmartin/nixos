local M = {}

local term_buf_nr = nil

local function get_window_opts()
  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.8)

  return {
    style = 'minimal',
    relative = 'editor',
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    border = 'double',
  }
end

local function find_toggle_win()
  if term_buf_nr and vim.api.nvim_buf_is_valid(term_buf_nr) then
    local wins = vim.api.nvim_list_wins()
    for _, win_id in ipairs(wins) do
      if vim.api.nvim_win_get_buf(win_id) == term_buf_nr then
        return win_id
      end
    end
  end
  return nil
end

function M.open_new()
  local opts = get_window_opts()
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_open_win(buf, true, opts)

  vim.cmd('terminal')
  vim.cmd('startinsert')

  vim.keymap.set('t', '<Esc>', [[<C-\><C-n>]], { buffer = buf, silent = true })
  vim.keymap.set('t', '<C-q>', [[<C-\><C-n><cmd>close!<CR>]], { buffer = buf, silent = true })
end

function M.toggle_floating()
  local existing_win_id = find_toggle_win()

  if existing_win_id then
    vim.api.nvim_win_close(existing_win_id, false)
  elseif term_buf_nr and vim.api.nvim_buf_is_valid(term_buf_nr) then
    local opts = get_window_opts()
    vim.api.nvim_open_win(term_buf_nr, true, opts)
    vim.cmd('startinsert')
  else
    local opts = get_window_opts()
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_open_win(buf, true, opts)

    term_buf_nr = buf

    vim.cmd('terminal')
    vim.cmd('startinsert')

    vim.keymap.set('t', '<Esc>', [[<C-\><C-n>]], { buffer = term_buf_nr, silent = true })
    vim.keymap.set('t', '<C-q>', [[<C-\><C-n><cmd>close!<CR>]], { buffer = term_buf_nr, silent = true })

    vim.api.nvim_create_autocmd('TermClose', {
      buffer = term_buf_nr,
      once = true,
      callback = function()
        term_buf_nr = nil
      end,
    })
  end
end

return M
