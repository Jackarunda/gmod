--box
--By Jackarunda
AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')
ENT.HasBattery=true
ENT.BatteryCharge=3000
ENT.BatteryMaxCharge=3000
function ENT:ExternalCharge(amt)
	self.BatteryCharge=self.BatteryMaxCharge
	self.Dead=false
	self:SetCollisionGroup(COLLISION_GROUP_NONE)
end
function ENT:SpawnFunction(ply,tr)
	local SpawnPos=tr.HitPos+tr.HitNormal*16
	local ent=ents.Create("ent_jack_turretbattery")
	ent:SetPos(SpawnPos)
	ent:SetNetworkedEntity("Owenur",ply)
	ent:Spawn()
	ent:Activate()
	local effectdata=EffectData()
	effectdata:SetEntity(ent)
	util.Effect("propspawn",effectdata)
	return ent
end
function ENT:Initialize()
	self.Entity:SetModel("models/Items/car_battery01.mdl")
	self.Entity:SetMaterial("models/mat_jack_turretbattery")
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)	
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.Entity:DrawShadow(true)
	local phys=self.Entity:GetPhysicsObject()
	if phys:IsValid()then
		phys:Wake()
		phys:SetMass(60)
	end
	if(self.Dead)then
		self.BatteryCharge=0
		self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
		timer.Simple(60,function()
			if(IsValid(self))then
				if(self.Dead)then
					self:Remove()
				end
			end
		end)
	end
	self.Entity:SetUseType(SIMPLE_USE)
end
function ENT:PhysicsCollide(data, physobj)
	if((data.Speed>80)and(data.DeltaTime>0.2))then
		self.Entity:EmitSound("DryWall.ImpactHard")
	end
end
function ENT:OnTakeDamage(dmginfo)
	self.Entity:TakePhysicsDamage(dmginfo)
end
function ENT:Use(activator,caller)
	activator:PickupObject(self)
end
function ENT:Think()
	--pfahahaha
end
function ENT:OnRemove()
	--aw fuck you
end