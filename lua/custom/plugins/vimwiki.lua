return {
  'vimwiki/vimwiki',
  init = function()
    print 'Setting up vimwiki!'
    vim.g.vimwiki_list = {
      {
        path = '~/Dropbox/zettel/wiki/',
        syntax = 'markdown',
        ext = 'md',
        diary_frequency = 'weekly',
      },
    }
    vim.g.vimwiki_global_ext = 0
    vim.g.vimwiki_folding = 'list'
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
    local function get_next_date(date, days_ahead)
      local cmd = string.format('date -j -v +%dd -f %%F %s +%%F', days_ahead, date)
      return vim.fn.system(cmd):gsub('[%s]+', '')
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
      local template_path = vim.fn.expand '~/Dropbox/zettel/templates/weeklyYYMMDD.md'
      local file = io.open(template_path, 'r')
      if not file then
        print 'Error: Could not open template file'
        return
      end
      local template_content = file:read '*all'
      file:close()
      -- Replace YYMMDD with the extracted date
      local content = string.gsub(template_content, 'YYYY[-]MM[-]DD', date)
      for i = 1, 6 do
        local next_day_date = get_next_date(date, i)
        content = string.gsub(content, string.format('[%d]YYY[-]MM[-]DD', tostring(i)), next_day_date)
      end
      print(content)
      -- Insert the content into the buffer
      vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(content, '\n'))
    end
    local augroup = vim.api.nvim_create_augroup('VimwikiDiaryEntry', { clear = true })
    vim.api.nvim_create_autocmd('BufNewFile', {
      pattern = '*/diary/*.md', -- Adjust this pattern to fit your Vimwiki diary entry file path
      callback = handle_weekly_diary_entry,
      group = augroup,
    })
  end,
}
