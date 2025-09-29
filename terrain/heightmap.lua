local terrain = {}

-- Normalize 2D array to [0,1]
local function normalize(heightmap)
    local ny = #heightmap
    local nx = #heightmap[1]

    local minv, maxv = math.huge, -math.huge
    for j = 1, ny do
        for i = 1, nx do
            local h = heightmap[j][i]
            if h < minv then minv = h end
            if h > maxv then maxv = h end
        end
    end

    local scale = 1 / (maxv - minv)
    for j = 1, ny do
        for i = 1, nx do
            heightmap[j][i] = (heightmap[j][i] - minv) * scale
        end
    end
end

-- Scale [-1,1] to [0,1]
local function transform_raw_elevation(raw)
    return (raw + 1)/2
end

-- Safely get height with boundary clamp
local function get_height(height, i, j)
    local ny = #height
    local nx = #height[1]
    i = math.max(1, math.min(nx, i))
    j = math.max(1, math.min(ny, j))
    return height[j][i]
end

-- Find steepest descent neighbor among 8
local function find_min_neighbor(height, i, j)
    local ny = #height
    local nx = #height[1]
    local best_i, best_j = i, j
    local best_val = height[j][i]

    for dj = -1, 1 do
        for di = -1, 1 do
            if not (di == 0 and dj == 0) then
                local ni = math.max(1, math.min(nx, i + di))
                local nj = math.max(1, math.min(ny, j + dj))
                local val = height[nj][ni]
                if val < best_val then
                    best_val = val
                    best_i, best_j = ni, nj
                end
            end
        end
    end
    return best_i, best_j
end

function terrain.generate(params, prng, noise)
    local S = params.samples_per_mile
    local nx = math.ceil(params.size_miles.width * S)
    local ny = math.ceil(params.size_miles.height * S)

    -- Allocate heightmap
    local height = {}
    for j = 1, ny do
        height[j] = {}
        for i = 1, nx do
            local x = (i - 0.5) / S
            local y = (j - 0.5) / S

            local raw = noise:fbm(
                x * params.elevation_params.scale,
                y * params.elevation_params.scale,
                params.elevation_params.octaves,
                params.elevation_params.persistence,
                params.elevation_params.lacunarity
            )

            -- Apply terrain shaping (user-defined)
            height[j][i] = transform_raw_elevation(raw)
        end
    end

    -- Normalize 0..1
    normalize(height)

    -- Allocate slope/flow maps
    local slope_map = {}
    local flow_dir_map = {}

    for j = 1, ny do
        slope_map[j] = {}
        flow_dir_map[j] = {}
        for i = 1, nx do
            local hL = get_height(height, i - 1, j)
            local hR = get_height(height, i + 1, j)
            local hD = get_height(height, i, j - 1)
            local hU = get_height(height, i, j + 1)

            -- central difference
            local dx = (hR - hL) / (2 / S)
            local dy = (hU - hD) / (2 / S)
            slope_map[j][i] = math.sqrt(dx * dx + dy * dy)

            -- flow direction (steepest descent)
            local ni, nj = find_min_neighbor(height, i, j)
            flow_dir_map[j][i] = { ni, nj }
        end
    end

    return {
        height = height,
        nx = nx, ny = ny, samples_per_mile = S,
        slope_map = slope_map, flow_dir_map = flow_dir_map
    }
end

return terrain
