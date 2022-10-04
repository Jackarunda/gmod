-- Jackarunda 2021
AddCSLuaFile()
ENT.Type = "anim"
ENT.Author = "AdventureBoots, Jackarunda"
ENT.Category = "JMod - EZ Explosives"
ENT.Information = "The deployment submunition for the EZ Cluster Buster"
ENT.PrintName = "BLU-108"
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.EZclusterBusterMunition = true
---
ENT.JModPreferredCarryAngles = Angle(0, 0, 0)
---
local STATE_OFF, STATE_PARACHUTING, STATE_ROCKETING = -1, 0, 1

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "State")
end

---
if SERVER then
	function ENT:Initialize()
		--self:SetModel("models/xqm/cylinderx2.mdl")
		self:SetModel("models/phxtended/bar1x.mdl")
		self:SetMaterial("phoenix_storms/Future_vents")
		--self:SetModelScale(1.25,0)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:DrawShadow(true)

		---
		timer.Simple(.01, function()
			self:GetPhysicsObject():SetMass(25)
			self:GetPhysicsObject():Wake()
		end)

		---
		self:SetState(STATE_OFF)

		timer.Simple(math.Rand(.4, 1), function()
			if IsValid(self) then
				self:StartParachuting()
			end
		end)
	end

	function ENT:StartParachuting()
		self:SetState(STATE_PARACHUTING)
		self:GetPhysicsObject():SetDragCoefficient(50)
		self:GetPhysicsObject():SetAngleDragCoefficient(200)
	end

	function ENT:StartRocketing()
		local Pos = self:GetPos()
		self:SetState(STATE_ROCKETING)
		local Phys = self:GetPhysicsObject()
		Phys:SetDragCoefficient(1)
		Phys:SetAngleDragCoefficient(10)
		self:SetAngles(Angle(0, 0, 90))
		Phys:AddAngleVelocity(Vector(0, 2500, 0))
		local Pitch = math.random(95, 105)
		self:EmitSound("snds_jack_gmod/rocket_launch.wav", 80, Pitch)
		sound.Play("snds_jack_gmod/rocket_launch.wav", Pos, 70, Pitch)
		local Eff = EffectData()
		Eff:SetOrigin(Pos)
		Eff:SetNormal(self:GetRight())
		Eff:SetScale(2)
		util.Effect("eff_jack_gmod_rocketthrust", Eff, true, true)

		timer.Simple(1.2, function()
			if IsValid(self) then
				self:Detonate()
			end
		end)
	end

	function ENT:PhysicsCollide(data, physobj)
		if not IsValid(self) then return end
		if data.HitEntity.EZclusterBusterMunition then return end

		if data.DeltaTime > 0.2 then
			self:Detonate()
		end
	end

	function ENT:OnTakeDamage(dmginfo)
		if self.Exploded then return end
		if dmginfo:GetInflictor() == self or dmginfo:GetInflictor().EZclusterBusterMunition == true then return end
		self:TakePhysicsDamage(dmginfo)
		local Dmg = dmginfo:GetDamage()

		if JMod.LinCh(Dmg, 20, 100) then
			local Pos, State = self:GetPos(), self:GetState()

			if State == JMod.EZ_STATE_ARMED then
			elseif not (State == JMod.EZ_STATE_BROKEN) then
				--self:Detonate()
				sound.Play("Metal_Box.Break", Pos)
				self:SetState(JMod.EZ_STATE_BROKEN)
				SafeRemoveEntityDelayed(self, 10)
			end
		end
	end

	function ENT:Detonate(delay, dmg)
		if self.Exploded then return end
		self.Exploded = true
		local Att = self.Owner or game.GetWorld()
		local Vel, Pos, Ang = self:GetVelocity(), self:LocalToWorld(self:OBBCenter()), self:GetAngles()
		local Up, Right, Forward = Ang:Up(), Ang:Right(), Ang:Forward()
		self:Remove()
		JMod.Sploom(Att, Pos, 10)
		local Dir = Angle(0, 0, 0)

		for i = 1, 8 do
			local DirVec = Dir:Forward()
			local Pos = self:LocalToWorld(self:OBBCenter())
			local Skeet = ents.Create("ent_jack_gmod_ezclusterbuster_skeet")
			JMod.Owner(Skeet, Att)
			Skeet:SetPos(Pos + DirVec * 30)
			Skeet:SetAngles(Angle(0, 0, 0))
			Skeet:Spawn()
			Skeet:Activate()
			Skeet:GetPhysicsObject():SetVelocity(Vel + DirVec * 600 + Vector(0, 0, math.random(-200, 200)))
			Dir:RotateAroundAxis(vector_up, 45)
		end
	end

	function ENT:Think()
		local Time, State, Phys, Att = CurTime(), self:GetState(), self:GetPhysicsObject(), self.Owner or game.GetWorld()
		local Vel, Pos, Ang = Phys:GetVelocity(), self:GetPos(), self:GetAngles()
		local Up, Forward, Right = self:GetUp(), self:GetForward(), self:GetRight()

		if State == STATE_PARACHUTING then
			-- use phys torque to point us upward
			Phys:ApplyForceOffset(Vector(0, 0, 50), Pos - Right * 100)
			Phys:ApplyForceOffset(Vector(0, 0, -50), Pos + Right * 100)
			-- check to see if we're close enough to the ground
			local Tr = util.QuickTrace(Pos, Vector(0, 0, -500), self)

			if Tr.Hit then
				self:StartRocketing()
			end
		elseif State == STATE_ROCKETING then
			local Eff = EffectData()
			Eff:SetOrigin(Pos)
			Eff:SetNormal(Right)
			Eff:SetScale(1)
			util.Effect("eff_jack_gmod_rocketthrust", Eff, true, true)
			Phys:ApplyForceCenter(Vector(0, 0, 4500))
		end

		--Phys:AddAngleVelocity(Vector(0,0,9e9))
		self:NextThink(CurTime() + .1)

		return true
	end
