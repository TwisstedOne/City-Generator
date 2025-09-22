local Renderer = {}

function Renderer.drawCity(city, blockSize)
    blockSize = blockSize or 20

    for y = 1, city.height do
        for x = 1, city.width do
            local block = city.blocks[y][x]
            if block.kind == "street" then
                love.graphics.setColor(0, 0, 0) -- black
            else
                love.graphics.setColor(0.8, 0.8, 0.8) -- light gray
            end
            love.graphics.rectangle("fill",
                (x - 1) * blockSize,
                (y - 1) * blockSize,
                blockSize,
                blockSize
            )
        end
    end
end

return Renderer