local config = require("config")
local errors = require("core.errors")
local ansi = require("core.ansi")

local utils = {}

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
            local ext = string.match(path, "%.(.+)")
            local content = file:read("*a")
            file:close()
            if content and content ~= "" then
                return {
                    extension = ext,
                    content = content
                }
            else
                errors.contentError()
            end
        else
            errors.fileError()
        end
    else
        errors.fileError()
    end
end

function utils.getFileName(text)
    if text and type(text) == "string" then
        for file in string.gmatch(text, "([^/]+)%.%w+$") do
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
                    files[index] = utils.getFileName(line)
                    index = index + 1
                end
                handle:close()
            end
        end
        return files
    else
        errors.fileError()
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

function utils.exists(path)
    return os.rename(path, path) ~= nil
end

function utils.addPadding(items, label, len)
    local maxLength = 0
    if items then
        for k, _ in pairs(items) do
            if #k > maxLength then
                maxLength = #k
            end
        end
    end
    local pad_len = len and (maxLength - #label + len) or maxLength - #label
    return ansi.colorize(label, "magenta") .. string.rep(" ", pad_len)
end

function utils.getContent(path)
    if path and path ~= "" then
        local file = io.open(path, "r")
        if file then
            local content = file:read("*a")
            file:close()
            if content ~= "" then
                return content
            else
                errors.contentError()
            end
        else
            errors.fileError()
        end
    end
end

function utils.getFileDetails(file, args)
    local size = 0
    if file then
        file:seek("end")
        size = file:seek()
        file:close()
    end
    local ext = config.default_output_type
    local location = config.default_output_location
    local now = os.date("*t")
    local date_str = string.format("%04d-%02d-%02d", now.year, now.month, now.day)
    local time_str = string.format("%02d:%02d:%02d", now.hour, now.min, now.sec)
    print(ansi.colorize(
        "Succefully created " ..
        ansi.colorize(args[4] .. "." .. config.default_output_type, "bright_yellow") ..
        " in " .. ansi.colorize(config.default_output_location, "blue"), "bright_green"))
    print(ansi.colorize("File Details:", "magenta"))
    print("  Name: " .. ansi.colorize((config.use_same_name and utils.getFileName(args[2]) or args[4]) .. "." .. ext, "bright_yellow"))
    print("  Location: " .. ansi.colorize(location, "blue"))
    print("  Extension: " .. ansi.colorize(ext, "cyan"))
    print("  Size: " .. ansi.colorize(string.format("%.2f kb", size / 1024), "bright_green"))
    print("  Date: " .. ansi.colorize(date_str, "bright_blue"))
    print("  Time: " .. ansi.colorize(time_str, "bright_blue"))
end

function utils.lastIndex(str, substr)
    local str_table = {}
    local maxLength = 0
    if (str and str ~= "") and substr then
        for char in string.gmatch(str, "%S") do
            table.insert(str_table, char)
        end

        for i, v in ipairs(str_table) do
            if v == substr then
                if i > maxLength then
                    maxLength = i
                end
            end
        end
    end
    return maxLength
end

return utils