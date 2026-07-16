-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set
local opts = { noremap = true, silent = true }

map("n", ";", ":", { desc = "CMD enter command mode" })

map({ "n", "v" }, "l", "j")
map({ "n", "v" }, "j", "l")

map({ "n", "i", "v", "t" }, "<C-w>h", "<C-w>k", opts)
map({ "n", "i", "v", "t" }, "<C-w>l", "<C-w>j", opts)
map({ "n", "i", "v", "t" }, "<C-w>j", "<C-w>h", opts)
map({ "n", "i", "v", "t" }, "<C-w>k", "<C-w>l", opts)

-- map({ "n", "i", "v", "t" }, "<C-h>", "<C-k>", opts)
-- map({ "n", "i", "v", "t" }, "<C-l>", "<C-j>", opts)
-- map({ "n", "i", "v", "t" }, "<C-j>", "<C-h>", opts)
-- map({ "n", "i", "v", "t" }, "<C-k>", "<C-l>", opts)

-- 只让 y / p 使用系统剪贴板
map({ "n", "v" }, "y", '"+y')
map({ "n", "v" }, "p", '"+p')
map({ "n", "v" }, "P", '"+P')
map({ "n", "v" }, "d", '"_d')

map({ "n", "i", "v" }, "<F2>", "<leader>cr", { remap = true, desc = "LSP rename" }) -- 重命名符号，等同于快捷键 `<leader>cr`

-- 终端
map({ "n", "i", "v", "t" }, "<A-i>", function()
  Snacks.terminal.toggle()
end)

-- 保存与重做
map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>", { desc = "file save" })
map({ "n", "i", "v" }, "<C-z>", "<cmd> undo <cr>", { desc = "history undo" })

local function toggle_comment(cmd)
  vim.cmd("normal " .. cmd)
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local line_count = vim.api.nvim_buf_line_count(0)
  if row < line_count then
    vim.api.nvim_win_set_cursor(0, { row + 1, col })
  end
end

map({ "n", "i" }, "<c-/>", function()
  toggle_comment("gcc")
end, { desc = "comment toggle", noremap = true })
-- map("i", "<C-_>", toggle_comment("<Esc>gcc^i"), { desc = "comment toggle", remap = true })
-- map("v", "<C-_>", toggle_comment("gc"), { desc = "comment toggle", remap = true })

map("n", "dw", [["_diw]], { noremap = true })
map("n", 'd"', [["_di"]], { noremap = true })
map("n", "d'", [["_di']], { noremap = true })
map("n", "d(", [["_di(]], { noremap = true })
map("n", "d)", [["_di)]], { noremap = true })
map("n", "d{", [["_di{]], { noremap = true })
map("n", "d}", [["_di}]], { noremap = true })
map("n", "d[", '"_di[', { noremap = true })
map("n", "d]", '"_di]', { noremap = true })

-- 剪切
map("v", "d", '"+d', opts)

map("n", "x", '"_x', { noremap = true })

-- 使用tab切换
vim.keymap.set("i", "<Tab>", function()
  local blink = require("blink.cmp")
  if blink.is_menu_visible() then
    blink.select_next()
  elseif vim.snippet.active({ direction = 1 }) then
    vim.snippet.jump(1)
  else
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Tab>", true, true, true), "n", false)
  end
end, { silent = true, noremap = true })

vim.keymap.set("i", "<S-Tab>", function()
  local blink = require("blink.cmp")
  if blink.is_menu_visible() then
    blink.select_prev()
  elseif vim.snippet.active({ direction = -1 }) then
    vim.snippet.jump(-1)
  else
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<S-Tab>", true, true, true), "n", false)
  end
end, { silent = true, noremap = true })

map("n", "<Tab>", "<cmd>BufferLineCycleNext<cr>", { desc = "buffer goto next" })
map("n", "<S-Tab>", "<cmd>BufferLineCyclePrev<cr>", { desc = "buffer goto prev" })
map("n", "<leader>x", "<cmd>bd<cr>", { desc = "buffer close" })

-- 光标后插入一个空格
map("n", "<leader>a", "a<Space><Esc>h", { desc = "Insert a space after the cursor" })
map("n", "<leader>\\", "a<Space><Esc>h", { desc = "Insert a space after the cursor" })
