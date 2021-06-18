AddCSLuaFile()

JMod = JMod or {}

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
