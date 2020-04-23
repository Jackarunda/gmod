--box
--By Jackarunda
AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')
function ENT:Initialize()
	self.Entity:SetModel("models/jrleitiss/riotshield/shield.mdl")
	self.Entity:SetColor(Color(100,100,100))
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.Entity:DrawShadow(true)
	local phys=self.Entity:GetPhysicsObject()
	if phys:IsValid()then
		phys:Wake()
		phys:SetMass(50)
		phys:SetMaterial("metal")
	end
	self.Entity:SetUseType(SIMPLE_USE)
	self.Held=false
	self.NextUseTime=0
	if not(self.Reinforcement)then
		self.Second=ents.Create("ent_jack_ballistic_shield")
		self.Second.Reinforcement=true
		self.Second:SetPos(self:GetPos()+self:GetForward()*20)
		self.Second:SetAngles(self:GetAngles())
		self.Second:Spawn()
		self.Second:Activate()
		self.Second:SetParent(self)
		self.Second:SetNoDraw(true)
		self.Second:GetPhysicsObject():SetMass(300)
		self.Second:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
		self.Second.ParentShield=self
		self.Third=ents.Create("ent_jack_ballistic_shield")
		self.Third.Reinforcement=true
		self.Third:SetPos(self:GetPos()+self:GetForward()*10)
		self.Third:SetAngles(self:GetAngles())
		self.Third:Spawn()
		self.Third:Activate()
		self.Third:SetParent(self)
		self.Third:SetNoDraw(true)
		self.Third:GetPhysicsObject():SetMass(300)
		self.Third:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
		self.Third.ParentShield=self
	end
end
function ENT:PhysicsCollide(data,physobj)
	if((data.Speed>80)and(data.DeltaTime>0.2))then
		self.Entity:EmitSound("Drywall.ImpactHard")
	end
end
function ENT:OnTakeDamage(dmginfo)
	dmginfo:SetDamageForce(dmginfo:GetDamageForce()/10)
	self.Entity:TakePhysicsDamage(dmginfo)
	if((dmginfo:IsDamageType(DMG_BULLET))or(dmginfo:IsDamageType(DMG_BUCKSHOT)))then
		local SelfPos=self:GetPos()
		sound.Play("Drywall.ImpactHard",SelfPos,75,100)
		sound.Play("Plastic_Barrel.BulletImpact",SelfPos,75,100)
		sound.Play("Plastic_Box.BulletImpact",SelfPos,75,100)
		sound.Play("Concrete.BulletImpact",SelfPos,75,100)
		if(self.Reinforcement)then
			if(math.random(1,3)==2)then
				self.Entity:EmitSound("snd_jack_ricochet_"..tostring(math.random(1,2))..".wav",75,math.Rand(90,110))
				local Bellit={
					Attacker=dmginfo:GetAttacker(),
					Damage=1,
					Force=5,
					Num=1,
					Tracer=0,
					Dir=(VectorRand()+self:GetForward()):GetNormalized(),
					Spread=Vector(0,0,0),
					Src=dmginfo:GetDamagePosition()+self:GetForward()
				}
				self:FireBullets(Bellit)
			end
		end
	end
end
function ENT:Use(activator,caller)
	if(self.Reinforcement)then return end
	if(activator:IsPlayer())then
		if(self.NextUseTime<CurTime())then
			self.NextUseTime=CurTime()+1
			if not(self:IsPlayerHolding())then
				local Vec=activator:GetAimVector()
				local Ang=Vec:Angle()
				self:SetPos(activator:GetShootPos()+Vec*10)
				self:SetAngles(Ang)
				activator:PickupObject(self)
			end
		end
	end
end
function ENT:Think()
	if(self:IsOnFire())then self:Extinguish() end
	self:NextThink(CurTime()+.5)
	return true
end
function ENT:OnRemove()
	--aw fuck you
end