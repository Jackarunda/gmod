AddCSLuaFile()
ENT.Type 			= "anim"
ENT.PrintName		= "Humans"
ENT.Author			= "Jackarunda"
ENT.Information	=""
ENT.Category		= "JMod - LEGACY NPCs"

ENT.Spawnable		= true
ENT.AdminSpawnable	= true
if(SERVER)then
	local SquadName="JackyHumanOpSquad"
	function ENT:SpawnFunction(ply,tr)
		local selfpos=tr.HitPos+tr.HitNormal*16
		local Delay=.01
		if(JackyOpSquadsMustPreCacheHumans)then
			Delay=1
			for key,ply in pairs(player.GetAll())do
				ply:PrintMessage(HUD_PRINTCENTER,"Please give the game a moment to\ncache the HL2 citizen/rebel models.")
			end
			timer.Simple(.5,function()
				util.PrecacheModel("models/Humans/Group01/Female_01.mdl")
				util.PrecacheModel("models/Humans/Group01/Female_02.mdl")
				util.PrecacheModel("models/Humans/Group01/Female_03.mdl")
				util.PrecacheModel("models/Humans/Group01/Female_04.mdl")
				util.PrecacheModel("models/Humans/Group01/Female_05.mdl")
				util.PrecacheModel("models/Humans/Group01/Female_06.mdl")
				util.PrecacheModel("models/Humans/Group01/Female_07.mdl")
				util.PrecacheModel("models/Humans/Group01/Male_01.mdl")
				util.PrecacheModel("models/Humans/Group01/male_02.mdl")
				util.PrecacheModel("models/Humans/Group01/male_03.mdl")
				util.PrecacheModel("models/Humans/Group01/Male_04.mdl")
				util.PrecacheModel("models/Humans/Group01/Male_05.mdl")
				util.PrecacheModel("models/Humans/Group01/male_06.mdl")
				util.PrecacheModel("models/Humans/Group01/male_07.mdl")
				util.PrecacheModel("models/Humans/Group01/male_08.mdl")
				util.PrecacheModel("models/Humans/Group01/male_09.mdl")
				util.PrecacheModel("models/Humans/Group03/Female_01.mdl")
				util.PrecacheModel("models/Humans/Group03/Female_02.mdl")
				util.PrecacheModel("models/Humans/Group03/Female_03.mdl")
				util.PrecacheModel("models/Humans/Group03/Female_04.mdl")
				util.PrecacheModel("models/Humans/Group03/Female_05.mdl")
				util.PrecacheModel("models/Humans/Group03/Female_06.mdl")
				util.PrecacheModel("models/Humans/Group03/Female_07.mdl")
				util.PrecacheModel("models/Humans/Group03/Male_01.mdl")
				util.PrecacheModel("models/Humans/Group03/male_02.mdl")
				util.PrecacheModel("models/Humans/Group03/male_03.mdl")
				util.PrecacheModel("models/Humans/Group03/Male_04.mdl")
				util.PrecacheModel("models/Humans/Group03/Male_05.mdl")
				util.PrecacheModel("models/Humans/Group03/male_06.mdl")
				util.PrecacheModel("models/Humans/Group03/male_07.mdl")
				util.PrecacheModel("models/Humans/Group03/male_08.mdl")
				util.PrecacheModel("models/Humans/Group03/male_09.mdl")
				util.PrecacheModel("models/Humans/Group03m/Female_01.mdl")
				util.PrecacheModel("models/Humans/Group03m/Female_02.mdl")
				util.PrecacheModel("models/Humans/Group03m/Female_03.mdl")
				util.PrecacheModel("models/Humans/Group03m/Female_04.mdl")
				util.PrecacheModel("models/Humans/Group03m/Female_05.mdl")
				util.PrecacheModel("models/Humans/Group03m/Female_06.mdl")
				util.PrecacheModel("models/Humans/Group03m/Female_07.mdl")
				util.PrecacheModel("models/Humans/Group03m/Male_01.mdl")
				util.PrecacheModel("models/Humans/Group03m/male_02.mdl")
				util.PrecacheModel("models/Humans/Group03m/male_03.mdl")
				util.PrecacheModel("models/Humans/Group03m/Male_04.mdl")
				util.PrecacheModel("models/Humans/Group03m/Male_05.mdl")
				util.PrecacheModel("models/Humans/Group03m/male_06.mdl")
				util.PrecacheModel("models/Humans/Group03m/male_07.mdl")
				util.PrecacheModel("models/Humans/Group03m/male_08.mdl")
				util.PrecacheModel("models/Humans/Group03m/male_09.mdl")
			end)
			JackyOpSquadsMustPreCacheHumans=false
		end
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
		timer.Simple(Delay,function()
			timer.Simple(.025,function()
				local npc=ents.Create("npc_citizen")
				npc:SetPos(selfpos)
				npc:SetKeyValue("citizentype","3")
				npc:SetKeyValue("Expression Type","Random")
				npc:SetKeyValue("additionalequipment","wep_jack_gmod_npcrocketlauncher")
				npc:SetCurrentWeaponProficiency(WEAPON_PROFICIENCY_PERFECT) --but gosh damn do they suck giant horse schlong at shooting things with their RPG
				npc:SetKeyValue("spawnflags","524544") --256+524288(SF_CITIZEN_AMMORESUPPLIER)
				npc.JackyFinickyAmmoGiver=true
				npc:SetKeyValue("ammosupply","RPG_Round")
				npc:SetKeyValue("ammoamount","1")
				npc:Spawn()
				npc:Activate()
				npc:SetKeyValue("SquadName",SquadName)
				npc.JackyDamageGroup=SquadName
				npc.JackyOpSquadDrop={"item_rpg_round"}
				npc:Fire("disableweaponpickup","",0)
				npc:Fire("startpatrolling","",math.Rand(30,60))
				npc:Fire("addoutput","onplayeruse !self,startpatrolling,"..tostring(npc).."0",0)
				npc:Fire("setammoresupplieroff","",0)
				JackyOpSquadSpawnEvent(npc)
				npc1=npc
			end)
			timer.Simple(0.05,function()
				local npc=ents.Create("npc_citizen")
				npc:SetPos(selfpos+Vector(50,0,0))
				npc:SetAngles(Angle(0,0,0))
				npc:SetKeyValue("citizentype","3")
				npc:SetKeyValue("spawnflags",SF_CITIZEN_MEDIC)
				npc:SetKeyValue("Expression Type","Random")
				npc:SetKeyValue("additionalequipment","weapon_smg1")
				npc.JackyOpSquadDrop={"item_healthvial"}
				npc:Spawn()
				npc:Activate()
				npc:SetKeyValue("SquadName",SquadName)
				npc.JackyDamageGroup=SquadName
				npc:Fire("startpatrolling","",math.Rand(30,60))
				JackyOpSquadSpawnEvent(npc)
				npc2=npc
			end)
			timer.Simple(0.1,function()
				local npc=ents.Create("npc_citizen")
				npc:SetPos(selfpos+Vector(50,50,0))
				npc:SetAngles(Angle(0,45,0))
				npc:SetKeyValue("citizentype","3")
				npc:SetKeyValue("Expression Type","Random")
				npc:SetKeyValue("additionalequipment","weapon_shotgun")
				npc:SetKeyValue("spawnflags",SF_CITIZEN_AMMORESUPPLIER)
				npc.JackyFinickyAmmoGiver=true
				npc:SetKeyValue("ammosupply","Buckshot")
				npc:SetKeyValue("ammoamount","6")
				npc.JackyOpSquadDrop={"item_box_buckshot"}
				npc:Spawn()
				npc:Activate()
				npc:SetKeyValue("SquadName",SquadName)
				npc.JackyDamageGroup=SquadName
				npc:Fire("startpatrolling","",math.Rand(30,60))
				JackyOpSquadSpawnEvent(npc)
				npc3=npc
			end)
			timer.Simple(0.15,function()
				local npc=ents.Create("npc_citizen")
				npc:SetPos(selfpos+Vector(0,50,0))
				npc:SetAngles(Angle(0,90,0))
				npc:SetKeyValue("citizentype","3")
				npc:SetKeyValue("Expression Type","Random")
				npc:SetKeyValue("spawnflags",SF_CITIZEN_MEDIC)
				npc:SetKeyValue("additionalequipment","weapon_smg1")
				npc.JackyOpSquadDrop={"item_healthvial"}
				npc:Spawn()
				npc:Activate()
				npc:SetKeyValue("SquadName",SquadName)
				npc.JackyDamageGroup=SquadName
				npc:Fire("startpatrolling","",math.Rand(30,60))
				npc:Fire("setmedicoff","",0)
				JackyOpSquadSpawnEvent(npc)
				npc4=npc
			end)
			timer.Simple(0.2,function()
				local npc=ents.Create("npc_citizen")
				npc:SetPos(selfpos+Vector(-50,50,0))
				npc:SetAngles(Angle(0,135,0))
				npc:SetKeyValue("citizentype","3")
				npc:SetKeyValue("Expression Type","Random")
				npc:SetKeyValue("additionalequipment","weapon_shotgun")
				npc:SetKeyValue("spawnflags",SF_CITIZEN_AMMORESUPPLIER)
				npc.JackyFinickyAmmoGiver=true
				npc:SetKeyValue("ammosupply","Buckshot")
				npc:SetKeyValue("ammoamount","6")
				npc.JackyOpSquadDrop={"item_box_buckshot"}
				npc:Spawn()
				npc:Activate()
				npc:SetKeyValue("SquadName",SquadName)
				npc.JackyDamageGroup=SquadName
				npc:Fire("startpatrolling","",math.Rand(30,60))
				JackyOpSquadSpawnEvent(npc)
				npc5=npc
			end)
			timer.Simple(0.25,function()
				local npc=ents.Create("npc_citizen")
				npc:SetPos(selfpos+Vector(-50,0,0))
				npc:SetAngles(Angle(0,180,0))
				npc:SetKeyValue("citizentype","3")
				npc:SetKeyValue("spawnflags",SF_CITIZEN_MEDIC)
				npc:SetKeyValue("Expression Type","Random")
				npc:SetKeyValue("additionalequipment","weapon_smg1")
				npc.JackyOpSquadDrop={"item_healthvial"}
				npc:Spawn()
				npc:Activate()
				npc:SetKeyValue("SquadName",SquadName)
				npc.JackyDamageGroup=SquadName
				npc:Fire("startpatrolling","",math.Rand(30,60))
				npc:Fire("setmedicoff","",0)
				JackyOpSquadSpawnEvent(npc)
				npc6=npc
			end)
			timer.Simple(0.3,function()
				local npc=ents.Create("npc_citizen")
				npc:SetPos(selfpos+Vector(-50,-50,0))
				npc:SetAngles(Angle(0,225,0))
				npc:SetKeyValue("citizentype","3")
				npc:SetKeyValue("Expression Type","Random")
				npc:SetKeyValue("additionalequipment","weapon_shotgun")
				npc:SetKeyValue("spawnflags",SF_CITIZEN_AMMORESUPPLIER)
				npc.JackyFinickyAmmoGiver=true
				npc:SetKeyValue("ammosupply","Buckshot")
				npc:SetKeyValue("ammoamount","6")
				npc.JackyOpSquadDrop={"item_box_buckshot"}
				npc:Spawn()
				npc:Activate()
				npc:SetKeyValue("SquadName",SquadName)
				npc.JackyDamageGroup=SquadName
				npc:Fire("startpatrolling","",math.Rand(30,60))
				JackyOpSquadSpawnEvent(npc)
				npc7=npc
			end)
			timer.Simple(0.35,function()
				local npc=ents.Create("npc_citizen")
				npc:SetPos(selfpos+Vector(0,-50,0))
				npc:SetAngles(Angle(0,270,0))
				npc:SetKeyValue("citizentype","3")
				npc:SetKeyValue("spawnflags",SF_CITIZEN_MEDIC)
				npc:SetKeyValue("Expression Type","Random")
				npc:SetKeyValue("additionalequipment","weapon_smg1")
				npc.JackyOpSquadDrop={"item_healthvial"}
				npc:Spawn()
				npc:Activate()
				npc:SetKeyValue("SquadName",SquadName)
				npc.JackyDamageGroup=SquadName
				npc:Fire("startpatrolling","",math.Rand(30,60))
				JackyOpSquadSpawnEvent(npc)
				npc8=npc
			end)
			timer.Simple(0.4,function()
				local npc=ents.Create("npc_citizen")
				npc:SetPos(selfpos+Vector(50,-50,0))
				npc:SetAngles(Angle(0,315,0))
				npc:SetKeyValue("citizentype","3")
				npc:SetKeyValue("Expression Type","Random")
				npc:SetKeyValue("additionalequipment","weapon_shotgun")
				npc:SetKeyValue("spawnflags",SF_CITIZEN_AMMORESUPPLIER)
				npc.JackyFinickyAmmoGiver=true
				npc:SetKeyValue("ammosupply","Buckshot")
				npc:SetKeyValue("ammoamount","6")
				npc.JackyOpSquadDrop={"item_box_buckshot"}
				npc:Spawn()
				npc:Activate()
				npc:SetKeyValue("SquadName",SquadName)
				npc.JackyDamageGroup=SquadName
				npc:Fire("startpatrolling","",math.Rand(30,60))
				JackyOpSquadSpawnEvent(npc)
				npc9=npc
			end)
			timer.Simple(0.45,function()
				local npc=ents.Create("npc_citizen")
				npc:SetPos(selfpos+Vector(100,0,0))
				npc:SetKeyValue("citizentype","1")
				npc:SetKeyValue("Expression Type","Random")
				npc:SetKeyValue("additionalequipment","weapon_pistol")
				npc:SetKeyValue("spawnflags",SF_CITIZEN_AMMORESUPPLIER)
				npc.JackyFinickyAmmoGiver=true
				npc:SetKeyValue("ammosupply","pistol")
				npc:SetKeyValue("ammoamount","18")
				npc:Spawn()
				npc:Activate()
				npc:SetKeyValue("SquadName",SquadName)
				npc.JackyDamageGroup=SquadName
				npc:Fire("startpatrolling","",math.Rand(30,60))
				JackyOpSquadSpawnEvent(npc)
				npc10=npc
			end)
			timer.Simple(0.5,function()
				local npc=ents.Create("npc_citizen")
				npc:SetPos(selfpos+Vector(100,100,0))
				npc:SetAngles(Angle(0,45,0))
				npc:SetKeyValue("citizentype","3")
				npc:SetKeyValue("Expression Type","Random")
				npc:SetKeyValue("additionalequipment","weapon_pistol")
				npc:SetKeyValue("spawnflags",SF_CITIZEN_AMMORESUPPLIER)
				npc.JackyFinickyAmmoGiver=true
				npc:SetKeyValue("ammosupply","Pistol")
				npc:SetKeyValue("ammoamount","18")
				npc.JackyOpSquadDrop={"item_ammo_pistol"}
				npc:Spawn()
				npc:Activate()
				npc:SetKeyValue("SquadName",SquadName)
				npc.JackyDamageGroup=SquadName
				npc:Fire("startpatrolling","",math.Rand(30,60))
				JackyOpSquadSpawnEvent(npc)
				npc11=npc
			end)
			timer.Simple(0.55,function()
				local npc=ents.Create("npc_citizen")
				npc:SetPos(selfpos+Vector(0,100,0))
				npc:SetAngles(Angle(0,90,0))
				npc:SetKeyValue("citizentype","1")
				npc:SetKeyValue("Expression Type","Random")
				npc:SetName("matt")
				npc:SetKeyValue("additionalequipment","weapon_crowbar")
				npc:SetKeyValue("spawnflags",SF_CITIZEN_AMMORESUPPLIER)
				npc.JackyFinickyAmmoGiver=true
				npc:SetKeyValue("ammosupply","Grenade")
				npc:SetKeyValue("ammoamount","1")
				npc.JackyOpSquadDrop={"weapon_frag"}
				npc:Spawn()
				npc:Activate()
				npc:SetKeyValue("SquadName",SquadName)
				npc.JackyDamageGroup=SquadName
				npc:Fire("startpatrolling","",math.Rand(30,60))
				npc:Fire("disableweaponpickup","",0)
				JackyOpSquadSpawnEvent(npc)
				npc12=npc
			end)
			timer.Simple(0.6,function()
				local npc=ents.Create("npc_citizen")
				npc:SetPos(selfpos+Vector(-100,100,0))
				npc:SetAngles(Angle(0,135,0))
				npc:SetKeyValue("citizentype","3")
				npc:SetKeyValue("Expression Type","Random")
				npc:SetKeyValue("additionalequipment","weapon_smg1")
				npc:SetKeyValue("spawnflags",SF_CITIZEN_AMMORESUPPLIER)
				npc.JackyFinickyAmmoGiver=true
				npc:SetKeyValue("ammosupply","SMG1_Grenade")
				npc:SetKeyValue("ammoamount","1")
				npc.JackyOpSquadDrop={"item_ammo_smg1","item_ammo_smg1_grenade"}
				npc:Spawn()
				npc:Activate()
				npc:SetKeyValue("SquadName",SquadName)
				npc.JackyDamageGroup=SquadName
				npc:Fire("startpatrolling","",math.Rand(30,60))
				JackyOpSquadSpawnEvent(npc)
				npc13=npc
			end)
			timer.Simple(0.65,function()
				local npc=ents.Create("npc_citizen")
				npc:SetPos(selfpos+Vector(-100,0,0))
				npc:SetAngles(Angle(0,180,0))
				npc:SetKeyValue("citizentype","1")
				npc:SetKeyValue("Expression Type","Random")
				npc:SetKeyValue("additionalequipment","weapon_pistol")
				npc:SetKeyValue("spawnflags",SF_CITIZEN_AMMORESUPPLIER)
				npc.JackyFinickyAmmoGiver=true
				npc:SetKeyValue("ammosupply","slam")
				npc:SetKeyValue("ammoamount","1")
				npc:Spawn()
				npc:Activate()
				npc:SetKeyValue("SquadName",SquadName)
				npc.JackyDamageGroup=SquadName
				npc:Fire("startpatrolling","",math.Rand(30,60))
				JackyOpSquadSpawnEvent(npc)
				npc14=npc
			end)
			timer.Simple(0.7,function()
				local npc=ents.Create("npc_citizen")
				npc:SetPos(selfpos+Vector(-100,-100,0))
				npc:SetAngles(Angle(0,225,0))
				npc:SetKeyValue("citizentype","3")
				npc:SetKeyValue("Expression Type","Random")
				npc:SetKeyValue("additionalequipment","weapon_pistol")
				npc:SetKeyValue("spawnflags",SF_CITIZEN_AMMORESUPPLIER)
				npc.JackyFinickyAmmoGiver=true
				npc:SetKeyValue("ammosupply","Pistol")
				npc:SetKeyValue("ammoamount","18")
				npc.JackyOpSquadDrop={"item_ammo_pistol"}
				npc:Spawn()
				npc:Activate()
				npc:SetKeyValue("SquadName",SquadName)
				npc.JackyDamageGroup=SquadName
				npc:Fire("startpatrolling","",math.Rand(30,60))
				JackyOpSquadSpawnEvent(npc)
				npc15=npc
			end)
			timer.Simple(0.75,function()
				local npc=ents.Create("npc_citizen")
				npc:SetPos(selfpos+Vector(0,-100,0))
				npc:SetAngles(Angle(0,270,0))
				npc:SetKeyValue("citizentype","1")
				npc:SetKeyValue("Expression Type","Random")
				npc:SetName("matt")
				npc:SetKeyValue("additionalequipment","weapon_crossbow")
				npc.JackyOpSquadDrop={"item_ammo_crossbow"}
				npc:SetKeyValue("spawnflags",SF_CITIZEN_AMMORESUPPLIER)
				npc.JackyFinickyAmmoGiver=true
				npc:SetKeyValue("ammosupply","XBowBolt")
				npc:SetKeyValue("ammoamount","1")
				npc:Spawn()
				npc:Activate()
				npc:SetKeyValue("SquadName",SquadName)
				npc.JackyDamageGroup=SquadName
				npc:Fire("startpatrolling","",math.Rand(30,60))
				npc:Fire("disableweaponpickup","",0)
				JackyOpSquadSpawnEvent(npc)
				npc16=npc
			end)
			timer.Simple(0.8,function()
				local npc=ents.Create("npc_citizen")
				npc:SetPos(selfpos+Vector(100,-100,0))
				npc:SetAngles(Angle(0,315,0))
				npc:SetKeyValue("citizentype","3")
				npc:SetKeyValue("Expression Type","Random")
				npc:SetKeyValue("additionalequipment","weapon_smg1")
				npc:SetKeyValue("spawnflags",SF_CITIZEN_AMMORESUPPLIER)
				npc.JackyFinickyAmmoGiver=true
				npc:SetKeyValue("ammosupply","SMG1")
				npc:SetKeyValue("ammoamount","45")
				npc.JackyOpSquadDrop={"item_ammo_smg1","item_ammo_smg1_grenade"}
				npc:Spawn()
				npc:Activate()
				npc:SetKeyValue("SquadName",SquadName)
				npc.JackyDamageGroup=SquadName
				npc:Fire("startpatrolling","",math.Rand(30,60))
				JackyOpSquadSpawnEvent(npc)
				npc17=npc
			end)
			timer.Simple(0.85,function()
				undo.Create("Human Opposition Squad")
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
				undo.SetCustomUndoText("Undone Human Opposition Squad")
				undo.Finish()
			end)
		end)
	end
	JackieNPCSpawningTable.Enhanced["Rocket Rebel"]=function(selfpos)
		local npc=ents.Create("npc_citizen")
		npc:SetPos(selfpos)
		npc:SetKeyValue("citizentype","3")
		npc:SetKeyValue("Expression Type","Random")
		npc:SetKeyValue("additionalequipment","wep_jack_npcrocketlauncher")
		npc:SetCurrentWeaponProficiency(WEAPON_PROFICIENCY_PERFECT) --but gosh damn do they suck giant horse schlong at shooting things with their RPG
		npc:SetKeyValue("spawnflags","524544") --256+524288(SF_CITIZEN_AMMORESUPPLIER)
		npc.JackyFinickyAmmoGiver=true
		npc:SetKeyValue("ammosupply","RPG_Round")
		npc:SetKeyValue("ammoamount","1")
		npc:Spawn()
		npc:Activate()
		npc:SetKeyValue("SquadName",SquadName)
		npc.JackyDamageGroup=SquadName
		npc.JackyOpSquadDrop={"item_rpg_round"}
		npc:Fire("disableweaponpickup","",0)
		npc:Fire("startpatrolling","",math.Rand(30,60))
		npc:Fire("addoutput","onplayeruse !self,startpatrolling,"..tostring(npc).."0",0)
		npc:Fire("setammoresupplieroff","",0)
		JackyOpSquadSpawnEvent(npc)
		return npc
	end
	JackieNPCSpawningTable.Enhanced["Ammo Rebel"]=function(selfpos)
		local npc=ents.Create("npc_citizen")
		npc:SetPos(selfpos)
		npc:SetAngles(Angle(0,0,0))
		npc:SetKeyValue("citizentype","3")
		npc:SetKeyValue("Expression Type","Random")
		npc:SetKeyValue("additionalequipment","weapon_smg1")
		npc:SetKeyValue("spawnflags",SF_CITIZEN_AMMORESUPPLIER)
		npc.JackyFinickyAmmoGiver=true
		npc:SetKeyValue("ammosupply","SMG1")
		npc:SetKeyValue("ammoamount","45")
		npc.JackyOpSquadDrop={"item_ammo_smg1","item_ammo_smg1_grenade"}
		npc:Spawn()
		npc:Activate()
		npc:SetKeyValue("SquadName",SquadName)
		npc.JackyDamageGroup=SquadName
		npc:Fire("startpatrolling","",math.Rand(30,60))
		JackyOpSquadSpawnEvent(npc)
		return npc
	end
end