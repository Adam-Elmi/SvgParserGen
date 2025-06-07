local utils = require("core.utils")

local errors = {}

function errors.customError(errorTitle, errorMessage)
    local function throwError()
        error(utils.colorize(errorTitle, "red") .. ": " .. utils.colorize(errorMessage, "magenta"))
    end

    local function errorHandler(err)
        return utils.colorize("Caught Error: ", "red") .. utils.colorize(err, "yellow")
    end

    local ok, result = xpcall(throwError, errorHandler)
    return ok, result
end

function errors.fileError()
    print(select(2,
        errors.customError("File Error",
            "Unable to open file at the specified path. Please ensure the path exists and is a valid string.")))
end

function errors.contentError()
    print(select(2, errors.customError("Content Error",
        "File content is empty!")))
end

function errors.commandError(is_unrecognized, command, is_incomplete)
    if is_unrecognized and type(is_unrecognized) == "boolean" then
        print(select(2,
            errors.customError("Invalid Command", string.format("'%s' is unrecognized command!", command))))
    elseif is_incomplete and type(is_incomplete) == "boolean" then
        print(select(2,
            errors.customError("Incomplete Command",
                string.format(
                    "The command '%s' is incomplete. Please provide all required arguments or options to complete the command.",
                    command))))
    else
        print(select(2, errors.customError("Command Error", "Invalid Command!")))
    end
end

function errors.extensionError(file, expected_extension, extension_received)
    local message = string.format(
        "Invalid file extension detected!\n\nFile: '%s'\nExpected Extension: .%s\nReceived Extension: .%s\n\nPlease provide a file with the correct extension.",
        file or "unknown",
        expected_extension or "unknown",
        extension_received or "unknown"
    )
    local title = "Extension Error"
    print(select(2, errors.customError(title, message)))
end

return errors
