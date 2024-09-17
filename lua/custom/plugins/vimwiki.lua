return {
  'vimwiki/vimwiki',
  init = function()
    print 'Setting up vimwiki!'
    vim.g.vimwiki_list = {
      {
        path = '~/Dropbox/zettel/wiki',
        syntax = 'markdown',
        ext = '.md',
        diary_frequency = 'weekly',
        custom_wiki2html = '$HOME/Dropbox/zettel/structure/convert.py',
        autotags = 1,
        path_html = '~/Dropbox/zettel/wiki/html',
        template_path = '~/Dropbox/zettel/wiki/templates',
        template_default = 'GitHub',
        template_ext = '.tpl',
        list_margin = 0,
        links_space_char = '_',
        auto_export = 1,
        auto_header = 1,
        automatic_nested_syntaxes = 1,
        html_filename_parameterization = 1,
      },
    }
    vim.g.vimwiki_global_ext = 0
    vim.g.vimwiki_folding = 'list'
    vim.g.vimwiki_markdown_link_ext = 1
  end,
  config = function()
    -- Archive todo function that moves item to *.arc.md
    vim.cmd(
      [[
  function! ArchiveSelected(filename) range
      let timestamp = '[' . strftime('%Y-%m-%d %H:%M:%S') . ']'
      let lines = getline(a:firstline, a:lastline)
      let archival_data = [timestamp] + lines
      call writefile(archival_data, a:filename, 'a')
      execute a:firstline . ',' . a:lastline . 'd _'
  endfunction
          ]],
      true
    )
    vim.keymap.set('n', '<F4>', '<cmd>call ArchiveSelected(expand("%:p") .. ".arc.md")<CR>')
    -- VimWikiTodo: Go to my work todo list
    vim.keymap.set('n', '<Leader>wT', '<cmd>e $HOME/Dropbox/zettel/wiki/work/todo.md<CR>')
    local function get_next_date(date, days_ahead)
      local cmd = string.format('date -j -v +%dd -f %%F %s +%%F', days_ahead, date)
      return vim.fn.system(cmd):gsub('[%s]+', '')
    end
    -- read file content and replace YYYY-MM-DD with date
    -- return the file contents
    local function get_template_and_replace_date(filepath, date)
      local template_path = vim.fn.expand(filepath)
      local file = io.open(template_path, 'r')
      if not file then
        print 'Error: Could not open template file'
        return
      end
      local template_content = file:read '*all'
      file:close()
      -- Replace YYMMDD with the extracted date
      local content = string.gsub(template_content, 'YYYY[-]MM[-]DD', date)
      return content
    end
    local function handle_weekly_diary_entry()
      print 'Grabbing weekly diary template!'
      -- Get the current buffer name
      local bufname = vim.api.nvim_buf_get_name(0)
      local filename = vim.fn.fnamemodify(bufname, ':t')
      print(filename)
      -- Extract the date from the filename
      local date_pattern = '[%d][%d][%d][%d][-][%d][%d][-][%d][%d]'
      local date = string.match(filename, date_pattern)
      if not date then
        print 'Error: Could not extract date from filename'
        return
      end
      -- Read the template file
      local template_path = '$HOME/Dropbox/zettel/templates/weeklyYYMMDD.md'
      local content = get_template_and_replace_date(template_path, date)
      if not content then
        print(string.format('Template %s not found', template_path))
        return
      end
      for i = 1, 6 do
        local next_day_date = get_next_date(date, i)
        content = string.gsub(content, string.format('YYYY[-]MM[-]D[%d]', tostring(i)), next_day_date)
      end

      -- Insert the content into the buffer
      vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(content, '\n'))
    end
    local augroup = vim.api.nvim_create_augroup('VimwikiDiaryEntry', { clear = true })
    vim.api.nvim_create_autocmd('BufNewFile', {
      pattern = '*/diary/*.md', -- Adjust this pattern to fit your Vimwiki diary entry file path
      callback = handle_weekly_diary_entry,
      group = augroup,
    })
    local function paste_template_with_verbose_date(template_path)
      local date = string.gsub(vim.fn.system 'date', ':', '-')
      local content = get_template_and_replace_date(template_path, date)
      if not content then
        print(string.format('Template %s not found', template_path))
      else
        vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(content, '\n'))
      end
    end

    -- Add keymap to paste permanent templates to new notes, and add which-key entry
    local permanent_template_filepath = '$HOME/Dropbox/zettel/templates/permanent.md'
    vim.keymap.set('n', '<leader>wp', function()
      paste_template_with_verbose_date(permanent_template_filepath)
    end, { noremap = true, silent = true })
    local wk = require 'which-key'
    wk.add { '<leader>wp', desc = '[P]aste Permanent Template' }
    wk.add { '<leader>wt', desc = 'Open Work [T]odo' }
  end,
}
