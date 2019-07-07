AddCSLuaFile()
player_manager.AddValidModel("JackaFireSuit","models/DPFilms/jetropolice/Playermodels/pm_policetrench.mdl")
player_manager.AddValidHands("JackaFireSuit","models/DPFilms/jeapons/v_arms_metropolice.mdl",0,"00000000")
player_manager.AddValidModel("JackaHazmatSuit","models/DPFilms/jetropolice/Playermodels/pm_police_bt.mdl")
player_manager.AddValidHands("JackaHazmatSuit","models/DPFilms/jeapons/v_arms_metropolice.mdl",0,"00000000")
player_manager.AddValidModel("JackyEODSuit","models/juggerjaut_player.mdl")
player_manager.AddValidHands("JackyEODSuit","models/DPFilms/jeapons/v_arms_metropolice.mdl",0,"00000000")
game.AddParticles("particles/muzzleflashes_test.pcf")
game.AddParticles("particles/muzzleflashes_test_b.pcf")
game.AddParticles( "particles/pcfs_jack_explosions_large.pcf")
game.AddParticles( "particles/pcfs_jack_explosions_medium.pcf")
game.AddParticles( "particles/pcfs_jack_explosions_small.pcf")

local ANGLE=FindMetaTable("Angle")
function ANGLE:GetCopy()
	return Angle(self.p,self.y,self.r)
end
local function stringFromTable(tab)
	
end
function jprint(...)
	local items,printstr={...},""
	for k,v in pairs(items)do
		-- todo: tables
		printstr=printstr..tostring(v)..", "
	end
	print(printstr)
	if(SERVER)then
		player.GetAll()[1]:PrintMessage(HUD_PRINTTALK,printstr)
		player.GetAll()[1]:PrintMessage(HUD_PRINTCENTER,printstr)
	elseif(CLIENT)then
		LocalPlayer():ChatPrint(printstr)
	end
end
function JMod_GoodBadColor(frac)
	-- color tech from bfs2114
	local r,g,b=math.Clamp(3-frac*4,0,1),math.Clamp(frac*2,0,1),math.Clamp(-3+frac*4,0,1)
	return r*255,g*255,b*255
end
-- EZ item quality grade (upgrade level) definitions
EZ_GRADE_BASIC=1
EZ_GRADE_COPPER=2
EZ_GRADE_SILVER=3
EZ_GRADE_GOLD=4
EZ_GRADE_PLATINUM=5
-- TODO
-- when you make the radio, give it a "black BFF" mode easter egg