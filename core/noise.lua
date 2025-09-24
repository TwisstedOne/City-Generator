--[[ Main Functions



]]--


-- noise.lua
local PRNG = require("core.prng")
local Noise = {}
Noise.__index = Noise

-- linear interpolation
local function lerp(a, b, t)
    return a + t * (b - a)
end

-- fade function (Perlin-style)
local function fade(t)
    return t * t * t * (t * (t * 6 - 15) + 10)
end

-- gradient directions for 2D value/perlin noise
local grad2 = {
    {1,0},{-1,0},{0,1},{0,-1},
    {1,1},{-1,1},{1,-1},{-1,-1}
}

-- initialize noise object
function Noise.init(seed)
    local prng = PRNG.init(seed)
    local obj = setmetatable({}, Noise)
    obj.prng = prng

    -- build permutation table (256 entries)
    obj.perm = {}
    for i = 0,255 do
        obj.perm[i] = i
    end

    -- shuffle using prng
    for i = 255, 1, -1 do
        local j = prng:randInt(0,i)
        obj.perm[i], obj.perm[j] = obj.perm[j], obj.perm[i]
    end

    -- duplicate table for overflow
    for i = 0,255 do
        obj.perm[i + 256] = obj.perm[i]
    end

    return obj
end

-- get gradient vector from permutation table
function Noise:grad(ix, iy)
    local idx = self.perm[(ix + self.perm[iy % 256]) % 256] % #grad2 + 1
    return grad2[idx][1], grad2[idx][2]
end

-- sample noise at (x,y), returns float in [-1,1]
function Noise:sample(x, y)
    local x0 = math.floor(x)
    local x1 = x0 + 1
    local y0 = math.floor(y)
    local y1 = y0 + 1

    local sx = fade(x - x0)
    local sy = fade(y - y0)

    local gx0y0x, gx0y0y = self:grad(x0,y0)
    local gx1y0x, gx1y0y = self:grad(x1,y0)
    local gx0y1x, gx0y1y = self:grad(x0,y1)
    local gx1y1x, gx1y1y = self:grad(x1,y1)

    local dx0 = x - x0
    local dx1 = x - x1
    local dy0 = y - y0
    local dy1 = y - y1

    local dot00 = gx0y0x*dx0 + gx0y0y*dy0
    local dot10 = gx1y0x*dx1 + gx1y0y*dy0
    local dot01 = gx0y1x*dx0 + gx0y1y*dy1
    local dot11 = gx1y1x*dx1 + gx1y1y*dy1

    local ix0 = lerp(dot00, dot10, sx)
    local ix1 = lerp(dot01, dot11, sx)

    local value = lerp(ix0, ix1, sy)
    -- clamp to [-1,1] (Perlin gradient noise is already roughly in this range)
    if value > 1 then value = 1 elseif value < -1 then value = -1 end
    return value
end

-- fractal Brownian motion
function Noise:fbm(x, y, octaves, persistence, lacunarity)
    octaves = octaves or 4
    persistence = persistence or 0.5
    lacunarity = lacunarity or 2.0

    local total = 0
    local amplitude = 1
    local frequency = 1
    local maxAmplitude = 0

    for i = 1, octaves do
        total = total + self:sample(x*frequency, y*frequency) * amplitude
        maxAmplitude = maxAmplitude + amplitude
        amplitude = amplitude * persistence
        frequency = frequency * lacunarity
    end

    return total / maxAmplitude  -- normalized roughly to [-1,1]
end

return Noise