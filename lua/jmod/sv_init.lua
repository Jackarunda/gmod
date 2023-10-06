JMod.Wind = Vector(0, 0, 0)
local force_workshop = CreateConVar("jmod_forceworkshop", 1, {FCVAR_ARCHIVE}, "Force clients to download JMod+its content? (requires a restart upon change)")

if force_workshop:GetBool() then
	resource.AddWorkshop("1919689921")
end

local function JackaSpawnHook(ply)
	ply.JModSpawnTime = CurTime()
	ply.JModFriends = ply.JModFriends or {}

	if ply.EZarmor and ply.EZarmor.suited then
		ply:SetColor(Color(255, 255, 255))
	end

	ply.EZarmor = {
		items = {},
		speedFrac = nil,
		effects = {},
		mskmat = nil,
		sndlop = nil,
		suited = false,
		bodygroups = nil,
		totalWeight = 0
	}

	JMod.EZarmorSync(ply)
	ply.EZhealth = nil
	ply.EZirradiated = nil
	ply.EZoxygen = 100
	ply.EZbleeding = 0
	JMod.SyncBleeding(ply)
	ply.EZvirus = nil

	timer.Simple(0, function()
		if IsValid(ply) then
			ply.EZoriginalPlayerModel = ply:GetModel()
		end
	end)

	if JMod.Config.Explosives.BombOwnershipLossOnRespawn then
		for k, ent in pairs(ents.GetAll()) do
			local EZowner = JMod.GetEZowner(ent)

			if ent.EZdroppableBombArmedTime and IsValid(EZowner) and EZowner == ply then
				JMod.SetEZowner(ent, game.GetWorld())
			elseif ent.EZdroppableBombLoadTime and IsValid(EZowner) and EZowner == ply then
				JMod.SetEZowner(ent, game.GetWorld())
			elseif ent.EZlaunchableWeaponArmedTime and IsValid(EZowner) and EZowner == ply and ent:GetState() == 1 then
				JMod.SetEZowner(ent, game.GetWorld())
			end
		end
	end
	
	local STATE_ROLLED, STATE_UNROLLED = 0, 1
	local sleepingbag = ply.JModSpawnPointEntity
	if(sleepingbag and (IsValid(sleepingbag)) and sleepingbag.State == STATE_UNROLLED)then
		--if(sleepingbag.nextSpawnTime<CurTime())then
			sleepingbag.nextSpawnTime=CurTime()+60
			if not IsValid(sleepingbag.Pod:GetDriver()) then --Get inside when respawn
				local Up = sleepingbag:GetUp()
				--ply:EnterVehicle(sleepingbag.Pod)
				ply:SetPos(sleepingbag:GetPos())
				sleepingbag.Pod:Fire("EnterVehicle", "nil", 0, ply, ply)
				net.Start("JMod_VisionBlur")
				net.WriteFloat(5)
				net.WriteFloat(2000)
				net.WriteBit(true)
				net.Send(ply)
				sleepingbag.Pod.EZvehicleEjectPos = nil
			end
		--else
		--	JMod.Hint(ply,"sleeping bag wait")
		--end
	end

	net.Start("JMod_PlayerSpawn")
	net.WriteBit(JMod.Config.General.Hints)
	net.Send(ply)
end

hook.Add("PlayerSpawn", "JMod_PlayerSpawn", JackaSpawnHook)
hook.Add("PlayerInitialSpawn", "JMod_PlayerInitialSpawn", function(ply) JackaSpawnHook(ply) ; JMod.LuaConfigSync(false) end)

function JMod.SyncBleeding(ply)
	net.Start("JMod_Bleeding")
	net.WriteInt(ply.EZbleeding, 8)
	net.Send(ply)
end

hook.Add("PlayerLoadout", "JMod_PlayerLoadout", function(ply)
	if JMod.Config and JMod.Config.QoL.GiveHandsOnSpawn then
		ply:Give("wep_jack_gmod_hands")
	end
end)

hook.Add("GetPreferredCarryAngles", "JMOD_PREFCARRYANGS", function(ent)
	if ent.JModPreferredCarryAngles then return ent.JModPreferredCarryAngles end
end)

