return {
    "whatyouhide/vim-textobj-xmlattr",

    dependencies = {
        "kana/vim-textobj-user",
    },

    -- Load when editing markup where XML attributes are useful
    ft = { "xml", "html", "xhtml", "jsx", "tsx", "vue" },

    -- Also lazy-load on first use of the text objects
    keys = {
        { "ax", mode = { "o", "x" }, desc = "Outer XML attribute" },
        { "ix", mode = { "o", "x" }, desc = "Inner XML attribute" },
    },
}
