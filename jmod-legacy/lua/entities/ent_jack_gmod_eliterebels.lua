AddCSLuaFile()
ENT.Type 			= "anim"
ENT.PrintName		= "Elite Rebels"
ENT.Author			= "Jackarunda"
ENT.Information		= ""
ENT.Category		= "JMod - LEGACY NPCs"

ENT.Spawnable		= true
ENT.AdminSpawnable	= true
if(SERVER)then
	local SquadName="JackyHumanOpSquad"
	local ModelTable={
		"models/Jumans/Group03/Male_01.mdl",
		"models/Jumans/Group03/male_02.mdl",
		"models/Jumans/Group03/male_03.mdl",
		"models/Jumans/Group03/Male_04.mdl",
		"models/Jumans/Group03/Male_05.mdl",
		"models/Jumans/Group03/male_06.mdl",
		"models/Jumans/Group03/male_07.mdl",
		"models/Jumans/Group03/male_08.mdl",
		"models/Jumans/Group03/male_09.mdl"
	}
	local MedicModelTable={
		"models/Jumans/Group03m/Male_01.mdl",
		"models/Jumans/Group03m/male_02.mdl",
		"models/Jumans/Group03m/male_03.mdl",
		"models/Jumans/Group03m/Male_04.mdl",
		"models/Jumans/Group03m/Male_05.mdl",
		"models/Jumans/Group03m/male_06.mdl",
		"models/Jumans/Group03m/male_07.mdl",
		"models/Jumans/Group03m/male_08.mdl",
		"models/Jumans/Group03m/male_09.mdl"
	}
	local function HaveSchizophrenia(npc)
		if(math.random(1,15)==6)then
			npc:Fire("speakidleresponse","",0)
		end
	end
	local function JackarundasPhysique(npc)
		npc:ManipulateBoneScale(npc:LookupBone("ValveBiped.Bip01_Spine4"),Vector(1.3,1.2,1.2))
		npc:ManipulateBoneScale(npc:LookupBone("ValveBiped.Bip01_Spine2"),Vector(1.1,1.1,1.1))
		npc:ManipulateBoneScale(npc:LookupBone("ValveBiped.Bip01_Spine1"),Vector(1,.85,.85))
		npc:ManipulateBoneScale(npc:LookupBone("ValveBiped.Bip01_Spine"),Vector(1,.85,.85))
		npc:ManipulateBoneScale(npc:LookupBone("ValveBiped.Bip01_L_UpperArm"),Vector(1,1.25,1.25))
		npc:ManipulateBoneScale(npc:LookupBone("ValveBiped.Bip01_L_Shoulder"),Vector(1,1.25,1.25))
		npc:ManipulateBoneScale(npc:LookupBone("ValveBiped.Bip01_L_Bicep"),Vector(1,1.25,1.25))
		npc:ManipulateBoneScale(npc:LookupBone("ValveBiped.Bip01_R_UpperArm"),Vector(1,1.25,1.25))
		npc:ManipulateBoneScale(npc:LookupBone("ValveBiped.Bip01_R_Shoulder"),Vector(1,1.25,1.25))
		npc:ManipulateBoneScale(npc:LookupBone("ValveBiped.Bip01_R_Bicep"),Vector(1,1.3,1.3))
		npc:ManipulateBoneScale(npc:LookupBone("ValveBiped.Bip01_R_Thigh"),Vector(1,1.4,1.4))
		npc:ManipulateBoneScale(npc:LookupBone("ValveBiped.Bip01_L_Thigh"),Vector(1,1.4,1.4))
	end
	function ENT:SpawnFunction(ply,tr)
		--524288(SF_CITIZEN_AMMORESUPPLIER)
		--131072(SF_CITIZEN_MEDIC)
		local selfpos=tr.HitPos+tr.HitNormal*16
		local npc1
		local npc2
		local npc3
		local npc4
		local model1=ModelTable[math.random(1,9)]
		local model3=ModelTable[math.random(1,9)]
		while(model3==model1)do
			model3=ModelTable[math.random(1,9)]
		end
		local model2=MedicModelTable[math.random(1,9)]
		local model4=MedicModelTable[math.random(1,9)]
		while(model4==model3)do
			model4=MedicModelTable[math.random(1,9)]
		end
		local npc=ents.Create("npc_citizen")
		npc:SetPos(selfpos+Vector(20,-20,0))
		npc:SetAngles(Angle(0,-45,0))
		npc:SetKeyValue("additionalequipment","weapon_smg1")
		npc:SetKeyValue("citizentype","3")
		npc:SetKeyValue("expressiontype","3")
		npc:SetKeyValue("spawnflags","524544") --256+524288(SF_CITIZEN_AMMORESUPPLIER)
		npc:SetKeyValue("ammosupply","SMG1_Grenade")
		npc:SetKeyValue("ammoamount","1")
		npc:SetMaxHealth(40)
		npc:SetHealth(40)
		npc:CapabilitiesAdd(CAP_NO_HIT_SQUADMATES)
		npc:CapabilitiesAdd(CAP_MOVE_SHOOT)
		npc:Spawn()
		npc.JackyProtectionMult=1.35
		npc.AmericanBulletResistantVest=true
		npc.OpSquadHelmet=true
		timer.Simple(.5,function()
			if(IsValid(npc))then
				umsg.Start("JackyOpSquadGiveHelmet")
					umsg.Entity(npc)
				umsg.End()
			end
		end)
		npc.JackyFirePowerMult=1.3
		npc.JackyFinickyAmmoGiver=true
		npc.JackyOpSquadDrop={"item_ammo_smg1_large","item_ammo_smg1_grenade"}
		npc:SetBloodColor(-1)
		npc:Activate()
		npc:SetKeyValue("SquadName",SquadName)
		npc.JackyDamageGroup=SquadName
		npc:SetModel(model1)
		JackarundasPhysique(npc)
		npc:SetCurrentWeaponProficiency(WEAPON_PROFICIENCY_PERFECT)
		npc:Fire("startpatrolling","",10)
		npc:Fire("disableweaponpickup","",0)
		npc.OpSquadAmazingHunter=true
		npc.OpSquadAware=true
		npc.OpSquadCareful=true
		npc.OpSquadAggressive=true
		npc.OpSquadStickTogether=true
		npc.OpSquadVengeful=true
		npc.OpSquadStabResistantClothing=true
		npc.OpSquadGrenadier=true
		JackyOpSquadSpawnEvent(npc)
		npc1=npc
		timer.Simple(0.1,function()
			local npc=ents.Create("npc_citizen")
			npc:SetPos(selfpos+Vector(20,20,0))
			npc:SetAngles(Angle(0,45,0))
			npc:SetKeyValue("additionalequipment","weapon_annabelle")
			npc:SetKeyValue("citizentype","3")
			npc:SetKeyValue("expressiontype","3")
			npc:SetKeyValue("spawnflags","524544") --256+524288(SF_CITIZEN_AMMORESUPPLIER)
			npc:SetKeyValue("ammosupply","357")
			npc:SetKeyValue("ammoamount","6")
			npc:SetMaxHealth(40)
			npc:SetHealth(40)
			npc:CapabilitiesAdd(CAP_NO_HIT_SQUADMATES)
			npc:CapabilitiesAdd(CAP_MOVE_SHOOT)
			npc:SetCurrentWeaponProficiency(WEAPON_PROFICIENCY_PERFECT)
			npc:Spawn()
			npc:SetCurrentWeaponProficiency(WEAPON_PROFICIENCY_PERFECT)
			npc.JackyProtectionMult=1.35
			npc.AmericanBulletResistantVest=true
			npc.OpSquadHelmet=true
			timer.Simple(.5,function()
				if(IsValid(npc))then
					umsg.Start("JackyOpSquadGiveHelmet")
						umsg.Entity(npc)
					umsg.End()
				end
			end)
			npc.JackyFirePowerMult=2.5 -- annabelle loaded with slugs
			npc.JackyFinickyAmmoGiver=true
			npc.JackyOpSquadDrop={"item_ammo_crossbow","item_ammo_357_large"}
			npc:SetBloodColor(-1)
			npc:Activate()
			npc:SetKeyValue("SquadName",SquadName)
			npc.JackyDamageGroup=SquadName
			npc:SetModel(model3)
			JackarundasPhysique(npc)
			npc:Fire("startpatrolling","",10)
			npc:Fire("disableweaponpickup","",0)
			npc:AddRelationship("npc_turret_floor D_FR 90")
			npc:AddRelationship("npc_turret_ceiling D_FR 90")
			npc.OpSquadAmazingHunter=true
			npc.OpSquadAware=true
			npc.OpSquadCareful=true
			npc.OpSquadAggressive=true
			npc.OpSquadStickTogether=true
			npc.OpSquadVengeful=true
			npc.OpSquadStabResistantClothing=true
			JackyOpSquadSpawnEvent(npc)
			npc2=npc
		end)
		timer.Simple(0.2,function()
			local npc=ents.Create("npc_citizen")
			npc:SetPos(selfpos+Vector(-20,20,0))
			npc:SetAngles(Angle(0,135,0))
			npc:SetKeyValue("additionalequipment","weapon_smg1")
			npc:SetKeyValue("citizentype","3")
			npc:SetKeyValue("expressiontype","3")
			npc:SetKeyValue("spawnflags","131328") --256+131072(SF_CITIZEN_MEDIC)
			npc:SetMaxHealth(40)
			npc:SetHealth(40)
			npc:CapabilitiesAdd(CAP_NO_HIT_SQUADMATES)
			npc:CapabilitiesAdd(CAP_MOVE_SHOOT)
			npc:Spawn()
			npc.JackyProtectionMult=1.35
			npc.AmericanBulletResistantVest=true
			npc.OpSquadHelmet=true
			timer.Simple(.5,function()
				if(IsValid(npc))then
					umsg.Start("JackyOpSquadGiveHelmet")
						umsg.Entity(npc)
					umsg.End()
				end
			end)
			npc.JackyFirePowerMult=1.3
			npc.JackyFinickyAmmoGiver=true
			npc.JackyOpSquadDrop={"item_ammo_smg1_large","item_ammo_smg1_grenade","item_healthvial"}
			npc:SetBloodColor(-1)
			npc:Activate()
			npc:SetKeyValue("SquadName",SquadName)
			npc.JackyDamageGroup=SquadName
			npc:SetModel(model2)
			JackarundasPhysique(npc)
			npc:SetCurrentWeaponProficiency(WEAPON_PROFICIENCY_PERFECT)
			npc:Fire("startpatrolling","",10)
			npc:Fire("disableweaponpickup","",0)
			npc.OpSquadAmazingHunter=true
			npc.OpSquadAware=true
			npc.OpSquadCareful=true
			npc.OpSquadAggressive=true
			npc.OpSquadMedic=true
			npc.OpSquadStickTogether=true
			npc.OpSquadVengeful=true
			npc.OpSquadStabResistantClothing=true
			npc.OpSquadGrenadier=true
			JackyOpSquadSpawnEvent(npc)
			npc3=npc
		end)
		timer.Simple(0.3,function()
			local npc=ents.Create("npc_citizen")
			npc:SetPos(selfpos+Vector(-20,-20,0))
			npc:SetAngles(Angle(0,-135,0))
			npc:SetKeyValue("additionalequipment","weapon_shotgun")
			npc:SetKeyValue("citizentype","3")
			npc:SetKeyValue("expressiontype","3")
			npc:SetKeyValue("spawnflags","131328") --256+131072(SF_CITIZEN_MEDIC)
			npc:SetMaxHealth(40)
			npc:SetHealth(40)
			npc:CapabilitiesAdd(CAP_NO_HIT_SQUADMATES)
			npc:CapabilitiesAdd(CAP_MOVE_SHOOT)
			npc:Spawn()
			npc.JackyProtectionMult=1.35
			npc.AmericanBulletResistantVest=true
			npc.OpSquadHelmet=true
			timer.Simple(.5,function()
				if(IsValid(npc))then
					umsg.Start("JackyOpSquadGiveHelmet")
						umsg.Entity(npc)
					umsg.End()
				end
			end)
			npc.JackyFirePowerMult=1.3
			npc.JackyFinickyAmmoGiver=true
			npc.JackyOpSquadDrop={"item_box_buckshot","item_healthvial"}
			npc:SetBloodColor(-1)
			npc:Activate()
			npc:SetKeyValue("SquadName",SquadName)
			npc.JackyDamageGroup=SquadName
			npc:SetModel(model4)
			JackarundasPhysique(npc)
			npc:SetCurrentWeaponProficiency(WEAPON_PROFICIENCY_PERFECT)
			npc:Fire("startpatrolling","",10)
			npc:Fire("disableweaponpickup","",0)
			npc:AddRelationship("npc_turret_floor D_FR 90")
			npc:AddRelationship("npc_turret_ceiling D_FR 90")
			npc.OpSquadAmazingHunter=true
			npc.OpSquadAware=true
			npc.OpSquadCareful=true
			npc.OpSquadAggressive=true
			npc.OpSquadMedic=true
			npc.OpSquadStickTogether=true
			npc.OpSquadVengeful=true
			npc.OpSquadStabResistantClothing=true
			JackyOpSquadSpawnEvent(npc)
			npc4=npc
		end)
		timer.Simple(0.4,function()
			undo.Create("Elite Rebel Squad")
			undo.SetPlayer(ply)
			if(IsValid(npc1))then undo.AddEntity(npc1) end
			if(IsValid(npc2))then undo.AddEntity(npc2) end
			if(IsValid(npc3))then undo.AddEntity(npc3) end
			if(IsValid(npc4))then undo.AddEntity(npc4) end
			undo.SetCustomUndoText("Undone Elite Rebel Squad")
			undo.Finish()
		end)
	end
	JackieNPCSpawningTable.Modified["Elite Rebel Grenadier"]=function(selfpos)
		local npc=ents.Create("npc_citizen")
		npc:SetPos(selfpos)
		npc:SetAngles(Angle(0,0,0))
		npc:SetKeyValue("additionalequipment","weapon_smg1")
		npc:SetKeyValue("citizentype","3")
		npc:SetKeyValue("expressiontype","3")
		npc:SetKeyValue("spawnflags","524544") --256+524288(SF_CITIZEN_AMMORESUPPLIER)
		npc:SetKeyValue("ammosupply","SMG1_Grenade")
		npc:SetKeyValue("ammoamount","1")
		npc:SetMaxHealth(40)
		npc:SetHealth(40)
		npc:CapabilitiesAdd(CAP_NO_HIT_SQUADMATES)
		npc:CapabilitiesAdd(CAP_MOVE_SHOOT)
		npc:Spawn()
		npc.JackyProtectionMult=1.35
		npc.AmericanBulletResistantVest=true
		npc.OpSquadHelmet=true
		timer.Simple(.5,function()
			if(IsValid(npc))then
				umsg.Start("JackyOpSquadGiveHelmet")
					umsg.Entity(npc)
				umsg.End()
			end
		end)
		npc.JackyFirePowerMult=1.3
		npc.JackyFinickyAmmoGiver=true
		npc.JackyOpSquadDrop={"item_ammo_smg1_large","item_ammo_smg1_grenade"}
		npc:SetBloodColor(-1)
		npc:Activate()
		npc:SetKeyValue("SquadName",SquadName)
		npc.JackyDamageGroup=SquadName
		npc:SetModel(ModelTable[math.random(1,9)])
		JackarundasPhysique(npc)
		npc:SetCurrentWeaponProficiency(WEAPON_PROFICIENCY_PERFECT)
		npc:Fire("startpatrolling","",10)
		npc:Fire("disableweaponpickup","",0)
		npc.OpSquadAmazingHunter=true
		npc.OpSquadAware=true
		npc.OpSquadCareful=true
		npc.OpSquadAggressive=true
		npc.OpSquadStickTogether=true
		npc.OpSquadVengeful=true
		npc.OpSquadStabResistantClothing=true
		npc.OpSquadGrenadier=true
		JackyOpSquadSpawnEvent(npc)
		return npc
	end
	JackieNPCSpawningTable.Modified["Elite Rebel Marksman"]=function(selfpos)
		local npc=ents.Create("npc_citizen")
		npc:SetPos(selfpos)
		npc:SetAngles(Angle(0,0,0))
		npc:SetKeyValue("additionalequipment","weapon_annabelle")
		npc:SetKeyValue("citizentype","3")
		npc:SetKeyValue("expressiontype","3")
		npc:SetKeyValue("spawnflags","524544") --256+524288(SF_CITIZEN_AMMORESUPPLIER)
		npc:SetKeyValue("ammosupply","357")
		npc:SetKeyValue("ammoamount","6")
		npc:SetMaxHealth(40)
		npc:SetHealth(40)
		npc:CapabilitiesAdd(CAP_NO_HIT_SQUADMATES)
		npc:CapabilitiesAdd(CAP_MOVE_SHOOT)
		npc:SetCurrentWeaponProficiency(WEAPON_PROFICIENCY_PERFECT)
		npc:Spawn()
		npc:SetCurrentWeaponProficiency(WEAPON_PROFICIENCY_PERFECT)
		npc.JackyProtectionMult=1.35
		npc.AmericanBulletResistantVest=true
		npc.OpSquadHelmet=true
		timer.Simple(.5,function()
			if(IsValid(npc))then
				umsg.Start("JackyOpSquadGiveHelmet")
					umsg.Entity(npc)
				umsg.End()
			end
		end)
		npc.JackyFirePowerMult=2.5 -- annabelle loaded with slugs
		npc.JackyFinickyAmmoGiver=true
		npc.JackyOpSquadDrop={"item_ammo_crossbow","item_ammo_357_large"}
		npc:SetBloodColor(-1)
		npc:Activate()
		npc:SetKeyValue("SquadName",SquadName)
		npc.JackyDamageGroup=SquadName
		npc:SetModel(ModelTable[math.random(1,9)])
		JackarundasPhysique(npc)
		npc:Fire("startpatrolling","",10)
		npc:Fire("disableweaponpickup","",0)
		npc:AddRelationship("npc_turret_floor D_FR 90")
		npc:AddRelationship("npc_turret_ceiling D_FR 90")
		npc.OpSquadAmazingHunter=true
		npc.OpSquadAware=true
		npc.OpSquadCareful=true
		npc.OpSquadAggressive=true
		npc.OpSquadStickTogether=true
		npc.OpSquadVengeful=true
		npc.OpSquadStabResistantClothing=true
		JackyOpSquadSpawnEvent(npc)
		return npc
	end
	JackieNPCSpawningTable.Modified["Elite Rebel Medic"]=function(selfpos)
		local npc=ents.Create("npc_citizen")
		npc:SetPos(selfpos)
		npc:SetAngles(Angle(0,0,0))
		npc:SetKeyValue("additionalequipment","weapon_smg1")
		npc:SetKeyValue("citizentype","3")
		npc:SetKeyValue("expressiontype","3")
		npc:SetKeyValue("spawnflags","131328") --256+131072(SF_CITIZEN_MEDIC)
		npc:SetMaxHealth(40)
		npc:SetHealth(40)
		npc:CapabilitiesAdd(CAP_NO_HIT_SQUADMATES)
		npc:CapabilitiesAdd(CAP_MOVE_SHOOT)
		npc:Spawn()
		npc.JackyProtectionMult=1.35
		npc.AmericanBulletResistantVest=true
		npc.OpSquadHelmet=true
		timer.Simple(.5,function()
			if(IsValid(npc))then
				umsg.Start("JackyOpSquadGiveHelmet")
					umsg.Entity(npc)
				umsg.End()
			end
		end)
		npc.JackyFirePowerMult=1.3
		npc.JackyFinickyAmmoGiver=true
		npc.JackyOpSquadDrop={"item_ammo_smg1_large","item_ammo_smg1_grenade","item_healthvial"}
		npc:SetBloodColor(-1)
		npc:Activate()
		npc:SetKeyValue("SquadName",SquadName)
		npc.JackyDamageGroup=SquadName
		npc:SetModel(MedicModelTable[math.random(1,9)])
		JackarundasPhysique(npc)
		npc:SetCurrentWeaponProficiency(WEAPON_PROFICIENCY_PERFECT)
		npc:Fire("startpatrolling","",10)
		npc:Fire("disableweaponpickup","",0)
		npc.OpSquadAmazingHunter=true
		npc.OpSquadAware=true
		npc.OpSquadCareful=true
		npc.OpSquadAggressive=true
		npc.OpSquadMedic=true
		npc.OpSquadStickTogether=true
		npc.OpSquadVengeful=true
		npc.OpSquadStabResistantClothing=true
		npc.OpSquadGrenadier=true
		JackyOpSquadSpawnEvent(npc)
		return npc
	end
end