--mark eighty tew jenraal prrpus bawmb
--By Jackarunda

AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')

function ENT:SpawnFunction(ply, tr)

	//if not tr.Hit then return end

	local SpawnPos=tr.HitPos+tr.HitNormal*16
	local ent=ents.Create("ent_jack_bomblet")
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
	self.Entity:SetModel("models/Items/AR2_Grenade.mdl")
	self.Entity:SetMaterial("models/entities/mat_jack_bomblet")

	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)	
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.Entity:DrawShadow(true)
	
	self.Exploded=false
	self.NoBombletTrigger=true

	local phys=self.Entity:GetPhysicsObject()
	if phys:IsValid()then
		phys:Wake()
		phys:SetMass(15)
		phys:SetMaterial("metal")
		--phys:SetDragCoefficient(math.Rand(0,100))
	end
	
	self.NextUseTime=CurTime()
	self.Heat=0
	
	self:SetCustomCollisionCheck(true)
	
	--duds are bad m'kay
	timer.Simple(math.Rand(89,91),function() if(IsValid(self))then self:Detonate() end end)
	
	//HA GARRY I FUCKING BEAT YOU AND YOUR STUPID RULES
	local Settings=physenv.GetPerformanceSettings()
	if(Settings.MaxVelocity<5000)then Settings.MaxVelocity=5000 end
	physenv.SetPerformanceSettings(Settings)
end

function ENT:Detonate()

	// OH SHI-
	
	if(self.Exploded)then return end
	self.Exploded=true
	
	local SelfPos=self:LocalToWorld(self:OBBCenter())
	
	self:EmitSound("snd_jack_fragsplodeclose.wav",90,100)
	self:EmitSound("snd_jack_fragsplodeclose.wav",90,105)
	sound.Play("snd_jack_fragsplodeclose.wav",SelfPos,90,95)
	sound.Play("snd_jack_fragsplodeclose.wav",SelfPos,90,110)
	self:EmitSound("snd_jack_fragsplodefar.wav",130,100)

	local splad=EffectData()
	splad:SetOrigin(SelfPos)
	splad:SetScale(1)
	util.Effect("eff_jack_bombletdetonate",splad,true,true)
	
	util.BlastDamage(self.Entity,self.Entity,SelfPos,220,110)
	util.ScreenShake(SelfPos,10,10,.5,250)
	
	local Tr=util.QuickTrace(SelfPos,self:GetPhysicsObject():GetVelocity(),{self})
	if(Tr.Hit)then util.Decal("Scorch",Tr.HitPos+Tr.HitNormal,Tr.HitPos-Tr.HitNormal) end
	
	for key,object in pairs(ents.FindInSphere(SelfPos,60))do
		local Phys=object:GetPhysicsObject()
		if(IsValid(Phys))then
			if(Phys:GetMass()<=350)then constraint.RemoveAll(object);object:Fire("enablemotion","",0) end
		end
	end

	self:Remove()
end

function ENT:PhysicsCollide(data, physobj)
	if(data.Speed>200)then
		self:Detonate()
	elseif((data.Speed>80)and(data.DeltaTime>0.2))then
		self.Entity:EmitSound("Canister.ImpactHard")
	end
end

local function NoCollide(entOne,entTwo)
	if((entOne.NoBombletTrigger)and(entTwo.NoBombletTrigger))then return false end
end
hook.Add("ShouldCollide","JackysBombletNoCollision",NoCollide)

function ENT:OnTakeDamage(dmginfo)
	local hitter=dmginfo:GetAttacker()
	if((dmginfo:IsExplosionDamage())and(dmginfo:GetDamage()>250))then
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
				JackySimpleOrdnanceArm(self,activator,"Set: Impact")
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
	if(self:IsOnFire())then
		self.Heat=self.Heat+1
		if(self.Heat>100)then
			self:Detonate()
		end
	else
		self.Heat=self.Heat-1
	end
end

function ENT:OnRemove()
end