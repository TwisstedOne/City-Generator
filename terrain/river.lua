--[[ Utils ]]--

local utils = {}

-- create a 2D grid of zeros
function utils.zero_grid(nx, ny)
    local grid = {}
    for j = 1, ny do
        grid[j] = {}
        for i = 1, nx do
            grid[j][i] = 0
        end
    end
    return grid
end

-- check if a grid index is in bounds
function utils.in_bounds(i, j, nx, ny)
    return i >= 1 and i <= nx and j >= 1 and j <= ny
end

-- convert grid index to world coordinates (miles)
function utils.grid_to_world(i, j, S)
    local x = (i-0.5)/S
    local y = (j-0.5)/S
    return x, y
end

--[[ River Functions ]]--

function compute_flow_accum(flow_dir_map, nx, ny)
    local flow_accum = utils.zero_grid(nx, ny)

    for j = 1, ny do
        for i = 1, nx do
            local visited = {}
            local ci, cj = i, j

            while true do
                local next_cell = flow_dir_map[cj][ci]  -- should store {i,j} or linear index
                if not next_cell or (next_cell.i == ci and next_cell.j == cj) then
                    break
                end
                local key = next_cell.i .. "," .. next_cell.j
                if visited[key] then break end  -- prevent loops
                visited[key] = true

                flow_accum[next_cell.j][next_cell.i] = flow_accum[next_cell.j][next_cell.i] + 1
                ci, cj = next_cell.i, next_cell.j
            end
        end
    end

    return flow_accum
end

function river_mask_from_accum(flow_accum, threshold)
    local ny = #flow_accum
    local nx = #flow_accum[1]
    local mask = utils.zero_grid(nx, ny)
    for j = 1, ny do
        for i = 1, nx do
            if flow_accum[j][i] >= threshold then
                mask[j][i] = true
            else
                mask[j][i] = false
            end
        end
    end
    return mask
end

function trace_river(start_i, start_j, river_mask, flow_dir_map)
    local path = {}
    local ci, cj = start_i, start_j
    local visited = {}

    while true do
        table.insert(path, {i=ci, j=cj})
        local key = ci..","..cj
        if visited[key] then break end
        visited[key] = true

        local next_cell = flow_dir_map[cj][ci]
        if not next_cell then break end
        if not river_mask[next_cell.j][next_cell.i] then break end

        ci, cj = next_cell.i, next_cell.j
    end

    return path
end

function path_to_world(path, S)
    local world_path = {}
    for _, p in ipairs(path) do
        local x, y = utils.grid_to_world(p.i, p.j, S)
        table.insert(world_path, {x=x, y=y})
    end
    return world_path
end

--[[ Main Function ]]--

local river = {}

function river.extract_rivers(terrain, params, prng)
    local nx, ny = terrain.nx, terrain.ny
    local flow_accum = compute_flow_accum(terrain.flow_dir_map, nx, ny)

    -- simple threshold: e.g., 1% of total cells
    local threshold = math.floor(nx*ny*0.01)
    local river_mask = river_mask_from_accum(flow_accum, threshold)

    local rivers = {}
    local visited_mask = utils.zero_grid(nx, ny)

    for j = 1, ny do
        for i = 1, nx do
            if river_mask[j][i] and not visited_mask[j][i] then
                local path = trace_river(i, j, river_mask, terrain.flow_dir_map)
                -- mark visited
                for _, p in ipairs(path) do
                    visited_mask[p.j][p.i] = true
                end
                local world_path = path_to_world(path, terrain.samples_per_mile)
                table.insert(rivers, {polyline = world_path})
            end
        end
    end

    return { flow_accum = flow_accum, rivers = rivers }
end

return river