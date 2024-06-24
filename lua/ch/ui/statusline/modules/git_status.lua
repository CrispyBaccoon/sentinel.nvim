local utils = require 'ch.ui.statusline.utils'

return function()
  if
      not vim.b[utils.stbufnr()].gitsigns_head
      or vim.b[utils.stbufnr()].gitsigns_git_status
  then
    return ''
  end

  local git_status = vim.b[utils.stbufnr()].gitsigns_status_dict

  local added = (git_status.added and git_status.added ~= 0)
      and (ch.lib.fmt.space(ch.lib.icons.diff_status.added) .. git_status.added)
      or ''
  local changed = (git_status.changed and git_status.changed ~= 0)
      and (ch.lib.fmt.space(ch.lib.icons.diff_status.changed) .. git_status.changed)
      or ''
  local removed = (git_status.removed and git_status.removed ~= 0)
      and (ch.lib.fmt.space(ch.lib.icons.diff_status.deleted) .. git_status.removed)
      or ''

  return added .. changed .. removed .. ' '
end
