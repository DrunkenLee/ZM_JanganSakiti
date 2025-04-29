print("ZM_JanganSakiti: Initializing anti-cheat protection...")

local blackScreenActive = false
local blackPanel = nil

  local exemptUsernames = {
    ["BlondeDanger"] = true,
    ["nmkmsp"] = true,
    ["ModeratorMana"] = true,
    ["admin"] = true,
    ["Halfdan"] = true,
    ["ModeratorCC"] = true,
    ["Aikyoong"] = true,
    ["Assistant"] = true
  }


local disconnectFromServer = function()
  setGameSpeed(1);
  pauseSoundAndMusic();
  setShowPausedMessage(true);
  getCore():quit();
end

local function isExemptUser()
    local player = getSpecificPlayer(0)
    if player then
        local username = player:getUsername()
        if username and exemptUsernames[username] then
            print("ZM_JanganSakiti: Exempt user detected: " .. username)
            return true
        end
    end
    return false
end


local function createBlackScreen()
    if blackScreenActive or isExemptUser() then return end
    blackPanel = ISPanel:new(0, 0, getCore():getScreenWidth(), getCore():getScreenHeight())
    blackPanel:initialise()
    blackPanel:instantiate()
    blackPanel.backgroundColor = {r=0, g=0, b=0, a=1}
    blackPanel:setVisible(true)
    blackPanel:addToUIManager()
    blackPanel:bringToTop()

    blackPanel.onRightMouseDown = function() return true end
    blackPanel.onRightMouseUp = function() return true end
    blackPanel.onMouseDown = function() return true end
    blackPanel.onMouseUp = function() return true end
    blackPanel.onMouseMove = function() return true end

    blackPanel:setCapture(true)

    blackScreenActive = true

    if isClient() then
        sendClientCommand("ZM_JanganSakiti", "CheatAttempt", {})
    end

    print("ZM_JanganSakiti: Black screen enabled - cheat attempt blocked")
end

local function ensureBlackScreenVisible()
    if blackScreenActive and blackPanel then
        if not blackPanel:isVisible() then
            blackPanel:setVisible(true)
        end
        blackPanel:bringToTop()
        blackPanel:setX(0)
        blackPanel:setY(0)
        blackPanel:setWidth(getCore():getScreenWidth())
        blackPanel:setHeight(getCore():getScreenHeight())
    end
end

local function onKeyStartPressed(key)
    if key == 27 and blackScreenActive then
        Events.OnTick.Add(function()
            ensureBlackScreenVisible()
            Events.OnTick.Remove(ensureBlackScreenVisible)
        end)
    end

    if key == 210 then
        print("ZM_JanganSakiti: INSERT key detected")
        if not isExemptUser() then
            print("ZM_JanganSakiti: INSERT key detected - potential cheat attempt")
            createBlackScreen()
            return true
        else
            print("ZM_JanganSakiti: INSERT key allowed for exempt user")
        end
    end
    return false
end

local function onGameStart()
    print("ZM_JanganSakiti: Game started, registering key handlers...")
    Events.OnKeyPressed.Add(onKeyStartPressed)
    Events.OnKeyStartPressed.Add(onKeyStartPressed)
    Events.OnPreUIDraw.Add(ensureBlackScreenVisible)
    Events.OnMainMenuEnter.Add(ensureBlackScreenVisible)
    Events.OnGameStart.Add(ensureBlackScreenVisible)
    Events.OnCreatePlayer.Add(ensureBlackScreenVisible)
    Events.OnResolutionChange.Add(ensureBlackScreenVisible)
end

Events.OnPreUIDraw.Add(function()
    if isKeyDown(210) then
        if not blackScreenActive and not isExemptUser() then
            print("ZM_JanganSakiti: INSERT key detected through isKeyDown - potential cheat attempt")
            createBlackScreen()
            disconnectFromServer()
        end
    end

    if blackScreenActive then
        ensureBlackScreenVisible()
    end
end)

Events.OnGameStart.Add(onGameStart)

print("ZM_JanganSakiti: Anti-cheat key protection loaded")