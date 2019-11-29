--box
--By Jackarunda
AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')
function ENT:SpawnFunction(ply,tr)
	local SpawnPos=tr.HitPos+tr.HitNormal*16
	local ent=ents.Create("ent_jack_suit_eod")
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
	self.Entity:SetModel("models/props_junk/cardboard_box003a.mdl")
	self.Entity:SetColor(Color(171,184,150))
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)	
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.Entity:DrawShadow(true)
	local phys=self.Entity:GetPhysicsObject()
	if phys:IsValid()then
		phys:Wake()
		phys:SetMass(45)
	end
	self.Entity:SetUseType(SIMPLE_USE)
	self.Remaining=50
	self.NextUseTime=0
end
function ENT:PhysicsCollide(data, physobj)
	if((data.Speed>80)and(data.DeltaTime>0.2))then
		self.Entity:EmitSound("Body.ImpactSoft")
	end
end
function ENT:OnTakeDamage(dmginfo)
	self.Entity:TakePhysicsDamage(dmginfo)
end
function ENT:Use(activator,caller)
	if(activator:IsPlayer())then
		if not((activator.JackyArmor.Vest)or(activator.JackyArmor.Helmet)or(activator.JackyArmor.Suit))then
			JackaBodyArmorUpdate(activator,"Suit","EOD",self:GetColor())
			activator:EmitSound("snd_jack_clothequip.wav",70,80)
			JackaGenericUseEffect(activator)
			self:Remove()
		end
	end
end
function ENT:Think()
	--self:SetColor(Color(math.random(0,255),math.random(0,255),math.random(0,255)))
end
function ENT:OnRemove()
	--aw fuck you
end