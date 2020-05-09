print("Core lua script loaded.")

local core = {}

function core.test(x)
    return x + 1
end

function someEvent(x, y, z)
    return 12312, "rewr", 512.12
end

return core
