-- Jackarunda 2021
AddCSLuaFile()
ENT.Type = "anim"
ENT.Author = "Jackarunda"
ENT.Category = "JMod - EZ Misc."
ENT.Information = "glhfggwpezpznore"
ENT.PrintName = "EZ Toolbox"
ENT.NoSitAllowed = true
ENT.Spawnable = true
ENT.AdminSpawnable = true
---
ENT.JModPreferredCarryAngles = Angle(0, 0, 0)
ENT.DamageThreshold = 120
ENT.JModEZstorable = true

---
local Props = {"models/props_c17/tools_wrench01a.mdl", "models/props_c17/tools_pliers01a.mdl", "models/props_forest/circularsaw01.mdl", "models/props_silo/welding_torch.mdl", "models/props_mining/pickaxe01.mdl", "models/props_silo/welding_helmet.mdl", "models/props_forest/axe.mdl", "models/weapons/w_defuser.mdl", "models/weapons/w_defuser.mdl", "models/props_c17/tools_wrench01a.mdl", "models/props_c17/tools_pliers01a.mdl"}

function ENT:SetupDataTables() 
	self:NetworkVar("Float", 0, "Electricity")
	self:NetworkVar("Float", 1, "Gas")
	self:NetworkVar("Float", 2, "BasicParts")
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
		timer.Simple(.01, function()
			self:GetPhysicsObject():SetMass(50)
			self:GetPhysicsObject():Wake()
		end)
		self.MaxElectricity = 100
		self.MaxGas = 100
		self.MaxBasicParts = 100
		if self.SpawnFull then
			self:SetElectricity(100)
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

			for k, mdl in pairs(Props) do
				local Item = ents.Create("prop_physics")
				Item:SetModel(mdl)
				Item:SetPos(Pos + VectorRand() * 5 + Vector(0, 0, 10))
				Item:SetAngles(VectorRand():Angle())
				Item:Spawn()
				Item:Activate()
				Item:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
				local Phys = Item:GetPhysicsObject()

				if IsValid(Phys) then
					Phys:SetVelocity(self:GetVelocity() / 2 + Vector(0, 0, 200) + VectorRand() * math.Rand(10, 600))
					Phys:AddAngleVelocity(VectorRand() * math.Rand(10, 3000))
				end

				SafeRemoveEntityDelayed(Item, math.random(10, 20))
			end

			self:Remove()
		end
	end

	function ENT:Use(activator)
		if activator:KeyDown(JMod.Config.General.AltFunctionKey) then
			activator:PickupObject(self)
		elseif not activator:HasWeapon("wep_jack_gmod_eztoolbox") then
			activator:Give("wep_jack_gmod_eztoolbox")
			activator:SelectWeapon("wep_jack_gmod_eztoolbox")

			local ToolBox = activator:GetWeapon("wep_jack_gmod_eztoolbox")
			ToolBox:SetBasicParts(self:GetBasicParts())
			ToolBox:SetElectricity(self:GetElectricity())
			ToolBox:SetGas(self:GetGas())

			self:Remove()
		else
			activator:PickupObject(self)
		end
	end

elseif CLIENT then
	function ENT:Initialize()
		self.MaxElectricity = 100
		self.MaxGas = 100
		self.MaxBasicParts = 100
	end
	function ENT:Draw()
		self:DrawModel()
		local Opacity = math.random(50, 200)
		local ElecFrac, GasFrac, PartFrac = self:GetElectricity()/self.MaxElectricity, self:GetGas()/self.MaxGas, self:GetBasicParts()/self.MaxBasicParts
		JMod.HoloGraphicDisplay(self, Vector(0, -5, 17), Angle(90, -50, 90), .05, 300, function()
			draw.SimpleTextOutlined("POWER "..math.Round(ElecFrac*100).."%","JMod-Display",-200,10,JMod.GoodBadColor(ElecFrac, true, Opacity),TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP,3,Color(0,0,0,Opacity))
			draw.SimpleTextOutlined("GAS "..math.Round(GasFrac*100).."%","JMod-Display",0,10,JMod.GoodBadColor(GasFrac, true, Opacity),TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP,3,Color(0,0,0,Opacity))
			draw.SimpleTextOutlined("PARTS "..math.Round(PartFrac*100).."%","JMod-Display",200,10,JMod.GoodBadColor(PartFrac, true, Opacity),TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP,3,Color(0,0,0,Opacity))
		end)
	end

	language.Add("ent_jack_gmod_eztoolbox", "EZ Toolbox")
end
