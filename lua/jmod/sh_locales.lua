JMod.Locales = JMod.Locales or {}

for i, f in pairs(file.Find("jmod/locales/*.lua", "LUA")) do
	AddCSLuaFile("jmod/locales/" .. f)
	include("jmod/locales/" .. f)
end

if CLIENT then
	function JMod.Lang(key)
		local langCode = GetConVar("gmod_language"):GetString() or "en"
		local langTable = JMod.Locales[langCode] or JMod.Locales["en"]
		local stringLiteral = langTable[key] or JMod.Locales["en"][key]

		return stringLiteral or "LANG ENTRY MISSING: " .. key
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
