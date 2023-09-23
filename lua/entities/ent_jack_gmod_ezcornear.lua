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
ENT.EZconsumes = nil
ENT.UsableMats = {MAT_DIRT, MAT_SAND, MAT_SLOSH, MAT_GRASS, MAT_SNOW}

local STATE_NORMAL, STATE_BURIED, STATE_GERMINATING = 0, 1, 2
---
function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "State")
end
---
if SERVER then
	function ENT:Initialize()
		self:SetModel("models/jmod/props/plants/corn_cob.mdl")
		self:SetMaterial("models/jmod/props/plants/cornv81t_d")
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
		self.LastWateredTime = Time
		self.EZremoveSelf = self.EZremoveSelf or false
		self:SetState(STATE_NORMAL)
		self.Mutated = false
		self.EZconsumes = {JMod.EZ_RESOURCE_TYPES.WATER}
		self.Hydration = 0
		self.GroundWeld = nil
	end

	function ENT:Mutate()
		if (self.Mutated) then return end
		self.Mutated = true
		self:SetSubMaterial(0, "models/jmod/props/plants/corn01t_d")
		self.EZconsumes = {JMod.EZ_RESOURCE_TYPES.EXPLOSIVES}
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
		end
	end

	function ENT:TryLoadResource(typ, amt)
		if(amt <= 0)then return 0 end
		local Time = CurTime()
		local Accepted = 0
		if(typ == JMod.EZ_RESOURCE_TYPES.WATER) or (typ == JMod.EZ_RESOURCE_TYPES.EXPLOSIVES)then
			local Wata = self.Hydration
			local Missing = 50 - Wata
			if (Missing <= 0) then return 0 end
			Accepted = math.min(Missing, amt)
			self.Hydration = Wata + Accepted
			self.LastWateredTime = Time
			self:EmitSound("snds_jack_gmod/liquid_load.wav", 60, math.random(120, 130))
		end
		return math.ceil(Accepted)
	end

	function ENT:PhysicsCollide(data, physobj)
		if data.DeltaTime > 0.2 and data.Speed > 50 then
			self:EmitSound("physics/body/body_medium_impact_soft7.wav", 60, math.random(70, 130))
		end
	end

	function ENT:Use(ply)
		local Time = CurTime()
		local Alt = ply:KeyDown(JMod.Config.General.AltFunctionKey)
		local State = self:GetState()

		if State == STATE_NORMAL then
			--if ply:KeyDown(IN_SPEED) then
				if Alt then
					ply.EZnutrition = ply.EZnutrition or {
						NextEat = 0,
						Nutrients = 0
					}
					if ply.EZnutrition.NextEat < Time then
						if ply.EZnutrition.Nutrients < 100 then
							sound.Play("snds_jack_gmod/nom" .. math.random(1, 5) .. ".wav", self:GetPos(), 60, math.random(90, 110))
	
							JMod.ConsumeNutrients(ply, 4)
	
							self:Remove()
						else
							JMod.Hint(ply, "nutrition filled")
						end
					end
				else
					self.EZremoveSelf = false
					self.LastTouchedTime = Time
					ply:PickupObject(self)
					JMod.Hint(ply, "alt to plant")
				end
			--[[else
				if Alt then
					JMod.SetEZowner(self, ply)
					self:Bury(ply)
					JMod.Hint(ply, "water seed")
				else
					ply:PickupObject(self)
					JMod.Hint(ply, "alt to eat")
					self.EZremoveSelf = false
					self.LastTouchedTime = Time
				end
			end]]--
		--[[elseif State == STATE_BURIED then
			self:DrawShadow(true)
			constraint.RemoveAll(self)
			self:SetPos(self:GetPos() + self:GetUp() * 40)
			self:SetState(STATE_NORMAL)
			self:SetCollisionGroup(COLLISION_GROUP_NONE)
			ply:PickupObject(self)--]]
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
		elseif State == STATE_BURIED then
			if not IsValid(self.GroundWeld) then self:Degenerate() end
			local Water = 0
			if StormFox and StormFox.IsRaining() then 
				Water = 5
				self.LastWateredTime = Time
			end
			self.Hydration = math.Clamp(self.Hydration + Water, 0, 100)
			if (self.Hydration >= 50) then
				self:SetState(STATE_GERMINATING)
				self:SetColor(Color(142, 172, 125))
			elseif (self.Hydration <= 1) and ((Time - 600) > self.LastWateredTime) then
				self:Degenerate()
			end
		elseif State == STATE_GERMINATING then
			if not IsValid(self.GroundWeld) then self:Degenerate() end
			if ((Time - 60) > self.LastTouchedTime) then
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
				timer.Simple(0, function()
					if IsValid(Stalk) and not(Stalk.Mutated) then
						Stalk:Mutate()
					end
				end)
			end
			JMod.SetEZowner(Stalk, Owner)
		end)
	end

	function ENT:OnTakeDamage(dmginfo)
		self:TakePhysicsDamage(dmginfo)
		local Pos, State = self:GetPos(), self:GetState()

		local Damage = dmginfo:GetDamage()
		if dmginfo:IsDamageType(DMG_RADIATION) and (math.random(0, 1000) >= 999) then
			self.Mutate()
		end
		if not(self.NoMorePop) and (State == STATE_NORMAL) and dmginfo:IsDamageType(DMG_BURN) or dmginfo:IsDamageType(DMG_SLOWBURN) and (math.random(1, 10) > 6) then
			local Pop = ents.Create("ent_jack_gmod_ezcornkernals")
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

	function ENT:OnRemove()
		--
	end

	function ENT:PostEntityPaste(ply, ent, createdEntities)
		local Time = CurTime()
		JMod.SetEZowner(self, ply, true)
		self.NextRefillTime = Time
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
	language.Add("ent_jack_gmod_ezcornear", "EZ Corn Cob")
end
