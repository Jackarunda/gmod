-- Jackarunda 2021
AddCSLuaFile()
ENT.Type = "anim"
ENT.Author = "AdventureBoots, Jackarunda"
ENT.Category = "JMod - EZ Explosives"
ENT.Information = "A bomb that deploys seeking anti-tank skeets"
ENT.PrintName = "EZ Cluster Buster" -- this is effectively a miniature CBU-97
ENT.Spawnable = true
ENT.AdminOnly = false
---
ENT.JModPreferredCarryAngles = Angle(0, 0, 0)
ENT.EZRackOffset = Vector(0, 0, 10)
ENT.EZRackAngles = Angle(0, 0, 90)
ENT.EZbombBaySize = 33
---
ENT.EZclusterBusterMunition = true
---
local STATE_BROKEN, STATE_OFF, STATE_ARMED = -1, 0, 1

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "State")
end

---
if SERVER then
	function ENT:SpawnFunction(ply, tr)
		local SpawnPos = tr.HitPos + tr.HitNormal * 40
		local ent = ents.Create(self.ClassName)
		ent:SetPos(SpawnPos)
		JMod.SetEZowner(ent, ply)
		ent:Spawn()
		ent:Activate()
		--local effectdata=EffectData()
		--effectdata:SetEntity(ent)
		--util.Effect("propspawn",effectdata)

		return ent
	end

	function ENT:Initialize()
		self:SetModel("models/jmod/explosives/bombs/bomb_cbu.mdl")
		self:SetSkin(1)
		--self.Entity:SetMaterial("models/jmod/explosives/bombs/cluster_buster")
		--self.Entity:SetModelScale(1.5,0)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:DrawShadow(true)
		self:SetUseType(SIMPLE_USE)

		---
		timer.Simple(.01, function()
			self:GetPhysicsObject():SetMass(200)
			self:GetPhysicsObject():Wake()
			self:GetPhysicsObject():EnableDrag(false)
			self:GetPhysicsObject():SetDamping(0, 0)
		end)

		---
		self:SetState(STATE_OFF)
		self.LastUse = 0
		self.FreefallTicks = 0

		if istable(WireLib) then
			self.Inputs = WireLib.CreateInputs(self, {"Detonate"}, {"This will directly detonate the bomb"})
		end
	end

	function ENT:TriggerInput(iname, value)
		if iname == "Detonate" and value ~= 0 then
			self:Detonate()
		end
	end

	function ENT:PhysicsCollide(data, physobj)
		if not IsValid(self) then return end

		if data.DeltaTime > .2 then
			if data.Speed > 50 then
				self:EmitSound("Canister.ImpactHard")
			end

			local DetSpd = 500

			if (data.Speed > DetSpd) and (self:GetState() == STATE_ARMED) then
				self:Detonate()

				return
			end

			if data.Speed > 1500 then
				self:Break()
			end
		end
	end

	function ENT:Break()
		if self:GetState() == STATE_BROKEN then return end
		self:SetState(STATE_BROKEN)
		self:EmitSound("snd_jack_turretbreak.wav", 70, math.random(80, 120))

		for i = 1, 20 do
			JMod.DamageSpark(self)
		end

		SafeRemoveEntityDelayed(self, 10)
	end

	function ENT:OnTakeDamage(dmginfo)
		if IsValid(self.DropOwner) then
			local Att = dmginfo:GetAttacker()
			if IsValid(Att) and (self.DropOwner == Att) then return end
		end

		self.Entity:TakePhysicsDamage(dmginfo)

		if JMod.LinCh(dmginfo:GetDamage(), 50, 100) then
			if math.random(1, 5) == 1 then
				self:Break()
			else
				JMod.SetEZowner(self, dmginfo:GetAttacker())
				self:Detonate()
			end
		end
	end

	function ENT:Use(activator)
		local State, Time = self:GetState(), CurTime()
		if State < 0 then return end

		if State == STATE_OFF then
			JMod.SetEZowner(self, activator)

			if Time - self.LastUse < .2 then
				self:SetState(STATE_ARMED)
				self:EmitSound("snds_jack_gmod/bomb_arm.wav", 70, 120)
				self.EZdroppableBombArmedTime = CurTime()
				JMod.Hint(activator, "airburst")
			else
				JMod.Hint(activator, "double tap to arm")
			end

			self.LastUse = Time
		elseif State == STATE_ARMED then
			JMod.SetEZowner(self, activator)

			if Time - self.LastUse < .2 then
				self:SetState(STATE_OFF)
				self:EmitSound("snds_jack_gmod/bomb_disarm.wav", 70, 120)
				self.EZdroppableBombArmedTime = nil
			else
				JMod.Hint(activator, "double tap to disarm")
			end

			self.LastUse = Time
		end
	end

	function ENT:Detonate()
		if self.Exploded then return end
		self.Exploded = true
		local Att = self.EZowner or game.GetWorld()
		local Vel, Pos, Ang = self:GetVelocity(), self:LocalToWorld(self:OBBCenter()), self:GetAngles()
		local Up, Right, Forward = Ang:Up(), Ang:Right(), Ang:Forward()
		self:Remove()
		JMod.Sploom(Att, Pos, 50)

		timer.Simple(0, function()
			local SpawnDirs = {Vector(-1, 0, 0), Vector(1, 0, 0), Vector(0, -1, 0), Vector(0, 1, 0)}

			for i = 1, 4 do
				local Bomblet = ents.Create("ent_jack_gmod_ezclusterbuster_sub")
				JMod.SetEZowner(Bomblet, Att)
				Bomblet:SetPos(Pos + SpawnDirs[i] * 30)
				Bomblet:SetAngles(VectorRand():Angle())
				Bomblet:Spawn()
				Bomblet:Activate()
				Bomblet:GetPhysicsObject():SetVelocity(Vel + SpawnDirs[i] * 700 + Vector(0, 0, math.random(100, 200)))
			end
		end)
	end

	function ENT:OnRemove()
	end

	--
	function ENT:EZdetonateOverride(detonator)
		self:Detonate()
	end

	function ENT:Think()
		if istable(WireLib) then
			WireLib.TriggerOutput(self, "State", self:GetState())
			--WireLib.TriggerOutput(self, "Guided", self:GetGuided())
		end

		local Phys = self:GetPhysicsObject()

		if (self:GetState() == STATE_ARMED) and (Phys:GetVelocity():Length() > 400) and not self:IsPlayerHolding() and not constraint.HasConstraints(self) then
			self.FreefallTicks = self.FreefallTicks + 1

			if self.FreefallTicks >= 5 then
				local Tr = util.QuickTrace(self:GetPos(), Phys:GetVelocity():GetNormalized() * 4000, self)

				if Tr.Hit then
					self:Detonate()
				end
			end
		else
			self.FreefallTicks = 0
		end

		JMod.AeroDrag(self, self:GetForward())
		self:NextThink(CurTime() + .1)

		return true
	end
elseif CLIENT then
	function ENT:Initialize()
	end

	--
	function ENT:Think()
	end

	--
	function ENT:Draw()
		self:DrawModel()
	end

	language.Add("ent_jack_gmod_ezblubomb", "EZ Cluster Buster")
end
