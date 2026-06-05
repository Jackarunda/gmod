-- Jackarunda 2026
AddCSLuaFile()
ENT.Type = "anim"
ENT.Author = "Jackarunda"
ENT.Category = "JMod - EZ Misc."
ENT.Information = "Reusable mount for snapping on munitions"
ENT.PrintName = "EZ Hardpoint"
ENT.Spawnable = true
ENT.AdminSpawnable = false
---
ENT.JModPreferredCarryAngles = Angle(0, 0, 0)
ENT.Model = "models/jmod/explosives/missile/rkx1.mdl"
ENT.EZbuoyancy = .3

if SERVER then
	function ENT:SpawnFunction(ply, tr)
		local SpawnPos = tr.HitPos + tr.HitNormal * 10
		local ent = ents.Create(self.ClassName)
		ent:SetAngles(Angle(0, 0, 0))
		ent:SetPos(SpawnPos)
		JMod.SetEZowner(ent, ply, true)
		ent:Spawn()
		ent:Activate()

		return ent
	end

	function ENT:Initialize()
		self:SetModel(self.Model)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:DrawShadow(true)
		self:SetUseType(SIMPLE_USE)
		---
		local Phys = self:GetPhysicsObject()
		timer.Simple(.01, function()
			if IsValid(Phys) then
				Phys:SetMass(100)
				Phys:Wake()
				Phys:EnableDrag(false)
				Phys:SetBuoyancyRatio(self.EZbuoyancy)
			end
		end)
		---
		self.AttachedEnt = nil
		self.AttachWeld = nil
		---
		if istable(WireLib) then
			self.Inputs = WireLib.CreateInputs(self, {"Launch [NORMAL]"}, {"Launches/drops the attached munition when > 0"})
			self.Outputs = WireLib.CreateOutputs(self, {"AttachedEntity [ENTITY]"}, {"The munition currently attached to the hardpoint"})
		end
	end

	function ENT:UpdateWireOutputs()
		if istable(WireLib) then
			WireLib.TriggerOutput(self, "AttachedEntity", IsValid(self.AttachedEnt) and self.AttachedEnt or NULL)
		end
	end

	function ENT:TriggerInput(iname, value)
		if iname == "Launch" and value > 0 then
			self:LaunchMunition(JMod.GetEZowner(self))
		end
	end

	function ENT:PhysicsCollide(data, physobj)
		local ent = data.HitEntity

		timer.Simple(0, function()
			if IsValid(self) and IsValid(ent) then
				self:AttachEntity(ent)
			end
		end)
	end

	function ENT:AttachEntity(ent)
		-- Only one munition at a time.
		if IsValid(self.AttachedEnt) and IsValid(self.AttachWeld) then return end

		if not IsValid(ent) then return end
		if ent == self then return end
		if ent.EZrackAngles == nil then return end
		if ent:GetVelocity():Length() >= 500 then return end
		if isfunction(ent.GetState) and ent:GetState() > 1 then return end

		local Time = CurTime()
		if self.NextAttach and (self.NextAttach > Time) then return end
		self.NextAttach = Time + .25

		if isfunction(ent.Arm) then
			ent:Arm(JMod.GetEZowner(self))
		end

		-- Angles: our angles with the munition's rack offset applied.
		ent:SetAngles(self:LocalToWorldAngles(ent.EZrackAngles))

		-- Position: either the munition's rack offset, or align its center of mass to our origin.
		if ent.EZrackOffset then
			ent:SetPos(self:LocalToWorld(ent.EZrackOffset))
		else
			local Phys = ent:GetPhysicsObject()
			local CenterWorld

			if IsValid(Phys) then
				CenterWorld = ent:LocalToWorld(Phys:GetMassCenter())
			else
				CenterWorld = ent:WorldSpaceCenter()
			end

			local CenterOffset = CenterWorld - ent:GetPos()
			ent:SetPos(self:GetPos() - CenterOffset)
		end

		-- Match our velocity so the weld doesn't snap from a speed difference.
		local SelfPhys, EntPhys = self:GetPhysicsObject(), ent:GetPhysicsObject()
		if IsValid(EntPhys) and IsValid(SelfPhys) then
			EntPhys:SetVelocity(SelfPhys:GetVelocity())
		end

		-- Weld with nocollide enabled.
		local Weld = constraint.Weld(self, ent, 0, 0, 0, true)

		self.AttachedEnt = ent
		self.AttachWeld = Weld
		ent.EZlauncher = self
		self:EmitSound("snd_jack_metallicload.ogg", 65, 90)
		self:UpdateWireOutputs()
	end

	function ENT:LaunchMunition(ply)
		if not IsValid(self.AttachedEnt) then return end
		local ent = self.AttachedEnt
		ply = ply or JMod.GetEZowner(self)

		-- Arm if able and not already armed.
		if isfunction(ent.GetState) and isfunction(ent.SetState) and (ent:GetState() ~= 1) then
			ent.DropOwner = ply
			ent:SetState(1)
		end

		-- Free the munition from the rack.
		if IsValid(self.AttachWeld) then
			self.AttachWeld:Remove()
		end

		local EntPhys, SelfPhys = ent:GetPhysicsObject(), self:GetPhysicsObject()
		if IsValid(EntPhys) then
			EntPhys:EnableMotion(true)
			EntPhys:Wake()
			if IsValid(SelfPhys) then
				EntPhys:SetVelocity(SelfPhys:GetVelocity())
			end
		end

		-- Pick a release command, preferring launch over drop.
		if isfunction(ent.Launch) then
			ent:Launch(ply)
		elseif isfunction(ent.Drop) then
			ent:Drop(ply)
		end

		self.AttachedEnt = nil
		self.AttachWeld = nil
		ent.EZlauncher = self
		self:EmitSound("snd_jack_metallicclick.ogg", 65, 90)
		self:UpdateWireOutputs()
	end

	function ENT:Use(activator)
		if not IsValid(activator) then return end

		-- Make sure the player is aiming directly at the hardpoint, so a Use meant
		-- to arm/disarm the attached munition doesn't accidentally drop it.
		local Tr = util.QuickTrace(activator:GetShootPos(), activator:GetAimVector() * 200, activator)
		if Tr.Entity ~= self then return end

		JMod.Hint(activator, "hardpoint")

		if IsValid(self.AttachedEnt) then
			self.AttachedEnt.EZlauncher = nil
		end

		if IsValid(self.AttachWeld) then
			self.AttachWeld:Remove()
			self.AttachedEnt = nil
			self.AttachWeld = nil
			self:EmitSound("snd_jack_metallicclick.ogg", 65, 90)
			self:UpdateWireOutputs()
		end
	end

	function ENT:PreEntityCopy()
		if IsValid(self.AttachedEnt) then
			self.DupeAttachedIndex = self.AttachedEnt:EntIndex()
		end
	end

	function ENT:PostEntityPaste(ply, ent, createdEntities)
		JMod.SetEZowner(ent, ply, true)

		if ent.DupeAttachedIndex then
			local Found = createdEntities[ent.DupeAttachedIndex]

			if IsValid(Found) then
				ent.AttachedEnt = Found
				
				for k, con in pairs(constraint.FindConstraints(ent, "Weld")) do
					if (con.Ent1 == Found) or (con.Ent2 == Found) then
						ent.AttachWeld = con.Constraint
						ent.EZlauncher = ent
						break
					end
				end

				if not IsValid(ent.AttachWeld) then
					print("EZ Hardpoint: something went wrong, couldn't find the weld connecting the pasted hardpoint to its attached entity")
				end
			end

			ent.DupeAttachedIndex = nil
			ent:UpdateWireOutputs()
		end
	end

	function ENT:OnRemove()
	end
elseif CLIENT then
	function ENT:Initialize()
		self:SetModel(self.Model)
	end

	function ENT:Draw()
		self:DrawModel()
	end

	function ENT:OnRemove()
	end

	language.Add("ent_jack_gmod_ezhardpoint", "EZ Hardpoint")
end
