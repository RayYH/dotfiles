return {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    main = "tokyonight",

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
            local darken = util.darken
            local lighten = util.lighten

            local prompt = "#2d3149"
            local bg_dark = c.bg_dark
            local bg_dark_d85 = darken(bg_dark, 0.85, "#000000")
            local bg_dark_d75 = darken(bg_dark, 0.75, "#000000")
            local bg_dark_d98 = darken(bg_dark, 0.98, "#000000")

            -- Bufferline
            hl.BufferlineInactive = {
                bg = bg_dark,
            }
            hl.BufferlineActiveSeparator = {
                bg = c.bg,
                fg = bg_dark_d85,
            }
            hl.BufferlineInactiveSeparator = {
                bg = bg_dark,
                fg = bg_dark_d85,
            }

            -- Neo-tree
            hl.NeoTreeFileNameOpened = {
                fg = c.orange,
            }

            -- GitSigns blame
            hl.GitSignsCurrentLineBlame = {
                fg = c.comment,
            }

            -- Tabs
            hl.TabActive = {
                bg = c.bg,
            }
            hl.TabActiveSeparator = {
                bg = c.bg,
                fg = bg_dark_d85,
            }
            hl.TabInactive = {
                bg = bg_dark,
            }
            hl.TabInactiveSeparator = {
                bg = bg_dark,
                fg = bg_dark_d85,
            }

            hl.SidebarTabActive = {
                bg = bg_dark,
            }
            hl.SidebarTabActiveSeparator = {
                bg = bg_dark,
                fg = bg_dark_d85,
            }
            hl.SidebarTabInactive = {
                bg = bg_dark_d75,
                fg = c.comment,
            }
            hl.SidebarTabInactiveSeparator = {
                bg = bg_dark_d75,
                fg = bg_dark_d85,
            }

            -- Statusline
            hl.StatusLine = {
                bg = bg_dark_d98,
                fg = c.fg_dark,
            }
            hl.StatusLineComment = {
                bg = bg_dark_d85,
                fg = c.comment,
            }

            -- Line numbers
            hl.LineNrAbove = {
                fg = c.fg_gutter,
            }
            hl.LineNr = {
                fg = lighten(c.fg_gutter, 0.7),
            }
            hl.LineNrBelow = {
                fg = c.fg_gutter,
            }

            -- Messages
            hl.MsgArea = {
                bg = bg_dark_d85,
            }

            -- Spelling
            hl.SpellBad = {
                undercurl = true,
                sp = "#7F3A43",
            }

            -- Telescope
            hl.TelescopeNormal = {
                bg = bg_dark,
                fg = c.fg_dark,
            }
            hl.TelescopeBorder = {
                bg = bg_dark,
                fg = bg_dark,
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
                bg = bg_dark,
                fg = bg_dark,
            }
            hl.TelescopeResultsTitle = {
                bg = bg_dark,
                fg = bg_dark,
            }

            -- Indent-blankline (ibl)
            hl.IblIndent = {
                fg = c.bg_highlight,
            }
            hl.IblScope = {
                fg = lighten(c.bg_highlight, 0.95),
            }

            -- Copilot
            hl.CopilotSuggestion = {
                fg = c.comment,
            }
        end,
    },

    config = function(_, opts)
        require("tokyonight").setup(opts)
        vim.cmd.colorscheme("tokyonight-night")
    end,
}
