game.AddParticles("particles/muzzleflashes_test.pcf")
game.AddParticles("particles/muzzleflashes_test_b.pcf")
game.AddParticles("particles/pcfs_jack_explosions_large.pcf")
game.AddParticles("particles/pcfs_jack_explosions_medium.pcf")
game.AddParticles("particles/pcfs_jack_explosions_small.pcf")
game.AddParticles("particles/pcfs_jack_nuclear_explosions.pcf")
game.AddParticles("particles/pcfs_jack_moab.pcf")
game.AddParticles("particles/gb5_large_explosion.pcf")
game.AddParticles("particles/gb5_500lb.pcf")
game.AddParticles("particles/gb5_100lb.pcf")
game.AddParticles("particles/gb5_50lb.pcf")
game.AddDecal("BigScorch",{"decals/big_scorch1","decals/big_scorch2","decals/big_scorch3"})
game.AddDecal("GiantScorch",{"decals/giant_scorch1","decals/giant_scorch2","decals/giant_scorch3"})
PrecacheParticleSystem("pcf_jack_nuke_ground")
PrecacheParticleSystem("pcf_jack_nuke_air")
PrecacheParticleSystem("pcf_jack_moab")
PrecacheParticleSystem("pcf_jack_moab_air")
PrecacheParticleSystem("cloudmaker_air")
PrecacheParticleSystem("cloudmaker_ground")
PrecacheParticleSystem("500lb_air")
PrecacheParticleSystem("500lb_ground")
PrecacheParticleSystem("100lb_air")
PrecacheParticleSystem("100lb_ground")
PrecacheParticleSystem("50lb_air")
--PrecacheParticleSystem("50lb_ground")
--
JMod.RavebreakBeatTime=.4
local Alphanumerics={"0","1","2","3","4","5","6","7","8","9","a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z","A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"}
function JMod.GenerateGUID()
	local Res=""
	for i=1,8 do
		Res=Res..table.Random(Alphanumerics)
	end
	return Res
end
--
function JMod.LinCh(num,low,high)
	-- Linear Chance
	return num>=(low+(high-low)*math.Rand(0,1))
end
--
function JMod.PlayersCanComm(listener,talker)
	if(listener==talker)then return true end
	if (engine.ActiveGamemode()=="sandbox") then
		return ((talker.JModFriends) and (table.HasValue(talker.JModFriends,listener)))
	else
		if ((talker.JModFriends) and (table.HasValue(talker.JModFriends,listener))) then return true end
		return listener:Team()==talker:Team()
	end
end
---
local OldPrecacheSound=util.PrecacheSound
util.PrecacheSound=function(snd)
	if(snd)then OldPrecacheSound(snd) end
end
local OldPrecacheModel=util.PrecacheModel
util.PrecacheModel=function(mdl)
	if(mdl)then OldPrecacheModel(mdl) end
end
--
hook.Add("EntityFireBullets","JMOD_ENTFIREBULLETS",function(ent,data)
	if(IsValid(JMod.BlackHole))then
		local BHpos=JMod.BlackHole:GetPos()
		local Bsrc,Bdir=data.Src,data.Dir
		local Vec=BHpos-Bsrc
		local Dist=Vec:Length()
		if(Dist<10000)then
			local ToBHdir=Vec:GetNormalized()
			local NewDir=(Bdir+ToBHdir*JMod.BlackHole:GetAge()/Dist*20):GetNormalized()
			data.Dir=NewDir
			return true
		end
	end
end)
hook.Add("StartCommand","JMod_StartCommand",function(ply,ucmd)
	local Time=CurTime()
	if(ply.JMod_RavebreakEndTime and ply.JMod_RavebreakEndTime>Time and ply.JMod_RavebreakStartTime<Time)then
		local Btns=ucmd:GetButtons()
		if(math.random(1,30)==1)then Btns=bit.bor(Btns,IN_JUMP) end
		if(math.random(1,5)==1)then Btns=bit.bor(Btns,IN_ATTACK) end
		if(math.random(1,400)==1)then Btns=bit.bor(Btns,IN_RELOAD) end
		ucmd:SetButtons(Btns)
	end
end)