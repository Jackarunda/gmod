JMod.Wind = Vector(0, 0, 0)
local force_workshop = CreateConVar("jmod_forceworkshop", 1, {FCVAR_ARCHIVE}, "Force clients to download JMod+its content? (requires a restart upon change)")

if force_workshop:GetBool() then
	resource.AddWorkshop("1919689921")
end

local function JackaSpawnHook(ply, transition)
	if transition then return end
	ply.EZragdoll = nil
	ply.JModFriends = ply.JModFriends or {}
	ply.JModInv = ply.JModInv or table.Copy(JMod.DEFAULT_INVENTORY)

	JMod.EZarmorSync(ply)
	JMod.CalcSpeed(ply)
	ply.EZoxygen = 100
	ply.EZbleeding = 0
	JMod.SyncBleeding(ply)

	timer.Simple(0, function()
		if IsValid(ply) then
			ply.EZoriginalPlayerModel = ply:GetModel()
			if ply.EZarmor.suited then
				for k, v in pairs(ply.EZarmor.items) do
					local ArmorInfo = JMod.ArmorTable[v.name]
		
					if ArmorInfo.plymdl then
						JMod.SetPlayerModel(ply, ArmorInfo.plymdl)
					end
				end
			end
		end
	end)

	if JMod.Config.Explosives.BombOwnershipLossOnRespawn then
		for k, ent in ents.Iterator() do
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
	
	-- Greetings, Reclaimer. I am 343 Guilty Spark, monitor of Installation 04
	timer.Simple(1, function()
		if (IsValid(ply)) then
			if not(ply.JMod_DidPlayerReclaimItems) then
				local PlayerTeam = ply:Team()
				-- this will only run once per player per session
				local ID, num = ply:SteamID64(), 0
				for k, v in ents.Iterator() do
					if (v.EZownerID and v.EZownerID == ID) then
						local EntLastKnownTeam = v.EZownerTeam or TEAM_UNASSIGNED
						if (EntLastKnownTeam == PlayerTeam) then
							JMod.SetEZowner(v, ply)
							num = num + 1
						else
							JMod.SetEZowner(v, game.GetWorld(), true)
						end
					end
				end
				ply.JMod_DidPlayerReclaimItems = true
				if (num > 0) then ply:PrintMessage(HUD_PRINTTALK, "JMod: you reclaimed control of " .. num .. " JMod items") end
			end
		end
	end)

	net.Start("JMod_PlayerSpawn")
	net.WriteBit(JMod.Config.General.Hints)
	net.Send(ply)
end

hook.Add("PlayerSpawn", "JMod_PlayerSpawn", JackaSpawnHook)
hook.Add("PlayerInitialSpawn", "JMod_PlayerInitialSpawn", function(ply, transit) 
	JackaSpawnHook(ply, transit)
	timer.Simple(0, function()
		if not IsValid(ply) then return end
		JMod.LuaConfigSync(true, ply)
		JMod.CraftablesSync(ply) 
	end)
end)

