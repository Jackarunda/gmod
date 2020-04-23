--missile disperser not dispenser
--By Jackarunda

AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')

function ENT:SpawnFunction(ply, tr)

	//if not tr.Hit then return end

	local SpawnPos=tr.HitPos+tr.HitNormal*20
	local ent=ents.Create("ent_jack_nitroglycerin")
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

	self.Entity:SetModel("models/healthvial.mdl")
	self.Entity:SetMaterial("models/glyceryl_trinitrate")

	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)	
	self.Entity:SetSolid(SOLID_VPHYSICS)
	
	self.Exploded=false
	
	self.LastSpeed=0

	local phys=self.Entity:GetPhysicsObject()
	if phys:IsValid()then
		phys:Wake()
		phys:SetVelocity(Vector(0,0,0))
	end

	self:Fire("enableshadow","",0)

end

function ENT:Detonate()

	// OH SHI-
	
	if(self.Exploded)then return end
	self.Exploded=true
	
	local SelfPos=self:GetPos()
	
	self:EmitSound("BaseExplosionEffect.Sound")
	
	local expl=ents.Create("env_explosion")
	expl:SetPos(SelfPos)
	expl:SetKeyValue("iMagnitude","300");
	expl:SetKeyValue("iRadiusOverride",300)
	expl:Spawn()
	expl:Activate()
	expl:Fire("explode","",0)
	expl:Fire("kill","",0)
	
	self:Remove()
	
end

function ENT:PhysicsCollide(data, physobj)
	// Play sound on bounce
	if(data.Speed>400)then
		self:Detonate()
	elseif(data.Speed>50 and data.DeltaTime>0.2)then
		local num=math.random(1,3)
		self.Entity:EmitSound("snd_jack_glass"..num..".wav")
	end
end

function ENT:OnTakeDamage(dmginfo)

	local hitter=dmginfo:GetAttacker()

	if(dmginfo:GetDamage()>2)then
		self:SetNetworkedEntity("Owenur",dmginfo:GetAttacker())
		self:Detonate()
	end

	self.Entity:TakePhysicsDamage(dmginfo)
	
end

function ENT:Use(activator, caller)
end

function ENT:Think()
	local vel=self:GetPhysicsObject():GetVelocity()
	local sped=vel:Length()
	if((sped-self.LastSpeed)>500)then
		self:Detonate()
	else
		self.LastSpeed=sped
	end
	if(self:IsOnFire())then
		self:Detonate()
	end
	self:NextThink(CurTime()+0.01)
	return true
end

function ENT:OnRemove()
end