hook.Add("AllowPlayerPickup", "JMOD_PLAYERPICKUP", function(ply, ent)
	if ent.JModNoPickup then return false end
end)

function JMod.ShouldDamageBiologically(ent)
	if not IsValid(ent) then return false end
	if (ent.JModDontIrradiate and ent.JModDontIrradiate == true) then return false end
	if (ent.IsJackyEZcrop) then return true end
	if (ent.Mutation) and (ent.Mutation < 100) then return true end
	if ent:IsPlayer() then return ent:Alive() end

	if (ent:IsNPC() or ent:IsNextBot()) and ent.Health and ent:Health() then
		local Phys = ent:GetPhysicsObject()

		if IsValid(Phys) then
			local Mat = Phys:GetMaterial()

			if Mat then
				if Mat == "metal" then return false end
				if Mat == "default" then return false end
			end
		end

		return ent:Health() > 0
	end

	return false
end

local function ShouldVirusInfect(ent)
	if not IsValid(ent) then return false end
	if ent.EZvirus and ent.EZvirus.Immune then return false end
	if ent:IsPlayer() then return ent:Alive() end
	if ent:IsNPC() then return string.find(ent:GetClass(), "citizen") end

	return false
end

local function VirusHostCanSee(host, ent)
	local Tr = util.TraceLine({
		start = host:GetPos(),
		endpos = ent:GetPos(),
		filter = {host, ent},
		mask = MASK_SHOT
	})

	return not Tr.Hit
end

function JMod.ViralInfect(ply, att)
	if ply.EZvirus then return end
	if ((ply.JModSpawnTime or 0) + 30) > CurTime() then return end
	local Severity, Latency = math.random(50, 500), math.random(10, 100)

	ply.EZvirus = {
		Severity = Severity,
		NextCough = CurTime() + Latency,
		InfectionWarned = false,
		Immune = false,
		Attacker = (IsValid(att) and att) or game.GetWorld(),
		NextFoodImmunityBoost = 0,
		NextAntibioticsImmunityBoost = 0
	}
end

function JMod.GeigerCounterSound(ply, intensity)
	if intensity <= .1 and math.random(1, 2) == 1 then return end
	local Num = math.Clamp(math.Round(math.Rand(0, intensity) * 15), 1, 10)
	ply:EmitSound("snds_jack_gmod/geiger" .. Num .. ".wav", 55, math.random(95, 105))
	--local Leaf = EffectData()
	--Leaf:SetOrigin(ply:GetPos() + VectorRand(-100, 100) + Vector(0, 0, 64))
	--util.Effect("eff_jack_gmod_ezleaf", Leaf, true, true)
end

function JMod.FalloutIrradiate(self, obj)
	local DmgAmt = self.DmgAmt or math.random(4, 20) * JMod.Config.Particles.NuclearRadiationMult

	if obj:WaterLevel() >= 3 then
		DmgAmt = DmgAmt / 3
	end

	---
	local Dmg, Helf, Att = DamageInfo(), obj:Health(), (IsValid(self.EZowner) and self.EZowner) or self
	Dmg:SetDamageType(DMG_RADIATION)
	Dmg:SetDamage(DmgAmt)
	Dmg:SetInflictor(self)
	Dmg:SetAttacker(Att)
	Dmg:SetDamagePosition(obj:GetPos())

	if obj:IsPlayer() then
		DmgAmt = DmgAmt / 4
		Dmg:SetDamage(DmgAmt)
		obj:TakeDamageInfo(Dmg)
		---
		JMod.GeigerCounterSound(obj, math.Rand(.1, .5))
		JMod.Hint(v, "radioactive fallout")

		timer.Simple(math.Rand(.1, 2), function()
			if IsValid(obj) then
				JMod.GeigerCounterSound(obj, math.Rand(.1, .5))
			end
		end)

		---
		local DmgTaken = Helf - obj:Health()

		if (DmgTaken > 0) and JMod.Config.Explosives.Nuke.RadiationSickness then
			obj.EZirradiated = (obj.EZirradiated or 0) + DmgTaken * 3

			timer.Simple(10, function()
				if IsValid(obj) and obj:Alive() then
					JMod.Hint(obj, "radiation sickness")
				end
			end)
		end
	else
		obj:TakeDamageInfo(Dmg)
	end
