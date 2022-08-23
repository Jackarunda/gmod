-- this causes an object to rotate to point forward while moving, like a dart
function JMod.AeroDrag(ent, forward, mult, spdReq)
	if (constraint.HasConstraints(ent)) then return end
	if (ent:IsPlayerHolding()) then return end
	local Phys=ent:GetPhysicsObject()
	local Vel=Phys:GetVelocity()
	local Spd=Vel:Length()
	if (not spdReq) then spdReq=300 end
	if (Spd < spdReq) then return end
	mult=mult or 1
	local Pos, Mass=Phys:LocalToWorld(Phys:GetMassCenter()), Phys:GetMass()
	Phys:ApplyForceOffset(Vel*Mass/6*mult, Pos+forward)
	Phys:ApplyForceOffset(-Vel*Mass/6*mult, Pos-forward)
	Phys:AddAngleVelocity(-Phys:GetAngleVelocity()*Mass/1000)
end

-- this causes an object to rotate to point and fly to a point you give it
function JMod.AeroGuide(ent, forward, targetPos, turnMult, thrustMult, angleDragMult, spdReq)
	--if(constraint.HasConstraints(ent))then return end
	--if(ent:IsPlayerHolding())then return end
	local Phys=ent:GetPhysicsObject()
	local Vel=Phys:GetVelocity()
	local Spd=Vel:Length()
	--if(Spd<spdReq)then return end
	local Pos, Mass=Phys:LocalToWorld(Phys:GetMassCenter()), Phys:GetMass()
	local TargetVec=targetPos-ent:GetPos()
	local TargetDir=TargetVec:GetNormalized()
	---
	Phys:ApplyForceOffset(TargetDir*Mass*turnMult*5000, Pos+forward)
	Phys:ApplyForceOffset(-TargetDir*Mass*turnMult*5000, Pos-forward)
	Phys:AddAngleVelocity(-Phys:GetAngleVelocity()*angleDragMult*3)
	--- todo: fuck
	Phys:ApplyForceCenter(forward*20000*thrustMult) -- todo: make this function fucking work ARGH
end

function JMod.EZ_WeaponLaunch(ply)
	if not ((IsValid(ply)) and (ply:Alive())) then return end
	local Weps={}

	for k, ent in pairs(ents.GetAll()) do
		if ent.EZlaunchableWeaponArmedTime and IsValid(ent.Owner) and ent.Owner == ply and ent:GetState() == 1 then
			table.insert(Weps, ent)
		end
	end

	local FirstWep, Earliest=nil, 9e9

	for k, wep in pairs(Weps) do
		if (wep.EZlaunchableWeaponArmedTime < Earliest) then
			FirstWep=wep
			Earliest=wep.EZlaunchableWeaponArmedTime
		end
	end

	if (IsValid(FirstWep)) then
		-- knock knock it's pizza time
		FirstWep:EmitSound("buttons/button6.wav", 75, 110)

		timer.Simple(.2, function()
			if (IsValid(FirstWep)) then
				FirstWep:Launch()
			end
		end)
	end
end