hook.Add("PlayerSelectSpawn", "JMod_SleepingBagSpawn", function(ply, transition) 
	if transition then return end
	ply.JModSpawnTime = CurTime()
	local STATE_ROLLED, STATE_UNROLLED = 0, 1
	local Sleepingbag = ply.JModSpawnPointEntity
	if IsValid(Sleepingbag) and (Sleepingbag.State == STATE_UNROLLED) and (IsValid(Sleepingbag.Pod)) then
		if (Sleepingbag.nextSpawnTime < ply.JModSpawnTime) then
			Sleepingbag.nextSpawnTime = ply.JModSpawnTime + 60
			if not IsValid(Sleepingbag.Pod:GetDriver()) then --Get inside when respawn
				ply:SetPos(Sleepingbag:GetPos())
				Sleepingbag.Pod:Fire("EnterVehicle", "nil", 0, ply, ply)
				net.Start("JMod_VisionBlur")
					net.WriteFloat(5)
					net.WriteFloat(2000)
					net.WriteBit(true)
				net.Send(ply)
				Sleepingbag.Pod.EZvehicleEjectPos = nil
				
				return Sleepingbag
			end
		else
			JMod.Hint(ply,"sleeping bag wait")
		end
	end
end)

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
	if ent.JModDontIrradiate then return not ent.JModDontIrradiate end
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
	ply:EmitSound("snds_jack_gmod/geiger" .. Num .. ".ogg", 55, math.random(95, 105))
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

		if (DmgTaken > 1) and JMod.Config.Explosives.Nuke.RadiationSickness then
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

	if hostFaceProt > 0 then
		Range = Range * (1 - (hostFaceProt) / 1)
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
			local VictimFaceProtection, VictimSkinProtection = JMod.GetArmorBiologicalResistance(obj, DMG_NERVEGAS)

			if VictimFaceProtection > 0 then
				Chance = Chance * (1 - (VictimFaceProtection) / 1)
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

	local VirusAttacker = (IsValid(ply.EZvirus.Attacker) and ply.EZvirus.Attacker) or game.GetWorld()
	local Dmg = DamageInfo()
	Dmg:SetDamageType(DMG_GENERIC) -- why aint this working to hazmat wearers?
	Dmg:SetAttacker(VirusAttacker)
	Dmg:SetInflictor(ply)
	Dmg:SetDamagePosition(ply:GetPos())
	Dmg:SetDamageForce(Vector(0, 0, 0))
	Dmg:SetDamage(1)
	ply:TakeDamageInfo(Dmg)
	--
	local HostFaceProtection, HostSkinProtection = JMod.GetArmorBiologicalResistance(ply, DMG_RADIATION)
	if (HostFaceProtection + HostSkinProtection) >= 2 then return end
	JMod.TryVirusInfectInRange(ply, VirusAttacker, HostFaceProtection, HostSkinProtection)

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

local function ImmobilizedThink(dude)
	local Time = CurTime()
	dude.EZImmobilizationTime = 0
	if dude.EZimmobilizers and next(dude.EZimmobilizers) and dude:Alive() then
		for immobilizer, immobilizeTime in pairs(dude.EZimmobilizers) do
			if not(IsValid(immobilizer)) or (immobilizer.GetTrappedPlayer and (immobilizer:GetTrappedPlayer() ~= dude)) or (immobilizeTime < Time) then
				dude.EZimmobilizers[immobilizer] = nil
			else
				dude.EZImmobilizationTime = math.max(dude.EZImmobilizationTime, immobilizeTime)
			end
		end
	else
		dude.EZimmobilizers = nil
	end
end

--- Sleepy Logic

local function SleepySitThink(dude)
	local Time = CurTime()
	if dude.JMod_IsSleeping then
		if dude:Health() < (dude:GetMaxHealth() * .15) then
			dude.EZhealth = math.max(dude.EZhealth or 0, 1)
		end
	end
end

--- Egg hunt logic

