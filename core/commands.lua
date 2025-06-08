local config = require("config")
local utils = require("core.utils")
local project = require("project")
local parser = require("core.parser")
local errors = require("core.errors")

local commands = {}
local args = arg or {}

function commands.info()
    if project then
        if args[1] == "-v" or args[1] == "--version" or args[1] == "--name" or args[1] == "-d" or args[1] == "--description" then
            print(
                utils.colorize(project.name, "bright_blue") .. " - " ..
                utils.colorize(project.version, "green") .. " \n- " ..
                utils.colorize(project.description, "bright_blue")
            )
        elseif args[1] == "--author" then
            print(utils.colorize(project.author, "bright_blue"))
        elseif args[1] == "--license" then
            print(utils.colorize(project.license, "green"))
        elseif args[1] == "-gh" or args[1] == "--github" then
            print(utils.addPadding(project.github, "username:", 2) .. utils.colorize(project.github.username, "blue"))
            print(utils.addPadding(project.github, "repo:", 2) .. utils.colorize(project.github.repo, "blue"))
            print(utils.addPadding(project.github, "homepage:", 2) .. utils.colorize(project.github.homepage, "blue"))
            print(utils.addPadding(project.github, "readme:", 2) .. utils.colorize(project.github.readme, "blue"))
            print(utils.addPadding(project.github, "issue:", 2) .. utils.colorize(project.github.issue, "blue"))
        end
    end
end

function commands.toJsxFile()
    if config and config.default_output_location and config.default_output_location ~= "" then
        if args[1] == "-jsx" and args[2] and (args[3] == "-o" or args[3] == "--output") and args[4] and args[5] == "-c" then
            local file_path = config.default_output_location .. "/" .. (config.use_same_name and utils.getFileName(args[2]) or args[4]) .. "." .. "jsx"
            local file = io.open(file_path, "r")
            local tarFile = utils.getFile(args[2])
            if string.match(args[2], "%.svg$") and tarFile.content and tarFile.content ~= "" then
                utils.getFileDetails(file, args)
                return parser:toJSX(args[2], config.default_output_location,
                    (config.use_same_name and utils.getFileName(args[2]) or args[4]), args[6] or "Custom")
            else
                errors.extensionError(args[2], "svg", tarFile.extension)
            end
        else
            errors.commandError();
        end
    else
        if args[1] == "-jsx" and args[2] and (args[3] == "-o" or args[3] == "--output") and args[4] and args[5] == "--name" and args[6] and args[7] == "-c" and args[8] then
            if string.match(args[2], "%.svg$") then
                return parser:toJSX(args[2], args[4], args[6], args[8])
            else
                errors.extensionError(args[2], "svg", string.match(args[2], "%.(.+)"))
            end
        else
            errors.commandError();
        end
    end
end

function commands.toSVGFile()
    if config and config.default_output_location and config.default_output_location then
        if args[1] == "-svg" and args[2] and (args[3] == "-o" or args[3] == "--output") and args[4] and args[5] == "--name" then
            if string.match(args[2], "%.jsx") then
                return parser:toSVG(args[2], args[4], (args[6] or ""))
            else
                errors.extensionError(args[2], "jsx", string.match(args[2], "%.(.+)"))
            end
        end
    end
end

function commands.run()
    if args[1] == "-v"
        or args[1] == "--version"
        or args[1] == "--name"
        or args[1] == "-d"
        or args[1] == "--description"
        or args[1] == "--author"
        or args[1] == "--license"
        or args[1] == "-gh"
        or args[1] == "github"
    then
        return commands.info()
    elseif (args[1] == "-jsx"
            and args[2]
            and (args[3] == "-o"
                or args[3] == "--output")
            and args[4]
            and args[5])
    then
        return commands.toJsxFile()
    elseif (args[1] == "-svg"
            and args[2]
            and (args[3] == "-o"
                or args[3] == "--output")
            and args[4]
            and args[5] == "--name")
    then
        return commands.toSVGFile()
    else
        if args[1] == "-svg" or args[1] == "-jsx" then
            errors.commandError(nil, args[1], true)
        elseif args[1] ~= "-svg" and args[1] ~= "-jsx" then
            errors.commandError(true, args[1])
        else
            print(
                utils.colorize(project.name, "bright_blue") .. " - " ..
                utils.colorize(project.version, "green") .. " \n- " ..
                utils.colorize(project.description, "bright_blue")
            )
        end
    end
end

commands.run()

return commands
