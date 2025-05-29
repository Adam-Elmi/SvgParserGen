local Parser = {}
Parser.__index = Parser
setmetatable(Parser, {})

function Parser:new()
    local obj = {}
    setmetatable(obj, self)
    return obj
end

