-- Jackarunda 2021
AddCSLuaFile()
ENT.Type = "anim"
ENT.Author = "Jackarunda"
ENT.Category = "JMod - EZ Misc."
ENT.Information = "glhfggwpezpznore"
ENT.PrintName = "EZ Medkit"
ENT.NoSitAllowed = true
ENT.Spawnable = true
ENT.AdminSpawnable = true
---
ENT.JModPreferredCarryAngles = Angle(0, -180, 0)
ENT.DamageThreshold = 120
ENT.JModEZstorable = true

---
local Props = {
	--"models/jmod/items/healthkit.mdl", 
	"models/healthvial.mdl", 
	--"models/jmod/items/medjit_medium.mdl", 
	"models/jmod/items/medjit_small.mdl", 
	--"models/weapons/w_models/w_syringe.mdl", 
	--"models/weapons/w_models/w_syringe_proj.mdl", 
	"models/weapons/w_models/w_bonesaw.mdl", 
	"models/bandages.mdl"
}

function ENT:SetupDataTables() 
	self:NetworkVar("Float", 0, "Supplies")
end

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
		self:SetModel("models/weapons/w_models/w_tooljox.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:DrawShadow(true)
		self:SetUseType(SIMPLE_USE)

		---
		local Phys = self:GetPhysicsObject()
		timer.Simple(.01, function()
			if not(IsValid(Phys)) then return end
			Phys:SetMass(50)
			Phys:Wake()
		end)
		self.MaxSupplies = 100
		self:SetSupplies(self.MaxSupplies)
	end

	function ENT:PhysicsCollide(data, physobj)
		if data.DeltaTime > 0.2 then
			if data.Speed > 100 then
				self:EmitSound("Plastic_Box.ImpactHard")
				self:EmitSound("Weapon.ImpactSoft")
			end
		end
	end

	function ENT:OnTakeDamage(dmginfo)
		self:TakePhysicsDamage(dmginfo)

		if dmginfo:GetDamage() > self.DamageThreshold then
			local Pos = self:GetPos()
			sound.Play("Plastic_Box.Break", Pos)

			for k, mdl in pairs(Props) do
				if util.IsValidModel(mdl) then 
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
			end

			self:Remove()
		end
	end

	function ENT:Use(activator)
		if JMod.IsAltUsing(activator) then
			activator:PickupObject(self)
		elseif not activator:HasWeapon("wep_jack_gmod_ezmedkit") then
			activator:Give("wep_jack_gmod_ezmedkit")
			activator:SelectWeapon("wep_jack_gmod_ezmedkit")

			timer.Simple(0, function()
				local Wep = activator:GetWeapon("wep_jack_gmod_ezmedkit")

				if IsValid(Wep) then
					Wep:SetSupplies(self:GetSupplies())
				end

				self:Remove()
			end)
		else
			activator:PickupObject(self)
		end
	end

	function ENT:Think()
	end

	--
	function ENT:OnRemove()
	end
	--aw fuck you
elseif CLIENT then
	function ENT:Initialize()
		self.Mdl = ClientsideModel("models/jmod/items/medjit_large.mdl")
		self.Mdl:SetPos(self:GetPos())
		self.Mdl:SetParent(self)
		self.Mdl:SetNoDraw(true)
		self.MaxSupplies = 100
	end

	function ENT:Draw()
		local Ang = self:GetAngles()
		Ang:RotateAroundAxis(self:GetUp(), 90)
		self.Mdl:SetRenderOrigin(self:GetPos() - self:GetUp() * 4)
		self.Mdl:SetRenderAngles(Ang)
		self.Mdl:DrawModel()
		local Opacity = math.random(50, 200)
		local SupplyFrac = self:GetSupplies()/self.MaxSupplies
		JMod.HoloGraphicDisplay(self, Vector(0, 6, 17), Angle(-90, 55, 90), .05, 300, function()
			draw.SimpleTextOutlined("SUPPLIES "..math.Round(SupplyFrac*100).."%","JMod-Display",0,-5,JMod.GoodBadColor(SupplyFrac, true, Opacity),TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP,3,Color(0,0,0,Opacity))
		end)
	end

	language.Add("ent_jack_gmod_ezmedkit", "EZ Medkit")
end
