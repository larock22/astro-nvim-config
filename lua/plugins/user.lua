---@type LazySpec
return {
  {
    "scottmckendry/cyberdream.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      transparent = true,
      italic_comments = true,
    },
    config = function(_, opts)
      vim.o.termguicolors = true
      require("cyberdream").setup(opts)
    end,
  },
}
