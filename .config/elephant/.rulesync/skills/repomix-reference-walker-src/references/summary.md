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

50 files | 4,702 lines

| Language | Files | Lines |
|----------|------:|------:|
| Rust | 26 | 3,222 |
| YAML | 6 | 162 |
| Markdown | 4 | 269 |
| NIX | 4 | 571 |
| Protocol Buffers | 4 | 90 |
| TOML | 3 | 259 |
| No Extension | 2 | 59 |
| CSS | 1 | 70 |

**Largest files:**
- `src/ui/window.rs` (762 lines)
- `src/main.rs` (412 lines)
- `src/data.rs` (396 lines)
- `src/preview/mod.rs` (355 lines)
- `src/state/mod.rs` (307 lines)
- `nix/modules/nixos.nix` (230 lines)
- `resources/config.toml` (229 lines)
- `src/keybinds.rs` (223 lines)
- `nix/modules/home-manager.nix` (220 lines)
- `README.md` (212 lines)
