AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Fire Hazard"
ENT.KillName = "Fire Hazard"
ENT.NoSitAllowed = true
ENT.IsRemoteKiller = true
local ThinkRate = 22 --Hz

function ENT:SetupDataTables()
	self:NetworkVar("Bool", 0, "HighVisuals")
end

if SERVER then
	function ENT:Initialize()
		self.Ptype = 1

		self.TypeInfo = {
			"Napalm", {Sound("snds_jack_gmod/fire1.wav"), Sound("snds_jack_gmod/fire2.wav")},
			"eff_jack_gmod_heavyfire", 10, 20, 200
		}

		----
		self:SetMoveType(MOVETYPE_NONE)
		self:DrawShadow(false)
		self:SetCollisionBounds(Vector(-20, -20, -10), Vector(20, 20, 10))
		self:PhysicsInitBox(Vector(-20, -20, -10), Vector(20, 20, 10))
		local phys = self:GetPhysicsObject()

		if IsValid(phys) then
			phys:EnableCollisions(false)
		end
		self:SetNotSolid(true)

		local Time = CurTime()
		self.NextFizz = 0
		self.DamageMul = (self.DamageMul or 1) * math.Rand(.9, 1.1)
		self.DieTime = Time + math.Rand(self.TypeInfo[4], self.TypeInfo[5])
		self.NextSound = 0
		self.NextEffect = 0
		self.NextEnvThink = Time + 5
		self.Range = self.TypeInfo[6]
		self.Power = 3

		if self.HighVisuals then
			self:SetHighVisuals(true)
			if self:WaterLevel() > 0 then
				local Tr = util.QuickTrace(self:GetPos(), Vector(0, 0, -self.Range), {self})

				if Tr.Hit then
					util.Decal("Scorch", Tr.HitPos + Tr.HitNormal, Tr.HitPos - Tr.HitNormal)
				end
			end
		end
	end

	local function Inflictor(ent)
		if not IsValid(ent) then return game.GetWorld() end
		local Infl = ent:GetDTEntity(0)
		if IsValid(Infl) then return Infl end

		return ent
	end

	local DamageBlacklist = {
		["vfire_ball"] = true,
		["ent_jack_gmod_ezfirehazard"] = true,
		["ent_jack_gmod_eznapalm"] = true
	}

	function ENT:Think()
		local Time, Pos, Dir = CurTime(), self:GetPos(), self:GetForward()
		local Water = self:WaterLevel()

		--print(self:WaterLevel())
		if self.NextFizz < Time then
			self.NextFizz = Time + .5

			if (Water < 1) and ((math.random(1, 2) == 2) or self.HighVisuals) then
				local Zap = EffectData()
				Zap:SetOrigin(Pos)
				Zap:SetStart(self:GetVelocity())
				util.Effect(self.TypeInfo[3], Zap, true, true)
			end
		end

		if self.NextSound < Time then
			self.NextSound = Time + 1
			self:EmitSound(table.Random(self.TypeInfo[2]), 65, math.random(90, 110))
			if (math.random(1,2) == 1) then JMod.EmitAIsound(self:GetPos(), 300, .5, 8) end
		end

		if self.NextEffect < Time then
			self.NextEffect = Time + 0.5
			local Par, Att, Infl = self:GetParent(), self.EZowner or self, Inflictor(self)

			if not IsValid(Att) then
				Att = Infl
			end

			if IsValid(Par) then 
				if Par:IsPlayer() and not Par:Alive() then
					self:Remove()

					return
				end
			elseif Water > 0 then
				self:SetPos(Pos + Vector(0, 0, 10))
			end

			local FireNearby = false

			for k, v in pairs(ents.FindInSphere(Pos, self.Range)) do

				if (v:GetClass() == "ent_jack_gmod_ezfirehazard") and (v ~= self) then
					FireNearby = v.HighVisuals
					if (v:GetPos():Distance(Pos) < self.Range * 0.2) then
						if self.DieTime > v.DieTime then
							v:Remove()
						end
					end
				end
				if not DamageBlacklist[v:GetClass()] and IsValid(v:GetPhysicsObject()) and util.QuickTrace(self:GetPos(), v:GetPos() - self:GetPos(), selfg).Entity == v then
					local Dam = DamageInfo()
					Dam:SetDamage(self.Power * math.Rand(.75, 1.25))
					Dam:SetDamageType(DMG_BURN)
					Dam:SetDamagePosition(Pos)
					Dam:SetAttacker(Att)
					Dam:SetInflictor(Infl)
					v:TakeDamageInfo(Dam)

					if vFireInstalled then
						CreateVFireEntFires(v, math.random(1, 3))
					elseif (v:IsOnFire() == false) and (math.random(1, 15) == 1) then
						v:Ignite(math.random(8, 12))
					end
				end
			end

			if not FireNearby then
				self.HighVisuals = true
				self:SetHighVisuals(true)
			end

			if vFireInstalled and (math.random(1, 100) == 1) then
				CreateVFireBall(math.random(20, 30), math.random(10, 20), self:GetPos(), VectorRand() * math.random(200, 400), self:GetOwner())
			end
		end

		if (self.NextEnvThink < Time) then
			self.NextEnvThink = Time + 5
			local Pos = self:GetPos()
			local Tr = util.QuickTrace(Pos, Vector(0, 0, 9e9), self)
			if not (Tr.HitSky) then
				if (math.random(1, 15) == 1) then
					local Gas = ents.Create("ent_jack_gmod_ezgasparticle")
					Gas:SetPos(Pos + Vector(0, 0, 10))
					JMod.SetEZowner(Gas, self.EZowner)
					Gas:SetDTBool(0, false)
					Gas:Spawn()
					Gas:Activate()
					Gas.CurVel = (Vector(0, 0, 100) + VectorRand() * 50)
				end
			end
			if Water > 0 then
				self:Remove()
			else
				if math.random(1, 5) == 1 then
					local Tr = util.QuickTrace(Pos, VectorRand() * self.Range, {self})
	
					if Tr.Hit then
						util.Decal("Scorch", Tr.HitPos + Tr.HitNormal, Tr.HitPos - Tr.HitNormal)
					end
				end
			end
		end

		if self.DieTime < Time then
			self:Remove()

			return
		end

		self:NextThink(Time + (1 / ThinkRate))

		return true
	end
