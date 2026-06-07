-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set
local opts = { noremap = true, silent = true }

map("n", ";", ":", { desc = "CMD enter command mode" })

map({ "n", "v" }, "l", "j")
map({ "n", "v" }, "j", "l")

vim.keymap.set("n", "<C-w>h", "<C-w>k", opts)
vim.keymap.set("n", "<C-w>l", "<C-w>j", opts)
vim.keymap.set("n", "<C-w>j", "<C-w>h", opts)
vim.keymap.set("n", "<C-w>k", "<C-w>l", opts)

-- 只让 y / p 使用系统剪贴板
vim.keymap.set({ "n", "v" }, "y", '"+y')
vim.keymap.set({ "n", "v" }, "p", '"+p')
vim.keymap.set({ "n", "v" }, "P", '"+P')
vim.keymap.set({ "n", "v" }, "d", '"_d')

map({ "n", "i", "v" }, "<F2>", function()
  if vim.bo.filetype == "NvimTree" then
    -- 如果在文件浏览器中，调用 NvimTree 的重命名功能
    require("nvim-tree.api").fs.rename()
  else
    require("nvchad.lsp.renamer")()
  end
end, { desc = "LSP rename" }) -- 重命名符号，等同于 NvChad 的快捷键 `<leader>ra`

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

map({ "n", "i" }, "<c-_>", function()
  toggle_comment("gcc")
end, { desc = "comment toggle", remap = true })
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
map("v", "d", '"+d', { noremap = true, silent = true })

map("n", "x", '"_x', { noremap = true })
