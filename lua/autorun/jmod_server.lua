include("jmod_shared.lua")
if(SERVER)then
	util.AddNetworkString("JMod_Friends") -- ^:3
	util.AddNetworkString("JMod_MineColor")
	util.AddNetworkString("JMod_ArmorColor")
	util.AddNetworkString("JMod_EZbuildKit")
	util.AddNetworkString("JMod_EZworkbench")
	util.AddNetworkString("JMod_Hint")
	util.AddNetworkString("JMod_EZtimeBomb")
	util.AddNetworkString("JMod_UniCrate")
	util.AddNetworkString("JMod_EZarmorSync")
	util.AddNetworkString("JMod_LuaConfigSync")
	util.AddNetworkString("JMod_PlayerSpawn")
	util.AddNetworkString("JMod_SignalNade")
	util.AddNetworkString("JMod_ModifyMachine")
	util.AddNetworkString("JMod_NuclearBlast")
	function JModEZarmorSync(ply)
		if not(ply.EZarmor)then return end
		ply.EZarmor.Effects={}
		for slot,info in pairs(ply.EZarmor.slots)do
			local Disabled=false
			if((slot=="Ears")and not(ply.EZarmor.headsetOn))then Disabled=true end
			if((slot=="Face")and not(ply.EZarmor.maskOn))then Disabled=true end
			if not(Disabled)then
				local Info=JMod_ArmorTable[slot][info[1]]
				if(Info.eff)then
					for k,eff in pairs(Info.eff)do
						ply.EZarmor.Effects[eff]=true
					end
				end
			end
		end
		net.Start("JMod_EZarmorSync")
		net.WriteEntity(ply)
		net.WriteTable(ply.EZarmor)
		net.Broadcast()
	end
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
	local MaxArmorProtection={
		[DMG_BULLET]=.9,[DMG_BLAST]=.9,[DMG_CLUB]=.9,[DMG_SLASH]=.9,[DMG_BURN]=.5,[DMG_CRUSH]=.6,[DMG_VEHICLE]=.4
	}
	function JMod_DamageArmor(ply,slot,amt)
		local ArmorInfo=ply.EZarmor.slots[slot]
		local Name,Dur=ArmorInfo[1],ArmorInfo[2]
		local Specs=JMod_ArmorTable[slot][Name]
		local ShouldWarn50=Dur>Specs.dur*.5
		ArmorInfo[2]=Dur-amt*math.Rand(1.2,1.5)*JMOD_CONFIG.ArmorDegredationMult -- degredation
		if(ArmorInfo[2]<=0)then
			ply:PrintMessage(HUD_PRINTCENTER,slot.." armor destroyed")
			JMod_RemoveArmorSlot(ply,slot,true)
			JModEZarmorSync(ply)
		elseif((ArmorInfo[2]<=Specs.dur*.5)and(ShouldWarn50))then
			ply:PrintMessage(HUD_PRINTCENTER,slot.." armor at 50%")
			JModEZarmorSync(ply)
		end
	end
	local function EZgetProtectionFromSlot(ply,slot,amt,typ)
		local ArmorInfo=ply.EZarmor.slots[slot]
		if not(ArmorInfo)then return 0 end
		if((slot=="Face")and not(ply.EZarmor.maskOn))then return 0 end
		if((slot=="Ears")and not(ply.EZarmor.headsetOn))then return 0 end
		local Specs=JMod_ArmorTable[slot][ArmorInfo[1]]
		JMod_DamageArmor(ply,slot,amt)
		return Specs.def or 0
	end
	local function EZarmorScaleDmg(ply,dmgtype,dmgamt,location,isFace)
		local Block=0
		if(location==HITGROUP_HEAD)then
			if(isFace)then
				Block=Block+EZgetProtectionFromSlot(ply,"Face",dmgamt,dmgtype)
			else
				Block=Block+EZgetProtectionFromSlot(ply,"Head",dmgamt)
			end
		elseif(location==HITGROUP_CHEST)then
			Block=Block+EZgetProtectionFromSlot(ply,"Torso",dmgamt*.67)
			Block=Block+EZgetProtectionFromSlot(ply,"Pelvis",dmgamt*.33)
		elseif(location==HITGROUP_LEFTARM)then
			Block=Block+EZgetProtectionFromSlot(ply,"LeftShoulder",dmgamt*.6)
			Block=Block+EZgetProtectionFromSlot(ply,"LeftForearm",dmgamt*.4)
		elseif(location==HITGROUP_RIGHTARM)then
			Block=Block+EZgetProtectionFromSlot(ply,"RightShoulder",dmgamt*.6)
			Block=Block+EZgetProtectionFromSlot(ply,"RightForearm",dmgamt*.4)
		elseif(location==HITGROUP_LEFTLEG)then
			Block=Block+EZgetProtectionFromSlot(ply,"LeftThigh",dmgamt*.6)
			Block=Block+EZgetProtectionFromSlot(ply,"LeftCalf",dmgamt*.4)
		elseif(location==HITGROUP_RIGHTLEG)then
			Block=Block+EZgetProtectionFromSlot(ply,"RightThigh",dmgamt*.6)
			Block=Block+EZgetProtectionFromSlot(ply,"RightCalf",dmgamt*.4)
		elseif(location==HITGROUP_GENERIC)then
			Block=Block+EZgetProtectionFromSlot(ply,"Face",dmgamt*.05)*.15
			Block=Block+EZgetProtectionFromSlot(ply,"Head",dmgamt*.1)*.15
			Block=Block+EZgetProtectionFromSlot(ply,"Torso",dmgamt*.15)*.2
			Block=Block+EZgetProtectionFromSlot(ply,"Pelvis",dmgamt*.1)*.1
			Block=Block+EZgetProtectionFromSlot(ply,"LeftShoulder",dmgamt*.1)*.05
			Block=Block+EZgetProtectionFromSlot(ply,"LeftForearm",dmgamt*.05)*.05
			Block=Block+EZgetProtectionFromSlot(ply,"RightShoulder",dmgamt*.1)*.05
			Block=Block+EZgetProtectionFromSlot(ply,"RightForearm",dmgamt*.05)*.05
			Block=Block+EZgetProtectionFromSlot(ply,"LeftThigh",dmgamt*.1)*.05
			Block=Block+EZgetProtectionFromSlot(ply,"LeftCalf",dmgamt*.05)*.05
			Block=Block+EZgetProtectionFromSlot(ply,"RightThigh",dmgamt*.1)*.05
			Block=Block+EZgetProtectionFromSlot(ply,"RightCalf",dmgamt*.05)*.05
		end
		return 1-((Block/100)*(MaxArmorProtection[dmgtype]))
	end
	local function EZspecialScaleDamage(ply,dmgtype,dmgamt)
		local Block=0
		for slot,info in pairs(ply.EZarmor.slots)do
			if(info)then
				if((slot=="Face")and not(ply.EZarmor.maskOn))then return 1 end
				if((slot=="Ears")and not(ply.EZarmor.headsetOn))then return 1 end
				local Name,Dur,Col=info[1],info[2],info[3]
				local Specs=JMod_ArmorTable[slot][Name]
				local ShouldWarn50,ShouldWarn10=Dur>Specs.dur*.5,Dur>Specs.dur*.1
				if(Specs.spcdef)then
					for typ,amt in pairs(Specs.spcdef)do
						if(typ==dmgtype)then
							Block=Block+amt
							info[2]=Dur-amt*dmgamt*math.Rand(.0004,.0006)*JMOD_CONFIG.ArmorDegredationMult -- degredation
							if(info[2]<=0)then
								ply:PrintMessage(HUD_PRINTCENTER,Name.." destroyed")
								JMod_RemoveArmorSlot(ply,slot,true)
								JModEZarmorSync(ply)
							elseif((info[2]<=Specs.dur*.5)and(ShouldWarn50))then
								ply:PrintMessage(HUD_PRINTCENTER,Name.." at 50% durability")
								JModEZarmorSync(ply)
							elseif((info[2]<=Specs.dur*.1)and(ShouldWarn10))then
								ply:PrintMessage(HUD_PRINTCENTER,Name.." at 10% durability")
								JModEZarmorSync(ply)
							end
						end
					end
				end
			end
		end
		Block=math.Clamp(Block,0,100)
		return 1-Block/100
	end
	local function JackyDamageHandling(victim,hitgroup,dmginfo)
		if(victim.EZarmor)then
			local Mul,dmg,ply,amt=1,dmginfo,victim,dmginfo:GetDamage()
			if((dmg:IsDamageType(DMG_BULLET))or(dmg:IsDamageType(DMG_BUCKSHOT)))then
				if(hitgroup==HITGROUP_HEAD)then
					local ApproachVec=dmginfo:GetDamageForce():GetNormalized()
					local FacingVec=ply:GetAimVector()
					local DotProduct=FacingVec:DotProduct(ApproachVec)
					local ApproachAngle=(-math.deg(math.asin(DotProduct))+90)
					Mul=EZarmorScaleDmg(ply,DMG_BULLET,amt,HITGROUP_HEAD,ApproachAngle>=135)
				elseif((hitgroup==HITGROUP_CHEST)or(hitgroup==HITGROUP_STOMACH))then
					Mul=EZarmorScaleDmg(ply,DMG_BULLET,amt,HITGROUP_CHEST)
				elseif(hitgroup==HITGROUP_LEFTARM)then
					Mul=EZarmorScaleDmg(ply,DMG_BULLET,amt,HITGROUP_LEFTARM)
				elseif(hitgroup==HITGROUP_RIGHTARM)then
					Mul=EZarmorScaleDmg(ply,DMG_BULLET,amt,HITGROUP_RIGHTARM)
				elseif(hitgroup==HITGROUP_LEFTLEG)then
					Mul=EZarmorScaleDmg(ply,DMG_BULLET,amt,HITGROUP_LEFTLEG)
				elseif(hitgroup==HITGROUP_RIGHTLEG)then
					Mul=EZarmorScaleDmg(ply,DMG_BULLET,amt,HITGROUP_RIGHTLEG)
				end
			elseif(dmginfo:IsDamageType(DMG_BLAST))then
				Mul=EZarmorScaleDmg(ply,DMG_BLAST,amt,HITGROUP_GENERIC)
			elseif(dmginfo:IsDamageType(DMG_SLASH))then
				Mul=EZarmorScaleDmg(ply,DMG_SLASH,amt,HITGROUP_GENERIC)
			elseif(dmginfo:IsDamageType(DMG_CLUB))then
				Mul=EZarmorScaleDmg(ply,DMG_CLUB,amt,HITGROUP_GENERIC)
			elseif(dmginfo:IsDamageType(DMG_CRUSH))then
				Mul=EZarmorScaleDmg(ply,DMG_CRUSH,amt,HITGROUP_GENERIC)
			elseif(dmginfo:IsDamageType(DMG_VEHICLE))then
				Mul=EZarmorScaleDmg(ply,DMG_VEHICLE,amt,HITGROUP_GENERIC)
			elseif(dmginfo:IsDamageType(DMG_BURN))then
				Mul=EZarmorScaleDmg(ply,DMG_BURN,amt,HITGROUP_GENERIC)
			else
				if(dmginfo:IsDamageType(DMG_NERVEGAS))then
					Mul=EZspecialScaleDamage(ply,DMG_NERVEGAS,amt)
				elseif(dmginfo:IsDamageType(DMG_RADIATION))then
					Mul=EZspecialScaleDamage(ply,DMG_RADIATION,amt)
				end
			end
			local Reduction=1-Mul
			Reduction=Reduction^(.7*JMOD_CONFIG.ArmorExponentMult)
			Mul=1-Reduction
			dmginfo:ScaleDamage(Mul)
		end
	end
	local function JackaScaleDamageHook(victim,hitgroup,dmginfo)
		JackyDamageHandling(victim,hitgroup,dmginfo)
	end
	hook.Add("ScalePlayerDamage","JMod_ScaleDamageHook",JackaScaleDamageHook)
	local function JackaDamageHook(victim,dmginfo)
		if(victim:IsPlayer())then
			JackyDamageHandling(victim,HITGROUP_GENERIC,dmginfo)
		end
	end
	hook.Add("EntityTakeDamage","JMod_DamageHook",JackaDamageHook)
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
	function JMod_AeroDrag(ent,forward,mult) -- this causes an object to rotate to point forward while moving, like a dart
		if(constraint.HasConstraints(ent))then return end
		if(ent:IsPlayerHolding())then return end
		local Phys=ent:GetPhysicsObject()
		local Vel=Phys:GetVelocity()
		local Spd=Vel:Length()
		if(Spd<300)then return end
		mult=mult or 1
		local Pos,Mass=Phys:LocalToWorld(Phys:GetMassCenter()),Phys:GetMass()
		Phys:ApplyForceOffset(Vel*Mass/6*mult,Pos+forward)
		Phys:ApplyForceOffset(-Vel*Mass/6*mult,Pos-forward)
		Phys:AddAngleVelocity(-Phys:GetAngleVelocity()*Mass/1000)
	end
	function JMod_AeroGuide(ent,forward,targetPos,turnMult,thrustMult,angleDragMult,spdReq) -- this causes an object to rotate to point and fly to a point you give it
		--if(constraint.HasConstraints(ent))then return end
		--if(ent:IsPlayerHolding())then return end
		local Phys=ent:GetPhysicsObject()
		local Vel=Phys:GetVelocity()
		local Spd=Vel:Length()
		--if(Spd<spdReq)then return end
		local Pos,Mass=Phys:LocalToWorld(Phys:GetMassCenter()),Phys:GetMass()
		local TargetVec=targetPos-ent:GetPos()
		local TargetDir=TargetVec:GetNormalized()
		---
		Phys:ApplyForceOffset(TargetDir*Mass*turnMult*5000,Pos+forward)
		Phys:ApplyForceOffset(-TargetDir*Mass*turnMult*5000,Pos-forward)
		Phys:AddAngleVelocity(-Phys:GetAngleVelocity()*angleDragMult*3)
		--- todo: fuck
		Phys:ApplyForceCenter(forward*20000*thrustMult) -- todo: make this function fucking work ARGH
	end
	-- EZ Radio Code --
	local NotifyAllMsgs={
		["normal"]={
			["good drop"]="good drop, package away, returning to base",
			["drop failed"]="drop failed, pilot could not locate a good drop position for the reported coordinates. Aircraft is RTB",
			["drop soon"]="be advised, aircraft on site, drop imminent",
			["ready"]="attention, this outpost is now ready to carry out delivery missions"
		},
		["bff"]={
			["good drop"]="AIGHT we dropped it, watch out yo",
			["drop failed"]="yo WHERE THE DROP SITE AT THO soz i gotta get back to base",
			["drop soon"]="ay dudes watch yo head we abouta drop the box",
			["ready"]="aight we GOOD TO GO out here jus tell us whatchya need anytime"
		}
	}
	local function NotifyAllRadios(stationID,msgID,direct)
		local Radios=EZ_RADIO_STATIONS[stationID].transceivers
		for k,v in pairs(Radios)do
			if(IsValid(v))then
				if(direct)then
					v:Speak(msgID)
				else
					if(v.BFFd)then
						v:Speak(NotifyAllMsgs["bff"][msgID])
					else
						v:Speak(NotifyAllMsgs["normal"][msgID])
					end
				end
			else
				Radios[k]=nil
			end
		end
	end
	local function FindDropPosFromSignalOrigin(origin)
		local Height,Attempts,Pos=0,0,nil
		while((Attempts<1000)and not(Height>5000))do
			Height=Height+50
			local TestPos=origin+Vector(0,0,Height)
			local Contents=util.PointContents(TestPos)
			if((Contents==CONTENTS_EMPTY)or(Contents==CONTENTS_TESTFOGVOLUME))then
				Pos=TestPos
			end
		end
		return Pos
	end
	local NextThink=0
	hook.Add("Think","JMod_RADIO_THINK",function()
		local Time=CurTime()
		if(Time<NextThink)then return end
		NextThink=Time+5
		for stationID,station in pairs(EZ_RADIO_STATIONS)do
			if(station.state==EZ_STATION_STATE_DELIVERING)then
				if(station.nextDeliveryTime<Time)then
					station.nextReadyTime=Time+math.ceil(JMOD_CONFIG.RadioSpecs.DeliveryTimeMult*math.Rand(30,60)*3)
					station.state=EZ_STATION_STATE_BUSY
					local DropPos=FindDropPosFromSignalOrigin(station.deliveryLocation)
					if(DropPos)then
						local DropVelocity=VectorRand()
						DropVelocity.z=0
						DropVelocity:Normalize()
						DropVelocity=DropVelocity*400
						local Eff=EffectData()
						Eff:SetOrigin(DropPos)
						Eff:SetStart(DropVelocity)
						util.Effect("eff_jack_gmod_jetflyby",Eff,true,true)
						local DeliveryItems=JMOD_CONFIG.RadioSpecs.AvailablePackages[station.deliveryType]
						timer.Simple(.9,function()
							local Box=ents.Create("ent_jack_aidbox")
							Box:SetPos(DropPos)
							Box.InitialVel=-DropVelocity*10
							Box.Contents=DeliveryItems
							Box.NoFadeIn=true
							Box:SetDTBool(0,"true")
							Box:Spawn()
							Box:Initialize()
							---
							sound.Play("snd_jack_flyby_drop.mp3",DropPos,150,100)
							for k,playa in pairs(ents.FindInSphere(DropPos,6000))do
								if(playa:IsPlayer())then sound.Play("snd_jack_flyby_drop.mp3",playa:GetShootPos(),50,100) end
							end
							NotifyAllRadios(stationID,"good drop")
						end)
					else
						NotifyAllRadios(stationID,"drop failed")
					end
				elseif((station.nextNotifyTime<Time)and not(station.notified))then
					station.notified=true
					NotifyAllRadios(stationID,"drop soon")
				end
			elseif(station.state==EZ_STATION_STATE_BUSY)then
				if(station.nextReadyTime<Time)then
					station.state=EZ_STATION_STATE_READY
					NotifyAllRadios(stationID,"ready")
				end
			end
			if(station.restrictedPackageDelivering)then
				if(station.restrictedPackageDeliveryTime<Time)then
					table.insert(station.restrictedPackageStock,station.restrictedPackageDelivering)
					NotifyAllRadios(stationID,"attention, this outpost has received a special shipment of "..station.restrictedPackageDelivering.." from regional HQ",true)
					station.restrictedPackageDelivering=nil
					station.restrictedPackageDeliveryTime=0
				end
			end
		end
	end)
	function JMod_EZ_Toggle_Mask(ply)
		if not(ply.EZarmor)then return end
		if not(ply.EZarmor.slots["Face"])then return end
		if not(ply:Alive())then return end
		ply:EmitSound("snds_jack_gmod/equip1.wav",60,math.random(80,120))
		ply.EZarmor.maskOn=not ply.EZarmor.maskOn
		local ExtraEquipSound=JMod_ArmorTable["Face"][ply.EZarmor.slots["Face"][1]].eqsnd
		if((ply.EZarmor.maskOn)and(ExtraEquipSound))then
			ply:EmitSound(ExtraEquipSound,50,math.random(80,120))
		end
		JModEZarmorSync(ply)
	end
	concommand.Add("jmod_ez_mask",function(ply,cmd,args)
		JMod_EZ_Toggle_Mask(ply)
	end)
	function JMod_EZ_Toggle_Headset(ply)
	if not(ply.EZarmor)then return end
		if not(ply.EZarmor.slots["Ears"])then return end
		if not(ply:Alive())then return end
		ply:EmitSound("snds_jack_gmod/equip2.wav",60,math.random(80,120))
		ply.EZarmor.headsetOn=not ply.EZarmor.headsetOn
		JModEZarmorSync(ply)
	end
	function JMod_EZ_WeaponLaunch(ply)
		if not((IsValid(ply))and(ply:Alive()))then return end
		local Weps={}
		for k,ent in pairs(ents.GetAll())do
			if((ent.EZlaunchableWeaponArmedTime)and(ent.Owner)and(ent.Owner==ply)and(ent:GetState()==1))then
				table.insert(Weps,ent)
			end
		end
		local FirstWep,Earliest=nil,9e9
		for k,wep in pairs(Weps)do
			if(wep.EZlaunchableWeaponArmedTime<Earliest)then
				FirstWep=wep
				Earliest=wep.EZlaunchableWeaponArmedTime
			end
		end
		if(IsValid(FirstWep))then
			-- knock knock it's pizza time
			FirstWep:EmitSound("buttons/button6.wav",75,110)
			timer.Simple(.2,function()
				if(IsValid(FirstWep))then FirstWep:Launch() end
			end)
		end
	end
	function JMod_EZ_BombDrop(ply)
		if not((IsValid(ply))and(ply:Alive()))then return end
		local Boms={}
		for k,ent in pairs(ents.GetAll())do
			if((ent.EZdroppableBombArmedTime)and(ent.Owner)and(ent.Owner==ply))then
				table.insert(Boms,ent)
			end
		end
		local FirstBom,Earliest=nil,9e9
		for k,bom in pairs(Boms)do
			if((bom.EZdroppableBombArmedTime<Earliest)and((constraint.HasConstraints(bom))or not(bom:GetPhysicsObject():IsMotionEnabled())))then
				FirstBom=bom
				Earliest=bom.EZdroppableBombArmedTime
			end
		end
		if(IsValid(FirstBom))then
			-- knock knock it's pizza time
			FirstBom:EmitSound("buttons/button6.wav",75,80)
			timer.Simple(.5,function()
				if(IsValid(FirstBom))then
					constraint.RemoveAll(FirstBom)
					FirstBom:GetPhysicsObject():EnableMotion(true)
					FirstBom:GetPhysicsObject():Wake()
				end
			end)
		end
	end
	concommand.Add("jmod_ez_headset",function(ply,cmd,args)
		JMod_EZ_Toggle_Headset(ply)
	end)
	concommand.Add("jmod_ez_bombdrop",function(ply,cmd,args)
		JMod_EZ_BombDrop(ply)
	end)
	concommand.Add("jmod_ez_launch",function(ply,cmd,args)
		JMod_EZ_WeaponLaunch(ply)
	end)
	hook.Add("PlayerSay","JMod_RADIO_SAY",function(ply,txt)
		if not(IsValid(ply))then return end
		if not(ply:Alive())then return end
		local lowerTxt=string.lower(txt)
		if(lowerTxt=="*trigger*")then JMod_EZ_Remote_Trigger(ply);return "" end
		if(lowerTxt=="*armor*")then JMod_EZ_Remove_Armor(ply);return "" end
		if(lowerTxt=="*mask*")then JMod_EZ_Toggle_Mask(ply);return "" end
		if(lowerTxt=="*headset*")then JMod_EZ_Toggle_Headset(ply);return "" end
		if(lowerTxt=="*bomb*")then JMod_EZ_BombDrop(ply);return "" end
		if(lowerTxt=="*launch*")then JMod_EZ_WeaponLaunch(ply);return "" end
		for k,v in pairs(ents.FindInSphere(ply:GetPos(),150))do
			if(v.EZreceiveSpeech)then
				if(v:EZreceiveSpeech(ply,txt))then return "" end -- hide the player's radio chatter from the server
			end
		end
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
	function JMod_EZradioEstablish(transceiver,id)
		local Station=EZ_RADIO_STATIONS[id] or {
			state=EZ_STATION_STATE_READY,
			nextDeliveryTime=0,
			nextReadyTime=0,
			deliveryLocation=nil,
			deliveryType=nil,
			transceivers={},
			nextNotifyTime=0,
			notified=false,
			restrictedPackageStock={},
			restrictedPackageDelivering=nil,
			restrictedPackageDeliveryTime=0
		}
		table.insert(Station.transceivers,transceiver)
		EZ_RADIO_STATIONS[id]=Station
	end
	local function GetArticle(word)
		local FirstLetter=string.sub(word,1,1)
		if(table.HasValue({"a","e","i","o","u"},FirstLetter))then
			return "an"
		else
			return "a"
		end
	end
	local function GetTimeString(seconds)
		local Minutes,Seconds,Result=math.floor(seconds/60),math.floor(seconds%60),""
		if(Minutes>0)then
			Result=Minutes.." minutes"
			if(Seconds>0)then Result=Result..", "..Seconds.." seconds" end
		elseif(Seconds>0)then
			Result=Seconds.." seconds"
		end
		return Result
	end
	local function StartDelivery(pkg,transceiver,station,bff)
		local Time=CurTime()
		local DeliveryTime,Pos=math.ceil(JMOD_CONFIG.RadioSpecs.DeliveryTimeMult*math.Rand(30,60)),transceiver:GetPos()
		
		local newTime, newPos = hook.Run("JMod_RadioDelivery", ply, transceiver, pkg, time, pos)
		DeliveryTime = newTime or DeliveryTime
		Pos = newPos or Pos
		
		station.state=EZ_STATION_STATE_DELIVERING
		station.nextDeliveryTime=Time+DeliveryTime
		station.deliveryLocation=Pos
		station.deliveryType=pkg
		station.notified=false
		station.nextNotifyTime=Time+(DeliveryTime-5)
		if(bff)then return "ayo GOOD COPY homie, we sendin "..GetArticle(pkg).." "..pkg.." box right over to "..math.Round(Pos.x).." "..math.Round(Pos.y).." "..math.Round(Pos.z).." in prolly like "..DeliveryTime.." seconds" end
		return "roger wilco, sending "..GetArticle(pkg).." "..pkg.." package to coordinates "..math.Round(Pos.x).." "..math.Round(Pos.y).." "..math.Round(Pos.z)..", ETA "..DeliveryTime.." seconds"
	end
	function JMod_EZradioRequest(transceiver,id,ply,pkg,bff)
		local PackageInfo,Station,Time=JMOD_CONFIG.RadioSpecs.AvailablePackages[pkg],EZ_RADIO_STATIONS[id],CurTime()
		if not(Station)then
			JMod_EZradioEstablish(transceiver,id)
			Station=EZ_RADIO_STATIONS[id]
		end
		transceiver.BFFd=bff
		
		local override, msg = hook.Run("JMod_CanRadioRequest", ply, transceiver, pkg)
		if override == false then
			return msg or "negative on that request."
		end
		
		if(Station.state==EZ_STATION_STATE_DELIVERING)then
			if(bff)then return "no can do bro, we deliverin somethin else" end
			return "negative on that request, we're currently delivering another package"
		elseif(Station.state==EZ_STATION_STATE_BUSY)then
			if(bff)then return "nah fam we ain't ready yet tryagin l8r aight" end
			return "negative on that request, the delivery team isn't currently on station"
		elseif(Station.state==EZ_STATION_STATE_READY)then
			if(table.HasValue(JMOD_CONFIG.RadioSpecs.RestrictedPackages,pkg))then
				if not(JMOD_CONFIG.RadioSpecs.RestrictedPackagesAllowed)then return "negative on that request, neither we nor regional HQ have any of that at this time" end
				if(table.HasValue(Station.restrictedPackageStock,pkg))then
					table.RemoveByValue(Station.restrictedPackageStock,pkg)
					return StartDelivery(pkg,transceiver,Station,bff)
				else
					if(Station.restrictedPackageDelivering)then
						return "negative on that request, we don't have any of that in stock and HQ is currently delivering another special shipment"
					else
						Station.restrictedPackageDelivering=pkg
						local DeliveryTime=JMOD_CONFIG.RadioSpecs.RestrictedPackageShipTime*math.Rand(.8,1.2)
						Station.restrictedPackageDeliveryTime=Time+DeliveryTime
						return "roger, we don't have any of that in stock but we've ordered it from regional HQ, it'll be at this outpost in "..GetTimeString(DeliveryTime)
					end
				end
			else
				return StartDelivery(pkg,transceiver,Station,bff)
			end
		end
	end
	function JMod_EZradioStatus(transceiver,id,ply,bff)
		local Station,Time,Msg=EZ_RADIO_STATIONS[id],CurTime(),""
		transceiver.BFFd=bff
		if(Station.state==EZ_STATION_STATE_DELIVERING)then
			Msg="this outpost is currently delivering a package"
			if(bff)then Msg="hey we gettin somethin fo someone else righ now" end
		elseif(Station.state==EZ_STATION_STATE_BUSY)then
			Msg="this outpost is currently preparing for deliveries"
			if(bff)then Msg="hey homie we pretty busy out here right now jus hol up" end
		elseif(Station.state==EZ_STATION_STATE_READY)then
			Msg="this outpost is ready to accept delivery missions"
			if(bff)then Msg="ANYTHING U NEED WE GOTCHU" end
		end
		if(#Station.restrictedPackageStock>0)then
			local InventoryList=""
			for k,v in pairs(Station.restrictedPackageStock)do
				InventoryList=InventoryList..v..", "
			end
			Msg=Msg..", and has a special stock of "..InventoryList
		end
		if(Station.restrictedPackageDelivering)then
			Msg=Msg..", and has a special delivery of "..Station.restrictedPackageDelivering.." arriving from regional HQ in "..GetTimeString(Station.restrictedPackageDeliveryTime-Time)
		end
		return Msg
	end
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
	local function EZgetWeightFromSlot(ply,slot)
		local ArmorInfo=ply.EZarmor.slots[slot]
		if not(ArmorInfo)then return 0 end
		local Name,Dur=ArmorInfo[1],ArmorInfo[2]
		local Specs=JMod_ArmorTable[slot][Name]
		return Specs.wgt or 0
	end
	local function CalcSpeed(ply)
		local Walk,Run,TotalWeight=ply.EZoriginalWalkSpeed or 200,ply.EZoriginalRunSpeed or 400,0
		for k,v in pairs(JMod_ArmorTable)do
			TotalWeight=TotalWeight+EZgetWeightFromSlot(ply,k)
		end
		local WeighedFrac=TotalWeight/225
		ply.EZarmor.speedfrac=math.Clamp(1-(.8*WeighedFrac*JMOD_CONFIG.ArmorWeightMult),.05,1)
		-- Handled in SetupMove hook
		--ply:SetWalkSpeed(Walk*(1-.8*WeighedFrac))
		--ply:SetRunSpeed(Run*(1-.8*WeighedFrac))
	end
	local EquipSounds={"snd_jack_clothequip.wav","snds_jack_gmod/equip1.wav","snds_jack_gmod/equip2.wav","snds_jack_gmod/equip3.wav","snds_jack_gmod/equip4.wav","snds_jack_gmod/equip5.wav"}
	function JMod_RemoveArmorSlot(ply,slot,broken)
		local Info=ply.EZarmor.slots[slot]
		if not(Info)then return end
		local Specs=JMod_ArmorTable[slot][Info[1]]
		timer.Simple(math.Rand(0,.5),function()
			if(broken)then
				ply:EmitSound("snds_jack_gmod/armorbreak.wav",60,math.random(80,120))
			else
				ply:EmitSound(table.Random(EquipSounds),60,math.random(80,120))
			end
		end)
		if not(broken)then
			local Ent=ents.Create(Specs.ent)
			Ent:SetPos(ply:GetShootPos()+ply:GetAimVector()*30+VectorRand()*math.random(1,20))
			Ent:SetAngles(AngleRand())
			Ent.Durability=Info[2]
			Ent:SetColor(Info[3])
			Ent:Spawn()
			Ent:Activate()
			Ent:GetPhysicsObject():SetVelocity(ply:GetVelocity())
		end
		ply.EZarmor.slots[slot]=nil
	end
	function JMod_EZ_Equip_Armor(ply,ent)
		if not(IsValid(ent))then return end
		--[[ -- this isn't needed anymore since we're using SetupMove
		if(not(ply.EZarmor)or not(#table.GetKeys(ply.EZarmor)>0))then
			ply.EZoriginalWalkSpeed=ply:GetWalkSpeed()
			ply.EZoriginalRunSpeed=ply:GetRunSpeed()
		end
		--]]
		JMod_RemoveArmorSlot(ply,ent.Slot)
		ply.EZarmor.slots[ent.Slot]={ent.ArmorName,ent.Durability,ent:GetColor()}
		ply:EmitSound(table.Random(EquipSounds),60,math.random(80,120))
		ent:Remove()
		CalcSpeed(ply)
		JModEZarmorSync(ply)
	end
	function JMod_EZ_Remove_Armor(ply)
		for k,v in pairs(JMod_ArmorTable)do
			JMod_RemoveArmorSlot(ply,k)
		end
		CalcSpeed(ply)
		JModEZarmorSync(ply)
	end
	-- copied from Homicide
	function JMod_BlastThatDoor(ent,vel)
		local Moddel,Pozishun,Ayngul,Muteeriul,Skin=ent:GetModel(),ent:GetPos(),ent:GetAngles(),ent:GetMaterial(),ent:GetSkin()
		sound.Play("Wood_Crate.Break",Pozishun,60,100)
		sound.Play("Wood_Furniture.Break",Pozishun,60,100)
		ent:Fire("open","",0)
		ent:SetNoDraw(true)
		ent:SetNotSolid(true)
		if((Moddel)and(Pozishun)and(Ayngul))then
			local Replacement=ents.Create("prop_physics")
			Replacement:SetModel(Moddel);Replacement:SetPos(Pozishun+Vector(0,0,1))
			Replacement:SetAngles(Ayngul)
			if(Muteeriul)then Replacement:SetMaterial(Muteeriul) end
			if(Skin)then Replacement:SetSkin(Skin) end
			Replacement:SetModelScale(.9,0)
			Replacement:Spawn()
			Replacement:Activate()
			if(vel)then Replacement:GetPhysicsObject():SetVelocity(vel) end
			timer.Simple(3,function()
				if(IsValid(Replacement))then Replacement:SetCollisionGroup(COLLISION_GROUP_WEAPON) end
			end)
			timer.Simple(30*JMOD_CONFIG.DoorBreachResetTimeMult,function()
				if(IsValid(ent))then ent:SetNotSolid(false);ent:SetNoDraw(false) end
				if(IsValid(Replacement))then Replacement:Remove() end
			end)
		end
	end
	function JMod_FragSplosion(shooter,origin,fragNum,fragDmg,fragMaxDist,attacker,direction,spread,zReduction)
		-- fragmentation/shrapnel simulation
		local Eff=EffectData()
		Eff:SetOrigin(origin)
		Eff:SetScale(fragNum)
		Eff:SetNormal(direction or Vector(0,0,0))
		Eff:SetMagnitude(spread or 0)
		util.Effect("eff_jack_gmod_fragsplosion",Eff,true,true)
		---
		shooter=shooter or game.GetWorld()
		if not(JMOD_CONFIG.FragExplosions)then
			util.BlastDamage(shooter,attacker,origin,fragDmg*8,fragDmg*3)
			return
		end
		local Spred=Vector(0,0,0)
		local BulletsFired,MaxBullets,disperseTime=0,300,.5
		if(fragNum>=12000)then disperseTime=2 elseif(fragNum>=6000)then disperseTime=1 end
		for i=1,fragNum do
			timer.Simple((i/fragNum)*disperseTime,function()
				local Dir
				if((direction)and(spread))then
					Dir=Vector(direction.x,direction.y,direction.z)
					Dir=Dir+VectorRand()*math.Rand(0,spread)
					Dir:Normalize()
				else
					Dir=VectorRand()
				end
				if(zReduction)then
					Dir.z=Dir.z/zReduction
					Dir:Normalize()
				end
				local Tr=util.QuickTrace(origin,Dir*fragMaxDist,shooter)
				if((Tr.Hit)and not(Tr.HitSky)and not(Tr.HitWorld)and(BulletsFired<MaxBullets))then
					local DmgMul=1
					if(BulletsFired>200)then DmgMul=2 end
					local firer=((IsValid(shooter))and shooter) or game.GetWorld()
					firer:FireBullets({
						Attacker=attacker,
						Damage=fragDmg*DmgMul,
						Force=fragDmg/8*DmgMul,
						Num=1,
						Src=origin,
						Tracer=0,
						Dir=Dir,
						Spread=Spred
					})
					BulletsFired=BulletsFired+1
				end
			end)
		end
	end
	function JMod_PackageObject(ent,pos,ang,ply)
		if(pos)then
			ent=ents.Create(ent)
			ent:SetPos(pos)
			ent:SetAngles(ang)
			if(ply)then
				JMod_Owner(ent,ply)
			end
			ent:Spawn()
			ent:Activate()
		end
		local Bocks=ents.Create("ent_jack_gmod_ezcompactbox")
		Bocks:SetPos(ent:LocalToWorld(ent:OBBCenter())+Vector(0,0,20))
		Bocks:SetAngles(ent:GetAngles())
		Bocks:SetContents(ent)
		if(ply)then
			JMod_Owner(Bocks,ply)
		end
		Bocks:Spawn()
		Bocks:Activate()
	end
	function JMod_SimpleForceExplosion(pos,power,range,sourceEnt)
		for k,v in pairs(ents.FindInSphere(pos,range))do
			if(not(IsValid(sourceEnt))or(v~=sourceEnt))then
				local Phys=v:GetPhysicsObject()
				if(IsValid(Phys))then
					local EntPos=v:LocalToWorld(v:OBBCenter())
					local Tr=util.TraceLine({start=pos,endpos=EntPos,filter={sourceEnt,v}})
					if not(Tr.Hit)then
						local DistFrac=(1-(EntPos:Distance(pos)/range))^2
						local Force=power*DistFrac
						if((v:IsNPC())or(v:IsPlayer()))then
							v:SetVelocity((EntPos-pos):GetNormalized()*Force/500)
						else
							Phys:ApplyForceCenter((EntPos-pos):GetNormalized()*Force*Phys:GetMass()^.25/2)
						end
					end
				end
			end
		end
	end
	function JMod_DecalSplosion(pos,decalName,range,num,sourceEnt)
		for i=1,num do
			local Dir=VectorRand()*math.random(1,range)
			Dir.z=-math.abs(Dir.z)/6
			local Tr=util.QuickTrace(pos,Dir,sourceEnt)
			if(Tr.Hit)then
				util.Decal(decalName,Tr.HitPos+Tr.HitNormal,Tr.HitPos-Tr.HitNormal)
			end
		end
	end
	function JMod_BlastDamageIgnoreWorld(pos,att,infl,dmg,range)
		for k,v in pairs(ents.FindInSphere(pos,range))do
			local EntPos=v:GetPos()
			local Vec=EntPos-pos
			local Dir=Vec:GetNormalized()
			local DistFrac=1-(Vec:Length()/range)
			local Dmg=DamageInfo()
			Dmg:SetDamage(dmg*DistFrac)
			Dmg:SetDamageForce(Dir*1e5*DistFrac)
			Dmg:SetDamagePosition(EntPos)
			Dmg:SetAttacker(att or game.GetWorld())
			Dmg:SetInflictor(infl or att or game.GetWorld())
			Dmg:SetDamageType(DMG_BLAST)
			v:TakeDamageInfo(Dmg)
		end
	end
	function JMod_WreckBuildings(blaster,pos,power,range,ignoreVisChecks)
		local origPower=power
		power=power*JMOD_CONFIG.ExplosionPropDestroyPower
		local maxRange=250*power*(range or 1) -- todo: this still doesn't do what i want for the nuke
		local maxMassToDestroy=10*power^.8
		local masMassToLoosen=30*power
		local allProps = ents.FindInSphere(pos,maxRange)
		for k,prop in pairs(allProps)do
			local physObj=prop:GetPhysicsObject()
			local propPos=prop:LocalToWorld(prop:OBBCenter())
			local DistFrac=(1-propPos:Distance(pos)/maxRange)
			local myDestroyThreshold=DistFrac*maxMassToDestroy
			local myLoosenThreshold=DistFrac*masMassToLoosen
			if(DistFrac>=.85)then myDestroyThreshold=myDestroyThreshold*7;myLoosenThreshold=myLoosenThreshold*7 end
			if((prop~=blaster)and(physObj:IsValid()))then
				local mass,proceed=physObj:GetMass(),ignoreVisChecks
				if not(proceed)then
					local tr=util.QuickTrace(pos,propPos-pos,blaster)
					proceed=((IsValid(tr.Entity))and(tr.Entity==prop))
				end
				if(proceed)then
					if(mass<=myDestroyThreshold)then
						SafeRemoveEntity(prop)
					elseif(mass<=myLoosenThreshold)then
						physObj:EnableMotion(true)
						constraint.RemoveAll(prop)
						physObj:ApplyForceOffset((propPos-pos):GetNormalized()*1000*DistFrac*power*mass,propPos+VectorRand()*10)
					else
						physObj:ApplyForceOffset((propPos-pos):GetNormalized()*1000*DistFrac*origPower*mass,propPos+VectorRand()*10)
					end
				end
			end
		end
	end
	function JMod_BlastDoors(blaster,pos,power,range,ignoreVisChecks)
		for k,door in pairs(ents.FindInSphere(pos,40*power*(range or 1)))do
			if(JMod_IsDoor(door))then
				local proceed=ignoreVisChecks
				if not(proceed)then
					local tr=util.QuickTrace(pos,door:LocalToWorld(door:OBBCenter())-pos,blaster)
					proceed=((IsValid(tr.Entity))and(tr.Entity==door))
				end
				if(proceed)then
					JMod_BlastThatDoor(door,(door:LocalToWorld(door:OBBCenter())-pos):GetNormalized()*1000)
				end
			end
		end
	end
	function JMod_Sploom(attacker,pos,mag)
		local Sploom=ents.Create("env_explosion")
		Sploom:SetPos(pos)
		Sploom:SetOwner(attacker or game.GetWorld())
		Sploom:SetKeyValue("iMagnitude",mag)
		Sploom:Spawn()
		Sploom:Activate()
		Sploom:Fire("explode","",0)
	end
	local SurfaceHardness={
		[MAT_METAL]=.95,[MAT_COMPUTER]=.95,[MAT_VENT]=.95,[MAT_GRATE]=.95,[MAT_FLESH]=.5,[MAT_ALIENFLESH]=.3,
		[MAT_SAND]=.1,[MAT_DIRT]=.3,[MAT_GRASS]=.2,[74]=.1,[85]=.2,[MAT_WOOD]=.5,[MAT_FOLIAGE]=.5,
		[MAT_CONCRETE]=.9,[MAT_TILE]=.8,[MAT_SLOSH]=.05,[MAT_PLASTIC]=.3,[MAT_GLASS]=.6
	}
	function JMod_RicPenBullet(ent,pos,dir,dmg,doBlasts,wreckShit,num,penMul,tracerName,callback) -- Slayer Ricocheting/Penetrating Bullets FTW
		if not(IsValid(ent))then return end
		if((num)and(num>10))then return end
		local Attacker=ent.Owner or ent or game.GetWorld()
		ent:FireBullets({
			Attacker=Attacker,
			Damage=dmg,
			Force=dmg,
			Num=1,
			Tracer=1,
			TracerName=tracerName or "",
			Dir=dir,
			Spread=Vector(0,0,0),
			Src=pos,
			Callback=callback or nil
		})
		local initialTrace=util.TraceLine({
			start=pos,
			endpos=pos+dir*50000,
			filter={ent}
		})
		if not(initialTrace.Hit)then return end
		local AVec,IPos,TNorm,SMul=initialTrace.Normal,initialTrace.HitPos,initialTrace.HitNormal,SurfaceHardness[initialTrace.MatType]
		if(doBlasts)then
			util.BlastDamage(ent,Attacker,IPos+TNorm*2,dmg/3,dmg/4)
			timer.Simple(0,function()
				local Tr=util.QuickTrace(IPos+TNorm,-TNorm*20)
				if(Tr.Hit)then util.Decal("FadingScorch",Tr.HitPos+Tr.HitNormal,Tr.HitPos-Tr.HitNormal) end
			end)
		end
		if((wreckShit)and not(initialTrace.HitWorld))then
			local Phys=initialTrace.Entity:GetPhysicsObject()
			if((IsValid(Phys))and(Phys.GetMass))then
				local Mass,Thresh=Phys:GetMass(),dmg/2
				if(Mass<=Thresh)then
					constraint.RemoveAll(initialTrace.Entity)
					Phys:EnableMotion(true)
					Phys:Wake()
					Phys:ApplyForceOffset(-AVec*dmg*2,IPos)
				end
			end
		end
		---
		if not(SMul)then SMul=.5 end
		local ApproachAngle=-math.deg(math.asin(TNorm:DotProduct(AVec)))
		local MaxRicAngle=60*SMul
		if(ApproachAngle>(MaxRicAngle*1.05))then -- all the way through (hot)
			local MaxDist,SearchPos,SearchDist,Penetrated=(dmg/SMul)*.15*(penMul or 1),IPos,5,false
			while((not(Penetrated))and(SearchDist<MaxDist))do
				SearchPos=IPos+AVec*SearchDist
				local PeneTrace=util.QuickTrace(SearchPos,-AVec*SearchDist)
				if((not(PeneTrace.StartSolid))and(PeneTrace.Hit))then
					Penetrated=true
				else
					SearchDist=SearchDist+5
				end
			end
			if(Penetrated)then
				ent:FireBullets({
					Attacker=Attacker,
					Damage=1,
					Force=1,
					Num=1,
					Tracer=0,
					TracerName="",
					Dir=-AVec,
					Spread=Vector(0,0,0),
					Src=SearchPos+AVec
				})
				if(doBlasts)then
					util.BlastDamage(ent,Attacker,SearchPos+AVec*2,dmg/2,dmg/4)
					timer.Simple(0,function()
						local Tr=util.QuickTrace(SearchPos+AVec,-AVec*20)
						if(Tr.Hit)then util.Decal("FadingScorch",Tr.HitPos+Tr.HitNormal,Tr.HitPos-Tr.HitNormal) end
					end)
				end
				local ThroughFrac=1-SearchDist/MaxDist
				JMod_RicPenBullet(ent,SearchPos+AVec,AVec,dmg*ThroughFrac*.7,doBlasts,wreckShit,(num or 0)+1,penMul,tracerName,callback)
			end
		elseif(ApproachAngle<(MaxRicAngle*.95))then -- ping whiiiizzzz
			if(SERVER)then sound.Play("snds_jack_gmod/ricochet_"..math.random(1,2)..".wav",IPos,60,math.random(90,100)) end
			local NewVec=AVec:Angle()
			NewVec:RotateAroundAxis(TNorm,180)
			NewVec=NewVec:Forward()
			JMod_RicPenBullet(ent,IPos+TNorm,-NewVec,dmg*.7,doBlasts,wreckShit,(num or 0)+1,penMul,tracerName,callback)
		end
	end
	function JMod_Owner(ent,newOwner)
		if not(IsValid(ent))then return end
		if not(IsValid(newOwner))then newOwner=game.GetWorld() end
		local OldOwner=ent.Owner
		if((OldOwner)and(OldOwner==newOwner))then return end
		ent.Owner=newOwner
		if not(CPPI)then return end
		if(ent.CPPISetOwner)then ent:CPPISetOwner(newOwner) end
	end
	function JMod_ShouldAllowControl(self,ply)
		if not(IsValid(ply))then return false end
		if not(IsValid(self.Owner))then return false end
		if(ply==self.Owner)then return true end
		local Allies=self.Owner.JModFriends or {}
		if(table.HasValue(Allies,ply))then return true end
		if(engine.ActiveGamemode()=="sandbox")then return false end
		return ply:Team()==self.Owner:Team()
	end
	function JMod_ShouldAttack(self,ent,vehiclesOnly)
		if not(IsValid(ent))then return false end
		if(ent:IsWorld())then return false end
		local Gaymode,PlayerToCheck,InVehicle=engine.ActiveGamemode(),nil,false
		if(ent:IsPlayer())then
			PlayerToCheck=ent
		elseif(ent:IsNPC())then
			local Class=ent:GetClass()
			if((self.WhitelistedNPCs)and(table.HasValue(self.WhitelistedNPCs,Class)))then return true end
			if((self.BlacklistedNPCs)and(table.HasValue(self.BlacklistedNPCs,Class)))then return false end
			if not(IsValid(self.Owner))then jprint("B") return ent:Health()>0 end
			if((ent.Disposition)and(ent:Disposition(self.Owner)==D_HT)and(ent.GetMaxHealth))then
				jprint("A")
				if(vehiclesOnly)then
					return ent:GetMaxHealth()>100
				else
					return ent:GetMaxHealth()>0
				end
			else
				return false
			end
		elseif(ent:IsVehicle())then
			PlayerToCheck=ent:GetDriver()
			InVehicle=true
		end
		if((IsValid(PlayerToCheck))and(PlayerToCheck.Alive))then
			if((vehiclesOnly)and not(InVehicle))then return false end
			if(PlayerToCheck.EZkillme)then return true end -- for testing
			if((self.Owner)and(PlayerToCheck==self.Owner))then return false end
			local Allies=(self.Owner and self.Owner.JModFriends)or {}
			if(table.HasValue(Allies,PlayerToCheck))then return false end
			local OurTeam=nil
			if(IsValid(self.Owner))then OurTeam=self.Owner:Team() end
			if(Gaymode=="sandbox")then return PlayerToCheck:Alive() end
			if(OurTeam)then return PlayerToCheck:Alive() and PlayerToCheck:Team()~=OurTeam end
			return PlayerToCheck:Alive()
		end
		return false
	end
	function JMod_EnemiesNearPoint(ent,pos,range,vehiclesOnly)
		for k,v in pairs(ents.FindInSphere(pos,range))do
			if(JMod_ShouldAttack(ent,v,vehiclesOnly))then return true end
		end
		return false
	end
	function JMod_EMP(pos,range)
		for k,ent in pairs(ents.FindInSphere(pos,range))do
			if((ent.SetState)and(ent.SetElectricity)and(ent.GetState)and(ent:GetState()>0))then
				ent:SetState(0)
			end
		end
	end
	local TriggerKeys={IN_ATTACK,IN_USE,IN_ATTACK2}
	function JMod_ThrowablePickup(playa,item,hardstr,softstr)
		playa:PickupObject(item)
		local HookName="EZthrowable_"..item:EntIndex()
		hook.Add("KeyPress",HookName,function(ply,key)
			if not(IsValid(playa))then hook.Remove("KeyPress",HookName) return end
			if not(ply==playa)then return end
			if((IsValid(item))and(ply:Alive()))then
				local Phys=item:GetPhysicsObject()
				if(key==IN_ATTACK)then
					timer.Simple(0,function()
						if(IsValid(Phys))then
							Phys:ApplyForceCenter(ply:GetAimVector()*(hardstr or 600)*Phys:GetMass())
							if(item.EZspinThrow)then
								Phys:ApplyForceOffset(ply:GetAimVector()*Phys:GetMass()*50,Phys:GetMassCenter()+Vector(0,0,10))
								Phys:ApplyForceOffset(-ply:GetAimVector()*Phys:GetMass()*50,Phys:GetMassCenter()-Vector(0,0,10))
							end
						end
					end)
				elseif(key==IN_ATTACK2)then
					local vec = ply:GetAimVector()
					vec.z = vec.z + 0.1
					timer.Simple(0,function()
						if(IsValid(Phys))then Phys:ApplyForceCenter(vec*(softstr or 400)*Phys:GetMass()) end
					end)
				end
			end
			if(table.HasValue(TriggerKeys,key))then hook.Remove("KeyPress",HookName) end
		end)
	end
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
