return {
  "ThePrimeagen/harpoon",
  config = function()
    local mark = require("harpoon.mark")
    local ui = require("harpoon.ui")

    vim.keymap.set("n", "<leader>m", mark.add_file, { desc = "Harpoon: [M]ark File" })
    vim.keymap.set("n", "<C-p>", ui.toggle_quick_menu, { desc = "Toggle Harpoon Menu" })

    vim.keymap.set("n", "<F25>", function()
      ui.nav_file(1)
    end, { desc = "Harpoon File 1" })
    vim.keymap.set("n", "<F26>", function()
      ui.nav_file(2)
    end, { desc = "Harpoon File 2" })
    vim.keymap.set("n", "<F27>", function()
      ui.nav_file(3)
    end, { desc = "Harpoon File 3" })
    vim.keymap.set("n", "<F28>", function()
      ui.nav_file(4)
    end, { desc = "Harpoon File 4" })
  end,
}
