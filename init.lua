-- ==========================================================================
-- 0. GLOBAL SETTINGS
-- ==========================================================================
vim.g.mapleader = " " 
vim.g.vimtex_toc_config = {
  fold_enable = 1,       -- Enable the ability to collapse/expand
  fold_level_start = 0,  -- 0 means everything starts CLOSED (collapsed)
  split_width = 27,
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
            "V+d: Delete Chunk       | u: Undo                 | Space+e: Sidebar         | Ctrl+\\: Terminal" ,
            "Tab: Next File          |  \\ll: Compile           | n: Search Next           | N: Search Previous",
            "gg: Go to 1st line      | /{text}: Search Forward | ?{text}: Search Backward |" ,
            " "  ,
            "--- LATEX & GIT ---",
            "SPC + tc : Toggle TOC   |  \\ll      : Compile ",
            "SPC + gp : Git Sync     |  SPC + p  : Paste Sys",
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


  { -- https://github.com/kylechui/nvim-surround/blob/main/lua/nvim-surround/config.lua
      "kylechui/nvim-surround",
      event = "VeryLazy",
      config = function()
        require("nvim-surround").setup({
          keymaps = {
            insert = "<C-g>s",
            insert_line = "<C-g>S",
            normal = "ys",
            normal_cur = "yc", -- was yss
            normal_line = "yS",
            normal_cur_line = "yC", -- was ySS
            visual = "S",
            visual_line = "gS",
            delete = "ds",
            change = "cs",
            change_line = "cS",
          },

         -- 2. THE FIX: Define "\" to wrap, then jump to end
        surrounds = {
          ["\\"] = {
            add = function()
              -- A. Ask for the command (User types 'sqrt' then hits ENTER)
              local cmd = require("nvim-surround.config").get_input("LaTeX Command: ")
              
              -- B. If user hit Enter (didn't cancel):
              if cmd then
                local last_char = cmd:sub(-1)
                local match_pairs = { ["("]=")", ["["]="]", ["{"]="}", ["|"]="|" }

                if match_pairs[last_char] then
                  local cmd_base = cmd:sub(1, -2) -- e.g. "left" or "Bigg"
                  local close_char = match_pairs[last_char]

                  -- Logic: "left" becomes "right", but "Bigg" stays "Bigg"
                  local close_cmd = cmd_base
                  if cmd_base == "left" then close_cmd = "right" end

                  -- Queue Jump: Find the opening char, jump to matching %, then insert
                  vim.schedule(function() 
                    vim.cmd("normal! f" .. last_char .. "%a") 
                  end)

                  return { { "\\" .. cmd_base .. last_char }, { "\\" .. close_cmd .. close_char } }
                         
                  -- C. Standard Command (text, sqrt, etc.) -> Add Curly Braces
                else
                  vim.schedule(function() vim.cmd("normal! f{%a") end)
                  return { { "\\" .. cmd .. "{" }, { "}" } }
                end              
              end
            end,
          },
        }, 
        })
      end
    },
  })


-- ==========================================================================
-- 4. CUSTOM SNIPPETS
-- ==========================================================================
local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local f = ls.function_node
local d = ls.dynamic_node
local fmt = require("luasnip.extras.fmt").fmt
local fmta = require("luasnip.extras.fmt").fmta
local rep = require("luasnip.extras").rep

