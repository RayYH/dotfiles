local offsets = {
    {
        filetype = "NvimTree",
        text = "  Files",
        highlight = "StatusLine",
        text_align = "left",
    },
    {
        filetype = "neo-tree",
        text = function()
            return " " .. vim.fn.fnamemodify(vim.fn.getcwd(), ":~")
        end,
        highlight = "StatusLineComment",
        text_align = "left",
    },
}

local custom_areas = {
    left = function()
        return { { text = " " } }
    end,
    right = function()
        return { { text = " " .. os.date("%H:%M") .. " ", fg = "#8fff6d" } }
    end,
}

local active_hl = {
    bg = { attribute = "bg", highlight = "StatusLine" },
}

local inactive_hl = {
    bg = { attribute = "bg", highlight = "BufferlineInactive" },
}

local highlights = {
    fill = active_hl,
    background = inactive_hl,
    close_button = inactive_hl,
    diagnostic = inactive_hl,
    diagnostic_visible = inactive_hl,
    modified = inactive_hl,
    modified_visible = inactive_hl,
    hint = inactive_hl,
    hint_visible = inactive_hl,
    info = inactive_hl,
    info_visible = inactive_hl,
    warning = inactive_hl,
    warning_visible = inactive_hl,
    error = inactive_hl,
    error_visible = inactive_hl,
    hint_diagnostic = inactive_hl,
    hint_diagnostic_visible = inactive_hl,
    info_diagnostic = inactive_hl,
    info_diagnostic_visible = inactive_hl,
    warning_diagnostic = inactive_hl,
    warning_diagnostic_visible = inactive_hl,
    error_diagnostic = inactive_hl,
    error_diagnostic_visible = inactive_hl,
    duplicate = inactive_hl,
    duplicate_visible = inactive_hl,
    separator = { fg = active_hl.bg, bg = inactive_hl.bg },
    separator_selected = { fg = active_hl.bg },
    separator_visible = { fg = active_hl.bg },
    trunc_marker = { bg = active_hl.bg },
    tab = inactive_hl,
    tab_separator = { fg = active_hl.bg, bg = inactive_hl.bg },
    tab_separator_selected = { fg = active_hl.bg },
    tab_close = { bg = "yellow" },
}

return {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = "nvim-tree/nvim-web-devicons",
    opts = {
        options = {
            indicator = { icon = " " },
            show_close_icon = false,
            tab_size = 0,
            max_name_length = 30,
            buffer_close_icon = "󰅖",
            offsets = offsets,
            hover = { enabled = true, delay = 0, reveal = { "close" } },
            separator_style = "slant",
            modified_icon = "",
            custom_areas = custom_areas,
            diagnostics_indicator = function(count, level, _, _)
                local icon = level:match("error") and " " or " "
                return icon .. count
            end,
        },
        highlights = highlights,
    },
}