elseif CLIENT then
	function ENT:Initialize()
		self.HighVisuals = self:GetHighVisuals()
		self.Ptype = 1

		self.TypeInfo = {
			"Napalm", {Sound("snds_jack_gmod/fire1.wav"), Sound("snds_jack_gmod/fire2.wav")},
			"eff_jack_gmod_heavyfire", 15, 14, 75
		}

		self.CastLight = (self.HighVisuals and (math.random(1, 5) == 1)) and JMod.Config.QoL.NukeFlashLightEnabled
		self.Size = self.TypeInfo[6]
		--self.FlameSprite=Material("mats_jack_halo_sprites/flamelet"..math.random(1,5))
		
		self.Offset = Vector(0, 0, 0)
		self.SizeX = 1
		self.SizeY = 1
		self.NextRandomize = 0
	end

	local GlowSprite = Material("mat_jack_gmod_glowsprite")
	local Col = Color(255, 255, 255, 255)

	function ENT:Think()
		local HighVis = self:GetHighVisuals()
		if (HighVis ~= self.HighVisuals) and (JMod.Config.QoL.NukeFlashLightEnabled) then
			self.CastLight = HighVis
			self.HighVisuals = HighVis
		end
		if self.CastLight and not GAMEMODE.Lagging then
			local dlight = DynamicLight(self:EntIndex())

			if dlight then
				dlight.pos = self:GetPos()
				dlight.r = 255
				dlight.g = 175
				dlight.b = 100
				dlight.brightness = 3
				dlight.Decay = 200
				dlight.Size = 400
				dlight.DieTime = CurTime() + 1
			end
		end
	end

	function ENT:Draw()
		local Time, Pos = CurTime(), self:GetPos()
		local Vec = (Pos - EyePos()):GetNormalized()
		render.SetMaterial(GlowSprite)
		render.DrawSprite(Pos + self.Offset - Vec * 75, self.SizeX, self.SizeY, Col)

		if (self.NextRandomize < Time) then
			self.Offset = VectorRand() * self.Size * math.Rand(0, .15)
			self.SizeX = self.Size * math.Rand(.85, 1.15)
			self.SizeY = self.Size * math.Rand(.85, 1.15)
			self.NextRandomize = Time + math.Rand(0.1, 0.2)
		end
	end
end
