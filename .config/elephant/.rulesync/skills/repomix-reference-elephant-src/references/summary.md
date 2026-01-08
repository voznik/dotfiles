This file is a merged representation of a subset of the codebase, containing files not matching ignore patterns, combined into a single document by Repomix.
The content has been processed where empty lines have been removed, content has been compressed (code blocks are separated by ⋮---- delimiter).

# Summary

## Purpose

This is a reference codebase organized into multiple files for AI consumption.
It is designed to be easily searchable using grep and other text-based tools.

## File Structure

This skill contains the following reference files:

| File | Contents |
|------|----------|
| `project-structure.md` | Directory tree with line counts per file |
| `files.md` | All file contents (search with `## File: <path>`) |
| `tech-stack.md` | Languages, frameworks, and dependencies |
| `summary.md` | This file - purpose and format explanation |

## Usage Guidelines

- This file should be treated as read-only. Any changes should be made to the
  original repository files, not this packed version.
- When processing this file, use the file path to distinguish
  between different files in the repository.
- Be aware that this file may contain sensitive information. Handle it with
  the same level of security as you would the original repository.

## Notes

- Some files may have been excluded based on .gitignore rules and Repomix's configuration
- Binary files are not included in this packed representation. Please refer to the Repository Structure section for a complete list of file paths, including binary files
- Files matching these patterns are excluded: LICENSE, *.lock, **/*.xml, **/*.txt
- Files matching patterns in .gitignore are excluded
- Files matching default ignore patterns are excluded
- Empty lines have been removed from all files
- Content has been compressed - code blocks are separated by ⋮---- delimiter
- Files are sorted by Git change count (files with more changes are at the bottom)

## Statistics

125 files | 7,014 lines

| Language | Files | Lines |
|----------|------:|------:|
| Go | 68 | 3,981 |
| No Extension | 21 | 758 |
| Markdown | 20 | 850 |
| Protocol Buffers | 5 | 99 |
| YAML | 4 | 259 |
| NIX | 3 | 854 |
| JSON | 1 | 71 |
| SERVICE | 1 | 11 |
| TOML | 1 | 68 |
| MOD | 1 | 63 |

**Largest files:**
- `nix/modules/nixos.nix` (320 lines)
- `nix/modules/home-manager.nix` (307 lines)
- `README.md` (279 lines)
- `flake.nix` (227 lines)
- `pkg/pb/pb/query.pb.go` (215 lines)
- `pkg/common/wlr/wlr-foreign-toplevel-management-unstable-v1.go` (211 lines)
- `.github/workflows/build.yml` (208 lines)
- `internal/providers/menus/README.md` (206 lines)
- `internal/providers/clipboard/setup.go` (168 lines)
- `internal/providers/todo/setup.go` (146 lines)
