return {
  'vimwiki/vimwiki',
  init = function()
    print 'Setting up vimwiki!'
    vim.g.vimwiki_list = {
      {
        path = '~/Dropbox/theVault/Zettel/wiki/',
        syntax = 'markdown',
        ext = 'md',
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
  end,
}
