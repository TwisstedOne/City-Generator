-- Dependencies --
local params = require("config.params")
local PRNG = require("core.prng")  
local NOISE = require("core.noise")  
local UTILS = require("core.utils")

local seed = params.seed
local rng = PRNG.init(seed)
local noise = NOISE.init(seed)

-- [[ Debug Values ]] -- 

local cellsize = 4
local gridsize = 500
local resolution = 100

-- [[ ------------ ]] -- 


local time = 0

local map = {}

for y = 1, gridsize/cellsize do
    map[y] = {}
    for x = 1, gridsize/cellsize do
        local height = (noise:fbm(x/resolution, y/resolution, 4, 0.5, 2) + 1) / 2

        map[y][x] = height
    end
end

function love.load()

end

function love.update(dt)
    local fps = 1 / dt
    time = time + dt
    --print("FPS:", math.floor(fps))
    --print(time)
end

function love.draw()
    
    --[[ 
    love.graphics.setColor(255, 255, 0)
    love.graphics.rectangle("fill", 90, 90, 520, 520)

    
    for y = 0, gridsize/cellsize - 1 do
        for x = 0, gridsize/cellsize - 1 do
            local height = map[y][x]

            love.graphics.setColor(height, height, height)
            love.graphics.rectangle("fill", 100 + x * cellsize, 100 + y * cellsize, cellsize, cellsize)
        end
    end
    ]]--

    local scale = 4
    local S = 10
    local nx = #map
    local ny = #map[1]

    for px = 0, nx * scale - 1 do
        for py = 0, ny * scale - 1 do
            local x = px / scale
            local y = py / scale

            local h = UTILS.sample_height_at_point(map, x, y, S)
            love.graphics.setColor(h, h, h)
            love.graphics.points(px, py)
        end
    end


    local mx, my = love.mouse.getPosition()
    local x = mx / scale   -- convert pixels → miles (tweak scale)
    local y = my / scale

    local h = UTILS.sample_height_at_point(map, x, y, 10)

    print("Height at ("..string.format("%.2f",x)..","..string.format("%.2f",y)..") = "..string.format("%.3f",h), 10, 10)
end

function love.keypressed(key)
    if key == "space" then
        print("Jump!")
    end
end

-- cd C:/Users/scott/City-Generator
-- & "C:\Program Files\LOVE\love.exe" .