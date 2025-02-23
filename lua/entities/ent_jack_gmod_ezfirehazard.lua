AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Fire Hazard"
ENT.KillName = "Fire Hazard"
ENT.NoSitAllowed = true
ENT.IsRemoteKiller = true
ENT.JModHighlyFlammableFunc = "Detonate"
ENT.Burnin = true
ENT.FireSounds = {Sound("snds_jack_gmod/fire1.ogg"), Sound("snds_jack_gmod/fire2.ogg")}
ENT.FireEffect = "eff_jack_gmod_heavyfire"
ENT.MaxIntensity = 20
ENT.FireRange = 250

local ThinkRate = 6 --Hz

function ENT:SetupDataTables()
	self:NetworkVar("Bool", 0, "HighVisuals")
	self:NetworkVar("Bool", 1, "Burning")
end

if SERVER then
	function ENT:Initialize()
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
		self.Intensity = self.Intensity or math.random(self.MaxIntensity * .5, self.MaxIntensity)
		self.Power = self.Intensity / self.MaxIntensity
		self.Range = self.FireRange * self.Power
		self.NextSound = 0
		self.NextDamage = 0
		self.NextEnvThink = Time + 3
		
		self:SetBurning(self.Burnin)

		if self.HighVisuals then
			self:SetHighVisuals(true)
		end

		if self:WaterLevel() <= 0 then
			local Tr = util.QuickTrace(self:GetPos(), Vector(0, 0, -self.Range), {self})

			if Tr.Hit and self.Burnin then
				util.Decal("Scorch", Tr.HitPos + Tr.HitNormal, Tr.HitPos - Tr.HitNormal, self)
			end
		end
	end

	local DamageBlacklist = {
		["vfire_ball"] = true,
		["ent_jack_gmod_ezfirehazard"] = true
	}

	function ENT:Detonate()
		if self.Burnin then return end
		self.Burnin = true
		self:SetBurning(true)
		if self:WaterLevel() <= 0 then
			local Tr = util.QuickTrace(self:GetPos(), Vector(0, 0, -self.Range), {self})

			if Tr.Hit then
				util.Decal("Scorch", Tr.HitPos + Tr.HitNormal, Tr.HitPos - Tr.HitNormal)
			end
		end
	end

	function ENT:OnTakeDamage(dmginfo)
		if dmginfo:IsExplosionDamage() and (dmginfo:GetDamage() >= self.Intensity * 1.5) then
			SafeRemoveEntity(self)
		elseif not(self.Burnin) and dmginfo:IsDamageType(DMG_BURN) then
			self:Detonate()
		end
	end

	local FlammableMaterials = {
		[MAT_WOOD] = true, 
		[MAT_FLESH] = true, 
		[MAT_GRASS] = true, 
		[MAT_FOLIAGE] = true, 
		[MAT_ANTLION] = true
	}

	local function ShouldIgnite(ent)
		if not IsValid(ent) then return false end
		if ent:IsOnFire() then return false end
		if ent.LVS then return false end
		if ent:IsPlayer() then return true end
		if ent:IsNPC() then return true end
		if ent:IsNextBot() then return true end
		if FlammableMaterials[ent:GetMaterialType()] then
			return true
		end
		return false
	end

	function ENT:Think()
		local Time, Pos, Dir = CurTime(), self:GetPos(), self:GetForward()
		
		if self.Burnin then 
			if self.NextSound < Time then
				self.NextSound = Time + math.Rand(.9, 1.1)
				if (self.Intensity > self.MaxIntensity * .5) then
					self:EmitSound(table.Random(self.FireSounds), 75, math.random(90, 110))
					if (math.random(1, 2) == 1) then JMod.EmitAIsound(self:GetPos(), 300, .5, 8) end
				end
			end

			if self.NextDamage < Time then
				self.NextDamage = Time + 0.5
				local Fraction = self.Intensity / (self.MaxIntensity * 1.5)
				local Par, Att, Infl = self:GetParent(), JMod.GetEZowner(self), self
				local Water = self:WaterLevel()

				if not IsValid(Att) then
					Att = Infl
				end

				if IsValid(Par) then 
					if Par:IsPlayer() and not(Par:Alive()) then
						self:Remove()

						return
					end
				elseif Water > 0 then
					local FireTracy = util.TraceLine({start = Pos, endpos = Pos + Vector(0, 0, 10), filter = self})
					self:SetPos(FireTracy.HitPos)

					if IsValid(FireTracy.Entity) then
						self:SetParent(FireTracy.Entity)
					end
				else
					local FireTracy = util.TraceLine({start = Pos + Vector(0, 0, 10), endpos = Pos + Vector(0, 0, -30), filter = self})
					self:SetPos(FireTracy.HitPos)

					if IsValid(FireTracy.Entity) then
						if FireTracy.Entity.JMod_NapalmBounce then
							self:Remove()
						else
							self:SetParent(FireTracy.Entity)
							Par = FireTracy.Entity
						end
					end
				end

				local FireNearby = false
				local ActualRange = math.min(self.Range * Fraction, self.Range)
				self.Power = math.max(Fraction * 10, 5)
				-- Just doin it here instead of reseting it every time
				local FireDam = DamageInfo()
				FireDam:SetDamageType(DMG_BURN)
				FireDam:SetDamagePosition(Pos)
				FireDam:SetAttacker(Att)
				FireDam:SetInflictor(Infl)

				for k, v in pairs(ents.FindInSphere(Pos, ActualRange)) do
					local TheirPos = v:GetPos()

					if (v:GetClass() == "ent_jack_gmod_ezfirehazard") and (v ~= self) and JMod.ClearLoS(self, v) then
						Pos = self:GetPos()
						FireNearby = v.GetHighVisuals and v:GetHighVisuals() or false
						if (TheirPos:Distance(Pos) < self.Range * 0.5) then
							local LeftTillMax = (self.MaxIntensity * 2) - self.Intensity
							local TheirIntensity = v.Intensity or 0
							local LeftTillTheirMax = (v.MaxIntensity * 2) - TheirIntensity

							if (LeftTillMax >= self.MaxIntensity) and (LeftTillTheirMax > self.MaxIntensity * 0.5) then
								local Taken = math.min(TheirIntensity, LeftTillMax)
								self.Intensity = self.Intensity + Taken
								--v.Intensity = TheirIntensity - Taken
								v:Remove()
								if not IsValid(Par) then
									self:SetPos(Pos + (TheirPos - Pos) * 0.5)
									--debugoverlay.Cross(self:GetPos(), 5, 2, Color(255, 0, 0), true)
								end

								break
							elseif not IsValid(Par) then
								local PlaceToGo = Pos - (TheirPos - Pos) * 0.75 + VectorRand()
								local MoveTr = util.TraceLine({
									starpos = Pos, 
									endpos = PlaceToGo, 
									filter = self,
									mask = MASK_SHOT
								})
								--debugoverlay.Line(Pos, PlaceToGo, 2, Color(0, 255, 0), true)
								self:SetPos(MoveTr.HitPos)

								break
							end
						end
					elseif v.JModHighlyFlammableFunc and JMod.VisCheck(Pos, v, self) then
						JMod.SetEZowner(v, self.EZowner)
						local Func = v[v.JModHighlyFlammableFunc]
						Func(v)
					elseif not DamageBlacklist[v:GetClass()] and IsValid(v:GetPhysicsObject()) and JMod.VisCheck(Pos, v, self) then
						local DistanceFactor = math.max( 1 - ( Pos:Distance( TheirPos ) / ActualRange ), 0 ) ^ 2
						FireDam:SetDamage(1 + (self.Power * DistanceFactor * 2))
						v:TakeDamageInfo(FireDam)

						if vFireInstalled then
							CreateVFireEntFires(v, math.random(1, 3))
						elseif (ShouldIgnite(v)) and (math.random(1, 5) == 1) then
							v:Ignite(math.random(8, 12) * Fraction, 0)
						end
					end
				end

				if not FireNearby then
					self.HighVisuals = true
					self:SetHighVisuals(true)
				end

				if vFireInstalled  then
					CreateVFireBall(math.random(20, 30), math.random(10, 20), self:GetPos(), VectorRand() * math.random(200, 400), JMod.GetEZowner(self))
					self:Remove()
				end

				self.Intensity = math.Clamp(self.Intensity - math.Rand(0.2, 1), 0, self.MaxIntensity * 1.5)

				if (Water < 1) and ((math.random(1, 3) == 1) or self.HighVisuals) then
					local Zap = EffectData()
					Zap:SetOrigin(Pos)
					Zap:SetScale(2.5 * Fraction)
					Zap:SetStart(self:GetVelocity())
					util.Effect(self.FireEffect, Zap, true, true)
				end
			end
		end

		if (self.NextEnvThink < Time) then
			self.NextEnvThink = Time + 5
			local Water = self:WaterLevel()
			local Pos = self:GetPos()
			local Tr = util.QuickTrace(Pos, Vector(0, 0, 9e9), self)
			if not (Tr.HitSky) then
				if (math.random(1, (self.Burnin and 2) or 50) == 1) then
					local Gas = ents.Create("ent_jack_gmod_ezcoparticle")
					Gas:SetPos(Pos + Vector(0, 0, Tr.HitPos))
					JMod.SetEZowner(Gas, self.EZowner)
					Gas:SetDTBool(0, false)
					Gas:Spawn()
					Gas:Activate()
					Gas:SetLifeTime(math.random(10, 20))
					Gas.CurVel = (Vector(0, 0, 100) + VectorRand() * 150)
				end
			end
			if Water > 0 then
				self:Remove()
			elseif self.Burnin then
				self.Intensity = self.Intensity - 1
				if math.random(1, 5) == 1 then
					local Tr = util.QuickTrace(Pos, VectorRand() * self.Range, {self})
	
					if Tr.Hit then
						util.Decal("Scorch", Tr.HitPos + Tr.HitNormal, Tr.HitPos - Tr.HitNormal)
					end
				end
			end
		end
	
		if self.Intensity <= 0 then
			self:Remove()

			return
		end

		self:NextThink(Time + (1 / ThinkRate))

		return true
	end

