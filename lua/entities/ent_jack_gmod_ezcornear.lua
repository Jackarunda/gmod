-- AdventureBoots 2023
AddCSLuaFile()
ENT.Type = "anim"
ENT.Author = "Jackarunda"
ENT.Information = "glhfggwpezpznore"
ENT.PrintName = "EZ Corn Cob"
ENT.Category = "JMod - EZ Misc."
ENT.Spawnable = true -- For now...
ENT.AdminOnly = false
---
ENT.JModEZstorable = true

local STATE_NORMAL, STATE_COOKING = 0, 1
---
function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "State")
end
---
if SERVER then
	function ENT:Initialize()
		self:SetModel("models/jmod/props/plants/corn_cob.mdl")
		self:SetMaterial("models/jmod/props/plants/cornear")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:DrawShadow(true)
		self:SetUseType(SIMPLE_USE)
		---
		local Phys = self:GetPhysicsObject()
		timer.Simple(.01, function()
			if IsValid(Phys) then
				Phys:SetMass(5)
				Phys:Wake()
			end
		end)
		---
		local Time = CurTime()
		self.LastTouchedTime = Time
		self.EZremoveSelf = self.EZremoveSelf or false
		self:SetState(STATE_NORMAL)
		if self.Mutated then
			self:Mutate() -- Just to make sure
		end
	end

	function ENT:Mutate()
		if (self.Mutated) then return end
		self.Mutated = true
		self:SetMaterial("models/jmod/props/plants/cornstalkdry")
	end

	function ENT:PhysicsCollide(data, physobj)
		if data.DeltaTime > 0.2 and data.Speed > 50 then
			self:EmitSound("physics/body/body_medium_impact_soft7.wav", 60, math.random(70, 130))
			if (data.Speed > 100) and (self:GetState() == STATE_COOKING) then
				timer.Simple(0, function() self:Detonate() end)
			end
		end
	end

	function ENT:Use(ply)
		local Time = CurTime()
		local Alt = JMod.IsAltUsing(ply)
		local State = self:GetState()

		if State == STATE_NORMAL then
			if Alt then
				if self.Mutated then
					JMod.ThrowablePickup(ply, self, 200, 300)
					self:SetState(STATE_COOKING)
				else
					if JMod.ConsumeNutrients(ply, 4) then
						sound.Play("snds_jack_gmod/nom" .. math.random(1, 5) .. ".ogg", self:GetPos(), 60, math.random(90, 110))
	
						self:Remove()
					end
				end
			else
				self.EZremoveSelf = false
				self.LastTouchedTime = Time
				ply:PickupObject(self)
				JMod.Hint(ply, "alt to plant")
			end
		else
			self:SetState(STATE_NORMAL)
		end
	end

	function ENT:Detonate()
		if self.Exploded then return end
		self.Exploded = true
		local SelfPos, Owner, SelfVel = self:LocalToWorld(self:OBBCenter()), JMod.GetEZowner(self), self:GetPhysicsObject():GetVelocity()
		JMod.Sploom(Owner, SelfPos, 10)

		for i = 1, 10 do
			timer.Simple(i / 120, function()
				local Gas = ents.Create("ent_jack_gmod_ezgasparticle")
				Gas:SetPos(SelfPos)
				JMod.SetEZowner(Gas, Owner)
				Gas:Spawn()
				Gas:Activate()
				Gas.CurVel = (SelfVel + VectorRand() * math.random(1, 200))
			end)
		end

		if IsValid(self.EZowner) then
			JMod.Hint(JMod.GetEZowner(self), "gas spread", self:GetPos())
		end

		self:Remove()
	end

	function ENT:Degenerate() 
		constraint.RemoveAll(self)
		self:SetNotSolid(true)
		self:DrawShadow(false)
		self:GetPhysicsObject():EnableCollisions(false)
		self:GetPhysicsObject():EnableGravity(false)
		self:GetPhysicsObject():SetVelocity(Vector(0, 0, -5))
		timer.Simple(2, function()
			if (IsValid(self)) then self:Remove() end
		end)
	end

	function ENT:Think()
		local State, Time = self:GetState(), CurTime()
		if State == STATE_NORMAL then
			if self.EZremoveSelf and ((Time - 300) > self.LastTouchedTime) then
				self:Degenerate()
			end
		end
		self:NextThink(Time + 5)
		return true
	end

	function ENT:OnTakeDamage(dmginfo)
		self:TakePhysicsDamage(dmginfo)
		local Pos, State = self:GetPos(), self:GetState()

		local Damage = dmginfo:GetDamage()
		if dmginfo:IsDamageType(DMG_RADIATION) and (math.random(0, 1000) >= 999) then
			self.Mutate()
		end
		if not(self.NoMorePop) and dmginfo:IsDamageType(DMG_BURN) or dmginfo:IsDamageType(DMG_SLOWBURN) and (math.random(1, 10) > 6) then
			if (State == STATE_NORMAL) then
				local Pop = ents.Create("ent_jack_gmod_ezcornkernals")
				Pop.Mutated = self.Mutated
				Pop:SetPos(self:GetPos())
				Pop:Spawn()
				Pop:Activate()
				self:EmitSound("garrysmod/balloon_pop_cute.wav", 60, math.random(70, 130))
				self.NoMorePop = true
				SafeRemoveEntityDelayed(self, 0)
			elseif (State == STATE_COOKING) then
				timer.Simple(0, function() self:Detonate() end)
			end
		end

		if JMod.LinCh(dmginfo:GetDamage(), 30, 100) then
			sound.Play("Wood_Solid.Break", Pos)
			SafeRemoveEntityDelayed(self, 1)
		end
	end

	function ENT:OnRemove()
		--
	end

	function ENT:PostEntityPaste(ply, ent, createdEntities)
		local Time = CurTime()
		JMod.SetEZowner(self, ply, true)
		self.LastTouchedTime = Time
	end

elseif CLIENT then
	function ENT:Initialize()
		--
	end

	function ENT:Draw()
		self:DrawModel()
	end
	language.Add("ent_jack_gmod_ezcornear", "EZ Corn Cob")
end
