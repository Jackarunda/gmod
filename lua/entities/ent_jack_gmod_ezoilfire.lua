-- Jackarunda 2021
AddCSLuaFile()
ENT.Type = "anim"
ENT.Author = "Jackarunda"
ENT.Category = "JMod - EZ Misc."
ENT.Information = "glhfggwpezpznore"
ENT.PrintName = "EZ Oil Fire"
ENT.NoSitAllowed = true
ENT.Spawnable = false
ENT.AdminSpawnable = false
---
ENT.JModHighlyFlammableFunc = "GoFlamin"
ENT.EZscannerDanger = true
ENT.DepositKey = 0

function ENT:SetupDataTables()
	self:NetworkVar("Bool", 0, "Burning")
end

if SERVER then
	concommand.Add("jmod_debug_oilfire", function(ply, cmd, args)
		if not JMod.IsAdmin(ply) then return end
		local Tr = ply:GetEyeTrace()
		local Firey = ents.Create("ent_jack_gmod_ezoilfire")
		Firey:SetPos(Tr.HitPos)
		Firey:Spawn()
	end, nil, "Spawns an oil fire where you are looking")

	function ENT:Initialize()
		self:SetModel("models/props_wasteland/prison_pipefaucet001a.mdl")
		self:PhysicsInit(SOLID_OBB)
		self:SetMoveType(MOVETYPE_NONE)
		self:SetSolid(SOLID_NONE)
		self:DrawShadow(true)
		self:SetAngles(Angle(180, 0, 90))

		---
		timer.Simple(0.1, function()
			if not IsValid(self) then return end
			if self:GetBurning() then
				self:GoFlamin()
			else
				self:Diffuse()
			end
		end)

		self:SetBurning(true)
		---
		self.RemoveTime = CurTime() + 300 / (self:WaterLevel() + 1)
	end

	function ENT:GoFlamin()
		local Tr = util.QuickTrace(self:GetPos() + Vector(2, 0, 10), Vector(0, 0, -40))

		if Tr.Hit then
			util.Decal("BigScorch", Tr.HitPos + Tr.HitNormal, Tr.HitPos - Tr.HitNormal)
		end

		if self.SoundLoop then
			self.SoundLoop:Stop()
		end
		self.SoundLoop = CreateSound(self, "snds_jack_gmod/intense_fire_loop.wav")
		self.SoundLoop:SetSoundLevel(80)
		self.SoundLoop:Play()
		self:SetBurning(true)
	end

	function ENT:Diffuse()
		if self.SoundLoop then
			self.SoundLoop:Stop()
		end
		self.SoundLoop = CreateSound(self, "snds_jack_gmod/intense_liquid_spray.wav")
		self.SoundLoop:SetSoundLevel(80)
		self.SoundLoop:Play()
		self:SetBurning(false)
		self.RemoveTime = self.RemoveTime - 250
	end

	function ENT:CanSee(ent)
		if not IsValid(ent) then return false end
		if ent == self then return false end
		local TargPos, SelfPos = ent:LocalToWorld(ent:OBBCenter()), self:LocalToWorld(self:OBBCenter()) + vector_up * 5

		local Tr = util.TraceLine({
			start = SelfPos,
			endpos = TargPos,
			filter = {self, ent},
			mask = MASK_SHOT + MASK_WATER
		})

		return not Tr.Hit
	end

	function ENT:BurnStuff()
		local Up, Forward, Right, Range = self:GetUp(), self:GetForward(), self:GetRight(), 500
		local Pos = self:GetPos() + Right * 150

		for i, ent in pairs(ents.FindInSphere(Pos + Right * 150, Range)) do
			if self:CanSee(ent) then
				local TheirPos = ent:GetPos()
				local DDistance = Pos:Distance(TheirPos)
				local DistanceFactor = (1 - DDistance / Range) ^ 2

				--jprint(DistanceFactor)

				local Dmg = DamageInfo()
				Dmg:SetDamage(100 * DistanceFactor) -- wanna scale this with distance
				Dmg:SetDamageType(DMG_BURN)
				--Dmg:SetDamageForce(Vector(0, 0, 5000)) -- some random upward force
				Dmg:SetAttacker(game.GetWorld()) -- the earth is mad at you
				Dmg:SetInflictor(game.GetWorld())
				Dmg:SetDamagePosition(ent:LocalToWorld(ent:OBBCenter()))

				if ent.TakeDamageInfo then
					ent:TakeDamageInfo(Dmg)
				end

				local PushNormal = (TheirPos - Pos):GetNormalized()
				if (ent:GetMoveType() == MOVETYPE_WALK) then
					ent:SetVelocity(PushNormal * 100 + Vector(0, 0, 1000 * DistanceFactor))
				elseif IsValid(ent:GetPhysicsObject()) then
					ent:GetPhysicsObject():ApplyForceOffset(PushNormal * 500 + Vector(0, 0, 5000 * DistanceFactor), Pos)
				end
			end
		end
	end

	function ENT:Think()
		local Time = CurTime()
		local SelfPos = self:LocalToWorld(self:OBBCenter())
		local SelfUp, SelfForward, SelfRight = self:GetUp(), self:GetForward(), self:GetRight()

		if not(self:GetBurning()) or (self:WaterLevel() >= 3) then
			JMod.LiquidSpray(SelfPos + SelfUp + SelfRight * 10, SelfRight * 1200, 1, self:EntIndex(), 1)
		else
			local Eff = EffectData()
			Eff:SetOrigin(SelfPos + SelfUp + SelfRight * 10)
			Eff:SetNormal(SelfRight)
			Eff:SetScale(1)
			util.Effect("eff_jack_gmod_ezoilfiresmoke", Eff, true)

			if self.DepositKey and JMod.NaturalResourceTable[self.DepositKey] then
				if JMod.DepleteNaturalResource(self.DepositKey, .1) then
					SafeRemoveEntity(self)
				end
			else
				--SafeRemoveEntity(self)
			end

			self:BurnStuff()
		end

		if math.random(1, 4) == 1 then
			local FireVec = VectorRand() + Vector(0, 0, 2)
			local Flame = ents.Create("ent_jack_gmod_eznapalm")
			Flame.Creator = self
			Flame:SetPos(SelfPos + Vector(0, 0, 10))
			Flame:SetAngles(FireVec:Angle())
			Flame:SetOwner(JMod.GetEZowner(self))
			JMod.SetEZowner(Flame, self.EZowner or self)
			Flame.InitalVel = FireVec * 200
			Flame.SpeedMul = 1
			Flame.HighVisuals = math.random(1, 5) == 1
			Flame.Burnin = self:GetBurning()
			Flame:Spawn()
			Flame:Activate()
		end

		if Time > self.RemoveTime then
			SafeRemoveEntity(self)
		end
		
		self:NextThink(Time + .1)

		return true
	end

	function ENT:OnTakeDamage(dmginfo)
		if dmginfo:IsExplosionDamage() and (dmginfo:GetDamage() >= 200) then
			self:Diffuse()
		elseif dmginfo:IsDamageType(DMG_BURN) and (math.random(1, 5) == 1) then
			self:GoFlamin()
		end
	end

	function ENT:OnRemove()
		if self.SoundLoop then
			self.SoundLoop:Stop()
		end
	end

