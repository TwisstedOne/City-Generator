local CityParameters = {
    seed = 12345,
    size_miles = {width = 8, height = 8},
    samples_per_mile = 40,
    elevation_params = {
        octaves = 5,
        persistence = 0.5,
        lacunarity = 2,
        scale = .5
    },
    --river_threshold = 0,
    coastline = false,
    park_params = {},
    num_attractors = 1,
    debug = true
}

return CityParameters