-- class.lua
-- Engine-agnostic OOP utility for Lua (works in Love2D + Roblox)

local Class = {}
Class.__index = Class

-- Create a new subclass
function Class:extend()
    local cls = {}
    for k, v in pairs(self) do
        if k:find("__") == nil then -- don't copy Lua metamethods
            cls[k] = v
        end
    end
    cls.__index = cls
    cls.super = self
    setmetatable(cls, self)
    return cls
end

-- Default constructor (can be overridden)
function Class:new()
end

-- Allow calling a class like a function
function Class:__call(...)
    local obj = setmetatable({}, self)
    obj:new(...)
    return obj
end

return Class