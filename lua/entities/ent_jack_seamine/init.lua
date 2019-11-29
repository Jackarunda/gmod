--uy
--By Jackarunda
AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')
function ENT:SpawnFunction(ply, tr)
	local SpawnPos=tr.HitPos+tr.HitNormal*32
	local ent=ents.Create("ent_jack_seamine")
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
	local Ang=self:GetAngles()
	Ang:RotateAroundAxis(Ang:Right(),180)
	self:SetAngles(Ang)
	self.Entity:SetModel("models/magnet/submine/submine.mdl")
	self.Entity:SetMaterial("models/mat_jack_dullscratchedmetal")
	self.Entity:SetColor(Color(160,170,175))
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)	
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.Entity:DrawShadow(true)
	self.Exploded=false
	local phys=self.Entity:GetPhysicsObject()
	if phys:IsValid()then
		phys:Wake()
		phys:SetMass(220)
		phys:SetMaterial("wood")
		phys:SetDamping(.2,.2)
	end
	self.NextUseTime=CurTime()
	--[[
	self.Counterweight=ents.Create("prop_physics")
	self.Counterweight:SetModel("models/props_junk/cardboard_box001a.mdl")
	self.Counterweight:SetPos(self:GetPos()-self:GetUp()*2)
	self.Counterweight.AreJackyTailFins=true
	self.Counterweight:Spawn()
	self.Counterweight:Activate()
	self.Counterweight:SetNotSolid(true)
	self.Counterweight:SetNoDraw(true)
	self.Counterweight:GetPhysicsObject():SetMass(70)
	self:DeleteOnRemove(self.Counterweight)
	constraint.Weld(self.Entity,self.Counterweight,0,0,0,true)
	--]]
	self:SetUseType(SIMPLE_USE)
end
function ENT:Detonate()
	if(self.Exploded)then return end
	self.Exploded=true
	local SelfPos=self:LocalToWorld(self:OBBCenter())
	--if(self.Counterweight)then self.Counterweight:Remove() end
	for key,object in pairs(ents.FindInSphere(SelfPos,150))do
		if(IsValid(object:GetPhysicsObject()))then
			if((object:Visible(self))and not(object.JackyArmoredPanel))then
				constraint.RemoveAll(object)
			end
		end
	end
	if(self:WaterLevel()>0)then
		sound.Play("ambient/water/water_splash"..math.random(1,3)..".wav",SelfPos,100,100)
		sound.Play("ambient/water/water_splash"..math.random(1,3)..".wav",SelfPos,100,99)
		sound.Play("ambient/water/water_splash"..math.random(1,3)..".wav",SelfPos,100,90)
		sound.Play("ambient/water/water_splash"..math.random(1,3)..".wav",SelfPos,110,80)
		sound.Play("ambient/water/water_splash"..math.random(1,3)..".wav",SelfPos,120,70)
		sound.Play("ambient/water/water_splash"..math.random(1,3)..".wav",SelfPos,120,60)
		sound.Play("ambient/water/water_splash"..math.random(1,3)..".wav",SelfPos,130,50)
		sound.Play("ambient/water/water_splash"..math.random(1,3)..".wav",SelfPos,140,40)
		local splad=EffectData()
		splad:SetOrigin(SelfPos)
		splad:SetScale(4)
		util.Effect("eff_jack_waterboom",splad,true,true)
	else
		sound.Play("BaseExplosionEffect.Sound",SelfPos)
		sound.Play("weapons/explode4.wav",SelfPos,100,150)
		sound.Play("snd_jack_bigsplodeclose.wav",SelfPos,110,100)
		sound.Play("snd_jack_bigsplodeclose.wav",SelfPos,110,100)
		self.Entity:EmitSound("BaseExplosionEffect.Sound")
		sound.Play("weapons/explode3.wav",self.Entity:GetPos(),100,150)
		local splad=EffectData()
		splad:SetOrigin(SelfPos)
		splad:SetScale(4)
		util.Effect("eff_jack_lightboom",splad,true,true)
		ParticleEffect("pcf_jack_airsplode_large",SelfPos,vector_up:Angle())
	end
	util.BlastDamage(self.Entity,self.Entity,SelfPos,1000,500)
	util.ScreenShake(SelfPos,99999,99999,1,1000)
	self:Remove()
end
function ENT:PhysicsCollide(data, physobj)
	if((data.Speed>80)and(data.DeltaTime>0.2))then
		self.Entity:EmitSound("Canister.ImpactHard")
	end
	if(data.Speed>5)then
		if(self.Armed)then
			self:Detonate()
		end
	end
end
function ENT:OnTakeDamage(dmginfo)
	local hitter=dmginfo:GetAttacker()
	if(self.Armed)then
		if(math.random(1,8)==3)then
			self:Detonate()
		end
	end
	self.Entity:TakePhysicsDamage(dmginfo)
end
function ENT:Use(activator,caller)
	if(activator:IsPlayer())then
		if not(self.NextUseTime<CurTime())then return end
		self.NextUseTime=CurTime()+.5
		if not(self.Armed)then
			if not(self.Fuzed)then
				self.Fuzed=true
				self:EmitSound("snd_jack_pinpull.wav",65,90)
				timer.Simple(10,function()
					if(IsValid(self))then
						self.Armed=true
					end
				end)
				JackaGenericUseEffect(activator)
			end
		end
	end
end
function ENT:Think()
	--
end