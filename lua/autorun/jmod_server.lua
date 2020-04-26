AddCSLuaFile("jmod_shared.lua")
AddCSLuaFile("jmod_shared_armor.lua")
AddCSLuaFile("jmod_client_armor.lua")
AddCSLuaFile("jmod_client_gui.lua")
AddCSLuaFile("jmod_client_hud.lua")
AddCSLuaFile("jmod_client.lua")
include("jmod_shared.lua")
include("jmod_shared_armor.lua")
include("jmod_server_armor.lua")
include("jmod_server_utility.lua")
include("jmod_server_radio.lua")
if(SERVER)then
	util.AddNetworkString("JMod_Friends") -- ^:3
	util.AddNetworkString("JMod_MineColor")
	util.AddNetworkString("JMod_EZbuildKit")
	util.AddNetworkString("JMod_EZworkbench")
	util.AddNetworkString("JMod_Hint")
	util.AddNetworkString("JMod_EZtimeBomb")
	util.AddNetworkString("JMod_UniCrate")
	util.AddNetworkString("JMod_LuaConfigSync")
	util.AddNetworkString("JMod_PlayerSpawn")
	util.AddNetworkString("JMod_SignalNade")
	util.AddNetworkString("JMod_ModifyMachine")
	util.AddNetworkString("JMod_NuclearBlast")
	local function JackaSpawnHook(ply)
		ply.JModFriends=ply.JModFriends or {}
		ply.EZarmor={
			slots={},
			maskOn=true,
			headsetOn=true,
			speedFrac=nil,
			Effects={}
		}
		JModEZarmorSync(ply)
		ply.EZhealth=nil
		ply.EZirradiated=nil
		net.Start("JMod_PlayerSpawn")
		net.WriteBit(JMOD_CONFIG.Hints)
		net.Send(ply)
	end
	hook.Add("PlayerSpawn","JackaSpawnHook",JackaSpawnHook)
	hook.Add("GetPreferredCarryAngles","JMOD_PREFCARRYANGS",function(ent)
		if(ent.JModPreferredCarryAngles)then return ent.JModPreferredCarryAngles end
	end)
	--- NO U ---
	concommand.Add("jmod_friends",function(ply)
		net.Start("JMod_Friends")
		net.WriteBit(false)
		net.WriteTable(ply.JModFriends or {})
		net.Send(ply)
	end)
	net.Receive("JMod_Friends",function(length,ply)
		local List,Good=net.ReadTable(),true
		for k,v in pairs(List)do
			if not((IsValid(v))and(v:IsPlayer()))then Good=false end
		end
		if(Good)then
			ply.JModFriends=List
			ply:PrintMessage(HUD_PRINTCENTER,"JMod EZ friends list updated")
			net.Start("JMod_Friends")
			net.WriteBit(true)
			net.WriteEntity(ply)
			net.WriteTable(List)
			net.Broadcast()
		else
			ply.JModFriends={}
		end
	end)
	concommand.Add("jmod_reloadconfig",function(ply)
		if((IsValid(ply))and not(ply:IsSuperAdmin()))then return end
		JMod_InitGlobalConfig()
	end)
	concommand.Add("jmod_resetconfig",function(ply)
		if((IsValid(ply))and not(ply:IsSuperAdmin()))then return end
		JMod_InitGlobalConfig(true)
	end)
	local NextMainThink,NextNutritionThink,NextArmorThink,NextSync=0,0,0,0
	hook.Add("Think","JMOD_SERVER_THINK",function()
		local Time=CurTime()
		if(NextMainThink>Time)then return end
		NextMainThink=Time+1
		---
		for k,playa in pairs(player.GetAll())do
			local Alive=playa:Alive()
			if((playa.EZhealth)and(Alive))then
				local Healin=playa.EZhealth
				if(Healin>0)then
					local Amt=1
					if(math.random(1,3)==2)then Amt=2 end
					playa.EZhealth=Healin-Amt
					local Helf,Max=playa:Health(),playa:GetMaxHealth()
					if(Helf<Max)then
						playa:SetHealth(math.Clamp(Helf+Amt,0,Max))
						if(playa:Health()==Max)then playa:RemoveAllDecals() end
					end
				end
			end
			if((playa.EZirradiated)and(Alive))then
				local Rads=playa.EZirradiated
				if((Rads>0)and(math.random(1,3)==1))then
					playa.EZirradiated=math.Clamp(Rads-.5,0,9e9)
					local Helf,Max=playa:Health(),playa:GetMaxHealth()
					local Dmg=DamageInfo()
					Dmg:SetAttacker(playa)
					Dmg:SetInflictor(game.GetWorld())
					Dmg:SetDamage(1)
					Dmg:SetDamageType(DMG_GENERIC)
					Dmg:SetDamagePosition(playa:GetShootPos())
					playa:TakeDamageInfo(Dmg)
					JMod_Hint(playa,"radsickness")
				end
			end
		end
		---
		if(NextNutritionThink<Time)then
			NextNutritionThink=Time+10/JMOD_CONFIG.FoodSpecs.DigestSpeed
			for k,playa in pairs(player.GetAll())do
				if(playa.EZnutrition)then
					if(playa:Alive())then
						local Nuts=playa.EZnutrition.Nutrients
						if(Nuts>0)then
							playa.EZnutrition.Nutrients=Nuts-1
							local Helf,Max,Nuts=playa:Health(),playa:GetMaxHealth()
							if(Helf<Max)then
								playa:SetHealth(Helf+1)
								if(playa:Health()==Max)then playa:RemoveAllDecals() end
							elseif(math.Rand(0,1)<.75)then
								local BoostMult=JMOD_CONFIG.FoodSpecs.BoostMult
								local BoostedFrac=(Helf-Max)/Max
								if(math.Rand(0,1)>BoostedFrac)then
									playa:SetHealth(Helf+BoostMult)
									if(playa:Health()>=Max)then playa:RemoveAllDecals() end
								end
							end
						end
					end
				end
			end
		end
		---
		if(NextArmorThink<Time)then
			NextArmorThink=Time+10
			for k,playa in pairs(player.GetAll())do
				if((playa.EZarmor)and(playa:Alive()))then
					if(playa.EZarmor.Effects.nightVision)then
						for slot,slotInfo in pairs(playa.EZarmor.slots)do
							local Info=JMod_ArmorTable[slot][slotInfo[1]]
							if((Info.eff)and(table.HasValue(Info.eff,"nightVision")))then
								JMod_DamageArmor(playa,slot,.5)
							end
						end
					elseif(playa.EZarmor.Effects.thermalVision)then
						for slot,slotInfo in pairs(playa.EZarmor.slots)do
							local Info=JMod_ArmorTable[slot][slotInfo[1]]
							if((Info.eff)and(table.HasValue(Info.eff,"thermalVision")))then
								JMod_DamageArmor(playa,slot,.5)
							end
						end
					end
					JModEZarmorSync(playa)
				end
			end
		end
		---
		if(NextSync<Time)then
			NextSync=Time+30
			net.Start("JMod_LuaConfigSync")
			net.WriteTable((JMOD_LUA_CONFIG and JMOD_LUA_CONFIG.ArmorOffsets) or {})
			net.Broadcast()
		end
	end)
	hook.Add("DoPlayerDeath","JMOD_SERVER_PLAYERDEATH",function(ply)
		ply.EZnutrition=nil
		ply.EZhealth=nil
		ply.EZkillme=nil
	end)
	hook.Add("PlayerLeaveVehicle","JMOD_LEAVEVEHICLE",function(ply,veh)
		if(veh.EZvehicleEjectPos)then
			local WorldPos=veh:LocalToWorld(veh.EZvehicleEjectPos)
			ply:SetPos(WorldPos)
			veh.EZvehicleEjectPos=nil
		end
	end)
	concommand.Add("jmod_ez_mask",function(ply,cmd,args)
		JMod_EZ_Toggle_Mask(ply)
	end)
	concommand.Add("jmod_ez_headset",function(ply,cmd,args)
		JMod_EZ_Toggle_Headset(ply)
	end)
	concommand.Add("jmod_ez_bombdrop",function(ply,cmd,args)
		JMod_EZ_BombDrop(ply)
	end)
	concommand.Add("jmod_ez_launch",function(ply,cmd,args)
		JMod_EZ_WeaponLaunch(ply)
	end)
	local SERVER_JMOD_HINT_GIVEN=false
	hook.Add("PlayerInitialSpawn","JMOD_INITIALSPAWN",function(ply)
		if((JMOD_CONFIG)and(JMOD_CONFIG.Hints)and not(SERVER_JMOD_HINT_GIVEN))then
			SERVER_JMOD_HINT_GIVEN=true
			timer.Simple(10,function()
				if(ply)then JMod_Hint(ply,"customize") end
			end)
		end
	end)
	concommand.Add("jmod_debug_killme",function(ply)
		if not(IsValid(ply))then return end
		if not(GetConVar("sv_cheats"):GetBool())then return end
		ply.EZkillme=true
		ply:PrintMessage(HUD_PRINTCENTER,"good luck")
	end)
	concommand.Add("jmod_ez_trigger",function(ply)
		JMod_EZ_Remote_Trigger(ply)
	end)
	concommand.Add("jmod_insta_upgrade",function(ply)
		if not(IsValid(ply))then return end
		if not(ply:IsSuperAdmin())then return end
		local Ent=ply:GetEyeTrace().Entity
		if((IsValid(Ent))and(Ent.EZupgrades)and(Ent.Upgrade))then
			Ent:Upgrade()
		end
	end)
	concommand.Add("jmod_ez_armor",function(ply,cmd,args)
		if not((IsValid(ply))and(ply:Alive()))then return end
		JMod_EZ_Remove_Armor(ply)
	end)
	function JMod_EZ_Remote_Trigger(ply)
		if not(IsValid(ply))then return end
		if not(ply:Alive())then return end
		sound.Play("snd_jack_detonator.wav",ply:GetShootPos(),55,math.random(90,110))
		timer.Simple(.75,function()
			if((IsValid(ply))and(ply:Alive()))then
				for k,v in pairs(ents.GetAll())do
					if((v.JModEZremoteTriggerFunc)and(v.Owner)and(v.Owner==ply))then
						v:JModEZremoteTriggerFunc(ply)
					end
				end
			end
		end)
	end
	net.Receive("JMod_MineColor",function(ln,ply)
		if not((IsValid(ply))and(ply:Alive()))then return end
		local Mine=net.ReadEntity()
		local Col=net.ReadColor()
		local Arm=tobool(net.ReadBit())
		if not(IsValid(Mine))then return end
		Mine:SetColor(Col)
		if(Arm)then Mine:Arm(ply) end
	end)
	net.Receive("JMod_ArmorColor",function(ln,ply)
		if not((IsValid(ply))and(ply:Alive()))then return end
		local Armor=net.ReadEntity()
		local Col=net.ReadColor()
		local Equip=tobool(net.ReadBit())
		if not(IsValid(Armor))then return end
		Armor:SetColor(Col)
		if(Equip)then JMod_EZ_Equip_Armor(ply,Armor) end
	end)
	net.Receive("JMod_SignalNade",function(ln,ply)
		if not((IsValid(ply))and(ply:Alive()))then return end
		local Nade=net.ReadEntity()
		local Col=net.ReadColor()
		local Arm=tobool(net.ReadBit())
		if not(IsValid(Nade))then return end
		Nade:SetColor(Col)
		if(Arm)then Nade:Prime() end
	end)
	net.Receive("JMod_EZbuildKit",function(ln,ply)
		local Num,Wep=net.ReadInt(8),ply:GetWeapon("wep_jack_gmod_ezbuildkit")
		if(IsValid(Wep))then
			Wep:SwitchSelectedBuild(Num)
		end
	end)
	net.Receive("JMod_EZworkbench",function(ln,ply)
		local Bench,Name=net.ReadEntity(),net.ReadString()
		if((IsValid(Bench))and(ply:Alive()))then
			if(ply:GetPos():Distance(Bench:GetPos())<200)then
				Bench:TryBuild(Name,ply)
			end
		end
	end)
	net.Receive("JMod_EZtimeBomb",function(ln,ply)
		local ent=net.ReadEntity()
		local tim=net.ReadInt(16)
		if((ent:GetState()==0)and(ent.Owner==ply)and(ply:Alive())and(ply:GetPos():Distance(ent:GetPos())<=150))then
			ent:SetTimer(math.min(tim,600))
			ent.DisarmNeeded=math.min(tim,600)/2
			ent:NextThink(CurTime()+1)
			ent:SetState(1)
			ent:EmitSound("weapons/c4/c4_plant.wav",60,120)
			ent:EmitSound("snd_jack_minearm.wav",60,100)
		end
	end)
	net.Receive("JMod_UniCrate",function(ln,ply)
		local box=net.ReadEntity()
		local class=net.ReadString()
		if !IsValid(box) or (box:GetPos() - ply:GetPos()):Length()>100 or not box.Items[class] or box.Items[class][1] <= 0 then return end
		local ent=ents.Create(class)
		ent:SetPos(box:GetPos())
		ent:SetAngles(box:GetAngles())
		ent:Spawn()
		ent:Activate()
		timer.Simple(0.01, function() ply:PickupObject(ent) end)
		box:SetItemCount(box:GetItemCount() - box.Items[class][2])
		box.Items[class] = box.Items[class][1] > 1 and {(box.Items[class][1] - 1), box.Items[class][2]} or nil
		box.NextLoad = CurTime() + 2
		box:EmitSound("Ammo_Crate.Close")
		box:CalcWeight()
	end)
	net.Receive("JMod_ModifyMachine",function(ln,ply)
		if not(ply:Alive())then return end
		local AmmoType=nil
		local Ent,Tbl,HasAmmoType=net.ReadEntity(),net.ReadTable(),tobool(net.ReadBit())
		if(HasAmmoType)then AmmoType=net.ReadString() end
		if not(IsValid(Ent))then return end
		if not(Ent:GetPos():Distance(ply:GetPos())<200)then return end
		local Wepolini=ply:GetActiveWeapon()
		if not((Wepolini)and(Wepolini.ModifyMachine))then return end
		Wepolini:ModifyMachine(Ent,Tbl,AmmoType)
	end)
	hook.Add("PlayerCanSeePlayersChat","JMOD_PLAYERSEECHAT",function(txt,teamOnly,listener,talker)
		if((talker.EZarmor)and(talker.EZarmor.Effects.teamComms))then
			return JMod_PlayersCanComm(listener,talker)
		end
	end)
	hook.Add("PlayerCanHearPlayersVoice","JMOD_PLAYERHEARVOICE",function(listener,talker)
		if((talker.EZarmor)and(talker.EZarmor.Effects.teamComms))then
			return JMod_PlayersCanComm(listener,talker)
		end
	end)
end
