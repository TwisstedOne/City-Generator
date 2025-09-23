local params = require("config.params")

function love.load()
    print(params["seed"])
end

function love.update(dt)

end

function love.draw()
    love.graphics.rectangle("fill", 100, 100, 200, 150)

end

function love.keypressed(key)
    if key == "space" then
        print("Jump!")
    end
end

-- cd C:/Users/scott/City-Generator
-- & "C:\Program Files\LOVE\love.exe" .