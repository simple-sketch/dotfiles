---@type LazySpec
return {
    "folke/snacks.nvim",
    -- Turn off the snacks explorer module; yazi.nvim is the file explorer.
    opts = { explorer = { enabled = false } },
    -- Release the keys LazyVim's snacks_explorer extra claims.
    keys = {
        { "<leader>e", false },
        { "<leader>E", false },
        { "<leader>fe", false },
        { "<leader>fE", false },
    },
}
