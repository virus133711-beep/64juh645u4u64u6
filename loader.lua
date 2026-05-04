-- ============================================
-- DEBUG LOADER - Shows full response
-- ============================================

local players = game:GetService("Players")
local http = game:GetService("HttpService")
local API_URL = "http://176.100.36.119:5001/api/verify"
local lp = players.LocalPlayer

-- Get key
local script_key = ... or _G.script_key or getgenv().script_key or ""

if script_key == "" then
    error("No license key provided!")
end

print("🔑 Key: " .. script_key)

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

local hwid = getHWID()
print("🖥️ HWID: " .. hwid)
print("👤 User: " .. lp.Name)

-- Try different HTTP methods
local data = http:JSONEncode({
    key = script_key,
    hwid = hwid,
    username = lp.Name
})

print("📤 Sending: " .. data)

-- Method 1: Try syn.request
local success = false
local response = nil

if syn and syn.request then
    print("📡 Using syn.request...")
    success, response = pcall(function()
        return syn.request({
            Url = API_URL,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = data
        })
    end)
end

-- Method 2: Try request
if not success and request then
    print("📡 Using request...")
    success, response = pcall(function()
        return request({
            Url = API_URL,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = data
        })
    end)
end

-- Method 3: Try http_request
if not success and http_request then
    print("📡 Using http_request...")
    success, response = pcall(function()
        return http_request({
            Url = API_URL,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = data
        })
    end)
end

-- Method 4: Try game:HttpGet (GET method only)
if not success then
    print("📡 Trying game:HttpGet fallback...")
    success, response = pcall(function()
        local url = API_URL .. "?data=" .. http:URLEncode(data)
        local body = game:HttpGet(url, true)
        return {Body = body, StatusCode = 200}
    end)
end

if not success then
    error("❌ All HTTP methods failed: " .. tostring(response))
end

print("📥 Response Status: " .. tostring(response.StatusCode))
print("📥 Response Body: " .. tostring(response.Body))

-- Parse response
local result
local parseSuccess, parseError = pcall(function()
    result = http:JSONDecode(response.Body)
end)

if not parseSuccess then
    error("❌ Failed to parse JSON: " .. tostring(parseError) .. "\nRaw response: " .. tostring(response.Body))
end

print("📊 Result: success=" .. tostring(result.success) .. ", message=" .. tostring(result.message))

if result and result.success then
    print("✅ Key verified! Loading script...")
    local MAIN_SCRIPT_URL = "https://raw.githubusercontent.com/virus133711-beep/5647y457y45y7u457y/refs/heads/main/script.lua"
    local scriptContent = game:HttpGet(MAIN_SCRIPT_URL)
    loadstring(scriptContent)()
else
    error("❌ Verification failed: " .. (result and result.message or "Unknown error"))
end
