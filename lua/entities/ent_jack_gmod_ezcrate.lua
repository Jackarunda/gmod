-- Jackarunda 2021
AddCSLuaFile()
ENT.Type = "anim"
ENT.PrintName = "EZ Resource Crate"
ENT.Author = "Jackarunda, TheOnly8Z"
ENT.Category = "JMod - EZ Misc."
ENT.NoSitAllowed = true
ENT.Spawnable = true
ENT.AdminSpawnable = true
---
ENT.JModPreferredCarryAngles = Angle(0, 0, 0)
ENT.DamageThreshold = 120
ENT.IsJackyEZcrate = true

---
function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "Resource")
	self:NetworkVar("String", 0, "ResourceType")
end

function ENT:GetEZsupplies(typ)
	local Supplies = {[self:GetResourceType()] = self:GetResource()}
	if typ then
		if Supplies[typ] then
			return Supplies[typ]
		else
			return nil
		end
	else
		return Supplies
	end
end

function ENT:SetEZsupplies(typ, amt, setter)
	if not SERVER then  return end
	if typ ~= self:GetResourceType() then return end
	if amt <= 0 then self:ApplySupplyType("generic") end
	self:SetResource(math.Clamp(amt, 0, self.MaxResource))
	self:CalcWeight()
end

---
if SERVER then
	function ENT:SpawnFunction(ply, tr)
		local SpawnPos = tr.HitPos + tr.HitNormal * 40
		local ent = ents.Create(self.ClassName)
		ent:SetAngles(Angle(0, 0, 0))
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
		self:SetModel("models/props_junk/wood_crate002a.mdl")
		--self:SetModelScale(1.5,0)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:DrawShadow(true)
		self:SetUseType(SIMPLE_USE)
		---
		self:SetResource(0)
		self:ApplySupplyType("generic")
		
		self.MaxResource = 100 * 20 * JMod.Config.ResourceEconomy.MaxResourceMult -- standard size
		self.EZconsumes = {}

		for k, v in pairs(JMod.EZ_RESOURCE_TYPES) do
			table.insert(self.EZconsumes, v)
		end

		self.NextLoad = 0
		---
		if istable(WireLib) then
			self.Outputs = WireLib.CreateOutputs(self, {"Type [STRING]", "Amount Left [NORMAL]"}, {"Will be 'generic' by default", "Amount of resources left in the crate"})
			self.Inputs = WireLib.CreateInputs(self, {"Drop [NORMAL]"}, {"Drops the amount specified in the input"})
		end
		---
		timer.Simple(.01, function()
			if IsValid(self) then
				self:CalcWeight()
			end
		end)
	end

	function ENT:TriggerInput(iname, value)
		if iname == "Drop" then
			if value > 0 then
				self:DropAmount(value)
			end
		end
	end

	function ENT:UpdateConfig()
		self:CalcWeight()
	end

	function ENT:ApplySupplyType(typ)
		self:SetResourceType(typ)
		self.EZsupplies = typ
		if typ == "generic" then
			self.ChildEntity = ""
		else
			self.ChildEntity = JMod.EZ_RESOURCE_ENTITIES[typ]
		end
	end

	function ENT:PhysicsCollide(data, physobj)
		if data.DeltaTime > 0.2 then
			if data.Speed > 100 then
				self:EmitSound("Wood_Crate.ImpactHard")
				self:EmitSound("Wood_Box.ImpactHard")
			end
		end
	end

	function ENT:CalcWeight()
		self.MaxResource = 100 * 20 * JMod.Config.ResourceEconomy.MaxResourceMult
		local Frac = self:GetResource() / self.MaxResource
		self:GetPhysicsObject():SetMass(100 + Frac * 300)
		self:GetPhysicsObject():Wake()
		if (WireLib) then
			WireLib.TriggerOutput(self, "Type", self:GetResourceType())
			WireLib.TriggerOutput(self, "Amount Left", self:GetResource())
		end
	end

	function ENT:OnTakeDamage(dmginfo)
		self:TakePhysicsDamage(dmginfo)

		if (dmginfo:GetDamage() > self.DamageThreshold) and not(self.Destroyed) then
			self.Destroyed = true
			local Pos = self:GetPos()
			sound.Play("Wood_Crate.Break", Pos)
			sound.Play("Wood_Box.Break", Pos)

			if self.ChildEntity ~= "" and self:GetResource() > 0 then
				for i = 1, math.floor(self:GetResource() / 100) do
					local Box = ents.Create(self.ChildEntity)
					Box:SetPos(Pos + self:GetUp() * 20)
					Box:SetAngles(self:GetAngles())
					Box:Spawn()
					Box:Activate()
				end
			end

			self:Remove()
		end
	end

	function ENT:Use(activator)
		JMod.Hint(activator, "crate")
		local Resource = self:GetResource()
		if Resource <= 0 then return end
		local Box, Given = ents.Create(self.ChildEntity), math.min(Resource, 100 * JMod.Config.ResourceEconomy.MaxResourceMult)
		Box:SetPos(self:GetPos() + self:GetUp() * 5)
		Box:SetAngles(self:GetAngles())
		Box:Spawn()
		Box:Activate()
		Box:SetEZsupplies(self:GetResourceType(), Given)
		timer.Simple(0.1, function()
			if IsValid(Box) and IsValid(activator) and activator:Alive() then
				activator:PickupObject(Box)
			end
		end)
		Box.NextLoad = CurTime() + 2
		self:SetEZsupplies(self:GetResourceType(), Resource - Given)
		self:EmitSound("Ammo_Crate.Close")
		self:CalcWeight()
	end

	function ENT:DropAmount(amt)
		local Resource = self:GetResource()
		if Resource <= 0 then return end
		local Given = math.min(Resource, amt)
		JMod.MachineSpawnResource(self, self:GetResourceType(), Given, Vector(0, 0, 6), Angle(0, 0, 0), nil, nil)
		self:SetEZsupplies(self:GetResourceType(), Resource - Given)
	end

	function ENT:Think()
	end

	function ENT:OnRemove()
	end

	function ENT:TryLoadResource(typ, amt, overrideTimer)
		local Time = CurTime()
		if (self.NextLoad > Time) and not(overrideTimer) then self.NextLoad = math.min(self.NextLoad, Time + .5) return 0 end
		if amt < 1 then return 0 end

		-- If unloaded, we set our type to the item type
		if self:GetResource() <= 0 and self:GetResourceType() == "generic" then
			self:ApplySupplyType(typ)
		end

		-- Consider the loaded type
		local OurNewType = self:GetResourceType()
		if typ == OurNewType then
			local Resource = self:GetResource()
			local Missing = self.MaxResource - Resource
			if Missing <= 0 then return 0 end
			local Accepted = math.min(Missing, amt)
			self:SetEZsupplies(OurNewType, Resource + Accepted)
			self:CalcWeight()
			self.NextLoad = Time + .5

			return Accepted
		end

		return 0
	end

	function ENT:PreEntityCopy()
		self.DupeEZsupplies = self.EZsupplies
	end

	local RestrictedMaterials = {
		JMod.EZ_RESOURCE_TYPES.FISSILEMATERIAL,
		JMod.EZ_RESOURCE_TYPES.ANTIMATTER
	}
	function ENT:PostEntityPaste(ply)
		local Type = self:GetResourceType()
		if not(JMod.IsAdmin(ply)) and table.HasValue(RestrictedMaterials, Type) then
			self:SetEZsupplies(Type, 0, self)
			self:ApplySupplyType(self.DupeEZsupplies or self.EZsupplies)
		end
		self.NextLoad = 0
	end
