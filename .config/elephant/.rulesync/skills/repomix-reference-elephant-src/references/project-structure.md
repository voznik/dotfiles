# Directory Structure

```
.github/
  workflows/
    build.yml (208 lines)
    github-releases-to-discord.yml (19 lines)
    update-vendor-hash.yml (30 lines)
  changelog_config.json (71 lines)
  FUNDING.yml (2 lines)
assets/
  elephant.service (11 lines)
cmd/
  elephant/
    elephant.go (47 lines)
internal/
  comm/
    client/
      activate.go (21 lines)
      common.go (5 lines)
      menu.go (18 lines)
      providerstate.go (25 lines)
      query.go (37 lines)
    handlers/
      activationrequesthandler.go (27 lines)
      common.go (12 lines)
      menurequesthandler.go (19 lines)
      queryrequesthandler.go (60 lines)
      staterequesthandler.go (30 lines)
      subscriberequesthandler.go (73 lines)
    comm.go (41 lines)
  install/
    install.go (34 lines)
  providers/
    1password/
      1password.go (25 lines)
      makefile (39 lines)
      README.md (25 lines)
      setup.go (54 lines)
    archlinuxpkgs/
      makefile (39 lines)
      package_gen_test.go (29 lines)
      package_gen.go (93 lines)
      package.go (23 lines)
      README.md (16 lines)
      setup.go (110 lines)
    bluetooth/
      makefile (39 lines)
      README.md (7 lines)
      setup.go (66 lines)
    bookmarks/
      makefile (39 lines)
      README.md (75 lines)
      setup.go (141 lines)
    calc/
      makefile (39 lines)
      README.md (17 lines)
      setup.go (91 lines)
    clipboard/
      makefile (39 lines)
      README.md (15 lines)
      setup.go (168 lines)
    desktopapplications/
      activate.go (53 lines)
      doc.go (10 lines)
      files.go (79 lines)
      hyprland.go (27 lines)
      makefile (39 lines)
      niri.go (41 lines)
      parser.go (74 lines)
      query.go (49 lines)
      README.md (10 lines)
      setup.go (76 lines)
    files/
      activate.go (32 lines)
      db.go (43 lines)
      file.go (8 lines)
      makefile (39 lines)
      query.go (20 lines)
      README.md (21 lines)
      setup.go (77 lines)
    menus/
      makefile (39 lines)
      README.md (206 lines)
      setup.go (74 lines)
    nirisessions/
      makefile (39 lines)
      README.md (67 lines)
      setup.go (82 lines)
    providerlist/
      makefile (39 lines)
      README.md (3 lines)
      setup.go (46 lines)
    runner/
      makefile (39 lines)
      README.md (8 lines)
      setup.go (89 lines)
    snippets/
      makefile (39 lines)
      README.md (21 lines)
      setup.go (64 lines)
    symbols/
      makefile (39 lines)
      parse.go (52 lines)
      README.md (7 lines)
      setup.go (64 lines)
    todo/
      makefile (39 lines)
      README.md (48 lines)
      setup.go (146 lines)
    unicode/
      makefile (39 lines)
      README.md (7 lines)
      setup.go (58 lines)
    websearch/
      makefile (39 lines)
      README.md (12 lines)
      setup.go (79 lines)
    windows/
      makefile (39 lines)
      README.md (3 lines)
      setup.go (75 lines)
    load.go (58 lines)
  util/
    doc.go (25 lines)
    preview.go (7 lines)
nix/
  modules/
    home-manager.nix (307 lines)
    nixos.nix (320 lines)
pkg/
  common/
    history/
      history.go (50 lines)
    wlr/
      tracker.go (6 lines)
      wlr-foreign-toplevel-management-unstable-v1.go (211 lines)
      wm.go (50 lines)
    config.go (46 lines)
    files.go (25 lines)
    fzf.go (20 lines)
    git.go (57 lines)
    menucfg.go (115 lines)
    runprefix.go (14 lines)
    terminal.go (36 lines)
    util.go (13 lines)
  pb/
    pb/
      activate.pb.go (94 lines)
      menu.pb.go (78 lines)
      providerstate.pb.go (97 lines)
      query.pb.go (215 lines)
      subscribe.pb.go (97 lines)
    activate.proto (14 lines)
    makefile (12 lines)
    menu.proto (9 lines)
    providerstate.proto (15 lines)
    query.proto (46 lines)
    subscribe.proto (15 lines)
.air.toml (68 lines)
.gitignore (3 lines)
BREAKING.md (3 lines)
flake.nix (227 lines)
go.mod (63 lines)
makefile (41 lines)
README.md (279 lines)
```
