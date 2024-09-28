local config = require("config")

local generator = {}

---This function removes inconsistencies between naming on markdown
local function translateLuaType(type)
    if type == "Table" then return "table" end
    if type == "String" then return "string" end
    if type == "Boolean" then return "boolean" end
    if type == "Number" then return "number" end
    if type == "Numbers" then return "number" end
    if type == "Function" then return "function" end
    if type == "Userdata" then return "userdata" end
    if type == "stageobject" then return "StageObject" end
    if type == "displayobject" then return "DisplayObject" end
    if type == "groupobject" then return "GroupObject" end
    if type == "Object" then return "table" end
    if type == "constant" then return "Constant" end
    if type == "index" then return "any" end
    if type == "json.encode()" then return "any" end
    if type == "audio.loadSound()" then return "table" end
    if type == "paint" then return "Paint" end
    if type == "CoronaClass" then return "CoronaPrototype" end
    if type == "path" then return "Path" end
    if type == "" then return "any" end
    return type
end

---Generates a nice lualsp header for each function, class, etc
---@param input ExtractedMethod
---@param returnvalue string | nil
---@return string
local function genLuaDocs(input, returnvalue)
    local o = ""

    for _, value in ipairs(input.arguments) do
        o = o .. "--- @param " .. value.name .. " " .. translateLuaType(value.type) .. " "
        if value.optional == true then
            o = o .. "| nil "
        end
        o = o .. value.docs .. "\n"
    end
    if returnvalue then
        o = o .. "--- @returns " .. translateLuaType(returnvalue) .. "\n"
    end
    return o
end

---Generates everything that will go inside (this,type,ofparams) to match the docs
---@param input ExtractedMethod
---@return string
local function genLuaParams(input)
    local o = ""
    for i, value in ipairs(input.arguments) do
        if i ~= 1 then
            o = o .. ", "
        end
        o = o .. value.name
    end
    return o
end

---With some magic, generate functions for lualsp
---@param key string
---@param cname string
---@param value ExtractedData
---@return string
local function generateLua(key, cname, value)
    if value.type == "function" then
        local sstr = "---" .. value.docs
        ---@param method ExtractedMethod
        for _, method in ipairs(value.methods) do
            sstr = sstr .. genLuaDocs(method, value.returnv) .. "function "
            if key ~= "global" then
                sstr = sstr .. key .. "."
            end
            sstr = sstr .. cname .. "(" .. genLuaParams(method) .. ") end\n\n"
        end
        return sstr
    end
    return ""
end

---Generates classes for luaLsp
local function generateLuaClass(name, args, inherits)
    local o = "---@class " .. name .. "\n"
    if inherits ~= nil then o = "---@class " .. name .. ": " .. translateLuaType(inherits) .. "\n" end
    for cname, cvalue in pairs(args) do
        if cvalue.type ~= "function" then
            o = o .. "---@field " .. cname .. " " .. translateLuaType(cvalue.type) .. "\n"
        end
    end
    return o .. "local " .. name .. " = {}\n\n"
end

---Generates lua anotations based on a lua table API
---@param input table
function generator.lua(input)
    for key, value in pairs(input) do
        local generate = true
        local outpath = "out/" .. value.category .. "_" .. key .. ".lua"
        local o = "---@meta\n\n"
        if value.overview ~= nil and config.generate_class_docs then
            o = o .. "---" .. value.overview .. "\n"
        end
        o = o .. generateLuaClass(key, value.childs, value.inherits)
        for cname, cvalue in pairs(value.childs) do
            o = o .. generateLua(key, cname, cvalue)
        end
        for _, fold in pairs(config.exluded_folders) do
            if outpath:match(fold) then
                generate = false
            end
        end
        if generate then
            local file2 = io.open(outpath, "w")
            if file2 then
                file2:write(o)
                file2:close()
            end
        end
    end
end

return generator
