--C4 Block
--By Jackarunda

AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')

function ENT:SpawnFunction(ply, tr)

	//if not tr.Hit then return end

	local SpawnPos=tr.HitPos+tr.HitNormal*6
	local ent=ents.Create("ent_jack_powderbottle")
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
	self.Entity:SetModel("models/props_lab/jar01b.mdl")
	self.Entity:SetMaterial("models/entities/mat_jack_powderbottle")

	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)	
	self.Entity:SetSolid(SOLID_VPHYSICS)
	
	self.Exploded=false
	self.IsJackyPowderBottle=true
	self.FuzeLength=900
	self.FuzeLit=false
	self.NextUseTime=CurTime()

	local phys=self.Entity:GetPhysicsObject()
	if phys:IsValid()then
		phys:Wake()
		phys:SetMass(30)
		phys:SetMaterial("plastic")
	end
	
	self.Entity:SetUseType(SIMPLE_USE)
	self:Fire("enableshadow","",0)
	
	//HA GARRY I FUCKING BEAT YOU AND YOUR STUPID RULES
	local Settings=physenv.GetPerformanceSettings()
	if(Settings.MaxVelocity<17500)then Settings.MaxVelocity=17500 end
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
	
	if(self.IsInvolvedInAnExplosion)then return end
	
	local SelfPos=self:GetPos()
	
	local SympatheticDetonationRadius=100
	
	local BarrelsIncludedInExplosion={self.Entity}
	for i=0,10 do
		for key,found in pairs(ents.FindInSphere(SelfPos,SympatheticDetonationRadius))do
			if(found.IsJackyPowderBottle)then
				if not(found==self.Entity)then
					if not(table.HasValue(BarrelsIncludedInExplosion,found))then
						if(self:LoSTo(found))then
							table.ForceInsert(BarrelsIncludedInExplosion,found)
							found.IsInvolvedInAnExplosion=true
							SympatheticDetonationRadius=SympatheticDetonationRadius+50
						end
					end
				end
			end
		end
	end
	
	local ExplosionPower=table.Count(BarrelsIncludedInExplosion)
	
	local AvgPos=Vector(0,0,0)
	local AvgVel=Vector(0,0,0)
	for key,thing in pairs(BarrelsIncludedInExplosion)do
		AvgPos=AvgPos+thing:GetPos()+Vector(0,0,1)
		AvgVel=AvgVel+thing:GetPhysicsObject():GetVelocity()
		SafeRemoveEntity(thing)
	end
	AvgPos=AvgPos/ExplosionPower --average the position of all the Barrels included
	AvgVel=AvgVel/ExplosionPower --average velocity of all the Barrels included
	local Pos=AvgPos
	
	self.Entity:EmitSound("weapons/explode4.wav",130,110)

	self:EmitSound("snd_jack_c4splodeclose.wav",100,90)
	self:EmitSound("snd_jack_c4splodefar.wav",130,90)
	if(ExplosionPower>4)then
		self:EmitSound("snd_jack_c4splodeclose.wav",100,100)
	end
	if(ExplosionPower>8)then
		self:EmitSound("snd_jack_c4splodeclose.wav",100,95)
		self:EmitSound("snd_jack_c4splodeclose.wav",100,95)
	end
	if(ExplosionPower>12)then
		self:EmitSound("snd_jack_c4splodeclose.wav",100,90)
		self:EmitSound("snd_jack_c4splodeclose.wav",100,90)
	end
	if(ExplosionPower>18)then
		self:EmitSound("snd_jack_c4splodeclose.wav",100,85)
		self:EmitSound("snd_jack_c4splodeclose.wav",100,85)
		self:EmitSound("snd_jack_c4splodeclose.wav",100,85)
	end
	if(ExplosionPower>25)then
		self:EmitSound("snd_jack_c4splodeclose.wav",100,80)
		self:EmitSound("snd_jack_c4splodeclose.wav",100,80)
		self:EmitSound("snd_jack_c4splodeclose.wav",100,80)
	end
	
	local BlastRadius=100+ExplosionPower*50
	
	local Explosion=ents.Create("ent_jack_powdersplosion")
	Explosion:SetPos(Pos)
	Explosion.BasePower=ExplosionPower*25
	Explosion.BlastRadius=BlastRadius
	Explosion.ParentEntity=self
	Explosion.Velocity=AvgVel
	Explosion.Small=true
	Explosion:Spawn()
	Explosion:Activate()

	self.Entity:Remove()
end

function ENT:PhysicsCollide(data, physobj)
	// Play sound on bounce
	if(data.Speed>80 and data.DeltaTime>0.2)then
		self.Entity:EmitSound("Plastic_Box.ImpactSoft")
		if(data.Speed>400)then
			self.Entity:EmitSound("Plastic_Box.ImpactHard")
		end
	end
end

function ENT:OnTakeDamage(dmginfo)
	local hitter=dmginfo:GetAttacker()
	if((dmginfo:IsExplosionDamage())and(dmginfo:GetDamage()>40))then
		if not(self.IsInvolvedInAnExplosion)then
			self:Detonate()
		end
	end
	self.Entity:TakePhysicsDamage(dmginfo)
end

function ENT:Use(activator)
	if(activator:IsPlayer())then
		if not(self.NextUseTime<CurTime())then return end
		self.NextFuzeTime=CurTime()+.5
		if not(self.FuzeLit)then
			local Count=activator:GetNetworkedInt("JackyDetGearCount")
			if(Count>0)then
				JackySimpleOrdnanceArm(self,activator,"Fuze Inserted")
				self.FuzeLit=true
			end
		else
			if(math.random(1,3)==2)then self.FuzeLit=false end
		end
	end
end

function ENT:Think()
	if(self:IsOnFire())then
		if not(self.FuzeLit)then
			self.FuzeLit=true
			self:Extinguish()
		end
	end
	if(self:WaterLevel()>0)then
		self:Extinguish()
		self.FuzeLit=false
	end
	if(self.FuzeLit)then
		self.FuzeLength=self.FuzeLength-5
		
		local Fsh=EffectData()
		Fsh:SetOrigin(self:GetPos()+self:GetUp()*5)
		Fsh:SetScale(.8)
		Fsh:SetNormal(self:GetUp())
		util.Effect("eff_jack_fuzeburn",Fsh,true,true)
		
		self.Entity:EmitSound("snd_jack_sss.wav",60,math.Rand(90,110))
		
		if(self.FuzeLength<=0)then
			self:Detonate()
		end
	end
	self:NextThink(CurTime()+0.05)
	return true
end

function ENT:LoSTo(entity)
	local TraceData={}
	TraceData.start=self:LocalToWorld(self:OBBCenter())+Vector(0,0,10)
	TraceData.endpos=entity:LocalToWorld(entity:OBBCenter())+Vector(0,0,10)
	TraceData.filter={self.Entity,entity}
	local Trace=util.TraceLine(TraceData)
	if not(Trace.StartSolid)then
		if not(Trace.Hit)then
			return true
		else
			return false
		end
	else --FUCK
		local TraceData={}
		TraceData.start=self:LocalToWorld(self:OBBCenter())
		TraceData.endpos=entity:LocalToWorld(entity:OBBCenter())
		TraceData.filter={self.Entity,entity}
		local Trace=util.TraceLine(TraceData)
		if not(Trace.Hit)then
			return true
		else
			return false
		end
	end
end

function ENT:OnRemove()
end

function ENT:Touch(ent)
	if(ent:IsOnFire())then
		if not(self.FuzeLit)then
			self.FuzeLit=true
		end
	end
end