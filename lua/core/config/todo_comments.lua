local Util = require 'core.utils'

return {
  setup = function(opts)
    Util.log('todo_comments.setup', 'loading todo_comments.')
    require('core.plugins').load 'todo_comments'

    local ok, tc = SR_L 'todo-comments'
    if not ok then
      return
    end

    tc.setup(opts)
  end,
}
