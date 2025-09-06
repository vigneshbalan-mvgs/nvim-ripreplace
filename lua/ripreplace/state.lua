local M = {}

M.last = { search = nil, replace = nil, results = {}, current_result_index = 0 }
M.active_win = nil
M.active_buf = nil

return M