end

function JMod.TryVirusInfectInRange(host, att, hostFaceProt, hostSkinProt)
	local Range, SelfPos = 300 * JMod.Config.Particles.VirusSpreadMult, host:GetPos()

	if hostFaceProt > 0 or hostSkinProt > 0 then
		Range = Range * (1 - (hostFaceProt + hostSkinProt) / 2)
	end

	if Range <= 0 then return end

	for key, obj in pairs(ents.FindInSphere(SelfPos, Range)) do
		if not (obj == host) and VirusHostCanSee(host, obj) and ShouldVirusInfect(obj) then
			local DistFrac = 1 - (obj:GetPos():Distance(SelfPos) / (Range * 1.2))
			local Chance = DistFrac * .2

			if obj:WaterLevel() >= 3 then
				Chance = Chance / 3
			end

			---
			local VictimFaceProtection, VictimSkinProtection = JMod.GetArmorBiologicalResistance(obj, DMG_RADIATION)

			if VictimFaceProtection > 0 or VictimSkinProtection > 0 then
				Chance = Chance * (1 - (VictimFaceProtection + VictimSkinProtection) / 2)
			end

			if Chance > 0 then
				local AAA = math.Rand(0, 1)

				if AAA < Chance then
					JMod.ViralInfect(obj, att)
				end
			end
		end
	end
end

local function VirusCough(ply)
	if math.random(1, 10) == 2 then
		JMod.TryCough(ply)
	end

	local Dmg = DamageInfo()
	Dmg:SetDamageType(DMG_GENERIC) -- why aint this working to hazmat wearers?
	Dmg:SetAttacker((IsValid(ply.EZvirus.Attacker) and ply.EZvirus.Attacker) or game.GetWorld())
	Dmg:SetInflictor(ply)
	Dmg:SetDamagePosition(ply:GetPos())
	Dmg:SetDamageForce(Vector(0, 0, 0))
	Dmg:SetDamage(1)
	ply:TakeDamageInfo(Dmg)
	--
	local HostFaceProtection, HostSkinProtection = JMod.GetArmorBiologicalResistance(ply, DMG_RADIATION)
	if (HostFaceProtection + HostSkinProtection) >= 2 then return end
	JMod.TryVirusInfectInRange(ply, ply.EZvirus.Attacker, HostFaceProtection, HostSkinProtection)

	if math.random(1, 10) == 10 then
		local Gas = ents.Create("ent_jack_gmod_ezvirusparticle")
		Gas:SetPos(ply:GetPos())
		JMod.SetEZowner(Gas, ply)
		Gas:Spawn()
		Gas:Activate()
		Gas.CurVel = (ply:GetVelocity() + ply:GetForward() * 10)
	end
end

local function VirusHostThink(dude)
	local Time = CurTime()

	if dude.EZvirus and not dude.EZvirus.Immune and dude.EZvirus.NextCough < Time then
		dude.EZvirus.NextCough = Time + math.Rand(.5, 2)

		if not dude.EZvirus.InfectionWarned then
			dude.EZvirus.InfectionWarned = true

			if dude.PrintMessage then
				dude:PrintMessage(HUD_PRINTTALK, "You've contracted the JMod virus. Get medical attention, eat food, and avoid contact with others.")
			end
		end

		VirusCough(dude)
		dude.EZvirus.Severity = math.Clamp(dude.EZvirus.Severity - 1, 0, 9e9)

		if dude.EZvirus.Severity <= 0 then
			dude.EZvirus.Immune = true

			if dude.PrintMessage then
				dude:PrintMessage(HUD_PRINTTALK, "You are now immune to the JMod virus.")
			end
		end
	end
end

