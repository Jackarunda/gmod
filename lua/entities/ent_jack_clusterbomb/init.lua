--mark eighty tew jenraal prrpus bawmb
--By Jackarunda

AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')

function ENT:SpawnFunction(ply, tr)

	//if not tr.Hit then return end

	local SpawnPos=tr.HitPos+tr.HitNormal*16
	local ent=ents.Create("ent_jack_clusterbomb")
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
	self:SetAngles(Angle(0,0,0))
	self.Entity:SetModel("models/Mechanics/robotics/a1.mdl")

	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)	
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.Entity:DrawShadow(true)
	
	self.Exploded=false

	local phys=self.Entity:GetPhysicsObject()
	if phys:IsValid()then
		phys:Wake()
		phys:SetMass(100)
	end
	
	self.NextUseTime=CurTime()
	self.Heat=0
	self.NoBombletTrigger=true
	
	self.TailFins=ents.Create("prop_physics")
	self.TailFins:SetModel("models/props_junk/cardboard_box001a.mdl")
	self.TailFins:SetPos(self:GetPos()-self:GetForward()*50)
	self.TailFins.AreJackyTailFins=true
	self.TailFins:Spawn()
	self.TailFins:Activate()
	self.TailFins:SetNotSolid(true)
	self.TailFins:SetNoDraw(true)
	self:DeleteOnRemove(self.TailFins)
	constraint.Weld(self.Entity,self.TailFins,0,0,0,true)
	
	//HA GARRY I FUCKING BEAT YOU AND YOUR STUPID RULES
	local Settings=physenv.GetPerformanceSettings()
	if(Settings.MaxVelocity<5000)then Settings.MaxVelocity=5000 end
	physenv.SetPerformanceSettings(Settings)
	
	if not(WireAddon==nil)then self.Inputs=Wire_CreateInputs(self,{"Detonate"}) end
end

function ENT:TriggerInput(iname,value)
	if(value==1)then
		self:Detonate()
	end
end

function ENT:Detonate()

	// OH SHI-
	
	if(self.Exploded)then return end
	self.Exploded=true
	
	local SelfPos=self:LocalToWorld(self:OBBCenter())

	local splad=EffectData()
	splad:SetOrigin(SelfPos)
	splad:SetScale(1)
	util.Effect("Explosion",splad,true,true)
	self.Entity:EmitSound("BaseExplosionEffect.Sound")
	
	for i=1,40 do
		local Dir=VectorRand()
		local Spl=ents.Create("ent_jack_bomblet")
		Spl:SetPos(SelfPos+Dir*math.Rand(1,15))
		Spl.ParentEntity=self.Entity
		Spl.NoBombletTrigger=true
		Spl:SetAngles(Dir:Angle())
		Spl:Spawn()
		Spl:Activate()
		Spl:GetPhysicsObject():SetVelocity(self:GetPhysicsObject():GetVelocity()*math.Rand(1.5,.5)+Dir*math.Rand(0,250))
		local Trail=util.SpriteTrail(Spl,0,Color(100,100,100,math.Rand(50,100)),false,2,20,.5,1/(15+1)*0.5,"trails/smoke.vmt")
		SafeRemoveEntityDelayed(Trail,math.Rand(.5,2))
	end

	self:Remove()
end

function ENT:PhysicsCollide(data, physobj)
	if((data.Speed>80)and(data.DeltaTime>0.2))then
		self.Entity:EmitSound("Canister.ImpactHard")
	end
end

function ENT:OnTakeDamage(dmginfo)
	local hitter=dmginfo:GetAttacker()
	if((dmginfo:IsExplosionDamage())and(dmginfo:GetDamage()>110))then
		self:Detonate()
	end
	self.Entity:TakePhysicsDamage(dmginfo)
end

function ENT:Use(activator,caller)
	if(activator:IsPlayer())then
		if not(self.NextUseTime<CurTime())then return end
		self.NextUseTime=CurTime()+.5
		if not(self.Armed)then
			local Num=activator:GetNetworkedInt("JackyDetGearCount")
			if(Num>0)then
				JackySimpleOrdnanceArm(self,activator,"Set: Free-Fall Time")
				self.Armed=true
			end
		else
			JackyOrdnanceDisarm(self,activator,"")
			self.Armed=false
			local Wap=activator:GetActiveWeapon()
			if(IsValid(Wap))then Wap:SendWeaponAnim(ACT_VM_DRAW) end
		end
	end
end

function ENT:Think()
	if(self.Armed)then
		local Vel=self:GetPhysicsObject():GetVelocity()
		local Speed=Vel:Length()
		if(Speed>500)then
			if(self:IsFreeFallin())then
				self.Travel=self.Travel+1
				if(self.Travel>12)then self:Detonate() return end
			else
				self.Travel=0
			end
		else
			self.Travel=0
		end
	else
		self.Travel=0
	end
	if(self:IsOnFire())then
		self.Heat=self.Heat+1
		if(self.Heat>100)then
			self:Detonate()
		end
	else
		self.Heat=self.Heat-1
	end
	self:NextThink(CurTime()+.1)
	return true
end

function ENT:IsFreeFallin()
	local SelfPos=self:LocalToWorld(self:OBBCenter())
	local TrOne=util.QuickTrace(SelfPos,Vector(0,0,100),{self})
	local TrTwo=util.QuickTrace(SelfPos,Vector(0,100,0),{self})
	local TrThree=util.QuickTrace(SelfPos,Vector(100,0,0),{self})
	local TrFour=util.QuickTrace(SelfPos,Vector(0,0,-100),{self})
	local TrFive=util.QuickTrace(SelfPos,Vector(0,-100,0),{self})
	local TrSix=util.QuickTrace(SelfPos,Vector(-100,0,0),{self})
	if not((TrOne.Hit)or(TrTwo.Hit)or(TrThree.Hit)or(TrFour.Hit)or(TrFive.Hit)or(TrSix.Hit))then return true else return false end
end

function ENT:OnRemove()
end