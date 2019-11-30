-- Jackarunda 2019
AddCSLuaFile()
ENT.Type="anim"
ENT.Author="Jackarunda"
ENT.Category="JMod - EZ"
ENT.Information="glhfggwpezpznore"
ENT.PrintName="EZ Build Kit"
ENT.Spawnable=true
ENT.AdminSpawnable=true
---
ENT.JModPreferredCarryAngles=Angle(0,90,0)
ENT.DamageThreshold=120
ENT.JModEZstorable=true
---
local Props={
	"models/props_c17/tools_wrench01a.mdl",
	"models/props_c17/tools_pliers01a.mdl",
	"models/props_forest/circularsaw01.mdl",
	"models/props_silo/welding_torch.mdl",
	"models/props_mining/pickaxe01.mdl",
	"models/props_silo/welding_helmet.mdl",
	"models/props_forest/axe.mdl",
	"models/weapons/w_defuser.mdl",
	"models/weapons/w_defuser.mdl",
	"models/props_c17/tools_wrench01a.mdl",
	"models/props_c17/tools_pliers01a.mdl"
}
if(SERVER)then
	function ENT:SpawnFunction(ply,tr)
		local SpawnPos=tr.HitPos+tr.HitNormal*40
		local ent=ents.Create(self.ClassName)
		ent:SetAngles(Angle(0,0,0))
		ent:SetPos(SpawnPos)
		ent.Owner=ply
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
				self.Entity:EmitSound("Metal_Box.ImpactHard")
				self.Entity:EmitSound("Canister.ImpactHard")
			end
		end
	end
	function ENT:OnTakeDamage(dmginfo)
		self.Entity:TakePhysicsDamage(dmginfo)
		if(dmginfo:GetDamage()>self.DamageThreshold)then
			local Pos=self:GetPos()
			sound.Play("Metal_Box.Break",Pos)
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
		if(activator:KeyDown(IN_WALK))then
			activator:PickupObject(self)
		elseif not(activator:HasWeapon("wep_jack_gmod_ezbuildkit"))then
			activator:Give("wep_jack_gmod_ezbuildkit")
			activator:SelectWeapon("wep_jack_gmod_ezbuildkit")
			self:Remove()
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
	function ENT:Draw()
		self:DrawModel()
	end
	language.Add("ent_jack_gmod_ezbuildkit","EZ Build Kit")
end