local function OpenChute(ply)
	ply:EmitSound("JMod_ZipLine_Clip")
	ply:SetNW2Bool("EZparachuting", true)
	local Chute = ents.Create("ent_jack_gmod_ezparachute")
	Chute:SetPos(ply:GetPos())
	Chute:SetNW2Entity("Owner", ply)
	for k, v in pairs(ply.EZarmor.items) do
		if JMod.ArmorTable[v.name].eff and JMod.ArmorTable[v.name].eff.parachute then
			Chute.ParachuteName = ply.EZarmor.items[k].name
			Chute.ChuteColor = ply.EZarmor.items[k].col 
			break
		end
	end
	Chute:Spawn()
	Chute:Activate()
	ply.EZparachute = Chute
end

local function DetachChute(ply) 
	ply:ViewPunch(Angle(5, 0, 0))
	ply:EmitSound("JMod_ZipLine_Clip")
	ply:SetNW2Bool("EZparachuting", false)
end

hook.Add("KeyPress", "JMOD_KEYPRESS", function(ply, key)
	if ply:GetMoveType() ~= MOVETYPE_WALK then return end
	if ply.IsProne and ply:IsProne() then return end
	if not(ply.EZarmor and ply.EZarmor.effects and ply.EZarmor.effects.parachute) then return end

	local IsParaOpen = ply:GetNW2Bool("EZparachuting", false) or IsValid(ply.EZparachute)
	if key == IN_JUMP and not IsParaOpen and not ply:OnGround() then
		if not(util.QuickTrace(ply:GetShootPos(), Vector(0, 0, -350), ply).Hit) then
			if ply:GetVelocity():Length() > 250 then OpenChute(ply) end
		end
	end

	if IsFirstTimePredicted() and key == IN_JUMP and ply:KeyDown(JMod.Config.General.AltFunctionKey) and IsParaOpen then
		DetachChute(ply)
	end
end)

hook.Add("OnPlayerHitGround", "JMOD_HITGROUND", function(ply, water, float, speed)
	--print("Player: " .. tostring(ply) .. " hit ", (water and "water") or "ground", "floater: " .. tostring(float), "Going: " .. tostring(speed))
	if ply:GetNW2Bool("EZparachuting", false) then
		timer.Simple(0.2, function()
			if IsValid(ply) and ply:Alive() then
				ply:ViewPunch(Angle(2, 0, 0))
				if ply:OnGround() then
					DetachChute(ply)
				end
			end
		end)
	end
end)



local NextMainThink, NextNutritionThink, NextArmorThink, NextSlowThink, NextNatrualThink, NextSync = 0, 0, 0, 0, 0, 0
local WindChange = Vector(0, 0, 0)

