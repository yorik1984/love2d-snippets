--[[
genLOVEsnippets.lua - LÖVE Snippets Generator

Generates VSCode-compatible code snippets for LÖVE game engine
based on love_api.lua structure.

USAGE:
    lua genLOVEsnippets.lua [OPTIONS] [OUTPUT_DIR]

OPTIONS:
    DEBUG             - Show debug information
    HELP              - Display this help message

COMMANDS:
    (no argument)     - Generate snippets to default directory: snippets/
    "path/to/dir"     - Generate snippets to custom directory

EXAMPLES:
    lua genLOVEsnippets.lua
    lua genLOVEsnippets.lua "my_snippets"
    lua genLOVEsnippets.lua DEBUG
    lua genLOVEsnippets.lua DEBUG "my_snippets"

OUTPUT:
    - Format: VSCode JSON snippets format
    - Covers: all module functions, callbacks, and type methods
]]

local HELP_TEXT = [[
genLOVEsnippets.lua - LÖVE Snippets Generator

Generates VSCode-compatible code snippets for LÖVE game engine
based on love_api.lua structure.

USAGE:
    lua genLOVEsnippets.lua [OPTIONS] [OUTPUT_DIR]

OPTIONS:
    DEBUG             - Show debug information
    HELP              - Display this help message

COMMANDS:
    (no argument)     - Generate snippets to default directory: snippets/
    "path/to/dir"     - Generate snippets to custom directory

EXAMPLES:
    lua genLOVEsnippets.lua
    lua genLOVEsnippets.lua "my_snippets"
    lua genLOVEsnippets.lua DEBUG
    lua genLOVEsnippets.lua DEBUG "my_snippets"

OUTPUT:
    - Format: VSCode JSON snippets format
    - Covers: all module functions, callbacks, and type methods
]]

local INTRO_TEXT = [[
 🚀 LÖVE Snippets Generator
 ==============================
]]

-- Best-effort UTF-8 on Windows
pcall(function()
    os.execute("chcp 65001 > nul 2>&1")
end)

local time = os.clock()

--------------------------------------------------------------------------------
-- Type discovery
--------------------------------------------------------------------------------
local API = {
    CONF            = "conf",
    ENGINE          = "love2d",
    ENGINE_NAME     = "LÖVE",
    FILE            = "love_api",
    FILE_EXT        = "lua",
    NAME            = "love",
    OUTPUT_DIR      = "snippets",
    PREF_GET        = "get",
    PREF_SET        = "set",
    PREF_NEW        = "new",
    SNIP_FILE_EXT   = "json",
    SNIP_PACKAGE    = "package",
    TARGET_FILE_EXT = "lua",
}

setmetatable(API, {
    __index = API,
    __newindex = function()
        error("Attempt to modify a constant", 2)
    end,
})

local function isProblematic(typeName)
    local problematic = {
        ["love.filesystem.getSource"] = true,
    }
    return problematic[typeName] == true
end

--------------------------------------------------------------------------------
-- Utilities
--------------------------------------------------------------------------------
local function isEmpty(s)
    return s == nil or (type(s) == "string" and s:match("^%s*$") ~= nil)
end

local function isPrimitiveType(typeName)
    local primitives = {
        ["any"]           = true,
        ["boolean"]       = true,
        ["function"]      = true,
        ["integer"]       = true,
        ["lightuserdata"] = true,
        ["nil"]           = true,
        ["number"]        = true,
        ["string"]        = true,
        ["table"]         = true,
        ["thread"]        = true,
        ["userdata"]      = true,
    }
    return primitives[typeName] == true
end

local function firstSentence(s)
    if isEmpty(s) then
        return ""
    end
    local pos = s:find("[\n.]")
    if pos then
        return s:sub(1, pos)
    end
    return s
end

