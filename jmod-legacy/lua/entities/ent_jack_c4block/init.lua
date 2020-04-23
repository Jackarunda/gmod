--C4 Block
--By Jackarunda

AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')

function ENT:SpawnFunction(ply, tr)

	//if not tr.Hit then return end

	local SpawnPos=tr.HitPos+tr.HitNormal*16
	local ent=ents.Create("ent_jack_c4block")
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

	self.Entity:SetModel("models/props_misc/tobacco_box-1.mdl")
	self.Entity:SetMaterial("models/entities/mat_jack_c4")

	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)	
	self.Entity:SetSolid(SOLID_VPHYSICS)
	
	self.Exploded=false
	
	self.IsJackyC4Explosive=true

	local phys=self.Entity:GetPhysicsObject()
	if phys:IsValid()then
		phys:Wake()
		phys:SetMass(10)
		phys:SetMaterial("gmod_silent")
	end
	
	self.Entity:SetUseType(SIMPLE_USE)
	
	self:Fire("enableshadow","",0)

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
	
	local SympatheticDetonationRadius=400
	
	local BlocksIncludedInExplosion={self.Entity}
	for i=0,10 do
		for key,found in pairs(ents.FindInSphere(SelfPos,SympatheticDetonationRadius))do
			if(found.IsJackyC4Explosive)then
				if not(found==self.Entity)then
					if not(table.HasValue(BlocksIncludedInExplosion,found))then
						if(self:LoSTo(found))then
							table.ForceInsert(BlocksIncludedInExplosion,found)
							found.IsInvolvedInAnExplosion=true
							SympatheticDetonationRadius=SympatheticDetonationRadius+150
						end
					end
				end
			end
		end
	end
	
	local ExplosionPower=table.Count(BlocksIncludedInExplosion)
	
	local AvgPos=Vector(0,0,0)
	for key,thing in pairs(BlocksIncludedInExplosion)do
		AvgPos=AvgPos+thing:GetPos()+Vector(0,0,1)
		SafeRemoveEntity(thing)
	end
	AvgPos=AvgPos/ExplosionPower --average the position of all the blocks included
	local Pos=AvgPos
	
	self.Entity:EmitSound("weapons/explode4.wav",130,150)

	self:EmitSound("snd_jack_c4splodeclose.wav",100,100)
	self:EmitSound("snd_jack_c4splodefar.wav",130,100)
	if(ExplosionPower>4)then
		self:EmitSound("snd_jack_c4splodeclose.wav",100,95)
	end
	if(ExplosionPower>8)then
		self:EmitSound("snd_jack_c4splodeclose.wav",100,90)
		self:EmitSound("snd_jack_c4splodeclose.wav",100,90)
	end
	if(ExplosionPower>12)then
		self:EmitSound("snd_jack_c4splodeclose.wav",100,85)
		self:EmitSound("snd_jack_c4splodeclose.wav",100,85)
	end
	if(ExplosionPower>18)then
		self:EmitSound("snd_jack_c4splodeclose.wav",100,80)
		self:EmitSound("snd_jack_c4splodeclose.wav",100,80)
		self:EmitSound("snd_jack_c4splodeclose.wav",100,80)
	end
	if(ExplosionPower>25)then
		self:EmitSound("snd_jack_c4splodeclose.wav",100,75)
		self:EmitSound("snd_jack_c4splodeclose.wav",100,75)
		self:EmitSound("snd_jack_c4splodeclose.wav",100,75)
	end

	---[[
	local splad=EffectData()
	splad:SetOrigin(Pos)
	splad:SetScale(4+ExplosionPower*1.1)
	util.Effect("eff_jack_plastisplosion",splad,true,true)--]]
	
	local BlastRadius=400+ExplosionPower*220
	
	local Explosion=ents.Create("ent_jack_plastisplosion")
	Explosion:SetPos(Pos)
	Explosion.BasePower=ExplosionPower*160
	Explosion.BlastRadius=BlastRadius
	Explosion.ParentEntity=self
	Explosion:SetOwner(self:GetOwner())
	Explosion:Spawn()
	Explosion:Activate()

	self.Entity:Remove()
end

function ENT:PhysicsCollide(data, physobj)
	// Play sound on bounce
	if(data.Speed>80 and data.DeltaTime>0.2)then
		self.Entity:EmitSound("snd_jack_claythunk.wav")
	end
end

function ENT:OnTakeDamage(dmginfo)

	local hitter=dmginfo:GetAttacker()
	if((dmginfo:IsExplosionDamage())and(dmginfo:GetDamage()>60))then
		if not(self.IsInvolvedInAnExplosion)then
			self:Detonate()
		end
	end

	self.Entity:TakePhysicsDamage(dmginfo)
	
end

function ENT:Use(activator,caller)
	if(activator:IsPlayer())then
		if(not(activator:HasWeapon("wep_jack_detpack")))then
			activator:Give("wep_jack_detpack")
			activator:SelectWeapon("wep_jack_detpack")
			JackyOrdnanceDisarm(self,activator,"Remote")
			self:Remove()
		end
	end
end

function ENT:Think()

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