--box
--By Jackarunda
AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')
function ENT:SpawnFunction(ply,tr)
	local SpawnPos=tr.HitPos+tr.HitNormal*16
	local ent=ents.Create("ent_jack_aidwater")
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
	self.Entity:SetModel("models/props/cs_office/Cardboard_box03.mdl")
	self.Entity:SetMaterial("models/mat_jack_aidwater")
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
		--self.Entity:EmitSound("DryWall.ImpactHard")
		self.Entity:EmitSound("Cardboard.ImpactHard")
		self.Entity:EmitSound("Weapon.ImpactSoft")
	end
end
function ENT:OnTakeDamage(dmginfo)
	self.Entity:TakePhysicsDamage(dmginfo)
end
function ENT:Use(activator,caller)
	if(activator:IsPlayer())then
		if(self.NextUseTime<CurTime())then
			self.NextUseTime=CurTime()+10
			self:GetEatenBy(activator)
			JackaGenericUseEffect(activator)
			timer.Simple(.3,function()
				if(IsValid(self))then
					self:GetEatenBy(activator)
				end
			end)
			timer.Simple(.6,function()
				if(IsValid(self))then
					self:GetEatenBy(activator)
				end
			end)
		end
	end
end
function ENT:GetEatenBy(ply)
	ply:EmitSound("snd_jack_drink"..tostring(math.random(1,2))..".wav",75,math.Rand(90,110))
	ply:ViewPunch(Angle(1,0,0))
	if(ply:Health()<100)then
		ply:SetHealth(ply:Health()+1)
	end
	self.Remaining=self.Remaining-1
	if(self.Remaining<=0)then self:Remove() end
end
function ENT:Think()
	--pfahahaha
end
function ENT:OnRemove()
	--aw fuck you
end