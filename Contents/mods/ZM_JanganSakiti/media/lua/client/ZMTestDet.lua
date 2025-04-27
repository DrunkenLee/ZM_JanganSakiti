local lastInventory = {}
local movedItemsTick = {}

local function onItemMoved(character, item, source, destination)
  local player = getPlayer()
  if not player or character ~= player then return end
  if destination == player:getInventory() then
      -- Skip if item was added by ServerPoints mod
      local modData = item:getModData()
      print("Item moved: " .. item:getFullType() .. " (source: " .. tostring(source) .. ", destination: " .. tostring(destination) .. ")")
      if modData and modData.Source == "SERVERPOINTS" then
          return
      end
      local srcName = "unknown"
      if not modData.Source then
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
          movedItemsTick[item:getFullType()] = (movedItemsTick[item:getFullType()] or 0) + 1
      end
  end
end

EventsPlus:Add("OnItemMoved", onItemMoved, "ZM_JanganSakiti_ItemMoved")

local itemTypeToCheck = {
    "Base.Ashley",
    "Base.Helga0",
    "Base.Specialist",
    "Base.Tifa",
    "Base.ada_wong",
    "Base.fbi",
    "Base.swat",
    "ZM_Mungkinkah.ZM_MysticOrb"
}

-- Convert itemTypeToCheck array to a lookup table for faster checks
local itemTypeToCheckLookup = {}
for _, itemType in ipairs(itemTypeToCheck) do
    itemTypeToCheckLookup[itemType] = true
end

local function checkInventory()
  local player = getPlayer()
  if not player then return end
  local inv = player:getInventory()
  if not inv then return end

  local currentItems = {}
  local skipItems = {}

  for i=0, inv:getItems():size()-1 do
      local item = inv:getItems():get(i)
      local fullType = item:getFullType()
      local modData = item:getModData()
      -- Skip items with Source == "SERVERPOINTS"
      if modData and modData.Source == "SERVERPOINTS" then
          skipItems[fullType] = (skipItems[fullType] or 0) + 1
      else
          currentItems[fullType] = (currentItems[fullType] or 0) + 1
      end
  end

  for itemType, count in pairs(currentItems) do
      local lastCount = lastInventory[itemType] or 0
      local movedCount = movedItemsTick[itemType] or 0
      if count > lastCount then
          local diff = count - lastCount
          if itemTypeToCheckLookup[itemType] then
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

Events.EveryTenMinutes.Add(function()
  checkInventory()
end)
