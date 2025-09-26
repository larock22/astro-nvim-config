-- load defaults i.e lua_lsp
require("nvchad.configs.lspconfig").defaults()

local lspconfig = require "lspconfig"

-- Language servers for Python, JavaScript/TypeScript, Go, Rust, C/C++
local servers = { 
  "html", 
  "cssls",
  "ruff",   -- Python (replaces pyright)
  "ts_ls",  -- TypeScript/JavaScript
  "gopls",  -- Go
  "rust_analyzer",  -- Rust
  "clangd",  -- C/C++
}
local nvlsp = require "nvchad.configs.lspconfig"

-- lsps with default config
for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    on_attach = nvlsp.on_attach,
    on_init = nvlsp.on_init,
    capabilities = nvlsp.capabilities,
  }
end

-- Additional configuration for specific servers
lspconfig.ruff.setup {
  on_attach = nvlsp.on_attach,
  on_init = nvlsp.on_init,
  capabilities = nvlsp.capabilities,
  settings = {
    args = {
      "--extend-select",
      "E,F,W,I,N,D",  -- Enable specific rule groups
      "--ignore",
      "D203,D213",    -- Ignore some docstring rules
      "--line-length",
      "88",
    },
  },
}

lspconfig.gopls.setup {
  on_attach = nvlsp.on_attach,
  on_init = nvlsp.on_init,
  capabilities = nvlsp.capabilities,
  settings = {
    gopls = {
      analyses = {
        unusedparams = true,
      },
      staticcheck = true,
    },
  },
}

lspconfig.rust_analyzer.setup {
  on_attach = nvlsp.on_attach,
  on_init = nvlsp.on_init,
  capabilities = nvlsp.capabilities,
  settings = {
    ["rust-analyzer"] = {
      cargo = {
        allFeatures = true,
      },
      checkOnSave = {
        command = "clippy",
      },
    },
  },
}
