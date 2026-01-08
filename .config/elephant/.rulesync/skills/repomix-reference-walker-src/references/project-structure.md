# Directory Structure

```
.github/
  ISSUE_TEMPLATE/
    bug_report.md (36 lines)
    config.yml (1 lines)
    feature_request.md (16 lines)
  workflows/
    build.yml (90 lines)
    github-releases-to-discord.yml (19 lines)
    nix_git.yml (25 lines)
    nix.yml (25 lines)
  FUNDING.yml (2 lines)
nix/
  modules/
    home-manager.nix (220 lines)
    nixos.nix (230 lines)
  package.nix (66 lines)
resources/
  themes/
    default/
      style.css (70 lines)
  config.toml (229 lines)
src/
  preview/
    mod.rs (355 lines)
  protos/
    activate.proto (14 lines)
    mod.rs (30 lines)
    providerstate.proto (15 lines)
    query.proto (46 lines)
    subscribe.proto (15 lines)
  providers/
    actionsmenu.rs (12 lines)
    archlinuxpkgs.rs (12 lines)
    bookmarks.rs (25 lines)
    calc.rs (23 lines)
    clipboard.rs (26 lines)
    default_provider.rs (10 lines)
    dmenu.rs (12 lines)
    emergency.rs (12 lines)
    files.rs (42 lines)
    mod.rs (144 lines)
    providerlist.rs (18 lines)
    symbols.rs (19 lines)
    todo.rs (23 lines)
    unicode.rs (16 lines)
  renderers/
    mod.rs (71 lines)
  state/
    mod.rs (307 lines)
  theme/
    mod.rs (146 lines)
  ui/
    mod.rs (1 lines)
    window.rs (762 lines)
  config.rs (115 lines)
  data.rs (396 lines)
  keybinds.rs (223 lines)
  main.rs (412 lines)
.gitignore (2 lines)
BREAKING.md (5 lines)
build.rs (10 lines)
Cargo.toml (28 lines)
flake.nix (55 lines)
makefile (57 lines)
README.md (212 lines)
rust-toolchain.toml (2 lines)
```