elseif CLIENT then
	local TxtCol = Color(10, 10, 10, 220)

	function ENT:Draw()
		local Ang, Pos = self:GetAngles(), self:GetPos()
		local Closeness = LocalPlayer():GetFOV() * EyePos():Distance(Pos)
		local DetailDraw = Closeness < 45000 -- cutoff point is 500 units when the fov is 90 degrees
		local ResourceName = string.upper(self:GetResourceType())
		self:DrawModel()

		if DetailDraw then
			local Up, Right, Forward, Resource = Ang:Up(), Ang:Right(), Ang:Forward(), tostring(self:GetResource())
			Ang:RotateAroundAxis(Ang:Right(), 90)
			Ang:RotateAroundAxis(Ang:Up(), -90)
			cam.Start3D2D(Pos + Up * 10 - Forward * 20 + Right, Ang, .15)
			draw.SimpleText("JACKARUNDA INDUSTRIES", "JMod-Stencil-S", 0, 0, TxtCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
			draw.SimpleText(ResourceName, "JMod-Stencil", 0, 15, TxtCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
			draw.SimpleText(Resource .. " UNITS", "JMod-Stencil-S", 0, 70, TxtCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
			cam.End3D2D()
			---
			Ang:RotateAroundAxis(Ang:Right(), 180)
			cam.Start3D2D(Pos + Up * 10 + Forward * 20 - Right, Ang, .15)
			draw.SimpleText("JACKARUNDA INDUSTRIES", "JMod-Stencil-S", 0, 0, TxtCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
			draw.SimpleText(ResourceName, "JMod-Stencil", 0, 15, TxtCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
			draw.SimpleText(Resource .. " UNITS", "JMod-Stencil-S", 0, 70, TxtCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
			cam.End3D2D()
		end
	end

	language.Add("ent_jack_gmod_ezcrate", "EZ Resource Crate")
end
