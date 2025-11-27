local ok_lazy, lazy_status = pcall(require, "lazy.status")

local function lsp_client_count()
    -- Only count clients attached to the current buffer
    local clients = vim.lsp.get_clients({ bufnr = 0 })
    return "󰅭 " .. tostring(#clients)
end

local function indent_info()
    local sw = vim.bo.shiftwidth
    if sw == 0 then
        sw = vim.bo.tabstop
    end
    local icon = vim.bo.expandtab and "␠" or "⇥"
    return string.format("%s %d", icon, sw or 0)
end

local function lazy_updates()
    if not ok_lazy then
        return ""
    end
    return lazy_status.updates()
end

local function has_lazy_updates()
    return ok_lazy and lazy_status.has_updates()
end

return {
    "nvim-lualine/lualine.nvim",

    -- Don't force eager load; this is perfect for VeryLazy
    event = "VeryLazy",

    -- Let lazy.nvim know which module to pass opts to
    main = "lualine",

    dependencies = {
        "arkav/lualine-lsp-progress",
        "nvim-tree/nvim-web-devicons",
    },

    opts = {
        options = {
            section_separators = "",
            component_separators = "",
            globalstatus = true,
            theme = "auto",
        },

        sections = {
            lualine_a = { "mode" },

            lualine_b = {
                "branch",
                {
                    "diff",
                    symbols = {
                        added = " ",
                        modified = " ",
                        removed = " ",
                    },
                },
                lsp_client_count,
                { "diagnostics", sources = { "nvim_diagnostic" } },
            },

            lualine_c = {
                "filename",
                "lsp_progress",
            },

            lualine_x = {
                {
                    lazy_updates,
                    cond = has_lazy_updates,
                    color = { fg = "#ff9e64" },
                },
            },

            lualine_y = {
                "filetype",
                "encoding",
                "fileformat",
                indent_info, -- previously a string, now a working component
            },

            lualine_z = {
                "searchcount",
                "selectioncount",
                "location",
                "progress",
            },
        },
    },
}