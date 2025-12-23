vim.g.mapleader = " " -- This MUST be the first line

-- ==========================================================================
-- 1. THE PLUGIN MANAGER (LAZY.NVIM)
--    This downloads the manager if you don't have it.
-- ==========================================================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- ==========================================================================
-- 2. PLUGINS SETUP
-- ==========================================================================
require("lazy").setup({

  -- DASHBOARD (Alpha)
  {
    'goolord/alpha-nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function ()
        local dashboard = require('alpha.themes.startify')
        
        -- Custom Header (You can put whatever text or ASCII art you like here)
        dashboard.section.header.val = {
            [[                               __                ]],
            [[  ___      __    __  __  __   /\_\    ___ ___    ]],
            [[ /' _ `\  /'__`\ /\ \/\ \/\ \  \/\ \  /' __` __`\  ]],
            [[ /\ \/\ \/\  __/ \ \ \_/ \_/ \  \ \ \ /\ \/\ \/\ \ ]],
            [[ \ \_\ \_\ \____\ \ \___^___ /   \ \_\\ \_\ \_\ \_\]],
            [[  \/_/\/_/\/____/  \/__//__/     \/_/ \/_/\/_/\/_/]],
            [[                                                   ]],
            [[                     NEOVIM                        ]],
        }

        -- Custom Menu
        dashboard.section.top_buttons.val = {
            dashboard.button("e", "  New file", ":ene <BAR> startinsert <CR>"),
            dashboard.button("r", "  Recently opened files", ":Telescope oldfiles<CR>"),
            dashboard.button("c", "  Configuration", ":e $MYVIMRC <CR>"),
            dashboard.button("q", "  Quit Neovim", ":qa<CR>"),
        }

        require('alpha').setup(dashboard.opts)
    end
  },
  -- 1. FILE TREE (Sidebar)
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup({
        view = {
          width = 35, -- Set the sidebar width
          side = "left",
        },
        renderer = {
          icons = {
            show = {
              file = true,
              folder = true,
            },
          },
        },
      })
      -- Re-verify the keymap
      vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>', { silent = true })
    end,
  },

  -- 2. AUTOPAIRS (Auto-close brackets)
  {
    'windwp/nvim-autopairs',
    event = "InsertEnter",
    config = true
  },

  -- 3. THEME (With Custom Green Math)
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("tokyonight").setup({
        on_highlights = function(hl, c)
          -- This forces all standard Math environments to be bright green
          hl.texMathZone = { fg = "#00FF00" } 
          hl.texMathZoneX = { fg = "#00FF00" }
          hl.texMathZoneXX = { fg = "#00FF00" }
        end,
      })
      -- Load the colorscheme
      vim.cmd[[colorscheme tokyonight-night]]
    end,
  },
  
  -- 4. BETTER COMPLETION (For that Environment Dropdown)
  -- Add this specific source for VimTeX
  { 
    "micangl/cmp-vimtex" 
  },


  -- A. VIMTEX (The Latex Engine)
  {
    "lervag/vimtex",
    lazy = false,
    config = function()
      -- Connect to SumatraPDF
      vim.g.vimtex_view_general_viewer = 'SumatraPDF'
      vim.g.vimtex_view_general_options = '-reuse-instance -forward-search @tex @line @pdf'
      vim.g.vimtex_compiler_method = 'latexmk'
    end
  },

  -- B. AUTOCOMPLETION & SNIPPETS
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-buffer",       -- suggest words in current file
      "hrsh7th/cmp-path",         -- suggest file paths
      "saadparwaiz1/cmp_luasnip", -- connect autocomplete to snippets
      "L3MON4D3/LuaSnip",         -- The snippet engine
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
          ['<C-Space>'] = cmp.mapping.complete(), -- Ctrl+Space to force menu
          ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Enter to pick
          
          -- Tab to jump forward in a snippet
          ["<Tab>"] = cmp.mapping(function(fallback)
            if luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          
          -- Shift+Tab to jump backward
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = 'luasnip' },
          { name = 'vimtex '},
          { name = 'buffer' },
        })
      })
    end
  },
})

-- ==========================================================================
-- 3. CUSTOM SNIPPETS
-- ==========================================================================
local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt
local extras = require("luasnip.extras")
local rep = extras.rep

ls.add_snippets("tex", {
  
  -- TYPE "beg" -> GET \begin{...} \end{...}
  s("beg", fmt([[
    \begin{{{}}}
        {}
    \end{{{}}}
  ]], { i(1), i(0), rep(1) })),

  -- TYPE "mk" -> GET $...$ (Inline Math)
  s("mk", fmt("${}$", { i(1) })),

  -- TYPE "dm" -> GET Display Math \[ ... \]
  s("dm", fmt([[
    \[
        {}
    \]
  ]], { i(1) })),

  -- TYPE "ff" -> GET Fraction \frac{}{}
  s("ff", fmt([[\frac{{{}}}{{{}}}]], { i(1), i(2) })),

  -- Type "lf" -> \left( ... \right)
  -- It captures the bracket type!
  -- Try typing "lf" -> Enter -> "(" -> It creates \left( | \right)
  s("lf", fmt([[
    \left{} {} \right{}
  ]], {
    i(1), -- You type the bracket here (e.g., "(" or "[")
    i(0), -- The cursor jumps here (middle)
    rep(1) -- This repeats whatever bracket you typed in i(1)
  }))
})  

-- ==========================================================================
-- LATEX SPECIFIC KEYMAPS
-- These only trigger when you open a .tex file
-- ==========================================================================

vim.api.nvim_create_autocmd("FileType", {
  pattern = "tex",
  callback = function()
    -- 1. THE "NEW LINE" BUTTON (Mapped to Alt + Enter)
    -- Adds "\\" to end of line, new line, adds "&", and moves cursor
    vim.keymap.set("i", "<C-l>", "<Esc>A \\\\<CR>& ", { buffer = true })

    -- 2. THE "TEXT" BUTTON (Mapped to Ctrl + t)
    -- Adds "&& \text{}" and puts cursor inside the bracket
    vim.keymap.set("i", "<C-t>", " && \\text{}<Left>", { buffer = true })
  end,
})
