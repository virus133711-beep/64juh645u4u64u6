-- ============================================
-- LOADER WITH KEY PARAMETER SUPPORT
-- ============================================

-- Get the key from the argument passed in
local script_key = ... or ""

-- Also check if it was set as a global variable
if script_key == "" and _G.script_key then
    script_key = _G.script_key
end

if script_key == "" then
    error([[
❌ No license key provided!

Usage (Method 1 - Recommended):
loadstring(game:HttpGet("YOUR_LOADER_URL"))("YOUR_KEY_HERE")

Usage (Method 2):
script_key = "YOUR_KEY_HERE"
loadstring(game:HttpGet("YOUR_LOADER_URL"))()
    ]])
end

print("🔑 Key found: " .. script_key)

-- Get HWID
local function getHWID()
    local lp = game:GetService("Players").LocalPlayer
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

-- Verify key via pastebin
local hwid = getHWID()
print("🖥️ HWID: " .. hwid)

-- Get keys from pastebin
local pastebinURL = "https://pastebin.com/raw/qe5bJ9tM"
local keyData = game:HttpGet(pastebinURL)

-- Check if key exists and is valid
local valid = false
local errorMsg = ""

for line in string.gmatch(keyData, "[^\n]+") do
    if not line:match("^#") then
        local parts = {}
        for part in string.gmatch(line, "[^|]+") do
            table.insert(parts, part)
        end
        
        if #parts >= 4 then
            local storedKey = parts[1]
            local storedHWID = parts[2]
            local activated = parts[3]
            local expires = parts[4]
            
            if storedKey == script_key then
                -- Check expiration
                if expires and tonumber(expires) and os.time() > tonumber(expires) then
                    valid = false
                    errorMsg = "Key has expired!"
                    break
                end
                
                -- Check if key is already used and HWID mismatch
                if activated == "1" and storedHWID ~= "" and storedHWID ~= hwid then
                    valid = false
                    errorMsg = "Key is locked to another HWID!"
                    break
                end
                
                valid = true
                break
            end
        end
    end
end

if valid then
    print("✅ Key verified! Loading script...")
    local scriptContent = game:HttpGet("https://raw.githubusercontent.com/virus133711-beep/5647y457y45y7u457y/refs/heads/main/script.lua")
    loadstring(scriptContent)()
else
    error("❌ " .. (errorMsg ~= "" and errorMsg or "Invalid license key!"))
end