hook.Add("Think", "JMOD_SERVER_THINK", function()
	--[[
	if(A<CurTime())then
		A=CurTime()+1
		JMod.Sploom(game.GetWorld(),Vector(0,0,0),10)
		JMod.FragSplosion(game.GetWorld(),Vector(0,0,0),3000,80,5000,game.GetWorld())
	end
	--]]
	--[[
	local Pos=ents.FindByClass("sky_camera")[1]:GetPos()
	local AAA=util.TraceLine({
		start=Pos+Vector(0,0,1000),
		endpos=player.GetAll()[1]:GetShootPos()+Vector(0,0,100),
		filter=player.GetAll()[1]
	})
	if(AAA.Hit)then jprint("VALID") else jprint("INVALID") end
	--]]
	--[[
	local ply=player.GetAll()[1]
	local pos=ply:GetPos()
	for k,v in pairs(ents.FindInSphere(pos,600))do
		if(v.GetPhysicsObject)then
			local Phys=v:GetPhysicsObject()
			if(IsValid(Phys))then
				local vec=(v:GetPos()-pos):GetNormalized()
				Phys:ApplyForceCenter(-vec*400)
			end
		end
	end
	--]]
	local Time = CurTime()
	if NextMainThink > Time then return end
	NextMainThink = Time + 1

	local Playas = player.GetAll()
	---
	for i = 1, #Playas do
		local playa = Playas[i]
		if playa:Alive() then

			if playa.EZhealth then
				local Healin = playa.EZhealth

				if Healin > 0 then
					local Amt = 1

					if math.random(1, 3) == 2 then
						Amt = 2
					end

					playa.EZhealth = Healin - Amt
					local Helf, Max = playa:Health(), playa:GetMaxHealth()

					if Helf < Max then
						playa:SetHealth(math.Clamp(Helf + Amt, 0, Max))

						if playa:Health() == Max then
							playa:RemoveAllDecals()
						end
					end
				end
			end

			if playa.EZbleeding then
				local Bleed = playa.EZbleeding

				if Bleed > 0 then
					local Amt = JMod.Config.QoL.BleedSpeedMult
					playa.EZbleeding = math.Clamp(Bleed - Amt, 0, 9e9)
					local Dmg = DamageInfo()
					Dmg:SetAttacker((IsValid(playa.EZbleedAttacker) and playa.EZbleedAttacker) or game.GetWorld())
					Dmg:SetInflictor(game.GetWorld())
					Dmg:SetDamage(Amt)
					Dmg:SetDamageType(DMG_GENERIC)
					Dmg:SetDamagePosition(playa:GetShootPos())
					playa:TakeDamageInfo(Dmg)
					net.Start("JMod_SFX")
					net.WriteString("snds_jack_gmod/quiet_heartbeat.wav")
					net.Send(playa)
					JMod.Hint(playa, "bleeding")
					--
					local Tr = util.QuickTrace(playa:GetShootPos() + VectorRand() * 30, Vector(0, 0, -150), playa)

					if Tr.Hit then
						util.Decal("Blood", Tr.HitPos + Tr.HitNormal, Tr.HitPos - Tr.HitNormal)
					end
				end
				JMod.SyncBleeding(playa)
			end

			if playa.EZirradiated then
				local Rads = playa.EZirradiated

				if (Rads > 0) and (math.random(1, 3) == 1) then
					playa.EZirradiated = math.Clamp(Rads - .5, 0, 9e9)
					local Dmg = DamageInfo()
					Dmg:SetAttacker(playa)
					Dmg:SetInflictor(game.GetWorld())
					Dmg:SetDamage(1)
					Dmg:SetDamageType(DMG_GENERIC)
					Dmg:SetDamagePosition(playa:GetShootPos())
					playa:TakeDamageInfo(Dmg)
				end
			end

			VirusHostThink(playa)

			if JMod.Config.QoL.Drowning then
				if playa:WaterLevel() >= 3 then
					if (playa.EZarmoor and playa.EZarmor.effects.scuba) then
						playa.EZoxygen = math.Clamp(playa.EZoxygen + 3, 0, 100)
					else
						playa.EZoxygen = math.Clamp(playa.EZoxygen - 1.67, 0, 100) -- 60 seconds before damage
					end

					if playa.EZoxygen <= 25 then
						playa.EZneedGasp = true
					end

					if playa.EZoxygen <= 0 then
						local Dmg = DamageInfo()
						Dmg:SetDamageType(DMG_DROWN)
						Dmg:SetDamage(5)
						Dmg:SetAttacker(playa)
						Dmg:SetInflictor(game.GetWorld())
						Dmg:SetDamagePosition(playa:GetPos())
						Dmg:SetDamageForce(Vector(0, 0, 0))
						playa:TakeDamageInfo(Dmg)
						--
						net.Start("JMod_VisionBlur")
						net.WriteFloat(4)
						net.WriteFloat(3)
						net.WriteBit(false)
						net.Send(playa)
					end
				elseif playa.EZoxygen < 100 then
					if playa.EZneedGasp then
						sound.Play("snds_jack_gmod/drown_gasp.wav", playa:GetShootPos(), 60, math.random(90, 110))
						playa.EZneedGasp = false
					end

					playa.EZoxygen = math.Clamp(playa.EZoxygen + 25, 0, 100) -- recover in 4 seconds
				end
			end
		end
	end

	---
	if NextNutritionThink < Time then
		NextNutritionThink = Time + 10 / JMod.Config.FoodSpecs.DigestSpeed

		for _, playa in ipairs(Playas) do
			if playa.EZnutrition then
				if playa:Alive() then
					local InBed = IsValid(playa:GetVehicle()) and (playa:GetVehicle():GetParent() == playa.JModSpawnPointEntity)
					local RestMult = 1
					if InBed then
						RestMult = 2
					end
					local Nuts = playa.EZnutrition.Nutrients

					if Nuts > 0 then
						playa.EZnutrition.Nutrients = Nuts - 1 * RestMult
						local Helf, Max, Nuts = playa:Health(), playa:GetMaxHealth()

						if Helf < Max then
							playa:SetHealth(Helf + 1)

							if playa:Health() == Max then
								playa:RemoveAllDecals()
							end
						elseif math.Rand(0, 1) < .75 then
							local BoostMult = JMod.Config.FoodSpecs.BoostMult * RestMult
							local BoostedFrac = (Helf - Max) / Max

							if math.Rand(0, 1) > BoostedFrac then
								playa:SetHealth(Helf + BoostMult)

								if playa:Health() >= Max then
									playa:RemoveAllDecals()
								end
							end
						end
					end
					if Nuts > 100 then
						if math.random(1, 3) == 3 then
							playa:ViewPunch(Angle(math.random(2, 3), 0, 0))
							playa:EmitSound("snd_jack_jmod_burp.wav", 100, math.random(80, 100))
						end
					end
				end
			end
		end
	end

	---
	if NextArmorThink < Time then
		NextArmorThink = Time + 2

		for _, playa in ipairs(Playas) do
			if playa.EZarmor and playa:Alive() then
				if playa.EZarmor.effects.nightVision then
					for id, armorData in pairs(playa.EZarmor.items) do
						local Info = JMod.ArmorTable[armorData.name]

						if Info.eff and Info.eff.nightVision then
							armorData.chrg.power = math.Clamp(armorData.chrg.power - JMod.Config.Armor.ChargeDepletionMult / 10, 0, 9e9)

							if armorData.chrg.power <= Info.chrg.power * .25 then
								JMod.EZarmorWarning(playa, "Night vision charge is low ("..tostring(armorData.chrg.power).."/"..tostring(Info.chrg.power)..")")
							end
						end
					end
				elseif playa.EZarmor.effects.thermalVision then
					for id, armorData in pairs(playa.EZarmor.items) do
						local Info = JMod.ArmorTable[armorData.name]

						if Info.eff and Info.eff.thermalVision then
							armorData.chrg.power = math.Clamp(armorData.chrg.power - JMod.Config.Armor.ChargeDepletionMult / 10, 0, 9e9)

							if armorData.chrg.power <= Info.chrg.power * .25 then
								JMod.EZarmorWarning(playa, "Thermal vision charge is low ("..tostring(armorData.chrg.power).."/"..tostring(Info.chrg.power)..")")
							end
						end
					end
				end

				if playa.EZarmor.effects.scuba then
					for id, armorData in pairs(playa.EZarmor.items) do
						local Info = JMod.ArmorTable[armorData.name]

						if Info.eff and Info.eff.scuba then
							armorData.chrg.gas = math.Clamp(armorData.chrg.gas - JMod.Config.Armor.ChargeDepletionMult / 10, 0, 9e9)

							if armorData.chrg.gas <= Info.chrg.gas * .25 then
								JMod.EZarmorWarning(playa, "SCBA breathing gas charge is low ("..tostring(armorData.chrg.gas).."/"..tostring(Info.chrg.gas)..")")
							end
						end
					end
				end

				JMod.CalcSpeed(playa)
				JMod.EZarmorSync(playa)
			end
		end
	end

	---
	if NextSlowThink < Time then
		NextSlowThink = Time + 2

		if JMod.Config.QoL.ExtinguishUnderwater then
			for k, v in pairs(ents.GetAll()) do
				if v.IsOnFire and v.WaterLevel then
					if v:IsOnFire() and (v:WaterLevel() >= 3) then
						v:Extinguish()
					end
				end
			end
		end
	end

	---
	for _, v in ipairs(ents.FindByClass("npc_*")) do
		VirusHostThink(v)

		if v.EZNPCincapacitate then
			if v.EZNPCincapacitate > Time then
				if not v.EZNPCincapacitated then
					v:SetNPCState(NPC_STATE_PLAYDEAD)
					v.EZNPCincapacitated = true
				end
			elseif v.EZNPCincapacitated then
				v:SetNPCState(NPC_STATE_ALERT)
				v.EZNPCincapacitated = false
			end
		end
	end

	---
	if NextNatrualThink < Time then
		NextNatrualThink = Time + 5
		JMod.Wind = JMod.Wind + WindChange / 10
		SetGlobal2Vector("JMod_Wind", JMod.Wind)

		if JMod.Wind:Length() > 1 then
			JMod.Wind:Normalize()
			WindChange = -WindChange
		end
	
		WindChange = WindChange + Vector(math.Rand(-.5, .5), math.Rand(-.5, .5), 0)
	
		if WindChange:Length() > 1 then
			WindChange:Normalize()
		end
	end

	---
	if NextSync < Time then
		NextSync = Time + 30
		JMod.LuaConfigSync(false)
	end
end)