elseif CLIENT then
	local GlowSprite = Material("sprites/mat_jack_basicglow")
	local HeatWaveMat = Material("sprites/heatwave")

	function ENT:Initialize()
	end

	function ENT:Think()
		if self:GetBurning() then
			local Pos, Dir = self:GetPos(), self:GetRight()
			local dlight = DynamicLight(self:EntIndex())

			if dlight then
				dlight.pos = Pos + Dir * 200
				dlight.r = 255
				dlight.g = 60
				dlight.b = 10
				dlight.brightness = 8
				dlight.Decay = 200
				dlight.Size = 1000
				dlight.DieTime = CurTime() + .5
			end
		end
	end

	---
	function ENT:Draw()
		self:DrawModel()
		if not(self:GetBurning()) or (self:WaterLevel() >= 3) then return end
		local Pos, Dir = self:GetPos(), self:GetRight()
		render.SetMaterial(GlowSprite)

		for i = 1, 10 do
			render.DrawSprite(Pos + Dir * (i * math.random(30, 60)), 150, 150, Color(255, 255 - i * 10, 255 - i * 20, 255))
		end

		if JMod.Config.QoL.NiceFire then
			render.SetMaterial(HeatWaveMat)

			for i = 1, 3 do
				render.DrawSprite(Pos + Dir * (i * math.random(50, 80)), 250, 200, Color(255, 255 - i * 10, 255 - i * 20, 255))
			end
		end
	end

	language.Add("ent_jack_gmod_ezoilfire", "EZ Oil Fire")
end
