--LayundMahn
--By Jackarunda
AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')
local UsableMats={MAT_DIRT,MAT_FOLIAGE,MAT_SAND,MAT_SLOSH,MAT_GRASS}
function ENT:SpawnFunction(ply, tr)
	local SpawnPos=tr.HitPos+tr.HitNormal*20
	local ent=ents.Create("ent_jack_boundingmine")
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
	self.Entity:SetModel("models/props_junk/glassjug01.mdl")
	self.Entity:SetColor(Color(153,147,111))
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)	
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.Entity:DrawShadow(true)
	self.Exploded=false
	local phys=self.Entity:GetPhysicsObject()
	if phys:IsValid()then
		phys:Wake()
		phys:SetMass(50)
		phys:SetMaterial("metal")
	end
	self:SetUseType(SIMPLE_USE)
	self.NextArmTime=CurTime()+3
	self.NextBounceNoiseTime=CurTime()
	if not(self.State)then self.State="Inactive" end
end
function ENT:Launch(toucher)
	self:DrawShadow(true)
	self.State="Flying"
	local Tr=util.QuickTrace(self:LocalToWorld(self:OBBCenter())+self:GetUp()*20,-self:GetUp()*40,{self,toucher})
	if(Tr.Hit)then timer.Simple(.1,function() util.Decal("Scorch",Tr.HitPos+Tr.HitNormal,Tr.HitPos-Tr.HitNormal) end) end
	constraint.RemoveAll(self)
	if(Tr.Hit)then self:SetPos(self:GetPos()+Tr.HitNormal*11) end
	self:GetPhysicsObject():ApplyForceCenter(self:GetUp()*16000)
	local Poof=EffectData()
	if(Tr.Hit)then
		Poof:SetOrigin(Tr.HitPos)
		Poof:SetNormal(Tr.HitNormal)
	else
		Poof:SetOrigin(self:GetPos())
		Poof:SetNormal(Vector(0,0,1))
	end
	Poof:SetScale(1)
	util.Effect("eff_jack_sminepop",Poof,true,true)
	util.SpriteTrail(self,0,Color(50,50,50,255),false,8,20,.5,1/(15+1)*0.5,"trails/smoke.vmt")
	self:EmitSound("snd_jack_sminepop.wav")
	sound.Play("snd_jack_sminepop.wav",self:GetPos(),120,80)
	timer.Simple(math.Rand(.4,.5),function()
		if(IsValid(self))then
			self:Detonate()
		end
	end)
	--GET THE FUCK OFF--
	Tr=util.QuickTrace(self:GetPos()+self:GetUp()*20,self:GetUp()*30,{self})
	if(Tr.Hit)then
		if(Tr.Entity:IsPlayer())then
			timer.Simple(.5,function()
				if((IsValid(Tr.Entity))and(IsValid(self)))then
					local Bam=DamageInfo()
					Bam:SetDamage(100)
					Bam:SetDamageType(DMG_BLAST)
					Bam:SetDamageForce(self:GetUp()*1000)
					Bam:SetDamagePosition(Tr.HitPos)
					Bam:SetAttacker(self)
					Bam:SetInflictor(self)
					Tr.Entity:TakeDamageInfo(Bam)
				end
			end)
		end
	end
end
function ENT:Detonate()
	if(self.Exploded)then return end
	self.Exploded=true
	local SelfPos=self:GetPos()
	sound.Play("snd_jack_fragsplodeclose.wav",SelfPos,75,100)
	local Poo=EffectData()
	Poo:SetOrigin(SelfPos)
	Poo:SetScale(1)
	Poo:SetDamageType(DMG_BLAST)
	Poo:SetNormal(Vector(0,0,0))
	util.Effect("eff_jack_shrapnelburst",Poo,true,true)
	util.BlastDamage(self.Entity,self.Entity,SelfPos,750,150)
	sound.Play("snd_jack_fragsplodeclose.wav",SelfPos,75,100)
	util.ScreenShake(SelfPos,99999,99999,1,750)
	for i=0,70 do
		local Trayuss=util.QuickTrace(SelfPos,VectorRand()*200-self:GetUp()*100,{self.Entity})
		if(Trayuss.Hit)then
			util.Decal("FadingScorch",Trayuss.HitPos+Trayuss.HitNormal,Trayuss.HitPos-Trayuss.HitNormal)
		end
	end
	self:Remove()
end
function ENT:PhysicsCollide(data, physobj)
	if((data.Speed>80)and(data.DeltaTime>0.2))then
		if not(data.HitEntity:IsPlayer())then self.Entity:EmitSound("SolidMetal.ImpactHard") end
	end
	if(data.HitEntity:IsWorld())then self:StartTouch(data.HitEntity) end
end
function ENT:StartTouch(ent)
	if(self.State=="Armed")then
		self.State="Preparing"
		self:EmitSound("snd_jack_metallicclick.wav",60,100)
		timer.Simple(math.Rand(.75,1.25),function() if(IsValid(self))then self:Launch(ent) end end)
	end
end
function ENT:EndTouch(ent)
	if(self.State=="Armed")then
		timer.Simple(math.Rand(1,2),function() if(IsValid(self))then self:Launch(ent) end end)
		self.State="Preparing"
		self:EmitSound("snd_jack_metallicclick.wav",60,100)
	end
end
function ENT:OnTakeDamage(dmginfo)
	if(self)then
		self:TakePhysicsDamage(dmginfo)
		if(math.random(1,8)==1)then self:StartTouch(dmginfo:GetAttacker()) end
	end
end
function ENT:Use(activator,caller)
	if((self.State=="Inactive")and(activator:IsPlayer()))then
		local Tr=util.QuickTrace(activator:GetShootPos(),activator:GetAimVector()*100,{activator,self})
		if((Tr.Hit)and(table.HasValue(UsableMats,Tr.MatType))and(IsValid(Tr.Entity:GetPhysicsObject())))then
			local Ang=Tr.HitNormal:Angle()
			Ang:RotateAroundAxis(Ang:Right(),-90)
			local Pos=Tr.HitPos-Tr.HitNormal*7.25
			self:SetAngles(Ang)
			self:SetPos(Pos)
			constraint.Weld(self,Tr.Entity,0,0,100000,true)
			local Fff=EffectData()
			Fff:SetOrigin(Tr.HitPos)
			Fff:SetNormal(Tr.HitNormal)
			Fff:SetScale(1)
			util.Effect("eff_jack_sminebury",Fff,true,true)
			self:EmitSound("snd_jack_pinpull.wav")
			activator:EmitSound("Dirt.BulletImpact")
			self.ShootDir=Tr.HitNormal
			self:DrawShadow(false)
			self.State="Armed"
			JackaGenericUseEffect(activator)
		else
			activator:PickupObject(self)
		end
	end
end
function ENT:Think()
	-- get the gerbils out of your ass
end
function ENT:OnRemove()
	-- fuck face
end