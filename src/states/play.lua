local Play = {}

local player = { x = 400, y = 300, w = 32, h = 48, speed = 220 }
local info = { mouseX = 0, mouseY = 0 }

function Play:load()
    -- nothing special yet
end

function Play:update(dt)
    -- keyboard movement (WASD + arrows)
    if love.keyboard.isDown("a", "left")  then player.x = player.x - player.speed * dt end
    if love.keyboard.isDown("d", "right") then player.x = player.x + player.speed * dt end
    if love.keyboard.isDown("w", "up")    then player.y = player.y - player.speed * dt end
    if love.keyboard.isDown("s", "down")  then player.y = player.y + player.speed * dt end

    -- clamp to screen
    local ww, wh = love.graphics.getWidth(), love.graphics.getHeight()
    player.x = math.max(0, math.min(ww - player.w, player.x))
    player.y = math.max(0, math.min(wh - player.h, player.y))

    -- mouse tracking
    info.mouseX, info.mouseY = love.mouse.getPosition()
end

function Play:draw()
    love.graphics.printf("Step 1: skeleton running. Move with WASD / arrows. Press Space to print in console.", 0, 6, love.graphics.getWidth(), "center")

    -- player rectangle
    love.graphics.rectangle("fill", player.x, player.y, player.w, player.h)

    -- mouse indicator
    love.graphics.circle("fill", info.mouseX, info.mouseY, 5)
end

function Play:keypressed(key)
    if key == "space" then
        print("Space pressed -- console visible if you launched from terminal.")
    end
end

function Play:mousepressed(x,y,button)
    if button == 1 then
        print(("Mouse clicked at: %.1f, %.1f"):format(x,y))
    end
end

return Play