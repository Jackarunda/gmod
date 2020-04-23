--box
--By Jackarunda
AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')
function ENT:Initialize()
	self.Entity:SetModel("models/props_junk/cardboard_box004a.mdl")
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)	
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.Entity:DrawShadow(true)
	local phys=self.Entity:GetPhysicsObject()
	if phys:IsValid()then
		phys:Wake()
		phys:SetMass(40)
	end
end
function ENT:PhysicsCollide(data, physobj)
	if((data.Speed>80)and(data.DeltaTime>0.2))then
		self.Entity:EmitSound("Weapon.ImpactSoft")
	end
end
function ENT:OnTakeDamage(dmginfo)
	self.Entity:TakePhysicsDamage(dmginfo)
end
function ENT:Use(activator,caller)
	--nothin, bitch
end
function ENT:Think()
	--pfahahaha
end
function ENT:OnRemove()
	--aw fuck you
end
function ENT:StartTouch(toucher)
	if(toucher:IsPlayer())then
		toucher:GiveAmmo(10,"SniperRound")
		toucher:GiveAmmo(10,"SniperPenetratedRound")
		toucher:GiveAmmo(10,"Thumper")
		toucher:GiveAmmo(10,"Gravity")
		toucher:GiveAmmo(10,"Battery")
		toucher:GiveAmmo(10,"GaussEnergy")
		toucher:GiveAmmo(10,"CombineCannon")
		toucher:GiveAmmo(10,"AirboatGun")
		toucher:GiveAmmo(10,"StriderMinigun")
		toucher:GiveAmmo(10,"HelicopterGun")
		self:Remove()
	end
end