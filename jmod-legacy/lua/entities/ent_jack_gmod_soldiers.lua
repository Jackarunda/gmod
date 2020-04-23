AddCSLuaFile()
ENT.Type 			= "anim"
ENT.PrintName		= "U.S. Army Fireteam"
ENT.Author			= "Jackarunda"
ENT.Information		= ""
ENT.Category		= "JMod - LEGACY NPCs"

ENT.Spawnable		= true
ENT.AdminSpawnable	= true
if(SERVER)then
	local SquadName="JackyHumanSoldierOpSquad"
	local function ModifyModel(npc)
		--npc:SetBodygroup(0,math.random(0,10)) --wtf
		npc:SetSkin(math.random(0,10))
		npc:SetBodygroup(1,math.random(0,4))
		npc:SetBodygroup(2,0)
		npc:SetBodygroup(3,math.random(0,4))
		npc:SetBodygroup(4,math.random(0,1))
		npc:SetBodygroup(5,1)
		npc:ManipulateBoneScale(npc:LookupBone("ValveBiped.Bip01_Spine1"),Vector(1,.75,.75))
	end
	function ENT:SpawnFunction(ply,tr)
		local selfpos=tr.HitPos+tr.HitNormal*16
		local npc1
		local npc2
		local npc3
		local npc4
		local npc=ents.Create("npc_citizen")
		npc:SetPos(selfpos+Vector(20,-20,0))
		npc:SetAngles(Angle(0,-45,0))
		npc:SetKeyValue("additionalequipment","wep_jack_gmod_npcm4m203")
		npc:SetKeyValue("citizentype","3")
		npc:SetKeyValue("expressiontype","2")
		npc:SetKeyValue("spawnflags","4194560") --256+4194304
		npc:SetKeyValue("model","models/Jumans/Group03/Male_01.mdl")
		npc:CapabilitiesAdd(CAP_NO_HIT_SQUADMATES)
		npc:CapabilitiesAdd(CAP_MOVE_SHOOT)
		npc:Spawn()
		npc.USMilitaryRiflemanTraining=true
		npc.JackyCombatLifeSaver=true
		npc.JackyProtectionMult=2
		npc.AmericanBulletResistantVest=true
		npc.JackyUSSoldier=true
		npc.OpSquadHelmet=true
		npc.BuiltInHelmet=true
		npc:SetBloodColor(-1)
		npc:Activate()
		npc:SetMaxHealth(50)
		npc:SetHealth(50)
		npc:SetKeyValue("SquadName",SquadName)
		npc.JackyDamageGroup=SquadName
		npc:SetModel("models/half-dead/jodern warfare 3/us_ranger_01.mdl")
		ModifyModel(npc)
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
		npc.OpSquadStoic=true
		JackyOpSquadSpawnEvent(npc)
		npc1=npc
		timer.Simple(0.1,function()
			local npc=ents.Create("npc_citizen")
			npc:SetPos(selfpos+Vector(-20,-20,0))
			npc:SetAngles(Angle(0,-135,0))
			npc:SetKeyValue("additionalequipment","wep_jack_gmod_npcm4m203")
			npc:SetKeyValue("citizentype","3")
			npc:SetKeyValue("expressiontype","2")
			npc:SetKeyValue("spawnflags","4194560") --256+4194304
			npc:SetKeyValue("model","models/Jumans/Group03/Male_01.mdl")
			npc:CapabilitiesAdd(CAP_NO_HIT_SQUADMATES)
			npc:CapabilitiesAdd(CAP_MOVE_SHOOT)
			npc:Spawn()
			npc.USMilitaryRiflemanTraining=true
			npc.JackyCombatLifeSaver=true
			npc.JackyProtectionMult=2
			npc.AmericanBulletResistantVest=true
			npc.JackyUSSoldier=true
			npc.OpSquadHelmet=true
			npc.BuiltInHelmet=true
			npc:SetBloodColor(-1)
			npc:Activate()
			npc:SetMaxHealth(50)
			npc:SetHealth(50)
			npc:SetKeyValue("SquadName",SquadName)
			npc.JackyDamageGroup=SquadName
			npc:SetModel("models/half-dead/jodern warfare 3/us_ranger_01.mdl")
			ModifyModel(npc)
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
			npc.OpSquadStoic=true
			JackyOpSquadSpawnEvent(npc)
			npc2=npc
		end)
		timer.Simple(0.2,function()
			local npc=ents.Create("npc_citizen")
			npc:SetPos(selfpos+Vector(-20,20,0))
			npc:SetAngles(Angle(0,135,0))
			npc:SetKeyValue("additionalequipment","wep_jack_gmod_npcm4m203")
			npc:SetKeyValue("citizentype","3")
			npc:SetKeyValue("expressiontype","2")
			npc:SetKeyValue("spawnflags","4194560") --256+4194304
			npc:SetKeyValue("model","models/Jumans/Group03/Male_01.mdl")
			npc:CapabilitiesAdd(CAP_NO_HIT_SQUADMATES)
			npc:CapabilitiesAdd(CAP_MOVE_SHOOT)
			npc:Spawn()
			npc.USMilitaryRiflemanTraining=true
			npc.JackyCombatLifeSaver=true
			npc.JackyProtectionMult=2
			npc.AmericanBulletResistantVest=true
			npc.JackyUSSoldier=true
			npc.OpSquadHelmet=true
			npc.BuiltInHelmet=true
			npc:SetBloodColor(-1)
			npc:Activate()
			npc:SetMaxHealth(50)
			npc:SetHealth(50)
			npc:SetKeyValue("SquadName",SquadName)
			npc.JackyDamageGroup=SquadName
			npc:SetModel("models/half-dead/jodern warfare 3/us_ranger_01.mdl")
			ModifyModel(npc)
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
			npc.OpSquadStoic=true
			JackyOpSquadSpawnEvent(npc)
			npc3=npc
		end)
		timer.Simple(0.3,function()
			local npc=ents.Create("npc_citizen")
			npc:SetPos(selfpos+Vector(20,20,0))
			npc:SetAngles(Angle(0,45,0))
			npc:SetKeyValue("additionalequipment","wep_jack_gmod_npcm4m203")
			npc:SetKeyValue("citizentype","3")
			npc:SetKeyValue("expressiontype","2")
			npc:SetKeyValue("spawnflags","4194560") --256+4194304
			npc:SetKeyValue("model","models/Jumans/Group03/Male_01.mdl")
			npc:CapabilitiesAdd(CAP_NO_HIT_SQUADMATES)
			npc:CapabilitiesAdd(CAP_MOVE_SHOOT)
			npc:Spawn()
			npc.USMilitaryRiflemanTraining=true
			npc.JackyCombatLifeSaver=true
			npc.JackyProtectionMult=2
			npc.AmericanBulletResistantVest=true
			npc.JackyUSSoldier=true
			npc.OpSquadHelmet=true
			npc.BuiltInHelmet=true
			npc:SetBloodColor(-1)
			npc:Activate()
			npc:SetMaxHealth(50)
			npc:SetHealth(50)
			npc:SetKeyValue("SquadName",SquadName)
			npc.JackyDamageGroup=SquadName
			npc:SetModel("models/half-dead/jodern warfare 3/us_ranger_01.mdl")
			ModifyModel(npc)
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
			npc.OpSquadStoic=true
			JackyOpSquadSpawnEvent(npc)
			npc4=npc
		end)
		--]]
		timer.Simple(0.4,function()
			undo.Create("Elite Rebel Squad")
			undo.SetPlayer(ply)
			if(IsValid(npc1))then undo.AddEntity(npc1) end
			if(IsValid(npc2))then undo.AddEntity(npc2) end
			if(IsValid(npc3))then undo.AddEntity(npc3) end
			if(IsValid(npc4))then undo.AddEntity(npc4) end
			undo.SetCustomUndoText("Undone U.S. Army FireTeam")
			undo.Finish()
		end)
	end
	JackieNPCSpawningTable.Modified["U.S. Army Rifleman"]=function(selfpos)
		local npc=ents.Create("npc_citizen")
		npc:SetPos(selfpos)
		npc:SetAngles(Angle(0,0,0))
		npc:SetKeyValue("additionalequipment","wep_jack_gmod_npcm4m203")
		npc:SetKeyValue("citizentype","3")
		npc:SetKeyValue("expressiontype","2")
		npc:SetKeyValue("spawnflags","4194560") --256+4194304
		npc:SetKeyValue("model","models/Jumans/Group03/Male_01.mdl")
		npc:CapabilitiesAdd(CAP_NO_HIT_SQUADMATES)
		npc:CapabilitiesAdd(CAP_MOVE_SHOOT)
		npc:Spawn()
		npc.USMilitaryRiflemanTraining=true
		npc.JackyCombatLifeSaver=true
		npc.JackyProtectionMult=2
		npc.AmericanBulletResistantVest=true
		npc.JackyUSSoldier=true
		npc.OpSquadHelmet=true
		npc.BuiltInHelmet=true
		npc:SetBloodColor(-1)
		npc:Activate()
		npc:SetMaxHealth(50)
		npc:SetHealth(50)
		npc:SetKeyValue("SquadName",SquadName)
		npc.JackyDamageGroup=SquadName
		npc:SetModel("models/half-dead/jodern warfare 3/us_ranger_01.mdl")
		ModifyModel(npc)
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
		npc.OpSquadStoic=true
		JackyOpSquadSpawnEvent(npc)
		return npc
	end
end