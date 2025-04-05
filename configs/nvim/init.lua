vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Setup lazy.nvim
require("lazy").setup({
  spec = {
    { "neoclide/coc.nvim", branch = "release" },
    { "prisma/vim-prisma" },
    { "leafOfTree/vim-svelte-plugin" },
    { "daltonmenezes/aura-theme", rtp = "packages/neovim" },
    { "goolord/alpha-nvim" },
    { "elkowar/yuck.vim" },
    { "nvim-lualine/lualine.nvim" },
    { "nvim-tree/nvim-web-devicons" },
    { "L3MON4D3/LuaSnip" },
    { "windwp/nvim-autopairs" },
    { "nvim-treesitter/nvim-treesitter" },
    { "nvim-lua/plenary.nvim" },
    { "BurntSushi/ripgrep" },
    { "nvim-telescope/telescope.nvim" },
    { "mrcjkb/rustaceanvim" },
    { "leafgarland/typescript-vim" },
    { "peitalin/vim-jsx-typescript" },
    { "laktak/tome" },
    { "scottmckendry/cyberdream.nvim" },
    { "sbdchd/neoformat" },
    { "lervag/vimtex" },
    { "sakhnik/nvim-gdb" },
    { "OXY2DEV/markview.nvim" },
    { "Yggdroot/indentLine" },
    { "tpope/vim-commentary" },
    { "yuttie/comfortable-motion.vim" },
    { "mrloop/telescope-git-branch.nvim" },
    { "tris203/precognition.nvim" },
    { "folke/noice.nvim" },
    { "MunifTanjim/nui.nvim" },
    { "rcarriga/nvim-notify" },
    { "nvim-tree/nvim-tree.lua" },
    { "catppuccin/nvim", as = "catppuccin" },
    { "hrsh7th/nvim-cmp" },
    { "hrsh7th/cmp-nvim-lsp" },
    { "hrsh7th/cmp-buffer" },
    { "hrsh7th/cmp-path" },
    { "saadparwaiz1/cmp_luasnip" },
    { "L3MON4D3/LuaSnip" },
    { "neovim/nvim-lspconfig" },
    { "williamboman/mason.nvim" },
    { "williamboman/mason-lspconfig.nvim" },
    { "hrsh7th/cmp-emoji" },
    { "rafamadriz/friendly-snippets" },
    { "onsails/lspkind.nvim" },
    { "windwp/nvim-autopairs" },
    { "nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim" } },
    { "nvim-treesitter/nvim-treesitter", dependencies = { "nvim-treesitter/nvim-treesitter-textobjects" } },
    { 'dasupradyumna/midnight.nvim', lazy = false },
  },
  checker = { enabled = false },
})

-- Snippet
local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

ls.add_snippets("sh", {
  s("if", {
    t("if [ "), i(1), t(" ]; then"),
    t({"", ""}),
    i(2),
    t({"", "fi"}),
  }),
})

-- nvim-cmp
local cmp = require("cmp")
local luasnip = require("luasnip")
local lspkind = require("lspkind")

cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ["<C-j>"] = cmp.mapping.select_next_item(),
    ["<C-k>"] = cmp.mapping.select_prev_item(),
    ["<C-d>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<C-e>"] = cmp.mapping.abort(),
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { "i", "s" }),
    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { "i", "s" }),
  }),
  sources = cmp.config.sources({
    { name = "luasnip" },
    { name = "nvim_lsp" },
    { name = "buffer" },
    { name = "path" },
    { name = "emoji" },
  }),
  window = {
    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },
  experimental = {
    ghost_text = false,
  },
})

-- LuaSnip
require("luasnip.loaders.from_vscode").lazy_load()

-- Mason
require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = { "pyright", "ts_ls", "clangd", "gopls", "html", "bashls", "zls" },
  automatic_installation = true,
})

-- LSP
local lspconfig = require("lspconfig")
lspconfig.pyright.setup{}
lspconfig.clangd.setup{}
lspconfig.html.setup{}
lspconfig.bashls.setup{}
lspconfig.zls.setup{}

-- Auto Pairs
require("nvim-autopairs").setup{}

-- Treesitter
require("nvim-treesitter.configs").setup {
  ensure_installed = { "lua", "python", "html", "css" },
  highlight = { enable = true },
  indent = { enable = true },
  textobjects = { enable = true },
}

-- Telescope
require("telescope").setup{
  defaults = {
    mappings = {
      i = {
        ["<C-j>"] = require("telescope.actions").move_selection_next,
        ["<C-k>"] = require("telescope.actions").move_selection_previous,
      },
    },
  },
}

-- Noice
require("noice").setup({
  lsp = {
    progress = {
      enabled = true,
      format = "lsp_progress",
      format_done = "lsp_progress_done",
      throttle = 1000 / 30,
      view = "notify",
    },
  },
  presets = {
    command_palette = true,
    long_message_to_split = true,
    inc_rename = false,
    lsp_doc_border = false,
  },
})

-- LuaLine
require("lualine").setup({
  options = { theme = "catppuccin" },
  sections = {
    lualine_c = { "filename" },
    lualine_x = { "encoding", "fileformat", "filetype" },
  },
})

-- Catppuccin
require("catppuccin").setup {
  color_overrides = {
    all = {
      base = "#000000",
      mantle = "#000000",
      crust = "#000000",
    },
  },
}

-- Nvim Tree
require("nvim-tree").setup({
  sort = {
    sorter = "case_sensitive",
  },
  view = {
    width = 30,
  },
  renderer = {
    group_empty = true,
  },
  filters = {
    dotfiles = true,
  },
})

local keymap = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }
vim.keymap.set("n", "<C-n>", ":NvimTreeToggle<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<Space>e", function()
  vim.cmd("wincmd p")
end, { noremap = true, silent = true })


-- vim.* settings
vim.cmd.colorscheme "catppuccin"
vim.g.did_load_filetypes = 1
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.opt.signcolumn = "yes"
vim.opt.relativenumber = false
vim.opt.number = true
vim.opt.syntax = 'on'
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.clipboard = "unnamedplus"
vim.g.mapleader = ' '
vim.cmd.set "timeout timeoutlen=3000 ttimeoutlen=100"
vim.g.vimtex_view_method = 'zathura'
vim.opt.wrap = false
vim.opt.whichwrap:append "<>[]hl"