function JMod.LuaConfigSync(copyArmorOffsets)
	local ToSend = {}
	ToSend.ArmorOffsets = (JMod.LuaConfig and JMod.LuaConfig.ArmorOffsets) or {}
	ToSend.AltFunctionKey = JMod.Config.General.AltFunctionKey
	ToSend.WeaponSwayMult = JMod.Config.Weapons.SwayMult
	ToSend.Blackhole = JMod.Config.Machines.Blackhole
	ToSend.CopyArmorOffsets = copyArmorOffsets or false
	net.Start("JMod_LuaConfigSync")
		net.WriteData(util.Compress(util.TableToJSON(ToSend)))
	net.Broadcast()
end

concommand.Add("jmod_force_lua_config_sync", function(ply, cmd, args)
	if ply and not ply:IsSuperAdmin() then return end
	JMod.LuaConfigSync(true)
end, nil, "Manually forces the Lua Config for Jmod to sync.")

concommand.Add("jacky_trace_debug", function(ply)
	if not GetConVar("sv_cheats"):GetBool() then return end
	local Tr = ply:GetEyeTrace()
	print("--------- trace results ----------")
	PrintTable(Tr)
	local Props = util.GetSurfaceData(Tr.SurfaceProps)

	if Props then
		print("----------- surface properties ----------")
		PrintTable(Props)
	end

	if Tr.Entity then
		print("----------- entity properties -----------")
		local Ent = Tr.Entity
		print(Ent)
		print("physmat", Ent:GetPhysicsObject():GetMaterial())
		print("mass", Ent:GetPhysicsObject():GetMass())
		print("model", Ent:GetModel())
		---
		if Ent == game.GetWorld() then return end
		print("----------- entity animation data -----------")

		for k, v in pairs(Ent:GetSequenceList()) do
			print("---", k, v, "---")
			PrintTable(Ent:GetSequenceInfo(k))
		end

		print("num pose params", Ent:GetNumPoseParameters())
		local Boobies = Ent:GetAnimCount()
		print("anim count", Boobies)

		for i = 0, Boobies do
			print("--- anim ---")
			local Tab = Ent:GetAnimInfo(i)

			if Tab then
				PrintTable(Tab)
			end
		end

		print("----------- entity bone data -----------")

		for i = 0, 100 do
			local Boner = Ent:GetBoneName(i)

			if Boner and not string.find(Boner, "INVALID") then
				print("bone", i, Boner)
			end
		end
	end

	print("---------- end trace debug -----------")
end, nil, "Prints information about what the player's crosshair is looking at.")

