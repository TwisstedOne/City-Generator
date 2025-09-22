local Game = require "src.game"

function love.load()
    Game:load()
end

function love.update(dt)
    Game:update(dt)
end

function love.draw()
    Game:draw()
end

function love.keypressed(key)
    if key == "escape" then love.event.quit() end
    if Game.keypressed then Game:keypressed(key) end
end

function love.mousepressed(x, y, button)
    if Game.mousepressed then Game:mousepressed(x,y,button) end
end