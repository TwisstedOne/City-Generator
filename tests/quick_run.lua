--[[ Dependencies ]]--
local params = require("config.params")
local PRNG = require("core.prng")  
local NOISE = require("core.noise")  
local UTILS = require("core.utils")

local seed = params.seed
local rng = PRNG.init(seed)
local noise = NOISE.init(seed)

--[[ ------------ ]]--



local qr = {}

qr.load = {}

function qr.load.Test1()
    qr.cellsize = 4
    qr.gridsize = 500
    qr.resolution = 100
    
    qr.map = {}

    for y = 1, qr.gridsize/qr.cellsize do
        qr.map[y] = {}
        for x = 1, qr.gridsize/qr.cellsize do
            local height = (noise:fbm(x/qr.resolution, y/qr.resolution, 5, 0.5, 2) + 1) / 2

            qr.map[y][x] = height
        end
    end
end

qr.draw = {}

function qr.draw.Test1()
    local lowest = 1
    local highest = 0

    for y = 1, qr.gridsize/qr.cellsize do
        for x = 1, qr.gridsize/qr.cellsize do
            local height = qr.map[y][x]

            if height < lowest then
                lowest = height
            end

            if height > highest then
                highest = height
            end

            love.graphics.setColor(height, height, height)
            love.graphics.rectangle("fill", x * qr.cellsize, 100 + y * qr.cellsize, qr.cellsize, qr.cellsize)
        end
    end

    for y = 1, qr.gridsize/qr.cellsize do
        for x = 1, qr.gridsize/qr.cellsize do
            local height = UTILS.sample_height_at_point(qr.map, x, y, 1)

            love.graphics.setColor(height, height, height)
            love.graphics.rectangle("fill", 600 + x * qr.cellsize, 100 + y * qr.cellsize, qr.cellsize, qr.cellsize)
        end
    end
    
    print("Lowest: "..lowest..", Highest: "..highest)


    local mx, my = love.mouse.getPosition()
    local x = math.floor(mx/qr.cellsize)
    local y = math.floor((my - 100)/qr.cellsize)

    local h1 = 0
    if x > 0 and x < qr.gridsize/qr.cellsize and y > 0 and y < qr.gridsize/qr.cellsize then
        h1 = qr.map[y][x]
    end

    local h2 = UTILS.sample_height_at_point(qr.map, mx, my, 1)
    print(qr.map[1][1].." "..UTILS.sample_height_at_point(qr.map, 1, 1, 1))
     
    --local h2 = map[x - 500][y]

    --print("Height at ("..string.format("%.2f",x)..","..string.format("%.2f",y)..") = "..string.format("%.3f",h1))
    --print("Noise at ("..string.format("%.2f",x)..","..string.format("%.2f",y)..") = "..string.format("%.3f",h2))
end

return qr