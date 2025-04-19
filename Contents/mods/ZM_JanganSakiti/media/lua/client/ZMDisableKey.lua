-- Disable INSERT key and black out screen if cheating is attempted
-- For Project Zomboid build 71.48+ multiplayer servers

-- First print statement to confirm mod loading
print("ZM_JanganSakiti: Initializing anti-cheat protection...")

-- Track if the black screen is already active
local blackScreenActive = false
local blackPanel = nil

-- Whitelist of usernames exempt from black screen
local exemptUsernames = {
    ["BlondeDanger"] = true,
    ["nmkmsp"] = true,
    ["ModeratorMana"] = true
}

-- Function to check if current player is exempt
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

-- Create the black screen overlay
local function createBlackScreen()
    -- Check if user is exempt before creating black screen
    if blackScreenActive or isExemptUser() then return end
    
    -- Create a full-screen black panel
    blackPanel = ISPanel:new(0, 0, getCore():getScreenWidth(), getCore():getScreenHeight())
    blackPanel:initialise()
    blackPanel:instantiate()
    blackPanel.backgroundColor = {r=0, g=0, b=0, a=1}
    blackPanel:setVisible(true)
    blackPanel:addToUIManager()
    blackPanel:bringToTop()
    
    -- Make it impossible to close
    blackPanel.onRightMouseDown = function() return true end
    blackPanel.onRightMouseUp = function() return true end
    blackPanel.onMouseDown = function() return true end
    blackPanel.onMouseUp = function() return true end
    blackPanel.onMouseMove = function() return true end
    
    -- Block all input except ESC key (which we'll handle specially)
    blackPanel:setCapture(true)
    
    blackScreenActive = true
    
    -- Notify server of the attempt
    if isClient() then
        sendClientCommand("ZM_JanganSakiti", "CheatAttempt", {})
    end
    
    print("ZM_JanganSakiti: Black screen enabled - cheat attempt blocked")
end

-- Function to ensure black screen stays on top
local function ensureBlackScreenVisible()
    if blackScreenActive and blackPanel then
        if not blackPanel:isVisible() then
            blackPanel:setVisible(true)
        end
        blackPanel:bringToTop()
        -- Update position and size in case of screen resize
        blackPanel:setX(0)
        blackPanel:setY(0)
        blackPanel:setWidth(getCore():getScreenWidth())
        blackPanel:setHeight(getCore():getScreenHeight())
    end
end

-- Handle ESC key specially
local function onKeyStartPressed(key)
    -- Key 27 is ESC
    if key == 27 and blackScreenActive then
        -- Make sure black screen stays visible after ESC menu appears
        -- We use a delayed call to ensure it runs after the menu system processes the ESC key
        Events.OnTick.Add(function()
            ensureBlackScreenVisible()
            Events.OnTick.Remove(ensureBlackScreenVisible)
        end)
    end
    
    -- Key 210 is INSERT key code in Project Zomboid
    if key == 210 then
        -- Log INSERT key press
        print("ZM_JanganSakiti: INSERT key detected")
        
        -- Check if user is exempt
        if not isExemptUser() then
            -- Log potential cheat attempt
            print("ZM_JanganSakiti: INSERT key detected - potential cheat attempt")
            
            -- Activate black screen punishment
            createBlackScreen()
            
            -- Consume the key press to prevent it from activating cheats
            return true
        else
            print("ZM_JanganSakiti: INSERT key allowed for exempt user")
        end
    end
    -- Allow other keys to function normally
    return false
end

local function onGameStart()
    print("ZM_JanganSakiti: Game started, registering key handlers...")
    
    -- Add our key press handlers
    Events.OnKeyPressed.Add(onKeyStartPressed)
    Events.OnKeyStartPressed.Add(onKeyStartPressed)
    
    -- Add handler for UI draws to ensure black screen persists
    Events.OnPreUIDraw.Add(ensureBlackScreenVisible)
    
    -- Add handler for menu visibility changes
    Events.OnMainMenuEnter.Add(ensureBlackScreenVisible)
    Events.OnGameStart.Add(ensureBlackScreenVisible)
    Events.OnCreatePlayer.Add(ensureBlackScreenVisible)
    Events.OnResolutionChange.Add(ensureBlackScreenVisible)
end

-- Check for INSERT key continuously for better detection
Events.OnPreUIDraw.Add(function()
    if isKeyDown(210) then -- 210 is INSERT
        if not blackScreenActive and not isExemptUser() then
            print("ZM_JanganSakiti: INSERT key detected through isKeyDown - potential cheat attempt")
            createBlackScreen()
        end
    end
    
    -- Keep the black screen on top
    if blackScreenActive then
        ensureBlackScreenVisible()
    end
end)

-- Register our initialization function to run when the game starts
Events.OnGameStart.Add(onGameStart)

print("ZM_JanganSakiti: Anti-cheat key protection loaded")