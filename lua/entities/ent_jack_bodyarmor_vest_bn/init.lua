--armer
--By Jackarunda
AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')
function ENT:SpawnFunction(ply,tr)
	local SpawnPos=tr.HitPos+tr.HitNormal*16
	local ent=ents.Create("ent_jack_bodyarmor_vest_bn")
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
	self.Entity:SetModel("models/combine_vests/bluevest.mdl")
	self.Entity:SetMaterial("models/mat_jack_bodyarmor_bn")
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)	
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.Entity:DrawShadow(true)
	local phys=self.Entity:GetPhysicsObject()
	if phys:IsValid()then
		phys:Wake()
		phys:SetMass(10)
	end
	self.Entity:SetUseType(SIMPLE_USE)
	self.Entity:SetColor(Color(47,54,33))
end
function ENT:PhysicsCollide(data, physobj)
	if((data.Speed>80)and(data.DeltaTime>0.2))then
		self.Entity:EmitSound("Body.ImpactSoft")
	end
end
function ENT:OnTakeDamage(dmginfo)
	self.Entity:TakePhysicsDamage(dmginfo)
end
function ENT:Think()
	--wat
end
function ENT:OnRemove()
	--aw fuck you
end
function ENT:Use(activator,caller)
	if(activator:IsPlayer())then
		if((activator.EZarmor)and(#table.GetKeys(activator.EZarmor.slots)>0))then return end
		if((not(activator.JackyArmor.Vest))and(not(activator.JackyArmor.Suit)))then
			JackaBodyArmorUpdate(activator,"Vest","Ballistic Nylon",self:GetColor())
			activator:EmitSound("snd_jack_clothequip.wav",70,100)
			JackaGenericUseEffect(activator)
			self:Remove()
		end
	end
end