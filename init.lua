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
})  
