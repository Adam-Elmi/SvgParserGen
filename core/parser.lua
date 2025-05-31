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


local function handleAttr(content, attr, sep)
    if content and attr then
        for _, v in ipairs(attr) do
            if v then
                if sep == "-" then
                    local camelCaseValue = utils.toCamelCase(v, sep)
                    local safeValue = utils.escape_pattern(v)
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
                    local safeValue = utils.escape_pattern(v)
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

local function handleRawSvg(content, kebab_attributes, special_attributes)
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

local function handleJSX(content)
    local kebab_attri = {}
    for _, v in ipairs(attributes.kebab_attributes) do
        kebab_attri[v] = utils.toCamelCase(v, "-")
    end
    if content then
        local svg_content = string.match(content, "<svg.-</svg>")
        if svg_content then
            for k, v in pairs(kebab_attri) do
                svg_content = string.gsub(svg_content, v, k)
            end
            for _, v in ipairs(attributes.special_attributes) do
                if v == "class" then
                    svg_content = string.gsub(svg_content, "className", v)
                elseif v == "xlink:href" then
                    svg_content = string.gsub(svg_content, "xlinkHref", v)
                end
            end
            return svg_content
        end
    end
end

local function missingFile(file, outputFile)
    local missing = {}
    if not file then table.insert(missing, "file") end
    if not outputFile then table.insert(missing, "outputFile") end
    print(select(2,
        utils.customError(
            "File Error",
            string.format(
                "The specified %s was not found or could not be accessed. Please check that the %s exists and the path is correct.",
                table.concat(missing, " and "),
                table.concat(missing, " and ")
            )
        )))
end

local function emptyContent(targetFile)
    print(select(2, utils.customError(
        "File Error",
        string.format(
            "The SVG file '%s' is empty or not valid. Please make sure the file has SVG content.",
            targetFile)
    )
    ))
end

function Parser:toJSX(targetFile, outputPath, outputFile, componentName)
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
                                    component_file:write(string.format(template_file, "default",
                                        (componentName and componentName ~= "" and componentName or compName), "",
                                        handleRawSvg(
                                            file.content,
                                            attributes.kebab_attributes,
                                            attributes.special_attributes
                                        )))
                                else
                                    component_file:write(string.format(template_file, "",
                                        (componentName and componentName ~= "" and componentName or compName), "",
                                        handleRawSvg(
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
                    else
                        emptyContent(targetFile)
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

function Parser:toSVG(targetFile, outputPath, outputFile)
    if utils.exists(targetFile) then
        local file = utils.getFile(targetFile, "jsx")
        if file and outputFile then
            if outputPath or (config.default_output_location and config.default_output_location ~= "") then
                if file.content and file.content ~= "" then
                    local newFile = io.open(string.format("%s/%s.%s", outputPath, outputFile, "svg"), "w")
                    if newFile then
                        newFile:write(handleJSX(file.content))
                    end
                else
                    emptyContent(targetFile)
                end
            else
                print(select(2,
                    utils.customError(
                        "Path Error",
                        string.format(
                            "The specified path '%s' was not found or could not be accessed. Please check that the path is correct.",
                            config.default_output_location
                        )
                    )))
            end
        else
            missingFile(file, outputFile)
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

Parser:toSVG("./generated/hello.jsx", "./core/example", "new.test")
return Parser
