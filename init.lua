-- ==========================================================================
-- 0. GLOBAL SETTINGS
-- ==========================================================================
vim.g.mapleader = " " 
vim.g.vimtex_toc_config = {
  fold_enable = 1,       -- Enable the ability to collapse/expand
  fold_level_start = 0,  -- 0 means everything starts CLOSED (collapsed)
  split_width = 22,
  show_numbers = 0,
  layers = { 'content' }, 
  
}
-- Tell Neovim that the code \27[13;2u (from your terminal) equals Shift+Enter
vim.cmd("set <S-CR>=^[13;2u")
-- ==========================================================================
-- 1. THE PLUGIN MANAGER (LAZY.NVIM)
-- ==========================================================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(lazypath)

-- ==========================================================================
-- 2. VISUALS & CLIPBOARD
-- ==========================================================================
vim.opt.number = true           
vim.opt.relativenumber = true   
vim.opt.termguicolors = true    
vim.opt.cursorline = true       
vim.opt.expandtab = true        
vim.opt.shiftwidth = 2          
vim.opt.tabstop = 2             
vim.opt.mouse = 'a'             
vim.opt.clipboard = "unnamedplus" -- Allows pasting from outside Neovim with 'p'
vim.opt.fillchars = { eob = " " } 
vim.opt.wrap = true
vim.opt.linebreak = true -- This stops words from being chopped in half.
vim.opt.breakindent = true -- Makes wrapped lines look cleaner by matching the indent of the line above
vim.opt.ignorecase = true
-- vim.opt.smartcase = true


-- ==========================================================================
-- 3. PLUGINS SETUP
-- ==========================================================================
require("lazy").setup({

  -- THEME: VS Code Colors
  {
    "Mofiqul/vscode.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require('vscode').setup({ italic_comments = true })
      require('vscode').load()
    end
  },
  -- TREESITTER: High-performance Syntax Highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main", -- Use the modern branch
    build = ":TSUpdate",
    config = function()
      -- THE FIX: We try both names just to be 100% sure we don't crash
      local ok, ts = pcall(require, "nvim-treesitter.config")
      if not ok then ok, ts = pcall(require, "nvim-treesitter.configs") end
      
      if ok then
        ts.setup({
          ensure_installed = { "latex", "lua", "vim", "vimdoc" }, -- Start small
          highlight = { enable = true, additional_vim_regex_highlighting = false },
        })
      end
    end
  },
   -- FILE TREE (Sidebar)
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup({
        -- This tells the tree to change its root to your current folder
        sync_root_with_cwd = true, 
        respect_buf_cwd = true,
        update_focused_file = {
          enable = true,
          update_root = true,
        },
        view = {
          width = 35,
          side = "left",
        },
        -- (Rest of your renderer settings here...)
      })
      vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>', { silent = true }) 
    end 
  }, 
   -- TELESCOPE   
  {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.8',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      local telescope = require('telescope')
      local builtin = require('telescope.builtin')

      -- 1. THE FIX: Disable treesitter preview to stop the crash
      telescope.setup({
        defaults = {
          preview = {
            treesitter = false, 
          }
        }
      })

      -- 2. YOUR KEYMAPS (Keep them!)
      vim.keymap.set('n', '<leader>fd', builtin.find_files, { desc = "Find Path/File" })
      -- This adds a shortcut for recent files if you want to use it outside the dashboard
      vim.keymap.set('n', '<leader>fr', builtin.oldfiles, { desc = "Find Recent Files" })
    end
  },
 
  -- TABS: Top bar
  {
    'akinsho/bufferline.nvim',
    dependencies = 'nvim-tree/nvim-web-devicons',
    config = function()
      require("bufferline").setup{ options = { separator_style = "thin" } }
      vim.keymap.set("n", "<Tab>", ":BufferLineCycleNext<CR>")
      vim.keymap.set("n", "<S-Tab>", ":BufferLineCyclePrev<CR>")
    end
  },

  -- STATUS BAR: Bottom bar
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('lualine').setup({ options = { theme = 'vscode' } })
    end
  },

  -- TERMINAL: Bottom toggle
  {
    'akinsho/toggleterm.nvim',
    version = "*",
    config = function()
      require("toggleterm").setup({
        size = 15,
        open_mapping = [[<C-\>]], 
        direction = 'horizontal',
      })
    end
  },

  -- DASHBOARD: Alpha (Simplified to prevent nil errors)
  {
    'goolord/alpha-nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function ()
        local dashboard = require('alpha.themes.dashboard')
     
        dashboard.section.buttons.val = {
            dashboard.button("e", "  New file", ":ene <BAR> startinsert <CR>"),
            dashboard.button("r", "  Recent files", ":Telescope oldfiles<CR>"),
	    dashboard.button("c", "  Configuration", ":e $MYVIMRC <CR>"),
            dashboard.button("q", "  Quit", ":qa<CR>"),
        }
        dashboard.section.footer.val = {
            " ",
            "--- SHORTCUTS IN NORMAL MODE ---",
            "V+d: Delete Chunk | u: Undo | Space+e: Sidebar" ,
            "Ctrl+\\: Terminal | Tab: Next File | \\ll: Compile | n: Search Next | N: Search Previous | gg: Go to 1st line",
            "/{text}: Search Forward | ?{text}: Search Backward",
            " "  ,
            "--- LATEX & GIT ---",
            "SPC + tc : Toggle TOC  |  \\ll      : Compile ",
            "SPC + gp : Git Sync    |  SPC + p  : Paste Sys",
        }
        require('alpha').setup(dashboard.opts)
    end
  },

  -- VIMTEX
  { "lervag/vimtex", lazy = false },

  -- AUTOCOMPLETION
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "saadparwaiz1/cmp_luasnip",
      "L3MON4D3/LuaSnip",
      "micangl/cmp-vimtex",
    },