concommand.Add("jacky_player_debug", function(ply, cmd, args)
	if not GetConVar("sv_cheats"):GetBool() then return end
	if not ply:IsSuperAdmin() then return end

	for k, v in pairs(player.GetAll()) do
		if v ~= ply then
			v:SetPos(ply:GetPos() + Vector(100 * k, 0, 0))
			v:SetHealth(100)
		end
	end
end, nil, "(CHEAT, ADMIN ONLY) Resets players' health.")

hook.Add("GetFallDamage", "JMod_FallDamage", function(ply, spd)
	if JMod.Config.QoL.RealisticFallDamage then return spd ^ 2 / 8000 end
end)

hook.Add("DoPlayerDeath", "JMOD_SERVER_DOPLAYERDEATH", function(ply, attacker, dmg)
	ply.EZnutrition = nil
	ply.EZhealth = nil
	ply.EZkillme = nil
	ply.EZoverDamage = dmg:GetDamage()
	--jprint(ply:Health(), ply.EZoverDamage)

	if ply.JackyMatDeathUnset then
		ply.JackyMatDeathUnset = false
		ply:SetMaterial("")
	end
end)

--hook.Remove("PlayerDeath", "JMOD_SERVER_PLAYERPARADEATH")
hook.Add("PlayerDeath", "JMOD_SERVER_PLAYERDEATH", function(ply, inflictor, attacker)
	if (JMod.Config.QoL.JModCorpseStayTime > 0) and ply.EZarmor and ply.EZarmor.items then
		SafeRemoveEntity(ply:GetRagdollEntity())
		local EZcorpse = ents.Create("ent_jack_gmod_ezcorpse")
		EZcorpse.DeadPlayer = ply
		if ply.EZoverDamage then
			EZcorpse.EZoverDamage = ply.EZoverDamage
		end
		EZcorpse:Spawn()
		EZcorpse:Activate()
	end
	ply.EZoverDamage = nil
end)

