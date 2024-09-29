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
---@param funcName string
---@param returnvalue string | nil
---@return string
local function genLuaDocs(input, funcName, returnvalue)
    local o = ""
    local className = config.single_argument_functions[funcName]
    if className ~= nil then
        o = o .. "---@class " .. className .. "\n"
        for _, value in ipairs(input.arguments) do
            o = o .. "--- @field " .. value.name .. " " .. translateLuaType(value.type)
            if value.optional == true then
                o = o .. "?"
            end
            o = o .. " " .. value.docs .. "\n"
        end
        o = o .. "\n\n--- @param " .. className .. " " .. className .. "\n"
    else
        for _, value in ipairs(input.arguments) do
            o = o .. "--- @param " .. value.name .. " " .. translateLuaType(value.type)
            if value.optional == true then
                o = o .. "?"
            end
            o = o .. " " .. value.docs .. "\n"
        end
    end

    if returnvalue then
        o = o .. "--- @returns " .. translateLuaType(returnvalue) .. "\n"
    end
    return o
end

---Generates everything that will go inside (this,type,ofparams) to match the docs
---@param input ExtractedMethod
---@param funcName string
---@return string
local function genLuaParams(input, funcName)
    local o = ""
    local className = config.single_argument_functions[funcName]
    if className ~= nil then
        o = className
    else
        for i, value in ipairs(input.arguments) do
            if i ~= 1 then
                o = o .. ", "
            end
            o = o .. value.name
        end
    end

    return o
end


---@param method ExtractedMethod
---@param funcName string
---@param returnval string|any
---@return string
local function genLuaOverloads(method, funcName, returnval)
    local needsOverload = false
    local prevOptional = false
    -- For quick checking for overloads
    ---@param arg ExtractedArg
    for _, arg in ipairs(method.arguments) do
        -- If there is a non optional argument after an optional one
        if prevOptional and arg.optional == false then
            needsOverload = true
        end
        prevOptional = arg.optional
    end

    local out = ""

    if config.custom_overloads[funcName] ~= nil then
        for _, overload in ipairs(config.custom_overloads[funcName]) do
            out = out .. "---@overload fun " .. overload
            if returnval then
                out = out .. ":" .. translateLuaType(returnval)
            end
            out = out .. "\n"
        end
    else
        if needsOverload and config.single_argument_functions[funcName] == nil then
            print("A function has been detected that Needs overloading:")
            print(funcName)
        end
    end
    return out
end

---With some magic, generate functions for lualsp
---@param category string
---@param key string
---@param cname string
---@param value ExtractedData
---@return string
local function generateLua(category, key, cname, value)
    if value.type == "function" then
        local sstr = "---" .. value.docs
        ---@param method ExtractedMethod
        for _, method in ipairs(value.methods) do
            local funcName = cname
            if key ~= "global" then
                funcName = key .. "." .. funcName
            end

            sstr = sstr .. genLuaDocs(method, funcName, value.returnv)
            if category == "type" then
                sstr = sstr .. "---@param self any\n"
            end
            sstr = sstr .. genLuaOverloads(method, funcName, value.returnv)
            sstr = sstr .. "function " .. funcName .. "("
            if category == "type" then
                sstr = sstr .. "self"
                if #method.arguments > 0 then
                    sstr = sstr .. ", "
                end
            end
            sstr = sstr .. genLuaParams(method, funcName) .. ") end\n\n"
        end
        return sstr
    end
    return ""
end

---Generates classes for luaLsp
---@param category string
---@param name string
---@param args any
---@param inherits string|nil
---@return unknown
local function generateLuaClass(category, name, args, inherits)
    local o = "---@class " .. name .. "\n"
    if inherits ~= nil then o = "---@class " .. name .. ": " .. translateLuaType(inherits) .. "\n" end
    for cname, cvalue in pairs(args) do
        if cvalue.type ~= "function" then
            o = o .. "---@field " .. cname .. " " .. translateLuaType(cvalue.type) .. "\n"
        end
    end

    if category == "type" or config.imported_libraries[name] ~= nil then
        return o .. "local " .. name .. " = {}\n\n"
    end
    return o .. name .. " = {}\n\n"
end

---Generates lua anotations based on a lua table API
---@param input table
function generator.lua(input)
    for key, value in pairs(input) do
        local generate = true
        local filename = key
        if value.category == "type" then
            filename = value.category .. "_" .. key
        end
        local outpath = "out/" .. filename .. ".lua"
        local o = "---@meta\n\n"
        if value.overview ~= nil and config.generate_class_docs then
            o = o .. "---" .. value.overview .. "\n"
        end
        o = o .. generateLuaClass(value.category, key, value.childs, value.inherits)
        for cname, cvalue in pairs(value.childs) do
            o = o .. generateLua(value.category, key, cname, cvalue)
        end

        if config.imported_libraries[key] ~= nil then
            o = o .. "return " .. key .. "\n"
        end


        local file2 = io.open(outpath, "w")
        if file2 then
            file2:write(o)
            file2:close()
        end
    end
end

return generator
