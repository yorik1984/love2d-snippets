# LÖVE Snippets

## Files Structure

Snippets are organized in JSON files within the [snippets/love2d](https://github.com/yorik1984/love2d-snippets/blob/main/snippets/love2d) directory:

| Section | File | Content |
| ------- | ---- | ------- |
| [Modules](#modules) | [modules.json](https://github.com/yorik1984/love2d-snippets/blob/main/snippets/love2d/modules.json) | Module functions (`love.audio`, `love.graphics`, etc.) |
| [Callbacks](#callbacks) | [callbacks.json](https://github.com/yorik1984/love2d-snippets/blob/main/snippets/love2d/callbacks.json) | Callback functions (`love.draw`, `love.update`, etc.) |
| [Functions and Type Methods](#functions-and-type-methods) | [functions.json](https://github.com/yorik1984/love2d-snippets/blob/main/snippets/love2d/functions.json) | Regular functions and type methods |
| [Constructors](#constructors) | [constructors.json](https://github.com/yorik1984/love2d-snippets/blob/main/snippets/love2d/constructors.json) | Constructor functions (`newImage`, `newSource`, etc.) |
| [Getters and Setters](#getters-and-setters) | [getters-setters.json](https://github.com/yorik1984/love2d-snippets/blob/main/snippets/love2d/getters-setters.json) | Getter and setter methods |
| [Enums](#enums) | [enums.json](https://github.com/yorik1984/love2d-snippets/blob/main/snippets/love2d/enums.json) | Enumeration values |
| [Conf Snippets](#conf-snippets) | [conf.json](https://github.com/yorik1984/love2d-snippets/blob/main/snippets/love2d/conf.json) | `conf.lua` configuration snippets |

## Usage

This collection uses **VS Code Snippets** format. Below are the key features used in our snippets.

> [!TIP]
> For complete documentation, see the [official VS Code Snippets guide](https://code.visualstudio.com/docs/editing/userdefinedsnippets).

#### Prefixes

One or more trigger words that display the snippet.

```json
"prefix": ["la", "love.audio"]
```

Typing `la` or `love.audio` will trigger the snippet

#### Body

One or more lines of content inserted when the snippet triggers.

```json
"body": [
    "love.audio.${0:}"
]
```

#### Placeholders (`${1:default}`)

Tab stops with default text. Press `Tab` (or your editor's configured completion key) to jump to the next placeholder.

| Syntax     | Meaning                             |
| ---------- | ----------------------------------- |
| `${1:foo}` | Placeholder with default text `foo` |
| `${2}`     | Empty placeholder (no default)      |
| `${0}`     | Final cursor position (always last) |

**Example:** `local ${1:source} = love.audio.newSource()` — `source` is selected and can be typed over.

#### Choice Placeholders (`${1|opt1,opt2,opt3|}`)

Dropdown list of predefined values.

```json
"body": [
    "${1|\"center\",\"left\",\"right\",\"justify\"|}"
]
```

When you reach this placeholder, shows a dropdown with the available options.

#### Variables

Dynamic values inserted based on the current context.

| Variable              | Meaning                            |
| --------------------- | ---------------------------------- |
| `${TM_FILENAME_BASE}` | Current filename without extension |
| `${TM_DIRECTORY}`     | Current file's directory path      |
| `${CURRENT_YEAR}`     | Current year                       |
| `${CLIPBOARD}`        | Contents of your clipboard         |

**Example with transformation:**

```json
"body": [
    "function ${1:${TM_FILENAME_BASE/(.*)/${1:/capitalize}/}}:directorydropped(${2:path})"
]
```

#### Variable Transformations (`${var/regex/format/}`)

Modify a variable's value before insertion.

| Example                                   | Output    |
| ----------------------------------------- | --------- |
| `${TM_FILENAME_BASE}`                     | `example` |
| `${TM_FILENAME_BASE/(.*)/${1:/upcase}/}`  | `EXAMPLE` |
| `${TM_FILENAME_BASE/./${1:/capitalize}/}` | `Example` |

**Common transformations:**

| Transform     | Effect                   |
| ------------- | ------------------------ |
| `/upcase`     | UPPERCASE                |
| `/downcase`   | lowercase                |
| `/capitalize` | First Letter Capitalized |

#### Scope

Specifies which languages the snippet works for.

```json
"scope": "lua"
```

#### Description

Optional description.

```json
"description": "Insert `love.audio.`"
```

## Files

> Folder: [snippets/love2d](https://github.com/yorik1984/love2d-snippets/blob/main/snippets/love2d)

### Modules

> File: [modules.json](https://github.com/yorik1984/love2d-snippets/blob/main/snippets/love2d/modules.json)

Snippets for LÖVE module functions (`love.graphics`, `love.audio`, `love.filesystem`, etc.)

The prefix is formed as: `l` + unique abbreviation of the module name (e.g., `la` for `love.audio`, `lg` for `love.graphics`).

See the snippet file for the complete list.

The full module name (e.g., `love.graphics`) also works as a prefix.

<details>
<summary><b>Example snippet:</b></summary>

```json
{
    "love.audio": {
        "prefix": [
            "la",
            "love.audio"
        ],
        "scope": "lua",
        "body": [
            "love.audio.${0:}"
        ],
        "description": "Insert `love.audio.`"
    }
}
```

</details>

### Callbacks

> File: [callbacks.json](https://github.com/yorik1984/love2d-snippets/blob/main/snippets/love2d/callbacks.json)

Snippets for LÖVE callback functions — special functions that LÖVE calls automatically when certain events occur (e.g., when the game starts, when a key is pressed, when a directory is dropped).

These snippets generate **four variants** for each callback:

| Variant                           | Prefix               | Output                            | Use case                         |
| --------------------------------- | -------------------- | --------------------------------- | -------------------------------- |
| **Global function (no params)**   | function name        | `function love.callback()`        | Simple scripts, beginners        |
| **Global function (with params)** | `p` + function name  | `function love.callback(params)`  | When you need callback arguments |
| **Class method (no params)**      | `m` + function name  | `function Class:callback()`       | Object-oriented programming      |
| **Class method (with params)**    | `mp` + function name | `function Class:callback(params)` | OOP with callback arguments      |

### Example for `load` callback

| Prefix   | Output                                          |
| -------- | ----------------------------------------------- |
| `load`   | `function love.load() end`                      |
| `pload`  | `function love.load(arg, unfilteredArg) end`    |
| `mload`  | `function MyClass:load() end`                   |
| `mpload` | `function MyClass:load(arg, unfilteredArg) end` |

### Placeholders

| Placeholder                                       | Meaning                                                                                             |
| ------------------------------------------------- | --------------------------------------------------------------------------------------------------- |
| `${1:${TM_FILENAME_BASE/(.*)/${1:/capitalize}/}}` | Inserts the current filename (capitalized) as the default name for the function's owner — OOP style |
| `${2:arg}, ${3:unfilteredArg}`                    | The parameters passed by LÖVE                                                                       |
| `${0}`                                            | Final cursor position after pressing `Tab` through all placeholders                                 |

<details>
<summary><b>Example snippets:</b></summary>

```json
{
    "love.load()": {
        "prefix": "load",
        "scope": "lua",
        "body": [
            "function love.load()",
            "\t${0:}",
            "end"
        ],
        "description": "This function is called exactly once at the beginning of the game."
    },
    "love.load()_param": {
        "prefix": "pload",
        "scope": "lua",
        "body": [
            "function love.load(${2:arg}, ${3:unfilteredArg})",
            "\t${0:}",
            "end"
        ],
        "description": "This function is called exactly once at the beginning of the game."
    },
    "love.load()_method": {
        "prefix": "mload",
        "scope": "lua",
        "body": [
            "function ${1:${TM_FILENAME_BASE/(.*)/${1:/capitalize}/}}:load()",
            "\t${0:}",
            "end"
        ],
        "description": "This function is called exactly once at the beginning of the game."
    },
    "love.load()_method_param": {
        "prefix": "mpload",
        "scope": "lua",
        "body": [
            "function ${1:${TM_FILENAME_BASE/(.*)/${1:/capitalize}/}}:load(${2:arg}, ${3:unfilteredArg})",
            "\t${0:}",
            "end"
        ],
        "description": "This function is called exactly once at the beginning of the game."
    }
}
```

</details>

### Functions and Type Methods

> File: [functions.json](https://github.com/yorik1984/love2d-snippets/blob/main/snippets/love2d/functions.json)

This section includes all LÖVE API functions **except callbacks and constructors**. These snippets are **declarative** — they insert a function or method call without assigning it to a variable.

**Includes:**

- Module functions (e.g., `love.graphics.circle()`)
- Type methods (e.g., `Body:getX()`)
- Getters and setters (e.g., `Body:getX()`)

**Excludes:**

- [Callbacks](#callbacks) (have their own section)
- [Constructors](#constructors) (functions starting with `new` — have their own section)

**Prefix rules:**

- The prefix format is `<method_name>_<module_or_type>` (e.g., `circle_graphics`, `getX_Body`)
- For overloaded functions, a number is appended to the prefix

<details>
<summary><b>Example snippets:</b></summary>

```json
{
    "love.graphics.circle()": {
        "prefix": "circle_graphics",
        "scope": "lua",
        "body": [
            "love.graphics.circle(${1|\"fill\",\"line\"|}, ${2:x}, ${3:y}, ${4:radius})$0"
        ],
        "description": "Draws a circle."
    },
    "Data:clone()": {
        "prefix": "clone_Data",
        "scope": "lua",
        "body": [
            "${1:data}:clone()$0"
        ],
        "description": "Creates a new copy of the Data object."
    },
    "Body:getX()_physics": {
        "prefix": "getX_Body",
        "scope": "lua",
        "body": [
            "${1:body}:getX()$0"
        ],
        "description": "Get the x position of the body in world coordinates."
    }
}
```

 </details>

### Constructors

> File: [constructors.json](https://github.com/yorik1984/love2d-snippets/blob/main/snippets/love2d/constructors.json)

Snippets for **constructor functions** — functions that create and return a LÖVE object (type) such as `Image`, `Source`, `Font`, etc.

**Characteristics:**

- Function names start with `new` (e.g., `love.graphics.newImage`, `love.audio.newSource`)
- These snippets **include variable declaration** (`local ... =`)
- The prefix starts with `l` (e.g., `lnewImage`, `lnewSource`)

**Prefix rules:**

- Base prefix: `l` + function name (e.g., `lnewSource`)
- For overloaded functions, a number is appended (e.g., `lnewSource2`)

<details>
<summary><b>Example snippet:</b></summary>

```json
{
    "love.audio.newSource()_overload2": {
        "prefix": "lnewSource2",
        "scope": "lua",
        "body": [
            "local ${1:source} = love.audio.newSource(${2:file}, ${3|\"static\",\"stream\",\"queue\"|})",
            "${0:}"
        ],
        "description": "Creates a new Source from a filepath, File, Decoder or SoundData. (Constructor)"
    }
}
```

</details>

### Getters and Setters

> File: [getters-setters.json](https://github.com/yorik1984/love2d-snippets/blob/main/snippets/love2d/getters-setters.json)

Snippets for getter and setter methods of LÖVE objects.

**Characteristics:**

- **Getters** — retrieve values from an object or module. These snippets **include variable declaration** (`local ... =`)
- **Setters** — modify object properties. These snippets work as **type methods** (called directly on the object)

**Prefix rules:**

- **Module getter prefix:** `l` + `get` + function name + `_` + module name (e.g., `lgetPointSize_graphics`)
- **Type method getter prefix:** `l` + `get` + function name + `_` + type name (e.g., `lgetControlPoint_BezierCurve`)
- **Setter prefix:** `set` + function name + `_` + type name (e.g., `setBackgroundColor_BackgroundColor`)

> [!Note]
> Getters are written as declarations with assignment `local x = love.graphics.getPointSize()` because you need to store the returned value. Setters are written as direct method calls `obj:setX(value)` since they modify the object directly.

<details>
<summary><b>Example snippets:</b></summary>

```json
{
    "love.graphics.getPointSize()": {
        "prefix": "lgetPointSize_graphics",
        "scope": "lua",
        "body": [
            "local ${1:size} = love.graphics.getPointSize()",
            "${0:}"
        ],
        "description": "Gets the point size."
    },
    "BezierCurve:getControlPoint()_math": {
        "prefix": "lgetControlPoint_BezierCurve",
        "scope": "lua",
        "body": [
            "local ${2:x}, ${3:y} = ${1:bezierCurve}:getControlPoint(${4:i})",
            "${0:}"
        ],
        "description": "Get coordinates of the i-th control point."
    },
    "BackgroundColor:setBackgroundColor()_graphics": {
        "prefix": "setBackgroundColor_BackgroundColor",
        "scope": "lua",
        "body": [
            "${1:backgroundColor}:setBackgroundColor(${2:red}, ${3:green}, ${4:blue}, ${5:1})",
            "${0:}"
        ],
        "description": "Sets the background color."
    }
}
```

</details>

### Enums

> File: [enums.json](https://github.com/yorik1984/love2d-snippets/blob/main/snippets/love2d/enums.json)

Snippets for LÖVE enumeration values — predefined constants used as parameters for various functions.

**Characteristics:**

- Enums provide **choice snippets** — a dropdown list of all possible values
- The prefix is the **enum type name** (e.g., `AlignMode`)
- Available in autocompletion as standalone snippets

<details>
<summary><b>Example snippet:</b></summary>

```json
{
    "alias love.AlignMode": {
    "prefix": "AlignMode",
    "scope": "lua",
    "body": [
        "${1|\"center\",\"left\",\"right\",\"justify\"|}"
    ],
    "description": "Text alignment."
    }
}
```

</details>

### Conf Snippets

> File: [conf.json](https://github.com/yorik1984/love2d-snippets/blob/main/snippets/love2d/conf.json)

Snippets for the `conf.lua` configuration file — used to configure LÖVE game settings before the game runs.

**Characteristics:**

- Generates a complete `love.conf` function template
- The prefix is `conff` (short for "conf function")
- Includes all available configuration options with sensible defaults
- Uses choice snippets (`${1|option1,option2|}`) for boolean and enum values

<details>
<summary><b>Example snippet:</b></summary>

```json
{
    "function love.conf(t)": {
        "prefix": "conff",
        "scope": "lua",
        "body": [
            "function love.conf(${2:t})",
            "\t${2:t}.identity              = ${3:nil}",
            "\t${2:t}.appendidentity        = ${4|false,true|}",
            "\t${2:t}.version               = ${5:\"11.5\"}",
            "\t${2:t}.console               = ${6|false,true|}",
            "\t${2:t}.accelerometerjoystick = ${7|true,false|}",
            "\t${2:t}.externalstorage       = ${8|false,true|}",
            "\t${2:t}.gammacorrect          = ${9|false,true|}",
            "",
            "\t${2:t}.audio.mic             = ${10|false,true|}",
            "\t${2:t}.audio.mixwithsystem   = ${11|true,false|}",
            "",
            "\t${2:t}.window.title          = ${12:\"Untitled\"}",
            "\t${2:t}.window.icon           = ${13:nil}",
            "\t${2:t}.window.width          = ${14:800}",
            "\t${2:t}.window.height         = ${15:600}",
            "\t${2:t}.window.borderless     = ${16|false,true|}",
            "\t${2:t}.window.resizable      = ${17|false,true|}",
            "\t${2:t}.window.minwidth       = ${18:1}",
            "\t${2:t}.window.minheight      = ${19:1}",
            "\t${2:t}.window.fullscreen     = ${20|false,true|}",
            "\t${2:t}.window.fullscreentype = ${21:\"desktop\"}",
            "\t${2:t}.window.usedpiscale    = ${22|true,false|}",
            "\t${2:t}.window.vsync          = ${23:true}",
            "\t${2:t}.window.depth          = ${24:nil}",
            "\t${2:t}.window.stencil        = ${25:nil}",
            "\t${2:t}.window.msaa           = ${26:0}",
            "\t${2:t}.window.display        = ${27:1}",
            "\t${2:t}.window.highdpi        = ${28|false,true|}",
            "\t${2:t}.window.x              = ${29:nil}",
            "\t${2:t}.window.y              = ${30:nil}",
            "",
            "\t${2:t}.modules.audio         = ${31|true,false|}",
            "\t${2:t}.modules.event         = ${32|true,false|}",
            "\t${2:t}.modules.graphics      = ${33|true,false|}",
            "\t${2:t}.modules.image         = ${34|true,false|}",
            "\t${2:t}.modules.joystick      = ${35|true,false|}",
            "\t${2:t}.modules.keyboard      = ${36|true,false|}",
            "\t${2:t}.modules.math          = ${37|true,false|}",
            "\t${2:t}.modules.mouse         = ${38|true,false|}",
            "\t${2:t}.modules.physics       = ${39|true,false|}",
            "\t${2:t}.modules.sound         = ${40|true,false|}",
            "\t${2:t}.modules.system        = ${41|true,false|}",
            "\t${2:t}.modules.timer         = ${42|true,false|}",
            "\t${2:t}.modules.touch         = ${43|true,false|}",
            "\t${2:t}.modules.video         = ${44|true,false|}",
            "\t${2:t}.modules.window        = ${45|true,false|}",
            "\t${2:t}.modules.thread        = ${46|true,false|}",
            "end"
        ],
        "description": "`conf` as a regular function"
    }
}
```

</details>
