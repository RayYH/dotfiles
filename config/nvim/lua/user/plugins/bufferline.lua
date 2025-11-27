local fn = vim.fn

-- Offsets -----------------------------------------------------

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
            -- show current working directory shortened with ~
            return " " .. fn.fnamemodify(fn.getcwd(), ":~")
        end,
        highlight = "StatusLineComment",
        text_align = "left",
    },
}

-- Custom areas (left/right "statusline" in bufferline) --------

local custom_areas = {
    left = function()
        return {
            { text = " " },
        }
    end,

    right = function()
        return {
            -- use a highlight group instead of hard-coded color
            {
                text = " " .. os.date("%H:%M") .. " ",
                highlight = "StatusLine",
            },
        }
    end,
}

-- Highlights --------------------------------------------------

local active_hl = {
    bg = { attribute = "bg", highlight = "StatusLine" },
}

local inactive_hl = {
    bg = { attribute = "bg", highlight = "BufferlineInactive" },
}

local highlights = {
    fill = active_hl,
    separator = { fg = active_hl.bg, bg = inactive_hl.bg },
    separator_selected = { fg = active_hl.bg },
    separator_visible = { fg = active_hl.bg },
    trunc_marker = { bg = active_hl.bg },

    tab = inactive_hl,
    tab_separator = { fg = active_hl.bg, bg = inactive_hl.bg },
    tab_separator_selected = { fg = active_hl.bg },
    tab_close = inactive_hl,
}

-- apply same inactive style for many groups programmatically
local inactive_keys = {
    "background",
    "close_button",
    "diagnostic",
    "diagnostic_visible",
    "modified",
    "modified_visible",
    "hint",
    "hint_visible",
    "info",
    "info_visible",
    "warning",
    "warning_visible",
    "error",
    "error_visible",
    "hint_diagnostic",
    "hint_diagnostic_visible",
    "info_diagnostic",
    "info_diagnostic_visible",
    "warning_diagnostic",
    "warning_diagnostic_visible",
    "error_diagnostic",
    "error_diagnostic_visible",
    "duplicate",
    "duplicate_visible",
}

for _, key in ipairs(inactive_keys) do
    highlights[key] = inactive_hl
end

-- Plugin spec -------------------------------------------------

return {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = { "nvim-tree/nvim-web-devicons" },

    -- lazy-load when buffers exist
    event = { "BufReadPost", "BufNewFile" },

    opts = {
        options = {
            indicator = { icon = " " },
            show_close_icon = false,
            buffer_close_icon = "󰅖",

            tab_size = 0,
            max_name_length = 30,

            offsets = offsets,
            hover = { enabled = true, delay = 0, reveal = { "close" } },
            separator_style = "slant",
            modified_icon = "",
            custom_areas = custom_areas,

            diagnostics_indicator = function(count, level)
                local icon = level:match("error") and " " or " "
                return icon .. count
            end,
        },
        highlights = highlights,
    },
}