function JMod.EZ_BombDrop(ply)
	if not ((IsValid(ply)) and (ply:Alive())) then return end
	local Boms={}
	local Bays={}

	for k, ent in pairs(ents.GetAll()) do
		if ent.EZdroppableBombArmedTime and IsValid(ent.Owner) and ent.Owner == ply then
			table.insert(Boms, ent)
		elseif ent.EZdroppableBombLoadTime and IsValid(ent.Owner) and ent.Owner == ply then
			table.insert(Bays, ent)
		end
	end

	local FirstBom, Earliest=nil, 9e9

	for k, bay in pairs(Bays) do
		if ((bay.EZdroppableBombLoadTime < Earliest) and (#bay.Bombs > 0)) then
			FirstBom=bay
			Earliest=bay.EZdroppableBombLoadTime
		end
	end
	for k, bom in pairs(Boms) do
		if ((bom.EZdroppableBombArmedTime < Earliest) and ((constraint.HasConstraints(bom)) or not (bom:GetPhysicsObject():IsMotionEnabled()))) then
			FirstBom=bom
			Earliest=bom.EZdroppableBombArmedTime
		end
	end

	if (IsValid(FirstBom)) then
		-- knock knock it's pizza time
		FirstBom:EmitSound("buttons/button6.wav", 75, 120)

		timer.Simple(.25, function()
			if (IsValid(FirstBom)) then
				if(FirstBom.EZdroppableBombArmedTime)then
					constraint.RemoveAll(FirstBom)
					FirstBom:GetPhysicsObject():EnableMotion(true)
					FirstBom:GetPhysicsObject():Wake()
				elseif(FirstBom.EZdroppableBombLoadTime)then
					FirstBom:BombRelease(#FirstBom.Bombs, true, ply)
				end
			end
		end)
	end
end

-- copied from Homicide
function JMod.BlastThatDoor(ent, vel)
	ent.JModDoorBreachedness=nil
	local Moddel, Pozishun, Ayngul, Muteeriul, Skin=ent:GetModel(), ent:GetPos(), ent:GetAngles(), ent:GetMaterial(), ent:GetSkin()
	sound.Play("Wood_Crate.Break", Pozishun, 60, 100)
	sound.Play("Wood_Furniture.Break", Pozishun, 60, 100)
	ent:Fire("unlock", "", 0)
	ent:Fire("open", "", 0)
	ent:SetNoDraw(true)
	ent:SetNotSolid(true)

	if Moddel and Pozishun and Ayngul then
		local Replacement=ents.Create("prop_physics")
		Replacement:SetModel(Moddel)
		Replacement:SetPos(Pozishun+Vector(0, 0, 1))
		Replacement:SetAngles(Ayngul)

		if (Muteeriul) then
			Replacement:SetMaterial(Muteeriul)
		end

		if (Skin) then
			Replacement:SetSkin(Skin)
		end

		Replacement:SetModelScale(.9, 0)
		Replacement:Spawn()
		Replacement:Activate()

		if (vel) then
			Replacement:GetPhysicsObject():SetVelocity(vel)
			timer.Simple(0,function()
				if(IsValid(Replacement))then Replacement:GetPhysicsObject():ApplyForceCenter(vel*100) end
			end)
		end

		timer.Simple(3, function()
			if (IsValid(Replacement)) then
				Replacement:SetCollisionGroup(COLLISION_GROUP_WEAPON)
			end
		end)

		timer.Simple(30*JMod.Config.DoorBreachResetTimeMult, function()
			if (IsValid(ent)) then
				ent:SetNotSolid(false)
				ent:SetNoDraw(false)
			end

			if (IsValid(Replacement)) then
				Replacement:Remove()
			end
		end)
	end
end

-- https://developer.valvesoftware.com/wiki/Ai_sound
function JMod.EmitAIsound(pos,vol,dur,typ)
	local snd=ents.Create("ai_sound")
	snd:SetPos(pos)
	snd:SetKeyValue("volume",tostring(vol))
	snd:SetKeyValue("duration",tostring(dur))
	snd:SetKeyValue("soundtype",tostring(typ))
	snd:Spawn()
	snd:Activate()
	snd:Fire("EmitAISound")
	SafeRemoveEntityDelayed(snd,dur+.5)
end

function JMod.FragSplosion(shooter, origin, fragNum, fragDmg, fragMaxDist, attacker, direction, spread, zReduction)
	-- fragmentation/shrapnel simulation
	local Eff=EffectData()
	Eff:SetOrigin(origin)
	Eff:SetScale(fragNum)
	Eff:SetNormal(direction or Vector(0, 0, 0))
	Eff:SetMagnitude(spread or 0)
	util.Effect("eff_jack_gmod_fragsplosion", Eff, true, true)
	---
	shooter=shooter or game.GetWorld()
	zReduction=zReduction or 2

	if not JMod.Config.FragExplosions then
		util.BlastDamage(shooter, attacker, origin, fragDmg*8, fragDmg*3)
		return
	end

	local Spred=Vector(0, 0, 0)
	local BulletsFired, MaxBullets, disperseTime=0, 300, .5

	if (fragNum >= 12000) then
		disperseTime=2
	elseif (fragNum >= 6000) then
		disperseTime=1
	end

	for i=1, fragNum do
		timer.Simple((i/fragNum)*disperseTime, function()
			local Dir

			if direction and spread then
				Dir=Vector(direction.x, direction.y, direction.z)
				Dir=Dir+VectorRand()*math.Rand(0, spread)
				Dir:Normalize()
			else
				Dir=VectorRand()
			end

			if (zReduction) then
				Dir.z=Dir.z/zReduction
				Dir:Normalize()
			end

			local Tr=util.QuickTrace(origin, Dir*fragMaxDist, shooter)

			if (Tr.Hit and not Tr.HitSky and not Tr.HitWorld and (BulletsFired < MaxBullets)) then
				local DmgMul=1

				if (BulletsFired > 200) then
					DmgMul=2
				end

				local firer=((IsValid(shooter)) and shooter) or game.GetWorld()

				firer:FireBullets({
					Attacker=attacker,
					Damage=fragDmg*DmgMul,
					Force=fragDmg/8*DmgMul,
					Num=1,
					Src=origin,
					Tracer=0,
					Dir=Dir,
					Spread=Spred,
							  AmmoType="Buckshot" -- for identification as "fragments"
				})

				BulletsFired=BulletsFired+1
			end
		end)
	end
end

function JMod.PackageObject(ent, pos, ang, ply)
	if (pos) then
		ent=ents.Create(ent)
		ent:SetPos(pos)
		ent:SetAngles(ang)

		if (ply) then
			JMod.Owner(ent, ply)
		end

		ent:Spawn()
		ent:Activate()
	end

	local Bocks=ents.Create("ent_jack_gmod_ezcompactbox")
	Bocks:SetPos(ent:LocalToWorld(ent:OBBCenter())+Vector(0, 0, 20))
	Bocks:SetAngles(ent:GetAngles())
	Bocks:SetContents(ent)

	if (ply) then
		JMod.Owner(Bocks, ply)
	end

	Bocks:Spawn()
	Bocks:Activate()
end

function JMod.SimpleForceExplosion(pos, power, range, sourceEnt)
	for k, v in pairs(ents.FindInSphere(pos, range)) do
		if (not (IsValid(sourceEnt)) or (v ~= sourceEnt)) then
			local Phys=v:GetPhysicsObject()

			if (IsValid(Phys)) then
				local EntPos=v:LocalToWorld(v:OBBCenter())

				local Tr=util.TraceLine({
					start=pos,
					endpos=EntPos,
					filter={sourceEnt, v}
				})

				if not Tr.Hit then
					local DistFrac=(1-(EntPos:Distance(pos)/range)) ^ 2
					local Force=power*DistFrac

					if ((v:IsNPC()) or (v:IsPlayer())) then
						v:SetVelocity((EntPos-pos):GetNormalized()*Force/500)
					else
						Phys:ApplyForceCenter((EntPos-pos):GetNormalized()*Force*Phys:GetMass() ^ .25/2)
					end
				end
			end
		end
	end
end

function JMod.DecalSplosion(pos, decalName, range, num, sourceEnt)
	for i=1,num/5 do
		timer.Simple(i/2,function()
			for j=1, num/5 do
				local Dir=VectorRand()*math.random(1, range)
				Dir.z=Dir.z/4
				local Tr=util.QuickTrace(pos, Dir, sourceEnt)
				if (Tr.Hit) then
					util.Decal(decalName, Tr.HitPos+Tr.HitNormal, Tr.HitPos-Tr.HitNormal)
				end
			end
		end)
	end
end

function JMod.BlastDamageIgnoreWorld(pos, att, infl, dmg, range)
	for k, v in pairs(ents.FindInSphere(pos, range)) do
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

local WreckBlacklist={"gmod_lamp", "gmod_cameraprop", "gmod_light", "ent_jack_gmod_nukeflash"}

function JMod.WreckBuildings(blaster, pos, power, range, ignoreVisChecks)
	local origPower=power
	power=power*JMod.Config.ExplosionPropDestroyPower
	local maxRange=250*power*(range or 1) -- todo: this still doesn't do what i want for the nuke
	local maxMassToDestroy=10*power ^ .8
	local masMassToLoosen=30*power
	local allProps=ents.FindInSphere(pos, maxRange)

	for k, prop in pairs(allProps) do
		if not (table.HasValue(WreckBlacklist, prop:GetClass()) or hook.Run("JMod_CanDestroyProp", prop, blaster, pos, power, range, ignore) == false or prop.ExplProof == true) then
			local physObj=prop:GetPhysicsObject()
			local propPos=prop:LocalToWorld(prop:OBBCenter())
			local DistFrac=(1-propPos:Distance(pos)/maxRange)
			local myDestroyThreshold=DistFrac*maxMassToDestroy
			local myLoosenThreshold=DistFrac*masMassToLoosen

			if (DistFrac >= .85) then
				myDestroyThreshold=myDestroyThreshold*7
				myLoosenThreshold=myLoosenThreshold*7
			end

			if ((prop ~= blaster) and (physObj:IsValid())) then
				local mass, proceed=physObj:GetMass(), ignoreVisChecks

				if not proceed then
					local tr=util.QuickTrace(pos, propPos-pos, blaster)
					proceed=((IsValid(tr.Entity)) and (tr.Entity == prop))
				end

				if proceed then
					if (mass <= myDestroyThreshold) then
						SafeRemoveEntity(prop)
					elseif (mass <= myLoosenThreshold) then
						physObj:EnableMotion(true)
						constraint.RemoveAll(prop)
						physObj:ApplyForceOffset((propPos-pos):GetNormalized()*1000*DistFrac*power*mass, propPos+VectorRand()*10)
					else
						physObj:ApplyForceOffset((propPos-pos):GetNormalized()*200*DistFrac*origPower*mass, propPos+VectorRand()*10)
					end
				end
			end
		end
	end
end

function JMod.BlastDoors(blaster, pos, power, range, ignoreVisChecks)
	for k, door in pairs(ents.FindInSphere(pos, 40*power*(range or 1))) do
		if (JMod.IsDoor(door) and hook.Run("JMod_CanDestroyDoor", door, blaster, pos, power, range, ignore) ~= false) then
			local proceed=ignoreVisChecks

			if not proceed then
				local tr=util.QuickTrace(pos, door:LocalToWorld(door:OBBCenter())-pos, blaster)
				proceed=((IsValid(tr.Entity)) and (tr.Entity == door))
			end

			if proceed then
				JMod.BlastThatDoor(door, (door:LocalToWorld(door:OBBCenter())-pos):GetNormalized()*1000)
			end
		end
	end
end

function JMod.Sploom(attacker, pos, mag, radius)
	local Sploom=ents.Create("env_explosion")
	Sploom:SetPos(pos)
	Sploom:SetOwner(attacker or game.GetWorld())
	Sploom:SetKeyValue("iMagnitude", mag)
	if(radius)then Sploom:SetKeyValue("iRadiusOverride",radius) end
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

local SurfaceHardness={
	[MAT_METAL]=.95,
	[MAT_COMPUTER]=.95,
	[MAT_VENT]=.95,
	[MAT_GRATE]=.95,
	[MAT_FLESH]=.5,
	[MAT_ALIENFLESH]=.3,
	[MAT_SAND]=.1,
	[MAT_DIRT]=.3,
	[MAT_GRASS]=.2,
	[74]=.1,
	[85]=.2,
	[MAT_WOOD]=.5,
	[MAT_FOLIAGE]=.5,
	[MAT_CONCRETE]=.9,
	[MAT_TILE]=.8,
	[MAT_SLOSH]=.05,
	[MAT_PLASTIC]=.3,
	[MAT_GLASS]=.6
}

-- Slayer Ricocheting/Penetrating Bullets FTW
function JMod.RicPenBullet(ent, pos, dir, dmg, doBlasts, wreckShit, num, penMul, tracerName, callback)
	if not (IsValid(ent)) then return end
	if (num and num > 10) then return end
	local Attacker=ent.Owner or ent or game.GetWorld()

	ent:FireBullets({
		Attacker=Attacker,
		Damage=dmg*2,
		Force=dmg,
		Num=1,
		Tracer=1,
		TracerName=tracerName or "",
		Dir=dir,
		Spread=Vector(0, 0, 0),
		Src=pos,
		Callback=callback or nil
	})

	local initialTrace=util.TraceLine({
		start=pos,
		endpos=pos+dir*50000,
		filter={ent}
	})

	if not initialTrace.Hit then return end
	local AVec, IPos, TNorm, SMul=initialTrace.Normal, initialTrace.HitPos, initialTrace.HitNormal, SurfaceHardness[initialTrace.MatType]

	local Eff=EffectData()
	Eff:SetOrigin(IPos)
	Eff:SetScale(.5)
	Eff:SetNormal(TNorm)
	util.Effect("eff_jack_gmod_efpburst",Eff,true,true)
	
	if (doBlasts) then
		util.BlastDamage(ent, Attacker, IPos+TNorm*2, dmg/6, dmg/4)

		timer.Simple(0, function()
			local Tr=util.QuickTrace(IPos+TNorm, -TNorm*20)

			if (Tr.Hit) then
				util.Decal("FadingScorch", Tr.HitPos+Tr.HitNormal, Tr.HitPos-Tr.HitNormal)
			end
		end)
	end

	if wreckShit and not initialTrace.HitWorld then
		local Phys=initialTrace.Entity:GetPhysicsObject()

		if IsValid(Phys) then
			local Mass, Thresh=Phys:GetMass(), dmg/2

			if (Mass <= Thresh) then
				constraint.RemoveAll(initialTrace.Entity)
				Phys:EnableMotion(true)
				Phys:Wake()
				Phys:ApplyForceOffset(-AVec*dmg*2, IPos)
			end
		end
	end

	---
	if not SMul then
		SMul=.5
	end

	local ApproachAngle=-math.deg(math.asin(TNorm:Dot(AVec)))
	local MaxRicAngle=60*SMul

	-- all the way through (hot)
	if (ApproachAngle > (MaxRicAngle*1.05)) then
		local MaxDist, SearchPos, SearchDist, Penetrated=(dmg/SMul)*.15*(penMul or 1), IPos, 5, false

		while ((not Penetrated) and (SearchDist < MaxDist)) do
			SearchPos=IPos+AVec*SearchDist
			local PeneTrace=util.QuickTrace(SearchPos, -AVec*SearchDist)

			if ((not PeneTrace.StartSolid) and PeneTrace.Hit) then
				Penetrated=true
			else
				SearchDist=SearchDist+5
			end
		end

		if (Penetrated) then
			ent:FireBullets({
				Attacker=Attacker,
				Damage=1,
				Force=1,
				Num=1,
				Tracer=0,
				TracerName="",
				Dir=-AVec,
				Spread=Vector(0, 0, 0),
				Src=SearchPos+AVec
			})

			if (doBlasts) then
				util.BlastDamage(ent, Attacker, SearchPos+AVec*2, dmg/4, dmg/4)

				timer.Simple(0, function()
					local Tr=util.QuickTrace(SearchPos+AVec, -AVec*20)

					if (Tr.Hit) then
						util.Decal("FadingScorch", Tr.HitPos+Tr.HitNormal, Tr.HitPos-Tr.HitNormal)
					end
				end)
			end

			local ThroughFrac=1-SearchDist/MaxDist
			JMod.RicPenBullet(ent, SearchPos+AVec, AVec, dmg*ThroughFrac*.7, doBlasts, wreckShit, (num or 0)+1, penMul, tracerName, callback)
		end
	elseif (ApproachAngle < (MaxRicAngle*.95)) then
		-- ping whiiiizzzz
		if (SERVER) then
			sound.Play("snds_jack_gmod/ricochet_" .. math.random(1, 2) .. ".wav", IPos, 60, math.random(90, 100))
		end

		local NewVec=AVec:Angle()
		NewVec:RotateAroundAxis(TNorm, 180)
		NewVec=NewVec:Forward()
		JMod.RicPenBullet(ent, IPos+TNorm, -NewVec, dmg*.7, doBlasts, wreckShit, (num or 0)+1, penMul, tracerName, callback)
	end
end

function JMod.Owner(ent, newOwner)
	if not (IsValid(ent)) then return end

	if not (IsValid(newOwner)) then
		newOwner=game.GetWorld()
	end

	local OldOwner=ent.Owner
	if (OldOwner and (OldOwner == newOwner)) then return end
	ent.Owner=newOwner

	if (CPPI and isfunction(ent.CPPISetOwner)) then
		ent:CPPISetOwner(newOwner)
	end
end

function JMod.ShouldAllowControl(self, ply)
	if not (IsValid(ply)) then return false end
	if not (IsValid(self.Owner)) then return false end
	if (ply == self.Owner) then return true end
	local Allies=self.Owner.JModFriends or {}
	if (table.HasValue(Allies, ply)) then return true end

	return (engine.ActiveGamemode() ~= "sandbox" or ply:Team() ~= TEAM_UNASSIGNED) and ply:Team() == self.Owner:Team()
end

function JMod.ShouldAttack(self,ent,vehiclesOnly,peaceWasNeverAnOption)
	if not(IsValid(ent))then return false end
	if(ent:IsWorld())then return false end
	local Gaymode,PlayerToCheck,InVehicle,TeamToCheck=engine.ActiveGamemode(),nil,false,nil
	if (ent:IsPlayer()) then
		PlayerToCheck=ent
	elseif(ent:IsNextBot())then
		-- our hands are really tied with nextbots, they lack all the NPC methods
		-- so just attack all of them
		if((ent.Health)and(type(ent.Health)=="function"))then
			local Helf=ent:Health()
			if((type(Helf)=="number")and(Helf>0))then return true end		
		end
	elseif(ent:IsNPC())then
		local Class=ent:GetClass()
		if(self.WhitelistedNPCs and (table.HasValue(self.WhitelistedNPCs, Class)))then return true end
		if(self.BlacklistedNPCs and (table.HasValue(self.BlacklistedNPCs, Class)))then return false end
		if not(IsValid(self.Owner))then
			return ent:Health()>0
		end
		if (ent.Disposition and (ent:Disposition(self.Owner) == D_HT) and ent.GetMaxHealth and ent.Health) then
			if (vehiclesOnly) then
				return ent:GetMaxHealth()>100 and ent:Health()>0
			else
				return ent:GetMaxHealth()>0 and ent:Health()>0
			end
		else
			return peaceWasNeverAnOption or false
		end
	elseif(ent:IsVehicle())then
		PlayerToCheck=ent:GetDriver()
		InVehicle=true
	elseif(ent.LFS and ent.GetEngineActive)then -- LunasFlightSchool compatibility
		if(ent:GetEngineActive() and ent.GetDriver)then
			local Pilot=ent:GetDriver()
			if(IsValid(Pilot))then
				PlayerToCheck=ent:GetDriver()
				InVehicle=true
			else
				return true
			end
		end
	elseif(ent.IS_DRONE and IsValid(ent.Owner))then -- Drones Rewrite compatibility
		if(ent.GetHealth and ent:GetHealth()>0)then PlayerToCheck=ent.Owner end
	end
	if ((IsValid(PlayerToCheck)) and PlayerToCheck.Alive) then
		if (vehiclesOnly and not InVehicle) then return false end
		if (PlayerToCheck.EZkillme) then return true end -- for testing
		if (PlayerToCheck:GetObserverMode() ~= 0) then return false end
		if (self.Owner and (PlayerToCheck == self.Owner)) then return false end
		local Allies=(self.Owner and self.Owner.JModFriends) or {}
		if (table.HasValue(Allies, PlayerToCheck)) then return false end
		local OurTeam=nil
		if (IsValid(self.Owner)) then
			OurTeam=self.Owner:Team()
			if Gaymode == "basewars" and self.Owner.IsAlly then
				return not self.Owner:IsAlly(PlayerToCheck)
			end
		end
		if (Gaymode == "sandbox" and OurTeam == TEAM_UNASSIGNED) then return PlayerToCheck:Alive() end
		if (OurTeam) then return PlayerToCheck:Alive() and PlayerToCheck:Team() ~= OurTeam end
		return PlayerToCheck:Alive()
	end
	return peaceWasNeverAnOption or false
end

function JMod.EnemiesNearPoint(ent, pos, range, vehiclesOnly)
	for k, v in pairs(ents.FindInSphere(pos, range)) do
		if (JMod.ShouldAttack(ent, v, vehiclesOnly)) then return true end
	end

	return false
end

function JMod.EMP(pos, range)
	for k, ent in pairs(ents.FindInSphere(pos, range)) do
		if (ent.SetState and ent.SetElectricity and ent.GetState and ent:GetState() > 0) then
			ent:SetState(0)
		end
	end
end

function JMod.Colorify(ent)
	if (IsValid(ent.Owner)) then
		if (engine.ActiveGamemode() == "sandbox" and ent.Owner:Team() == TEAM_UNASSIGNED) then
			local Col=ent.Owner:GetPlayerColor()
			ent:SetColor(Color(Col.x*255, Col.y*255, Col.z*255))
		else
			local Tem=ent.Owner:Team()

			if (Tem) then
				local Col=team.GetColor(Tem)

				if (Col) then
					ent:SetColor(Col)
				end
			end
		end
	end
end

local TriggerKeys={IN_ATTACK, IN_USE, IN_ATTACK2}

function JMod.ThrowablePickup(playa, item, hardstr, softstr)
	playa:PickupObject(item)
	local HookName="EZthrowable_" .. item:EntIndex()

	hook.Add("KeyPress", HookName, function(ply, key)
		if not (IsValid(playa)) then
			hook.Remove("KeyPress", HookName)

			return
		end

		if ply ~= playa then return end

		if ((IsValid(item)) and (ply:Alive())) then
			local Phys=item:GetPhysicsObject()

			if (key == IN_ATTACK) then
				timer.Simple(0, function()
					if (IsValid(Phys)) then
						Phys:ApplyForceCenter(ply:GetAimVector()*(hardstr or 600)*Phys:GetMass())

						if (item.EZspinThrow) then
							Phys:ApplyForceOffset(ply:GetAimVector()*Phys:GetMass()*50, Phys:GetMassCenter()+Vector(0, 0, 10))
							Phys:ApplyForceOffset(-ply:GetAimVector()*Phys:GetMass()*50, Phys:GetMassCenter()-Vector(0, 0, 10))
						end
					end
				end)
			elseif (key == IN_ATTACK2) then
				local vec=ply:GetAimVector()
				vec.z=vec.z+0.3

				timer.Simple(0, function()
					if (IsValid(Phys)) then
						Phys:ApplyForceCenter(vec*(softstr or 400)*Phys:GetMass())
					end
				end)
			elseif key == IN_USE then
				if item.GetState and item:GetState() == JMod.EZ_STATE_PRIMED then
					JMod.Hint(playa, "grenade drop", item)
				end
			end
		end

		if (table.HasValue(TriggerKeys, key)) then
			hook.Remove("KeyPress", HookName)
		end
	end)
end

function JMod.BlockPhysgunPickup(ent, isblock)
	if isblock == false then isblock=nil end
	ent.block_pickup=isblock
end

hook.Add("PhysgunPickup", "EZPhysgunBlock", function(ply, ent)
	if ent.block_pickup then 
		JMod.Hint(ply, "blockphysgun")
		return false 
	end
end)

concommand.Add("jacky_sandbox",function(ply,cmd,args)
	if not(IsValid(ply) and ply:IsSuperAdmin())then return end
	if not(GetConVar("sv_cheats"):GetBool())then return end
	for k,v in pairs({
		{"impulse 101",10},
		"sbox_maxballoons 9e9",
		"sbox_maxbuttons 9e9",
		"sbox_maxdynamite 9e9",
		"sbox_maxeffects 9e9",
		"sbox_maxemitters 9e9",
		"sbox_maxhoverballs 9e9",
		"sbox_maxlamps 9e9",
		"sbox_maxlights 9e9",
		"sbox_maxnpcs 9e9",
		"sbox_maxprops 9e9",
		"sbox_maxragdolls 9e9",
		"sbox_maxsents 9e9",
		"sbox_maxthrusters 9e9",
		"sbox_maxturrets 9e9",
		"sbox_maxvehicles 9e9",
		"sbox_maxwheels 9e9",
		"sbox_noclip 1",
		"sbox_weapons 1"
	})do
		if(type(v)=="string")then
			ply:ConCommand(v)
		else
			for i=1,v[2] do
				ply:ConCommand(v[1])
			end
		end
	end
	for k,v in pairs(JMod.AmmoTable)do
		ply:GiveAmmo(150,k)
	end
	local Helf=ply:Health()
	if(Helf<999)then
		ply:SetHealth(999)
	else
		ply:SetHealth(Helf+1000)
	end
end, nil, "Sets us to Sandbox god mode thing.")

concommand.Add("jmod_debug_destroy", function(ply,cmd,args)
	if not(GetConVar("sv_cheats"):GetBool())then return end
	if not(ply:IsSuperAdmin())then return end
	local Tr=ply:GetEyeTrace()
	if not(Tr.Entity)then print("No Entity to destroy") return end
	local ent = Tr.Entity
	if(ent.Destroy)then 
		print("Destroying ent: "..tostring(ent)) 
		ent:Destroy(DamageInfo()) 
	else print("Entity does not have a destroy function") end
end, nil, "Destroys the current JMod thing you are looking at")
