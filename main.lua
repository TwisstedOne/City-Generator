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
        local height = (noise:fbm(x/resolution, y/resolution, 5, 0.5, 2) + 1) / 2

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
    --love.graphics.setColor(255, 255, 0)
    --love.graphics.rectangle("fill", 90, 90, 520, 520)
    
    for y = 1, gridsize/cellsize do
        for x = 1, gridsize/cellsize do
            local height = map[y][x]

            love.graphics.setColor(height, height, height)
            love.graphics.rectangle("fill", x * cellsize, 100 + y * cellsize, cellsize, cellsize)
        end
    end

    for y = 1, gridsize/cellsize do
        for x = 1, gridsize/cellsize do
            local height = UTILS.sample_height_at_point(map, x, y, 1)

            love.graphics.setColor(height, height, height)
            love.graphics.rectangle("fill", 600 + x * cellsize, 100 + y * cellsize, cellsize, cellsize)
        end
    end
    


    local mx, my = love.mouse.getPosition()
    local x = math.floor(mx/cellsize)
    local y = math.floor((my - 100)/cellsize)

    local h1 = 0
    if x > 0 and x < gridsize/cellsize and y > 0 and y < gridsize/cellsize then
        h1 = map[y][x]
    end

    local h2 = UTILS.sample_height_at_point(map, mx, my, 1)
    print(map[1][1].." "..UTILS.sample_height_at_point(map, 1, 1, 1))
     
    --local h2 = map[x - 500][y]

    --print("Height at ("..string.format("%.2f",x)..","..string.format("%.2f",y)..") = "..string.format("%.3f",h1))
    --print("Noise at ("..string.format("%.2f",x)..","..string.format("%.2f",y)..") = "..string.format("%.3f",h2))
end

function love.keypressed(key)
    if key == "space" then
        print("Jump!")
    end
end

-- cd C:/Users/scott/City-Generator
-- & "C:\Program Files\LOVE\love.exe" .