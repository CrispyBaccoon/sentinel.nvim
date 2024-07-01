return {
  setup = function(opts)
    ch.log('todo_comments.setup', 'loading todo_comments.')
    require('ch.plugins').load 'todo_comments'

    local ok, tc = SR_L 'todo-comments'
    if not ok then
      return
    end

    tc.setup(opts)
  end,
}
