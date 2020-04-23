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
	self.Entity:SetModel("models/hawx/weapons/agm-65 maverick.mdl")
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
		phys:EnableDrag(false)
	end
	self:Fire("enableshadow","",0)
	self.Exploded=false
	self.ExplosiveMul=0.5
	self.MotorFired=false
	self.Engaged=false
	self:SetModelScale(.25,0)
	self:SetColor(Color(10,15,20))
	util.PrecacheSound("snd_jack_missilemotorfire.wav")
	self.InitialAng=self:GetAngles()
	timer.Simple(.15,function()
		if(IsValid(self))then
			self:FireMotor()
		end
	end)
	local Settins=physenv.GetPerformanceSettings()
	if(Settins.MaxVelocity<3000)then
		Settins.MaxVelocity=3000
		physenv.SetPerformanceSettings(Settins)
	end
	--if not(self.InitialVel)then self.InitialVel=Vector(0,0,0) end
end
function ENT:FireMotor()
	if(self.MotorFired)then return end
	self.MotorFired=true
	sound.Play("snd_jack_missilemotorfire.wav",self:GetPos(),85,110)
	sound.Play("snd_jack_missilemotorfire.wav",self:GetPos()+Vector(0,0,1),88,110)
	self:SetDTBool(0,true)
	self.Engaged=true
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
	if not(self.Engaged)then
		self:GetPhysicsObject():EnableGravity(false)
		self:SetAngles(self.InitialAng)
		self:GetPhysicsObject():SetVelocity(self.InitialVel)
	end
	if(self.MotorFired)then
		local Flew=EffectData()
		Flew:SetOrigin(self:GetPos()-self:GetRight()*20)
		Flew:SetNormal(-self:GetRight())
		Flew:SetScale(5)
		util.Effect("eff_jack_rocketthrust",Flew)
		local SelfPos=self:GetPos()
		local Phys=self:GetPhysicsObject()
		Phys:EnableGravity(false)
		Phys:ApplyForceCenter(self:GetRight()*self.MotorPower)
		self.MotorPower=self.MotorPower+1500
		if(self.MotorPower>=160000)then self.MotorPower=160000 end
	end
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
		Boom:SetScale(2.25)
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
		util.BlastDamage(self.Entity,self.Entity,SelfPos,600,400)
		self:EmitSound("snd_jack_fragsplodeclose.wav",80,100)
		sound.Play("snd_jack_fragsplodeclose.wav",SelfPos+Vector(0,0,1),75,80)
		sound.Play("snd_jack_fragsplodefar.wav",SelfPos+Vector(0,0,2),100,80)
		for i=0,40 do
			local Trayuss=util.QuickTrace(SelfPos,VectorRand()*200,{self.Entity})
			if(Trayuss.Hit)then
				util.Decal("Scorch",Trayuss.HitPos+Trayuss.HitNormal,Trayuss.HitPos-Trayuss.HitNormal)
			end
		end
		for key,obj in pairs(ents.FindInSphere(SelfPos,250))do
			if(IsValid(obj:GetPhysicsObject()))then
				if((obj:Visible(self))and not(obj.JackyArmoredPanel))then
					if(obj:GetPhysicsObject():GetMass()<800)then
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