local Class = {}

function Class.new(base)
    local cls = {}
    cls.__index = cls

    function cls:new(...)
        local instance = setmetatable({}, cls)
        if instance.init then
            instance:init(...)
        end
        return instance
    end

    if base then
        setmetatable(cls, { __index = base })
        cls.__base = base
    end

    return cls
end

return Class