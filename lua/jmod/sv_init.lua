local force_workshop = CreateConVar("jmod_forceworkshop", 1, {FCVAR_ARCHIVE}, "Force clients to download JMod + its content? (requires a restart upon change)")

if force_workshop:GetBool() then
    resource.AddWorkshop("1919689921")
end

local function JackaSpawnHook(ply)
	ply.JModSpawnTime=CurTime()
	ply.JModFriends=ply.JModFriends or {}
	if(ply.EZarmor and ply.EZarmor.suited)then
		ply:SetColor(Color(255,255,255))
	end
	ply.EZarmor={
		items={},
		speedFrac=nil,
		effects={},
		mskmat=nil,
		sndlop=nil,
		suited=false,
		bodygroups=nil
	}
	JMod.EZarmorSync(ply)
	ply.EZhealth=nil
	ply.EZirradiated=nil
	ply.EZoxygen=100
	ply.EZbleeding=0
	ply.EZvirus=nil
	timer.Simple(0,function()
		if(IsValid(ply))then
			ply.EZoriginalPlayerModel=ply:GetModel()
		end
	end)
	net.Start("JMod_PlayerSpawn")
	net.WriteBit(JMod.Config.Hints)
	net.Send(ply)
end
hook.Add("PlayerSpawn","JMod_PlayerSpawn",JackaSpawnHook)
hook.Add("PlayerInitialSpawn","JMod_PlayerInitialSpawn",JackaSpawnHook)

function JMod.SyncBleeding(ply)
	net.Start("JMod_Bleeding")
	net.WriteInt(ply.EZbleeding,8)
	net.Send(ply)
end

hook.Add("PlayerLoadout","JMod_PlayerLoadout",function(ply)
	if((JMod.Config)and(JMod.Config.QoL.GiveHandsOnSpawn))then
		ply:Give("wep_jack_gmod_hands")
	end
end)

hook.Add("GetPreferredCarryAngles","JMOD_PREFCARRYANGS",function(ent)
	if(ent.JModPreferredCarryAngles)then return ent.JModPreferredCarryAngles end
end)

hook.Add("AllowPlayerPickup","JMOD_PLAYERPICKUP",function(ply,ent)
	if(ent.JModNoPickup)then return false end
end)

local function ShouldVirusInfect(ent)
	if not(IsValid(ent))then return false end
	if(ent.EZvirus and ent.EZvirus.Immune)then return false end
	if(ent:IsPlayer())then return ent:Alive() end
	if(ent:IsNPC())then return string.find(ent:GetClass(),"citizen") end
	return false
end

local function VirusHostCanSee(host,ent)
	local Tr=util.TraceLine({
		start=host:GetPos(),
		endpos=ent:GetPos(),
		filter={host,ent},
		mask=MASK_SHOT
	})
	return not Tr.Hit
end

function JMod.ViralInfect(ply,att)
	if(ply.EZvirus)then return end
	if(((ply.JModSpawnTime or 0)+30)>CurTime())then return end
	local Severity,Latency=math.random(50,500),math.random(10,100)
	ply.EZvirus={
		Severity=Severity,
		NextCough=CurTime()+Latency,
		InfectionWarned=false,
		Immune=false,
		Attacker=(IsValid(att) and att) or game.GetWorld(),
		NextFoodImmunityBoost=0,
		NextAntibioticsImmunityBoost=0
	}
end

function JMod.TryVirusInfectInRange(host,att,hostFaceProt,hostSkinProt)
	local Range,SelfPos=300*JMod.Config.VirusSpreadMult,host:GetPos()
	if(hostFaceProt>0 or hostSkinProt>0)then
		Range=Range*(1-(hostFaceProt+hostSkinProt)/2)
	end
	if(Range<=0)then return end
	for key,obj in pairs(ents.FindInSphere(SelfPos,Range))do
		if(not(obj==host)and(VirusHostCanSee(host,obj))and(ShouldVirusInfect(obj)))then
			local DistFrac=1-(obj:GetPos():Distance(SelfPos)/(Range*1.2))
			local Chance=DistFrac*.2
			if(obj:WaterLevel()>=3)then Chance=Chance/3 end
			---
			local VictimFaceProtection,VictimSkinProtection=JMod.GetArmorBiologicalResistance(obj,DMG_RADIATION)
			if(VictimFaceProtection>0 or VictimSkinProtection>0)then
				Chance=Chance*(1-(VictimFaceProtection+VictimSkinProtection)/2)
			end
			if(Chance>0)then
				local AAA=math.Rand(0,1)
				if(AAA<Chance)then
					JMod.ViralInfect(obj,att)
				end
			end
		end
	end
