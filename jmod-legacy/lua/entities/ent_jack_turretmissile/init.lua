--gernaaaayud
--By Jackarunda
AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')
ENT.MotorPower=0
local HULL_TARGETING={
	[HULL_TINY]=-5,
	[HULL_TINY_CENTERED]=0,	
	[HULL_SMALL_CENTERED]=-5,
	[HULL_HUMAN]=10,
	[HULL_WIDE_SHORT]=20,
	[HULL_WIDE_HUMAN]=15,
	[HULL_MEDIUM]=0,
	[HULL_MEDIUM_TALL]=35,
	[HULL_LARGE]=30,
	[HULL_LARGE_CENTERED]=30
}
function ENT:Initialize()
	self.Entity:SetModel("models/hawx/weapons/aim-9 sidewinder.mdl")
	self.Entity:SetMaterial("models/mat_jack_sidewinderaam")
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)	
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.Entity:SetCollisionGroup(COLLISION_GROUP_NONE)
	self.Entity:SetUseType(SIMPLE_USE)
	local phys=self.Entity:GetPhysicsObject()
	if phys:IsValid()then
		phys:Wake()
		phys:SetMass(15)
		--phys:EnableGravity(false)
		phys:SetDamping(1,5)
	end
	self:Fire("enableshadow","",0)
	self.Exploded=false
	self.ExplosiveMul=0.5
	self.MotorFired=false
	self.Engaged=false
	self.AimAng=self:GetAngles()
	timer.Simple(.5,function()
		if(IsValid(self))then
			self:FireMotor()
		end
	end)
	self:SetModelScale(.25,0)
	self:SetColor(Color(10,15,20))
	self:GetPhysicsObject():AddAngleVelocity(-self:GetPhysicsObject():GetAngleVelocity())
	timer.Simple(.1,function()
		if(IsValid(self))then
			local Vel=self:GetPhysicsObject():GetVelocity()
			self:SetAngles(self.InitialAng)
			self:GetPhysicsObject():SetVelocity(Vel)
		end
	end)
	util.PrecacheSound("snd_jack_missilemotorfire.wav")
end
function ENT:FireMotor()
	if(self.MotorFired)then return end
	self.MotorFired=true
	sound.Play("snd_jack_missilemotorfire.wav",self:GetPos(),85,100)
	sound.Play("snd_jack_missilemotorfire.wav",self:GetPos()+Vector(0,0,1),88,100)
	self:SetDTBool(0,true)
	timer.Simple(.5,function()
		if(IsValid(self))then
			self.Engaged=true
		end
	end)
end
function ENT:PhysicsCollide(data,physobj)
	if((data.Speed>80)and(data.DeltaTime>.2))then
		self:Detonate()
	end
end
function ENT:OnTakeDamage(dmginfo)
	self.Entity:TakePhysicsDamage(dmginfo)
end
function ENT:Think()
	if(self.Exploded)then return end
	if not(self.MotorFired)then
		self:GetPhysicsObject():AddAngleVelocity(-self:GetPhysicsObject():GetAngleVelocity())
		return
	end
	if not(self.Engaged)then
		self:GetPhysicsObject():AddAngleVelocity(-self:GetPhysicsObject():GetAngleVelocity())
	end
	local Flew=EffectData()
	Flew:SetOrigin(self:GetPos()-self:GetRight()*20)
	Flew:SetNormal(-self:GetRight())
	Flew:SetScale(5)
	util.Effect("eff_jack_rocketthrust",Flew)
	local SelfPos=self:GetPos()
	local Phys=self:GetPhysicsObject()
	Phys:EnableGravity(false)
	if(IsValid(self.Target))then
		local TargPhys=self.Target:GetPhysicsObject()
		if((IsValid(self.Target))and(self.Engaged))then
			local TargetPosition=self:GetTargetPos(self.Target)
			if(TargetPosition)then
				local Vel=Phys:GetVelocity()
				local Vec=(TargetPosition-SelfPos)
				local Dir=Vec:GetNormalized()
				local Dist=Vec:Length()
				if(Dist>Vel:Length()/1.8)then
					local ErrorVelocity=self:GetVelocity()-Vec
					local AdjustedTargetPosition=TargetPosition-ErrorVelocity
					TargetPosition=AdjustedTargetPosition
					Vec=(TargetPosition-SelfPos)
					Dir=Vec:GetNormalized()
				end
				local TheAngle=Dir:Angle()
				TheAngle:RotateAroundAxis(TheAngle:Up(),90)
				self:SetAngles(TheAngle)
				Phys:SetVelocity(Vel)
				if(Dist<750)then
					local Speed=Vel:Length()
					Phys:SetVelocity(Dir*Speed)
				end
				--pretty much all homing missiles use proximity triggering rather than relying on impact fuzes
				if(Dist<200)then
					self:Detonate()
					return
				end
			end
		end
	end
	Phys:ApplyForceCenter(self:GetRight()*self.MotorPower)
	self.MotorPower=self.MotorPower+300
	if(self.MotorPower>=25000)then self.MotorPower=25000 end
	self:NextThink(CurTime()+.025)
	return true
