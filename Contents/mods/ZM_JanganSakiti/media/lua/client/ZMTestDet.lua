local lastInventory = {}
local movedItemsTick = {}

local function onItemMoved(character, item, source, destination)
    local player = getPlayer()
    if not player or character ~= player then return end
    if destination == player:getInventory() then
        local srcName = "unknown"
        if source == nil then
            srcName = "spawned (no source)"
        elseif source.getType and source:getType() == "floor" then
            srcName = "ground"
        elseif source.getType and (source:getType() == "inventorycontainer" or source:getType() == "container") then
            srcName = "container"
        elseif source.getType then
            srcName = source:getType()
        end
        print("Item added to inventory: " .. item:getFullType() .. " (source: " .. srcName .. ")")
        -- Mark this item as moved this tick
        movedItemsTick[item:getFullType()] = (movedItemsTick[item:getFullType()] or 0) + 1
    end
end

EventsPlus:Add("OnItemMoved", onItemMoved, "ZM_JanganSakiti_ItemMoved")

local function checkInventory()
    local player = getPlayer()
    if not player then return end
    local inv = player:getInventory()
    if not inv then return end

    local currentItems = {}
    for i=0, inv:getItems():size()-1 do
        local item = inv:getItems():get(i)
        local fullType = item:getFullType()
        currentItems[fullType] = (currentItems[fullType] or 0) + 1
    end

    for itemType, count in pairs(currentItems) do
        local lastCount = lastInventory[itemType] or 0
        local movedCount = movedItemsTick[itemType] or 0
        if count > lastCount then
            local diff = count - lastCount
            if movedCount < diff then
                print("Item spawned directly to inventory: "..itemType.." x"..(diff - movedCount))
                -- Send log to server
                sendClientCommand("ZM_JanganSakiti", "CheatAttempt", {
                    reason = "ItemSpawned",
                    itemType = itemType,
                    amount = (diff - movedCount)
                })
            end
        end
    end

    lastInventory = currentItems
    movedItemsTick = {}
end

Events.OnPlayerUpdate.Add(function()
    checkInventory()
end)