end

local function VirusCough(ply)
	if(math.random(1,10)==2)then JMod.TryCough(ply) end
	local Dmg=DamageInfo()
	Dmg:SetDamageType(DMG_GENERIC) -- why aint this working to hazmat wearers?
	Dmg:SetAttacker((IsValid(ply.EZvirus.Attacker) and ply.EZvirus.Attacker)or game.GetWorld())
	Dmg:SetInflictor(ply)
	Dmg:SetDamagePosition(ply:GetPos())
	Dmg:SetDamageForce(Vector(0,0,0))
	Dmg:SetDamage(1)
	ply:TakeDamageInfo(Dmg)
	--
	local HostFaceProtection,HostSkinProtection=JMod.GetArmorBiologicalResistance(ply,DMG_RADIATION)
	if((HostFaceProtection+HostSkinProtection)>=2)then return end
	JMod.TryVirusInfectInRange(ply,ply.EZvirus.Attacker,HostFaceProtection,HostSkinProtection)
	if(math.random(1,10)==10)then
		local Gas=ents.Create("ent_jack_gmod_ezvirusparticle")
		Gas:SetPos(ply:GetPos())
		JMod.Owner(Gas,ply)
		Gas:Spawn()
		Gas:Activate()
		Gas:GetPhysicsObject():SetVelocity(ply:GetVelocity())
	end
end

local function VirusHostThink(dude)
	local Time=CurTime()
	if(dude.EZvirus and not dude.EZvirus.Immune and dude.EZvirus.NextCough<Time)then
		dude.EZvirus.NextCough=Time+math.Rand(.5,2)
		if not(dude.EZvirus.InfectionWarned)then
			dude.EZvirus.InfectionWarned=true
			if(dude.PrintMessage)then dude:PrintMessage(HUD_PRINTTALK,"You've contracted the JMod virus. Get medical attention, eat food, and avoid contact with others.") end
		end
		VirusCough(dude)
		dude.EZvirus.Severity=math.Clamp(dude.EZvirus.Severity-1,0,9e9)
		if(dude.EZvirus.Severity<=0)then
			dude.EZvirus.Immune=true
			if(dude.PrintMessage)then dude:PrintMessage(HUD_PRINTTALK,"You are now immune to the JMod virus.") end
		end
	end
end

