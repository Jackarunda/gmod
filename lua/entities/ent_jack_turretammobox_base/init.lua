--box
--By Jackarunda
AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')
local MATS={["9x19mm"]="mat_jack_ammobox_9mm",["7.62x51mm"]="mat_jack_ammobox_762",["5.56x45mm"]="mat_jack_ammobox_556",["12GAshotshell"]="mat_jack_ammobox_shot",[".338 Lapua Magnum"]="mat_jack_ammobox_338",[".22 Long Rifle"]="mat_jack_ammobox_22",["40x53mm Grenade"]="mat_jack_ammobox_40mm"}
function ENT:Initialize()
	self.Entity:SetModel("models/Items/BoxSRounds.mdl")
	self.Entity:SetMaterial("models/"..MATS[self.AmmoType])
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)	
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.Entity:DrawShadow(true)
	local phys=self.Entity:GetPhysicsObject()
	if phys:IsValid()then
		phys:Wake()
		phys:SetMass(60)
	end
	if(self.Empty)then
		phys:SetMass(15)
		self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	end
	self.Entity:SetUseType(SIMPLE_USE)
end
function ENT:PhysicsCollide(data, physobj)
	if((data.Speed>80)and(data.DeltaTime>0.2))then
		self.Entity:EmitSound("Metal_Box.ImpactHard")
		if not(self.Empty)then
			self.Entity:EmitSound("Weapon.ImpactSoft")
		end
	end
end
function ENT:OnTakeDamage(dmginfo)
	self.Entity:TakePhysicsDamage(dmginfo)
end
function ENT:Use(activator,caller)
	if not(self.Empty)then activator:PickupObject(self) end
end
function ENT:Think()
	--pfahahaha
end
function ENT:OnRemove()
	--aw fuck you
end