---@type LazySpec
return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = function(_, opts)
      opts.filesystem = opts.filesystem or {}
      opts.filesystem.filtered_items = opts.filesystem.filtered_items or {}

      opts.filesystem.filtered_items.hide_dotfiles = false
      opts.filesystem.filtered_items.always_show = opts.filesystem.filtered_items.always_show or {}

      if not vim.tbl_contains(opts.filesystem.filtered_items.always_show, ".artifacts") then
        table.insert(opts.filesystem.filtered_items.always_show, ".artifacts")
      end

      return opts
    end,
  },
}
