package.path = package.path .. ";src/?.lua;src/?/init.lua;src/?/*.lua"

local City = require("game.city")
local Renderer = require("love.renderer")

local city

function love.load()
    city = City:new(12345, 40, 20) -- seed, width, height
end

function love.draw()
    Renderer.drawCity(city, 20) -- block size
end

-- cd C:/Users/scott/City-Generator
-- "C:\Program Files\LOVE\love.exe" .