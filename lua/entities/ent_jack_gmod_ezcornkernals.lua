-- AdventureBoots 2023
AddCSLuaFile()
ENT.Type = "anim"
ENT.Author = "Jackarunda"
ENT.Category = "JMod - EZ Misc."
ENT.PrintName = "EZ Corn Kernels"
ENT.NoSitAllowed = true
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.JModEZstorable = true
---
ENT.EZconsumes = nil
ENT.JModEZstorable = true
ENT.UsableMats = {MAT_DIRT, MAT_SAND, MAT_SLOSH, MAT_GRASS, MAT_SNOW}
ENT.MaxWater = 25
ENT.JModDontIrradiate = false

local STATE_NORMAL, STATE_BURIED, STATE_GERMINATING = 0, 1, 2
---
function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "State")
end
---
if SERVER then
	function ENT:SpawnFunction(ply, tr)
		local SpawnPos = tr.HitPos + tr.HitNormal * 20
		local ent = ents.Create(self.ClassName)
		ent:SetAngles(Angle(0, 0, 0))
		ent:SetPos(SpawnPos)
		ent:Spawn()
		ent:Activate()

		return ent
	end

	function ENT:Initialize()
		self:SetModel("models/jmod/props/seed_packet.mdl")
		self:SetMaterial("models/jmod/props/corn_packet")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:DrawShadow(true)
		self:SetUseType(SIMPLE_USE)
		self:GetPhysicsObject():SetMass(5)

		local Phys = self:GetPhysicsObject()
		timer.Simple(.01, function()
			if IsValid(Phys) then
				Phys:SetMass(5)
				Phys:Wake()
			end
		end)

		local Time = CurTime()
		self.LastTouchedTime = Time -- we need to have some kind of auto-despawn, since they multiply
		self.LastWateredTime = Time
		self.EZremoveSelf = self.EZremoveSelf or false
		self:SetState(STATE_NORMAL)
		self.Hydration = 0
		self.GroundWeld = nil
		self.EZconsumes = {JMod.EZ_RESOURCE_TYPES.WATER}
		if self.Mutated then
			self:Mutate()
		end
	end

	function ENT:Mutate()
		if (self.Mutated) then return end
		self.Mutated = true
		self.EZconsumes = {JMod.EZ_RESOURCE_TYPES.CHEMICALS}
	end

	function ENT:Bury(activator)
		local Tr = util.QuickTrace(activator:GetShootPos(), activator:GetAimVector() * 100, {activator, self})

		if Tr.Hit and table.HasValue(self.UsableMats, Tr.MatType) and IsValid(Tr.Entity:GetPhysicsObject()) then
			local Ang = Tr.HitNormal:Angle()
			Ang:RotateAroundAxis(Ang:Right(), -90)
			local Pos = Tr.HitPos - Tr.HitNormal * 0
			self:SetAngles(Ang)
			self:SetPos(Pos)
			self:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)
			self.GroundWeld = constraint.Weld(self, Tr.Entity, 0, 0, 50000, true)
			local Fff = EffectData()
			Fff:SetOrigin(Tr.HitPos)
			Fff:SetNormal(Tr.HitNormal)
			Fff:SetScale(1)
			util.Effect("eff_jack_sminebury", Fff, true, true)
			activator:EmitSound("Dirt.BulletImpact")
			self.ShootDir = Tr.HitNormal
			self:DrawShadow(false)
			self:SetState(STATE_BURIED)
			--JackaGenericUseEffect(activator)
			self.LastWateredTime = CurTime()
		end
	end

	function ENT:TryLoadResource(typ, amt)
		if(amt <= 0)then return 0 end
		local Time = CurTime()
		local Accepted = 0
		if(typ == JMod.EZ_RESOURCE_TYPES.WATER) or (self.Mutated and (typ == JMod.EZ_RESOURCE_TYPES.CHEMICALS))then
			local Wata = self.Hydration
			local Missing = self.MaxWater - Wata
			if (Missing <= 0) then return 0 end
			Accepted = math.min(Missing, amt)
			self.Hydration = Wata + Accepted
			self.LastWateredTime = Time
			self:EmitSound("snds_jack_gmod/liquid_load.ogg", 60, math.random(120, 130))
		end
		return math.ceil(Accepted)
	end

	function ENT:PhysicsCollide(data, physobj)
		--
	end

	function ENT:OnTakeDamage(dmginfo)
		self:TakePhysicsDamage(dmginfo)
		local Pos, State = self:GetPos(), self:GetState()

		if not(self.NoMorePop) and (State == STATE_NORMAL) and dmginfo:IsDamageType(DMG_BURN) or dmginfo:IsDamageType(DMG_SLOWBURN) and (math.random(1, 10) >= 4) then
			local Pop = ents.Create("ent_jack_gmod_ezpopcorn")
			Pop:SetPos(self:GetPos())
			Pop:Spawn()
			Pop:Activate()
			self:EmitSound("garrysmod/balloon_pop_cute.wav", 60, math.random(70, 130))
			self.NoMorePop = true
			SafeRemoveEntityDelayed(self, 0)
		end

		if JMod.LinCh(dmginfo:GetDamage(), 30, 100) then
			sound.Play("Wood_Solid.Break", Pos)
			SafeRemoveEntityDelayed(self, 1)
		end
	end

	function ENT:Use(activator)
		local State = self:GetState()
		--if State < 0 then return end
		self.LastTouchedTime = CurTime()
		local Alt = JMod.IsAltUsing(activator)

		if State == STATE_NORMAL then
			if Alt then
				JMod.SetEZowner(self, activator)
				self:Bury(activator)
				JMod.Hint(activator, "water seed")
			else
				activator:PickupObject(self)
				JMod.Hint(activator, "alt to plant")
			end
		elseif State == STATE_BURIED then
			self:DrawShadow(true)
			constraint.RemoveAll(self)
			self:SetPos(self:GetPos() + self:GetUp() * 40)
			self:SetState(STATE_NORMAL)
			self:SetCollisionGroup(COLLISION_GROUP_NONE)
			activator:PickupObject(self)
		end
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
			if self:IsOnFire() then
				local Pop = ents.Create("ent_jack_gmod_ezpopcorn")
				Pop:SetPos(self:GetPos())
				Pop:Spawn()
				Pop:Activate()
				self:EmitSound("garrysmod/balloon_pop_cute.wav", 60, math.random(70, 130))
				SafeRemoveEntityDelayed(self, 0)
			end
		elseif State == STATE_BURIED then
			if not IsValid(self.GroundWeld) then self:Degenerate() end
			local Water = 0
			if StormFox and StormFox.IsRaining() then 
				Water = 5
				self.LastWateredTime = Time
			end
			self.Hydration = math.Clamp(self.Hydration + Water, 0, 100)
			if (self.Hydration >= 25 * JMod.Config.ResourceEconomy.WaterRequirementMult) then
				self:SetState(STATE_GERMINATING)
				self:SetColor(Color(150, 150, 150))
			elseif (self.Hydration <= 1) and ((Time - 600) > self.LastWateredTime) then
				self:Degenerate()
			end
		elseif State == STATE_GERMINATING then
			if not IsValid(self.GroundWeld) then self:Degenerate() end
			if ((Time - 60 * (1 / math.max(JMod.Config.ResourceEconomy.GrowthSpeedMult, 0.01))) > self.LastTouchedTime) then
				self:SpawnCorn()
			end
		end
		self:NextThink(Time + 5)
		return true
	end

	function ENT:SpawnCorn()
		local Pos, Owner, WatToGive = self:GetPos(), self.EZowner, self.Hydration
		self:Remove()
		timer.Simple(.1, function()
			local Stalk = ents.Create("ent_jack_gmod_ezcornstalk")
			Stalk:SetPos(Pos + Vector(0, 0, 10))
			Stalk:Spawn()
			Stalk:Activate()
			Stalk.Hydration = WatToGive * 2
			if self.Mutated then
				Stalk:Mutate()
			end
			JMod.SetEZowner(Stalk, Owner)
		end)
	end

	function ENT:OnRemove()
		--
	end

	function ENT:PostEntityPaste(ply, ent, createdEntities)
		local Time = CurTime()
		JMod.SetEZowner(self, ply, true)
		self.LastTouchedTime = Time
	end

	function ENT:GravGunPickupAllowed(ply) 
		local State = self:GetState()
		if (State == STATE_NORMAL) then
			return true
		end
	end
	
elseif CLIENT then
	function ENT:Initialize()
		--
	end

	function ENT:Draw()
		self:DrawModel()
	end

	language.Add("ent_jack_gmod_ezcornkernals", "EZ Corn Kernels")
end