local SpawnFails=0
// copied from Homicide
function JMod.FindHiddenSpawnLocation()
	local DistMul, InitialDist, MinAddDist, SpawnExclusionDist = 10, 200, 300, 1000
	local SpawnPos, Tries, Players, TryDist = nil, 0, player.GetAll(), InitialDist * DistMul
	local NoBlockEnts = {}
	table.Add(NoBlockEnts, Players)
	for key, potential in pairs(Players) do
		if not (potential:Alive()) then table.remove(Players, key) end
	end
	if (#Players < 1) then return nil end
	local SelectedPlaya = table.Random(Players)
	local Origin = SelectedPlaya:GetPos()
	while ((SpawnPos == nil) and (TryDist <= 9000 * DistMul)) do
		while ((SpawnPos == nil) and (Tries < 15)) do
			local RandVec, Below, Vertical = VectorRand() * (math.Rand(10, TryDist) + MinAddDist), false, 0
			if (math.random(1, 3) == 2) then RandVec.z = math.abs(RandVec.z) end
			RandVec.z = RandVec.z / 2
			if (math.random(1, 3) == 2) then RandVec.z = RandVec.z / 2 end
			Vertical = RandVec.z
			local TryPos = Origin + RandVec
			if (util.IsInWorld(TryPos)) then
				local Contents = util.PointContents(TryPos)
				if ((Contents == CONTENTS_EMPTY) or (Contents == CONTENTS_TESTFOGVOLUME)) then
					local Close = false
					for key, plaiyah in pairs(Players) do -- spawn may not be close to a player
						if(TryPos:Distance(plaiyah:GetPos()) < MinAddDist) then Close=true; break end
					end
					if not (Close) then
						local AboveGround = true
						if (Vertical < 0) then -- if the pos is below the player, then the player must be standing on something
							local UpTr = util.QuickTrace(TryPos, Vector(0, 0, -Vertical + 10), Players) -- we therefore should be able to detect that something
							if not (UpTr.Hit) then AboveGround=false end -- if we can't, then the pos is probably below the surface of "solid" groud
						elseif (Vertical > 0) then -- if the pos is above the player, there's gotta be something that we can fall onto
							local DownTr = util.QuickTrace(TryPos, Vector(0, 0, -Vertical * 5), Players) -- try to detect the surface we're gonna fall on
							if not (DownTr.Hit) then AboveGround = false end -- if we can't see anything that far down, we're probably below the ground
						end
						if (AboveGround) then
							local FinalDownTr = util.QuickTrace(TryPos, Vector(0, 0, -20000), NoBlockEnts)
							if (FinalDownTr.Hit) then
								TryPos = FinalDownTr.HitPos + Vector(0, 0, 10)
								local CanSee = false
								for key, ply in pairs(Players) do
									if (ply:Alive()) then
										local ToTrace = util.TraceLine({start = ply:GetShootPos(), endpos = TryPos + Vector(0, 0, 10), filter = NoBlockEnts})
										if not (ToTrace.Hit) then
											CanSee = true
											break
										end
										local ToTrace2 = util.TraceLine({start = ply:GetShootPos(), endpos = TryPos - Vector(0, 0, 10), filter = NoBlockEnts})
										if not (ToTrace2.Hit) then
											CanSee=true
											break
										end
									end
								end
								for key, cayum in pairs(ents.FindByClass("sky_camera")) do -- don't spawn shit in the skybox you stupid fucking game
									local ToTrace = util.TraceLine({start = cayum:GetPos(), endpos = TryPos})
									if not (ToTrace.Hit) then
										CanSee = true
										break
									end
								end
								if not (CanSee) then
									SpawnPos = TryPos
								end
							end
						end
					end
				end
			end
			Tries=Tries + 1
		end
		TryDist = TryDist + 200 * DistMul
		Tries=0
	end
	if(SpawnPos == nil)then
		SpawnFails=SpawnFails + 1
	else
		SpawnFails = 0
	end
	return SpawnPos
end

local NextEasterThink = 0
local function EasterEggThink(dude)
	local Time = CurTime()
	if (Time > NextEasterThink) then
		NextEasterThink = Time + 50
		local Pos = JMod.FindHiddenSpawnLocation()
		if (Pos) then
			local Eg = ents.Create("ent_jack_gmod_ezeasteregg")
			Eg:SetPos(Pos)
			Eg:SetAngles(AngleRand())
			Eg:Spawn()
			Eg:Activate()
		end
	end
end

--- PARACHUTE LOGIC

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
	if not(JMod.PlyHasArmorEff(ply, "parachute")) then return end

	local IsParaOpen = ply:GetNW2Bool("EZparachuting", false) or IsValid(ply.EZparachute)
	if key == IN_JUMP and not IsParaOpen and not ply:OnGround() then
		if not(util.QuickTrace(ply:GetShootPos(), Vector(0, 0, -350), ply).Hit) then
			if ply:GetVelocity():Length() > 250 then OpenChute(ply) end
		end
	end

	if IsFirstTimePredicted() and key == IN_JUMP and JMod.IsAltUsing(ply) and IsParaOpen then
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

	if JMod.GetHoliday() == "Easter" then
		EasterEggThink()
	end

	local PlyIterator, Playas, startingindex = player.Iterator()
	---
	for k, playa in PlyIterator, Playas, startingindex do

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
					net.WriteString("snds_jack_gmod/quiet_heartbeat.ogg")
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
					if (playa.EZarmor and playa.EZarmor.effects.scuba) then
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
						sound.Play("snds_jack_gmod/drown_gasp.ogg", playa:GetShootPos(), 60, math.random(90, 110))
						playa.EZneedGasp = false
					end

					playa.EZoxygen = math.Clamp(playa.EZoxygen + 25, 0, 100) -- recover in 4 seconds
				end
			end

			ImmobilizedThink(playa)

			SleepySitThink(playa)
		end
	end

	---
	if NextNutritionThink < Time then
		NextNutritionThink = Time + 10 / JMod.Config.FoodSpecs.DigestSpeed

		for _, playa in PlyIterator, Playas, startingindex do
			if playa.EZnutrition then
				if playa:Alive() then
					local RestMult = 1
					if playa.JMod_IsSleeping then
						RestMult = 2
					end
					local Nuts = playa.EZnutrition.Nutrients

					if Nuts > 0 then
						playa.EZnutrition.Nutrients = Nuts - 1
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
							playa:EmitSound("snd_jack_jmod_burp.ogg", 100, math.random(80, 100))
						end
					end
				end
			end
		end
	end

	---
	if NextArmorThink < Time then
		NextArmorThink = Time + 2

		for _, playa in PlyIterator, Playas, startingindex do

			if playa.EZarmor and playa:Alive() then
				local ArmorEffs = playa.EZarmor.effects or {}

				if ArmorEffs.nightVision or ArmorEffs.thermalVision or ArmorEffs.tacticalVision then
					for id, armorData in pairs(playa.EZarmor.items) do
						if armorData.chrg then
							local Info = JMod.ArmorTable[armorData.name]

							if Info.eff then 
								if Info.eff.nightVision then
									armorData.chrg.power = math.Clamp(armorData.chrg.power - JMod.Config.Armor.ChargeDepletionMult / 10, 0, 9e9)

									if armorData.chrg.power <= Info.chrg.power * .2 then
										JMod.EZarmorWarning(playa, "Night vision charge is low ("..tostring(armorData.chrg.power).."/"..tostring(Info.chrg.power)..")")
									end
								end

								if Info.eff.thermalVision then
									armorData.chrg.power = math.Clamp(armorData.chrg.power - JMod.Config.Armor.ChargeDepletionMult / 10, 0, 9e9)
	
									if armorData.chrg.power <= Info.chrg.power * .2 then
										JMod.EZarmorWarning(playa, "Thermal vision charge is low ("..tostring(armorData.chrg.power).."/"..tostring(Info.chrg.power)..")")
									end
								end

								if Info.eff.tacticalVision then
									armorData.chrg.power = math.Clamp(armorData.chrg.power - JMod.Config.Armor.ChargeDepletionMult / 10, 0, 9e9)
	
									if armorData.chrg.power <= Info.chrg.power * .2 then
										JMod.EZarmorWarning(playa, "Tactical vision charge is low ("..tostring(armorData.chrg.power).."/"..tostring(Info.chrg.power)..")")
									end
								end
							end
						end
					end
				end

				if ArmorEffs.scuba then
					for id, armorData in pairs(playa.EZarmor.items) do
						local Info = JMod.ArmorTable[armorData.name]

						if (Info.eff and Info.eff.scuba) and (armorData.chrg and armorData.chrg.gas) then
							armorData.chrg.gas = math.Clamp(armorData.chrg.gas - JMod.Config.Armor.ChargeDepletionMult / 10, 0, 9e9)

							if armorData.chrg.gas <= Info.chrg.gas * .25 then
								JMod.EZarmorWarning(playa, "SCBA breathing gas charge is low ("..tostring(armorData.chrg.gas).."/"..tostring(Info.chrg.gas)..")")
							end
						end
					end
				end

				if ArmorEffs.weapon then
					for id, armorData in pairs(playa.EZarmor.items) do
						local Info = JMod.ArmorTable[armorData.name]

						if Info.eff and Info.eff.weapon then
							if not playa:HasWeapon(Info.eff.weapon) then
								local Sweppy = playa:Give(Info.eff.weapon)
								playa:SelectWeapon(Sweppy)
								Sweppy.EZarmorID = id
							end
						end
					end
				end

				if ArmorEffs.chargeEquipped then
					for id, armorData in pairs(playa.EZarmor.items) do
						local Info = JMod.ArmorTable[armorData.name]

						if Info.eff and Info.eff.chargeEquipped then
							local SubtractCharge = armorData.chrg and armorData.chrg.power
							
							local ArmorIDsToCharge = {}
							for id2, armorData2 in pairs(playa.EZarmor.items) do
								local Info2 = JMod.ArmorTable[armorData2.name]

								if not(Info2.eff and Info2.eff.chargeEquipped) and armorData2.chrg and armorData2.chrg.power and (armorData2.chrg.power < Info2.chrg.power) then
									table.insert(ArmorIDsToCharge, id2)
								end
							end

							for i = 1, #ArmorIDsToCharge do
								local id2 = ArmorIDsToCharge[i]
								local armorData2 = playa.EZarmor.items[id2]
								local Info2 = JMod.ArmorTable[armorData2.name]

								local ChargeAmount = math.min(Info2.chrg.power - armorData2.chrg.power, armorData.chrg.power)

								armorData2.chrg.power = math.min(armorData2.chrg.power + ChargeAmount, Info2.chrg.power)
								if SubtractCharge then
									armorData.chrg.power = math.max(armorData.chrg.power - ChargeAmount, 0)
								end
							end
						end
					end
				end

				if ArmorEffs.chargeShield then
					for id, armorData in pairs(playa.EZarmor.items) do
						local Info = JMod.ArmorTable[armorData.name]

						if Info.eff and Info.eff.chargeShield then
							local SubtractCharge = armorData.chrg and armorData.chrg.power

							local PlyArmor, PlyMaxArmor = playa:Armor(), playa:GetMaxArmor()
							if PlyArmor < PlyMaxArmor then
								local MissingShields = math.max(PlyMaxArmor - PlyArmor, 0)
								local AvailablePower = SubtractCharge and armorData.chrg.power or 1
								local ConversionRatio = .75
								local AmountToCharge = math.min(AvailablePower * ConversionRatio, MissingShields, 2)

								armorData.chrg.power = math.max(armorData.chrg.power - (AmountToCharge / ConversionRatio), 0)
								playa:SetArmor(PlyArmor + AmountToCharge)
							end
						end
					end
				end

				--JMod.CalcSpeed(playa)
				--JMod.EZarmorSync(playa)
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
end)

