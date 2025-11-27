-- lua/user/plugins/neo-tree.lua
local function system_open(path)
    -- Slightly more portable "open this file/folder" helper
    if vim.fn.has("macunix") == 1 then
        vim.fn.jobstart({ "open", path }, { detach = true })
    elseif vim.fn.has("unix") == 1 then
        vim.fn.jobstart({ "xdg-open", path }, { detach = true })
    else
        -- Fallback: just echo the path so you notice it
        vim.notify("No system-open handler for this OS: " .. path, vim.log.levels.WARN)
    end
end

return {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",

    -- Lazy-load via key or command
    keys = {
        {
            "<leader>nt",
            "<cmd>Neotree reveal toggle<CR>",
            mode = "n",
            desc = "Toggle Neo-tree file explorer",
        },
    },
    cmd = { "Neotree" },

    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-tree/nvim-web-devicons",
        "MunifTanjim/nui.nvim",
        {
            "s1n7ax/nvim-window-picker",
            opts = {
                filter_rules = {
                    autoselect_one = true,
                    include_current_win = false,
                    bo = {
                        filetype = { "neo-tree", "neo-tree-popup", "notify" },
                        buftype = { "terminal", "quickfix" },
                    },
                },
                highlights = {
                    statusline = {
                        focused = { bg = "#414868" },
                        unfocused = { bg = "#414868" },
                    },
                },
            },
        },
    },

    opts = {
        close_if_last_window = true,
        hide_root_node = true,

        sources = {
            "filesystem",
            "buffers",
            "git_status",
            "document_symbols",
        },

        source_selector = {
            winbar = true,
            statusline = false,
            separator = { left = "", right = "" },
            show_separator_on_edge = false,
            highlight_tab = "SidebarTabInactive",
            highlight_tab_active = "SidebarTabActive",
            highlight_background = "StatusLine",
            highlight_separator = "SidebarTabInactiveSeparator",
            highlight_separator_active = "SidebarTabActiveSeparator",
        },

        enable_opened_markers = true,

        default_component_configs = {
            indent = { padding = 0 },
            name = {
                use_git_status_colors = false,
                highlight_opened_files = true,
            },
        },

        filesystem = {
            filtered_items = {
                hide_dotfiles = false,
                hide_by_name = { ".git" },
            },
            follow_current_file = { enabled = true },
            group_empty_dirs = false,
            window = {
                mappings = {
                    ["oo"] = "system_open",
                },
            },
        },

        commands = {
            system_open = function(state)
                local node = state.tree:get_node()
                if not node then
                    return
                end
                local path = node:get_id()
                system_open(path)
            end,
        },
    },
}