ls.add_snippets("tex", {
  -- 1. REAL NUMBERS AUTO-EXPAND (R2 -> \mathbb{R}^2, Rn -> \mathbb{R}^n)
  -- Trigger: R followed immediately by a digit (0-9) or 'n'
  s(
    {trig = "R([%d|n])", regTrig = true, snippetType="autosnippet", condition = in_mathzone},
    fmt([[\mathbb{{R}}^{{{}}}]], {
      f(function(_, snip) return snip.captures[1] end)
    })
  ),

  -- 2. VECTOR FIELDS / SETS NOTATION (VF(X,M) -> \mathcal{X}(M))
  -- Trigger: VF(...,...) automatically when you type the closing ')'
  s(
    {trig = "VF%((.-),(.-)%)", regTrig = true, snippetType="autosnippet", condition = in_mathzone},
    fmt([[\mathcal{{{}}}({})]], {
      f(function(_, snip) return snip.captures[1] end), -- The first capture (X)
      f(function(_, snip) return snip.captures[2] end)  -- The second capture (M)
    })
  ),
  -- 3. AUTO DOTS (, ... , -> , \ldots, )
  -- Trigger: You type ", ... ," and it instantly becomes ", \ldots, "
  s(
    {trig = ", ... ,", snippetType="autosnippet", condition = in_mathzone},
    fmt(", \\ldots, ", {})
  ),

s(
			{ trig = ":([%w%*]+%s?)", regTrig = true, wordTrig = true, dscr = "new environment",priority =100},
			fmta(
				[[
				\begin{<>}
					<><>
				\end{<>}
				]],
				{
					f(function(_, snip) return snip.captures[1] end),
					d(1, get_visual), i(0),
					f(function(_, snip) return snip.captures[1] end),
				}
			)	),

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

vim.keymap.set('n', ';', ':')

-- CLIPBOARD & DELETE FIXES
-- Toggle the LaTeX Table of Contents (ToC)
vim.keymap.set('n', '<leader>tc', ':VimtexTocToggle<CR>', { desc = "Toggle Table of Contents" })

vim.keymap.set('n', 'x', '"_x')
vim.keymap.set("x", "p", [["_dP]])

-- COPY & PASTE EXTERNALLY / INTERNALLY


-- COPY & PASTE EXTERNALLY / INTERNALLY
-- COPY & PASTE EXTERNALLY / INTERNALLY
vim.keymap.set('v', '<C-c>', '"+y') --Copy in visual mode
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



-- STACK COPY (Accumulate lines from above)

    -- Global state to track the "stacking" sequence
    _G.stack_state = { active = false, start_row = 0, count = 0 }

    vim.keymap.set('i', '<M-Up>', function()
      local row, col = unpack(vim.api.nvim_win_get_cursor(0))
      
      -- 1. CHECK RESET: If cursor moved oddly or we typed, reset the stack
      -- (We expect the cursor to be on the line BELOW what we just inserted)
      if _G.stack_state.active then
         if row ~= (_G.stack_state.last_insert_row + 1) then
            _G.stack_state.active = false
         end
      end

      -- 2. INITIALIZE if new sequence
      if not _G.stack_state.active then
          _G.stack_state.active = true
          _G.stack_state.base_row = row -- The "original" cursor line
          _G.stack_state.count = 0
      end

      -- 3. CALCULATE TARGET LINE (The line we want to steal)
      -- We look upwards from the ORIGINAL base row, minus how many we've already stolen
      local target_idx = _G.stack_state.base_row - 1 - _G.stack_state.count - 1 
      
      if target_idx < 0 then 
        print("Top of file reached!")
        return 
      end

      -- 4. GET & INSERT TEXT
      local target_text = vim.api.nvim_buf_get_lines(0, target_idx, target_idx + 1, false)[1]
      
      -- Insert the text at the CURRENT cursor row (pushing the cursor down)
      vim.api.nvim_buf_set_lines(0, row - 1, row - 1, false, { target_text })
      
      -- 5. UPDATE STATE
      _G.stack_state.count = _G.stack_state.count + 1
      _G.stack_state.last_insert_row = row -- We just inserted at 'row', so cursor is now row+1
      
      -- Move cursor down to stay "under" the stack we are building
      vim.api.nvim_win_set_cursor(0, { row + 1, col })

    end, { desc = "Stack copy previous lines" })

-- INCREMENTAL SELECTION (Ctrl + Left/Right)


  -- 1. SELECT RIGHT (Ctrl + Right)
  -- Behavior: Enters Visual Mode (if not on) and jumps to end of next word
  vim.keymap.set({'n', 'i', 'v'}, '<C-Right>', function()
    local mode = vim.api.nvim_get_mode().mode
    
    -- If in INSERT Mode: Exit insert, enter Visual, move right
    if mode == 'i' then
      vim.cmd("stopinsert")
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("ve", true, false, true), 'n', true)
    
    -- If in NORMAL Mode: Enter Visual, move right
    elseif mode == 'n' then
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("ve", true, false, true), 'n', true)
      
    -- If in VISUAL Mode: Just extend the selection right
    elseif mode == 'v' or mode == 'V' or mode == '\22' then
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("e", true, false, true), 'n', true)
    end
  end, { desc = "Select word right" })


  -- 2. SELECT LEFT (Ctrl + Left)
  -- Behavior: Enters Visual Mode (if not on) and jumps back one word
  vim.keymap.set({'n', 'i', 'v'}, '<C-Left>', function()
    local mode = vim.api.nvim_get_mode().mode
    
    if mode == 'i' then
      vim.cmd("stopinsert")
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("vb", true, false, true), 'n', true)
      
    elseif mode == 'n' then
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("vb", true, false, true), 'n', true)
      
    elseif mode == 'v' or mode == 'V' or mode == '\22' then
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("b", true, false, true), 'n', true)
    end
  end, { desc = "Select word left" })


  -- 3. SELECT WHOLE LINE UP (Ctrl + Up)
  -- Forces Visual Line Mode (V) to grab the whole line
  vim.keymap.set({'n', 'i', 'v'}, '<C-Up>', function()
    local mode = vim.fn.mode()
    if mode == 'i' then
      vim.cmd("stopinsert")
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("Vk", true, false, true), 'n', true)
    elseif mode == 'n' then
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("Vk", true, false, true), 'n', true)
    elseif mode == 'v' then
      -- Switch from char-visual (v) to line-visual (V) then move up
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("Vk", true, false, true), 'n', true)
    elseif mode == 'V' then
      -- Already in line-visual, just move up
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("k", true, false, true), 'n', true)
    end
  end, { desc = "Select line up" })

  -- 4. SELECT WHOLE LINE DOWN (Ctrl + Down)
  -- Forces Visual Line Mode (V) to grab the whole line
  vim.keymap.set({'n', 'i', 'v'}, '<C-Down>', function()
    local mode = vim.fn.mode()
    if mode == 'i' then
      vim.cmd("stopinsert")
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("Vj", true, false, true), 'n', true)
    elseif mode == 'n' then
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("Vj", true, false, true), 'n', true)
    elseif mode == 'v' then
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("Vj", true, false, true), 'n', true)
    elseif mode == 'V' then
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("j", true, false, true), 'n', true)
    end
  end, { desc = "Select line down" })

  -- 5. SELECT TO LINE END (Ctrl + Shift + Right)
  -- Uses '$' to jump to end of line
  vim.keymap.set({'n', 'i', 'v'}, '<C-S-Right>', function()
    local mode = vim.fn.mode()
    if mode == 'i' then
      vim.cmd("stopinsert")
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("v$", true, false, true), 'n', true)
    elseif mode == 'n' then
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("v$", true, false, true), 'n', true)
    elseif mode == 'v' or mode == 'V' or mode == '\22' then
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("$", true, false, true), 'n', true)
    end
  end, { desc = "Select to EOL" })

  -- 6. SELECT TO LINE START (Ctrl + Shift + Left)
  -- Uses '0' to jump to start of line
  vim.keymap.set({'n', 'i', 'v'}, '<C-S-Left>', function()
    local mode = vim.fn.mode()
    if mode == 'i' then
      vim.cmd("stopinsert")
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("v0", true, false, true), 'n', true)
    elseif mode == 'n' then
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("v0", true, false, true), 'n', true)
    elseif mode == 'v' or mode == 'V' or mode == '\22' then
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("0", true, false, true), 'n', true)
    end
  end, { desc = "Select to SOL" })

-- ==========================================================================
-- HOME / END NAVIGATION (For Fn + Left/Right)
-- ==========================================================================

-- 1. HOME (Fn + Left) -> Go to start of line
vim.keymap.set({'n', 'i'}, '<Home>', function()
  -- If in Insert Mode, we use <C-o> to jump without leaving insert
  if vim.fn.mode() == 'i' then
     vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-o>^", true, false, true), 'n', true)
  else
     -- In Normal Mode, go to first non-empty character
     vim.cmd("normal! ^")
  end
end, { desc = "Go to start of text" })

-- 2. END (Fn + Right) -> Go to end of line
vim.keymap.set({'n', 'i'}, '<End>', function()
  if vim.fn.mode() == 'i' then
     -- In Insert Mode, just move to the end
     vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<End>", true, false, true), 'n', true)
  else
     -- In Normal Mode, go to end ($)
     vim.cmd("normal! $")
  end
end, { desc = "Go to end of line" })








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
    vim.keymap.set('i', '<S-CR>', smartInsert, {desc = 'Smart Insert Item'})
  end
})