config = function()
  local cmp = require("cmp")
  local luasnip = require("luasnip")

  cmp.setup({
    snippet = {
      expand = function(args)
        luasnip.lsp_expand(args.body)
      end,
    },
    mapping = cmp.mapping.preset.insert({
      -- 1. Up/Down Arrows: Cycle completion menu if visible
      ["<Down>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_next_item({ behavior = cmp.SelectBehavior.Insert })
        else
          fallback()
        end
      end, { "i", "s" }),

      ["<Up>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_prev_item({ behavior = cmp.SelectBehavior.Insert })
        else
          fallback()
        end
      end, { "i", "s" }),

      -- 2. Tab: Do NOTHING if menu is visible (Arrows handle it). 
      -- If menu is closed: Jump snippets or Tabout.
      ["<Tab>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          return -- Important: This makes Tab do nothing when menu is open
        elseif luasnip.expand_or_jumpable() then
          luasnip.expand_or_jump()
        elseif require("tabout").tabout then
          -- We try to tabout; if we aren't in brackets, it falls back to normal Tab
          local success = require("tabout").tabout()
          if not success then fallback() end
        else
          fallback()
        end
      end, { "i", "s" }),

      -- 3. Enter: Confirm the selection
      ["<CR>"] = cmp.mapping.confirm({ select = true }),
    }), -- This brace closes the mapping table correctly

    -- Sources must be OUTSIDE the mapping table
    sources = cmp.config.sources({
      { name = 'vimtex' },
      { name = 'luasnip' },
      { name = 'buffer' },
    }),
  })
end,
},
  -- TABOUT
  {
    'abecodes/tabout.nvim',
    event = 'InsertEnter', 
    config = function()
      require('tabout').setup({
        tabkey = '<Tab>', 
        backwards_tabkey = '<S-Tab>',
        completion = true --do not tab out when in completion mode
      })
    end,
  },

  -- AUTO-PAIRS
  { 'windwp/nvim-autopairs', event = "InsertEnter", config = true },
})


-- ==========================================================================
-- 4. CUSTOM SNIPPETS
-- ==========================================================================
local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt
local rep = require("luasnip.extras").rep

ls.add_snippets("tex", {
  s("beg", fmt([[\begin{{{}}}{}\end{{{}}}]], { i(1), i(0), rep(1) })),
  s("ff", fmt([[\frac{{{}}}{{{}}}]], { i(1), i(2) })),
  s("mm", fmt("${}$", { i(1) })),
  s("dm", fmt([[
  	\[
		{}
	\]
	]], { i(1) })),
  s("lr", fmt([[\left{} {} \right{}]], { i(1), i(0), rep(1) }))
})

-- ==========================================================================
-- 5. AUTO-SAVE & TERMINAL
-- ==========================================================================
vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI", "BufLeave" }, {
  pattern = "*.tex",
  callback = function()
    if vim.bo.modified then vim.cmd("silent! write") end
  end,
})

-- ==========================================================================
-- 6. KEYMAPS
-- ==========================================================================

-- i. TERMINAL FIXES
function _G.set_terminal_keymaps()
  local opts = {buffer = 0}
  vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], opts)
  vim.keymap.set('t', 'jk', [[<C-\><C-n>]], opts)
end
vim.cmd('autocmd! TermOpen term://* lua set_terminal_keymaps()')


-- ii. WRAPPED LINE NAVIGATION
vim.keymap.set('n', 'j', "gj", { silent = true })
vim.keymap.set('n', 'k', "gk", { silent = true })

-- CLIPBOARD & DELETE FIXES
-- Toggle the LaTeX Table of Contents (ToC)
vim.keymap.set('n', '<leader>tc', ':VimtexTocToggle<CR>', { desc = "Toggle Table of Contents" })

