--[[ Dependencies ]]--
local params = require("config.params")
local PRNG = require("core.prng")  
local NOISE = require("core.noise")  
local UTILS = require("core.utils")
local HEIGHTMAP = require("terrain.heightmap")
local RIVER = require("terrain.river")

-- Params
local seed = params.seed


-- Objects
local rng = PRNG.init(seed)
local noise = NOISE.init(seed)

--[[ ------------ ]]--



local qr = {}

qr.load = {}
qr.draw = {}

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

function qr.load.Test2()
    qr.map = HEIGHTMAP.generate(params, rng, noise)
    qr.rivers_result = RIVER.extract_rivers(qr.map, params, rng)
    print(qr.map.nx, qr.map.ny)
end

function qr.draw.Test2()
    for y = 1, qr.map.ny do
        for x = 1, qr.map.nx do
            local h = qr.map.height[y][x]
            love.graphics.setColor(h, h, h)
            love.graphics.rectangle("fill", (x-1)*2, (y-1)*2, 2, 2)
        end
    end

    love.graphics.setColor(0, 0, 1)
    for _, river in ipairs(qr.rivers_result.rivers) do
        for i = 2, #river.polyline do
            local p0 = river.polyline[i-1]
            local p1 = river.polyline[i]
            love.graphics.line(p0.x*2, p0.y*2, p1.x*2, p1.y*2)
        end
    end
end

return qr