function JMod.LuaConfigSync(copyArmorOffsets, ply)
	local ToSend = {}
	ToSend.AltFunctionKey = JMod.Config.General.AltFunctionKey
	ToSend.WeaponSwayMult = JMod.Config.Weapons.SwayMult
	ToSend.Blackhole = JMod.Config.Machines.Blackhole
	ToSend.QoL = table.FullCopy(JMod.Config.QoL)
	ToSend.MaxResourceMult = JMod.Config.ResourceEconomy.MaxResourceMult
	ToSend.Flashbang = JMod.Config.Explosives.Flashbang
	ToSend.ScoutIDwhitelist = table.FullCopy(JMod.Config.Armor.ScoutIDwhitelist)
	ToSend.ArmorOffsets = (copyArmorOffsets and JMod.LuaConfig and JMod.LuaConfig.ArmorOffsets) or nil
	
	net.Start("JMod_LuaConfigSync")
		net.WriteData(util.Compress(util.TableToJSON(ToSend)))
	if ply then 
		net.Send(ply)
	else
		net.Broadcast()
	end
end

function JMod.CraftablesSync(ply)
	local ToSend = {}
	ToSend.Craftables = table.FullCopy(JMod.Config.Craftables)
	ToSend.Orderables = table.FullCopy(JMod.Config.RadioSpecs.AvailablePackages)

	net.Start("JMod_LuaConfigSync")
		net.WriteData(util.Compress(util.TableToJSON(ToSend)))
	if ply and IsValid(ply) then
		net.Send(ply)
	else
		net.Broadcast()
	end
