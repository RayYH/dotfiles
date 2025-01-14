-- Helper function to check if there are words before the cursor
local has_words_before = function()
    local _, col = unpack(vim.api.nvim_win_get_cursor(0))
    if col == 0 then
        return false
    end
    local current_line = vim.api.nvim_get_current_line()
    return current_line:sub(col, col):match("%s") == nil
end

-- Helper function to remove leading whitespace
local function ltrim(s)
    return s:match("^%s*(.*)")
end

return {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
        "neovim/nvim-lspconfig",
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-nvim-lsp-signature-help",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-cmdline",
        "hrsh7th/nvim-cmp",
        "L3MON4D3/LuaSnip",
        "saadparwaiz1/cmp_luasnip",
        "onsails/lspkind-nvim",
    },

    config = function()
        --- @type any
        local cmp = require("cmp")
        local luasnip = require("luasnip")
        local lspkind = require("lspkind")

        require("luasnip.loaders.from_snipmate").lazy_load()
        require("luasnip.loaders.from_lua").load({
            paths = "~/.config/nvim/snippets",
        })

        cmp.setup({
            preselect = cmp.PreselectMode.None,
            snippet = {
                expand = function(args)
                    luasnip.lsp_expand(args.body)
                end,
            },

            window = { completion = { col_offset = -2 } },
            formatting = {
                fields = { "kind", "abbr", "menu" },
                format = lspkind.cmp_format({
                    mode = "symbol_text",
                    before = function(_, vim_item)
                        vim_item.abbr = ltrim(vim_item.abbr)
                        return vim_item
                    end,
                }),
            },
            mapping = {
                ["<Tab>"] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.select_next_item()
                    elseif luasnip.expand_or_jumpable() then
                        luasnip.expand_or_jump()
                    elseif has_words_before() then
                        cmp.complete()
                    else
                        fallback()
                    end
                end, { "i", "s" }),
                ["<S-Tab>"] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.select_prev_item()
                    elseif luasnip.jumpable(-1) then
                        luasnip.jump(-1)
                    else
                        fallback()
                    end
                end, { "i", "s" }),
                ["<CR>"] = cmp.mapping.confirm({ select = false }),
            },

            sources = {
                { name = "nvim_lsp" },
                { name = "nvim_lsp_signature_help" },
                { name = "luasnip" },
                { name = "buffer" },
                { name = "path" },
            },
        })

        cmp.setup.cmdline("/", {
            mapping = cmp.mapping.preset.cmdline(),
            sources = { { name = "buffer" } },
        })

        cmp.setup.cmdline(":", {
            mapping = cmp.mapping.preset.cmdline(),
            sources = { { name = "path" }, { name = "cmdline" } },
        })
    end,
}
