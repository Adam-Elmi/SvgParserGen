local config = require("config")
local utils = require("core.utils")
local project = require("project")
local parser = require("core.parser")

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
        else
            if args[1] then
                print(select(2,
                    utils.customError("Invalid Command", string.format("'%s' is unrecognized command!", args[1]))))
            else
                print(
                    utils.colorize(project.name, "bright_blue") .. " - " ..
                    utils.colorize(project.version, "green") .. " \n- " ..
                    utils.colorize(project.description, "bright_blue")
                )
            end
        end
    end
end

function commands.run()
    if config then
        if config.default_output_location and config.default_output_location ~= "" then
            if args[1] == "-s" and args[2] then
                return parser:singleParse(args[2], config.default_output_location)
            else
                print(select(2, utils.customError("Error", "Invalid Command!")))
            end
        else
            if args[1] == "-s" and args[2] and args[3] == "-o" and args[4] then
                return parser:singleParse(args[2], args[4])
            else
                print(select(2, utils.customError("Error", "Invalid Command!")))
            end
        end
    end
end

print(commands.run())

return commands
