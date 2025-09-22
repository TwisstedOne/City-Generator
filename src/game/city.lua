local Class = require("core.class")
local Block = require("game.block")

local City = Class.new()

function City:init(seed, width, height)
    self.seed = seed
    self.width = width
    self.height = height
    self.blocks = {}

    love.math.setRandomSeed(seed)

    self:generate()
end

function City:generate()
    for y = 1, self.height do
        self.blocks[y] = {}
        for x = 1, self.width do
            -- Simple rule: every 5th row/col is a street
            local kind
            if x % 5 == 0 or y % 5 == 0 then
                kind = "street"
            else
                kind = "lot"
            end
            self.blocks[y][x] = Block:new(x, y, kind)
        end
    end
end

return City