local Class = require("core.class")

local Block = Class.new()

function Block:init(x, y, kind)
    self.x = x
    self.y = y
    self.kind = kind or "lot" -- "street" or "lot"
end

return Block