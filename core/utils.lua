--[[ Main Functions

.clamp(x, a, b)
.normalize_vector()
.world_to_grid()
.grid_to_world()
.sample_height_at_point()

]]--

local utils = {}

function utils.clamp(x, a, b)
    if x < a then return a end
    if x > b then return b end
    return x
end

function utils.normalize_vector(x, y)
    local len = math.sqrt(x*x + y*y)
    if len == 0 then return 0,0 end
    return x/len, y/len
end

function utils.world_to_grid(x, y, S, nx, ny)
    local i = math.floor(x * S)
    local j = math.floor(y * S)
    i = utils.clamp(i, 0, nx-1)
    j = utils.clamp(j, 0, ny-1)
    return i, j
end

function utils.grid_to_world(i, j, S)
    local x = (i + 0.5) / S
    local y = (j + 0.5) / S
    return x, y
end

-- Sample Height At Point

function frac(x)
    return x - math.floor(x)
end

function bilinear_interpolate(h00, h10, h01, h11, sx, sy)
    local a = h00 * (1 - sx) + h10 * sx
    local b = h01 * (1 - sx) + h11 * sx
    return a * (1 - sy) + b * sy
end

function utils.sample_height_at_point(heightmap, x, y, S)
    local ny = #heightmap
    local nx = #heightmap[1]

    local j_f = x * S - 1
    local i_f = y * S - 1

    local i0 = math.floor(i_f)
    local j0 = math.floor(j_f)

    local sx = frac(i_f)
    local sy = frac(j_f)

    -- get corners safely
    local function get(i, j)
        i = utils.clamp(i, 0, nx-1)
        j = utils.clamp(j, 0, ny-1)
        return heightmap[i+1][j+1]
    end

    local h00 = get(i0, j0)
    local h10 = get(i0+1, j0)
    local h01 = get(i0, j0+1)
    local h11 = get(i0+1, j0+1)

    return bilinear_interpolate(h00, h10, h01, h11, sx, sy)
end

return utils