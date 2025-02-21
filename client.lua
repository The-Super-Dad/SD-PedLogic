local hostilePedConfig = {
    {
        model = `hc_hacker`,
        locations = {
            vector3(-1071.45, -241.56, 42.27-1) ,
            vector3(-1074.22, -249.76, 37.76-1) ,
            vector3(-1065.89, -244.99, 39.73-1) ,
            vector3(-1061.00, -240.49, 39.73-1) ,

        }
    },
}



RegisterNetEvent('SpawnHostilePeds', function()
    local playerPed = PlayerPedId()
    local playerGroup = GetPedRelationshipGroupHash(playerPed)
    local hostilePeds = {}
    local hostileGroup = AddRelationshipGroup("HOSTILE_PEDS")

    for _, pedConfig in ipairs(hostilePedConfig) do
        local pedModel = GetHashKey(pedConfig.model)

        RequestModel(pedModel)
        while not HasModelLoaded(pedModel) do
            Wait(1)
        end

        for _, spawnCoords in ipairs(pedConfig.locations) do
            local ped = CreatePed(4, pedModel, spawnCoords.x, spawnCoords.y, spawnCoords.z, 0.0, true, false)
            SetPedRelationshipGroupHash(ped, hostileGroup)
            GiveWeaponToPed(ped, GetHashKey("WEAPON_TECPISTOL"), 250, false, true)
            TaskCombatPed(ped, playerPed, 0, 16)
            SetPedAccuracy(ped, 50)
            SetPedDropsWeaponsWhenDead(ped, false)
            table.insert(hostilePeds, ped)
        end

        SetModelAsNoLongerNeeded(pedModel)
    end

    -- Set relationship between hostile peds and player
    SetRelationshipBetweenGroups(5, hostileGroup, playerGroup) -- Hostile towards player
    SetRelationshipBetweenGroups(0, hostileGroup, hostileGroup) -- Neutral towards each other
----Check if they are all dead
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(1000)
            for i, ped in ipairs(hostilePeds) do
                if DoesEntityExist(ped) and IsPedDeadOrDying(ped, true) then
                    table.remove(hostilePeds, i)
                end
            end
            if #hostilePeds == 0 then
                lib.notify({ title = 'Robbery', description = 'All hostile peds are dead', type = 'success' })
                Wait(1000)
                lib.notify({ title = 'Search', description = 'Go find the computer', type = 'success' })
                ---Trigger event here upon all peds dead
                break
            end
        end
    end)
end)
