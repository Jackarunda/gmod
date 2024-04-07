-- Jackarunda 2021
AddCSLuaFile()
ENT.Type = "anim"
ENT.Author = "Jackarunda"
ENT.Category = "JMod - EZ Misc."
ENT.Information = "glhfggwpezpznore"
ENT.PrintName = "EZ Flamethrower"
ENT.NoSitAllowed = true
ENT.Spawnable = false -- No warcrime for you
ENT.AdminSpawnable = true
---
ENT.JModPreferredCarryAngles = Angle(0, 0, 0)
ENT.DamageThreshold = 120
ENT.JModEZstorable = true

function ENT:SetupDataTables() 
	self:NetworkVar("Float", 0, "Fuel")
	self:NetworkVar("Float", 1, "Gas")
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
		self:SetModel("models/weapons/w_models/w_tooljox.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:DrawShadow(true)
		self:SetUseType(SIMPLE_USE)

		---
		local Phys = self:GetPhysicsObject()
		timer.Simple(.01, function()
			if not IsValid(Phys) then return end
			Phys:SetMass(50)
			Phys:Wake()
		end)
		self.MaxFuel = 100
		self.MaxGas = 100
		if self.SpawnFull then
			self:SetFuel(100)
			self:SetGas(100)
		end
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
		self.Entity:TakePhysicsDamage(dmginfo)

		if dmginfo:GetDamage() > self.DamageThreshold then
			local Pos = self:GetPos()
			sound.Play("Metal_Box.Break", Pos)

			self:Remove()
		end
	end

	function ENT:Use(activator)
		local SwepToGive = "wep_jack_gmod_ezflamethrower"
		if activator:KeyDown(JMod.Config.General.AltFunctionKey) then
			activator:PickupObject(self)
		elseif not activator:HasWeapon(SwepToGive) then
			activator:Give(SwepToGive)
			activator:SelectWeapon(SwepToGive)

			local ToolBox = activator:GetWeapon(SwepToGive)
			ToolBox:SetFuel(self:GetFuel())
			ToolBox:SetGas(self:GetGas())

			self:Remove()
		else
			activator:PickupObject(self)
		end
	end

elseif CLIENT then
	function ENT:Initialize()
		self.MaxFuel = 100
		self.MaxGas = 100
	end
	function ENT:Draw()
		self:DrawModel()
		local Opacity = math.random(50, 200)
		local FuelFrac, GasFrac = self:GetFuel()/self.MaxFuel, self:GetGas()/self.MaxGas
		JMod.HoloGraphicDisplay(self, Vector(0, -5, 17), Angle(90, -50, 90), .05, 300, function()
			draw.SimpleTextOutlined("FUEL "..math.Round(FuelFrac*100).."%","JMod-Display",-200,10,JMod.GoodBadColor(FuelFrac, true, Opacity),TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP,3,Color(0,0,0,Opacity))
			draw.SimpleTextOutlined("GAS "..math.Round(GasFrac*100).."%","JMod-Display",0,10,JMod.GoodBadColor(GasFrac, true, Opacity),TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP,3,Color(0,0,0,Opacity))
		end)
	end

	language.Add("ent_jack_gmod_eztoolbox", "EZ Toolbox")
end
