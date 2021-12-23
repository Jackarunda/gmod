JMod.Locales=JMod.Locales or {}
for i,f in pairs(file.Find("jmod/locales/*.lua", "LUA"))do
    AddCSLuaFile("jmod/locales/" .. f)
    include("jmod/locales/" .. f)
end
function JMod.Lang(key)
    -- todo
end
