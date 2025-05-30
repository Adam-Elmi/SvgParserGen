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

function Parser:singleParse(targetFile, outputPath, outputFile)
    if utils.exists(targetFile) then
        if (outputPath and utils.exists(outputPath)) or (config.default_output_location and utils.exists(config.default_output_location)) then
            local file = utils.getFile(targetFile, "svg")
            if config.default_output_type and config.default_output_type ~= "" then
                if file and outputFile then
                    local template_file = utils.getContent("./templates/react.tpl")
                    print(template_file)
                    local component_file = io.open(
                        string.format("%s/%s.%s", config.default_output_location, outputFile, config.default_output_type),
                        "w")
                    if component_file and template_file then
                        if config.import_as_default then
                            component_file:write(string.format(template_file, "default", "ComponentIcon", "",
                                utils.handleRawSvg(
                                    file.content,
                                    attributes.kebab_attributes,
                                    attributes.special_attributes
                                )))
                        else
                            component_file:write(string.format(template_file, "", "ComponentIcon", "",
                                utils.handleRawSvg(
                                    file.content,
                                    attributes.kebab_attributes,
                                    attributes.special_attributes
                                )))
                        end
                        component_file:close()
                    else
                        print(select(2,
                            utils.customError("File Error", "Failed to open file for writing: " .. outputFile)))
                    end
                end
            end
        else
            return select(2,
                utils.customError("Path Error",
                    string.format("%s is invalid path! Please provide a valid output path.",
                        (outputPath or config.default_output_location))))
        end
    else
        return select(2,
            utils.customError("Path Error", "Target path is invalid path! Please provide a valid target path."))
    end
end

return Parser
