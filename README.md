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
- [Conf](/USAGE.md#conf-snippets) snippets
- [package.json](https://github.com/yorik1984/love2d-snippets/blob/main/snippets/package.json) manifest listing the snippet files

For full instructions, see [USAGE.md](USAGE.md).

## 📦 Installations

Use the plugins listed below to integrate these snippets into your editor (IDE), or connect the snippets directory according to your editor's requirements.

### [VS Code](https://code.visualstudio.com/)

This is actually link to the VS Code extension. You can install it from the VS Code Marketplace.

[![Install from VS Code Marketplace](https://img.shields.io/badge/VS%20Code%20Marketplace-Install-blue)](https://marketplace.visualstudio.com/items?itemName=yorik1984.love2d-snippets)

Or search for `love2d-snippets` in the Extensions view (`Ctrl+Shift+X`).

### [Neovim](https://neovim.io/) and [LuaSnip](https://github.com/L3MON4D3/LuaSnip)

#### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
    "yorik1984/love2d-snippets",
    branch = "main", -- default or `branch = "11.5"` for special API version
    ft = "lua",
    dependencies = {
        "L3MON4D3/LuaSnip",
    },
    config = function()
        local paths = { vim.fn.stdpath("data") .. "/lazy/love2d-snippets/snippets" }
        require("luasnip.loaders.from_vscode").lazy_load({ paths = paths })
    end
}
```

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

### Typical output files:

- `snippets/love2d/callbacks.json`
- `snippets/love2d/conf.json`
- `snippets/love2d/constructors.json`
- `snippets/love2d/enums.json`
- `snippets/love2d/functions.json`
- `snippets/love2d/getters-setters.json`
- `snippets/love2d/modules.json`
- `snippets/package.json`

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
```

If custom directory is not provided, the default output directory is `snippets/`.

## 📚 References & Related Projects

+ **[love2d-definitions](https://github.com/yorik1984/love2d-definitions)**<br>
[LuaCATS](https://luals.github.io/wiki/annotations/) definition for [LÖVE](https://love2d.org/) framework.
Creates `---@class` and `---@alias` definitions for perfect autocompletion and type checking in IDEs with LuaCATS.
    - **🤖 Automated Updates:** Uses GitHub Actions to stay in sync with the official love-api, just like this plugin.
    - **📦 Ready-to-Use:** Provides a pre-generated `library/` folder that you can directly add to your workspace library.
    - **🧠 Smart Type System:** Intelligently handles type unions, plural forms (e.g., `tables` → `table[]`), optional parameters, and function overloads.
    - **📌 Version Branches:** Includes branches for specific LÖVE versions (e.g., `11.5`), so you can use annotations that match your project.

+ **[love2d-tresitter.nvim](https://github.com/yorik1984/love2d-treesitter.nvim)**<br>
Is a comprehensive plugin for [Neovim](https://neovim.io/) that highlight [LÖVE](http://love2d.org) syntax in your editor.
Provides complete LÖVE API syntax highlighting for LÖVE functions, modules, types, and callbacks, with full **[Treesitter](https://github.com/nvim-treesitter/nvim-treesitter)** support.
    * **🤖 Automated Updates:** Uses GitHub Actions to stay in sync with the official love-api, just like this definitions.
    * **⚙️ Fully Customizable:** Offers flexible styling options for colors and font styles (bold, italic, etc.).
    * **📌 Version Branches:** Maintains version-specific branches (e.g., `11.5`) to match different LÖVE releases.

+ **[Snip2d](https://github.com/Immow/Snip2d)**<br>
Snippets for Lua framework love2d 

+ **[Love2D-Snippets-VSCode](https://github.com/CodingJinxx/Love2D-Snippets-VSCode)**<br>
Snippet Extension for Love2D in Lua

## 📜 License

MIT License

<div align="center">
  <sub>
    Built with ♡ for the LÖVE community
    <br>
    <a href="https://github.com/yorik1984/love2d-snippets/issues">Report Issue</a> ·
    <a href="https://github.com/yorik1984/love2d-snippets/discussions">Discussion</a> ·
    <a href="https://love2d.org/">LÖVE</a>
  </sub>
</div>