concommand.Add("jmod_debug_parachute", function(ply, cmd, args) 
	if IsValid(ply) and not ply:IsSuperAdmin() then return end
	local Tr = ply:GetEyeTrace()
	local Ent = Tr.Entity
	if IsValid(Ent) then
		local Chute = ents.Create("ent_jack_gmod_ezparachute")
		Chute:SetPos(Ent:GetPos())
		Chute:SetNW2Entity("Owner", Ent)
		Chute.ParachuteName = "Parachute"
		for k, v in pairs(ply.EZarmor.items) do
			if JMod.ArmorTable[v.name].eff and JMod.ArmorTable[v.name].eff.parachute then
				Chute.ChuteColor = ply.EZarmor.items[k].col 
				break
			end
		end
		Chute:Spawn()
		Chute:Activate()
		Ent:SetNW2Bool("EZparachuting", true)
		Ent.EZparachute = Chute
	end
end, nil, "Apply's an EZ parachute to an entity")

hook.Add("PlayerLeaveVehicle", "JMOD_LEAVEVEHICLE", function(ply, veh)
	if veh.EZvehicleEjectPos then
		local WorldPos = veh:LocalToWorld(veh.EZvehicleEjectPos)
		local Tr = util.TraceLine({
			start = veh:LocalToWorld(veh:OBBCenter()),
			endpos = WorldPos,
			mask = MASK_SOLID,
			filter = {ply, veh, veh:GetParent()}
		})
		if not Tr.Hit then ply:SetPos(veh:LocalToWorld(veh.EZvehicleEjectPos)) end
		veh.EZvehicleEjectPos = nil
	end
end)

function JMod.EZ_Remote_Trigger(ply)
	if not IsValid(ply) then return end
	if not ply:Alive() then return end
	sound.Play("snd_jack_detonator.wav", ply:GetShootPos(), 55, math.random(90, 110))

	timer.Simple(.75, function()
		if IsValid(ply) and ply:Alive() then
			for k, v in pairs(ents.GetAll()) do
				if v.JModEZremoteTriggerFunc and v.EZowner and (v.EZowner == ply) then
					v:JModEZremoteTriggerFunc(ply)
				end
			end
		end
	end)
end

hook.Add("PlayerCanSeePlayersChat", "JMOD_PLAYERSEECHAT", function(txt, teamOnly, listener, talker)
	if not IsValid(talker) then return end
	if talker.EZarmor and talker.EZarmor.effects.teamComms then return JMod.PlayersCanComm(listener, talker) end
end)

hook.Add("PlayerCanHearPlayersVoice", "JMOD_PLAYERHEARVOICE", function(listener, talker)
	if talker.EZarmor and talker.EZarmor.effects.teamComms then return JMod.PlayersCanComm(listener, talker) end
end)