local NextMainThink,NextNutritionThink,NextArmorThink,NextSlowThink,NextSync=0,0,0,0,0
hook.Add("Think","JMOD_SERVER_THINK",function()
	--[[
	local Pos=ents.FindByClass("sky_camera")[1]:GetPos()
	local AAA=util.TraceLine({
		start=Pos+Vector(0,0,1000),
		endpos=player.GetAll()[1]:GetShootPos()+Vector(0,0,100),
		filter=player.GetAll()[1]
	})
	if(AAA.Hit)then jprint("VALID") else jprint("INVALID") end
	--]]
	local Time=CurTime()
	if(NextMainThink>Time)then return end
	NextMainThink=Time+1
	---
	for k,playa in pairs(player.GetAll())do
		local Alive=playa:Alive()
		if(Alive)then
			if(playa.EZhealth)then
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
			if(playa.EZbleeding)then
				local Bleed=playa.EZbleeding
				if(Bleed>0)then
					local Amt=JMod.Config.QoL.BleedSpeedMult
					playa.EZbleeding=math.Clamp(Bleed-Amt,0,9e9)
					local Dmg=DamageInfo()
					Dmg:SetAttacker((IsValid(playa.EZbleedAttacker) and playa.EZbleedAttacker) or game.GetWorld())
					Dmg:SetInflictor(game.GetWorld())
					Dmg:SetDamage(Amt)
					Dmg:SetDamageType(DMG_GENERIC)
					Dmg:SetDamagePosition(playa:GetShootPos())
					playa:TakeDamageInfo(Dmg)
					net.Start("JMod_SFX")
					net.WriteString("snds_jack_gmod/quiet_heartbeat.wav")
					net.Send(playa)
					JMod.Hint(playa,"bleeding")
					--
					local Tr=util.QuickTrace(playa:GetShootPos()+VectorRand()*30,Vector(0,0,-150),playa)
					if(Tr.Hit)then
						util.Decal("Blood",Tr.HitPos+Tr.HitNormal,Tr.HitPos-Tr.HitNormal)
					end
				end
			end
			if(playa.EZirradiated)then
				local Rads=playa.EZirradiated
				if((Rads>0)and(math.random(1,3)==1))then
					playa.EZirradiated=math.Clamp(Rads-.5,0,9e9)
					local Dmg=DamageInfo()
					Dmg:SetAttacker(playa)
					Dmg:SetInflictor(game.GetWorld())
					Dmg:SetDamage(1)
					Dmg:SetDamageType(DMG_GENERIC)
					Dmg:SetDamagePosition(playa:GetShootPos())
					playa:TakeDamageInfo(Dmg)
				end
			end
			VirusHostThink(playa)
			if(JMod.Config.QoL.Drowning)then
				if(playa:WaterLevel()>=3)then
					playa.EZoxygen=math.Clamp(playa.EZoxygen-1.67,0,100) -- 60 seconds before damage
					if(playa.EZoxygen<=25)then playa.EZneedGasp=true end
					if(playa.EZoxygen<=0)then
						local Dmg=DamageInfo()
						Dmg:SetDamageType(DMG_DROWN)
						Dmg:SetDamage(5)
						Dmg:SetAttacker(playa)
						Dmg:SetInflictor(game.GetWorld())
						Dmg:SetDamagePosition(playa:GetPos())
						Dmg:SetDamageForce(Vector(0,0,0))
						playa:TakeDamageInfo(Dmg)
					end
				elseif(playa.EZoxygen<100)then
					if(playa.EZneedGasp)then
						sound.Play("snds_jack_gmod/drown_gasp.wav",playa:GetShootPos(),60,math.random(90,110))
						playa.EZneedGasp=false
					end
					playa.EZoxygen=math.Clamp(playa.EZoxygen+25,0,100) -- recover in 4 seconds
				end
			end
		end
	end
	---
	if(NextNutritionThink<Time)then
		NextNutritionThink=Time+10/JMod.Config.FoodSpecs.DigestSpeed
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
							local BoostMult=JMod.Config.FoodSpecs.BoostMult
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
		NextArmorThink=Time+2
		for k,playa in pairs(player.GetAll())do
			if((playa.EZarmor)and(playa:Alive()))then
				if(playa.EZarmor.effects.nightVision)then
					for id,armorData in pairs(playa.EZarmor.items)do
						local Info=JMod.ArmorTable[armorData.name]
						if((Info.eff)and(Info.eff.nightVision))then
							armorData.chrg.power=math.Clamp(armorData.chrg.power-JMod.Config.ArmorChargeDepletionMult/10,0,9e9)
							if(armorData.chrg.power<=Info.chrg.power*.25)then JMod.EZarmorWarning(playa,"armor's electricity soon to be depleted!") end
						end
					end
				elseif(playa.EZarmor.effects.thermalVision)then
					for id,armorData in pairs(playa.EZarmor.items)do
						local Info=JMod.ArmorTable[armorData.name]
						if((Info.eff)and(Info.eff.thermalVision))then
							armorData.chrg.power=math.Clamp(armorData.chrg.power-JMod.Config.ArmorChargeDepletionMult/10,0,9e9)
							if(armorData.chrg.power<=Info.chrg.power*.25)then JMod.EZarmorWarning(playa,"armor's electricity soon to be depleted!") end
						end
					end
				end
				JMod.CalcSpeed(playa)
				JMod.EZarmorSync(playa)
			end
		end
	end
	---
	if(NextSlowThink<Time)then
		NextSlowThink=Time+2
		if(JMod.Config.QoL.ExtinguishUnderwater)then
			for k,v in pairs(ents.GetAll())do
				if((v.IsOnFire)and(v.WaterLevel))then
					if((v:IsOnFire())and(v:WaterLevel()>=3))then
						v:Extinguish()
					end
				end
			end
		end
	end
	---
	for k,v in pairs(ents.FindByClass("npc_*"))do
		VirusHostThink(v)
		if(v.EZNPCincapacitate)then
			if(v.EZNPCincapacitate>Time)then
				if not(v.EZNPCincapacitated)then
					v:SetNPCState(NPC_STATE_PLAYDEAD)
					v.EZNPCincapacitated=true
				end
			elseif(v.EZNPCincapacitated)then
				v:SetNPCState(NPC_STATE_ALERT)
				v.EZNPCincapacitated=false
			end
		end
	end
	---
	if(NextSync<Time)then
		NextSync=Time+30
		net.Start("JMod_LuaConfigSync")
		net.WriteTable((JMod.LuaConfig and JMod.LuaConfig.ArmorOffsets) or {})
		net.WriteInt(JMod.Config.AltFunctionKey,32)
		net.WriteFloat(JMod.Config.WeaponSwayMult)
		net.WriteBit(false)
		net.Broadcast()
	end
end)