end
function ENT:OnRemove()
	--pff
end
function ENT:Detonate()
	if(self.Exploding)then return end
	self.Exploding=true
	local SelfPos=self:GetPos()
	local Pos=SelfPos
	if(true)then
		/*-  EFFECTS  -*/
		util.ScreenShake(SelfPos,99999,99999,1,750)
		local Boom=EffectData()
		Boom:SetOrigin(SelfPos)
		Boom:SetScale(2)
		util.Effect("eff_jack_lightboom",Boom,true,true)
		ParticleEffect("pcf_jack_airsplode_medium",SelfPos,self:GetAngles())
		for key,thing in pairs(ents.FindInSphere(SelfPos,500))do
			if((thing:IsNPC())and(self:Visible(thing)))then
				if(table.HasValue({"npc_strider","npc_combinegunship","npc_helicopter","npc_turret_floor","npc_turret_ground","npc_turret_ceiling"},thing:GetClass()))then
					thing:SetHealth(1)
					thing:Fire("selfdestruct","",.5)
				end
			end
		end
		util.BlastDamage(self.Entity,self.Entity,SelfPos,600,300)
		self:EmitSound("snd_jack_fragsplodeclose.wav",80,100)
		sound.Play("snd_jack_fragsplodeclose.wav",SelfPos+Vector(0,0,1),75,80)
		sound.Play("snd_jack_fragsplodefar.wav",SelfPos+Vector(0,0,2),100,80)
		for i=0,30 do
			local Trayuss=util.QuickTrace(SelfPos,VectorRand()*200,{self.Entity})
			if(Trayuss.Hit)then
				util.Decal("Scorch",Trayuss.HitPos+Trayuss.HitNormal,Trayuss.HitPos-Trayuss.HitNormal)
			end
		end
		for key,obj in pairs(ents.FindInSphere(SelfPos,200))do
			if(IsValid(obj:GetPhysicsObject()))then
				if((obj:Visible(self))and not(obj.JackyArmoredPanel))then
					if(obj:GetPhysicsObject():GetMass()<500)then
						constraint.RemoveAll(obj)
					end
				end
			end
		end
		self.Entity:Remove()
	end
end
function ENT:Use(activator,caller)
	--lol dude
end
function ENT:GetTargetPos(ent)
	local Pos=ent:LocalToWorld(ent:OBBCenter())
	local Hull
	if not(ent.GetHullType)then
		Hull=HULL_HUMAN
	else
		Hull=ent:GetHullType()
	end
	local Add=Vector(0,0,HULL_TARGETING[Hull])
	if((string.find(ent:GetClass(),"vehicle",1,false))or(string.find(ent:GetClass(),"car",1,false)))then
		Add=Vector(0,0,0)
	end
	Pos=Pos+Add
	if((ent:IsPlayer())and(ent:Crouching()))then
		Pos=Pos-Vector(0,0,20)
	end
	return Pos
end