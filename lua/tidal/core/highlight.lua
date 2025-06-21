local config = require("tidal.config")
local ns = config.namespace
local hl_opts = config.options.selection_highlight

local M = {}

local api = vim.api

local higroup = "TidalSent"

-- Ensure highlight group is set
if hl_opts and hl_opts.highlight then
  api.nvim_set_hl(0, higroup, hl_opts.highlight)
else
  -- Fallback highlight
  api.nvim_set_hl(0, higroup, { bg = "#3e4451", fg = "#ffffff" })
end

--- Apply a transient highlight to a range in the current buffer
---@param start { [1]: integer, [2]: integer } Start position {line, col}
---@param finish { [1]: integer, [2]: integer } Finish position {line, col}
function M.apply_highlight(start, finish)
  local bufnr = api.nvim_get_current_buf()
  local start_row, start_col = start[1], start[2]
  local end_row, end_col = finish[1], finish[2]
  
  -- Use extmarks for highlighting
  local mark_id = api.nvim_buf_set_extmark(bufnr, ns, start_row, start_col, {
    end_line = end_row,
    end_col = end_col,
    hl_group = higroup,
    priority = 1000,
  })
  
  -- Clear highlight after timeout
  if hl_opts and hl_opts.timeout and hl_opts.timeout > 0 then
    vim.defer_fn(function()
      pcall(api.nvim_buf_del_extmark, bufnr, ns, mark_id)
    end, hl_opts.timeout)
  end
end

--- Clear tidal.nvim highlights in all buffers
function M.clear_all()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
  end
end

return M