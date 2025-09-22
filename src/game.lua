local Game = {}
local Play = require "src.states.play"

function Game:load()
    love.window.setTitle("Prototype - Play")
    math.randomseed(os.time())
    self.state = Play
    if self.state.load then self.state.load(self) end
end

function Game:update(dt)
    if self.state.update then self.state.update(self, dt) end
end

function Game:draw()
    if self.state.draw then self.state.draw(self) end
end

function Game:keypressed(key)
    if self.state.keypressed then self.state.keypressed(self, key) end
end

function Game:mousepressed(x,y,button)
    if self.state.mousepressed then self.state.mousepressed(self, x, y, button) end
end

return Game