vim.keymap.set('n', 'x', '"_x')
vim.keymap.set("x", "p", [["_dP]])

-- COPY & PASTE EXTERNALLY / INTERNALLY


-- COPY & PASTE EXTERNALLY / INTERNALLY
-- COPY & PASTE EXTERNALLY / INTERNALLY
vim.keymap.set('v', '<leader>c', '"+y') --Copy in visual mode
vim.keymap.set('n', '<leader>p', '"+p') --Paste in normal mode
-- Undo with Ctrl+z in Normal and Visual Mode
vim.keymap.set({'n', 'v'}, '<C-z>', 'u', { desc = 'Undo' })

-- UNDO
vim.keymap.set('i', '<C-z>', '<C-o>u', { desc = 'Undo in insert mode' })


-- One-key Git Sync (Add, Commit, and Push)
vim.keymap.set('n', '<leader>gp', function()
    -- 1. Get the directory of the file you are currently editing
    local file_dir = vim.fn.expand('%:p:h')
    
    -- 2. Construct the command: 
    -- Change directory to file_dir, THEN run git commands
    local cmd = string.format("cd %s && git add . && git commit -m 'auto-update' && git push", vim.fn.shellescape(file_dir))
    
    -- 3. Execute the command and print the result
    print("Syncing: " .. file_dir)
    vim.fn.system(cmd)
    print("Git Sync Complete!")
end, { desc = 'Git sync from current file directory' })

-- ==========================================================================
-- 6. AUTOMATION & FILE-SPECIFIC FIXES
-- ==========================================================================
-- Word Wrap Fix:
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "latex", "tex" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.breakindent = true
  end,
})

-- Automatically jump to the last known cursor position on open
vim.api.nvim_create_autocmd("BufReadPost", {
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- ==========================================================================
-- 7. CUSTOM COLOURS
-- ==========================================================================

-- Targets the name inside {align*} or {equation} from your screenshot
vim.api.nvim_set_hl(0, "texMathEnvArgName", { fg = "#9CDCFE" }) 

-- Targets the \begin and \end tags for math zones
vim.api.nvim_set_hl(0, "texMathEnvBgnEnd", { fg = "#C586C0", bold = true })

-- A catch-all for the math zone itself if needed
vim.api.nvim_set_hl(0, "texMathZoneEnv", { fg = "#9CDCFE" })


vim.api.nvim_set_hl(0, "texDelimiter", { fg = "#77DD77", bold = true }) 
vim.api.nvim_set_hl(0, "texEnvArgName", { fg = "#9CDCFE", bold = true , force = true }) 

vim.api.nvim_set_hl(0, "texMathZoneX", { fg = "#77DD77" })
-- For when Treesitter is active
vim.api.nvim_set_hl(0, "@markup.math", { fg = "#77DD77", bold = true })

-- For when the old "texMathDelimZone" is active (what you're seeing now)
vim.api.nvim_set_hl(0, "texMathDelimZone", { fg = "#77DD77", bold = true })
vim.api.nvim_set_hl(0, "texMathSymbol", { fg = "#77DD77", bold = true })
require('nvim-treesitter.install').prefer_git = true

-- ==========================================================================
-- 8. LATEX SPECIFIC LOGIC (Refined for init.lua)
-- ==========================================================================
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "tex", "latex" }, -- catches both standard tex and detected latex
  callback = function(event)
    print("LaTeX Setup Loaded!") -- CONFIRMATION MESSAGE
    
    local buf = event.buf
    local function opts(desc)
      return { silent = true, buffer = buf, desc = desc }
    end

    -- 1. THE SMART INSERT FUNCTION
    local function smartInsert()
      local row, col = unpack(vim.api.nvim_win_get_cursor(0))
      local current_line = vim.api.nvim_get_current_line()
      local whiteSpace = string.match(current_line, '^%s*') or ''

      -- Define environments
      local environments = {
        { names = {'itemize', 'enumerate'}, text = '\\item ', adjust_ws = function(line, ws) return string.match(line, '\\item') and ws:sub(1) or ws end },
        { names = {'equivEnumerate'}, text = '\\item[($\\Rw$)] ', adjust_ws = function(line, ws) return string.match(line, '\\item') and ws:sub(1) or ws end },
        { names = {'Exercise', 'Answer'}, text = '\\Question ' },
        { names = {'align', 'align*'}, pre_text = '\\\\', text = '&= ' },
        { names = {'cases', 'gather*', 'matrix', 'pmatrix'}, pre_text = '\\\\', text = '' }
      }

      for _, env in ipairs(environments) do
        for _, name in ipairs(env.names) do
           -- Safe check for VimTeX
           local ok, is_inside = pcall(vim.fn["vimtex#env#is_inside"], name)
           if ok and is_inside[1] > 0 and is_inside[2] > 0 then
             local pre_text = env.pre_text or ''
             local text_to_insert = env.text or ''
             local current_whiteSpace = env.adjust_ws and env.adjust_ws(current_line, whiteSpace) or whiteSpace
             local final_text = current_whiteSpace .. text_to_insert
             
             vim.api.nvim_buf_set_text(0, row - 1, col, row - 1, col, { pre_text, final_text })
             vim.api.nvim_win_set_cursor(0, { row + 1, #final_text + 1 })
             return
           end
        end
      end
      -- Fallback: Just insert a normal newline
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<CR>", true, false, true), "n", true)
    end

       -- If you REALLY want Shift-Enter, uncomment the line below. 
    -- If it doesn't work, your terminal is blocking it.
    vim.keymap.set('i', '<S-CR>', smartInsert, opts('Smart Insert Item'))
  end
})