local function valJSON(s)
    if not s then
        return ""
    end

    local strRes = s

    if s == '"' then
        strRes = [[\"]]
    elseif s == "'" then
        strRes = [[']]
    elseif s == "\\" then
        strRes = [[\\]]
    elseif s == "," then
        strRes = [[\,]]
    end

    return strRes
end

local function escapeJSON(s)
    if not s then
        return ""
    end
    s = tostring(s)
    s = s:gsub("\\", "\\\\")
    s = s:gsub('"', '\\"')
    s = s:gsub("\n", "\\n")
    s = s:gsub("\r", "\\r")
    s = s:gsub("\t", "\\t")
    return s
end

local function sizeOfTable(t)
    local c = 0
    for _ in pairs(t) do
        c = c + 1
    end
    return c
end

-- Convert type name to camelCase variable name
local function toVariableName(typeName)
    if not typeName or typeName == "" then
        return "obj"
    end
    -- Make first character lowercase
    return typeName:sub(1, 1):lower() .. typeName:sub(2)
end

local function isConstructorName(name)
    return name:match("^" .. API.PREF_NEW) ~= nil
end

--------------------------------------------------------------------------------
-- CLI
--------------------------------------------------------------------------------
local function createDirectory(path)
    local isWindows = package.config:sub(1, 1) == "\\"
    if isWindows then
        path = path:gsub("/", "\\")
        os.execute("mkdir " .. path .. " 2>nul")
    else
        os.execute("mkdir -p " .. path .. " 2>/dev/null")
    end
end

local debugMode = false
local function debugPrint(...)
    if debugMode then
        io.write("\n 🔧 DEBUG: ", ...)
        io.write("\n")
    end
end

local outputDir = API.OUTPUT_DIR
for i = 1, #arg do
    local a = arg[i]
    if a == "DEBUG" then
        debugMode = true
    elseif a == "HELP" then
        io.write(HELP_TEXT, "\n")
        os.exit(0)
    else
        io.write(INTRO_TEXT, "\n")
        outputDir = a
    end
end

-- Load API
local ok, apiRequire = pcall(function()
    return require(API.FILE)
end)

if not ok then
    io.stderr:write(
        " ❌ Error: could not require '"
        .. API.FILE
        .. "'. Make sure "
        .. API.FILE
        .. "."
        .. API.FILE_EXT
        .. " is present in the current directory\n"
    )
    os.exit(1)
elseif debugMode then
    print("\n ✅ Successfully loaded " .. API.FILE .. API.FILE_EXT .. "\n")
end

if debugMode then
    print(string.format(
        [[
 Debug mode: ENABLE
 Output directory: %s]],
        outputDir
    ))
end

createDirectory(outputDir)

--------------------------------------------------------------------------------
-- Parameter expansion
--------------------------------------------------------------------------------
local function expandParameters(arguments)
    if not arguments then
        return {}
    end
    local expanded = {}
    for _, argument in ipairs(arguments) do
        if argument.name == "..." then
            expanded[#expanded + 1] = argument
        elseif type(argument.name) == "string" and string.find(argument.name, ",") then
            for name in string.gmatch(argument.name, "%s*([^,]+)%s*") do
                expanded[#expanded + 1] = {
                    type        = argument.type,
                    name        = name,
                    description = argument.description,
                    default     = argument.default,
                    table       = argument.table,
                }
            end
        else
            expanded[#expanded + 1] = argument
        end
    end
    return expanded
end

--------------------------------------------------------------------------------
-- Common Argument Processing Functions
--------------------------------------------------------------------------------
-- Get enum constants by searching api
local function getEnumConstantsFromApi(typeName, api)
    if not typeName then
        return nil
    end
    local baseName = typeName:gsub("%[%]$", "")

    local function searchModule(module)
        if module.enums then
            for _, enum in ipairs(module.enums) do
                if enum.name == baseName then
                    return enum.constants
                end
            end
        end
        if module.modules then
            for _, sub in ipairs(module.modules) do
                local result = searchModule(sub)
                if result then return result end
            end
        end
        return nil
    end

    return searchModule(api)
end

-- Process enum argument with choice list
local function processEnumArgument(arg, enumConsts, idx)
    local quotedConsts = {}
    for _, const in ipairs(enumConsts) do
        table.insert(quotedConsts, '"' .. const .. '"')
    end

    local defaultConst = arg.default
    if defaultConst and type(defaultConst) == "string" then
        for _, const in ipairs(enumConsts) do
            if const == defaultConst then
                table.insert(quotedConsts, 1, '"' .. defaultConst .. '"')
                break
            end
        end
    end

    return ("${%d|%s|}"):format(idx, table.concat(quotedConsts, ","))
end

-- Process regular argument with name or default value
local function processRegularArgument(arg, idx, showDefaultAsHint)
    showDefaultAsHint = showDefaultAsHint == nil and false or showDefaultAsHint
    if arg.type == "boolean" and arg.default ~= nil then
        if arg.default:lower() == "true" then
            return ("${%d|true,false|}"):format(idx)
        elseif arg.default:lower() == "false" then
            return ("${%d|false,true|}"):format(idx)
        end
    end
    if arg.default then
        if showDefaultAsHint then
            return ("${%d:%s (%s)}"):format(idx, arg.name, tostring(arg.default))
        else
            return ("${%d:%s}"):format(idx, tostring(arg.default))
        end
    end
    return ("${%d:%s}"):format(idx, arg.name)
end

-- Process table argument with fields
local function processTableArgument(fields, startIdx, getEnumConstantsFunc)
    local tableParts = {}
    local currentIdx = startIdx

    for _, field in ipairs(fields) do
        if field.name ~= "..." then
            local fieldType = field.type or "any"
            local fieldConsts = getEnumConstantsFunc(fieldType)

            if fieldConsts and #fieldConsts > 0 then
                local quotedConsts = {}
                for _, const in ipairs(fieldConsts) do
                    table.insert(quotedConsts, '"' .. const .. '"')
                end
                local defaultField = field.default
                if defaultField and type(defaultField) == "string" then
                    for _, const in ipairs(fieldConsts) do
                        if const == defaultField then
                            table.insert(quotedConsts, 1, '"' .. defaultField .. '"')
                            break
                        end
                    end
                end
                table.insert(
                    tableParts,
                    ("%s = ${%d|%s|}"):format(field.name, currentIdx, table.concat(quotedConsts, ","))
                )
            else
                local defaultStr = ""
                if field.default ~= nil then
                    if field.type == "string" then
                        defaultStr = '"' .. tostring(field.default) .. '"'
                    else
                        defaultStr = tostring(field.default)
                    end
                end
                table.insert(tableParts, ("%s = ${%d:%s}"):format(field.name, currentIdx, defaultStr))
            end
            currentIdx = currentIdx + 1
        end
    end

    if #tableParts > 0 then
        return "{ " .. table.concat(tableParts, ", ") .. " }"
    end
    return "{}"
end

-- Main argument processing function factory
local function createArgumentProcessor(getEnumConstantsFunc)
    return function(arg, startIdx)
        local argType = arg.type or "any"
        local enumConsts = getEnumConstantsFunc(argType)

        if enumConsts and #enumConsts > 0 then
            return processEnumArgument(arg, enumConsts, startIdx), 1
        elseif arg.table and #arg.table > 0 then
            return processTableArgument(arg.table, startIdx, getEnumConstantsFunc), 1
        else
            return processRegularArgument(arg, startIdx), 1
        end
    end
end

-- Generate parameter string from arguments
local function generateParamString(arguments, processArgument)
    if not arguments or #arguments == 0 then
        return "", 0
    end

    local paramParts = {}
    local placeholderIdx = 1

    for _, arg in ipairs(arguments) do
        if arg.name == "..." then
            table.insert(paramParts, "...")
        else
            local result, used = processArgument(arg, placeholderIdx)
            if result then
                table.insert(paramParts, result)
                placeholderIdx = placeholderIdx + used
            end
        end
    end

    return table.concat(paramParts, ", "), placeholderIdx - 1
end

--------------------------------------------------------------------------------
-- Data Collection
--------------------------------------------------------------------------------
-- Collect callbacks from api.callbacks
local function collectCallbacks(api)
    local callbacks = {}
    if api.callbacks then
        debugPrint("Collecting ", #api.callbacks, " callbacks")
        for _, cb in ipairs(api.callbacks) do
            if cb.name == API.CONF then
                debugPrint("Skipping " .. API.CONF .. " (will be handled separately)")
            else
                local params = {}
                if cb.variants and #cb.variants > 0 then
                    params = expandParameters(cb.variants[1].arguments or {})
                end

                local function getEnumConstantsFunc(typeName)
                    return getEnumConstantsFromApi(typeName, api)
                end
                local processArgument = createArgumentProcessor(getEnumConstantsFunc)

                local function generateParamStringForCallback(arguments, startIndex)
                    startIndex = startIndex or 1
                    return generateParamString(arguments, function(arg, idx)
                        return processArgument(arg, idx + startIndex - 1)
                    end)
                end

                table.insert(callbacks, {
                    name         = cb.name,
                    fullName     = API.NAME .. "." .. cb.name,
                    description  = cb.description or "",
                    parameters   = params,
                    paramsString = function(startIndex)
                        return generateParamStringForCallback(params, startIndex)
                    end,
                    variants     = cb.variants or {},
                    isCallback   = true,
                })
            end
        end
    end
    return callbacks
end

-- Collect constructors from api.functions (functions that return a type)
local function collectConstructors(api)
    local constructors = {}
    local nonNewConstructors = {}

    local function isEnumTypeFromApi(typeName)
        if not typeName then
            return false
        end
        local baseName = typeName:gsub("%[%]$", "")
        local function searchModule(module)
            if module.enums then
                for _, enum in ipairs(module.enums) do
                    if enum.name == baseName then
                        return true
                    end
                end
            end
            if module.modules then
                for _, sub in ipairs(module.modules) do
                    if searchModule(sub) then
                        return true
                    end
                end
            end
            return false
        end
        return searchModule(api)
    end

    local function getEnumConstantsFunc(typeName)
        return getEnumConstantsFromApi(typeName, api)
    end

    local processArgument = createArgumentProcessor(getEnumConstantsFunc)

    local function generateParamStringForConstructor(arguments, startIndex)
        startIndex = startIndex or 1
        if not arguments or #arguments == 0 then
            return ""
        end

        local paramParts = {}
        local placeholderIdx = startIndex

        for _, arg in ipairs(arguments) do
            if arg.name == "..." then
                table.insert(paramParts, "...")
            else
                local result, used = processArgument(arg, placeholderIdx)
                if result then
                    table.insert(paramParts, result)
                    placeholderIdx = placeholderIdx + used
                end
            end
        end

        return table.concat(paramParts, ", ")
    end

    local function scanModule(module, modulePath)
        if module.functions then
            for _, func in ipairs(module.functions) do
                if func.variants and #func.variants > 0 then
                    for vIdx, variant in ipairs(func.variants) do
                        if variant.returns and #variant.returns > 0 then
                            local ret = variant.returns[1]
                            local retType = ret.type or "any"

                            -- Only functions starting with "new" are constructors
                            if isConstructorName(func.name) and not isEnumTypeFromApi(retType) and not isPrimitiveType(retType) then
                                local params = {}
                                if variant.arguments then
                                    params = expandParameters(variant.arguments)
                                end

                                -- Track constructors not starting with "new" for debug
                                if not isConstructorName(func.name) then
                                    table.insert(nonNewConstructors, {
                                        name = func.name,
                                        fullName = modulePath .. "." .. func.name,
                                        returns = retType
                                    })
                                end

                                table.insert(constructors, {
                                    name         = func.name,
                                    fullName     = modulePath .. "." .. func.name,
                                    description  = func.description or "",
                                    parameters   = params,
                                    paramsString = function(startIndex)
                                        return generateParamStringForConstructor(params, startIndex)
                                    end,
                                    variants     = func.variants or {},
                                    modulePath   = modulePath,
                                    returns      = retType,
                                    typeName     = toVariableName(ret.name),
                                    variantIdx   = vIdx,
                                })
                            end
                        end
                    end
                end
            end
        end

        if module.modules then
            for _, sub in ipairs(module.modules) do
                scanModule(sub, modulePath .. "." .. sub.name)
            end
        end
    end

    scanModule(api, API.NAME)

    if debugMode and #nonNewConstructors > 0 then
        print("\n 🔧 DEBUG: Constructors not starting with 'new' (" .. #nonNewConstructors .. "):")
        for _, c in ipairs(nonNewConstructors) do
            print(" • " .. c.fullName .. " -> returns " .. c.returns)
        end
        print("")
    end

    return constructors
end

-- Collect getter/setter pairs
local function collectGettersSetters(api)
    local allPairs = {}
    local functionsByName = {}

    -- Create processArgument for enum processing
    local function getEnumConstantsFunc(typeName)
        return getEnumConstantsFromApi(typeName, api)
    end
    local processArgument = createArgumentProcessor(getEnumConstantsFunc)

    local function generateParamStringForFunc(arguments, startIndex)
        if not arguments or #arguments == 0 then
            return ""
        end
        return generateParamString(arguments, function(arg, idx)
            return processArgument(arg, idx + startIndex - 1)
        end)
    end

    -- Helper to expand parameters
    local function expandParams(args)
        if not args then
            return {}
        end
        local expanded = {}
        for _, arg in ipairs(args) do
            if arg.name == "..." then
                expanded[#expanded + 1] = arg
            elseif type(arg.name) == "string" and string.find(arg.name, ",") then
                for name in string.gmatch(arg.name, "%s*([^,]+)%s*") do
                    expanded[#expanded + 1] = {
                        type        = arg.type,
                        name        = name,
                        description = arg.description,
                        default     = arg.default,
                        table       = arg.table,
                    }
                end
            else
                expanded[#expanded + 1] = arg
            end
        end
        return expanded
    end

    -- Scan module functions
    local function scanModule(module, modulePath)
        if module.functions then
            for _, func in ipairs(module.functions) do
                local fullName = modulePath .. "." .. func.name
                functionsByName[fullName] = { func = func, isMethod = false, modulePath = modulePath }
            end
        end

        if module.modules then
            for _, sub in ipairs(module.modules) do
                scanModule(sub, modulePath .. "." .. sub.name)
            end
        end
    end

    -- Scan type methods
    local function scanTypes(module, modulePath)
        if module.types then
            for _, typ in ipairs(module.types) do
                if typ.functions then
                    for _, func in ipairs(typ.functions) do
                        local fullName = modulePath .. "." .. typ.name .. "." .. func.name
                        functionsByName[fullName] = {
                            func       = func,
                            isMethod   = true,
                            modulePath = modulePath .. "." .. typ.name,
                            typeName   = typ.name,
                        }
                    end
                end
            end
        end

        if module.modules then
            for _, sub in ipairs(module.modules) do
                scanTypes(sub, modulePath .. "." .. sub.name)
            end
        end
    end

    -- Start scanning
    scanModule(api, API.NAME)
    scanTypes(api, API.NAME)

    -- Process all collected functions to find getter/setter pairs
    for fullName, info in pairs(functionsByName) do
        local func = info.func
        if func.name:match("^" .. API.PREF_GET) then
            local baseName = func.name:sub(4)
            local setterFull = fullName:gsub("%." .. API.PREF_GET, "." .. API.PREF_SET)
            local setterInfo = functionsByName[setterFull]

            if setterInfo and not isProblematic(fullName) then
                local getParams = {}
                if func.variants and #func.variants > 0 then
                    getParams = expandParams(func.variants[1].arguments or {})
                end

                local setParams = {}
                if setterInfo.func.variants and #setterInfo.func.variants > 0 then
                    setParams = expandParams(setterInfo.func.variants[1].arguments or {})
                end

                local pair = {
                    getter     = {
                        name         = func.name,
                        fullName     = fullName,
                        description  = func.description or "",
                        parameters   = getParams,
                        variants     = func.variants or {},
                        paramsString = function(startIndex)
                            return generateParamStringForFunc(getParams, startIndex)
                        end,
                    },
                    setter     = {
                        name         = setterInfo.func.name,
                        fullName     = setterFull,
                        description  = setterInfo.func.description or "",
                        parameters   = setParams,
                        variants     = setterInfo.func.variants or {},
                        paramsString = function(startIndex)
                            return generateParamStringForFunc(setParams, startIndex)
                        end,
                    },
                    baseName   = baseName,
                    modulePath = info.modulePath,
                    isMethod   = info.isMethod,
                    typeName   = info.typeName,
                }

                table.insert(allPairs, pair)
            end
        end
    end

    return allPairs
end

-- Collect enums data for snippets
local function collectEnums(api)
    local enums = {}

    local function processModule(module)
        if module.enums then
            for _, enum in ipairs(module.enums) do
                local constantNames = {}
                if enum.constants then
                    for _, const in ipairs(enum.constants) do
                        table.insert(constantNames, valJSON(const.name))
                    end
                end
                enum.constants = constantNames

                table.insert(enums, {
                    name        = enum.name,
                    fullName    = API.NAME .. "." .. enum.name,
                    description = enum.description or "",
                    constants   = constantNames,
                })
            end
        end
        if module.modules then
            for _, sub in ipairs(module.modules) do
                processModule(sub)
            end
        end
    end

    processModule(api)
    return enums
end

-- Get top level modules list from API
local function collectModules(api)
    local modules = { API.NAME }
    if api.modules then
        for _, module in ipairs(api.modules) do
            table.insert(modules, API.NAME .. "." .. module.name)
        end
    end
    return modules
end

-- Find love.conf in callbacks and extract its fields
local function collectConf(api)
    if not api.callbacks then
        return nil
    end

    for _, cb in ipairs(api.callbacks) do
        if cb.name == API.CONF then
            if cb.variants and #cb.variants > 0 then
                local variant = cb.variants[1]
                if variant.arguments and #variant.arguments > 0 then
                    local arg = variant.arguments[1]
                    if arg.table and type(arg.table) == "table" then
                        return arg.table
                    end
                end
            end
        end
    end
    return nil
end

--------------------------------------------------------------------------------
-- Helper functions for snippet creation
--------------------------------------------------------------------------------
local function buildParamString(parameters, offset, showDefaultAsHint)
    showDefaultAsHint = showDefaultAsHint == nil and false or showDefaultAsHint
    if not parameters or #parameters == 0 then
        return ""
    end
    local paramParts = {}
    for argIdx, arg in ipairs(parameters) do
        local idx = argIdx + offset
        table.insert(paramParts, processRegularArgument(arg, idx, showDefaultAsHint))
    end
    return table.concat(paramParts, ", ")
end

local function createSnippet(prefix, body, description, scope)
    return {
        prefix      = prefix,
        body        = body,
        description = description,
        scope       = scope or API.TARGET_FILE_EXT,
    }
end

--------------------------------------------------------------------------------
-- Snippet Generators
--------------------------------------------------------------------------------
-- Generate callback snippets
local function generateCallbacks(callbacks)
    local snippets = {}
    local nextIdx = 2

    if debugMode and #callbacks > 0 then
        debugPrint("Generating callback snippets...")
    end

    for _, cb in ipairs(callbacks) do
        local paramsString = cb.paramsString(nextIdx)
        local body = {
            string.format("function ${1:${TM_FILENAME_BASE/(.*)/${1:/capitalize}/}}:%s(%s)", cb.name, paramsString),
            "\t${0:}",
            "end",
        }
        local key = API.NAME .. "." .. cb.name .. "()"
        snippets[key] = createSnippet(
            cb.name,
            body,
            firstSentence(cb.description)
        )

        if debugMode then
            print(" • " .. key)
        end
    end

    return snippets
end

-- Generate constructor snippets
local function generateConstructors(constructors)
    local snippets = {}
    local nextIdx = 2

    if debugMode and #constructors > 0 then
        debugPrint("Generating constructor snippets...")
    end
    for _, const in ipairs(constructors) do
        local paramsString = const.paramsString(nextIdx)
        if paramsString == "" then
            paramsString = buildParamString(const.parameters, nextIdx)
        end

        local body = {
            string.format("local ${1:%s} = %s(%s)", const.typeName, const.fullName, paramsString),
            "${0:}",
        }

        local key = const.fullName .. "()"
        local prefix = "l" .. const.name
        if const.variantIdx and const.variantIdx > 1 then
            key = key .. "_overload" .. const.variantIdx
            prefix = prefix .. const.variantIdx
        end

        snippets[key] = createSnippet(
            prefix,
            body,
            firstSentence(const.description) .. " (Constructor)"
        )

        if debugMode then
            print(" • " .. key)
        end
    end

    return snippets
end

-- Generate snippets for getter/setter pairs (both module functions and type methods)
local function generateGettersSetters(pairs)
    local snippets = {}

    for _, pair in ipairs(pairs) do
        local module     = pair.modulePath                         -- "love.graphics"
        local moduleName = module:gsub("^" .. API.NAME .. "%.", "") -- graphics
        local baseName   = pair.baseName                           -- "Color"
        local varName    = toVariableName(baseName)                -- "color"
        local getterName = pair.getter.name                        -- "getColor"
        local setterName = pair.setter.name                        -- "setColor"
        local getterCall = pair.getter.fullName                    -- "love.graphics.getColor"
        local getKey     = getterCall .. "()"                      -- "love.graphics.getColor()"

        if not snippets[module] then
            snippets[module] = {}
        end

        -- Generate all getter variants
        if pair.getter.variants and #pair.getter.variants > 0 then
            for vIdx, variant in ipairs(pair.getter.variants) do
                local getterReturns = {}
                if variant.returns and #variant.returns > 0 then
                    for i, ret in ipairs(variant.returns) do
                        local retName = ret.name or ("value" .. i)
                        local idx = pair.isMethod and i + 1 or i
                        table.insert(getterReturns, ("${%d:%s}"):format(idx, retName))
                    end
                end

                local startIdx = #getterReturns + 1
                if pair.isMethod then
                    startIdx = startIdx + 1
                end
                local gettParams = pair.getter.paramsString(startIdx)

                local currentGetKey = getKey
                local currentGetterCall = getterCall
                local typeName = pair.isMethod and pair.typeName or moduleName
                local prefix = "l" .. getterName .. "_" .. typeName
                if vIdx > 1 then
                    currentGetKey = currentGetKey .. "_overload" .. vIdx
                    prefix = prefix .. vIdx
                end

                if pair.isMethod then
                    local objPlaceholder = "${1:" .. toVariableName(pair.typeName) .. "}"
                    currentGetterCall    = objPlaceholder .. ":" .. getterName
                    currentGetKey        = pair.typeName .. ":" .. getterName .. "()"
                    if vIdx > 1 then
                        currentGetKey = currentGetKey .. "_overload" .. vIdx
                    end
                end

                local getterResultStr = ""
                if #getterReturns > 0 then
                    getterResultStr = "local " .. table.concat(getterReturns, ", ") .. " = "
                elseif not pair.isMethod then
                    getterResultStr = "local " .. varName .. " = "
                end

                local getterParam = #(variant.arguments or {}) ~= 0 and gettParams or ""
                local getterline = string.format("%s%s(%s)", getterResultStr, currentGetterCall, getterParam)

                local getBody = { getterline, "${0:}" }
                snippets[module][currentGetKey] = createSnippet(
                    prefix,
                    getBody,
                    firstSentence(variant.description or pair.getter.description or "")
                )
            end
        end

        -- Generate all setter variants
        if pair.setter.variants and #pair.setter.variants > 0 then
            for vIdx, variant in ipairs(pair.setter.variants) do
                local settParams = pair.setter.paramsString(2)

                local typeName = pair.isMethod and pair.typeName or pair.baseName
                local objPlaceholder = "${1:" .. toVariableName(typeName) .. "}"

                local currentSetterCall = objPlaceholder .. ":" .. setterName
                local currentSetKey = typeName .. ":" .. setterName .. "()"

                local prefix = API.PREF_SET .. baseName .. "_" .. typeName
                if vIdx > 1 then
                    currentSetKey = currentSetKey .. "_overload" .. vIdx
                    prefix = prefix .. vIdx
                end

                local setterParam = #(variant.arguments or {}) ~= 0 and settParams or ""
                local setterline = string.format("%s(%s)", currentSetterCall, setterParam)

                local setBody = { setterline, "${0:}" }
                snippets[module][currentSetKey] = createSnippet(
                    prefix,
                    setBody,
                    firstSentence(variant.description or pair.setter.description or "")
                )
            end
        end
    end

    if debugMode then
        debugPrint("Generating getter <-> setter pairs...")
        local sorted = {}
        for _, pair in ipairs(pairs) do
            table.insert(sorted, pair)
        end

        table.sort(sorted, function(a, b)
            if a.isMethod ~= b.isMethod then
                return a.isMethod == false
            end

            local aName, bName
            if a.isMethod then
                aName = a.typeName
                bName = b.typeName
            else
                aName = a.getter.fullName:match("^(.-)%.[^%.]+$") or ""
                bName = b.getter.fullName:match("^(.-)%.[^%.]+$") or ""
            end

            if aName ~= bName then
                return aName < bName
            end

            return a.getter.name < b.getter.name
        end)

        local maxNameLen = 0
        for _, pair in ipairs(sorted) do
            local name = pair.isMethod and (pair.typeName .. ":")
                or (pair.getter.fullName:match("^(.-)%.[^%.]+$") .. ".")
            if #name > maxNameLen then
                maxNameLen = #name
            end
        end

        local maxGetterLen = 0
        for _, pair in ipairs(sorted) do
            local getter = pair.getter.name .. "()"
            if #getter > maxGetterLen then
                maxGetterLen = #getter
            end
        end

        for _, pair in ipairs(sorted) do
            local name         = pair.isMethod and (pair.typeName .. ":")
                or (pair.getter.fullName:match("^(.-)%.[^%.]+$") .. ".")
            local getter       = pair.getter.name .. "()"
            local setter       = pair.setter.name .. "()"

            local nameSpaces   = string.rep(" ", maxNameLen - #name)
            local getterSpaces = string.rep(" ", maxGetterLen - #getter)

            print(" • " .. name .. nameSpaces .. getter .. getterSpaces .. " <-> " .. setter)
        end
    end

    return snippets
end

-- Generate enum snippets (standalone, for backwards compatibility)
local function generateEnums(enums)
    local snippets = {}

    for _, enum in ipairs(enums) do
        local constantNames = {}
        for _, const in ipairs(enum.constants) do
            table.insert(constantNames, '"' .. const .. '"')
        end
        local choiceString = table.concat(constantNames, ",")

        local enumKey = "alias " .. enum.fullName
        snippets[enumKey] = createSnippet(
            enum.name,
            { ("${1|%s|}"):format(choiceString) },
            firstSentence(enum.description)
        )
    end

    if debugMode and #enums > 0 then
        debugPrint("Generating enum(alias) snippets...")
        local sortedEnums = {}
        for _, enum in ipairs(enums) do
            table.insert(sortedEnums, enum)
        end
        table.sort(sortedEnums, function(a, b)
            return a.name < b.name
        end)

        local maxLen = 0
        for _, enum in ipairs(sortedEnums) do
            if #enum.name > maxLen then
                maxLen = #enum.name
            end
        end

        for _, enum in ipairs(sortedEnums) do
            local spaces = string.rep(" ", maxLen - #enum.name)
            print(" • " .. enum.name .. spaces .. " " .. #enum.constants)
        end
    end

    return snippets
end

-- Generate snippets for functions
local function generateFunctions(api)
    local snippets = {}

    local function getEnumConstantsFunc(typeName)
        return getEnumConstantsFromApi(typeName, api)
    end

    local processArgument = createArgumentProcessor(getEnumConstantsFunc)

    local function generateParamStringWithEnums(arguments)
        return generateParamString(arguments, processArgument)
    end

    local function addSnippet(fullName, func, variant, vIdx, paramsString)
        local body = {}
        table.insert(body, fullName .. "(" .. paramsString .. ")$0")

        local key = fullName .. "()"
        local prefix = func.name
        if vIdx > 1 then
            key = key .. "_overload" .. vIdx
            prefix = prefix .. vIdx
        end

        snippets[key] = createSnippet(
            prefix,
            body,
            firstSentence(variant.description or func.description or "")
        )
    end

    local function processFunctions(module, modulePath)
        if not module then
            return
        end
        modulePath = modulePath or API.NAME

        if module.functions then
            for _, func in ipairs(module.functions) do
                for vIdx, variant in ipairs(func.variants or {}) do
                    local arguments = expandParameters(variant.arguments or {})
                    local paramsString, _ = generateParamStringWithEnums(arguments)
                    local fullName = modulePath .. "." .. func.name
                    addSnippet(fullName, func, variant, vIdx, paramsString)
                end
            end
        end

        if module.types then
            for _, typ in ipairs(module.types) do
                if typ.functions then
                    for _, func in ipairs(typ.functions) do
                        for vIdx, variant in ipairs(func.variants or {}) do
                            local arguments = expandParameters(variant.arguments or {})
                            local paramsString, _ = generateParamStringWithEnums(arguments)
                            local fullName = modulePath .. "." .. typ.name .. ":" .. func.name
                            addSnippet(fullName, func, variant, vIdx, paramsString)
                        end
                    end
                end
            end
        end

        if module.modules then
            for _, sub in ipairs(module.modules) do
                processFunctions(sub, modulePath .. "." .. sub.name)
            end
        end
    end

    processFunctions(api, API.NAME)

    return snippets
end

-- Generate modules snippets
local function generateModules(modules)
    local snippets = {}
    local prefixes = {}

    -- Collect all module short names
    local moduleShortNames = {}
    for _, module in ipairs(modules) do
        if module ~= API.NAME then
            local shortName = module:gsub("^" .. API.NAME .. "%.", "")
            table.insert(moduleShortNames, { full = module, short = shortName })
        end
    end

    -- Generate unique prefixes
    for _, mod in ipairs(moduleShortNames) do
        local shortName = mod.short
        -- Start with first letter + first letter of shortName (2 letters total)
        local prefix = API.NAME:sub(1, 1) .. shortName:sub(1, 1)
        local pos = 2 -- start from second character position for additional letters

        while true do
            local conflict = false
            for _, other in ipairs(moduleShortNames) do
                if other ~= mod then
                    local otherPrefix = API.NAME:sub(1, 1) .. other.short:sub(1, 1)
                    if pos > 2 then
                        if #other.short >= pos then
                            otherPrefix = API.NAME:sub(1, 1) .. other.short:sub(1, pos - 1)
                        else
                            otherPrefix = API.NAME:sub(1, 1) .. other.short
                        end
                    end
                    if otherPrefix == prefix then
                        conflict = true
                        break
                    end
                end
            end

            if not conflict then
                break
            end

            -- Add next character from the shortName
            if pos <= #shortName then
                prefix = API.NAME:sub(1, 1) .. shortName:sub(1, pos)
                pos = pos + 1
            else
                -- No more letters, use full shortName
                prefix = API.NAME:sub(1, 1) .. shortName
                break
            end
        end

        prefixes[mod.full] = prefix
    end

    -- Generate snippets
    for _, mod in ipairs(moduleShortNames) do
        local body    = { mod.full .. ".${0:}" }
        local key     = mod.full
        snippets[key] = createSnippet(
            { prefixes[mod.full], mod.full },
            body,
            "Insert `" .. mod.full .. ".`"
        )
    end

    if debugMode and #moduleShortNames > 0 then
        debugPrint("Generating module snippets...")

        -- Calculate max widths for alignment
        local maxFullLen = 0
        for _, mod in ipairs(moduleShortNames) do
            local fullLen = #mod.full
            if fullLen > maxFullLen then
                maxFullLen = fullLen
            end
        end

        for _, mod in ipairs(moduleShortNames) do
            local full = mod.full
            local prefix = prefixes[mod.full]
            local fullSpaces = string.rep(" ", maxFullLen - #full)
            print(" • " .. full .. fullSpaces .. " -> prefix: " .. prefix)
        end
    end

    return snippets
end

-- Generate conf snippets
local function generateConf(fields)
    if not fields or #fields == 0 then
        return nil
    end

    local snippets = {}

    local function buildConfBody(firstLine)
        local body           = { firstLine }
        local placeholderIdx = 3
        local lines          = {}

        local previousDepth, previousTop

        local function insertSeparatorIfNeeded(fullName)
            local top   = fullName:match("^[^.]+") or fullName
            local depth = 1
            for _ in fullName:gmatch("%.") do
                depth = depth + 1
            end

            if previousDepth ~= nil then
                if depth ~= previousDepth or top ~= previousTop and depth > 1 then
                    table.insert(lines, { fullName = false })
                end
            end

            previousDepth = depth
            previousTop   = top
        end

        local function collectFields(flds, prefix)
            for _, f in ipairs(flds) do
                local fullName = (prefix or "") .. f.name
                if f.table and type(f.table) == "table" then
                    collectFields(f.table, fullName .. ".")
                else
                    insertSeparatorIfNeeded(fullName)

                    table.insert(lines, {
                        fullName    = fullName,
                        placeholder = placeholderIdx,
                        arg         = { name = f.name, type = f.type, default = f.default },
                    })
                    placeholderIdx = placeholderIdx + 1
                end
            end
        end

        collectFields(fields, "")

        local maxLen = 0
        for _, line in ipairs(lines) do
            if line.fullName then
                local len = #line.fullName
                if len > maxLen then
                    maxLen = len
                end
            end
        end

        for _, line in ipairs(lines) do
            if line.fullName then
                local indent = maxLen - #line.fullName
                local spaces = string.rep(" ", indent)
                local valuePlaceholder = processRegularArgument(line.arg, line.placeholder)

                table.insert(
                    body,
                    string.format("\t${2:t}.%s%s = %s", line.fullName, spaces, valuePlaceholder)
                )
            else
                table.insert(body, "")
            end
        end

        table.insert(body, "end")
        return body
    end

    snippets["function " .. API.NAME .. "." .. API.CONF .. "(t)"] = createSnippet(
        API.CONF .. "f",
        buildConfBody("function " .. API.NAME .. "." .. API.CONF .. "(${2:t})"),
        "`" .. API.CONF .. "` as a regular function"
    )

    snippets[API.NAME .. "." .. API.CONF .. " = function(t)"] = createSnippet(
        API.CONF .. "a",
        buildConfBody(API.NAME .. "." .. API.CONF .. " = function(${2:t})"),
        "`" .. API.CONF .. "` assigned as a function value"
    )

    if debugMode then
        debugPrint(
            "Generated "
            .. sizeOfTable(snippets)
            .. " "
            .. API.CONF
            .. " snippets\n"
        )
    end

    return snippets
end

--------------------------------------------------------------------------------
-- File Writers
--------------------------------------------------------------------------------
-- Write a single JSON file
local function writeJSONFile(filePath, snippets)
    if not snippets or not next(snippets) then
        return 0
    end

    local sortedKeys = {}
    for key in pairs(snippets) do
        table.insert(sortedKeys, key)
    end
    table.sort(sortedKeys)

    local file = io.open(filePath, "w")
    if not file then
        print("   ❌ Error: Could not create " .. filePath)
        return 0
    end

    file:write("{\n")
    for i, key in ipairs(sortedKeys) do
        local data = snippets[key]
        file:write(string.format('\t"%s": {\n', key))

        if type(data.prefix) == "table" then
            file:write('\t\t"prefix": [\n')
            for p, pref in ipairs(data.prefix) do
                local comma = (p < #data.prefix) and "," or ""
                file:write(string.format('\t\t\t"%s"%s\n', escapeJSON(pref), comma))
            end
            file:write("\t\t],\n")
        else
            file:write(string.format('\t\t"prefix": "%s",\n', escapeJSON(data.prefix)))
        end

        file:write(string.format('\t\t"scope": "%s",\n', escapeJSON(data.scope)))

        file:write('\t\t"body": [\n')
        for k, line in ipairs(data.body) do
            local comma = (k < #data.body) and "," or ""
            file:write(string.format('\t\t\t"%s"%s\n', escapeJSON(line), comma))
        end
        file:write("\t\t],\n")

        file:write(string.format('\t\t"description": "%s"\n', escapeJSON(data.description)))

        local comma = (i < #sortedKeys) and "," or ""
        file:write("\t}" .. comma .. "\n")
    end
    file:write("}\n")
    file:close()

    return #sortedKeys
end

-- Write all snippet files
local function writeSnippetFiles(outPath, apiData)
    local snippetsDir = outPath .. "/" .. API.ENGINE
    createDirectory(snippetsDir)

    local stats = { files = 0, snippets = 0 }

    local flatGetterSetter = {}
    if apiData.gettersSetters.snippet then
        for _, moduleSnips in pairs(apiData.gettersSetters.snippet) do
            for key, snip in pairs(moduleSnips) do
                flatGetterSetter[key] = snip
            end
        end
    end

    for name, field in pairs(apiData) do
        if field.snippet and field.filename then
            local snippets = field.snippet
            if name == "gettersSetters" then
                snippets = flatGetterSetter
            end

            if snippets and next(snippets) then
                local count = writeJSONFile(snippetsDir .. "/" .. field.filename, snippets)
                if count > 0 then
                    stats.files = stats.files + 1
                    stats.snippets = stats.snippets + count
                    print(" • Created " ..
                    outputDir .. "/" .. API.ENGINE .. "/" .. field.filename .. " with " .. count .. " snippets")
                end
            end
        end
    end

    return stats
end

-- Write package.json file
local function writePackageJson(outPath, apiData)
    local packageJsonPath = outPath .. "/" .. API.SNIP_PACKAGE .. "." .. API.SNIP_FILE_EXT

    local pkg = io.open(packageJsonPath, "w")

    if not pkg then
        print(" • Warning: Could not create " .. API.SNIP_PACKAGE .. "." .. API.SNIP_FILE_EXT)
        return false
    end

    pkg:write("{\n")
    pkg:write(string.format('\t"name": "%s-snippets",\n', API.ENGINE))
    pkg:write('\t"contributes": {\n')
    pkg:write('\t\t"snippets": [\n')

    local files = {}
    for _, field in pairs(apiData) do
        if field.filename and field.snippet then
            table.insert(files, field.filename)
        end
    end
    table.sort(files)

    for i, filename in ipairs(files) do
        local comma = (i < #files) and "," or ""
        pkg:write(
            string.format(
                '\t\t\t{ "language": ["%s"], "path": "./%s/%s" }%s\n',
                API.TARGET_FILE_EXT,
                API.ENGINE,
                filename,
                comma
            )
        )
    end

    pkg:write("\t\t ]\n")
    pkg:write("\t}\n")
    pkg:write("}\n")
    pkg:close()

    print(" • Created " .. API.SNIP_PACKAGE .. "." .. API.SNIP_FILE_EXT)
    return true
end

--------------------------------------------------------------------------------
-- Statistics
--------------------------------------------------------------------------------
local function printStatistics(apiData)
    print("\n 📊 Statistics:")

    local total = 0
    local fileCount = 0

    for _, field in pairs(apiData) do
        if field.snippet and field.snippet ~= false then
            local count = 0
            if type(field.snippet) == "table" then
                for _ in pairs(field.snippet) do
                    count = count + 1
                end
                if count > 0 then
                    fileCount = fileCount + 1
                end
            elseif type(field.snippet) == "number" then
                count = field.snippet
                if count > 0 then
                    fileCount = fileCount + 1
                end
            end
            total = total + count
            print(string.format(" • %s: %d", field.label, count))
        elseif field.api and field.api ~= false then
            local apiCount = 0
            if type(field.api) == "table" then
                for _ in pairs(field.api) do
                    apiCount = apiCount + 1
                end
            else
                apiCount = #field.api
            end
            print(string.format(" • %s: %d", field.label, apiCount))
            total = total + apiCount
        end
    end

    print(string.format(" • Snippets generated: %d", total))
    print(string.format(" • Files created: %d", fileCount))
end

--------------------------------------------------------------------------------
-- Main Generator Function
--------------------------------------------------------------------------------
local function generateSnippets(api, outPath)
    local apiData = {
        {
            name      = "enums",
            collector = collectEnums,
            generator = generateEnums,
        },
        {
            name      = "functions",
            collector = false,
            generator = generateFunctions,
        },
        {
            name      = "callbacks",
            collector = collectCallbacks,
            generator = generateCallbacks,
        },
        {
            name      = "constructors",
            collector = collectConstructors,
            generator = generateConstructors,
        },
        {
            name      = "gettersSetters",
            collector = collectGettersSetters,
            generator = generateGettersSetters,
        },
        {
            name      = "modules",
            collector = collectModules,
            generator = generateModules,
        },
        {
            name      = API.CONF,
            collector = collectConf,
            generator = generateConf,
        },
    }

    for _, field in ipairs(apiData) do
        local collected = field.collector and field.collector(api) or false
        local snippet

        local args = field.name == "functions" and api or collected
        snippet = field.generator(args)

        apiData[field.name] = {
            api      = collected,
            snippet  = snippet,
            filename = field.name:gsub("([A-Z])", "-%1"):lower() .. "." .. API.SNIP_FILE_EXT,
            label    = field.name:gsub("([A-Z])", " %1"):gsub("^%l", string.upper):gsub("_", " "),
        }
    end

    writeSnippetFiles(outPath, apiData)
    writePackageJson(outPath, apiData)
    printStatistics(apiData)
end

--------------------------------------------------------------------------------
-- Main
--------------------------------------------------------------------------------
print("\n 🔍 Generating " .. API.ENGINE_NAME .. " snippets...")

generateSnippets(apiRequire, outputDir)

print("\n 📁 snippets structure ready in: " .. outputDir)

local completed = os.clock() - time

print(string.format("\n ⏱️  Completed in %.2f ms", completed * 1000))
