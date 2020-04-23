--mark eighty tew jenraal prrpus bawmb
--By Jackarunda

AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')

function ENT:SpawnFunction(ply, tr)

	//if not tr.Hit then return end

	local SpawnPos=tr.HitPos+tr.HitNormal*16
	local ent=ents.Create("ent_jack_dynamite")
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

	self.Entity:SetAngles(Angle(0,0,0))

	self.Entity:SetModel("models/Items/AR2_Grenade.mdl")
	self.Entity:SetMaterial("models/entities/mat_jack_dynamite")

	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)	
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.Entity:DrawShadow(true)
	
	self.Entity:SetUseType(SIMPLE_USE)
	
	self.Exploded=false
	
	if not(self.FuzeLength)then
		self.FuzeLength=900
	end
	if not(self.FuzeLit)then
		self.FuzeLit=false
	end

	local phys=self.Entity:GetPhysicsObject()
	if phys:IsValid()then
		phys:Wake()
		phys:SetMass(10)
	end
	/*-
	local FuzeModel=ents.Create("prop_dynamic")
	FuzeModel:SetModel("models/props_junk/PopCan01a.mdl")
	FuzeModel:SetMaterial("phoenix_storms/grey_steel")
	FuzeModel:SetPos(self:GetPos()+Vector(62,-10,0))
	FuzeModel:SetAngles(Angle(-90,0,0))
	FuzeModel:SetParent(self)
	FuzeModel:Spawn()
	FuzeModel:Activate()
	self:DeleteOnRemove(FuzeModel)
	-*/
	local HalfModel=ents.Create("prop_dynamic")
	HalfModel:SetModel("models/Items/AR2_Grenade.mdl")
	HalfModel:SetMaterial("models/entities/mat_jack_dynamite")
	HalfModel:SetPos(self:GetPos()+self:GetForward()*2)
	HalfModel:SetAngles(Angle(0,180,0))
	HalfModel:SetParent(self)
	HalfModel:Spawn()
	HalfModel:Activate()
	self:DeleteOnRemove(HalfModel)
	
	self.NextUseTime=CurTime()
	
	local Der=EffectData()
	Der:SetEntity(HalfModel)
	util.Effect("propspawn",Der)
end

function ENT:Detonate()

	// OH SHI-
	
	if(self.Exploded)then return end
	self.Exploded=true
	
	local SelfPos=self:LocalToWorld(self:OBBCenter())
	
	self:EmitSound("BaseExplosionEffect.Sound")
	self:EmitSound("snd_jack_fragsplodeclose.wav",90,100)
	//sound.Play("snd_jack_c4splodeclose.wav",SelfPos,90,120)

	---[[
	local splad=EffectData()
	splad:SetOrigin(SelfPos)
	splad:SetScale(2.5)
	util.Effect("eff_jack_detonate",splad,true,true)--]]
	
	local Spl=ents.Create("ent_jack_plastisplosion")
	Spl:SetPos(SelfPos)
	Spl.BasePower=110
	Spl.BlastRadius=350
	Spl.ParentEntity=self.Entity
	Spl.FromDynamite=true
	Spl:Spawn()
	Spl:Activate()
	
	self:Remove()
end

function ENT:PhysicsCollide(data, physobj)
	// Play sound on bounce
	if(data.Speed>80 and data.DeltaTime>0.2)then
		//self.Entity:EmitSound("Canister.ImpactHard")
	end
end

function ENT:OnTakeDamage(dmginfo)

	local hitter=dmginfo:GetAttacker()

	if((dmginfo:IsExplosionDamage())and(dmginfo:GetDamage()>50))then
		self:Detonate()
	end
	
	if(dmginfo:IsDamageType(DMG_BURN))then
		self.FuzeLit=true
	end

	self.Entity:TakePhysicsDamage(dmginfo)
	
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
		Fsh:SetOrigin(self:GetPos()+self:GetForward()*5)
		Fsh:SetScale(1)
		Fsh:SetNormal(self:GetForward())
		util.Effect("eff_jack_fuzeburn",Fsh,true,true)
		
		self.Entity:EmitSound("snd_jack_sss.wav",65,math.Rand(90,110))
		
		if(self.FuzeLength<=0)then
			self:Detonate()
		end
	end
	self:NextThink(CurTime()+0.05)
	return true
end

function ENT:Use(activator)
	if(activator:IsPlayer())then
		if not(activator:HasWeapon("wep_jack_dynamite"))then
			activator:Give("wep_jack_dynamite")
			activator:SelectWeapon("wep_jack_dynamite")
			local Lit=self.FuzeLit
			local Length=self.FuzeLength
			timer.Simple(.01,function()
				if(IsValid(activator))then
					activator:GetWeapon("wep_jack_dynamite").dt.Lit=Lit
					activator:GetWeapon("wep_jack_dynamite").dt.FuzeLength=Length
				end
			end)
			self:Remove()
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