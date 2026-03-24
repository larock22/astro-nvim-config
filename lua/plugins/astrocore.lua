
-- AstroCore provides a central place to modify mappings, vim options, autocommands, and more!
-- Configuration documentation can be found with `:h astrocore`
-- NOTE: We highly recommend setting up the Lua Language Server (`:LspInstall lua_ls`)
--       as this provides autocomplete and documentation while editing

local function git_root()
  local start = vim.fn.expand "%:p:h"
  if start == nil or start == "" then start = vim.loop.cwd() end
  local root = vim.fn.systemlist({ "git", "-C", start, "rev-parse", "--show-toplevel" })
  if vim.v.shell_error ~= 0 or #root == 0 then return nil end
  return root[1]
end

local function find_git_base(root)
  local targets = { "main", "master", "origin/main", "origin/master" }
  for _, target in ipairs(targets) do
    vim.fn.system({ "git", "-C", root, "rev-parse", "--verify", "--quiet", target })
    if vim.v.shell_error == 0 then return target end
  end
end

local function open_diff_buffer(cmd, title, root)
  local output = vim.fn.systemlist(cmd)
  local exit_code = vim.v.shell_error

  if exit_code ~= 0 then
    vim.notify(("Git diff failed (%d): %s"):format(exit_code, table.concat(output, "\n")), vim.log.levels.ERROR)
    return
  end

  if #output == 0 then
    vim.notify(("No diff to show (%s)"):format(root), vim.log.levels.INFO)
    return
  end

  vim.cmd "new"
  vim.api.nvim_buf_set_name(0, title)
  vim.bo.buftype = "nofile"
  vim.bo.bufhidden = "wipe"
  vim.bo.swapfile = false
  vim.bo.filetype = "diff"
  vim.bo.modifiable = true
  vim.api.nvim_buf_set_lines(0, 0, -1, false, output)
  vim.bo.modifiable = false
  vim.bo.readonly = true
  vim.keymap.set("n", "q", "<cmd>bd!<cr>", { buffer = 0, silent = true, desc = "Close diff buffer" })
end

local function git_diff_worktree()
  local root = git_root()
  if not root then
    vim.notify("Not in a git repository", vim.log.levels.WARN)
    return
  end
  open_diff_buffer({ "git", "-C", root, "--no-pager", "diff" }, "git-diff-working-tree", root)
end

local function git_diff_base()
  local root = git_root()
  if not root then
    vim.notify("Not in a git repository", vim.log.levels.WARN)
    return
  end
  local base = find_git_base(root)
  if not base then
    vim.notify("Could not find main/master branch", vim.log.levels.WARN)
    return
  end
  open_diff_buffer({ "git", "-C", root, "--no-pager", "diff", base }, "git-diff-" .. base, root)
end

local function git_diffview_base()
  local root = git_root()
  if not root then
    vim.notify("Not in a git repository", vim.log.levels.WARN)
    return
  end
  local base = find_git_base(root)
  if not base then
    vim.notify("Could not find main/master branch", vim.log.levels.WARN)
    return
  end
  vim.cmd("DiffviewOpen " .. base)
end

---@type LazySpec
return {
  "AstroNvim/astrocore",
  init = function()
    if vim.fn.exists ":GitDiff" == 0 then
      vim.api.nvim_create_user_command("GitDiff", git_diff_base, {
        desc = "Open git diff vs main/master in a scratch buffer",
      })
    end
    if vim.fn.exists ":GitDiffBase" == 0 then
      vim.api.nvim_create_user_command("GitDiffBase", git_diff_base, {
        desc = "Open git diff vs main/master in a scratch buffer",
      })
    end
    if vim.fn.exists ":GitDiffView" == 0 then
      vim.api.nvim_create_user_command("GitDiffView", git_diffview_base, {
        desc = "Open side-by-side diff view vs main/master",
      })
    end
  end,
  ---@type AstroCoreOpts
  opts = {
    -- Configure core features of AstroNvim
    features = {
      large_buf = { size = 1024 * 256, lines = 10000 }, -- set global limits for large files for disabling features like treesitter
      autopairs = true, -- enable autopairs at start
      cmp = true, -- enable completion at start
      diagnostics = { virtual_text = true, virtual_lines = false }, -- diagnostic settings on startup
      highlighturl = true, -- highlight URLs at start
      notifications = true, -- enable notifications at start
    },
    -- Diagnostics configuration (for vim.diagnostics.config({...})) when diagnostics are on
    diagnostics = {
      virtual_text = true,
      underline = true,
    },
    -- passed to `vim.filetype.add`
    filetypes = {
      -- see `:h vim.filetype.add` for usage
      extension = {
        foo = "fooscript",
      },
      filename = {
        [".foorc"] = "fooscript",
      },
      pattern = {
        [".*/etc/foo/.*"] = "fooscript",
      },
    },
    -- vim options can be configured here
    options = {
      opt = { -- vim.opt.<key>
        relativenumber = false, -- sets vim.opt.relativenumber
        number = true, -- sets vim.opt.number
        spell = false, -- sets vim.opt.spell
        signcolumn = "yes", -- sets vim.opt.signcolumn to yes
        wrap = true, -- sets vim.opt.wrap
        cursorline = true, -- highlight current line
      },
      g = { -- vim.g.<key>
        -- configure global vim variables (vim.g)
        -- NOTE: `mapleader` and `maplocalleader` must be set in the AstroNvim opts or before `lazy.setup`
        -- This can be found in the `lua/lazy_setup.lua` file
      },
    },
    -- Mappings can be configured through AstroCore as well.
    -- NOTE: keycodes follow the casing in the vimdocs. For example, `<Leader>` must be capitalized
    mappings = {
      -- first key is the mode
      n = {
        -- second key is the lefthand side of the map

        -- navigate buffer tabs
        ["]b"] = { function() require("astrocore.buffer").nav(vim.v.count1) end, desc = "Next buffer" },
        ["[b"] = { function() require("astrocore.buffer").nav(-vim.v.count1) end, desc = "Previous buffer" },

        -- mappings seen under group name "Buffer"
        ["<Leader>bd"] = {
          function()
            require("astroui.status.heirline").buffer_picker(
              function(bufnr) require("astrocore.buffer").close(bufnr) end
            )
          end,
          desc = "Close buffer from tabline",
        },

        -- tables with just a `desc` key will be registered with which-key if it's installed
        -- this is useful for naming menus
        -- ["<Leader>b"] = { desc = "Buffers" },
        ["<Leader>g"] = { desc = "Git" },
        ["<Leader>gd"] = { git_diffview_base, desc = "Git diffview vs main/master" },
        ["<Leader>gm"] = { git_diff_base, desc = "Git diff vs main/master" },
        ["<Leader>gw"] = { git_diff_worktree, desc = "Git diff (working tree)" },
        ["<Leader>gq"] = { "<cmd>DiffviewClose<cr>", desc = "Git diffview close" },

        -- Window splits
        ["<Leader>wv"] = { "<cmd>vsplit<cr>", desc = "Vertical split" },
        ["<Leader>ws"] = { "<cmd>split<cr>", desc = "Horizontal split" },
        ["<Leader>wf"] = {
          function()
            vim.cmd("vsplit")
            require("telescope.builtin").find_files()
          end,
          desc = "Vertical split + find file"
        },
        ["<Leader>wh"] = {
          function()
            vim.cmd("split")
            require("telescope.builtin").find_files()
          end,
          desc = "Horizontal split + find file"
        },

        -- setting a mapping to false will disable it
        -- ["<C-S>"] = false,
      },
      i = {},
      t = {},
    },
  },
}
