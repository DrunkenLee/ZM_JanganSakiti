-- Server-side handler for logging cheat attempts
-- For Project Zomboid build 71.48+ multiplayer servers

print("ZM_JanganSakiti: Server-side cheat handler initializing...")

-- Function to handle client commands
local function onClientCommand(module, command, player, args)
    -- Only process our mod's commands
    if module ~= "ZM_JanganSakiti" then return end
    
    -- Handle cheat attempt detection with proper null checks
    if command == "CheatAttempt" and player then
        -- Safely get player info
        local username = player:getUsername() or "Unknown"
        
        -- Check if player is an admin
        local isAdmin = false
        if player:getAccessLevel() and player:getAccessLevel() ~= "" then
            isAdmin = true
        end

        -- Improved log with details from args
        local reason = args and args.reason or "Unknown"
        local itemType = args and args.itemType or "Unknown"
        local amount = args and args.amount or "Unknown"

        print(string.format(
            "ZM_JanganSakiti: Cheat detected! Player: %s%s | Reason: %s | Item: %s | Amount: %s",
            username,
            isAdmin and " (ADMIN)" or "",
            reason,
            itemType,
            tostring(amount)
        ))
    end
end

-- Register for client commands
Events.OnClientCommand.Add(onClientCommand)

print("ZM_JanganSakiti: Server-side anti-cheat handler loaded successfully")