elseif CLIENT then
	function ENT:Initialize()
		self.HighVisuals = self:GetHighVisuals()

		self.CastLight = (self.HighVisuals and (math.random(1, 5) == 1)) and JMod.Config.QoL.NiceFire
		self.Size = self.FireRange
		self.NextFizz = 0
		self.Offset = Vector(0, 0, 0)
		self.SizeX = 1
		self.SizeY = 1
		self.NextRandomize = 0
	end

	local GlowSprite = Material("mat_jack_gmod_glowsprite")
	local Col = Color(255, 255, 255, 255)

	function ENT:Think()
		self.Burnin = self:GetBurning()
		if not self.Burnin then return end

		local Time, Pos = CurTime(), self:GetPos()
		local Water = self:WaterLevel()
		local HighVis = self:GetHighVisuals()

		if (HighVis ~= self.HighVisuals) and (JMod.Config.QoL.NiceFire) then
			self.CastLight = HighVis
			self.HighVisuals = HighVis
		end
		
		--[[if self.HighVisuals then
			if self.NextFizz < Time then
				self.NextFizz = Time + .5

				if (Water < 1) and ((math.random(1, 3) == 1) or self.HighVisuals) then
					local Zap = EffectData()
					Zap:SetOrigin(Pos)
					Zap:SetScale(1)
					Zap:SetStart(self:GetVelocity())
					util.Effect(self.FireEffect, Zap, true, true)
				end
			end
		end--]]

		if self.CastLight and not(GAMEMODE.Lagging) and not(vFireInstalled) then
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
		if not self.Burnin then return end
		local Time, Pos = CurTime(), self:GetPos()
		local Vec = (Pos - EyePos()):GetNormalized()
		render.SetMaterial(GlowSprite)
		render.DrawSprite(Pos + self.Offset - Vec * 75, self.SizeX * .5, self.SizeY * .5, Col)

		if (self.NextRandomize < Time) then
			self.Offset = VectorRand() * self.Size * math.Rand(0, .15)
			self.SizeX = self.Size * math.Rand(.85, 1.15)
			self.SizeY = self.Size * math.Rand(.85, 1.15)
			self.NextRandomize = Time + math.Rand(0.1, 0.2)
		end
	end
end
