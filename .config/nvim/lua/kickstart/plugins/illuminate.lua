return {
  "RRethy/vim-illuminate",
  config = function()
    require("illuminate").configure({
      delay = 250,
      min_count_to_highlight = 1,
    })
  end,
}
