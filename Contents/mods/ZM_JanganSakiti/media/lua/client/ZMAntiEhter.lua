(function()
  local exemptUsernames = {
    ["BlondeDanger"] = true,
    ["nmkmsp"] = true,
    ["ModeratorMana"] = true
  }

  local isExemptUser = function()
    local player = getPlayer()
    if player then
      local username = player:getUsername()
      if username and exemptUsernames[username] then
        print("ZM_JanganSakiti: Exempt user detected in EtherHack check: " .. username)
        return true
      end
    end
    return false
  end

  local etherHackFunctions = {
    'getAntiCheat8Status',
    'getAntiCheat12Status',
    'getExtraTexture',
    'hackAdminAccess',
    'isDisableFakeInfectionLevel',
    'isDisableInfectionLevel',
    'isDisableWetness',
    'isEnableUnlimitedCarry',
    'isOptimalWeight',
    'isOptimalCalories',
    'isPlayerInSafeTeleported',
    'learnAllRecipes',
    'requireExtra',
    'safePlayerTeleport',
    'toggleEnableUnlimitedCarry',
    'toggleOptimalWeight',
    'toggleOptimalCalories',
    'toggleDisableFakeInfectionLevel',
    'toggleDisableInfectionLevel',
    'toggleDisableWetness',
  };

  local disconnectFromServer = function()
    setGameSpeed(1);
    pauseSoundAndMusic();
    setShowPausedMessage(true);
    getCore():quit();
  end

  local getGlobalFunctions = function()
    local array = {};
    for name, value in pairs(_G) do
      if type(value) == 'function' and string.find(tostring(value), 'function ') == 1 then
        table.insert(array, name);
      end
    end
    table.sort(array, function(a, b) return a:upper() < b:upper() end);
    return array;
  end

  local kick = function(hackName)
    if isExemptUser() then
      print("ZM_JanganSakiti: Exempt user allowed to use " .. hackName)
      return
    end

    local player = getPlayer();
    local username = player:getUsername();
    local ticketMessage = 'Hello. I am using ' .. hackName .. '. Please ban me.'

    local __f = function(tickets) end
    __f = function(tickets)
      Events.ViewTickets.Remove(__f);
      local length = tickets:size() - 1;
      for i = 0, length, 1 do
        local ticket = tickets:get(i);
        local author, message = ticket:getAuthor(), ticket:getMessage();
        if author == username and message == ticketMessage then
          disconnectFromServer();
          return
        end
      end
      addTicket(username, ticketMessage, -1);
      disconnectFromServer();
    end
    Events.ViewTickets.Add(__f);

    getTickets(username);
  end

  local hasValue = function(array, value)
    for _, next in ipairs(array) do if value == next then return true end end
    return false
  end

  local checkIfGlobalFunctionsExists = function(global, funcs)
    for i = 1, #funcs do if hasValue(global, funcs[i]) then return true end end
    return false;
  end

  local detectEtherHack = function(global)
    if checkIfGlobalFunctionsExists(global, etherHackFunctions) then
      kick('EtherHack');
      return true;
    end
    return false;
  end
end)();
