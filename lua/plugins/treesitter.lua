return {
  "nvim-treesitter/nvim-treesitter",
  lazy = false,
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter").setup({
      ensure_installed = {
        "lua", "vim", "vimdoc",
        "python", "javascript", "typescript",
        "html", "css", "json", "yaml", "toml",
        "c", "cpp", "rust", "go",
        "java", "kotlin", "swift",
        "bash", "fish",
        "markdown", "markdown_inline",
        "sql", "graphql",
        "dockerfile", "terraform",
        "regex", "comment",
      },
      highlight = { enable = true },
      indent    = { enable = true },
    })
  end,
}
