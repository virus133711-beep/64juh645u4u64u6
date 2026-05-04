-- ============================================
-- DIRECT API LOADER (No pastebin needed)
-- ============================================

local script_key = ... or _G.script_key or ""

if script_key == "" then
    error("❌ No license key provided! Usage: loadstring(...)('YOUR_KEY')")
end

print("🔑 Verifying key: " .. script_key)

local API_URL = "http://176.100.36.119:5001/api/verify"
local http = game:GetService("HttpService")
local lp = game:GetService("Players").LocalPlayer

-- Get HWID
local function getHWID()
    local userId = lp.UserId
    local accountAge = lp.AccountAge
    local graphicsInfo = ""
    pcall(function() graphicsInfo = tostring(settings().Rendering.GraphicsMode) end)
    local viewportSize = workspace.CurrentCamera.ViewportSize
    local screenInfo = tostring(viewportSize.X) .. "x" .. tostring(viewportSize.Y)
    local hwidString = tostring(userId) .. ":" .. tostring(accountAge) .. ":" .. graphicsInfo .. ":" .. screenInfo
    local hash = ""
    for i = 1, #hwidString do
        hash = hash .. string.format("%02x", string.byte(hwidString, i))
    end
    return hash:sub(1, 32)
end

local hwid = getHWID()
print("🖥️ HWID: " .. hwid)

-- Make request
local requestFunc = syn and syn.request or request or http_request or (http and http.request)

if not requestFunc then
    error("❌ No HTTP function available for your executor!")
end

local data = http:JSONEncode({
    key = script_key,
    hwid = hwid,
    username = lp.Name
})

local success, response = pcall(function()
    return requestFunc({
        Url = API_URL,
        Method = "POST",
        Headers = {["Content-Type"] = "application/json"},
        Body = data
    })
end)

if not success then
    error("❌ Connection failed: " .. tostring(response))
end

local result = http:JSONDecode(response.Body)

if result and result.success then
    print("✅ Key verified! Loading script...")
    local MAIN_SCRIPT = "https://raw.githubusercontent.com/virus133711-beep/5647y457y45y7u457y/refs/heads/main/script.lua"
    loadstring(game:HttpGet(MAIN_SCRIPT))()
else
    local msg = result and result.message or "Unknown error"
    error("❌ " .. msg)
end
