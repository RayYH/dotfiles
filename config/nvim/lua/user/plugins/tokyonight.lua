return {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {
        transparent = true,
        styles = {
            sidebars = "transparent",
            floats = "transparent",
        },
        on_colors = function(colors)
            colors.gitSigns = {
                add = colors.teal,
                change = colors.purple,
                delete = colors.red,
            }
        end,
        on_highlights = function(hl, c)
            local util = require("tokyonight.util")
            local prompt = "#2d3149"

            hl.BufferlineInactive = {
                bg = c.bg_dark,
            }
            hl.BufferlineActiveSeparator = {
                bg = c.bg,
                fg = util.darken(c.bg_dark, 0.85, "#000000"),
            }
            hl.BufferlineInactiveSeparator = {
                bg = c.bg_dark,
                fg = util.darken(c.bg_dark, 0.85, "#000000"),
            }

            hl.NeoTreeFileNameOpened = {
                fg = c.orange,
            }

            hl.GitSignsCurrentLineBlame = {
                fg = c.comment,
            }

            -- Tabs
            hl.TabActive = {
                bg = c.bg,
            }
            hl.TabActiveSeparator = {
                bg = c.bg,
                fg = util.darken(c.bg_dark, 0.85, "#000000"),
            }
            hl.TabInactive = {
                bg = c.bg_dark,
            }
            hl.TabInactiveSeparator = {
                bg = c.bg_dark,
                fg = util.darken(c.bg_dark, 0.85, "#000000"),
            }

            hl.SidebarTabActive = {
                bg = c.bg_dark,
            }
            hl.SidebarTabActiveSeparator = {
                bg = c.bg_dark,
                fg = util.darken(c.bg_dark, 0.85, "#000000"),
            }
            hl.SidebarTabInactive = {
                bg = util.darken(c.bg_dark, 0.75, "#000000"),
                fg = c.comment,
            }
            hl.SidebarTabInactiveSeparator = {
                bg = util.darken(c.bg_dark, 0.75, "#000000"),
                fg = util.darken(c.bg_dark, 0.85, "#000000"),
            }

            hl.StatusLine = {
                bg = util.darken(c.bg_dark, 0.98, "#000000"),
                fg = c.fg_dark,
            }
            hl.StatusLineComment = {
                bg = util.darken(c.bg_dark, 0.85, "#000000"),
                fg = c.comment,
            }

            hl.LineNrAbove = {
                fg = c.fg_gutter,
            }
            hl.LineNr = {
                fg = util.lighten(c.fg_gutter, 0.7),
            }
            hl.LineNrBelow = {
                fg = c.fg_gutter,
            }

            hl.MsgArea = {
                bg = util.darken(c.bg_dark, 0.85, "#000000"),
            }

            -- Spelling
            hl.SpellBad = {
                undercurl = true,
                sp = "#7F3A43",
            }

            -- Telescope
            hl.TelescopeNormal = {
                bg = c.bg_dark,
                fg = c.fg_dark,
            }
            hl.TelescopeBorder = {
                bg = c.bg_dark,
                fg = c.bg_dark,
            }
            hl.TelescopePromptNormal = {
                bg = prompt,
            }
            hl.TelescopePromptBorder = {
                bg = prompt,
                fg = prompt,
            }
            hl.TelescopePromptTitle = {
                bg = c.bg,
                fg = c.fg_dark,
            }
            hl.TelescopePreviewTitle = {
                bg = c.bg_dark,
                fg = c.bg_dark,
            }
            hl.TelescopeResultsTitle = {
                bg = c.bg_dark,
                fg = c.bg_dark,
            }

            -- Indent
            hl.IblIndent = {
                fg = c.bg_highlight,
            }
            hl.IblScope = {
                fg = util.lighten(c.bg_highlight, 0.95),
            }

            -- Copilot
            hl.CopilotSuggestion = {
                fg = c.comment,
            }
        end,
    },
    config = function(_, opts)
        require("tokyonight").setup(opts)

        vim.cmd("colorscheme tokyonight-night")
    end,
}
