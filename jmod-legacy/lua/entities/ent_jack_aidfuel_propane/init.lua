--box
--By Jackarunda
AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')
function ENT:SpawnFunction(ply,tr)
	local SpawnPos=tr.HitPos+tr.HitNormal*16
	local ent=ents.Create("ent_jack_aidfuel_propane")
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
	self.Entity:SetModel("models/props_junk/PropaneCanister001a.mdl")
	self.Entity:SetColor(Color(200,200,200))
	self.Entity:SetMaterial("models/mat_jack_aidfuel_propane")
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)	
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.Entity:DrawShadow(true)
	local phys=self.Entity:GetPhysicsObject()
	if phys:IsValid()then
		phys:Wake()
		phys:SetMass(35)
	end
	self.StructuralIntegrity=100
	self.Asploded=false
end
function ENT:PhysicsCollide(data, physobj)
	if((data.Speed>80)and(data.DeltaTime>0.2))then
		self.Entity:EmitSound("Canister.ImpactHard")
		self.Entity:EmitSound("Wade.StepRight")
		self.Entity:EmitSound("Wade.StepLeft")
	end
end
function ENT:OnTakeDamage(dmginfo)
	self.Entity:TakePhysicsDamage(dmginfo)
	self.StructuralIntegrity=self.StructuralIntegrity-dmginfo:GetDamage()
	if(self.StructuralIntegrity<=0)then
		self:Asplode()
	end
end
function ENT:Asplode()
	if(self.Asploded)then return end
	self.Asploded=true
	local SelfPos=self:LocalToWorld(self:OBBCenter())
	JMod_Sploom(self.Entity,SelfPos,110)
	self:Remove()
end
function ENT:Use(activator,caller)
	--nope
end
function ENT:Think()
	--pfahahaha
end
function ENT:OnRemove()
	--aw fuck you
end