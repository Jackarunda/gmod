AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')

function ENT:SpawnFunction(ply, tr)

	//if not tr.Hit then return end

	local SpawnPos=tr.HitPos+tr.HitNormal*16
	local ent=ents.Create("ent_jack_firework")
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

	self.Entity:SetModel("models/mechanics/solid_steel/type_b_2_4.mdl")

	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)	
	self.Entity:SetSolid(SOLID_VPHYSICS)
	
	self.Exploded=false

	local phys=self.Entity:GetPhysicsObject()
	if phys:IsValid()then
		phys:Wake()
		phys:SetMass(250)
	end

	self.Entity:DrawShadow(true)
	
	self:SetAngles(Angle(0,0,0))
	self.Nice=ents.Create("prop_dynamic")
	self.Nice:SetModel("models/props_phx/ww2bomb.mdl")
	self.Nice:SetMaterial("models/entities/mat_jack_firework")
	self.Nice:SetAngles(Angle(0,0,0))
	self.Nice:SetPos(self:GetPos()-self:GetUp()*6)
	self.Nice:SetParent(self)
	self.Nice:Spawn()
	self.Nice:Activate()
	
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
	
	self.Armed=false
	self.NextUseTime=CurTime()
	self.Heat=0
	self.Travel=0
	
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
	
	timer.Simple(.01,function()
		sound.Play("snd_jack_fireworksplodeclose.wav",SelfPos,75,100)
		sound.Play("snd_jack_fireworksplodeclose.wav",SelfPos,130,100)
		sound.Play("snd_jack_fireworksplodefar.wav",SelfPos,130,100)
	end)

	for i=5,50 do
		if(math.random(0,i)<8)then
			timer.Simple(i/10*math.Rand(.9,1.1),function()
				sound.Play("snd_jack_fireworkpop"..tostring(math.random(1,5))..".wav",SelfPos,math.Rand(80,120),math.Rand(90,100))
			end)
		end
	end
	
	if not(AmericanSongPlaying)then
		AmericanSongPlaying=true
		timer.Simple(5,function()
			local Song="snd_jack_merica"..math.random(1,10)..".mp3"
			sound.Play(Song,SelfPos,150,95)
			for key,found in pairs(player.GetAll())do
				if(found:GetName()=="Jackarunda")then
					sound.Play(Song,SelfPos,140,95)
					sound.Play(Song,SelfPos,130,95)
					sound.Play(Song,SelfPos,120,95)
					sound.Play(Song,SelfPos,110,95)
				end
			end
			timer.Simple(10,function()
				AmericanSongPlaying=false
			end)
		end)
	end
	
	local Poof=EffectData()
	Poof:SetOrigin(SelfPos)
	Poof:SetStart(self:GetPhysicsObject():GetVelocity())
	Poof:SetScale(1)
	util.Effect("eff_jack_america",Poof,true,true)
	
	self:Remove()
end

function ENT:PhysicsCollide(data, physobj)
	// Play sound on bounce
	if(data.Speed>80 and data.DeltaTime>0.2)then
		if(self)then self:EmitSound("Canister.ImpactHard") end
	end
end

function ENT:OnTakeDamage(dmginfo)

	local hitter=dmginfo:GetAttacker()

	if((dmginfo:IsExplosionDamage())and(dmginfo:GetDamage()>90))then
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
				JackySimpleOrdnanceArm(self,activator,"Set: Upward Flight Time")
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
		if(Vel.z>0)then
			local Speed=Vel:Length()
			if(Speed>600)then
				self.Travel=self.Travel+1
				if(self.Travel>18)then self:Detonate() return end
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

function ENT:OnRemove()
end

local function SetUpGlobalVar()
	AmericanSongPlaying=false
end
hook.Add("Initialize","JackysGlobalVarInit",SetUpGlobalVar)