--LayundMahn
--By Jackarunda
AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')
function ENT:SpawnFunction(ply, tr)
	local SpawnPos=tr.HitPos+tr.HitNormal*20
	local ent=ents.Create("ent_jack_slam")
	ent:SetAngles(Angle(0,0,0))
	ent:SetPos(SpawnPos)
	ent.Owner=ply
	ent:Spawn()
	ent:Activate()
	local effectdata=EffectData()
	effectdata:SetEntity(ent)
	util.Effect("propspawn",effectdata)
	return ent
end
function ENT:Initialize()
	self.Entity:SetModel("models/weapons/w_jlam.mdl")
	self.Entity:SetColor(Color(217,208,157))
	self.Entity:SetBodygroup(0,0)
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)	
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.Entity:DrawShadow(true)
	self.Exploded=false
	local phys=self.Entity:GetPhysicsObject()
	if phys:IsValid()then
		phys:Wake()
		phys:SetMass(40)
		phys:SetMaterial("metal")
	end
	self:SetUseType(SIMPLE_USE)
	self.NextArmTime=CurTime()+3
	self.NextBounceNoiseTime=CurTime()
	if not(self.State)then self.State="Inactive" end
	self.Picked=0
end
function ENT:Detonate(tr)
	if(self.Exploded)then return end
	self.Exploded=true
	local SelfPos=self:GetPos()
	local Dir=self:GetUp()
	sound.Play("snd_jack_fragsplodeclose.wav",SelfPos,75,95)
	local Poo=EffectData()
	Poo:SetOrigin(SelfPos)
	Poo:SetScale(1)
	Poo:SetNormal(Dir)
	util.Effect("eff_jack_directionalsplode",Poo,true,true)
	for i=0,2 do
		JMod_Sploom(self.Entity,SelfPos+VectorRand(),20)
	end
	for i=0,5 do
		local QT=util.QuickTrace(SelfPos,VectorRand()*50,{self})
		if(QT.Hit)then
			util.Decal("Scorch",QT.HitPos-QT.HitNormal,QT.HitPos+QT.HitNormal)
		end
	end
	for i=1,20 do
		local Bellit={
			Attacker=self.Entity,
			Damage=1,
			Force=1,
			Num=1,
			Tracer=0,
			Dir=Dir,
			Spread=Vector(.001,.001,.001),
			Src=SelfPos+Dir
		}
		self:FireBullets(Bellit)
	end
	if(IsValid(tr.Entity))then
		local Phys=tr.Entity:GetPhysicsObject()
		if(IsValid(Phys))then
			if not(tr.Entity.JackyArmorPanel)then
				constraint.RemoveAll(tr.Entity)
			end
		end
		local Sploom=DamageInfo()
		Sploom:SetDamageType(DMG_BULLET)
		Sploom:SetDamage(math.Rand(200,275))
		Sploom:SetDamageForce(Dir*1e7)
		Sploom:SetAttacker(self)
		Sploom:SetInflictor(self)
		Sploom:SetDamagePosition(tr.HitPos)
		tr.Entity:TakeDamageInfo(Sploom)
		util.BlastDamage(self,self,tr.HitPos,75,250)
	end
	sound.Play("snd_jack_fragsplodeclose.wav",SelfPos,75,95)
	util.ScreenShake(SelfPos,99999,99999,1,750)
	self:Remove()
end
function ENT:PhysicsCollide(data, physobj)
	if((data.Speed>80)and(data.DeltaTime>0.2))then
		self.Entity:EmitSound("DryWall.ImpactHard")
	end
end
function ENT:OnTakeDamage(dmginfo)
	self:TakePhysicsDamage(dmginfo)
end
function ENT:Use(activator,caller)
	if((self.State=="Inactive")and(activator:IsPlayer()))then
		if(self.Picked>0)then
			local Tr=util.QuickTrace(activator:GetShootPos(),activator:GetAimVector()*100,{activator,self})
			if((Tr.Hit)and(IsValid(Tr.Entity:GetPhysicsObject())))then
				local Ang=Tr.HitNormal:Angle()
				Ang:RotateAroundAxis(Ang:Right(),-90)
				local Pos=Tr.HitPos+Tr.HitNormal*2
				self:SetAngles(Ang)
				self:SetPos(Pos)
				constraint.Weld(self,Tr.Entity,0,0,5000,true)
				self:SetBodygroup(0,1)
				self:EmitSound("snd_jack_pinpull.wav")
				self.ShootDir=self:GetUp()
				self.State="Armimg"
				timer.Simple(2,function()
					if(IsValid(self))then
						self:Arm()
					end
				end)
				JackaGenericUseEffect(activator)
			end
		else
			activator:PickupObject(self)
			self.Picked=10
		end
	end
end
function ENT:Arm()
	self.State="Armed"
	local Dir=self:GetUp()
	local Tr=util.QuickTrace(self:GetPos()+Dir,Dir*1000,{self})
	if(Tr.Hit)then
		self.InitialDist=math.Round(((self:GetPos()+Dir)-Tr.HitPos):Length())
	else
		self.InitialDist=1000
	end
end
function ENT:Think()
	if(self.State=="Armed")then
		local Dir=self:GetUp()
		local SelfPos=self:GetPos()+Dir
		local TrDist=1000
		local Tr=util.QuickTrace(SelfPos,Dir*1000,{self})
		if(Tr.Hit)then
			TrDist=math.Round((SelfPos-Tr.HitPos):Length())
		end
		if(TrDist!=self.InitialDist)then
			self:Detonate(Tr)
		end
	elseif(self.State=="Inactive")then
		if(self:IsPlayerHolding())then
			self.Picked=10
		end
	end
	self.Picked=self.Picked-1
	if(self.Picked<0)then self.Picked=0 end
	self:NextThink(CurTime()+.05)
	return true
end
function ENT:OnRemove()
	-- fuck face
end