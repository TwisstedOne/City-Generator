--[[ Main Functions

:rand() - return float between [0, 1)
:randInt(a, b) - inclusive integer range, i.e [1, 4] -> 1, 2, 3, 4
:choice(list) - pick a random element from list
:hash2(x, y) - return 32-bit integer, consistent for (x, y) as long as seed is consistent

]]--

-- prng.lua for Lua 5.1
local PRNG = {}
PRNG.__index = PRNG

local MASK32 = 0xFFFFFFFF
local MOD32  = 4294967296 -- 2^32

local function to32(x)
    return x % MOD32
end

-- Pure-Lua bitwise functions
local function band(a,b)
    a = to32(a); b = to32(b)
    local res, bitval = 0,1
    for i=0,31 do
        local aa = a % 2
        local bb = b % 2
        if aa == 1 and bb == 1 then res = res + bitval end
        a = (a-aa)/2
        b = (b-bb)/2
        bitval = bitval*2
    end
    return to32(res)
end

local function bxor(a,b)
    a = to32(a); b = to32(b)
    local res, bitval = 0,1
    for i=0,31 do
        local aa = a % 2
        local bb = b % 2
        if (aa+bb) % 2 == 1 then res = res + bitval end
        a = (a-aa)/2
        b = (b-bb)/2
        bitval = bitval*2
    end
    return to32(res)
end

local function lshift(a,n)
    return to32(a*(2^n))
end

local function rshift(a,n)
    return to32(math.floor(a/(2^n)))
end

local function mul32(a,b)
    a = to32(a); b = to32(b)
    local a_low  = a % 65536
    local a_high = math.floor(a/65536)
    local b_low  = b % 65536
    local b_high = math.floor(b/65536)
    local low = a_low * b_low
    local mid = a_high * b_low + a_low * b_high
    return to32(low + ((mid % 65536) * 65536))
end

local function add32(a,b)
    return to32(a+b)
end

-- splitmix32 PRNG step
local function splitmix32(state)
    state = add32(state, 0x9E3779B9)
    local z = state
    z = bxor(z, rshift(z,16))
    z = mul32(z, 0x85EBCA6B)
    z = bxor(z, rshift(z,13))
    z = mul32(z, 0xC2B2AE35)
    z = bxor(z, rshift(z,16))
    return state, to32(z)
end

local function int32_to_float(x)
    return to32(x)/MOD32
end

local function step_generator(state)
    return splitmix32(state)
end

-- PRNG API
function PRNG.init(seed)
    seed = seed or os.time()
    seed = to32(seed)
    local _, _ = splitmix32(seed) -- initialize
    return setmetatable({ state = seed }, PRNG)
end

function PRNG:rand()
    local new_state, v = step_generator(self.state)
    self.state = new_state
    return int32_to_float(v)
end

function PRNG:randInt(a,b)
    if not a then return 0 end
    if b == nil then b = a; a = 1 end
    if a > b then a,b = b,a end
    return math.floor(self:rand()*(b-a+1)) + a
end

function PRNG:choice(tbl)
    return tbl[self:randInt(1,#tbl)]
end

function PRNG:hash2(x,y)
    local xi = to32(math.floor(x or 0))
    local yi = to32(math.floor(y or 0))
    local combined = bxor(add32(mul32(xi, 0x1F1F1F1F), yi), self.state)
    local _, h = splitmix32(combined)
    return h
end

return PRNG