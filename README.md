<div align="center">

<img src="https://raw.githubusercontent.com/yorik1984/love2d-snippets/main/assets/love2d-snippets-logo512.png" alt="LÖVE snippets logo" height="256">

<h1>&nbsp;&nbsp;♡ <a href="https://love2d.org">LÖVE</a> ♡ Snippets&nbsp;&nbsp;</h1>

[![LÖVE Snippets Generator](https://github.com/yorik1984/love2d-snippets/actions/workflows/generate_love_api.yml/badge.svg)](https://github.com/yorik1984/love2d-snippets/actions/workflows/generate_love_api.yml)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/yorik1984/love2d-snippets/blob/main/LICENSE)
[![Lua](https://img.shields.io/badge/Lua-5.1-blue.svg)](https://www.lua.org/)
[![LÖVE API](https://img.shields.io/badge/L%C3%96VE_API-11.5-EA316E.svg)](https://github.com/love2d-community/love-api)

</div>

This tool parses the [LÖVE API](https://github.com/love2d-community/love-api) and generates VS Code-compatible snippet JSON files.

## 🚀 Features
 
- **Universal snippet collection** – the generated JSON files work in any editor that supports VS Code-style snippets compatible with any VS Code snippets loader.
The `snippets/` folder contains prepared snippet JSON files for all LÖVE modules
- **Standalone script** – run in repository workflows (GitHub Actions, CI/CD, or plugin repos) to generate snippets automatically
- **GitHub Actions automation** – optional CI workflow re-runs the generator to keep snippets up to date when the official [love-api](https://github.com/love2d-community/love-api) changes
- **Full API coverage** – generates snippets for all modules, functions, callbacks, type methods, constructors, getters/setters, enums, and `conf.lua`

## 📝 What's included

- [Modules](./USAGE.md#modules)
- [Callbacks](./USAGE.md#callbacks)
- [Functions and Type methods](./USAGE.md#functions-and-type-methods)
- [Constructors](./USAGE.md#constructors)
- [Getters and setters](./USAGE.md#getters-and-setters)
- [Enums](./USAGE.md#enums) as choice snippets
- [Conf](./USAGE.md#conf-snippets) snippets
- [package.json](./package.json) manifest listing the snippet files

For full instructions, see [USAGE.md](./USAGE.md).

## Indentation in Snippets

This snippet collection uses **tab characters (`\t`)** for indentation, not spaces.

### Why Tabs?

Using tabs for indentation offers several key benefits:

1. **Personalization** – Every developer can configure their editor to display tabs at their preferred width (2, 4, 8 spaces, etc.) without changing the actual file. What you see as 2 spaces, another developer can see as 8 spaces — the same file works for everyone.
2. **Portability** – Tabs work consistently across different editors, operating systems, and team environments. Copy-pasting code between projects doesn't break indentation.
3. **Clean diffs** – Since the number of tab characters doesn't change when someone adjusts their display settings, version control diffs remain clean and readable.
4. **File size** – One tab character takes less space than 2-4 spaces, which adds up in large codebases.

### The Golden Rule

**Tabs for indentation, spaces for alignment**.

- Use **tabs** at the beginning of lines to indicate nesting levels.
- Use **spaces** to align elements within a line (e.g., continuing a statement, aligning comments).

This separation ensures that indentation adapts to individual preferences while alignment remains visually consistent for everyone.

## 📦 Installations

For detailed installation instructions, see the [Wiki](https://github.com/yorik1984/love2d-snippets/wiki).

## 🔄 Rebuilding the API

### 🤖 Automated Workflow

The repository is configured for automatic updates via GitHub Actions:

- On every push to `main` branch
- Can be manually triggered via `workflow_dispatch`

The workflow automatically:

1. Clones the official love-api
2. Generates snippets
3. Commits updates to the repository


## 🗂 Output

- One JSON file per category under `snippets/love2d/` by default.
- A `package.json` that contributes the snippet files for editors or for packaging into an extension.
- Generated snippet scope: `lua`.

### Full stats and output files:

For a complete statistics and list of generated files, see [STATS.md](./STATS.md).

### ✋ Manual Generation (Optional)

> [!TIP]
> **You don't need to do this!** The automated workflow keeps everything up-to-date.  
> Manual generation is only for:
> - Testing custom modifications
> - Contributing to plugin development
> - Offline environments without GitHub Actions

> [!WARNING]
> Generate API manually only if the LÖVE version you need is missing from the repository branches. Branch name corresponds to LÖVE version number (e.g., branch `11.5` contains API for LÖVE 11.5). The `main` branch always contains the latest API version.

If you still want to generate files manually:
1. Download [LÖVE API](https://github.com/love2d-community/love-api) for the version you need
2. Copy `modules/` and `love_api.lua` to the root of this repository
3. Run the generator:

```bash
# Generate to default directory
lua genLOVEsnippets.lua

# Generate to custom directory
lua genLOVEsnippets.lua "my_snippets"

# Show debug info and generate to default directory
lua genLOVEsnippets.lua DEBUG

# Show debug info and generate to custom directory
lua genLOVEsnippets.lua DEBUG "my_snippets"

# Show help
lua genLOVEsnippets.lua HELP

# Add  statistics to `STATS.md`, create if not present
lua genLOVEsnippets.lua STATS
```

If custom directory is not provided, the default output directory is `snippets/`.

## 📚 References & Related Projects

+ **[love2d-definitions](https://github.com/yorik1984/love2d-definitions)** <br>
[LuaCATS](https://luals.github.io/wiki/annotations/) definition for [LÖVE](https://love2d.org/) framework.
Creates `---@class` and `---@alias` definitions for perfect autocompletion and type checking in IDEs with LuaCATS.
    - **🤖 Automated Updates:** Uses GitHub Actions to stay in sync with the official love-api, just like this plugin.
    - **📦 Ready-to-Use:** Provides a pre-generated `library/` folder that you can directly add to your workspace library.
    - **🧠 Smart Type System:** Intelligently handles type unions, plural forms (e.g., `tables` → `table[]`), optional parameters, and function overloads.
    - **📌 Version Branches:** Includes branches for specific LÖVE versions (e.g., `11.5`), so you can use annotations that match your project.

+ **[love2d-tresitter.nvim](https://github.com/yorik1984/love2d-treesitter.nvim)** <br>
Is a comprehensive plugin for [Neovim](https://neovim.io/) that highlight [LÖVE](http://love2d.org) syntax in your editor.
Provides complete LÖVE API syntax highlighting for LÖVE functions, modules, types, and callbacks, with full **[Treesitter](https://github.com/nvim-treesitter/nvim-treesitter)** support.
    * **🤖 Automated Updates:** Uses GitHub Actions to stay in sync with the official love-api, just like this definitions.
    * **⚙️ Fully Customizable:** Offers flexible styling options for colors and font styles (bold, italic, etc.).
    * **📌 Version Branches:** Maintains version-specific branches (e.g., `11.5`) to match different LÖVE releases.

+ **[Snip2d](https://github.com/Immow/Snip2d)** <br>
Snippets for Lua framework love2d 

+ **[Love2D-Snippets-VSCode](https://github.com/CodingJinxx/Love2D-Snippets-VSCode)** <br>
Snippet Extension for Love2D in Lua

## 📜 License

MIT License

<div align="center">
  <sub>
    Built with ♡ for the LÖVE community
    <br>
    <a href="https://github.com/yorik1984/love2d-snippets/issues">Report Issue</a> •
    <a href="https://github.com/yorik1984/love2d-snippets/discussions">Discussion</a> •
    <a href="https://love2d.org/">LÖVE</a>
  </sub>
</div>
