local opt = vim.opt

-- Undo Settings
opt.swapfile = false
opt.backup = false
opt.undodir = vim.env.HOME .. "/.nvim/undodir"

-- Increase Scroll Off
opt.scrolloff = 8

-- Mini Pairs Disabled
vim.g.minipairs_disable = true

-- Tab Options
opt.tabstop = 4
opt.softtabstop = 4
opt.shiftwidth = 4

-- spelling
opt.spell = true
opt.spelllang = "en_us"