end

local PlyConfigRequestTimes = {}

net.Receive("JMod_LuaConfigSync", function(len, ply)
	local Time = CurTime()

	if PlyConfigRequestTimes[ply] and PlyConfigRequestTimes[ply] > Time then return end
	PlyConfigRequestTimes[ply] = Time + 5

	JMod.LuaConfigSync(false, ply)
	JMod.CraftablesSync(ply)
end)

concommand.Add("jmod_force_lua_config_sync", function(ply, cmd, args)
	if ply and not ply:IsSuperAdmin() then return end
	JMod.LuaConfigSync(true)
	JMod.CraftablesSync()
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

		print("---------- entity bodygroup data -----------")
		PrintTable(Ent:GetBodyGroups())
	end

	print("---------- end trace debug -----------")
end, nil, "Prints information about what the player's crosshair is looking at.")

concommand.Add("jacky_player_debug", function(ply, cmd, args)
	if not GetConVar("sv_cheats"):GetBool() then return end
	if not ply:IsSuperAdmin() then return end

	--[[local ValidEntNum = 1
	for k, v in ents.Iterator() do
		if IsValid(v) and v ~= ply and (v:IsPlayer() or string.find(v:GetClass(), "npc_")) then
			local Ang = ply:GetAngles()
			Ang:RotateAroundAxis(Ang:Up(), ValidEntNum * 42)
			local Dir = Ang:Forward()
			v:SetPos(ply:GetPos() + Dir * ValidEntNum * 100)
			v:SetHealth(100)
			ValidEntNum = ValidEntNum + 1
		end
	end--]]
	JMod.DebugArrangeEveryone(ply, args[1] or 1)
end, nil, "(CHEAT, ADMIN ONLY) Resets players' health.")

