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

function Parser:toJSX(targetFile, outputPath, outputFile)
    if utils.exists(targetFile) then
        if (outputPath and utils.exists(outputPath)) or (config.default_output_location and utils.exists(config.default_output_location)) then
            local file = utils.getFile(targetFile, "svg")
            if config.default_output_type and config.default_output_type ~= "" then
                if file and outputFile then
                    if file.content and file.content ~= "" then
                        if string.match(targetFile, "%.svg$") then
                            local compName = (config.default_component_name ~= "" and config.default_component_name) or
                            "ComponentIcon"
                            local template_file = utils.getContent("./templates/react.tpl")
                            local component_file = io.open(
                                string.format("%s/%s.%s", outputPath, outputFile, config.default_output_type),
                                "w")
                            if component_file and template_file then
                                if config.import_as_default then
                                    component_file:write(string.format(template_file, "default", compName, "",
                                        utils.handleRawSvg(
                                            file.content,
                                            attributes.kebab_attributes,
                                            attributes.special_attributes
                                        )))
                                else
                                    component_file:write(string.format(template_file, "", compName, "",
                                        utils.handleRawSvg(
                                            file.content,
                                            attributes.kebab_attributes,
                                            attributes.special_attributes
                                        )))
                                end
                                component_file:close()
                            else
                                if outputFile then
                                    print(select(2,
                                        utils.customError("File Error", "Failed to open file for writing: " .. outputFile)))
                                end
                            end
                        else
                            print(select(2, utils.customError(
                                "Extension Error",
                                string.format(
                                    "Invalid extension file! The target file '%s' must have a .svg extension, but got '.%s'. Please provide a valid SVG file.",
                                    targetFile,
                                    file.extension or "unknown"
                                )
                            )))
                        end
                    end
                    print(select(2, utils.customError(
                        "File Error",
                        string.format(
                            "The SVG file '%s' is empty or not valid. Please make sure the file has SVG content.",
                            targetFile)
                    )
                    ))
                end
            end
        else
            return select(2,
                utils.customError("Path Error",
                    string.format("%s is invalid path! Please provide a valid output path.",
                        (outputPath or config.default_output_location))))
        end
    else
        print(select(2,
            utils.customError(
                "File Error",
                string.format(
                    "The specified file '%s' was not found or could not be accessed. Please check that the file exists and the path is correct.",
                    targetFile
                )
            )))
    end
end

return Parser
