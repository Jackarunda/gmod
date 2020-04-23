--mark eighty tew jenraal prrpus bawmb
--By Jackarunda

AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')

function ENT:SpawnFunction(ply, tr)

	//if not tr.Hit then return end

	local SpawnPos=tr.HitPos+tr.HitNormal*16
	local ent=ents.Create("ent_jack_apersbomb")
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

	sound.Play("weapons/explode4.wav",SelfPos,100,150)
	sound.Play("snd_jack_c4splodeclose.wav",SelfPos,110,110)
	self.Entity:EmitSound("BaseExplosionEffect.Sound")

	local Owner=self.Owner
	self:Remove()

	local Blamo=ents.Create("ent_jack_smallshrapnelsplosion")
	Blamo:SetPos(SelfPos+Vector(0,0,5))
	Blamo.Owner=Owner
	Blamo:Spawn()
	Blamo:Activate()
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
				JackySimpleOrdnanceArm(self,activator,"Set: Proximity")
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
	local SelfPos=self:GetPos()
	if(self:IsOnFire())then
		self.Heat=self.Heat+1
		if(self.Heat>100)then
			self:Detonate()
		end
	else
		self.Heat=self.Heat-1
	end
	if(self.Armed)then
		local Vel=self:GetPhysicsObject():GetVelocity()
		local Dir=Vel:GetNormalized()
		local Speed=Vel:Length()
		if(Speed>1000)then
			local TrDat={
				start=SelfPos,
				endpos=SelfPos+Dir*500,
				filter={self},
				mask=-1
			}
			local Tr=util.TraceLine(TrDat)
			if(Tr.Hit)then
				local Phys=Tr.Entity:GetPhysicsObject()
				if(IsValid(Phys))then
					local Vayle=Phys:GetVelocity()
					local Diff=(Vayle-Vel):Length()
					if(Diff>100)then
						self:Detonate()
					end
				else
					self:Detonate()
				end
			end
		end
	end
end

function ENT:OnRemove()
end