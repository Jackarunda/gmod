-- Jackarunda 2019
AddCSLuaFile()
ENT.Type="anim"
ENT.Author="Jackarunda"
ENT.Category="JMod - EZ Misc."
ENT.Information="glhfggwpezpznore"
ENT.PrintName="EZ Medkit"
ENT.NoSitAllowed=true
ENT.Spawnable=true
ENT.AdminSpawnable=true
---
ENT.JModPreferredCarryAngles=Angle(0,0,0)
ENT.DamageThreshold=120
ENT.JModEZstorable=true
---
local Props={
	"models/items/healthkit.mdl",
	"models/healthvial.mdl",
	"models/items/medjit_medium.mdl",
	"models/items/medjit_small.mdl",
	"models/weapons/w_models/w_syringe.mdl",
	"models/weapons/w_models/w_syringe_proj.mdl",
	"models/weapons/w_models/w_bonesaw.mdl",
	"models/bandages.mdl"
}
if(SERVER)then
	function ENT:SpawnFunction(ply,tr)
		local SpawnPos=tr.HitPos+tr.HitNormal*40
		local ent=ents.Create(self.ClassName)
		ent:SetAngles(Angle(0,0,0))
		ent:SetPos(SpawnPos)
		JMod_Owner(ent,ply)
		ent:Spawn()
		ent:Activate()
		--local effectdata=EffectData()
		--effectdata:SetEntity(ent)
		--util.Effect("propspawn",effectdata)
		return ent
	end
	function ENT:Initialize()
		self.Entity:SetModel("models/weapons/w_models/w_tooljox.mdl")
		self.Entity:PhysicsInit(SOLID_VPHYSICS)
		self.Entity:SetMoveType(MOVETYPE_VPHYSICS)	
		self.Entity:SetSolid(SOLID_VPHYSICS)
		self.Entity:DrawShadow(true)
		self.Entity:SetUseType(SIMPLE_USE)
		---
		timer.Simple(.01,function()
			self:GetPhysicsObject():SetMass(50)
			self:GetPhysicsObject():Wake()
		end)
	end
	function ENT:PhysicsCollide(data,physobj)
		if(data.DeltaTime>0.2)then
			if(data.Speed>100)then
				self.Entity:EmitSound("Plastic_Box.ImpactHard")
				self.Entity:EmitSound("Weapon.ImpactSoft")
			end
		end
	end
	function ENT:OnTakeDamage(dmginfo)
		self.Entity:TakePhysicsDamage(dmginfo)
		if(dmginfo:GetDamage()>self.DamageThreshold)then
			local Pos=self:GetPos()
			sound.Play("Plastic_Box.Break",Pos)
			for k,mdl in pairs(Props)do
				local Item=ents.Create("prop_physics")
				Item:SetModel(mdl)
				Item:SetPos(Pos+VectorRand()*5+Vector(0,0,10))
				Item:SetAngles(VectorRand():Angle())
				Item:Spawn()
				Item:Activate()
				Item:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
				local Phys=Item:GetPhysicsObject()
				if(IsValid(Phys))then
					Phys:SetVelocity(self:GetVelocity()/2+Vector(0,0,200)+VectorRand()*math.Rand(10,600))
					Phys:AddAngleVelocity(VectorRand()*math.Rand(10,3000))
				end
				SafeRemoveEntityDelayed(Item,math.random(10,20))
			end
			self:Remove()
		end
	end
	function ENT:Use(activator)
		if(activator:KeyDown(JMOD_CONFIG.AltFunctionKey))then
			activator:PickupObject(self)
		elseif not(activator:HasWeapon("wep_jack_gmod_ezmedkit"))then
			activator:Give("wep_jack_gmod_ezmedkit")
			activator:SelectWeapon("wep_jack_gmod_ezmedkit")
			timer.Simple(0,function()
				local Wep=activator:GetWeapon("wep_jack_gmod_ezmedkit")
				if(IsValid(Wep))then
					Wep:SetSupplies(self.Supplies or 50)
				end
				self:Remove()
			end)
		else
			activator:PickupObject(self)
		end
	end
	function ENT:Think()
		--
	end
	function ENT:OnRemove()
		--aw fuck you
	end
elseif(CLIENT)then
	function ENT:Initialize()
		self.Mdl=ClientsideModel("models/items/medjit_large.mdl")
		self.Mdl:SetPos(self:GetPos())
		self.Mdl:SetParent(self)
		self.Mdl:SetNoDraw(true)
	end
	function ENT:Draw()
		local Ang=self:GetAngles()
		Ang:RotateAroundAxis(self:GetUp(),90)
		self.Mdl:SetRenderOrigin(self:GetPos()-self:GetUp()*4)
		self.Mdl:SetRenderAngles(Ang)
		self.Mdl:DrawModel()
	end
	language.Add("ent_jack_gmod_ezmedkit","EZ Medkit")
end