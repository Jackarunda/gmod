-- this causes an object to rotate to point forward while moving, like a dart
function JMod.AeroDrag(ent, forward, mult, spdReq)
	if constraint.HasConstraints(ent) then return end
	if ent:IsPlayerHolding() then return end
	local Phys = ent:GetPhysicsObject()
	if not IsValid(Phys) then return end
	local Vel = Phys:GetVelocity()
	local Spd = Vel:Length()

	if not spdReq then
		spdReq = 300
	end

	if Spd < spdReq then return end
	mult = mult or 1
	local Pos, Mass = Phys:LocalToWorld(Phys:GetMassCenter()), Phys:GetMass()
	Phys:ApplyForceOffset(Vel * Mass / 6 * mult, Pos + forward)
	Phys:ApplyForceOffset(-Vel * Mass / 6 * mult, Pos - forward)
	Phys:AddAngleVelocity(-Phys:GetAngleVelocity() * Mass / 1000)
end

-- this causes an object to rotate to point and fly to a point you give it
function JMod.AeroGuide(ent, forward, targetPos, turnMult, thrustMult, angleDragMult, spdReq)
	--if(constraint.HasConstraints(ent))then return end
	--if(ent:IsPlayerHolding())then return end
	local Phys = ent:GetPhysicsObject()
	if not IsValid(Phys) then return end
	local Vel = Phys:GetVelocity()
	local Spd = Vel:Length()
	--if(Spd<spdReq)then return end
	local Pos, Mass = Phys:LocalToWorld(Phys:GetMassCenter()), Phys:GetMass()
	local TargetVec = targetPos - ent:GetPos()
	local TargetDir = TargetVec:GetNormalized()
	---
	Phys:ApplyForceOffset(TargetDir * Mass * turnMult * 5000, Pos + forward)
	Phys:ApplyForceOffset(-TargetDir * Mass * turnMult * 5000, Pos - forward)
	Phys:AddAngleVelocity(-Phys:GetAngleVelocity() * angleDragMult * 3)
	--- todo: fuck
	Phys:ApplyForceCenter(forward * 20000 * thrustMult) -- todo: make this function fucking work ARGH
end

function JMod.EZ_WeaponLaunch(ply)
	if not (IsValid(ply) and ply:Alive()) then return end
	local Weps = {}

	for k, ent in pairs(ents.GetAll()) do
		if ent.EZlaunchableWeaponArmedTime and IsValid(ent.EZowner) and ent.EZowner == ply and ent:GetState() == 1 then
			table.insert(Weps, ent)
		end
	end

	local FirstWep, Earliest = nil, 9e9

	for k, wep in pairs(Weps) do
		if wep.EZlaunchableWeaponArmedTime < Earliest then
			FirstWep = wep
			Earliest = wep.EZlaunchableWeaponArmedTime
		end
	end

	if IsValid(FirstWep) then
		-- knock knock it's pizza time
		FirstWep:EmitSound("buttons/button6.wav", 75, 110)

		timer.Simple(.2, function()
			if IsValid(FirstWep) then
				FirstWep.DropOwner = ply
				FirstWep:Launch()
			end
		end)
	end
end

