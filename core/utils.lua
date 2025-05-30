local config = require("config")

local utils = {}

function utils.customError(errorTitle, errorMessage)
    local function throwError()
        error(utils.colorize(errorTitle, "red") .. ": " .. utils.colorize(errorMessage, "magenta"))
    end

    local function errorHandler(err)
        return utils.colorize("Caught Error: ", "red") .. utils.colorize(err, "yellow")
    end

    local ok, result = xpcall(throwError, errorHandler)
    return ok, result
end

function utils.colorize(text, color)
    local colors = {
        reset = "\27[0m",
        red = "\27[31m",
        green = "\27[32m",
        yellow = "\27[33m",
        blue = "\27[34m",
        magenta = "\27[35m",
        cyan = "\27[36m",
        white = "\27[37m",
        black = "\27[30m",
        bright_black = "\27[90m",
        bright_green = "\27[92m",
        bright_yellow = "\27[93m",
        bright_blue = "\27[94m",
        bright_white = "\27[97m",
    }

    text = text or ""

    return (colors[color] or colors.reset) .. text .. colors.reset
end

function utils.getPlatform()
    local sep = package.config:sub(1, 1)

    if sep == "\\" then
        return "windows"
    else
        return "other_platform"
    end
end

function utils.winPathFormat(path)
    if path and config.use_windows_format_path then
        if utils.getPlatform() == "windows" then
            path = string.gsub(path, "/", "\\")
            return path
        else
            return path
        end
    end
end

local function includes(contents, value)
    if contents then
        if value and value ~= "" and type(value) == "string" then
            if contents[value] then
                return true
            else
                return false
            end
        end
    end
end


function utils.getFile(path, extension)
    if path and type(path) == "string" then
        local file = io.open(utils.winPathFormat(path), "r")
        if file then
            if extension and extension ~= "" then
                if includes(config.accepted_extensions, extension) then
                    local ext = string.match(path, "%." .. string.format("%s$", extension))
                    local content = file:read("*a")
                    file:close()
                    if content and content ~= "" then
                        return {
                            extension = ext,
                            content = content
                        }
                    else
                        return select(2, utils.customError("Content Error",
                            "File content is empty!"))
                    end
                else
                    return select(2, utils.customError("Extension Error", "Extension is not supported!"))
                end
            else
                return select(2, utils.customError("Extension Error",
                    "Extension is not provided! Please provide the extension"))
            end
        else
            return select(2, utils.customError("Error", "Path must be defined and a string type"))
        end
    else
        return select(2, utils.customError("Error", "Path must be defined and a string type"))
    end
end

local function getFileName(text)
    if text and type(text) == "string" then
        for file in string.gmatch(text, "[%w%._%-]+%.svg") do
            return file
        end
    end
end

local index = 1

function utils.getFiles(path)
    local files = {}
    if path and type(path) == "string" then
        if utils.getPlatform() == "windows" then
            local handle = io.popen("dir " .. utils.winPathFormat(path))
            if handle then
                for line in handle:lines() do
                    files[index] = getFileName(line)
                    index = index + 1
                end
                handle:close()
            end
        end
        return files
    else
        return select(2, utils.customError("Error", "Path must be defined and a string type"))
    end
end

function utils.split(str, sep)
    local result = {}
    if str and str ~= "" then
        for match in string.gmatch(str, "([^" .. sep .. "]+)") do
            table.insert(result, match)
        end
        return result
    end
end

function utils.toCamelCase(text, sep)
    local parts = utils.split(text, sep)
    local result = ""
    for i = 1, #parts do
        if i == 1 then
            result = result .. string.lower(parts[i])
        else
            result = result .. string.upper(string.sub(parts[i], 1, 1)) .. string.lower(string.sub(parts[i], 2))
        end
    end
    return result
end

function utils.escape_pattern(s)
    return s:gsub("([^%w])", "%%%1")
end

local function handleAttr(content, attributes, sep)
    if content and attributes then
        for _, v in ipairs(attributes) do
            if v then
                if sep == "-" then
                    local camelCaseValue = utils.toCamelCase(v, sep)
                    local safeValue = v:gsub("([^%w])", "%%%1")
                    content = string.gsub(content, safeValue, camelCaseValue)
                elseif sep == "special" then
                    local specialValue = ""
                    if v == "class" then
                        specialValue = "className"
                    elseif v == "xlink:href" then
                        specialValue = "xlinkHref"
                    else
                        return select(2, utils.customError("Special Error", "Unrecognized special attribute"))
                    end
                    local safeValue = v:gsub("([^%w])", "%%%1")
                    content = string.gsub(content, safeValue, specialValue)
                else
                    return select(2, utils.customError("Error", "Separator is undefined or invalid"))
                end
            else
                return select(2, utils.customError("Content Error", "Attribute is nil or false"))
            end
        end
    end
    return content
end


function utils.handleAttributes(content, kebab_attributes, special_attributes)
    if content then
        if kebab_attributes and #kebab_attributes > 0 then
            content = handleAttr(content, kebab_attributes, "-")
        end
        if special_attributes and #special_attributes > 0 then
            content = handleAttr(content, special_attributes, "special")
        end
        return content
    end
end

return utils