hook.Add("GetFallDamage", "JMod_FallDamage", function(ply, spd)
	--local ThiccPlayer = (ply.EZarmor and ply.EZarmor.totalWeight or 10) / 10 -- Maybe?
	if JMod.Config.QoL.RealisticFallDamage then return (spd ^ 2 / 8000) end
end)

hook.Add("DoPlayerDeath", "JMOD_SERVER_DOPLAYERDEATH", function(ply, attacker, dmg)
	
	ply.EZoverDamage = dmg:GetDamage()
	--jprint(ply:Health(), ply.EZoverDamage)

	if ply.JackyMatDeathUnset then
		ply.JackyMatDeathUnset = false
		ply:SetMaterial("")
	end
end)

hook.Add("PlayerDeath", "JMOD_SERVER_PLAYERDEATH", function(ply, inflictor, attacker)
	local ShouldJModCorpse = JMod.Config.QoL.JModCorpseStayTime > 0
	local EZcorpse
	if ShouldJModCorpse then
		local PlyRagdoll = ply:GetRagdollEntity()
		if IsValid(PlyRagdoll) then
			if ply.EZoriginalPlayerModel then
				JMod.SetPlayerModel(ply, ply.EZoriginalPlayerModel)
				PlyRagdoll:SetModel(ply.EZoriginalPlayerModel)
			end
			local BodyGroupValues = ""
			for i = 1, PlyRagdoll:GetNumBodyGroups() do
				BodyGroupValues = BodyGroupValues .. tostring(PlyRagdoll:GetBodygroup(i - 1))
			end
			SafeRemoveEntity(PlyRagdoll)
			EZcorpse = ents.Create("ent_jack_gmod_ezcorpse")
			EZcorpse.DeadPlayer = ply
			if ply.EZoverDamage then
				EZcorpse.EZoverDamage = ply.EZoverDamage
			end
			EZcorpse.BodyGroupValues = BodyGroupValues
			EZcorpse:Spawn()
			EZcorpse:Activate()
			if IsValid(EZcorpse.EZragdoll) then
				EZcorpse.EZragdoll.EZstorageSpace = JMod.GetStorageCapacity(ply) 
				ply.EZragdoll = EZcorpse.EZragdoll
			end
		end
	end

	ply:SetNW2Bool("EZrocketSpin", false)

	local ShouldInvDrop = JMod.Config.QoL.JModInvDropOnDeath
	if (ply.JModInv and (ShouldInvDrop or ShouldJModCorpse)) then
		local PlyPos = ply:GetPos()
		local ShouldTransfer = ShouldJModCorpse and not ShouldInvDrop
		for _, v in ipairs(ply.JModInv.items) do
			local RandomVec = Vector(math.random(-100, 100), math.random(-100, 100), math.random(0, 100))
			local Removed = JMod.RemoveFromInventory(ply, v.ent, PlyPos + RandomVec, false, ShouldTransfer)
			if ShouldTransfer and IsValid(Removed) then
				JMod.AddToInventory(EZcorpse.EZragdoll, Removed)
			end
		end
		for typ, amt in pairs(ply.JModInv.EZresources) do
			local RandomVec = Vector(math.random(-100, 100), math.random(-100, 100), math.random(0, 100))
			local RemovedTyp, Removed = JMod.RemoveFromInventory(ply, {typ, amt}, PlyPos + RandomVec, false, ShouldTransfer)
			if ShouldTransfer then
				JMod.AddToInventory(EZcorpse.EZragdoll, {RemovedTyp, Removed})
			end
		end
	end
end)

