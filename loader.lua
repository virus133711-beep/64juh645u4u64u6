-- ============================================
-- UNIVERSAL LOADER (Works with most executors)
-- ============================================

local players = game:GetService("Players")
local http = game:GetService("HttpService")
local API_URL = "http://176.100.36.119:5001/api/verify"
local lp = players.LocalPlayer

-- Universal HTTP request function
local function getRequestFunction()
    -- Try different executor HTTP functions
    local requestFunc = syn and syn.request 
        or request 
        or http_request 
        or http.request 
        or (http and http.request)
        or (getgenv and getgenv().request)
        or (shared and shared.request)
    
    -- For executors that use loadstring with custom functions
    if not requestFunc then
        -- Check if we can use game:HttpGet (limited but works sometimes)
        local success, result = pcall(function()
            return game:HttpGet(API_URL)
        end)
        if success then
            return function(options)
                local body = game:HttpGet(options.Url)
                return {Body = body, StatusCode = 200}
            end
        end
    end
    
    return requestFunc
end

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
    local executor = identifyexecutor and identifyexecutor() or "Unknown"
    
    local hwidString = tostring(userId) .. ":" .. tostring(accountAge) .. ":" .. graphicsInfo .. ":" .. screenInfo .. ":" .. executor
    
    local hash = ""
    for i = 1, #hwidString do
        hash = hash .. string.format("%02x", string.byte(hwidString, i))
    end
    
    return hash:sub(1, 32)
end

-- Verify key
local function verifyKey(key)
    local hwid = getHWID()
    local requestFunc = getRequestFunction()
    
    if not requestFunc then
        return false, "No HTTP request function found for your executor!"
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
        return false, "Request failed: " .. tostring(response)
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
    
    return false, "Verification failed!"
end

-- ============================================
-- YOUR MAIN SCRIPT URL
-- ============================================
local MAIN_SCRIPT_URL = "https://raw.githubusercontent.com/virus133711-beep/5647y457y45y7u457y/refs/heads/main/script.lua"

-- ============================================
-- GET KEY FROM ARGUMENT
-- ============================================
local script_key = ... or ""

if script_key == "" then
    error("No license key provided!")
end

print("Verifying key: " .. script_key)
local valid, message = verifyKey(script_key)

if valid then
    print("Success! Loading script...")
    local success, result = pcall(function()
        return game:HttpGet(MAIN_SCRIPT_URL)
    end)
    
    if success and result then
        loadstring(result)()
    else
        error("Failed to load main script: " .. tostring(result))
    end
else
    error("License error: " .. message)
end
