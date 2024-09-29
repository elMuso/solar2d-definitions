local API = {}
local config = require("config")
local parser = require("parser")
local serpent = require('serpent')
local generator = require('generator')
-- local lfs = require("lfs")
local DIR_SEP = '/'


local function getFileList(path)
    local i, t, popen = 0, {}, io.popen
    for filename in popen('dir "' .. path .. '" /b'):lines() do
        i = i + 1
        t[i] = path .. DIR_SEP .. filename
    end
    return t
end



---Iterates over markdown files and folders
---@param list table<string> actual files and directories
---@param category string  the actual folder name as a package
---@param pck string | nil the actual folder name as a package
local function processApiDir(list, category, pck)
    --- @param path string
    for _, path in ipairs(list) do
        local package = pck
        local name = GetLastPathItem(path)
        local isFile = name:find("%.markdown")
        local pch = pck
        if pch == nil then
            pch = parser.beforeComma(name)
        end
        if name:match("event") then
            category = "library"
            pch = "event"
        end
        if pch ~= nil then
            for _, value in ipairs(config.excluded_folders) do
                --     print(name)

                if value == category .. "_" .. pch then
                    goto skip_to_next
                end
            end
        end

        if package == nil then
            local lp = parser.parseSingleFile(category, name, API)
            parser.parseIndex(path, API[lp], true)
        end
        if isFile and package ~= nil then
            -- Is file
            if name == 'index.markdown' then
                -- parser.parseOverview(path, API[package])
                parser.parseIndex(path, API[package], false)
            else
                parser.parseFile(path, name, API[package])
            end
        elseif not isFile then
            -- Is folder
            local lsat = getFileList(path)
            API[name] = { type = "", description = '', childs = {}, category = category }
            processApiDir(lsat, category, name)
        end
        ::skip_to_next::
    end
end
local function dirLookup(dir, subdirs)
    for _, value in ipairs(subdirs) do
        local list = getFileList(dir .. DIR_SEP .. value)
        processApiDir(list, value, nil)
    end
end



-- processApiDir('library', 'lib')
dirLookup("corona-docs/markdown/api", { "library", "type" })
generator.lua(API)
local file = io.open("solarparsed.lua", "w")
if file then
    file:write("local api = " .. serpent.line(API, { indent = ' ', comment = false }))
    file:close()
end
