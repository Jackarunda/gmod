AddCSLuaFile()

--[[ -- Old include lines if you want it
local sv = {
    "jmod_server",
    "jmod_server_armor",
    "jmod_server_radio",
    "jmod_server_utility"
}

local sh = {
    "jmod_shared",
    "jmod_shared_armor"
}

local cl = {
    "jmod_client",
    "jmod_client_armor",
    "jmod_client_gui",
    "jmod_client_hud"
}

-- Shared files
for _, f in pairs(sh) do
    AddCSLuaFile("jmod/" .. f .. ".lua")
    include("jmod/" .. f .. ".lua")
end

-- Client files (AddCSLuaFile'd in shared)
for _, f in pairs(cl) do
    AddCSLuaFile("jmod/" .. f .. ".lua")
end

if SERVER then -- Server files
    for _, f in pairs(sv) do
        include("jmod/" .. f .. ".lua")
    end
elseif CLIENT then -- Client files
    for _, f in pairs(cl) do
        include("jmod/" .. f .. ".lua")
    end
end
]]

local sv, sh, cl = {}, {}, {}

for i, f in pairs(file.Find("jmod/*.lua", "LUA")) do
    
    if string.Left(f, 3) == "sv_" then
        if SERVER then include("jmod/" .. f) end
    elseif string.Left(f, 3) == "cl_" then
        if CLIENT then include("jmod/" .. f)
        else AddCSLuaFile("jmod/" .. f) end
    elseif string.Left(f, 3) == "sh_" then
        AddCSLuaFile("jmod/" .. f)
        include("jmod/" .. f)
    else
        print("JMod detected unaccounted for lua file '" .. f .. "' - check prefixes!")
    end
    
end

