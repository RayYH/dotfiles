local api = vim.api

return {
    "nvimdev/dashboard-nvim",
    event = "VimEnter",

    opts = {
        theme = "doom",
        config = {
            disable_move = true,
            header = {
                "",
                "",
                "",
                "███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗",
                "████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║",
                "██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║",
                "██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║",
                "██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║",
                "╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝",
                "",
                "--------------------------------------------------",
                "",
                "",
            },
            center = {
                {
                    icon = "󰚰  ",
                    desc = "Update Plugins          ",
                    key = "u",
                    keymap = "SPC f u",
                    action = "Lazy update",
                },
                {
                    icon = "  ",
                    desc = "Find file               ",
                    key = "f",
                    keymap = "SPC f f",
                    action = "Telescope find_files",
                },
                {
                    icon = "  ",
                    desc = "Recent files            ",
                    key = "r",
                    keymap = "SPC f r",
                    action = "Telescope oldfiles",
                },
                {
                    icon = "  ",
                    desc = "Find Word               ",
                    key = "g",
                    keymap = "SPC f g",
                    action = "Telescope live_grep",
                },
            },
            footer = { "" },
        },
        hide = {
            statusline = false,
            tabline = false,
            winbar = false,
        },
    },

    init = function()
        local colors = {
            DashboardHeader = "#6272a4",
            DashboardDesc   = "#f8f8f2",
            DashboardIcon   = "#bd93f9",
            DashboardKey    = "#6272a4",
            DashboardFooter = "#6272a4",
        }

        for group, fg in pairs(colors) do
            api.nvim_set_hl(0, group, { fg = fg })
        end
    end,
}