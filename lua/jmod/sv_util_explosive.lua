
function JMod.FragSplosion(shooter, origin, fragNum, fragDmg, fragMaxDist, attacker, direction, spread, zReduction, doEffect)
	-- fragmentation/shrapnel simulation
	shooter = (IsValid(shooter) and shooter) or game.GetWorld()
	zReduction = zReduction or 2
	doEffect = true

	local ShrapnelDamageInfo = nil
	local PreSetupDamageInfo = false
	if type(fragDmg) ~= "number" then
		ShrapnelDamageInfo = fragDmg
		fragDmg = ShrapnelDamageInfo:GetDamage()
		PreSetupDamageInfo = true
		if IsValid(shooter) then
			ShrapnelDamageInfo:SetInflictor(shooter)
		end
		if IsValid(attacker) then
			ShrapnelDamageInfo:SetAttacker(attacker)
		end
	else
		ShrapnelDamageInfo = DamageInfo()
		ShrapnelDamageInfo:SetAttacker(attacker)
		ShrapnelDamageInfo:SetInflictor(shooter)
		ShrapnelDamageInfo:SetDamageType(DMG_BUCKSHOT)
	end

	if not JMod.Config.Explosives.FragExplosions then
		if PreSetupDamageInfo then
			util.BlastDamageInfo(ShrapnelDamageInfo, origin, fragMaxDist * .30)
		else
			util.BlastDamage(shooter, attacker, origin, fragMaxDist * .30, fragDmg)
		end

		return
	end

	local WaterDivider = 1
	for i = 1, 4 do
		if bit.band(util.PointContents(origin + Vector(0, 0, i * 50)), CONTENTS_WATER) == CONTENTS_WATER then
			WaterDivider = i
		else
			break
		end
	end

	local Dir = Vector(0, 0, 1)
	if direction then
		Dir = Vector(direction.x, direction.y, direction.z)
	end

	local BulletsFired, MaxBullets, disperseTime = 0, fragNum / 10, .5

	if fragNum >= 12000 then
		disperseTime = 2
	elseif fragNum >= 6000 then
		disperseTime = 1
	end

	local DirAng = Dir:Angle()
	DirAng:RotateAroundAxis(DirAng:Forward(), math.random(-180, 180))
	local FragAng = DirAng:GetCopy()

	local MaxAngle = 180
	local AngleFraction = MaxAngle / fragNum

	for i = 1, fragNum do
		timer.Simple((i / fragNum) * disperseTime, function()

			if direction and spread then
				FragAng:RotateAroundAxis(FragAng:Up(), AngleFraction * spread)
				FragAng:RotateAroundAxis(DirAng:Forward(), i)
				Dir = FragAng:Forward()
			else
				Dir = VectorRand()
			end

			if zReduction then
				Dir.z = Dir.z / zReduction
				Dir:Normalize()
			end

			local Tr = util.QuickTrace(origin, Dir * fragMaxDist / WaterDivider, shooter)

			if (BulletsFired < MaxBullets) and Tr.Hit and not Tr.HitSky and not Tr.HitWorld then
				debugoverlay.Line(origin, Tr.HitPos, 5, Color(255, 0, 0), true)
				local DmgMul = 1 / WaterDivider

				if ((Tr.Entity.IsVehicle and Tr.Entity:IsVehicle()) or Tr.Entity.LFS or Tr.Entity.LVS or Tr.Entity.EZlowFragPlease) then
					DmgMul = DmgMul * .25 -- This is basically the same as lowering the amount of frags by 25%
				end

				if IsValid(Tr.Entity:GetPhysicsObject()) and (Tr.Entity:GetPhysicsObject():GetMass() > 300) then
					DmgMul = math.Round(1 / fragDmg, 4)
				end

				local DistFactor = (-Tr.Fraction + 1.1)^2.5
				local DamageToDeal = math.min(math.Round(fragDmg * DmgMul * DistFactor, 2), fragDmg * DmgMul)
				if DamageToDeal >= 1 then
					-- Convert the distance from source hammer units to meters
					local DistanceConversion = math.Round(Tr.StartPos:Distance(Tr.HitPos) / 52.493, 2)
					--print("Damage to deal: " .. DamageToDeal, "Meters: " .. DistanceConversion, "Target: " .. tostring(Tr.Entity))
					ShrapnelDamageInfo:SetDamage(DamageToDeal)
					ShrapnelDamageInfo:SetDamagePosition(Tr.HitPos)
					ShrapnelDamageInfo:SetDamageForce(Dir * DamageToDeal * .5)
					Tr.Entity:DispatchTraceAttack(ShrapnelDamageInfo, Tr, Dir)
				end

				BulletsFired = BulletsFired + 1
			else
				debugoverlay.Line(origin, Tr.HitPos, 2, Color(217, 255, 0), true)
			end
		end)
	end
	if doEffect then
		local Eff = EffectData()
		Eff:SetOrigin(origin)
		Eff:SetScale(fragNum)
		Eff:SetNormal(direction or Vector(0, 0, 0))
		Eff:SetMagnitude(spread or 0)
		util.Effect("eff_jack_gmod_fragsplosion", Eff, true, true)
	end
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

