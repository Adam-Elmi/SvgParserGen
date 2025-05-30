local config = require("config")
local utils = require("core.utils")
local attributes = require("core.attributes")

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
            local file = utils.getFile(targetFile, "svg")
            if config.default_output_type and config.default_output_type ~= "" then
                if file then
                    print(file)
                    return utils.handleAttributes(file.content, attributes.kebab_attributes,
                        attributes.special_attributes)
                end
            end
        else
            return select(2, utils.customError(utils.colorize("Path Error", "red"),
                utils.colorize("Output path is not provided! Please provide the output path.", "magenta")))
        end
    else
        return select(2, utils.customError(utils.colorize("Path Error", "red"),
            utils.colorize("Target path is not provided! Please provide the target path.", "magenta")))
    end
end

print(Parser:singleParse("./core/example/test.svg"))
