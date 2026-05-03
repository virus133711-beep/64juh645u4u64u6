-- ============================================
-- KEY SYSTEM LOADER
-- ============================================

local players = game:GetService("Players")
local http = game:GetService("HttpService")

-- Configuration
local API_URL = "http://176.100.36.119:5001/api/verify"
local lp = players.LocalPlayer

-- Get HWID
local function getHWID()
    local userId = lp.UserId
    local accountAge = lp.AccountAge
    
    local graphicsInfo = ""
    pcall(function()
        graphicsInfo = tostring(settings().Rendering.GraphicsMode)
    end)
    
    local viewportSize = workspace.CurrentCamera.ViewportSize
    local screenInfo = tostring(viewportSize.X) .. "x" .. tostring(viewportSize.Y)
    
    local hwidString = tostring(userId) .. ":" .. tostring(accountAge) .. ":" .. graphicsInfo .. ":" .. screenInfo
    
    local hash = ""
    for i = 1, #hwidString do
        hash = hash .. string.format("%02x", string.byte(hwidString, i))
    end
    
    return hash:sub(1, 32)
end

-- Verify key with server
local function verifyKey(key)
    local hwid = getHWID()
    
    local data = {
        key = key,
        hwid = hwid,
        username = lp.Name
    }
    
    local requestFunc = syn and syn.request or request or http_request or (http and http.request)
    
    if not requestFunc then
        return false, "No HTTP request method available!"
    end
    
    local success, response = pcall(function()
        return requestFunc({
            Url = API_URL,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = http:JSONEncode(data)
        })
    end)
    
    if success and response and response.Body then
        local result = http:JSONDecode(response.Body)
        
        if result.success then
            return true, "Key verified!"
        else
            if result.message == "INVALID_KEY" then
                return false, "Invalid license key!"
            elseif result.message == "KEY_EXPIRED" then
                return false, "Key has expired!"
            elseif result.message == "WRONG_HWID" then
                return false, "Key locked to another HWID!"
            else
                return false, result.message or "Verification failed!"
            end
        end
    end
    
    return false, "Could not connect to license server!"
end

-- Main execution
local script_key = "YWGSCaYzIjfkZbYKfbbFSEWiIEQtqgBz"  -- CHANGE THIS TO YOUR KEY

print("Verifying license...")
local valid, message = verifyKey(script_key)

if valid then
    print("✅ " .. message)
    print("Loading script...")
    -- Load your actual script here
    loadstring(game:HttpGet("https://github.com/virus133711-beep/5647y457y45y7u457y/blob/main/script.lua"))()
else
    print("❌ " .. message)
    print("Invalid license key. Please contact the seller.")
    -- Optional: Kick or shutdown
    game:Shutdown()
end