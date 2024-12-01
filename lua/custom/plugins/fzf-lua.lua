return {
  'ibhagwan/fzf-lua',
  -- optional for icon support
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  config = function()
    -- local dictpath = '~/Dropbox/App/fzf-pinyin/dict_simplified.txt'
    -- local actions = require 'fzf-lua.actions'
    -- calling `setup` is optional for customization
    -- add temp path from scripts/mini.sh in case this is running locally
    local tempdir = vim.trim(vim.fn.system [[sh -c "dirname $(mktemp -u)"]])
    local packpath = os.getenv 'PACKPATH' or tempdir .. '/fzf-lua.tmp/nvim/site'
    vim.cmd('set packpath=' .. packpath)

    vim.o.termguicolors = true

    require('fzf-lua').setup { defaults = { git_icons = false } }

    vim.api.nvim_set_keymap('n', '<C-\\>', [[<Cmd>lua require"fzf-lua".buffers()<CR>]], {})
    vim.api.nvim_set_keymap('n', '<C-k>', [[<Cmd>lua require"fzf-lua".builtin()<CR>]], {})
    vim.api.nvim_set_keymap('n', '<C-p>', [[<Cmd>lua require"fzf-lua".files()<CR>]], {})
    vim.api.nvim_set_keymap('n', '<C-l>', [[<Cmd>lua require"fzf-lua".live_grep_glob()<CR>]], {})
    vim.api.nvim_set_keymap('n', '<C-g>', [[<Cmd>lua require"fzf-lua".grep_project()<CR>]], {})
    vim.api.nvim_set_keymap('n', '<F1>', [[<Cmd>lua require"fzf-lua".help_tags()<CR>]], {})

    ChineseResult = ''

    HistoryFile = '~/Dropbox/App/fzf-pinyin/combined_simplified.txt'
    DictionaryFile = '~/Dropbox/App/fzf-pinyin/dict_simplified.txt'

    function fzf_pinyin()
      pinyin_cmd = 'cat ' .. HistoryFile .. ' ' .. DictionaryFile .. ' | rg ""'
      require('fzf-lua').fzf_exec(pinyin_cmd, {
        prompt = 'pinyin>',
        actions = {
          -- Use fzf-lua builtin actions or your own handler

          ['default'] = function(selected, opts)
            -- edit the string so it only returns characters outside brackets
            local result_no_pinyin = string.gsub(selected[1], '%s*%b[]%s*', ' ')
            local result_chinese = string.match(result_no_pinyin, '^%s*(.-)%s*$')
            ChineseResult = ChineseResult .. result_chinese
            fzf_pinyin()
          end,
          ['esc'] = function(selected, opts)
            -- insert at end of cursor in insert mode
            vim.api.nvim_put({ ChineseResult }, 'c', true, true)
            vim.api.nvim_feedkeys('a', 'n', true)
            ChineseResult = ''
          end,
        },
      }, { exec_silent = true, reload = true })
    end

    vim.api.nvim_set_keymap('i', '<C-x><C-f>', '<Cmd>lua fzf_pinyin()<CR>', { noremap = true, silent = true })

    require('fzf-lua').utils.info '|<C-\\> buffers|<C-p> files|<C-g> grep|<C-l> live grep|<C-k> builtin|<F1> help|'
  end,
}
