-- ============================================
-- DA HOOD SCRIPT LOADER WITH KEY VERIFICATION
-- ============================================

local players = game:GetService("Players")
local http = game:GetService("HttpService")
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

-- Verify key
local function verifyKey(key)
    local hwid = getHWID()
    
    local data = {
        key = key,
        hwid = hwid,
        username = lp.Name
    }
    
    local requestFunc = syn and syn.request or request or http_request or (http and http.request)
    
    if not requestFunc then
        return false, "No HTTP request method!"
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
    
    if not success then
        return false, "Request failed: " .. tostring(response)
    end
    
    if not response then
        return false, "No response from server"
    end
    
    if response.StatusCode ~= 200 then
        return false, "Server error: " .. tostring(response.StatusCode)
    end
    
    if not response.Body or response.Body == "" then
        return false, "Empty response from server"
    end
    
    -- Safely parse JSON
    local result
    local parseSuccess, parseError = pcall(function()
        result = http:JSONDecode(response.Body)
    end)
    
    if not parseSuccess then
        print("Raw response: " .. tostring(response.Body))
        return false, "Invalid server response"
    end
    
    if result.success then
        return true, "Verified!"
    else
        if result.message == "INVALID_KEY" then
            return false, "Invalid key!"
        elseif result.message == "KEY_EXPIRED" then
            return false, "Key expired!"
        elseif result.message == "WRONG_HWID" then
            return false, "Key locked to another HWID!"
        else
            return false, result.message or "Verification failed!"
        end
    end
end

-- ============================================
-- CHANGE THIS TO YOUR ACTUAL SCRIPT URL
-- ============================================
local MAIN_SCRIPT_URL = "https://raw.githubusercontent.com/virus133711-beep/5647y457y45y7u457y/refs/heads/main/script.lua"

-- ============================================
-- GET KEY FROM ARGUMENT
-- ============================================
local script_key = ... or ""

if script_key == "" then
    error("❌ No license key provided!\nUsage: loadstring(game:HttpGet('loader_url'))('YOUR_KEY')")
end

print("🔑 Verifying license key: " .. script_key)
local valid, message = verifyKey(script_key)

if valid then
    print("✅ " .. message)
    print("📥 Loading script...")
    local scriptContent = game:HttpGet(MAIN_SCRIPT_URL)
    loadstring(scriptContent)()
else
    print("❌ " .. message)
    warn("Invalid license key. Contact seller.")
    task.wait(3)
    game:Shutdown()
end