function JMod.EZ_BombDrop(ply)
	if not (IsValid(ply) and ply:Alive()) then return end
	local Boms = {}
	local Bays = {}

	for k, ent in pairs(ents.GetAll()) do
		if ent.EZdroppableBombArmedTime and IsValid(ent.EZowner) and ent.EZowner == ply then
			table.insert(Boms, ent)
		elseif ent.EZdroppableBombLoadTime and IsValid(ent.EZowner) and ent.EZowner == ply then
			table.insert(Bays, ent)
		end
	end

	local FirstBom, Earliest = nil, 9e9

	for k, bay in pairs(Bays) do
		if (bay.EZdroppableBombLoadTime < Earliest) and (#bay.Bombs > 0) then
			FirstBom = bay
			Earliest = bay.EZdroppableBombLoadTime
		end
	end

	for k, bom in pairs(Boms) do
		if (bom.EZdroppableBombArmedTime < Earliest) and (constraint.HasConstraints(bom) or not bom:GetPhysicsObject():IsMotionEnabled()) then
			FirstBom = bom
			Earliest = bom.EZdroppableBombArmedTime
		end
	end

	if IsValid(FirstBom) then
		-- knock knock it's pizza time
		FirstBom:EmitSound("buttons/button6.wav", 75, 120)

		timer.Simple(.25, function()
			if IsValid(FirstBom) then
				if FirstBom.EZdroppableBombArmedTime then
					constraint.RemoveAll(FirstBom)
					FirstBom:GetPhysicsObject():EnableMotion(true)
					FirstBom:GetPhysicsObject():Wake()
					FirstBom.DropOwner = ply
				elseif FirstBom.EZdroppableBombLoadTime then
					FirstBom:BombRelease(#FirstBom.Bombs, true, ply)
				end
			end
		end)
	end
end

function JMod.DamageSpark(ent)
	local effectdata = EffectData()
	effectdata:SetOrigin(ent:GetPos() + ent:GetUp() * 10 + VectorRand() * math.random(0, 10))
	effectdata:SetNormal(VectorRand())
	effectdata:SetMagnitude(math.Rand(2, 4)) --amount and shoot hardness
	effectdata:SetScale(math.Rand(.5, 1.5)) --length of strands
	effectdata:SetRadius(math.Rand(2, 4)) --thickness of strands
	util.Effect("Sparks", effectdata, true, true)
	ent:EmitSound("snd_jack_turretfizzle.wav", 70, 100)
end

-- copied from Homicide
function JMod.BlastThatDoor(ent, vel)
	ent.JModDoorBreachedness = nil
	local Moddel, Pozishun, Ayngul, Muteeriul, Skin = ent:GetModel(), ent:GetPos(), ent:GetAngles(), ent:GetMaterial(), ent:GetSkin()
	sound.Play("Wood_Crate.Break", Pozishun, 60, 100)
	sound.Play("Wood_Furniture.Break", Pozishun, 60, 100)
	ent:Fire("unlock", "", 0)
	ent:Fire("open", "", 0)
	ent:SetNoDraw(true)
	ent:SetNotSolid(true)

	if Moddel and Pozishun and Ayngul then
		local Replacement = ents.Create("prop_physics")
		Replacement:SetModel(Moddel)
		Replacement:SetPos(Pozishun + Vector(0, 0, 1))
		Replacement:SetAngles(Ayngul)

		if Muteeriul then
			Replacement:SetMaterial(Muteeriul)
		end

		if Skin then
			Replacement:SetSkin(Skin)
		end

		Replacement:SetModelScale(.9, 0)
		Replacement:Spawn()
		Replacement:Activate()

		if vel then
			Replacement:GetPhysicsObject():SetVelocity(vel)

			timer.Simple(0, function()
				if IsValid(Replacement) then
					Replacement:GetPhysicsObject():ApplyForceCenter(vel * 100)
				end
			end)
		end

		timer.Simple(3, function()
			if IsValid(Replacement) then
				Replacement:SetCollisionGroup(COLLISION_GROUP_WEAPON)
			end
		end)

		timer.Simple(30 * JMod.Config.Explosives.DoorBreachResetTimeMult, function()
			if IsValid(ent) then
				ent:SetNotSolid(false)
				ent:SetNoDraw(false)
			end

			if IsValid(Replacement) then
				Replacement:Remove()
			end
		end)
	end
end

-- https://developer.valvesoftware.com/wiki/Ai_sound
function JMod.EmitAIsound(pos, vol, dur, typ)
	local snd = ents.Create("ai_sound")
	snd:SetPos(pos)
	snd:SetKeyValue("volume", tostring(vol))
	snd:SetKeyValue("duration", tostring(dur))
	snd:SetKeyValue("soundtype", tostring(typ))
	snd:Spawn()
	snd:Activate()
	snd:Fire("EmitAISound")
	SafeRemoveEntityDelayed(snd, dur + .5)
end

function JMod.FragSplosion(shooter, origin, fragNum, fragDmg, fragMaxDist, attacker, direction, spread, zReduction)
	-- fragmentation/shrapnel simulation
	local Eff = EffectData()
	Eff:SetOrigin(origin)
	Eff:SetScale(fragNum)
	Eff:SetNormal(direction or Vector(0, 0, 0))
	Eff:SetMagnitude(spread or 0)
	util.Effect("eff_jack_gmod_fragsplosion", Eff, true, true)
	---
	shooter = shooter or game.GetWorld()
	zReduction = zReduction or 2

	if not JMod.Config.Explosives.FragExplosions then
		util.BlastDamage(shooter, attacker, origin, fragDmg * 8, fragDmg)

		return
	end

	local Spred = Vector(0, 0, 0)
	local BulletsFired, MaxBullets, disperseTime = 0, 300, .5

	if fragNum >= 12000 then
		disperseTime = 2
	elseif fragNum >= 6000 then
		disperseTime = 1
	end

	for i = 1, fragNum do
		timer.Simple((i / fragNum) * disperseTime, function()
			local Dir

			if direction and spread then
				Dir = Vector(direction.x, direction.y, direction.z)
				Dir = Dir + VectorRand() * math.Rand(0, spread)
				Dir:Normalize()
			else
				Dir = VectorRand()
			end

			if zReduction then
				Dir.z = Dir.z / zReduction
				Dir:Normalize()
			end

			local Tr = util.QuickTrace(origin, Dir * fragMaxDist, shooter)

			if Tr.Hit and not Tr.HitSky and not Tr.HitWorld and (BulletsFired < MaxBullets) then
				local LowFrag = (Tr.Entity.IsVehicle and Tr.Entity:IsVehicle()) or Tr.Entity.LFS or Tr.Entity.LVS or Tr.Entity.EZlowFragPlease

				if (not LowFrag) or (LowFrag and math.random(1, 4) == 2) then
					local DmgMul = 1

					if BulletsFired > 500 then
						DmgMul = 5
					end

					local firer = (IsValid(shooter) and shooter) or game.GetWorld()

					firer:FireBullets({
						Attacker = attacker,
						Damage = fragDmg * DmgMul,
						Force = fragDmg / 8 * DmgMul,
						Num = 1,
						Src = origin,
						Tracer = 0,
						Dir = Dir,
						Spread = Spred,
						AmmoType = "Buckshot" -- for identification as "fragments"
						
					})

					BulletsFired = BulletsFired + 1
				end
			end
		end)
	end
end

function JMod.PackageObject(ent, pos, ang, ply)
	if pos then
		ent = ents.Create(ent)
		ent:SetPos(pos)
		ent:SetAngles(ang)

		if ply then
			JMod.SetEZowner(ent, ply)
		end

		ent:Spawn()
		ent:Activate()
	end

	local Bocks = ents.Create("ent_jack_gmod_ezcompactbox")
	Bocks:SetPos(ent:LocalToWorld(ent:OBBCenter()) + Vector(0, 0, 20))
	Bocks:SetAngles(ent:GetAngles())
	Bocks:SetContents(ent)

	if ply then
		JMod.SetEZowner(Bocks, ply)
	end

	Bocks:Spawn()
	Bocks:Activate()
	return Bocks
end

function JMod.SimpleForceExplosion(pos, power, range, sourceEnt)
	for k, v in pairs(ents.FindInSphere(pos, range)) do
		if not IsValid(sourceEnt) or (v ~= sourceEnt) then
			local Phys = v:GetPhysicsObject()

			if IsValid(Phys) then
				local EntPos = v:LocalToWorld(v:OBBCenter())

				local Tr = util.TraceLine({
					start = pos,
					endpos = EntPos,
					filter = {sourceEnt, v}
				})

				if not Tr.Hit then
					local DistFrac = (1 - (EntPos:Distance(pos) / range)) ^ 2
					local Force = power * DistFrac

					if v:IsNPC() or v:IsPlayer() then
						v:SetVelocity((EntPos - pos):GetNormalized() * Force / 500)
					else
						Phys:ApplyForceCenter((EntPos - pos):GetNormalized() * Force * Phys:GetMass() ^ .25 / 2)
					end
				end
			end
		end
	end
end

function JMod.DecalSplosion(pos, decalName, range, num, sourceEnt)
	for i = 1, num / 5 do
		timer.Simple(i / 2, function()
			for j = 1, num / 5 do
				local Dir = VectorRand() * math.random(1, range)
				Dir.z = Dir.z / 4
				local Tr = util.QuickTrace(pos, Dir, sourceEnt)

				if Tr.Hit then
					util.Decal(decalName, Tr.HitPos + Tr.HitNormal, Tr.HitPos - Tr.HitNormal)
				end
			end
		end)
	end
end

function JMod.BlastDamageIgnoreWorld(pos, att, infl, dmg, range)
	for k, v in pairs(ents.FindInSphere(pos, range)) do
		local EntPos = v:GetPos()
		local Vec = EntPos - pos
		local Dir = Vec:GetNormalized()
		local DistFrac = 1 - (Vec:Length() / range)
		local Dmg = DamageInfo()
		Dmg:SetDamage(dmg * DistFrac)
		Dmg:SetDamageForce(Dir * 1e5 * DistFrac)
		Dmg:SetDamagePosition(EntPos)
		Dmg:SetAttacker(att or game.GetWorld())
		Dmg:SetInflictor(infl or att or game.GetWorld())
		Dmg:SetDamageType(DMG_BLAST)
		v:TakeDamageInfo(Dmg)
	end
end

local WreckBlacklist = {"gmod_lamp", "gmod_cameraprop", "gmod_light", "ent_jack_gmod_nukeflash"}

function JMod.WreckBuildings(blaster, pos, power, range, ignoreVisChecks)
	local origPower = power
	power = power * JMod.Config.Explosives.PropDestroyPower
	local maxRange = 250 * power * (range or 1) -- todo: this still doesn't do what i want for the nuke
	local maxMassToDestroy = 10 * power ^ .8
	local masMassToLoosen = 30 * power
	local allProps = ents.FindInSphere(pos, maxRange)

	for k, prop in pairs(allProps) do
		if not (table.HasValue(WreckBlacklist, prop:GetClass()) or hook.Run("JMod_CanDestroyProp", prop, blaster, pos, power, range, ignore) == false or prop.ExplProof == true) then
			local physObj = prop:GetPhysicsObject()
			local propPos = prop:LocalToWorld(prop:OBBCenter())
			local DistFrac = 1 - propPos:Distance(pos) / maxRange
			local myDestroyThreshold = DistFrac * maxMassToDestroy
			local myLoosenThreshold = DistFrac * masMassToLoosen

			if DistFrac >= .85 then
				myDestroyThreshold = myDestroyThreshold * 7
				myLoosenThreshold = myLoosenThreshold * 7
			end

			if (prop ~= blaster) and physObj:IsValid() then
				local mass, proceed = physObj:GetMass(), ignoreVisChecks

				if not proceed then
					local tr = util.QuickTrace(pos, propPos - pos, blaster)
					proceed = IsValid(tr.Entity) and (tr.Entity == prop)
				end

				if proceed then
					if mass <= myDestroyThreshold then
						SafeRemoveEntity(prop)
					elseif mass <= myLoosenThreshold then
						physObj:EnableMotion(true)
						constraint.RemoveAll(prop)
						physObj:ApplyForceOffset((propPos - pos):GetNormalized() * 1000 * DistFrac * power * mass, propPos + VectorRand() * 10)
					else
						physObj:ApplyForceOffset((propPos - pos):GetNormalized() * 200 * DistFrac * origPower * mass, propPos + VectorRand() * 10)
					end
				end
			end
		end
	end
end

function JMod.BlastDoors(blaster, pos, power, range, ignoreVisChecks)
	for k, door in pairs(ents.FindInSphere(pos, 40 * power * (range or 1))) do
		if JMod.IsDoor(door) and hook.Run("JMod_CanDestroyDoor", door, blaster, pos, power, range, ignore) ~= false then
			local proceed = ignoreVisChecks

			if not proceed then
				local tr = util.QuickTrace(pos, door:LocalToWorld(door:OBBCenter()) - pos, blaster)
				proceed = IsValid(tr.Entity) and (tr.Entity == door)
			end

			if proceed then
				JMod.BlastThatDoor(door, (door:LocalToWorld(door:OBBCenter()) - pos):GetNormalized() * 1000)
			end
		end
		if door:GetClass() == "func_breakable_surf" then
			door:Fire("Break")
		end
	end
end

function JMod.Sploom(attacker, pos, mag, radius)
	local Sploom = ents.Create("env_explosion")
	Sploom:SetPos(pos)
	Sploom:SetOwner(attacker or game.GetWorld())
	Sploom:SetKeyValue("iMagnitude", mag or "1")

	if radius then
		Sploom:SetKeyValue("iRadiusOverride", radius)
	end

	Sploom:Spawn()
	Sploom:Activate()
	Sploom:Fire("explode", "", 0)
	--[[ -- HE doesn't make fires
	if vFireInstalled then
		local fires=math.Round(math.random()*(mag/80))
		for i=1, fires do
			timer.Simple(i*0.05, function()
				CreateVFireBall(mag/10, mag/10, pos+Vector(0,0,5), VectorRand()*math.random(mag, mag*2))
			end)
		end
	end
	]]
end

local SurfaceHardness = {
	[MAT_METAL] = .95,
	[MAT_COMPUTER] = .95,
	[MAT_VENT] = .95,
	[MAT_GRATE] = .95,
	[MAT_FLESH] = .5,
	[MAT_ALIENFLESH] = .3,
	[MAT_SAND] = .1,
	[MAT_DIRT] = .3,
	[MAT_GRASS] = .2,
	[74] = .1,
	[85] = .2,
	[MAT_WOOD] = .5,
	[MAT_FOLIAGE] = .5,
	[MAT_CONCRETE] = .9,
	[MAT_TILE] = .8,
	[MAT_SLOSH] = .05,
	[MAT_PLASTIC] = .3,
	[MAT_GLASS] = .6
}

-- Slayer Ricocheting/Penetrating Bullets FTW
function JMod.RicPenBullet(ent, pos, dir, dmg, doBlasts, wreckShit, num, penMul, tracerName, callback)
	if not IsValid(ent) then return end
	if num and num > 10 then return end
	local Attacker = ent.EZowner or ent or game.GetWorld()

	ent:FireBullets({
		Attacker = Attacker,
		Damage = dmg * 2,
		Force = dmg,
		Num = 1,
		Tracer = 1,
		TracerName = tracerName or "",
		Dir = dir,
		Spread = Vector(0, 0, 0),
		Src = pos,
		Callback = callback or nil
	})

	local initialTrace = util.TraceLine({
		start = pos,
		endpos = pos + dir * 50000,
		filter = {ent}
	})

	if not initialTrace.Hit then return end
	local AVec, IPos, TNorm, SMul = initialTrace.Normal, initialTrace.HitPos, initialTrace.HitNormal, SurfaceHardness[initialTrace.MatType]
	local Eff = EffectData()
	Eff:SetOrigin(IPos)
	Eff:SetScale(.5)
	Eff:SetNormal(TNorm)
	util.Effect("eff_jack_gmod_efpburst", Eff, true, true)

	if doBlasts then
		util.BlastDamage(ent, Attacker, IPos + TNorm * 2, dmg / 6, dmg / 4)

		timer.Simple(0, function()
			local Tr = util.QuickTrace(IPos + TNorm, -TNorm * 20)

			if Tr.Hit then
				util.Decal("FadingScorch", Tr.HitPos + Tr.HitNormal, Tr.HitPos - Tr.HitNormal)
			end
		end)
	end

	if wreckShit and not initialTrace.HitWorld then
		local Phys = initialTrace.Entity:GetPhysicsObject()

		if IsValid(Phys) then
			local Mass, Thresh = Phys:GetMass(), dmg / 2

			if Mass <= Thresh then
				constraint.RemoveAll(initialTrace.Entity)
				Phys:EnableMotion(true)
				Phys:Wake()
				Phys:ApplyForceOffset(-AVec * dmg * 2, IPos)
			end
		end
	end

	---
	if not SMul then
		SMul = .5
	end

	local ApproachAngle = -math.deg(math.asin(TNorm:Dot(AVec)))
	local MaxRicAngle = 60 * SMul

	-- all the way through (hot)
	if ApproachAngle > (MaxRicAngle * 1.05) then
		local MaxDist, SearchPos, SearchDist, Penetrated = (dmg / SMul) * .15 * (penMul or 1), IPos, 5, false

		while (not Penetrated) and (SearchDist < MaxDist) do
			SearchPos = IPos + AVec * SearchDist
			local PeneTrace = util.QuickTrace(SearchPos, -AVec * SearchDist)

			if (not PeneTrace.StartSolid) and PeneTrace.Hit then
				Penetrated = true
			else
				SearchDist = SearchDist + 5
			end
		end

		if Penetrated then
			ent:FireBullets({
				Attacker = Attacker,
				Damage = 1,
				Force = 1,
				Num = 1,
				Tracer = 0,
				TracerName = "",
				Dir = -AVec,
				Spread = Vector(0, 0, 0),
				Src = SearchPos + AVec
			})

			if doBlasts then
				util.BlastDamage(ent, Attacker, SearchPos + AVec * 2, dmg / 4, dmg / 4)

				timer.Simple(0, function()
					local Tr = util.QuickTrace(SearchPos + AVec, -AVec * 20)

					if Tr.Hit then
						util.Decal("FadingScorch", Tr.HitPos + Tr.HitNormal, Tr.HitPos - Tr.HitNormal)
					end
				end)
			end

			local ThroughFrac = 1 - SearchDist / MaxDist
			JMod.RicPenBullet(ent, SearchPos + AVec, AVec, dmg * ThroughFrac * .7, doBlasts, wreckShit, (num or 0) + 1, penMul, tracerName, callback)
		end
	elseif ApproachAngle < (MaxRicAngle * .95) then
		-- ping whiiiizzzz
		if SERVER then
			sound.Play("snds_jack_gmod/ricochet_" .. math.random(1, 2) .. ".wav", IPos, 60, math.random(90, 100))
		end

		local NewVec = AVec:Angle()
		NewVec:RotateAroundAxis(TNorm, 180)
		NewVec = NewVec:Forward()
		JMod.RicPenBullet(ent, IPos + TNorm, -NewVec, dmg * .7, doBlasts, wreckShit, (num or 0) + 1, penMul, tracerName, callback)
	end
end

function JMod.GetEZowner(ent)
	if not IsValid(ent) then return game.GetWorld() end

	if ent.EZowner and IsValid(ent.EZowner) then

		return ent.EZowner
	else
		
		return game.GetWorld()
	end
end

function JMod.SetEZowner(ent, newOwner, setColor)
	if not IsValid(ent) then return end
	if not IsValid(newOwner) then newOwner = game.GetWorld() end

	if JMod.GetEZowner(ent) == newOwner then
		if setColor == true then
			JMod.Colorify(ent)
		end

		return 
	end

	ent.EZowner = newOwner

	if setColor == true then
		JMod.Colorify(ent)
	end

	if CPPI and isfunction(ent.CPPISetOwner) then
		ent:CPPISetOwner(newOwner)
	end

	if newOwner:IsPlayer() then
		if (JMod.EZ_OwnerID[newOwner:SteamID()] ~= newOwner) and not(IsValid(JMod.EZ_OwnerID[newOwner:SteamID()])) then
			JMod.EZ_OwnerID[newOwner:SteamID()] = newOwner
		end
	end
end

function JMod.ShouldAllowControl(self, ply)
	if not IsValid(ply) then return false end
	if (ply.EZkillme) then return false end
	if not IsValid(self.EZowner) then return false end
	if ply == self.EZowner then return true end
	local Allies = self.EZowner.JModFriends or {}
	if table.HasValue(Allies, ply) then return true end

	return (engine.ActiveGamemode() ~= "sandbox" or ply:Team() ~= TEAM_UNASSIGNED) and ply:Team() == self.EZowner:Team()
end

function JMod.ShouldAttack(self, ent, vehiclesOnly, peaceWasNeverAnOption)
	if not IsValid(ent) then return false end
	if ent:IsWorld() then return false end
	local Gaymode, PlayerToCheck, InVehicle = engine.ActiveGamemode(), nil, false

	if ent:IsPlayer() then
		PlayerToCheck = ent
	elseif ent:IsNextBot() then
		-- our hands are really tied with nextbots, they lack all the NPC methods
		-- so just attack all of them
		if ent.Health and (type(ent.Health) == "function") then
			local Helf = ent:Health()
			if (type(Helf) == "number") and (Helf > 0) then return true end
		elseif ent.Health and (type(ent.Health) == "number") then
			if ent.Health > 0 then return true end
		end
	elseif ent:IsNPC() then
		local Class = ent:GetClass()
		if self.WhitelistedNPCs and table.HasValue(self.WhitelistedNPCs, Class) then return true end
		if self.BlacklistedNPCs and table.HasValue(self.BlacklistedNPCs, Class) then return false end
		if not IsValid(self.EZowner) then return ent:Health() > 0 end

		if ent.Disposition and (ent:Disposition(self.EZowner) == D_HT) and ent.GetMaxHealth and ent.Health then
			if vehiclesOnly then
				return ent:GetMaxHealth() > 100 and ent:Health() > 0
			else
				return ent:GetMaxHealth() > 0 and ent:Health() > 0
			end
		else
			return peaceWasNeverAnOption or false
		end
	elseif ent:IsVehicle() then
		PlayerToCheck = ent:GetDriver()
		InVehicle = true
	elseif (ent.LFS and ent.GetEngineActive) or (ent.LVS and not(ent.ExplodedAlready)) then
		--jprint(ent.LVS, ent.GetEngineActive(), ent.GetDriver and ent:GetDriver())
		-- LunasFlightSchool compatibility
		if ent:GetEngineActive() and ent.GetDriver then
			local Pilot = ent:GetDriver()

			if IsValid(Pilot) then
				PlayerToCheck = ent:GetDriver()
				InVehicle = true
			else
				return true
			end
		end
	elseif ent.IS_DRONE and IsValid(ent.EZowner) then
		-- Drones Rewrite compatibility
		if ent.GetHealth and ent:GetHealth() > 0 then
			PlayerToCheck = ent.EZowner
		end
	end

	if IsValid(PlayerToCheck) and PlayerToCheck.Alive then
		if vehiclesOnly and not InVehicle then return false end
		if PlayerToCheck.EZkillme then return true end -- for testing
		if PlayerToCheck:GetObserverMode() ~= 0 then return false end
		if self.EZowner and (PlayerToCheck == self.EZowner) then return false end
		local Allies = (self.EZowner and self.EZowner.JModFriends) or {}
		if table.HasValue(Allies, PlayerToCheck) then return false end
		local OurTeam = nil

		if IsValid(self.EZowner) then
			OurTeam = self.EZowner:Team()
			if Gaymode == "basewars" and self.EZowner.IsAlly then return not self.EZowner:IsAlly(PlayerToCheck) end
		end

		if Gaymode == "sandbox" and OurTeam == TEAM_UNASSIGNED then return PlayerToCheck:Alive() end
		if OurTeam then return PlayerToCheck:Alive() and PlayerToCheck:Team() ~= OurTeam end

		return PlayerToCheck:Alive()
	end

	return peaceWasNeverAnOption or false
end

function JMod.EnemiesNearPoint(ent, pos, range, vehiclesOnly)
	for k, v in pairs(ents.FindInSphere(pos, range)) do
		if JMod.ShouldAttack(ent, v, vehiclesOnly) then return true end
	end

	return false
end

function JMod.EMP(pos, range)
	for k, ent in pairs(ents.FindInSphere(pos, range)) do
		if ent.SetState and ent.SetElectricity and ent.GetState and ent:GetState() > 0 then
			ent:SetState(0)
		end
	end
end

function JMod.Colorify(ent)
	if (ent.EZcolorable ~= nil) and (ent.EZcolorable == false) then return end
	if IsValid(JMod.GetEZowner(ent)) then
		if engine.ActiveGamemode() == "sandbox" and ent.EZowner:Team() == TEAM_UNASSIGNED then
			local Col = ent.EZowner:GetPlayerColor()
			ent:SetColor(Color(Col.x * 255, Col.y * 255, Col.z * 255))
		else
			local Tem = ent.EZowner:Team()

			if Tem then
				local Col = team.GetColor(Tem)

				if Col then
					ent:SetColor(Col)
				end
			end
		end
	else
		ent:SetColor(Color(255, 255, 255))
	end
end

local TriggerKeys = {IN_ATTACK, IN_USE, IN_ATTACK2}

function JMod.ThrowablePickup(playa, item, hardstr, softstr)
	playa:PickupObject(item)
	local HookName = "EZthrowable_" .. item:EntIndex()

	hook.Add("KeyPress", HookName, function(ply, key)
		if not IsValid(playa) then
			hook.Remove("KeyPress", HookName)

			return
		end

		if ply ~= playa then return end

		if IsValid(item) and ply:Alive() then
			local Phys = item:GetPhysicsObject()

			if key == IN_ATTACK then
				timer.Simple(0, function()
					if IsValid(Phys) then
						Phys:ApplyForceCenter(ply:GetAimVector() * (hardstr or 600) * Phys:GetMass())

						if item.EZspinThrow then
							Phys:ApplyForceOffset(ply:GetAimVector() * Phys:GetMass() * 50, Phys:GetMassCenter() + Vector(0, 0, 10))
							Phys:ApplyForceOffset(-ply:GetAimVector() * Phys:GetMass() * 50, Phys:GetMassCenter() - Vector(0, 0, 10))
						end
					end
				end)
			elseif key == IN_ATTACK2 then
				local vec = ply:GetAimVector()
				vec.z = vec.z + 0.3

				timer.Simple(0, function()
					if IsValid(Phys) then
						Phys:ApplyForceCenter(vec * (softstr or 400) * Phys:GetMass())
					end
				end)
			elseif key == IN_USE then
				if item.GetState and item:GetState() == JMod.EZ_STATE_PRIMED then
					JMod.Hint(playa, "grenade drop", item)
				end
			end
		end

		if table.HasValue(TriggerKeys, key) then
			hook.Remove("KeyPress", HookName)
		end
	end)
end

function JMod.BlockPhysgunPickup(ent, isblock)
	if isblock == false then
		isblock = nil
	end

	ent.block_pickup = isblock
end

function JMod.MachineSpawnResource(machine, resourceType, amount, relativeSpawnPos, relativeSpawnAngle, ejectionVector, findCrate, range)
	amount = math.Round(amount)
	if not(amount) or (amount < 1) then return end --print("[JMOD] " .. tostring(machine) .. " tried to produce a resource with 0 value") return end
	local SpawnPos, SpawnAngle, MachineOwner = machine:LocalToWorld(relativeSpawnPos), relativeSpawnAngle and machine:LocalToWorldAngles(relativeSpawnAngle), JMod.GetEZowner(machine)
	for i = 1, math.ceil(amount/100*JMod.Config.ResourceEconomy.MaxResourceMult) do
		if findCrate then
			range = range or 256
			range = range * range -- Sqr root stuff
			local BestCrate = nil
			local IsGenericCrate = true

			for _, ent in pairs(ents.FindInSphere(machine:LocalToWorld(machine:OBBCenter()), range)) do
				if (ent.IsJackyEZcrate) then
					local Dist = machine:LocalToWorld(machine:OBBCenter()):DistToSqr(ent:LocalToWorld(ent:OBBCenter()))
					if (Dist <= range) and (ent:GetResource() < ent.MaxResource) then
						local EntSupplies = ent:GetEZsupplies()
						if EntSupplies[resourceType] ~= nil then
							BestCrate = ent
							range = Dist
							IsGenericCrate = false
						elseif EntSupplies["generic"] == 0 and (IsGenericCrate == true) then
							BestCrate = ent
							range = Dist
							IsGenericCrate = true
						end
					end
				end
			end
			
			if IsValid(BestCrate) then
				local Accepted = BestCrate:TryLoadResource(resourceType, amount, true)
				
				if Accepted > 0 then
					local entPos = BestCrate:LocalToWorld(BestCrate:OBBCenter())
					JMod.ResourceEffect(resourceType, machine:LocalToWorld(machine:OBBCenter()), entPos, amount * 0.02, 0.1, 1)
					amount = amount - Accepted
					if amount <= 0 then 
					
						return
					end
				end
			end
		end

		local SpawnAmount = math.min(amount, 100 * JMod.Config.ResourceEconomy.MaxResourceMult)
		JMod.ResourceEffect(resourceType, machine:LocalToWorld(machine:OBBCenter()), SpawnPos, SpawnAmount * 0.02, 1, 1)
		timer.Simple(1 * math.ceil(amount/100 * JMod.Config.ResourceEconomy.MaxResourceMult), function()
			local Resource = ents.Create(JMod.EZ_RESOURCE_ENTITIES[resourceType])
			Resource:SetPos(SpawnPos)
			Resource:SetAngles(SpawnAngle or Resource.JModPreferredCarryAngles or Angle(0, 0, 0))
			Resource:Spawn()
			JMod.SetEZowner(MachineOwner)
			Resource:SetResource(SpawnAmount)
			Resource:Activate()
			--local NoCollide = constraint.NoCollide(machine, Resource, 0, 0)
			--Resource:GetPhysicsObject():SetVelocity(ejectionVector)
			--[[
			timer.Simple(1, function()
				if IsValid(Resource) then
					constraint.RemoveConstraints(Resource, "NoCollide")
				end
			end)
			--]]
		end)
		amount = amount - SpawnAmount
		if amount <= 0 then
			
			return
		end
	end
end

local LiquidResourceTypes = {JMod.EZ_RESOURCE_TYPES.WATER, JMod.EZ_RESOURCE_TYPES.COOLANT, JMod.EZ_RESOURCE_TYPES.OIL, JMod.EZ_RESOURCE_TYPES.CHEMICALS, JMod.EZ_RESOURCE_TYPES.FUEL}

local SpriteResourceTypes = {JMod.EZ_RESOURCE_TYPES.GAS, JMod.EZ_RESOURCE_TYPES.SAND, JMod.EZ_RESOURCE_TYPES.PAPER, JMod.EZ_RESOURCE_TYPES.ANTIMATTER, JMod.EZ_RESOURCE_TYPES.PROPELLANT, JMod.EZ_RESOURCE_TYPES.CLOTH, JMod.EZ_RESOURCE_TYPES.POWER}

function JMod.ResourceEffect(typ, fromPoint, toPoint, amt, spread, scale, upSpeed)
	--print("Type: " .. tostring(typ) .. " From point: " .. tostring(fromPoint) .. " Amount: " .. amt)
	amt = amt or 1
	spread = spread or 1
	scale = scale or 1
	upSpeed = upSpeed or 0

	amt = math.Clamp(amt, 0.5, 5)

	local UseSprites = table.HasValue(SpriteResourceTypes, typ)

	if (UseSprites) then amt = amt * 2 end

	for j = 0, 2 * amt do
		timer.Simple(j / 20, function()
			for i = 1, math.ceil(7 * amt * JMod.Config.Machines.SupplyEffectMult) do
				local whee = EffectData()
				whee:SetOrigin(fromPoint)
				if toPoint then
					whee:SetStart(toPoint)
				end
				whee:SetFlags(JMod.ResourceToIndex[typ])
				whee:SetMagnitude(spread)
				whee:SetRadius(upSpeed)
				whee:SetScale(scale)

				if toPoint then
					whee:SetSurfaceProp(1) -- we have somewhere to go
				else
					whee:SetSurfaceProp(0) -- just do a directionless explosion of particles
				end

				if table.HasValue(LiquidResourceTypes, typ) then
					util.Effect("eff_jack_gmod_resource_liquid", whee, true, true)
				elseif UseSprites then
					util.Effect("eff_jack_gmod_resource_sprites", whee, true, true)
				else
					util.Effect("eff_jack_gmod_resource_props", whee, true, true)
				end
			end
		end)
	end
end

function JMod.FindBoltPos(ply, origin, dir)
	local Pos, Vec = origin or ply:GetShootPos(), dir or ply:GetAimVector()

	local Tr1 = util.QuickTrace(Pos, Vec * 80, {ply})

	if Tr1.Hit then
		local Ent1 = Tr1.Entity
		if Tr1.HitSky or Ent1:IsWorld() or Ent1:IsPlayer() or Ent1:IsNPC() then return nil end
		if not IsValid(Ent1:GetPhysicsObject()) then return nil end

		local Tr2 = util.QuickTrace(Tr1.HitPos, Tr1.HitNormal * -40, {ply, Ent1})

		if Tr2.Hit then
			local Ent2 = Tr2.Entity
			if (Ent1 == Ent2) or Tr2.HitSky or Ent2:IsPlayer() or Ent2:IsNPC() then return nil end
			if not Ent2:IsWorld() and not IsValid(Ent2:GetPhysicsObject()) then return nil end
			local Dist = Tr1.HitPos:Distance(Tr2.HitPos)
			if Dist > 30 then return nil end

			return true, Tr1.HitPos, Tr2.HitPos, Ent1, Ent2
		end
	end
end

function JMod.Bolt(ply)
	local Success, Pos, Vec, Ent1, Ent2 = JMod.FindBoltPos(ply)
	if not Success then return end
	
	local Axis = constraint.Axis(Ent1, Ent2, 0, 0, Ent1:WorldToLocal(Pos), Ent2:WorldToLocal(Vec), 50000, 0, 1, false)
	
	local Dir = (Pos - Vec):GetNormalized()
	local Bolt = ents.Create("prop_dynamic")
	Bolt:SetModel("models/crossbow_bolt.mdl")
	Bolt:SetMaterial("models/shiny")
	Bolt:SetColor(Color(50, 50, 50))
	Bolt:SetPos(Pos - Dir * 20)
	Bolt:SetAngles(Dir:Angle())
	Bolt:Spawn()
	Bolt:Activate()
	Bolt:SetParent(Ent1)
	Ent1.EZnails = Ent1.EZnails or {}
	table.insert(Ent1.EZnails, Bolt)
	sound.Play("snds_jack_gmod/ez_tools/" .. math.random(1, 27) .. ".wav", Pos, 60, math.random(80, 120))
end

function JMod.FindNailPos(ply, origin, dir)
	local Pos, Vec = origin or ply:GetShootPos(), dir or ply:GetAimVector()

	local Tr1 = util.QuickTrace(Pos, Vec * 80, {ply})

	if Tr1.Hit then
		local Ent1 = Tr1.Entity
		if Tr1.HitSky or Ent1:IsWorld() or Ent1:IsPlayer() or Ent1:IsNPC() then return nil end
		if not IsValid(Ent1:GetPhysicsObject()) then return nil end

		local Tr2 = util.QuickTrace(Pos, Vec * 120, {ply, Ent1})

		if Tr2.Hit then
			local Ent2 = Tr2.Entity
			if (Ent1 == Ent2) or Tr2.HitSky or Ent2:IsPlayer() or Ent2:IsNPC() then return nil end
			if not Ent2:IsWorld() and not IsValid(Ent2:GetPhysicsObject()) then return nil end
			local Dist = Tr1.HitPos:Distance(Tr2.HitPos)
			if Dist > 30 then return nil end

			return true, Tr1.HitPos, Vec, Ent1, Ent2
		end
	end
end

function JMod.Nail(ply)
	local Success, Pos, Vec, Ent1, Ent2 = JMod.FindNailPos(ply)
	if not Success then return end
	local Weld = constraint.Find(Ent1, Ent2, "Weld", 0, 0)

	if Weld then
		local Strength = Weld:GetTable().forcelimit + 5000
		Weld:Remove()

		timer.Simple(.01, function()
			Weld = constraint.Weld(Ent1, Ent2, 0, 0, Strength, false, false)
		end)
	else
		Weld = constraint.Weld(Ent1, Ent2, 0, 0, 5000, false, false)
	end

	local Nail = ents.Create("prop_dynamic")
	Nail:SetModel("models/crossbow_bolt.mdl")
	Nail:SetMaterial("models/shiny")
	Nail:SetColor(Color(50, 50, 50))
	Nail:SetPos(Pos - Vec * 2)
	Nail:SetAngles(Vec:Angle())
	Nail:Spawn()
	Nail:Activate()
	Nail:SetParent(Ent1)
	Ent1.EZnails = Ent1.EZnails or {}
	table.insert(Ent1.EZnails, Nail)
	sound.Play("snds_jack_gmod/ez_tools/" .. math.random(1, 27) .. ".wav", Pos, 60, math.random(80, 120))
end

function JMod.GetPackagableObject(packager, origin, dir)
	local PackageBlacklist = {"func_"}
	local Tr = util.QuickTrace(origin or packager:GetShootPos(), (dir or packager:GetAimVector()) * 80, {packager})

	local Ent = Tr.Entity

	if IsValid(Ent) and not Ent:IsWorld() then
		if Ent.EZunpackagable then

			return nil, "No."
		end

		if Ent:IsPlayer() or Ent:IsNPC() then return nil end
		if Ent:IsRagdoll() then return nil end
		local Constraints, Constrained = constraint.GetTable(Ent), false

		for k, v in pairs(Constraints) do
			if v.Type ~= "NoCollide" then
				Constrained = true
				break
			end
		end

		if Constrained then

			return nil, "object is constrained"
		end

		for k, v in pairs(PackageBlacklist) do
			if string.find(Ent:GetClass(), v) then

				return nil, "can't package this"
			end
		end

		if Ent.IsJackyEZmachine and Ent.GetState and Ent:GetState() ~= 0 then
			return nil, "device must be turned off to package"
		end

		return Ent
	end

	return nil
end

function JMod.Package(packager)
	local Ent, Message = JMod.GetPackagableObject(packager)

	if Ent then
		JMod.PackageObject(Ent)
		sound.Play("snds_jack_gmod/packagify.wav", packager:GetPos(), 60, math.random(90, 110))

		for i = 1, 3 do
			timer.Simple(i / 3, function()
				if IsValid(packager) then
					sound.Play("snds_jack_gmod/ez_tools/" .. math.random(1, 27) .. ".wav", packager:GetPos(), 60, math.random(80, 120))
				end
			end)
		end
	elseif isstring(Message) then
		packager:PrintMessage(HUD_PRINTCENTER, Message)
	end
end

function JMod.EZprogressTask(ent, pos, deconstructor, task)
	local Time = CurTime()

	if not IsValid(ent) then return "Invalid Ent" end

	if ent:GetNW2Float("EZcancel"..task.."Time", 0) <= Time then
		ent:SetNW2Float("EZ"..task.."Progress", 0)
	end
	ent:SetNW2Float("EZcancel"..task.."Time", Time + 3)
	
	local Prog = ent:GetNW2Float("EZ"..task.."Progress", 0)
	local Phys = ent:GetPhysicsObject()
	
	if IsValid(Phys) then
		local WorkSpreadMult = JMod.CalcWorkSpreadMult(ent, pos)

		if task == "loosen" then
			if constraint.HasConstraints(ent) or not Phys:IsMotionEnabled() then
				local Mass = Phys:GetMass() ^ .8
				local AddAmt = 300 / Mass * WorkSpreadMult * JMod.Config.Tools.Toolbox.DeconstructSpeedMult
				ent:SetNW2Float("EZ"..task.."Progress", math.Clamp(Prog + AddAmt, 0, 100))

				if Prog >= 100 then
					sound.Play("snds_jack_gmod/ez_tools/hit.wav", pos + VectorRand(), 70, math.random(50, 60))
					constraint.RemoveAll(ent)
					Phys:EnableMotion(true)
					Phys:Wake()
					ent:SetNW2Float("EZ"..task.."Progress", 0)
					if ent.EZnails then
						for _, v in ipairs(ent.EZnails) do
							if IsValid(v) then
								v:Remove()
							end
						end
						ent.EZnails = {}
					end
				end
			else
				return "object is already unconstrained"
			end
		elseif task == "salvage" then
			if constraint.HasConstraints(ent) or not Phys:IsMotionEnabled() then
				return "object is constrained"
			else
				local Mass = Phys:GetMass() ^ .8
				local Yield, Message = JMod.GetSalvageYield(ent)

				if #table.GetKeys(Yield) <= 0 then
					return Message
				else
					local AddAmt = 250 / Mass * WorkSpreadMult * JMod.Config.Tools.Toolbox.DeconstructSpeedMult
					ent:SetNW2Float("EZ"..task.."Progress", math.Clamp(Prog + AddAmt, 0, 100))
					
					if Prog >= 100 then
						sound.Play("snds_jack_gmod/ez_tools/hit.wav", pos + VectorRand(), 70, math.random(50, 60))

						for k, v in pairs(Yield) do
							local AmtLeft = v

							while AmtLeft > 0 do
								local Remove = math.min(AmtLeft, 100 * JMod.Config.ResourceEconomy.MaxResourceMult)
								local Ent = ents.Create(JMod.EZ_RESOURCE_ENTITIES[k])
								Ent:SetPos(pos + VectorRand() * 40 + Vector(0, 0, 30))
								Ent:SetAngles(AngleRand())
								Ent:Spawn()
								Ent:Activate()
								Ent:SetResource(Remove)
								JMod.SetEZowner(Ent, deconstructor)
								timer.Simple(.1, function()
									if (IsValid(Ent) and IsValid(Ent:GetPhysicsObject())) then 
										Ent:GetPhysicsObject():SetVelocity(Vector(0, 0, 0)) --- This is so jank
									end
								end)
								AmtLeft = AmtLeft - Remove
							end
						end
						SafeRemoveEntity(ent)
					end
				end
			end
		end
	end
end

function JMod.BuildRecipe(results, ply, Pos, Ang)
	if istable(results) then
		for k, v in ipairs(results) do
			for n = 1, (results[k][2] or 1) do
				local Ent = ents.Create(results[k][1])
				Ent:SetPos(Pos)
				Ent:SetAngles(Ang)
				JMod.SetEZowner(Ent, ply)
				Ent:SetCreator(ply)
				Ent:Spawn()
				Ent:Activate()
				if (results[k][3]) then
					Ent:SetResource(results[k][3])
				end
			end
		end
	else
		local StringParts=string.Explode(" ", results)
		if((StringParts[1])and(StringParts[1] == "FUNC"))then
			local FuncName = StringParts[2]
			if((JMod.LuaConfig) and (JMod.LuaConfig.BuildFuncs) and (JMod.LuaConfig.BuildFuncs[FuncName]))then
				local Ent = JMod.LuaConfig.BuildFuncs[FuncName](ply, Pos, Ang)
				if(Ent)then
					if(Ent:GetPhysicsObject():GetMass() <= 15)then ply:PickupObject(Ent) end
				end
			else
				print("JMOD WORKBENCH ERROR: garrysmod/lua/autorun/JMod.LuaConfig.lua is missing, corrupt, or doesn't have an entry for that build function")
			end
		else
			local Ent = ents.Create(results)
			Ent:SetPos(Pos)
			Ent:SetAngles(Ang)
			JMod.SetEZowner(Ent, ply)
			Ent:SetCreator(ply)
			Ent:Spawn()
			Ent:Activate()
			if(Ent:GetPhysicsObject():GetMass() <= 15)then ply:PickupObject(Ent) end
		end
	end
end

function JMod.ConsumeNutrients(ply, amt)
	local Time = CurTime()
	amt = math.Round(amt)
	ply.EZnutrition.NextEat = Time + amt / JMod.Config.FoodSpecs.EatSpeed
	ply.EZnutrition.Nutrients = ply.EZnutrition.Nutrients + amt * JMod.Config.FoodSpecs.ConversionEfficiency

	if ply.getDarkRPVar and ply.setDarkRPVar and ply:getDarkRPVar("energy") then
		local Old = ply:getDarkRPVar("energy")
		ply:setDarkRPVar("energy", math.Clamp(Old + amt * JMod.Config.FoodSpecs.ConversionEfficiency, 0, 100))
	end

	ply:PrintMessage(HUD_PRINTCENTER, "nutrition: " .. ply.EZnutrition.Nutrients .. "/100")
end

function JMod.GetPlayerStrength(ply)
	if not(IsValid(ply) and ply:IsPlayer() and ply:Alive()) then return 0 end
	if ply.EZnutrition then

		return 1 + (ply.EZnutrition.Nutrients * 0.1) * JMod.Config.General.HandGrabStrength
	else
		
		return 1 * JMod.Config.General.HandGrabStrength
	end
end

hook.Add("PhysgunPickup", "EZPhysgunBlock", function(ply, ent)
	if ent.block_pickup then
		JMod.Hint(ply, "blockphysgun")

		return false
	end
end)

concommand.Add("jacky_sandbox", function(ply, cmd, args)
	if not (IsValid(ply) and ply:IsSuperAdmin()) then return end
	if not GetConVar("sv_cheats"):GetBool() then return end

	for k, v in pairs({
		{"impulse 101", 10},
		"sbox_maxballoons 9e9", "sbox_maxbuttons 9e9", "sbox_maxdynamite 9e9", "sbox_maxeffects 9e9", "sbox_maxemitters 9e9", "sbox_maxhoverballs 9e9", "sbox_maxlamps 9e9", "sbox_maxlights 9e9", "sbox_maxnpcs 9e9", "sbox_maxprops 9e9", "sbox_maxragdolls 9e9", "sbox_maxsents 9e9", "sbox_maxthrusters 9e9", "sbox_maxturrets 9e9", "sbox_maxvehicles 9e9", "sbox_maxwheels 9e9", "sbox_noclip 1", "sbox_weapons 1"
	}) do
		if type(v) == "string" then
			ply:ConCommand(v)
		else
			for i = 1, v[2] do
				ply:ConCommand(v[1])
			end
		end
	end

	for k, v in pairs(JMod.AmmoTable) do
		ply:GiveAmmo(150, k)
	end

	local Helf = ply:Health()

	if Helf < 999 then
		ply:SetHealth(999)
	else
		ply:SetHealth(Helf + 1000)
	end
end, nil, "Sets us to Sandbox god mode thing.")

concommand.Add("jmod_debug_destroy", function(ply, cmd, args)
	if not GetConVar("sv_cheats"):GetBool() then return end
	if not ply:IsSuperAdmin() then return end
	local Tr = ply:GetEyeTrace()

	if not Tr.Entity then
		print("No Entity to destroy")

		return
	end

	local ent = Tr.Entity

	if ent.Destroy then
		print("Destroying ent: " .. tostring(ent))
		ent:Destroy(DamageInfo())
	else
		print("Entity does not have a destroy function")
	end
end, nil, "Destroys the current JMod thing you are looking at")