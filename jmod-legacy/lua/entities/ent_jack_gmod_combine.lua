AddCSLuaFile()
ENT.Type 			= "anim"
ENT.PrintName		= "Combine"
ENT.Author			= "Jackarunda"
ENT.Information		= ""
ENT.Category		= "JMod - LEGACY NPCs"

ENT.Spawnable		= true
ENT.AdminSpawnable	= true
if(SERVER)then
	local SquadName="JackyCombineOpSquad"
	local function Anchor(npc)
		local TrDat={}
		TrDat.start=npc:GetPos()+Vector(0,0,50)
		TrDat.endpos=npc:GetPos()+Vector(0,0,-30)
		TrDat.filter={npc}
		local Tr=util.TraceLine(TrDat)
		if(Tr.Hit)then
			constraint.Weld(npc,Tr.Entity,0,0,5000)
		end
	end
	function ENT:SpawnFunction(ply,tr)
		local selfpos=tr.HitPos+tr.HitNormal*16
		util.PrecacheModel("models/props_combine/combine_mine01.mdl")
		util.PrecacheModel("models/roller.mdl")
		util.PrecacheModel("models/combine_soldier.mdl")
		util.PrecacheModel("models/combine_super_soldier.mdl")
		util.PrecacheModel("models/combine_soldier_prisonguard.mdl")
		util.PrecacheModel("models/hunter.mdl")
		util.PrecacheModel("models/manhack.mdl")
		util.PrecacheModel("models/police.mdl")
		util.PrecacheModel("models/combine_turrets/floor_turret.mdl")
		util.PrecacheModel("models/combine_helicopter.mdl")
		util.PrecacheModel("models/combine_strider.mdl")
		util.PrecacheModel("models/gunship.mdl")
		util.PrecacheModel("models/combine_dropship.mdl")
		util.PrecacheModel("models/combine_dropship_container.mdl")
		//this is for easy editing of the various positions
		local gunshipflyradius=2250
		local gunshipflyheight=2500
		local gunshipspawnpos=Vector(0,0,800)
		local helicopteroneflyradius=1800
		local helicopteroneflyheight=1500
		local helicopteronesecondaryflyradius=700
		local helicopteronesecondaryflyheight=200
		local helicopteronespawnpos=Vector(0,0,600)
		local npc1
		local npc2
		local npc3
		local npc4
		local npc5
		local npc6
		local npc7
		local npc8
		local npc9
		local npc10
		local npc11
		local npc12
		local npc13
		local npc14
		local npc15
		local npc16
		local npc17
		local npc18
		local npc19
		local npc20
		local npc21
		local npc22
		local npc23
		local npc24
		local npc25
		local npc26
		local npc27
		local npc28
		local npc29
		local npc30
		local npc31
		local npc32
		local npc=ents.Create("npc_hunter")
		npc:SetPos(selfpos)
		npc:Spawn()
		npc:Activate()
		npc:StopMoving()
		npc:SetKeyValue("SquadName",SquadName)
		npc.JackyDamageGroup=SquadName
		JackyOpSquadSpawnEvent(npc)
		npc1=npc
		timer.Simple(0.05,function()
			local npc=ents.Create("npc_combine_s")
			npc:SetPos(selfpos+Vector(75,0,0))
			npc:SetKeyValue("additionalequipment","weapon_ar2")
			npc:SetModel("models/combine_super_soldier.mdl")
			npc:SetKeyValue("NumGrenades","3")
			npc:SetMaxHealth(60)
			npc:SetHealth(60)
			npc:Spawn()
			npc.JackyOpSquadDrop={"item_ammo_ar2","item_ammo_ar2_altfire"}
			npc:Activate()
			npc:SetKeyValue("SquadName",SquadName)
			npc.JackyDamageGroup=SquadName
			npc.OpSquadIonBaller=true
			JackyOpSquadSpawnEvent(npc)
			npc2=npc
		end)
		timer.Simple(0.1,function()
			local npc=ents.Create("npc_combine_s")
			npc:SetPos(selfpos+Vector(75,75,0))
			npc:SetAngles(Angle(0,45,0))
			npc:SetKeyValue("additionalequipment","weapon_ar2")
			npc:SetKeyValue("NumGrenades","3")
			npc:Spawn()
			npc.JackyOpSquadDrop={"item_ammo_ar2","weapon_frag"}
			npc:Activate()
			npc:SetKeyValue("SquadName",SquadName)
			npc.JackyDamageGroup=SquadName
			npc.OpSquadGrenadier=true
			JackyOpSquadSpawnEvent(npc)
			npc3=npc
			npc1:StopMoving()
		end)
		timer.Simple(0.15,function()
			local npc=ents.Create("npc_combine_s")
			npc:SetPos(selfpos+Vector(0,75,0))
			npc:SetAngles(Angle(0,90,0))
			npc:SetKeyValue("additionalequipment","weapon_shotgun")
			npc:SetModel("models/combine_soldier_prisonguard.mdl")
			npc:Spawn()
			npc.JackyOpSquadDrop={"item_box_buckshot"}
			npc:Activate()
			npc:SetKeyValue("SquadName",SquadName)
			npc.JackyDamageGroup=SquadName
			JackyOpSquadSpawnEvent(npc)
			npc4=npc
		end)
		timer.Simple(0.2,function()
			local npc=ents.Create("npc_combine_s")
			npc:SetPos(selfpos+Vector(-75,75,0))
			npc:SetAngles(Angle(0,135,0))
			npc:SetKeyValue("additionalequipment","weapon_ar2")
			npc:SetKeyValue("NumGrenades","3")
			npc:Spawn()
			npc.JackyOpSquadDrop={"item_ammo_ar2","weapon_frag"}
			npc:Activate()
			npc:SetKeyValue("SquadName",SquadName)
			npc.JackyDamageGroup=SquadName
			npc.OpSquadGrenadier=true
			JackyOpSquadSpawnEvent(npc)
			npc5=npc
		end)
		timer.Simple(0.25,function()
			local npc=ents.Create("npc_combine_s")
			npc:SetPos(selfpos+Vector(-75,0,0))
			npc:SetAngles(Angle(0,180,0))
			npc:SetKeyValue("additionalequipment","weapon_ar2")
			npc:SetModel("models/combine_super_soldier.mdl")
			npc:SetKeyValue("NumGrenades","3")
			npc:SetMaxHealth(60)
			npc:SetHealth(60)
			npc:Spawn()
			npc.JackyOpSquadDrop={"item_ammo_ar2","item_ammo_ar2_altfire"}
			npc:Activate()
			npc:SetKeyValue("SquadName",SquadName)
			npc.JackyDamageGroup=SquadName
			npc.OpSquadIonBaller=true
			JackyOpSquadSpawnEvent(npc)
			npc6=npc
			npc1:StopMoving()
		end)
		timer.Simple(0.3,function()
			local npc=ents.Create("npc_combine_s")
			npc:SetPos(selfpos+Vector(-75,-75,0))
			npc:SetAngles(Angle(0,225,0))
			npc:SetKeyValue("additionalequipment","weapon_ar2")
			npc:SetKeyValue("NumGrenades","3")
			npc:Spawn()
			npc.JackyOpSquadDrop={"item_ammo_ar2","weapon_frag"}
			npc.OpSquadGrenadier=true
			npc:Activate()
			npc:SetKeyValue("SquadName",SquadName)
			npc.JackyDamageGroup=SquadName
			JackyOpSquadSpawnEvent(npc)
			npc7=npc
		end)
		timer.Simple(0.35,function()
			local npc=ents.Create("npc_combine_s")
			npc:SetPos(selfpos+Vector(0,-75,0))
			npc:SetAngles(Angle(0,270,0))
			npc:SetKeyValue("additionalequipment","weapon_shotgun")
			npc:SetModel("models/combine_soldier_prisonguard.mdl")
			npc:Spawn()
			npc.JackyOpSquadDrop={"item_box_buckshot"}
			npc:Activate()
			npc:SetKeyValue("SquadName",SquadName)
			npc.JackyDamageGroup=SquadName
			JackyOpSquadSpawnEvent(npc)
			npc8=npc
		end)
		timer.Simple(0.4,function()
			local npc=ents.Create("npc_combine_s")
			npc:SetPos(selfpos+Vector(75,-75,0))
			npc:SetAngles(Angle(0,315,0))
			npc:SetKeyValue("additionalequipment","weapon_ar2")
			npc:SetKeyValue("NumGrenades","3")
			npc:Spawn()
			npc.JackyOpSquadDrop={"item_ammo_ar2","weapon_frag"}
			npc.OpSquadGrenadier=true
			npc:Activate()
			npc:SetKeyValue("SquadName",SquadName)
			npc.JackyDamageGroup=SquadName
			JackyOpSquadSpawnEvent(npc)
			npc9=npc
		end)
		timer.Simple(0.45,function()
			local npc=ents.Create("npc_metropolice")
			npc:SetPos(selfpos+Vector(150,0,0))
			npc:SetKeyValue("additionalequipment","weapon_pistol")
			npc:SetKeyValue("manhacks","10")
			npc:Spawn()
			npc:Fire("EnableManhackToss","1",0)
			npc:Activate()
			npc:SetKeyValue("SquadName",SquadName)
			npc.JackyDamageGroup=SquadName
			JackyOpSquadSpawnEvent(npc)
			npc10=npc
		end)
		timer.Simple(0.5,function()
			local npc=ents.Create("npc_turret_floor")
			npc:SetPos(selfpos+Vector(150,150,-15))
			npc:SetAngles(Angle(0,45,0))
			npc:Spawn()
			npc:Activate()
			Anchor(npc)
			npc:SetKeyValue("SquadName",SquadName)
			npc.JackyDamageGroup=SquadName
			JackyOpSquadSpawnEvent(npc)
			npc11=npc
		end)
		timer.Simple(0.55,function()
			local npc=ents.Create("npc_metropolice")
			npc:SetPos(selfpos+Vector(0,150,0))
			npc:SetAngles(Angle(0,90,0))
			npc:SetKeyValue("additionalequipment","weapon_stunstick")
			npc:SetKeyValue("manhacks","10")
			npc:Spawn()
			npc:Fire("EnableManhackToss","1",0)
			npc:Activate()
			npc:SetKeyValue("SquadName",SquadName)
			npc.JackyDamageGroup=SquadName
			JackyOpSquadSpawnEvent(npc)
			npc12=npc
		end)
		timer.Simple(0.6,function()
			local npc=ents.Create("npc_turret_floor")
			npc:SetPos(selfpos+Vector(-150,150,-15))
			npc:SetAngles(Angle(0,135,0))
			npc:Spawn()
			npc:Activate()
			Anchor(npc)
			npc:SetKeyValue("SquadName",SquadName)
			npc.JackyDamageGroup=SquadName
			JackyOpSquadSpawnEvent(npc)
			npc13=npc
		end)
		timer.Simple(0.65,function()
			local npc=ents.Create("npc_metropolice")
			npc:SetPos(selfpos+Vector(-150,0,0))
			npc:SetAngles(Angle(0,180,0))
			npc:SetKeyValue("additionalequipment","weapon_pistol")
			npc:SetKeyValue("manhacks","10")
			npc:Spawn()
			npc:Fire("EnableManhackToss","1",0)
			npc:Activate()
			npc:SetKeyValue("SquadName",SquadName)
			npc.JackyDamageGroup=SquadName
			JackyOpSquadSpawnEvent(npc)
			npc14=npc
		end)
		timer.Simple(0.7,function()
			local npc=ents.Create("npc_turret_floor")
			npc:SetPos(selfpos+Vector(-150,-150,-15))
			npc:SetAngles(Angle(0,225,0))
			npc:Spawn()
			npc:Activate()
			Anchor(npc)
			npc:SetKeyValue("SquadName",SquadName)
			npc.JackyDamageGroup=SquadName
			JackyOpSquadSpawnEvent(npc)
			npc15=npc
		end)
		timer.Simple(0.75,function()
			local npc=ents.Create("npc_metropolice")
			npc:SetPos(selfpos+Vector(0,-150,0))
			npc:SetAngles(Angle(0,270,0))
			npc:SetKeyValue("additionalequipment","weapon_stunstick")
			npc:SetKeyValue("manhacks","10")
			npc:Spawn()
			npc:Fire("EnableManhackToss","1",0)
			npc:Activate()
			npc:SetKeyValue("SquadName",SquadName)
			npc.JackyDamageGroup=SquadName
			JackyOpSquadSpawnEvent(npc)
			npc16=npc
		end)
		timer.Simple(0.8,function()
			local npc=ents.Create("npc_turret_floor")
			npc:SetPos(selfpos+Vector(150,-150,-15))
			npc:SetAngles(Angle(0,315,0))
			npc:Spawn()
			npc:Activate()
			Anchor(npc)
			npc.JackyOpSquadNoCollide=true
			npc:SetKeyValue("SquadName",SquadName)
			npc.JackyDamageGroup=SquadName
			JackyOpSquadSpawnEvent(npc)
			npc17=npc
		end)
		timer.Simple(0.85,function()
			local npc=ents.Create("npc_manhack")
			npc:SetPos(selfpos+Vector(0,20,100))
			npc:SetAngles(Angle(0,90,0))
			npc:SetKeyValue("spawnflags","65536")
			npc:Spawn()
			npc:Activate()
			npc:SetKeyValue("SquadName",SquadName)
			npc.JackyDamageGroup=SquadName
			npc:Fire("unpack","",0)
			JackyOpSquadSpawnEvent(npc)
			npc23=npc
		end)
		timer.Simple(0.9,function()
			local npc=ents.Create("npc_rollermine")
			npc:SetPos(selfpos+Vector(225,225,0))
			npc:SetKeyValue("uniformsightdist","1")
			npc:SetKeyValue("startburied","1")
			npc:Spawn()
			npc:Activate()
			npc:SetKeyValue("SquadName",SquadName)
			npc.JackyDamageGroup=SquadName
			JackyOpSquadSpawnEvent(npc)
			npc18=npc
		end)
		timer.Simple(0.95,function()
			local npc=ents.Create("npc_manhack")
			npc:SetPos(selfpos+Vector(0,-20,100))
			npc:SetAngles(Angle(0,270,0))
			npc:SetKeyValue("spawnflags","65536")
			npc:Spawn()
			npc:Activate()
			npc:SetKeyValue("SquadName",SquadName)
			npc.JackyDamageGroup=SquadName
			npc:Fire("unpack","",0)
			JackyOpSquadSpawnEvent(npc)
			npc24=npc
		end)
		timer.Simple(1,function()
			local npc=ents.Create("npc_rollermine")
			npc:SetPos(selfpos+Vector(-225,225,0))
			npc:SetKeyValue("uniformsightdist","1")
			npc:SetKeyValue("startburied","1")
			npc:Spawn()
			npc:Activate()
			npc:SetKeyValue("SquadName",SquadName)
			npc.JackyDamageGroup=SquadName
			JackyOpSquadSpawnEvent(npc)
			npc19=npc
			npc1:StopMoving()
		end)
		timer.Simple(1.05,function()
			local npc=ents.Create("npc_manhack")
			npc:SetPos(selfpos+Vector(20,0,100))
			npc:SetKeyValue("spawnflags","65536")
			npc:Spawn()
			npc:Activate()
			npc:SetKeyValue("SquadName",SquadName)
			npc.JackyDamageGroup=SquadName
			npc:Fire("unpack","",0)
			JackyOpSquadSpawnEvent(npc)
			npc25=npc
		end)
		timer.Simple(1.1,function()
			local npc=ents.Create("npc_rollermine")
			npc:SetPos(selfpos+Vector(-225,-225,0))
			npc:SetKeyValue("uniformsightdist","1")
			npc:SetKeyValue("startburied","1")
			npc:Spawn()
			npc:Activate()
			npc:SetKeyValue("SquadName",SquadName)
			npc.JackyDamageGroup=SquadName
			JackyOpSquadSpawnEvent(npc)
			npc20=npc
		end)
		timer.Simple(1.15,function()
			local npc=ents.Create("npc_manhack")
			npc:SetPos(selfpos+Vector(-20,0,100))
			npc:SetAngles(Angle(0,180,0))
			npc:SetKeyValue("spawnflags","65536")
			npc:Spawn()
			npc:Activate()
			npc:SetKeyValue("SquadName",SquadName)
			npc.JackyDamageGroup=SquadName
			npc:Fire("unpack","",0)
			JackyOpSquadSpawnEvent(npc)
			npc26=npc
		end)
		timer.Simple(1.2,function()
			local npc=ents.Create("npc_rollermine")
			npc:SetPos(selfpos+Vector(225,-225,0))
			npc:SetKeyValue("uniformsightdist","1")
			npc:SetKeyValue("startburied","1")
			npc:Spawn()
			npc:Activate()
			npc:SetKeyValue("SquadName",SquadName)
			npc.JackyDamageGroup=SquadName
			JackyOpSquadSpawnEvent(npc)
			npc21=npc
		end)
		timer.Simple(1.25,function()
			local npc=ents.Create("npc_cscanner")
			npc:SetPos(selfpos+Vector(0,-150,75))
			npc:SetAngles(Angle(0,270,0))
			npc:Spawn()
			npc.JackyOpSquadDrop={"item_battery"}
			npc:Activate()
			npc:SetKeyValue("SquadName",SquadName)
			npc.JackyDamageGroup=SquadName
			JackyOpSquadSpawnEvent(npc)
			npc27=npc
		end)
		timer.Simple(1.3,function()
			local npc=ents.Create("npc_clawscanner")
			npc:SetPos(selfpos+Vector(-150,0,75))
			npc:SetAngles(Angle(0,180,0))
			npc:Spawn()
			npc.JackyOpSquadDrop={"item_battery"}
			npc.OpSquadMineDropper=true
			npc:Activate()
			npc:SetKeyValue("SquadName",SquadName)
			npc.JackyDamageGroup=SquadName
			JackyOpSquadSpawnEvent(npc)
			npc28=npc
		end)
		timer.Simple(1.35,function()
			local npc=ents.Create("npc_cscanner")
			npc:SetPos(selfpos+Vector(0,150,75))
			npc:SetAngles(Angle(0,90,0))
			npc:Spawn()
			npc.JackyOpSquadDrop={"item_battery"}
			npc:Activate()
			npc:SetKeyValue("SquadName",SquadName)
			npc.JackyDamageGroup=SquadName
			JackyOpSquadSpawnEvent(npc)
			npc29=npc
		end)
		timer.Simple(1.4,function()
			local npc=ents.Create("npc_clawscanner")
			npc:SetPos(selfpos+Vector(150,0,75))
			npc:Spawn()
			npc.JackyOpSquadDrop={"item_battery"}
			npc.OpSquadMineDropper=true
			npc:Activate()
			npc:SetKeyValue("SquadName",SquadName)
			npc.JackyDamageGroup=SquadName
			JackyOpSquadSpawnEvent(npc)
			npc22=npc
		end)
		timer.Simple(1.45,function()
			local npc=ents.Create("npc_strider")
			npc:SetPos(selfpos)
			npc:SetAngles(Angle(0,-90,0))
			npc:SetKeyValue("spawnflags","65536")
			npc:Spawn()
			npc:Activate()
			npc:SetMaxHealth(60)
			npc:SetHealth(60)
			npc:SetKeyValue("SquadName",SquadName)
			npc.JackyDamageGroup=SquadName
			npc.OpSquadWanderer=true
			npc.OpSquadWarspaceCannoneer=true
			npc.OpSquadRandomCroucher=true
			npc:Fire("enablecrouchwalk","",0)
			local name="HasAHunterProtecting"..npc:EntIndex()
			npc:SetName(name)
			npc1:Fire("followstrider",name,0)
			JackyOpSquadSpawnEvent(npc)
			npc30=npc
		end)
		timer.Simple(1.5,function()
			local MyNodeBuffer={}
			local Nodes=4
			local ent=ents.Create("path_track")
			ent:SetPos(selfpos+Vector(-gunshipflyradius,gunshipflyradius,gunshipflyheight))
			ent:Spawn()
			if(ent:IsInWorld())then table.insert(MyNodeBuffer,ent) end
			if not(ent:IsInWorld())then ent:Remove(); Nodes=Nodes-1  end
			local ent=ents.Create("path_track")
			ent:SetPos(selfpos+Vector(-gunshipflyradius,-gunshipflyradius,gunshipflyheight))
			ent:Spawn()
			if(ent:IsInWorld())then table.insert(MyNodeBuffer,ent) end
			if not(ent:IsInWorld())then ent:Remove(); Nodes=Nodes-1  end
			local ent=ents.Create("path_track")
			ent:SetPos(selfpos+Vector(gunshipflyradius,-gunshipflyradius,gunshipflyheight))
			ent:Spawn()
			if(ent:IsInWorld())then table.insert(MyNodeBuffer,ent) end
			if not(ent:IsInWorld())then ent:Remove(); Nodes=Nodes-1  end
			local ent=ents.Create("path_track")
			ent:SetPos(selfpos+Vector(gunshipflyradius,gunshipflyradius,gunshipflyheight))
			ent:Spawn()
			if(ent:IsInWorld())then table.insert(MyNodeBuffer,ent) end
			if not(ent:IsInWorld())then ent:Remove(); Nodes=Nodes-1  end
			local npc=ents.Create("npc_combinegunship")
			npc:SetPos(selfpos+gunshipspawnpos)
			npc:SetAngles(Angle(0,90,0))
			npc:Spawn()
			npc:SetMaxHealth(150)
			npc:SetHealth(150)
			npc:Activate()
			npc:SetKeyValue("SquadName",SquadName)
			npc.JackyDamageGroup=SquadName
			npc:Fire("blindfireon","",0)
			npc:Fire("enablegroundattack","",0)
			npc.OpSquadWarspaceCannoneer=true																			--	
			JackyOpSquadSpawnEvent(npc)
			npc31=npc
			for var=1,Nodes,1 do
				MyNodeBuffer[var]:SetName(tostring(npc)..tostring(var))
				npc:DeleteOnRemove(MyNodeBuffer[var])
			end
			for var=1,Nodes,1 do
				if(var!=Nodes)then
					MyNodeBuffer[var]:Fire("addoutput","OnPass !activator,SetTrack,".. tostring(npc)..tostring((var+1)),1)
				else
					MyNodeBuffer[var]:Fire("addoutput","OnPass !activator,SetTrack,".. tostring(npc).."1",1)
				end
			end
			local TrackName=tostring(npc).."1"
			npc:Fire("SetTrack",TrackName,0.1)
		end)
		timer.Simple(1.55,function()
			local MyNodeBuffer={}
			local Nodes=6
			local ent=ents.Create("path_track")
			ent:SetPos(selfpos+Vector(-helicopteroneflyradius,helicopteroneflyradius,helicopteroneflyheight))
			ent:Spawn()
			if(ent:IsInWorld())then table.insert(MyNodeBuffer,ent) end
			if not(ent:IsInWorld())then ent:Remove(); Nodes=Nodes-1  end
			local ent=ents.Create("path_track")
			ent:SetPos(selfpos+Vector(-helicopteronesecondaryflyradius,0,helicopteronesecondaryflyheight))
			ent:Spawn()
			if(ent:IsInWorld())then table.insert(MyNodeBuffer,ent) end
			if not(ent:IsInWorld())then ent:Remove(); Nodes=Nodes-1  end
			local ent=ents.Create("path_track")
			ent:SetPos(selfpos+Vector(-helicopteroneflyradius,-helicopteroneflyradius,helicopteroneflyheight))
			ent:Spawn()
			if(ent:IsInWorld())then table.insert(MyNodeBuffer,ent) end
			if not(ent:IsInWorld())then ent:Remove(); Nodes=Nodes-1  end
			local ent=ents.Create("path_track")
			ent:SetPos(selfpos+Vector(helicopteroneflyradius,-helicopteroneflyradius,helicopteroneflyheight))
			ent:Spawn()
			if(ent:IsInWorld())then table.insert(MyNodeBuffer,ent) end
			if not(ent:IsInWorld())then ent:Remove(); Nodes=Nodes-1  end
			local ent=ents.Create("path_track")
			ent:SetPos(selfpos+Vector(helicopteronesecondaryflyradius,0,helicopteronesecondaryflyheight))
			ent:Spawn()
			if(ent:IsInWorld())then table.insert(MyNodeBuffer,ent) end
			if not(ent:IsInWorld())then ent:Remove(); Nodes=Nodes-1  end
			local ent=ents.Create("path_track")
			ent:SetPos(selfpos+Vector(helicopteroneflyradius,helicopteroneflyradius,helicopteroneflyheight))
			ent:Spawn()
			if(ent:IsInWorld())then table.insert(MyNodeBuffer,ent) end
			if not(ent:IsInWorld())then ent:Remove(); Nodes=Nodes-1  end
			local npc=ents.Create("npc_helicopter")
			npc:SetPos(selfpos+helicopteronespawnpos)
			npc:SetKeyValue("spawnflags","1376512") --256+65536+262144+1048576
			npc:Spawn()
			npc:SetMaxHealth(500)
			npc:SetHealth(500)
			npc:Activate()
			npc:SetKeyValue("SquadName",SquadName)
			npc.JackyDamageGroup=SquadName
			npc.OpSquadInconsistentHeliGunner=true
			npc:Fire("missileon","",0)
			npc:Fire("gunon","",0)
			npc.OpSquadBombDropper=true
			npc.OpSquadRotorDamage=true
			JackyOpSquadSpawnEvent(npc)
			npc32=npc
			for var=1, Nodes,1  do
				MyNodeBuffer[var]:SetName(tostring(npc) .. tostring(var))
				npc:DeleteOnRemove(MyNodeBuffer[var])
			end
			for var=1, Nodes,1  do
				if(var != Nodes)then
					MyNodeBuffer[var]:Fire("addoutput","OnPass !activator,SetTrack," ..  tostring(npc) .. tostring((var+1)),1)
				else
					MyNodeBuffer[var]:Fire("addoutput","OnPass !activator,SetTrack," ..  tostring(npc) .. "1",1)
				end
			end
			local TrackName=tostring(npc) .. "1"
			npc:Fire("SetTrack",TrackName,0.1)
		end)
		timer.Simple(1.6,function()							--FUCK this was alot of work
			undo.Create("Combine Opposition Squad")
			undo.SetPlayer(ply)
			if(IsValid(npc1))then undo.AddEntity(npc1) end
			if(IsValid(npc2))then undo.AddEntity(npc2) end
			if(IsValid(npc3))then undo.AddEntity(npc3) end
			if(IsValid(npc4))then undo.AddEntity(npc4) end
			if(IsValid(npc5))then undo.AddEntity(npc5) end
			if(IsValid(npc6))then undo.AddEntity(npc6) end
			if(IsValid(npc7))then undo.AddEntity(npc7) end
			if(IsValid(npc8))then undo.AddEntity(npc8) end
			if(IsValid(npc9))then undo.AddEntity(npc9) end
			if(IsValid(npc10))then undo.AddEntity(npc10) end
			if(IsValid(npc11))then undo.AddEntity(npc11) end
			if(IsValid(npc12))then undo.AddEntity(npc12) end
			if(IsValid(npc13))then undo.AddEntity(npc13) end
			if(IsValid(npc14))then undo.AddEntity(npc14) end
			if(IsValid(npc15))then undo.AddEntity(npc15) end
			if(IsValid(npc16))then undo.AddEntity(npc16) end
			if(IsValid(npc17))then undo.AddEntity(npc17) end
			if(IsValid(npc18))then undo.AddEntity(npc18) end
			if(IsValid(npc19))then undo.AddEntity(npc19) end
			if(IsValid(npc20))then undo.AddEntity(npc20) end
			if(IsValid(npc21))then undo.AddEntity(npc21) end
			if(IsValid(npc22))then undo.AddEntity(npc22) end
			if(IsValid(npc23))then undo.AddEntity(npc23) end
			if(IsValid(npc24))then undo.AddEntity(npc24) end
			if(IsValid(npc25))then undo.AddEntity(npc25) end
			if(IsValid(npc26))then undo.AddEntity(npc26) end
			if(IsValid(npc27))then undo.AddEntity(npc27) end
			if(IsValid(npc28))then undo.AddEntity(npc28) end
			if(IsValid(npc29))then undo.AddEntity(npc29) end
			if(IsValid(npc30))then undo.AddEntity(npc30) end
			if(IsValid(npc31))then undo.AddEntity(npc31) end
			if(IsValid(npc32))then undo.AddEntity(npc32) end
			undo.SetCustomUndoText("Undone Combine Opposition Squad")
			undo.Finish()
		end)
	end
	JackieNPCSpawningTable.Enhanced["MetroCop"]=function(selfpos)
		local npc=ents.Create("npc_metropolice")
		npc:SetPos(selfpos)
		npc:SetKeyValue("additionalequipment","weapon_pistol")
		npc:SetKeyValue("manhacks","100")
		npc:Spawn()
		npc:Fire("EnableManhackToss","1",0)
		npc:Activate()
		npc:SetKeyValue("SquadName",SquadName)
		npc.JackyDamageGroup=SquadName
		JackyOpSquadSpawnEvent(npc)
		return npc
	end
	JackieNPCSpawningTable.Enhanced["Strider"]=function(selfpos)
		local npc=ents.Create("npc_strider")
		npc:SetPos(selfpos)
		npc:SetAngles(Angle(0,0,0))
		npc:SetKeyValue("spawnflags","65536")
		npc:Spawn()
		npc:Activate()
		npc:SetMaxHealth(60)
		npc:SetHealth(60)
		npc:SetKeyValue("SquadName",SquadName)
		npc.JackyDamageGroup=SquadName
		npc.OpSquadWanderer=true
		npc.OpSquadWarspaceCannoneer=true
		npc.OpSquadRandomCroucher=true
		npc:Fire("enablecrouchwalk","",0)
		JackyOpSquadSpawnEvent(npc)
		return npc
	end
	JackieNPCSpawningTable.Enhanced["Synth Scanner"]=function(selfpos)
		local npc=ents.Create("npc_clawscanner")
		npc:SetPos(selfpos)
		npc:SetAngles(Angle(0,0,0))
		npc:Spawn()
		npc.JackyOpSquadDrop={"item_battery"}
		npc.OpSquadMineDropper=true
		npc:Activate()
		npc:SetKeyValue("SquadName",SquadName)
		npc.JackyDamageGroup=SquadName
		JackyOpSquadSpawnEvent(npc)
		return npc
	end
	JackieNPCSpawningTable.Enhanced["HunterCopter"]=function(selfpos)
		local helicopteroneflyradius=1800
		local helicopteroneflyheight=1500
		local helicopteronesecondaryflyradius=700
		local helicopteronesecondaryflyheight=200
		local helicopteronespawnpos=Vector(0,0,600)
		local MyNodeBuffer={}
		local Nodes=6
		local ent=ents.Create("path_track")
		ent:SetPos(selfpos+Vector(-helicopteroneflyradius,helicopteroneflyradius,helicopteroneflyheight))
		ent:Spawn()
		if(ent:IsInWorld())then table.insert(MyNodeBuffer,ent) end
		if not(ent:IsInWorld())then ent:Remove(); Nodes=Nodes-1  end
		local ent=ents.Create("path_track")
		ent:SetPos(selfpos+Vector(-helicopteronesecondaryflyradius,0,helicopteronesecondaryflyheight))
		ent:Spawn()
		if(ent:IsInWorld())then table.insert(MyNodeBuffer,ent) end
		if not(ent:IsInWorld())then ent:Remove(); Nodes=Nodes-1  end
		local ent=ents.Create("path_track")
		ent:SetPos(selfpos+Vector(-helicopteroneflyradius,-helicopteroneflyradius,helicopteroneflyheight))
		ent:Spawn()
		if(ent:IsInWorld())then table.insert(MyNodeBuffer,ent) end
		if not(ent:IsInWorld())then ent:Remove(); Nodes=Nodes-1  end
		local ent=ents.Create("path_track")
		ent:SetPos(selfpos+Vector(helicopteroneflyradius,-helicopteroneflyradius,helicopteroneflyheight))
		ent:Spawn()
		if(ent:IsInWorld())then table.insert(MyNodeBuffer,ent) end
		if not(ent:IsInWorld())then ent:Remove(); Nodes=Nodes-1  end
		local ent=ents.Create("path_track")
		ent:SetPos(selfpos+Vector(helicopteronesecondaryflyradius,0,helicopteronesecondaryflyheight))
		ent:Spawn()
		if(ent:IsInWorld())then table.insert(MyNodeBuffer,ent) end
		if not(ent:IsInWorld())then ent:Remove(); Nodes=Nodes-1  end
		local ent=ents.Create("path_track")
		ent:SetPos(selfpos+Vector(helicopteroneflyradius,helicopteroneflyradius,helicopteroneflyheight))
		ent:Spawn()
		if(ent:IsInWorld())then table.insert(MyNodeBuffer,ent) end
		if not(ent:IsInWorld())then ent:Remove(); Nodes=Nodes-1  end
		local npc=ents.Create("npc_helicopter")
		npc:SetPos(selfpos+Vector(0,0,250))
		npc:SetKeyValue("spawnflags","1376512") --256+65536+262144+1048576
		npc:Spawn()
		npc:SetMaxHealth(500)
		npc:SetHealth(500)
		npc:Activate()
		npc:SetKeyValue("SquadName",SquadName)
		npc.JackyDamageGroup=SquadName
		npc.OpSquadInconsistentHeliGunner=true
		npc:Fire("missileon","",0)
		npc:Fire("gunon","",0)
		npc.OpSquadBombDropper=true
		npc.OpSquadRotorDamage=true
		JackyOpSquadSpawnEvent(npc)
		npc32=npc
		for var=1, Nodes,1  do
			MyNodeBuffer[var]:SetName(tostring(npc) .. tostring(var))
			npc:DeleteOnRemove(MyNodeBuffer[var])
		end
		for var=1, Nodes,1  do
			if(var != Nodes)then
				MyNodeBuffer[var]:Fire("addoutput","OnPass !activator,SetTrack," ..  tostring(npc) .. tostring((var+1)),1)
			else
				MyNodeBuffer[var]:Fire("addoutput","OnPass !activator,SetTrack," ..  tostring(npc) .. "1",1)
			end
		end
		local TrackName=tostring(npc) .. "1"
		npc:Fire("SetTrack",TrackName,0.1)
		return npc
	end
	JackieNPCSpawningTable.Enhanced["Gunship"]=function(selfpos)
		local gunshipflyradius=2250
		local gunshipflyheight=2500
		local gunshipspawnpos=Vector(0,0,800)
		local MyNodeBuffer={}
		local Nodes=4
		local ent=ents.Create("path_track")
		ent:SetPos(selfpos+Vector(-gunshipflyradius,gunshipflyradius,gunshipflyheight))
		ent:Spawn()
		if(ent:IsInWorld())then table.insert(MyNodeBuffer,ent) end
		if not(ent:IsInWorld())then ent:Remove(); Nodes=Nodes-1  end
		local ent=ents.Create("path_track")
		ent:SetPos(selfpos+Vector(-gunshipflyradius,-gunshipflyradius,gunshipflyheight))
		ent:Spawn()
		if(ent:IsInWorld())then table.insert(MyNodeBuffer,ent) end
		if not(ent:IsInWorld())then ent:Remove(); Nodes=Nodes-1  end
		local ent=ents.Create("path_track")
		ent:SetPos(selfpos+Vector(gunshipflyradius,-gunshipflyradius,gunshipflyheight))
		ent:Spawn()
		if(ent:IsInWorld())then table.insert(MyNodeBuffer,ent) end
		if not(ent:IsInWorld())then ent:Remove(); Nodes=Nodes-1  end
		local ent=ents.Create("path_track")
		ent:SetPos(selfpos+Vector(gunshipflyradius,gunshipflyradius,gunshipflyheight))
		ent:Spawn()
		if(ent:IsInWorld())then table.insert(MyNodeBuffer,ent) end
		if not(ent:IsInWorld())then ent:Remove(); Nodes=Nodes-1  end
		local npc=ents.Create("npc_combinegunship")
		npc:SetPos(selfpos+Vector(0,0,500))
		npc:SetAngles(Angle(0,90,0))
		npc:Spawn()
		npc:SetMaxHealth(150)
		npc:SetHealth(150)
		npc:Activate()
		npc:SetKeyValue("SquadName",SquadName)
		npc.JackyDamageGroup=SquadName
		npc:Fire("blindfireon","",0)
		npc:Fire("enablegroundattack","",0)
		npc.OpSquadWarspaceCannoneer=true																			--	
		JackyOpSquadSpawnEvent(npc)
		npc31=npc
		for var=1,Nodes,1 do
			MyNodeBuffer[var]:SetName(tostring(npc)..tostring(var))
			npc:DeleteOnRemove(MyNodeBuffer[var])
		end
		for var=1,Nodes,1 do
			if(var!=Nodes)then
				MyNodeBuffer[var]:Fire("addoutput","OnPass !activator,SetTrack,".. tostring(npc)..tostring((var+1)),1)
			else
				MyNodeBuffer[var]:Fire("addoutput","OnPass !activator,SetTrack,".. tostring(npc).."1",1)
			end
		end
		local TrackName=tostring(npc).."1"
		npc:Fire("SetTrack",TrackName,0.1)
		return npc
	end
end