# elephant-walker-custom-lua-menus

Custom Lua menus for [Walker](https://github.com/abenz1267/walker) launcher using the Elephant provider system. Provides quick access to AI CLI tools: **Goose**, **OpenCode**, **Gemini CLI**, and **TokScale**.

## Features

- **Goose**: Sessions, recipes, projects, prompts, model switching
- **OpenCode**: Sessions, projects, model switching
- **Gemini CLI**: Sessions, model switching
- **TokScale**: View daily token usage and costs by model
- Lazy-loading architecture for fast menu performance
- Desktop notifications for errors and status updates

## Requirements

- [Walker](https://github.com/abenz1267/walker) with Elephant provider enabled
- One or more AI CLI tools:
  - [Goose](https://github.com/block/goose)
  - [OpenCode](https://github.com/opencode-ai/opencode)
  - [Gemini CLI](https://github.com/google-gemini/gemini-cli)
  - [TokScale](https://github.com/voznik/tokscale) (token usage tracking)

## Installation

1. Clone or copy to your Elephant config directory:

```bash
# Clone
git clone https://github.com/voznik/elephant-walker-custom-lua-menus.git ~/.config/elephant

# Or copy specific folders
cp -r menus/goose ~/.config/elephant/menus/
cp -r menus/opencode ~/.config/elephant/menus/
cp -r menus/gemini ~/.config/elephant/menus/
cp -r menus/tokscale ~/.config/elephant/menus/
cp utils/shared.lua ~/.config/elephant/utils/
```

2. Launch Walker and search for "Goose", "OpenCode", "Gemini", or "TokScale"

## Usage

Launch Walker and type the tool name:

| Menu     | Command                            |
| -------- | ---------------------------------- |
| Goose    | `walker --provider menus:goose`    |
| OpenCode | `walker --provider menus:opencode` |
| Gemini   | `walker --provider menus:gemini`   |
| TokScale | `walker --provider menus:tokscale` |

Or simply open Walker and search for the tool name.

## Structure

```
~/.config/elephant/
├── menus/
│   ├── goose/
│   │   ├── main.lua           # Main menu
│   │   ├── sessions.lua       # Session management
│   │   ├── recipes.lua        # Recipe browser
│   │   ├── recipe_params.lua  # Recipe parameter input
│   │   ├── models.lua         # Model switching
│   │   ├── projects.lua       # Recent projects
│   │   └── prompts.lua        # Prompt library
│   ├── opencode/
│   │   ├── main.lua
│   │   ├── sessions.lua
│   │   ├── models.lua
│   │   └── projects.lua
│   ├── gemini/
│   │   ├── main.lua
│   │   ├── sessions.lua
│   │   └── models.lua
│   └── tokscale/
│       ├── main.lua           # Token usage menu
│       └── today.lua          # Today's usage breakdown
└── utils/
    └── shared.lua             # Shared helpers
```

## Customization

### Adding New Menus

Create a new `.lua` file in `menus/` with:

```lua
Name = "my_menu"
NamePretty = "My Custom Menu"
Icon = "icon-name"

dofile(os.getenv("HOME") .. "/.config/elephant/utils/shared.lua")

function GetEntries()
    return {
        { Text = "Entry 1", Actions = { default = "lua:MyAction" } },
    }
end

function MyAction()
    RunInTerminal("my-command")
end
```

### Model Configuration

Models are configured in `~/.config/goose/config.yaml`. The menu uses `sed` to update `GOOSE_PROVIDER` and `GOOSE_MODEL` values.

## License

MIT

## Acknowledgments

- [Walker](https://github.com/abenz1267/walker) - Application launcher for Wayland/X11
- [Goose](https://github.com/block/goose) - AI agent by Block
- [OpenCode](https://github.com/opencode-ai/opencode) - AI coding assistant
- [Gemini CLI](https://github.com/google-gemini/gemini-cli) - Google's Gemini CLI
