local config = require("config")
function dump(o)
    if type(o) == 'table' then
        local s = '{ '
        for k, v in pairs(o) do
            if type(k) ~= 'number' then k = '"' .. k .. '"' end
            s = s .. '[' .. k .. '] = ' .. dump(v) .. ','
        end
        return s .. '} '
    else
        return tostring(o)
    end
end

local parser = {}

---utility func
---@param str string
---@param substr string
---@return number
local function find_last_index(str, substr)
    local last_index = -1

    for i = #str, 1, -1 do
        local index = string.find(str, substr, i, true)
        if index then
            last_index = index
            break
        end
    end

    return last_index
end

---utility func
local function isSpecialType(r)
    return (r
        and r ~= 'String'
        and r ~= 'Boolean'
        and r ~= 'Number'
        and r ~= 'Numbers'
        and r ~= 'Constant'
        and r ~= 'Function'
        and r ~= 'Array'
        and r ~= 'Table'
        and r ~= 'TYPE'
        and r ~= 'Object'
        and r ~= 'Library'
        and r ~= 'Module'
        and r ~= 'CoronaClass'
        and r ~= 'Event'
        and r ~= 'Listener'
    -- and r ~= 'Userdata'
    )
end


---To get a folder name and file name
---@param str string
---@return string
function GetLastPathItem(str)
    local lastSlashIndex = find_last_index(str, "/")
    if lastSlashIndex == -1 then
        return ""
    end
    return string.sub(str, lastSlashIndex + 1)
end

local function extractInfo(filename)
    local parent
    local overview = ""
    local i = 0
    local inOverview = false
    local f = io.open(filename, 'r')
    if f == nil then return end
    for l in f:lines() do
        i = i + 1
        if l:find("^> __Parent__") then
            parent = l:match("%[(.-)%]")
        elseif l:find("Overview") then
            inOverview = true
        elseif inOverview then
            if l:find("##") then
                inOverview = false
            else
                overview = overview .. l
            end
        end
    end
    f:close()
    return parent, overview
end

---utility func
---@param s string
---@param piece string
---@return boolean
local function startswith(s, piece)
    return string.sub(s, 1, string.len(piece)) == piece
end

---utility func
local function beforeComma(line)
    for i = 1, line:len() do
        if line:sub(i, i) == '.' then
            return line:sub(1, i - 1)
        end
    end
    return line
end

--- @class TitleContent
--- @field d string
--- @field t string

---Gets everything inside a Header in markdown
---@param markdown_text string
---@param heading string
---@return table<TitleContent>
local function parseTitles(markdown_text, heading)
    local content = {}
    local index = 1
    for line in markdown_text:gmatch("([^\n]*)\n?") do
        if content[index] == nil then
            content[index] = { t = "global", d = "" }
        end
        if string.match(line, "^" .. heading .. " .+$") then
            index = index + 1
            content[index] = { t = line:gsub(heading .. " ", ""), d = "" }
        else
            content[index].d = content[index].d .. "\n" .. line
        end
    end

    return content
end

--- @class ExtractedArg
--- @field name string
--- @field type string
--- @field optional boolean
--- @field docs string

--- @class ExtractedMethod
--- @field arguments table<ExtractedArg>
--- @field name string


--- @class ExtractedData
--- @field type string
--- @field methods table<ExtractedMethod>
--- @field docs string
--- @field returnv string | nil


---utility func
---@param str string
---@return string
local function extractStringBetweenBrackets(str)
    local start, stop = string.find(str, "%[(.-)%]")
    if start and stop then
        return string.sub(str, start + 1, stop - 1)
    else
        return ""
    end
end
---Removes unnecesary things from a name
---@param str string
---@return string
local function cleanTitle(str)
    ---@type string
    local p = string.gsub(str, " ~%^%(required%)%^~", "")
    p = string.gsub(p, " ~%^%(optional%)%^~", "")
    p = string.gsub(p, "%[...%]", "...")
    p = string.gsub(p, "%[", "")
    p = string.gsub(p, "%]", "")
    p = string.gsub(p, " ", "")
    return p
end


---@param input string
---@return string
local function extractArgumentDocs(input)
    if not config.generate_arguments_docs then
        return ""
    end
    local pattern = "_%b[]%b[]%._ "
    local s = string.gsub(input, "\n", "")
    s = string.gsub(s, pattern, "")
    return s
end

---Parse arguments from text
---@param arg TitleContent
---@param data ExtractedMethod
local function generateArgument(arg, data)
    local sepnames = (arg.t .. ","):gmatch("(.-),")
    for compname in sepnames do
        for singlename in (compname .. "/"):gmatch("(.-)/") do
            local argument = {
                name = cleanTitle(singlename),
                type = extractStringBetweenBrackets(arg.d),
                docs = extractArgumentDocs(arg.d),
                optional = not (arg.t:find("optional") == nil)
            } --[[@as ExtractedArg]]
            data.arguments[#data.arguments + 1] = argument
        end
    end
end

---comment
---@param raw string
---@param data ExtractedData
---@param title string
local function genMethod(raw, data, title)
    if title ~= "main" and title == "global" then
        return
    end
    local args = parseTitles(raw, "#####")

    ---@type ExtractedMethod
    local method = {
        name = title,
        arguments = {}
    }
    for _, arg in ipairs(args) do
        if not (arg.t == "global") then
            generateArgument(arg, method)
        end
    end

    data.methods[#data.methods + 1] = method
end

---comment
---@param filename string
---@return ExtractedData
local function extractTypeArgsReturns(filename)
    local data = {
        type = "",
        methods = {},
        docs = ""
    } --[[@as ExtractedData]]
    local f = io.open(filename, 'r')
    if f == nil then return data end
    local blocks = parseTitles(f:read("a"), "##")
    for _, value in ipairs(blocks) do
        local ccc = value.d --[[@as string]]
        if value.t == "global" then
            -- Parse general info here
            for line in ccc:gmatch("([^\n]*)\n?") do
                if startswith(line, '> __Type__') then
                    data.type = line:match('%[api%.type%.(%a*)%]', 1):lower()
                elseif startswith(line, '> __Return value__') then
                    data.returnv = line:match('%[(%a*)%]', 1)
                end
            end
        elseif value.t == "Overview" then
            data.docs = string.gsub(value.d, "\n", " ") .. "\n"
        elseif value.t == "Syntax" then
            -- Parse function info here
            local variants = parseTitles(ccc, "###")
            if #variants == 1 then
                genMethod(ccc, data, "main")
            else
                for _, variant in ipairs(variants) do
                    genMethod(variant.d, data, variant.t)
                end
            end
        elseif value.t == "Example" or value.t == "Examples" then
            -- Parse for documentation, todo
        end
    end
    f:close()
    return data
end

---Parses a markdown file to a buffer
---@param path string
---@param name string
---@param buffer table
function parser.parseFile(path, name, buffer)
    local data = extractTypeArgsReturns(path)
    buffer.childs[beforeComma(name)] = data
end

---comment
---@param category string
---@param name string
---@param api table
---@return string
function parser.parseSingleFile(category, name, api)
    local package = beforeComma(name)
    if api[package] == nil then
        api[package] = { type = "", description = '', childs = {}, category = category }
    end
    return package
end

---Parses and sets a directory to a buffer
---@param path string
---@param buffer table
---@param force boolean
function parser.parseIndex(path, buffer, force)
    local parent, overview = extractInfo(path)
    if parent and (isSpecialType(parent) or force) then buffer.inherits = parent end
    buffer.overview = overview
end

return parser
