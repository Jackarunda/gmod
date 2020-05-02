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

hook.Add("SetupMove","JMOD_ARMOR_MOVE",function(ply,mv,cmd)
	---[[
	if((ply.EZarmor)and(ply.EZarmor.speedfrac)and not(ply.EZarmor.speedfrac==1))then
		local origSpeed=(cmd:KeyDown(IN_SPEED) and ply:GetRunSpeed()) or ply:GetWalkSpeed()
		mv:SetMaxClientSpeed(origSpeed*ply.EZarmor.speedfrac)
	end
	--]]
end)
function JMod_GoodBadColor(frac)
	-- color tech from bfs2114
	local r,g,b=math.Clamp(3-frac*4,0,1),math.Clamp(frac*2,0,1),math.Clamp(-3+frac*4,0,1)
	return r*255,g*255,b*255
end
function JMOD_WhomILookinAt(ply,cone,dist)
	local CreatureTr,ObjTr,OtherTr=nil,nil,nil
	for i=1,(150*cone) do
		local Vec=(ply:GetAimVector()+VectorRand()*cone):GetNormalized()
		local Tr=util.QuickTrace(ply:GetShootPos(),Vec*dist,{ply})
		if((Tr.Hit)and not(Tr.HitSky)and(Tr.Entity))then
			local Ent,Class=Tr.Entity,Tr.Entity:GetClass()
			if((Ent:IsPlayer())or(Ent:IsNPC()))then
				CreatureTr=Tr
			elseif((Class=="prop_physics")or(Class=="prop_physics_multiplayer")or(Class=="prop_ragdoll"))then
				ObjTr=Tr
			else
				OtherTr=Tr
			end
		end
	end
	if(CreatureTr)then return CreatureTr.Entity,CreatureTr.HitPos,CreatureTr.HitNormal end
	if(ObjTr)then return ObjTr.Entity,ObjTr.HitPos,ObjTr.HitNormal end
	if(OtherTr)then return OtherTr.Entity,OtherTr.HitPos,OtherTr.HitNormal end
	return nil,nil,nil
end
--
function JMod_IsDoor(ent)
	local Class=ent:GetClass()
	return ((Class=="prop_door")or(Class=="prop_door_rotating")or(Class=="func_door")or(Class=="func_door_rotating"))
end
--
function JMod_PlayersCanComm(listener,talker)
	if(listener==talker)then return true end
	if (engine.ActiveGamemode()=="sandbox") then
		return ((talker.JModFriends) and (table.HasValue(talker.JModFriends,listener)))
	else
		if ((talker.JModFriends) and (table.HasValue(talker.JModFriends,listener))) then return true end
		return listener:Team()==talker:Team()
	end
end
--
hook.Add("EntityFireBullets","JMOD_ENTFIREBULLETS",function(ent,data)
	if(IsValid(JMOD_BLACK_HOLE))then
		local BHpos=JMOD_BLACK_HOLE:GetPos()
		local Bsrc,Bdir=data.Src,data.Dir
		local Vec=BHpos-Bsrc
		local Dist=Vec:Length()
		if(Dist<10000)then
			local ToBHdir=Vec:GetNormalized()
			local NewDir=(Bdir+ToBHdir*JMOD_BLACK_HOLE:GetAge()/Dist*20):GetNormalized()
			data.Dir=NewDir
			return true
		end
	end
end)