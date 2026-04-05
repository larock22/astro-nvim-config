---@type LazySpec
return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    commit = "4916d6592ede8c07973490d9322f187e07dfefac",
    lazy = false,
    build = ":TSUpdate",
    opts = {
      install_dir = vim.fn.stdpath "data" .. "/site",
    },
    config = function(_, opts)
      for _, bin in ipairs { "/opt/homebrew/bin", "/usr/local/bin" } do
        if vim.fn.executable(bin .. "/tree-sitter") == 1 then
          vim.env.PATH = bin .. ":" .. vim.env.PATH
          break
        end
      end

      require("nvim-treesitter").setup(opts)
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    commit = "93d60a475f0b08a8eceb99255863977d3a25f310",
  },
}
