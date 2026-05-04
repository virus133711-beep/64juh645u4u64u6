local key = "A4F9F4E8F1F8230C-54102334-07CEAE81"
local hwid = getHWID()

-- Get keys from pastebin
local pastebinURL = "https://pastebin.com/raw/qe5bJ9tM"
local keyData = game:HttpGet(pastebinURL)

-- Check if key exists and is valid
local valid = false
for line in string.gmatch(keyData, "[^\n]+") do
    if not line:startswith("#") then
        local parts = {}
        for part in string.gmatch(line, "[^|]+") do
            table.insert(parts, part)
        end
        local storedKey = parts[1]
        local storedHWID = parts[2]
        local activated = parts[3]
        local expires = parts[4]
        
        if storedKey == key then
            if activated == "1" and storedHWID ~= "" and storedHWID ~= hwid then
                valid = false
                break
            end
            valid = true
            break
        end
    end
end

if valid then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/virus133711-beep/5647y457y45y7u457y/refs/heads/main/script.lua"))()
else
    error("Invalid key")
end