concommand.Add("jmod_force_lua_config_sync",function(ply,cmd,args)
	if(ply and not ply:IsSuperAdmin())then return end
	net.Start("JMod_LuaConfigSync")
	net.WriteTable((JMod.LuaConfig and JMod.LuaConfig.ArmorOffsets) or {})
	net.WriteInt(JMod.Config.AltFunctionKey,32)
	net.WriteFloat(JMod.Config.WeaponSwayMult)
	net.WriteBit(true)
	net.Broadcast()
end)

concommand.Add("jacky_trace_debug",function(ply)
	if not(GetConVar("sv_cheats"):GetBool())then return end
	local Tr=ply:GetEyeTrace()
	print("--------- trace results ----------")
	PrintTable(Tr)
	local Props=util.GetSurfaceData(Tr.SurfaceProps)
	if(Props)then
		print("----------- surface properties ----------")
		PrintTable(Props)
	end
	print("---------- end trace debug -----------")
end)

concommand.Add("jacky_player_debug",function(ply,cmd,args)
	if not(GetConVar("sv_cheats"):GetBool())then return end
	if not(ply:IsSuperAdmin())then return end
	for k,v in pairs(player.GetAll())do
		if(v~=ply)then
			v:SetPos(ply:GetPos()+Vector(100*k,0,0))
			v:SetHealth(100)
		end
	end
end)

hook.Add("GetFallDamage","JMod_FallDamage",function(ply,spd)
	if(JMod.Config.QoL.RealisticFallDamage)then
		return spd^2/8000
	end
end)

hook.Add("DoPlayerDeath","JMOD_SERVER_PLAYERDEATH",function(ply)
	ply.EZnutrition=nil
	ply.EZhealth=nil
	ply.EZkillme=nil
	if(ply.JackyMatDeathUnset)then ply.JackyMatDeathUnset=false;ply:SetMaterial("") end
end)

hook.Add("PlayerLeaveVehicle","JMOD_LEAVEVEHICLE",function(ply,veh)
	if(veh.EZvehicleEjectPos)then
		local WorldPos=veh:LocalToWorld(veh.EZvehicleEjectPos)
		ply:SetPos(WorldPos)
		veh.EZvehicleEjectPos=nil
	end
end)

function JMod.EZ_Remote_Trigger(ply)
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

hook.Add("PlayerCanSeePlayersChat","JMOD_PLAYERSEECHAT",function(txt,teamOnly,listener,talker)
	if((talker.EZarmor)and(talker.EZarmor.effects.teamComms))then
		return JMod.PlayersCanComm(listener,talker)
	end
end)

hook.Add("PlayerCanHearPlayersVoice","JMOD_PLAYERHEARVOICE",function(listener,talker)
	if((talker.EZarmor)and(talker.EZarmor.effects.teamComms))then
		return JMod.PlayersCanComm(listener,talker)
	end
end)

