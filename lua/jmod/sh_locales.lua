JMod.Locales=JMod.Locales or {}
for i,f in pairs(file.Find("jmod/locales/*.lua", "LUA"))do
    AddCSLuaFile("jmod/locales/" .. f)
    include("jmod/locales/" .. f)
end
if(CLIENT)then
    function JMod.Lang(key)
        
    end
end

--[[
en
bg
cs
da
de
el
en-PT
es-ES
et
fi
fr
he
hr
hu
it
ja
ko
lt
nl
no
pl
pt-BR
pt-PT
ru
sk
sv-SE
th
tr
uk
vi
zh-CN
zh-TW
--]]
