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

function utils.getFile(path)
    if path and type(path) == "string" then
        local file = io.open(utils.winPathFormat(path), "r")
        if file then
            local extension = string.match(path, "%.svg$")
            local content = file:read("*a")
            file:close()
            return {
                extension = extension,
                content = content
            }
        else
            return "File is not found!"
        end
    else
        local _, result = utils.customError("Error", "Path must be defined and a string type")
        return result
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
        local _, result = utils.customError("Error", "Path must be defined and a string type")
        return result
    end
end

return utils