local WreckBlacklist = {"gmod_lamp", "gmod_cameraprop", "gmod_light", "ent_jack_gmod_nukeflash", "ent_jack_gmod_ezoilfire"}

function JMod.WreckBuildings(blaster, pos, power, range, ignoreVisChecks)
	local origPower = power
	power = power * JMod.Config.Explosives.PropDestroyPower
	local maxRange = 250 * power * (range or 1) -- todo: this still doesn't do what i want for the nuke
	local maxMassToDestroy = 10 * power ^ .8
	local masMassToLoosen = 30 * power
	local allProps = ents.FindInSphere(pos, maxRange)

	for k, prop in pairs(allProps) do
		if not (table.HasValue(WreckBlacklist, prop:GetClass()) or (prop:IsNPC() or prop:IsPlayer()) or (prop.ExplProof == true) or hook.Run("JMod_CanDestroyProp", prop, blaster, pos, power, range, ignoreVisChecks) == false) then
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
						if (mass * 2 >= myDestroyThreshold) and (DistFrac >= .9) and string.find(physObj:GetMaterial(), "metal") then
							timer.Simple(.1, function()
								JMod.FragSplosion(blaster, propPos, mass * 10, 100, maxRange * 100, game.GetWorld(), (propPos - pos):GetNormalized(), DistFrac)
							end)
						end
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
		--if prop:GetClass() == "npc_strider" then
			--prop:Fire("break")
		--end
	end
end

function JMod.BlastDoors(blaster, pos, power, range, ignoreVisChecks)
	for k, door in pairs(ents.FindInSphere(pos, 40 * power * (range or 1))) do
		if JMod.IsDoor(door) and hook.Run("JMod_CanDestroyDoor", door, blaster, pos, power, range, ignoreVisChecks) ~= false then
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