elseif CLIENT then
	function ENT:Initialize()
	end

	---
	function ENT:Draw()
		self:DrawModel()
		local State, Pos, Up, Right, Forward = self:GetState(), self:GetPos(), self:GetUp(), self:GetRight(), self:GetForward()
		local GlowSprite = Material("mat_jack_gmod_glowsprite")
		local Vel = self:GetVelocity()
		local Dir = Vel:GetNormalized()

		if State == STATE_PARACHUTING then
			if self.Parachute then
				if Vel:Length() > 0 then
					Dir = Dir + Vector(.01, 0, 0) -- stop the turn spasming
					local Ang = Dir:Angle()
					Ang:RotateAroundAxis(Ang:Right(), 90)
					self.Parachute:SetRenderOrigin(self:LocalToWorld(self:OBBCenter()))
					self.Parachute:SetRenderAngles(Ang)
					self.Parachute:DrawModel()
				end
			else
				self.Parachute = ClientsideModel("models/jessev92/rnl/items/parachute_deployed.mdl")
				self.Parachute:SetModelScale(0.3, 0)
				self.Parachute:SetNoDraw(true)
				self.Parachute:SetParent(self)
			end
		elseif State == STATE_ROCKETING then
			if self.Parachute then
				self.Parachute:Remove()
				self.Parachute = nil
			end

			Dir = Right
			render.SetMaterial(GlowSprite)

			for i = 1, 10 do
				local Inv = 10 - i
				render.DrawSprite(Pos + Dir * (i * 10 + math.random(10, 20)), 5 * Inv, 5 * Inv, Color(255, 255 - i * 10, 255 - i * 20, 255))
			end

			local dlight = DynamicLight(self:EntIndex())

			if dlight then
				dlight.pos = Pos + Dir * 45
				dlight.r = 255
				dlight.g = 175
				dlight.b = 100
				dlight.brightness = 2
				dlight.Decay = 200
				dlight.Size = 400
				dlight.DieTime = CurTime() + .5
			end
		end
	end

	language.Add("ent_jack_gmod_ezclusterbuster_sub", "EZ Cluster Buster Submunition")
end
