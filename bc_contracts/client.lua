local contract, veh, pickupBlip, dropBlip

local function help(text)
    BeginTextCommandDisplayHelp('STRING')
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayHelp(0, false, true, -1)
end

local function clear()
    if pickupBlip then RemoveBlip(pickupBlip) end
    if dropBlip then RemoveBlip(dropBlip) end
    pickupBlip, dropBlip, contract, veh = nil, nil, nil, nil
end

RegisterCommand('contract', function()
    if contract then return end
    TriggerServerEvent('bc_contracts:request')
end, false)

RegisterNetEvent('bc_contracts:start', function(data)
    contract = data
    local hash = joaat(data.model)
    RequestModel(hash)
    local t = GetGameTimer()
    while not HasModelLoaded(hash) and GetGameTimer() - t < 5000 do Wait(50) end

    local p = data.pickup
    veh = CreateVehicle(hash, p.x, p.y, p.z, p.w, true, false)
    SetVehicleNumberPlateText(veh, data.plate)
    SetEntityAsMissionEntity(veh, true, true)
    SetVehicleDoorsLocked(veh, 1) -- Phase 4: swap for locked + lockpick/hotwire
    SetModelAsNoLongerNeeded(hash)

    pickupBlip = AddBlipForCoord(p.x, p.y, p.z)
    SetBlipSprite(pickupBlip, 225); SetBlipColour(pickupBlip, 1); SetBlipRoute(pickupBlip, true)
    BeginTextCommandSetBlipName('STRING'); AddTextComponentSubstringPlayerName('Target: ' .. data.label); EndTextCommandSetBlipName(pickupBlip)

    Wait(500)
    TriggerServerEvent('bc_contracts:spawned', NetworkGetNetworkIdFromEntity(veh))
    TriggerEvent('esx:showNotification', ('Find the %s (plate %s). BACKSPACE cancels.'):format(data.label, data.plate))

    local droppedBlipShown = false
    while contract do
        local sleep = 500
        local ped = PlayerPedId()

        if IsControlJustPressed(0, 177) then -- BACKSPACE
            TriggerServerEvent('bc_contracts:cancel')
            break
        end

        if veh and IsPedInVehicle(ped, veh, false) then
            if not droppedBlipShown then
                droppedBlipShown = true
                if pickupBlip then RemoveBlip(pickupBlip); pickupBlip = nil end
                local d = data.drop
                dropBlip = AddBlipForCoord(d.x, d.y, d.z)
                SetBlipSprite(dropBlip, 50); SetBlipColour(dropBlip, 2); SetBlipRoute(dropBlip, true)
            end
            local d = data.drop
            local dist = #(GetEntityCoords(ped) - vec3(d.x, d.y, d.z))
            if dist < 60.0 then
                sleep = 0
                DrawMarker(1, d.x, d.y, d.z - 1.0, 0, 0, 0, 0, 0, 0, 6.0, 6.0, 1.5, 0, 255, 100, 120, false, false, 2, false, nil, nil, false)
                if dist < 6.0 then
                    help('Press ~INPUT_CONTEXT~ to deliver')
                    if IsControlJustPressed(0, 38) then TriggerServerEvent('bc_contracts:deliver') end
                end
            end
        end
        Wait(sleep)
    end
end)

RegisterNetEvent('bc_contracts:clear', clear)