hook.Add("PostPlayerDeath", "JMod_PostPlayerDeath", function(ply)
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

	ply.EZnutrition = nil
	ply.EZhealth = nil
	ply.EZkillme = nil
	ply.EZoverDamage = nil
	ply.EZirradiated = nil
	ply.JMod_WillAsplode = nil
	ply.EZvirus = nil
	if ply:GetNW2Float("EZblastShock", 0) > 0 then
		ply:SetNW2Float("EZblastShock", 0)
	end
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
end, nil, "Applies an EZ parachute to an entity")

concommand.Add("jmod_debug_shieldbubble", function(ply, cmd, args) 
	if IsValid(ply) and not ply:IsSuperAdmin() then return end
	local Tr = ply:GetEyeTrace()
	local Ent = Tr.Entity
	local Shieldbubble = ents.Create("ent_jack_gmod_bubble_shield")
	local SizeClass = tonumber(SizeClass)
	if SizeClass then
		Shieldbubble:SetSizeClass(SizeClass)
	end
	Shieldbubble:SetPos(Tr.HitPos)
	if IsValid(Ent) then
		Shieldbubble.Projector = Ent
	end
	Shieldbubble:Spawn()
	Shieldbubble:Activate()
end, nil, "Applies an EZ shield to an entity with optional grade")

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

hook.Add("PlayerCanSeePlayersChat", "JMOD_PLAYERSEECHAT", function(txt, teamOnly, listener, talker)
	if not IsValid(talker) then return end
	if talker.EZarmor and talker.EZarmor.effects.teamComms then return JMod.PlayersCanComm(listener, talker) end
end)

hook.Add("PlayerCanHearPlayersVoice", "JMOD_PLAYERHEARVOICE", function(listener, talker)
	if talker.EZarmor and talker.EZarmor.effects.teamComms then return JMod.PlayersCanComm(listener, talker) end
end)

local function ResetBouyancy(ply, ent)
	if ent.EZbuoyancy then
		local phys = ent:GetPhysicsObject()
		timer.Simple(0, function()
			if IsValid(phys) then
				phys:SetBuoyancyRatio(ent.EZbuoyancy)
			end
		end)
	end
end

hook.Add("PhysgunDrop", "JMod_ResetBouyancy", ResetBouyancy)

hook.Add("GravGunDrop", "JMod_ResetBouyancy", ResetBouyancy)

hook.Add("GravGunPunt", "JMod_ResetBouyancy", ResetBouyancy)

hook.Add("OnPlayerPhysicsDrop", "JMod_ResetBouyancy", ResetBouyancy)

hook.Add("OnEntityWaterLevelChanged", "JMod_WaterExtinguish", function(ent, oldLevel, newLevel)
	if JMod.Config.QoL.ExtinguishUnderwater and (ent.IsOnFire and ent:IsOnFire()) then
		if (oldLevel == 0) and (newLevel > 0) then
			sound.Play("snds_jack_gmod/hiss.ogg", ent:GetPos(), 100, math.random(70, 80))--"snds_jack_gmod/hiss.ogg", ent:GetPos(), 100, math.random(90, 110))
		end
		ent:Extinguish()
	end
end)