function JMod.FireSplosion(pos, vel, amt, spreadMult, speed, quickTrace, blaster, attacker)
	if not(pos) then return end
	if not(amt) or (amt < 1) then return end
	vel = vel or Vector(0, 0, 0)
	local dir = vel:GetNormalized()
	amt = math.Round(amt)
	spreadMult = spreadMult or 1

	local attacker = (IsValid(attacker) and attacker) or JMod.GetEZowner(blaster)

	for i = 1, amt do
		local DoNapalm = true
		if quickTrace then 
			local tr = util.QuickTrace(pos, dir + VectorRand() * 20 * spreadMult, blaster)
			if tr.Hit then
				local Haz = ents.Create("ent_jack_gmod_ezfirehazard")
				Haz:SetDTInt(0, 1)
				Haz:SetPos(tr.HitPos + tr.HitNormal * 2)
				Haz:SetAngles(tr.HitNormal:Angle())
				JMod.SetEZowner(Haz, JMod.GetEZowner(attacker))
				Haz.HighVisuals = math.random(1, amt) >= amt * .75
				Haz.Burnin = true
				Haz:Spawn()
				Haz:Activate()
				
				if IsValid(tr.Entity) and tr.Entity:IsWorld() then
					Haz:SetParent(tr.Entity)
				end

				DoNapalm = false
			end
		end
		if DoNapalm then
			timer.Simple(i / (amt + amt * .2), function()
				local FireVec = (dir + VectorRand() * spreadMult + Vector(0, 0, .3)):GetNormalized()
				--FireVec.z = FireVec.z / 2
				local Flame = ents.Create("ent_jack_gmod_eznapalm")
				Flame:SetPos(pos)
				Flame:SetAngles(FireVec:Angle())
				if IsValid(blaster) then
					Flame:SetOwner(blaster)
					JMod.SetEZowner(Flame, IsValid(attacker) and attacker or blaster)
				end
				Flame.SpeedMul = .5
				Flame.InitialVel = FireVec + vel
				Flame.Creator = attacker
				Flame.HighVisuals = math.random(1, amt) >= amt / 2
				Flame:Spawn()
				Flame:Activate()
			end)
		end
	end
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
	local Attacker = JMod.GetEZowner(ent)

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

	if not initialTrace.Hit or initialTrace.HitSky then return end
	local AVec, IPos, TNorm, SMul = initialTrace.Normal, initialTrace.HitPos, initialTrace.HitNormal, SurfaceHardness[initialTrace.MatType] or .99
	local DontStop = false
	if (util.GetSurfacePropName(initialTrace.SurfaceProps) == "chainlink") and math.Rand(0, 1) < SMul then
		DontStop = true
	else
		local Eff = EffectData()
		Eff:SetOrigin(IPos)
		if doBlasts then
			Eff:SetScale(.5)
		else
			Eff:SetScale(.2)
		end
		Eff:SetNormal(TNorm)
		util.Effect("eff_jack_gmod_efpburst", Eff, true, true)
	end
	
	if doBlasts and not DontStop then
		util.BlastDamage(ent, Attacker, IPos + TNorm * 2, dmg / 6, dmg / 4)

		timer.Simple(0, function()
			local Tr = util.QuickTrace(IPos + TNorm, -TNorm * 20)

			if Tr.Hit then
				util.Decal("FadingScorch", Tr.HitPos + Tr.HitNormal, Tr.HitPos - Tr.HitNormal)
			end
		end)
	end

	if wreckShit and not initialTrace.HitWorld and not DontStop then
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
	if ApproachAngle > (MaxRicAngle * 1.05) or DontStop then
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
			if not DontStop then
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
			end

			local ThroughFrac = (1 - SearchDist / MaxDist)
			local IntDef = SMul * ThroughFrac * .05
			--print("throughfrac", ThroughFrac, "intdef", IntDef) 
			JMod.RicPenBullet(ent, SearchPos + AVec, AVec + VectorRand(-IntDef, IntDef), dmg * ThroughFrac * (DontStop and 1 or .7), DontStop, wreckShit, (num or 0) + 1, penMul, tracerName, callback)
		end
	elseif ApproachAngle < (MaxRicAngle * .95) then
		-- ping whiiiizzzz
		if SERVER then
			sound.Play("snds_jack_gmod/ricochet_" .. math.random(1, 2) .. ".ogg", IPos, 60, math.random(90, 100))
		end

		local NewVec = AVec:Angle()
		NewVec:RotateAroundAxis(TNorm, 180)
		NewVec = NewVec:Forward()
		JMod.RicPenBullet(ent, IPos + TNorm, -NewVec, dmg * .7, doBlasts, wreckShit, (num or 0) + 1, penMul, tracerName, callback)
	end
end

function JMod.EnergeticsCookoff(pos, attacker, powerMult, numExplo, numBullet, numFire)
	-- spark/smoke effects
	for i = 1, numExplo do
		timer.Simple(math.Rand(0, .5), function()
			JMod.Sploom(attacker, pos + VectorRand() * powerMult, powerMult * 10, 50)
		end)
	end
	for i = 1, numBullet do
		timer.Simple(math.Rand(0, .5), function()
			local dir = VectorRand():GetNormalized()
			local firer = (IsValid(attacker) and attacker) or game.GetWorld()

			sound.Play("snd_jack_fireworkpop" .. math.random(1, 5) .. ".ogg", pos + VectorRand() * 10, 75, math.random(90, 110))

			firer:FireBullets({
				Attacker = attacker,
				Damage = powerMult,
				Force = 0,
				Num = 1,
				Src = pos,
				Tracer = 0,
				TracerName = "Tracer",
				Dir = dir,
				Spread = 1,
				AmmoType = "Buckshot"
			})
		end)
	end
	JMod.FireSplosion(pos, Vector(0, 0, 0), numFire, powerMult, 1, true, nil, attacker)
end