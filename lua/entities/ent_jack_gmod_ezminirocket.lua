-- Jackarunda 2021
AddCSLuaFile()
ENT.Type = "anim"
ENT.Author = "Jackarunda"
ENT.Category = "JMod - EZ Explosives"
ENT.Information = "glhfggwpezpznore"
ENT.PrintName = "EZ Mini Rocket"
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.CollisionGroup = COLLISION_GROUP_NONE
ENT.NoPhys = true
ENT.IsEZrocket = true
local ThinkRate = 22 --Hz

ENT.DetType = "HEAT"
ENT.DetTypes = {
	["INCENDIARY"] = function(self, tr, pos, dir, attacker) 
		JMod.FireSplosion(pos, dir * 100, 10, 2, 1, true, self, attacker)
	end,
	["THERMOBARIC"] = function(self, tr, pos, dir, attacker) 
		local Sploom = EffectData()
		Sploom:SetOrigin(pos)
		util.Effect("eff_jack_gmod_faebomb_predet", Sploom, true, true)
		---
		local Oof = .05

		for i = 1, 500 do
			local Tr = util.QuickTrace(pos, VectorRand() * 500, self)

			if Tr.Hit then
				Oof = Oof * 1.005
			end
		end

		---
		timer.Simple(.3, function()
			util.ScreenShake(pos, 1000, 3, 2, 2000 * Oof)
			---
			util.BlastDamage(game.GetWorld(), IsValid(attacker) and attacker or game.GetWorld(), pos, 2000 * Oof, 200 * Oof)
			---
			for k, v in ipairs(ents.FindInSphere(pos, 2000 * Oof)) do
				if v:GetClass() == "ent_jack_gmod_ezoilfire" then
					v:Diffuse()
				end
			end
			---
			for i = 1, 2 * Oof do
				sound.Play("ambient/explosions/explode_" .. math.random(1, 9) .. ".wav", pos + VectorRand() * 1000, 160, math.random(80, 110))
			end

			---
			JMod.WreckBuildings(self, pos, 10 * Oof)
			JMod.BlastDoors(self, pos, 10 * Oof)

			---
			timer.Simple(.2, function()
				JMod.WreckBuildings(self, pos, 10 * Oof)
				JMod.BlastDoors(self, pos, 10 * Oof)
			end)

			---
			timer.Simple(.1, function()
				local Tr = util.QuickTrace(pos + Vector(0, 0, 100), Vector(0, 0, -400))

				if Tr.Hit then
					util.Decal("BigScorch", Tr.HitPos + Tr.HitNormal, Tr.HitPos - Tr.HitNormal)
				end
			end)

			---
			local Sploom = EffectData()
			Sploom:SetOrigin(pos)
			Sploom:SetScale(Oof)
			util.Effect("eff_jack_gmod_faebomb_main", Sploom, true, true)
		end)
	end,
}

