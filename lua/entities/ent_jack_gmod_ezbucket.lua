-- AdventureBoots 2023
AddCSLuaFile()
ENT.Type = "anim"
ENT.Author = "Jackarunda"
ENT.Category = "JMod - EZ Misc."
ENT.Information = "glhfggwpezpznore"
ENT.PrintName = "EZ Bucket"
ENT.NoSitAllowed = true
ENT.Spawnable = true
ENT.AdminSpawnable = true
---
ENT.JModPreferredCarryAngles = Angle(0, 0, 0)
ENT.DamageThreshold = 120
ENT.JModEZstorable = true
ENT.JModEZstorableVolume = 2.5

function ENT:GetEZsupplies(typ) 
	local Supplies = {[JMod.EZ_RESOURCE_TYPES.WATER] = self:GetWater()}
	if typ then
		if Supplies[typ] and Supplies[typ] > 0 then
			return Supplies[typ]
		else
			return nil
		end
	else
		return Supplies
	end
end

function ENT:SetEZsupplies(typ, amt, setter)
	if not SERVER then return end -- Important because this is shared as well
	if typ ~= JMod.EZ_RESOURCE_TYPES.WATER then return end -- Type doesn't matter because we only have one type, but we have it here because of uniformness
	self:SetWater(amt) -- Otherwise, just set our resource to the new value
	--[[local Phys = self:GetPhysicsObject()
	timer.Simple(.01, function()
		if not IsValid(Phys) then return end
		Phys:SetMass(math.max(self:GetWater() * .5, 2.5))
		Phys:Wake()
	end)--]]
end

hook.Add("OnEntityWaterLevelChanged", "JMod_BucketFill", function(ent, old, new)
	if not IsValid(ent) then return end
	if ent:GetClass() == "ent_jack_gmod_ezbucket" and new >= 1 then
		ent:SetEZsupplies( JMod.EZ_RESOURCE_TYPES.WATER, ent.MaxWater or 50)
	end
end)

---
function ENT:SetupDataTables() 
	self:NetworkVar("Float", 0, "Water")
end

if SERVER then
	function ENT:SpawnFunction(ply, tr)
		local SpawnPos = tr.HitPos + tr.HitNormal * 40
		local ent = ents.Create(self.ClassName)
		ent:SetAngles(Angle(0, 0, 0))
		ent:SetPos(SpawnPos)
		JMod.SetEZowner(ent, ply)
		if JMod.Config.Machines.SpawnMachinesFull then
			ent.SpawnFull = true
		end
		ent:Spawn()
		ent:Activate()
		return ent
	end

	function ENT:Initialize()
		self:SetModel("models/props_junk/metalbucket01a.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:DrawShadow(true)
		self:SetUseType(SIMPLE_USE)

		---
		self.MaxWater = 50
		if self.SpawnFull then
			self:SetWater(self.MaxWater)
		end
		---
		local Phys = self:GetPhysicsObject()
		timer.Simple(.01, function()
			if not IsValid(Phys) then return end
			Phys:SetMass(math.max(self:GetWater(), 2.5))
			Phys:Wake()
		end)
	end

	function ENT:PhysicsCollide(data, physobj)
		if data.DeltaTime > 0.2 then
			if data.Speed > 100 then
				self:EmitSound("Metal_Box.ImpactHard")
				self:EmitSound("Canister.ImpactHard")
			end
		end
	end

	function ENT:OnTakeDamage(dmginfo)
		self:TakePhysicsDamage(dmginfo)

		if dmginfo:GetDamage() > self.DamageThreshold then
			local Pos = self:GetPos()
			sound.Play("Metal_Box.Break", Pos)

			self:Remove()
		end
	end

	function ENT:Use(activator)
		if JMod.IsAltUsing(activator) then
			activator:PickupObject(self)
		elseif not activator:HasWeapon("wep_jack_gmod_ezbucket") then
			activator:Give("wep_jack_gmod_ezbucket")
			activator:SelectWeapon("wep_jack_gmod_ezbucket")

			local ToolBox = activator:GetWeapon("wep_jack_gmod_ezbucket")
			ToolBox:SetWater(self:GetWater())

			self:Remove()
		else
			activator:PickupObject(self)
		end
	end

elseif CLIENT then
	function ENT:Initialize()
		self.MaxWater = 50
	end

	function ENT:Draw()
		self:DrawModel()
		local Opacity = math.random(50, 200)
		local WaterFrac = self:GetWater()/self.MaxWater
		JMod.HoloGraphicDisplay(self, Vector(10, 0, 5), Angle(90, -90, 90), .05, 300, function()
			draw.SimpleTextOutlined("WATER "..self:GetWater(),"JMod-Display",-200,10,JMod.GoodBadColor(WaterFrac, true, Opacity),TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP,3,Color(0,0,0,Opacity))
		end)
	end

	language.Add("ent_jack_gmod_ezbucket", "EZ Bucket")
end
