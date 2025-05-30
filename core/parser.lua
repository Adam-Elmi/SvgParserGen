local config = require("config")
local utils = require("core.utils")

local Parser = {}
Parser.__index = Parser
setmetatable(Parser, {})

function Parser:new()
    local obj = {}
    setmetatable(obj, self)
    return obj
end

function Parser:singleParse(targetFile, outputPath)
    if targetFile then
        if outputPath and outputPath ~= "" or config.default_output_location and config.default_output_location ~= "" then
            return true
        else
            local _, error = utils.customError(utils.colorize("Path Error:", "red"),
                utils.colorize("Output path is not provided! Please provide the output path.", "magenta"))
                return error
        end
    else
        local _, error = utils.customError(utils.colorize("Path Error:", "red"),
            utils.colorize("Target path is not provided! Please provide the target path.", "magenta"))
            return error
    end
end

print(Parser:singleParse("Hello"))
