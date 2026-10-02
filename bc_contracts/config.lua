Config = {}

Config.StartCost   = 70      -- clean cash to start a contract
Config.MinSeconds  = 45      -- anti-exploit: minimum time before delivery counts
Config.CooldownSec = 120     -- wait between contracts
Config.DropRadius  = 8.0

-- payout is DIRTY money (black_money account), random between the two numbers
Config.Vehicles = {
    { model = 'sultan',  label = 'Sultan',  payout = { 1500, 2500 } },
    { model = 'kuruma',  label = 'Kuruma',  payout = { 2500, 3500 } },
    { model = 'comet2',  label = 'Comet',   payout = { 3000, 4500 } },
    { model = 'baller',  label = 'Baller',  payout = { 2000, 3000 } },
}

-- SAMPLE coordinates - adjust to spots you like (vec4 = x, y, z, heading)
Config.Pickups = {
    vec4(-340.7, -874.5, 31.1, 168.0),
    vec4(1152.3, -326.2, 69.2, 96.0),
    vec4(-1616.6, -1013.1, 13.1, 180.0),
}

Config.Dropoffs = {
    vec3(-467.3, -1683.8, 18.9),
    vec3(724.4, -1073.7, 22.2),
    vec3(-1145.9, -2005.5, 13.2),
}
