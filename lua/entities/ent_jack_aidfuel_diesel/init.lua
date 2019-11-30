--box
--By Jackarunda
AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')
function ENT:SpawnFunction(ply,tr)
	local SpawnPos=tr.HitPos+tr.HitNormal*16
	local ent=ents.Create("ent_jack_aidfuel_diesel")
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
	self.Entity:SetModel("models/props_lab/harddrive02.mdl")
	self.Entity:SetColor(Color(50,50,50))
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)	
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.Entity:DrawShadow(true)
	local phys=self.Entity:GetPhysicsObject()
	if phys:IsValid()then
		phys:Wake()
		phys:SetMass(35)
	end
	self.Burning=false
	self.FuelLeft=100
	self.Entity:SetUseType(SIMPLE_USE)
end
function ENT:PhysicsCollide(data, physobj)
	if((data.Speed>80)and(data.DeltaTime>0.2))then
		if(self.FuelLeft>0)then
			self.Entity:EmitSound("Wade.StepRight")
			self.Entity:EmitSound("Wade.StepLeft")
		end
		self.Entity:EmitSound("Metal_Box.ImpactHard")
	end
end
function ENT:OnTakeDamage(dmginfo)
	self.Entity:TakePhysicsDamage(dmginfo)
end
function ENT:Use(activator,caller)
	if(self.FuelLeft<=0)then return end
	JackaGenericUseEffect(activator)
	if(self.Fougassed)then
		self.Fougassed=false
		self:EmitSound("snd_jack_pinpush.wav")
		self.Fougasstivator=nil
		self:SetDTBool(0,false)
	else
		local Foug=self:FindFougasseKit()
		if(IsValid(Foug))then
			self.Fougassed=true
			self:SetDTBool(0,true)
			self.Fougasstivator=activator
			Foug:NotifySetup(activator)
			Foug:Remove()
			self:EmitSound("snd_jack_pinpull.wav")
		else
			if not(self.Burning)then
				self:BeginBurnin()
			else
				self:StahpBurnin()
			end
		end
	end
end
function ENT:FindFougasseKit()
	for key,thing in pairs(ents.FindInSphere(self:GetPos(),75))do
		if(thing:GetClass()=="ent_jack_fougassekit")then
			return thing
		end
	end
	return nil
end
function ENT:Fougassplode()
	if(self.Asploded)then return end
	self.Asploded=true
	local SelfPos=self:LocalToWorld(self:OBBCenter())
	local Poof=EffectData()
	Poof:SetOrigin(SelfPos)
	Poof:SetScale(4)
	util.Effect("eff_jack_fougasseburst",Poof,true,true)
	ParticleEffect("pcf_jack_airsplode_small",SelfPos,vector_up:Angle())
	sound.Play("snd_jack_firebomb.wav",SelfPos,85,110)
	if(self:WaterLevel()>0)then self:Remove() return end
	for key,found in pairs(ents.FindInSphere(SelfPos,400))do
		if(IsValid(found:GetPhysicsObject()))then
			if(self:Visible(found))then
				found:Ignite(30)
			end
		end
	end
	JMod_Sploom(self.Entity,SelfPos,30)
	for i=0,25 do
		local Tr=util.QuickTrace(SelfPos,VectorRand()*math.Rand(200,300),{self})
		if(Tr.Hit)then
			util.Decal("Scorch",Tr.HitPos+Tr.HitNormal,Tr.HitPos-Tr.HitNormal)
			local OhLawdyJeezusItsaFaar=ents.Create("env_fire")
			OhLawdyJeezusItsaFaar:SetKeyValue("health",tostring(math.random(20,30)))
			OhLawdyJeezusItsaFaar:SetKeyValue("firesize",tostring(math.random(30,120)))
			OhLawdyJeezusItsaFaar:SetKeyValue("fireattack","1")
			OhLawdyJeezusItsaFaar:SetKeyValue("damagescale","20")
			OhLawdyJeezusItsaFaar:SetKeyValue("spawnflags","128")
			OhLawdyJeezusItsaFaar:SetPos(Tr.HitPos)
			OhLawdyJeezusItsaFaar:Spawn()
			OhLawdyJeezusItsaFaar:Activate()
			OhLawdyJeezusItsaFaar:Fire("StartFire","",0)
		end
	end
	sound.Play("snd_jack_firebomb.wav",SelfPos,85,110)
	sound.Play("snd_jack_gasolineburn.wav",SelfPos,80,80)
	self:Remove()
end
function ENT:BeginBurnin()
	if(self.FuelLeft<=0)then return end
	self.Burning=true
	self:EmitSound("snd_jack_littleignite.wav",75,100)
end
function ENT:StahpBurnin()
	self.Burning=false
	self:EmitSound("snd_jack_littleignite.wav",75,100)
end
function ENT:Think()
	local SelfPos=self:LocalToWorld(self:OBBCenter())
	local SelfUp=self:GetUp()
	local SelfForward=self:GetForward()
	if(self.Burning)then
		if(self:WaterLevel()>0)then self:StahpBurnin() return end
		local Fft=EffectData()
		Fft:SetOrigin(SelfPos+SelfForward*7+SelfUp*10)
		Fft:SetScale(1)
		Fft:SetEntity(self)
		util.Effect("eff_jack_torchburn",Fft,true,true)
		local Tr=util.QuickTrace(SelfPos+SelfForward*7,SelfUp*25,{self})
		if(Tr.Hit)then
			if(math.random(1,8)==1)then
				util.Decal("FadingScorch",Tr.HitPos+Tr.HitNormal,Tr.HitPos-Tr.HitNormal)
				if(IsValid(Tr.Entity:GetPhysicsObject()))then
					Tr.Entity:Ignite(14)
				end
			end
		end
		self.FuelLeft=self.FuelLeft-.075
		if(self.FuelLeft<=0)then
			self:StahpBurnin()
			SafeRemoveEntityDelayed(self,10)
		end
	end
	self:NextThink(CurTime()+.1)
	return true
end
function ENT:OnRemove()
	--aw fuck you
end