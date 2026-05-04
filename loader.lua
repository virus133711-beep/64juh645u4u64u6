-- ============================================
-- SIMPLE LOADER - FIXED VERSION
-- ============================================

local players = game:GetService("Players")
local http = game:GetService("HttpService")
local API_URL = "http://176.100.36.119:5001/api/verify"
local lp = players.LocalPlayer

-- ============================================
-- GET THE KEY (MULTIPLE METHODS)
-- ============================================
local script_key = nil

-- Method 1: Check if it was passed as an argument
if ... and ... ~= "" then
    script_key = ...
    print("✅ Key found via argument")
end

-- Method 2: Check global variable
if not script_key and _G.script_key and _G.script_key ~= "" then
    script_key = _G.script_key
    print("✅ Key found via _G.script_key")
end

-- Method 3: Check getgenv
if not script_key and getgenv and getgenv().script_key and getgenv().script_key ~= "" then
    script_key = getgenv().script_key
    print("✅ Key found via getgenv().script_key")
end

-- Method 4: Check shared
if not script_key and shared and shared.script_key and shared.script_key ~= "" then
    script_key = shared.script_key
    print("✅ Key found via shared.script_key")
end

-- If no key found, show error
if not script_key or script_key == "" then
    error([[
    ❌ No license key provided!
    
    Please use ONE of these methods:
    
    Method 1 (Recommended):
    loadstring(game:HttpGet("YOUR_LOADER_URL"))("YOUR_KEY_HERE")
    
    Method 2:
    script_key = "YOUR_KEY_HERE"
    loadstring(game:HttpGet("YOUR_LOADER_URL"))()
    
    Method 3:
    getgenv().script_key = "YOUR_KEY_HERE"
    loadstring(game:HttpGet("YOUR_LOADER_URL"))()
    ]])
end

print("🔑 Key found: " .. script_key)

-- ============================================
-- GET HWID
-- ============================================
local function getHWID()
    local userId = lp.UserId
    local accountAge = lp.AccountAge
    
    local graphicsInfo = ""
    pcall(function()
        graphicsInfo = tostring(settings().Rendering.GraphicsMode)
    end)
    
    local viewportSize = workspace.CurrentCamera.ViewportSize
    local screenInfo = tostring(viewportSize.X) .. "x" .. tostring(viewportSize.Y)
    local executor = identifyexecutor and identifyexecutor() or "Unknown"
    
    local hwidString = tostring(userId) .. ":" .. tostring(accountAge) .. ":" .. graphicsInfo .. ":" .. screenInfo .. ":" .. executor
    
    local hash = ""
    for i = 1, #hwidString do
        hash = hash .. string.format("%02x", string.byte(hwidString, i))
    end
    
    return hash:sub(1, 32)
end

-- ============================================
-- VERIFY KEY
-- ============================================
local function verifyKey(key)
    local hwid = getHWID()
    
    -- Find working HTTP function
    local requestFunc = syn and syn.request or request or http_request or (http and http.request)
    
    if not requestFunc then
        -- Try using game:HttpGet as fallback
        return false, "No HTTP function available. Try a different executor."
    end
    
    local data = {
        key = key,
        hwid = hwid,
        username = lp.Name
    }
    
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
        return false, "Connection failed: " .. tostring(response)
    end
    
    if response and response.Body then
        local result = http:JSONDecode(response.Body)
        if result and result.success then
            return true, "Verified!"
        elseif result and result.message then
            if result.message == "INVALID_KEY" then
                return false, "Invalid license key!"
            elseif result.message == "KEY_EXPIRED" then
                return false, "Key has expired!"
            elseif result.message == "WRONG_HWID" then
                return false, "Key locked to another HWID!"
            else
                return false, result.message
            end
        end
    end
    
    return false, "Verification failed - Server error"
end

-- ============================================
-- MAIN SCRIPT URL
-- ============================================
local MAIN_SCRIPT_URL = "https://raw.githubusercontent.com/virus133711-beep/5647y457y45y7u457y/refs/heads/main/script.lua"

-- ============================================
-- RUN VERIFICATION
-- ============================================
print("🔒 Verifying license...")
local valid, message = verifyKey(script_key)

if valid then
    print("✅ " .. message)
    print("📥 Loading script...")
    local scriptContent = game:HttpGet(MAIN_SCRIPT_URL)
    loadstring(scriptContent)()
else
    error("❌ " .. message)
end