---
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
		self.NextDet = 0
		self.FuelLeft = 100
		self.DieTime = CurTime() + 10
		self.NextThrust = 0
		self:Think()
	end

	function ENT:Detonate(tr)
		if self.NextDet > CurTime() then return end
		if self.Exploded then return end
		self.Exploded = true
		local SelfPos, Att, Dir = (tr and tr.HitPos + tr.HitNormal * 5) or self:GetPos() + Vector(0, 0, 30), self.EZowner or self, -self:GetRight()
		JMod.Sploom(Att, SelfPos, 150)
		---
		util.ScreenShake(SelfPos, 1000, 3, 2, 700)
		self:EmitSound("snd_jack_fragsplodeclose.ogg", 90, 100)
		---
		util.BlastDamage(game.GetWorld(), Att, SelfPos + Vector(0, 0, 50), self.BlastRadius or 100, self.Damage or 100)

		for k, ent in pairs(ents.FindInSphere(SelfPos, 200)) do
			if ent:GetClass() == "npc_helicopter" then
				if math.random(1, 2) == 1 then
					ent:Fire("selfdestruct", "", math.Rand(0, 2))
				end
			end
		end

		---
		JMod.WreckBuildings(self, SelfPos, .4)
		JMod.BlastDoors(self, SelfPos, 2)

		---
		timer.Simple(.2, function()
			local Tr = util.QuickTrace(SelfPos - Dir * 100, Dir * 300)

			if Tr.Hit then
				util.Decal("Scorch", Tr.HitPos + Tr.HitNormal, Tr.HitPos - Tr.HitNormal)
			end
		end)

		if self.DetTypes[self.DetType] then
			self.DetTypes[self.DetType](self, tr, SelfPos, Dir, Att)
		end

		---
		self:Remove()
		local Ang = self:GetAngles()
		Ang:RotateAroundAxis(Ang:Forward(), -90)

		timer.Simple(.1, function()
			ParticleEffect("50lb_air", SelfPos - Dir * 20, Ang)
			ParticleEffect("50lb_air", SelfPos - Dir * 50, Ang)
		end)
	end

	function ENT:OnRemove()
	end

	--
	local LastTime = 0

	function ENT:Think()
		local Time, Pos, Dir, Speed = CurTime(), self:GetPos(), self.CurVel:GetNormalized(), self.CurVel:Length()
		local Tr

		if self.InitialTrace then
			Tr = self.InitialTrace
			self.InitialTrace = nil
		else
			local Filter = {self}

			table.insert(Filter, self:GetOwner())
			--Tr=util.TraceLine({start=Pos,endpos=Pos+self.CurVel/ThinkRate,filter=Filter})
			local Mask, HitWater, HitChainLink = MASK_SHOT, false, true

			if HitWater then
				Mask = Mask + MASK_WATER
			end

			if HitChainLink then
				Mask = nil
			end

			Tr = util.TraceHull({
				start = Pos,
				endpos = Pos + self.CurVel / ThinkRate,
				filter = Filter,
				mins = Vector(-3, -3, -3),
				maxs = Vector(3, 3, 3),
				mask = Mask
			})
		end

		if Tr.Hit then
			if Tr.HitSky then
				self:Remove()

				return
			end

			self:Detonate(Tr)
		else
			self:SetPos(Pos + self.CurVel / ThinkRate)
			self.CurVel = self.CurVel + physenv.GetGravity() / ThinkRate * 2

			---
			if (self.FuelLeft > 0) and (self.NextThrust < Time) then
				self.NextThrust = Time + .02
				self.CurVel = self.CurVel + self.CurVel:GetNormalized() * 200
				self.FuelLeft = self.FuelLeft - 5
				---
				local Eff = EffectData()
				Eff:SetOrigin(self:GetPos())
				Eff:SetNormal(-self.CurVel:GetNormalized())
				Eff:SetScale(.75)
				util.Effect("eff_jack_gmod_rockettrail", Eff, true, true)
			end
		end

		if IsValid(self) then
			if self.DieTime < Time then
				self:Detonate()

				return
			end

			self:NextThink(Time + (1 / ThinkRate))
		end

		LastTime = Time

		return true
	end
elseif CLIENT then
	function ENT:Initialize()
		self.Mdl = JMod.MakeModel(self, "models/jmod/explosives/missile/missile_patriot.mdl", 1)
		self.RenderPos = self:GetPos()
		self.NextRender = CurTime() + .05
	end

	function ENT:OnRemove()
		if IsValid(self.Mdl) then
			self.Mdl:Remove()
		end
	end

	--
	local GlowSprite = Material("mat_jack_gmod_glowsprite")

	function ENT:Think()
		self.BurnoutTime = self.BurnoutTime or CurTime() + 1

		if self.BurnoutTime > CurTime() then
			local Pos, Dir = self.RenderPos, self:GetRight()

			local dlight = DynamicLight(self:EntIndex())

			if dlight then
				dlight.pos = Pos + Dir * 35
				dlight.r = 255
				dlight.g = 175
				dlight.b = 100
				dlight.brightness = 1
				dlight.Decay = 200
				dlight.Size = 400
				dlight.DieTime = CurTime() + .5
			end
		end
	end

	function ENT:Draw()
		if self.NextRender > CurTime() then return end
		local Pos, Ang, Dir = self.RenderPos, self:GetAngles(), self:GetRight()
		Ang:RotateAroundAxis(Ang:Up(), 90)
		--self:DrawModel()
		local RenderPos = Pos + Ang:Up() * 1.5 - Ang:Right() * 0 - Ang:Forward() * 1
		JMod.RenderModel(self.Mdl, RenderPos, Ang, Vector(.2, .4, .4), nil, nil, true)
		--
		self.BurnoutTime = self.BurnoutTime or CurTime() + 1

		if self.BurnoutTime > CurTime() then
			render.SetMaterial(GlowSprite)

			for i = 1, 10 do
				local Inv = 10 - i
				render.DrawSprite(Pos + Dir * (i * 5 + math.random(30, 40) - 15), 3 * Inv, 3 * Inv, Color(255, 255 - i * 10, 255 - i * 20, 255))
			end
		end

		self.RenderPos = LerpVector(FrameTime() * 20, self.RenderPos, self:GetPos())
	end
end
