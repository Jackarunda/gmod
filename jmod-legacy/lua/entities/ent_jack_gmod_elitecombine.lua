AddCSLuaFile()
ENT.Type 			= "anim"
ENT.PrintName		= "Elite Combine"
ENT.Author			= "Jackarunda"
ENT.Information		= ""
ENT.Category		= "JMod - LEGACY NPCs"

ENT.Spawnable		= true
ENT.AdminSpawnable	= true
if(SERVER)then
	local SquadName="JackyCombineOpSquad"
	local function EliteOverWatchPhysique(npc)
		npc:ManipulateBoneScale(npc:LookupBone("ValveBiped.Bip01_Spine4"),Vector(1.3,1.2,1.2))
		npc:ManipulateBoneScale(npc:LookupBone("ValveBiped.Bip01_Spine2"),Vector(1,1.1,1.1))
		npc:ManipulateBoneScale(npc:LookupBone("ValveBiped.Bip01_Spine1"),Vector(1,.85,.85))
		npc:ManipulateBoneScale(npc:LookupBone("ValveBiped.Bip01_Spine"),Vector(1,.85,.85))
		npc:ManipulateBoneScale(npc:LookupBone("ValveBiped.Bip01_L_UpperArm"),Vector(1,1.1,1.1))
		npc:ManipulateBoneScale(npc:LookupBone("ValveBiped.Bip01_R_UpperArm"),Vector(1,1.1,1.1))
		npc:ManipulateBoneScale(npc:LookupBone("ValveBiped.Bip01_L_Thigh"),Vector(1,1.1,1.1))
		npc:ManipulateBoneScale(npc:LookupBone("ValveBiped.Bip01_R_Thigh"),Vector(1,1.1,1.1))
	end
	function ENT:SpawnFunction(ply,tr)
		local selfpos=tr.HitPos+tr.HitNormal*16
		local npc1
		local npc2
		local npc3
		local npc4
		local npc=ents.Create("npc_combine_s")
		npc:SetPos(selfpos+Vector(20,-20,0))
		npc:SetAngles(Angle(0,-45,0))
		npc:SetKeyValue("additionalequipment","weapon_smg1")
		npc:SetKeyValue("model","models/combine_soldier.mdl")
		npc:SetKeyValue("spawnflags","256")
		npc:SetKeyValue("tacticalvariant","2")
		npc:SetMaxHealth(40)
		npc:SetHealth(40)
		npc:CapabilitiesAdd(CAP_MOVE_SHOOT)
		npc:CapabilitiesAdd(CAP_NO_HIT_SQUADMATES)
		npc:Spawn()
		npc:SetMaterial("models/combine/soldier")
		npc.JackyOpSquadDrop={"item_ammo_smg1_large","weapon_frag","item_ammo_smg1_grenade"}
		npc.JackyFirePowerMult=1.25
		npc.JackyProtectionMult=2
		npc.OpSquadFullBodySuit=true
		npc.OpSquadFlameRetardantSuit=true
		npc:SetBloodColor(-1)
		npc.OpSquadGoodHelmet=true
		npc:Activate()
		EliteOverWatchPhysique(npc)
		npc:SetKeyValue("SquadName",SquadName)
		npc.JackyDamageGroup=SquadName
		npc:SetCurrentWeaponProficiency(WEAPON_PROFICIENCY_PERFECT)
		npc:Fire("startpatrolling","",10)
		npc.NextHealTime=CurTime()
		npc.OpSquadHardHitter=true
		npc.OpSquadAmazingHunter=true
		npc.OpSquadGrenadier=true
		npc.OpSquadAware=true
		npc.OpSquadAutoHealer=true
		npc.OpSquadAggressive=true
		npc.OpSquadCareful=true
		npc.OpSquadStickTogether=true
		JackyOpSquadSpawnEvent(npc)
		npc1=npc
		timer.Simple(0.1,function()
			local npc=ents.Create("npc_combine_s")
			npc:SetPos(selfpos+Vector(-20,-20,0))
			npc:SetAngles(Angle(0,-135,0))
			npc:SetKeyValue("additionalequipment","weapon_ar2")
			npc:SetKeyValue("model","models/combine_super_soldier.mdl")
			npc:SetKeyValue("spawnflags","256")
			npc:SetKeyValue("tacticalvariant","2")
			npc:SetMaxHealth(40)
			npc:SetHealth(40)
			npc:CapabilitiesAdd(CAP_MOVE_SHOOT)
			npc:CapabilitiesAdd(CAP_NO_HIT_SQUADMATES)
			npc:Spawn()
			npc:SetMaterial("models/combine/cyclops")
			npc.JackyOpSquadDrop={"item_ammo_ar2_large","item_ammo_ar2_altfire"}
			npc.JackyFirePowerMult=1.25
			npc.JackyProtectionMult=2
			npc.OpSquadFullBodySuit=true
			npc.OpSquadFlameRetardantSuit=true
			npc:SetBloodColor(-1)
			npc.OpSquadGoodHelmet=true
			npc.OpSquadHardHitter=true
			npc:Activate()
			EliteOverWatchPhysique(npc)
			npc:SetKeyValue("SquadName",SquadName)
			npc.JackyDamageGroup=SquadName
			npc:SetCurrentWeaponProficiency(WEAPON_PROFICIENCY_PERFECT)
			npc:Fire("startpatrolling","",10)
			npc.NextHealTime=CurTime()
			npc.OpSquadAmazingHunter=true
			npc.OpSquadIonBaller=true
			npc.OpSquadAware=true
			npc.OpSquadAutoHealer=true
			npc.OpSquadAggressive=true
			npc.OpSquadCareful=true
			npc.OpSquadStickTogether=true
			JackyOpSquadSpawnEvent(npc)
			npc2=npc
		end)
		timer.Simple(0.2,function()
			local npc=ents.Create("npc_combine_s")
			npc:SetPos(selfpos+Vector(-20,20,0))
			npc:SetAngles(Angle(0,135,0))
			npc:SetKeyValue("additionalequipment","weapon_shotgun")
			npc:SetKeyValue("model","models/combine_soldier.mdl")
			npc:SetKeyValue("spawnflags","256")
			npc:SetKeyValue("tacticalvariant","2")
			npc:SetMaxHealth(40)
			npc:SetHealth(40)
			npc:CapabilitiesAdd(CAP_MOVE_SHOOT)
			npc:CapabilitiesAdd(CAP_NO_HIT_SQUADMATES)
			npc:Spawn()
			npc:SetMaterial("models/combine/soldier")
			npc.JackyOpSquadDrop={"item_box_buckshot","weapon_frag"}
			npc.JackyFirePowerMult=1.25
			npc.JackyProtectionMult=2
			npc.OpSquadFullBodySuit=true
			npc.OpSquadFlameRetardantSuit=true
			npc.OpSquadHardHitter=true
			npc:SetBloodColor(-1)
			npc.OpSquadGoodHelmet=true
			npc:Activate()
			EliteOverWatchPhysique(npc)
			npc:SetKeyValue("SquadName",SquadName)
			npc.JackyDamageGroup=SquadName
			npc:SetCurrentWeaponProficiency(WEAPON_PROFICIENCY_PERFECT)
			npc:Fire("startpatrolling","",10)
			npc.NextHealTime=CurTime()
			npc.OpSquadAmazingHunter=true
			npc.OpSquadGrenadier=true
			npc.OpSquadAware=true
			npc.OpSquadAutoHealer=true
			npc.OpSquadAggressive=true
			npc.OpSquadCareful=true
			npc.OpSquadStickTogether=true
			JackyOpSquadSpawnEvent(npc)
			npc3=npc
		end)
		timer.Simple(0.3,function()
			local npc=ents.Create("npc_combine_s")
			npc:SetPos(selfpos+Vector(20,20,0))
			npc:SetAngles(Angle(0,45,0))
			npc:SetKeyValue("additionalequipment","weapon_ar2")
			npc:SetKeyValue("model","models/combine_super_soldier.mdl")
			npc:SetKeyValue("spawnflags","256")
			npc:SetKeyValue("tacticalvariant","2")
			npc:SetMaxHealth(40)
			npc:SetHealth(40)
			npc:CapabilitiesAdd(CAP_MOVE_SHOOT)
			npc:CapabilitiesAdd(CAP_NO_HIT_SQUADMATES)
			npc:Spawn()
			npc:SetMaterial("models/combine/cyclops")
			npc.JackyOpSquadDrop={"item_ammo_ar2_large","item_ammo_ar2_altfire"}
			npc.JackyFirePowerMult=1.25
			npc.JackyProtectionMult=2
			npc.OpSquadFullBodySuit=true
			npc.OpSquadFlameRetardantSuit=true
			npc:SetBloodColor(-1)
			npc.OpSquadGoodHelmet=true
			npc:Activate()
			EliteOverWatchPhysique(npc)
			npc.OpSquadHardHitter=true
			npc:SetKeyValue("SquadName",SquadName)
			npc.JackyDamageGroup=SquadName
			npc:SetCurrentWeaponProficiency(WEAPON_PROFICIENCY_PERFECT)
			npc:Fire("startpatrolling","",10)
			npc.NextHealTime=CurTime()
			npc.OpSquadAmazingHunter=true
			npc.OpSquadIonBaller=true
			npc.OpSquadAware=true
			npc.OpSquadAutoHealer=true
			npc.OpSquadAggressive=true
			npc.OpSquadCareful=true
			npc.OpSquadStickTogether=true
			JackyOpSquadSpawnEvent(npc)
			npc4=npc
		end)--]]
		timer.Simple(0.4,function()
			undo.Create("HyperElite Combine Squad")
			undo.SetPlayer(ply)
			if(IsValid(npc1))then undo.AddEntity(npc1) end
			if(IsValid(npc2))then undo.AddEntity(npc2) end
			if(IsValid(npc3))then undo.AddEntity(npc3) end
			if(IsValid(npc4))then undo.AddEntity(npc4) end
			undo.SetCustomUndoText("Undone HyperElite Combine squad")
			undo.Finish()
		end)
	end
	JackieNPCSpawningTable.Modified["Elite Combine Biclops"]=function(selfpos)
		local npc=ents.Create("npc_combine_s")
		npc:SetPos(selfpos)
		npc:SetAngles(Angle(0,0,0))
		local Wep="weapon_smg1"
		local Drop={"item_ammo_smg1_large","weapon_frag","item_ammo_smg1_grenade"}
		if(math.random(1,2)==1)then
			Wep="weapon_shotgun"
			Drop={"item_box_buckshot","weapon_frag"}
		end
		npc:SetKeyValue("additionalequipment",Wep)
		npc:SetKeyValue("model","models/combine_soldier.mdl")
		npc:SetKeyValue("spawnflags","256")
		npc:SetKeyValue("tacticalvariant","2")
		npc:SetMaxHealth(40)
		npc:SetHealth(40)
		npc:CapabilitiesAdd(CAP_MOVE_SHOOT)
		npc:CapabilitiesAdd(CAP_NO_HIT_SQUADMATES)
		npc:Spawn()
		npc:SetMaterial("models/combine/soldier")
		npc.JackyOpSquadDrop=Drop
		npc.JackyFirePowerMult=1.25
		npc.JackyProtectionMult=2
		npc.OpSquadFullBodySuit=true
		npc.OpSquadFlameRetardantSuit=true
		npc:SetBloodColor(-1)
		npc.OpSquadGoodHelmet=true
		npc:Activate()
		EliteOverWatchPhysique(npc)
		npc:SetKeyValue("SquadName",SquadName)
		npc.JackyDamageGroup=SquadName
		npc:SetCurrentWeaponProficiency(WEAPON_PROFICIENCY_PERFECT)
		npc:Fire("startpatrolling","",10)
		npc.NextHealTime=CurTime()
		npc.OpSquadHardHitter=true
		npc.OpSquadAmazingHunter=true
		npc.OpSquadGrenadier=true
		npc.OpSquadAware=true
		npc.OpSquadAutoHealer=true
		npc.OpSquadAggressive=true
		npc.OpSquadCareful=true
		npc.OpSquadStickTogether=true
		JackyOpSquadSpawnEvent(npc)
		return npc
	end
	JackieNPCSpawningTable.Modified["Elite Combine Cyclops"]=function(selfpos)
		local npc=ents.Create("npc_combine_s")
		npc:SetPos(selfpos)
		npc:SetAngles(Angle(0,0,0))
		npc:SetKeyValue("additionalequipment","weapon_ar2")
		npc:SetKeyValue("model","models/combine_super_soldier.mdl")
		npc:SetKeyValue("spawnflags","256")
		npc:SetKeyValue("tacticalvariant","2")
		npc:SetMaxHealth(40)
		npc:SetHealth(40)
		npc:CapabilitiesAdd(CAP_MOVE_SHOOT)
		npc:CapabilitiesAdd(CAP_NO_HIT_SQUADMATES)
		npc:Spawn()
		npc:SetMaterial("models/combine/cyclops")
		npc.JackyOpSquadDrop={"item_ammo_ar2_large","item_ammo_ar2_altfire"}
		npc.JackyFirePowerMult=1.25
		npc.JackyProtectionMult=2
		npc.OpSquadFullBodySuit=true
		npc.OpSquadFlameRetardantSuit=true
		npc:SetBloodColor(-1)
		npc.OpSquadGoodHelmet=true
		npc:Activate()
		EliteOverWatchPhysique(npc)
		npc.OpSquadHardHitter=true
		npc:SetKeyValue("SquadName",SquadName)
		npc.JackyDamageGroup=SquadName
		npc:SetCurrentWeaponProficiency(WEAPON_PROFICIENCY_PERFECT)
		npc:Fire("startpatrolling","",10)
		npc.NextHealTime=CurTime()
		npc.OpSquadAmazingHunter=true
		npc.OpSquadIonBaller=true
		npc.OpSquadAware=true
		npc.OpSquadAutoHealer=true
		npc.OpSquadAggressive=true
		npc.OpSquadCareful=true
		npc.OpSquadStickTogether=true
		JackyOpSquadSpawnEvent(npc)
		return npc
	end
end