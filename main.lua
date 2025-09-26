-- Dependencies --
local params = require("config.params")
local PRNG = require("core.prng")  
local NOISE = require("core.noise")  
local UTILS = require("core.utils")
local QUICKRUN = require("tests.quick_run")

local seed = params.seed
local rng = PRNG.init(seed)
local noise = NOISE.init(seed)


-- [[ Debug Values ]] -- 

local time = 0
local test = "Test1"

-- [[ ------------ ]] -- 

function love.load()
    QUICKRUN.load[test]()
end

function love.update(dt)
    local fps = 1 / dt
    time = time + dt
    --print("FPS:", math.floor(fps))
    --print(time)
end

function love.draw()    
    if QUICKRUN.draw[test] then
        QUICKRUN.draw[test]()
    else
        print("no function for "..test)
    end
end

function love.keypressed(key)
    if key == "space" then
        print("Jump!")
    end
end

-- cd C:/Users/scott/City-Generator
-- & "C:\Program Files\LOVE\love.exe" .