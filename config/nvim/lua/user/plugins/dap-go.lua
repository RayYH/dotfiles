return {
    "leoluz/nvim-dap-go",
    ft = { "go", "gomod", "gowork" }, -- only load when editing Go-related files

    dependencies = {
        "mfussenegger/nvim-dap",
    },

    -- You can tweak dap-go’s options here later
    opts = {
        -- example if you want to customize delve later:
        -- delve = {
        --     initialize_timeout_sec = 20,
        --     port = "${port}",
        -- },
    },

    config = function(_, opts)
        local ok, dap_go = pcall(require, "dap-go")
        if not ok then
            return
        end
        dap_go.setup(opts)
    end,
}