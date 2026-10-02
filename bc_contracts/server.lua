local ESX = exports['es_extended']:getSharedObject()
local active, cooldown = {}, {}

local function notify(src, msg) TriggerClientEvent('esx:showNotification', src, msg) end

local function cleanup(src)
    local c = active[src]
    if c and c.netId then
        local ent = NetworkGetEntityFromNetworkId(c.netId)
        if ent and ent ~= 0 and DoesEntityExist(ent) then DeleteEntity(ent) end
    end
    active[src] = nil
end

RegisterNetEvent('bc_contracts:request', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end
    if active[src] then return notify(src, 'You already have a contract. Press BACKSPACE to cancel it.') end
    if cooldown[src] and cooldown[src] > os.time() then return notify(src, 'Lay low for a bit before the next one.') end
    if xPlayer.getMoney() < Config.StartCost then return notify(src, ('You need $%d cash to start a contract.'):format(Config.StartCost)) end

    xPlayer.removeMoney(Config.StartCost, 'bc_contract_start')
    local v = Config.Vehicles[math.random(#Config.Vehicles)]
    local pickup = Config.Pickups[math.random(#Config.Pickups)]
    local drop = Config.Dropoffs[math.random(#Config.Dropoffs)]
    local plate = ('BC%05d'):format(math.random(0, 99999))

    active[src] = {
        model = v.model, plate = plate, drop = drop,
        payout = math.random(v.payout[1], v.payout[2]), started = os.time(),
    }
    TriggerClientEvent('bc_contracts:start', src, { model = v.model, label = v.label, plate = plate, pickup = pickup, drop = drop })
end)

RegisterNetEvent('bc_contracts:spawned', function(netId)
    local c = active[source]
    if c and type(netId) == 'number' then c.netId = netId end
end)

RegisterNetEvent('bc_contracts:deliver', function()
    local src = source
    local c = active[src]
    local xPlayer = ESX.GetPlayerFromId(src)
    if not c or not c.netId or not xPlayer then return end

    local ent = NetworkGetEntityFromNetworkId(c.netId)
    if not ent or ent == 0 or not DoesEntityExist(ent) then return notify(src, 'Vehicle not found.') end
    if GetEntityModel(ent) ~= joaat(c.model) then return end
    if GetVehiclePedIsIn(GetPlayerPed(src), false) ~= ent then return notify(src, 'You must be in the vehicle.') end
    if #(GetEntityCoords(ent) - c.drop) > Config.DropRadius + 4.0 then return end
    if os.time() - c.started < Config.MinSeconds then return notify(src, 'Too fast - something is off.') end

    xPlayer.addAccountMoney('black_money', c.payout, 'bc_contract_payout')
    notify(src, ('Contract done. You got $%d dirty money.'):format(c.payout))
    cooldown[src] = os.time() + Config.CooldownSec
    cleanup(src)
    TriggerClientEvent('bc_contracts:clear', src)
end)

RegisterNetEvent('bc_contracts:cancel', function()
    local src = source
    if not active[src] then return end
    cleanup(src)
    TriggerClientEvent('bc_contracts:clear', src)
    notify(src, 'Contract cancelled.')
end)

AddEventHandler('playerDropped', function() cleanup(source); cooldown[source] = nil end)
