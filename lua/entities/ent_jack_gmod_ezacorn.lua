-- Jackarunda 2023
AddCSLuaFile()
ENT.Type = "anim"
ENT.Author = "Jackarunda"
ENT.Category = "JMod - EZ Misc."
ENT.PrintName = "EZ Acorn"
ENT.NoSitAllowed = true
ENT.Spawnable = false --wonder when jack will get back to this...
ENT.AdminSpawnable = true
---
ENT.JModEZstorable = true

local STATE_NORMAL, STATE_BURIED = 0, 1
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
		self:SetModel("models/cktheamazingfrog/player/scrat/acorn.mdl")
		self:SetModelScale(.25)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:DrawShadow(true)
		self:SetUseType(SIMPLE_USE)
		self:GetPhysicsObject():SetMass(5)

		timer.Simple(.01, function()
			self:GetPhysicsObject():SetMass(5)
			self:GetPhysicsObject():Wake()
		end)

		self.UsableMats = {MAT_DIRT, MAT_FOLIAGE, MAT_SAND, MAT_SLOSH, MAT_GRASS, MAT_SNOW}
		self.LastTouchedTime = CurTime() -- we need to have some kind of auto-despawn, since they multiply
		self:Activate()
	end

	function ENT:Bury(activator)
		local Tr = util.QuickTrace(activator:GetShootPos(), activator:GetAimVector() * 100, {activator, self})

		if Tr.Hit and table.HasValue(self.UsableMats, Tr.MatType) and IsValid(Tr.Entity:GetPhysicsObject()) then
			local Ang = Tr.HitNormal:Angle()
			Ang:RotateAroundAxis(Ang:Right(), -90)
			local Pos = Tr.HitPos - Tr.HitNormal * 10
			self:SetAngles(Ang)
			self:SetPos(Pos)
			constraint.Weld(self, Tr.Entity, 0, 0, 50000, true)
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

	function ENT:PhysicsCollide(data, physobj)
		--
	end

	function ENT:OnTakeDamage(dmginfo)
		self:TakePhysicsDamage(dmginfo)
		local Pos, State = self:GetPos(), self:GetState()

		if JMod.LinCh(dmginfo:GetDamage(), 30, 100) then
			sound.Play("Metal_Box.Break", Pos)
			--self:SetState(JMod.EZ_STATE_BROKEN)
			SafeRemoveEntityDelayed(self, 1)
		end
	end

	function ENT:Use(activator)
		local State = self:GetState()
		--if State < 0 then return end
		self.LastTouchedTime = CurTime()
		local Alt = activator:KeyDown(JMod.Config.General.AltFunctionKey)

		if State == STATE_NORMAL then
			if Alt then
				JMod.SetEZowner(self, activator)
				self:Bury(activator)
			else
				activator:PickupObject(self)
			end
		elseif State == STATE_BURIED then
			self:DrawShadow(true)
			constraint.RemoveAll(self)
			self:SetPos(self:GetPos() + self:GetUp() * 40)
			activator:PickupObject(self)
		end
	end

	function ENT:Think()
		local State, Time = self:GetState(), CurTime()

		if State == STATE_NORMAL then
			if Time - 120 > self.LastTouchedTime then
				self:Remove()
			end
		elseif State == STATE_BURIED then
			if Time - 60 > self.LastTouchedTime then
				self:SpawnTree()
			end
		end
		self:NextThink(Time + 1)
		return true
	end

	function ENT:SpawnTree() 
		local Tree = ents.Create("ent_jack_gmod_eztree")
		Tree:SetPos(self:GetPos() + Vector(0, 0, 10))
		Tree:SetAngles(Angle(0, 0, math.random(0, 360)))
		Tree:SetWater(10)
		Tree:Spawn()
		Tree:Activate()
		self:Remove()
	end

	function ENT:OnRemove()
	end
	
elseif CLIENT then
	function ENT:Initialize()
	end

	function ENT:Draw()
		self:DrawModel()
	end

	language.Add("ent_jack_gmod_ezacorn", "EZ Acorn")
end
