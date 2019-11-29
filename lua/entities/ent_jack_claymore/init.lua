--Heavy Shaped Bomb
--By Jackarunda
AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')
local PlantableMats={MAT_WOOD,MAT_DIRT,MAT_SAND,MAT_SLOSH,MAT_FOLIAGE}
function ENT:SpawnFunction(ply, tr)
	local SpawnPos=tr.HitPos+tr.HitNormal*16
	local ent=ents.Create("ent_jack_claymore")
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
	self.Entity:SetModel("models/hunter/plates/plate025x025.mdl")
	self.Entity:SetColor(Color(153,147,111))
	self.Entity:SetRenderMode(RENDERMODE_TRANSALPHA)
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)	
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.Entity:DrawShadow(true)
	self.Exploded=false
	self.PrettyModel=ents.Create("prop_dynamic")
	self.PrettyModel:SetPos(self:GetPos()+self:GetForward()*6)
	self.PrettyModel:SetModel("models/Weapons/w_clayjore.mdl")
	self.PrettyModel:SetMaterial("models/mat_jack_claymore")
	local TheAngle=self:GetAngles()
	TheAngle:RotateAroundAxis(TheAngle:Right(),90)
	self.PrettyModel:SetAngles(TheAngle)
	self.PrettyModel:SetParent(self.Entity)
	self.PrettyModel:Spawn()
	self.PrettyModel:Activate()
	local phys=self.Entity:GetPhysicsObject()
	if phys:IsValid()then
		phys:Wake()
		phys:SetMass(50)
	end
	self.Entity:SetUseType(SIMPLE_USE)
	self.Armed=false
	self.NextUseTime=0
end
function ENT:Detonate()
	if(self.Exploded)then return end
	self.Exploded=true
	local SelfPos=self:GetPos()
	local Forward=self:GetForward()
	local Up=self:GetUp()
	local Origin=SelfPos-Forward*20
	util.BlastDamage(self.Entity,self.Entity,SelfPos,100,50)
	local Sploom=EffectData()
	Sploom:SetOrigin(Origin)
	Sploom:SetNormal(-Up)
	Sploom:SetScale(1)
	util.Effect("eff_jack_directionalsplode",Sploom,true,true)
	local Pow=EffectData()
	Pow:SetOrigin(Origin)
	Pow:SetDamageType(DMG_BULLET)
	Pow:SetNormal(-Up)
	Pow:SetScale(1)
	util.Effect("eff_jack_shrapnelburst",Pow,true,true)
	self.Entity:EmitSound("BaseExplosionEffect.Sound")
	self:EmitSound("snd_jack_fragsplodeclose.wav",100,120)
	util.ScreenShake(SelfPos,99999,99999,.5,1000)
	local MaxRange=1000
	for key,target in pairs(ents.FindInSphere(SelfPos,MaxRange))do
		if not((target==self)or(target==self.PrettyModel)or(target:IsWorld()))then
			if(IsValid(target:GetPhysicsObject()))then
				local TargPos=target:LocalToWorld(target:OBBCenter())
				local TrueVec=(SelfPos-TargPos):GetNormalized()
				local LookVec=-Up
				local DotProduct=LookVec:DotProduct(TrueVec)
				local ApproachAngle=(-math.deg(math.asin(DotProduct))+90)
				if(ApproachAngle>130)then
					if(self:Visible(target))then
						self:FireBullets({ --for the effect
							Attacker=self.Entity,
							Damage=1,
							Force=1,
							Num=1,
							Tracer=0,
							Dir=-TrueVec,
							Spread=Vector(0,0,0),
							Src=SelfPos
						})
						local DistFrac=1-((TargPos-SelfPos):Length()/MaxRange)
						local Sploo=DamageInfo()
						Sploo:SetAttacker(self)
						Sploo:SetInflictor(self)
						Sploo:SetDamage(300*DistFrac*math.Rand(.9,1.1))
						Sploo:SetDamageForce(-TrueVec*25000*DistFrac)
						Sploo:SetDamageType(DMG_BLAST)
						Sploo:SetDamagePosition(TargPos+Vector(0,0,100))
						target:TakeDamageInfo(Sploo)
					end
				end
			end
		end
	end
	for i=0,5 do
		local QT=util.QuickTrace(SelfPos,VectorRand()*50,{self})
		if(QT.Hit)then
			util.Decal("Scorch",QT.HitPos-QT.HitNormal,QT.HitPos+QT.HitNormal)
		end
	end
	self:Remove()
end
function ENT:PhysicsCollide(data, physobj)
	if(data.Speed>80 and data.DeltaTime>0.2)then
		self:EmitSound("Plastic_Box.ImpactHard")
	end
end
function ENT:OnTakeDamage(dmginfo)
	self:TakePhysicsDamage(dmginfo)
	if(dmginfo:GetDamageType()==DMG_BLAST)then
		if(dmginfo:GetDamage()>20)then
			self:Detonate()
		end
	end
end
function ENT:Use(activator,caller)
	if(self.NextUseTime>CurTime())then return end
	self.NextUseTime=CurTime()+1
	if not(self.Armed)then
		local Tr=util.QuickTrace(activator:GetShootPos(),activator:GetAimVector()*100,{self,activator})
		if((Tr.Hit)and(IsValid(Tr.Entity:GetPhysicsObject())))then
			if(table.HasValue(PlantableMats,Tr.MatType))then
				local TheAngle=activator:GetAimVector():Angle()
				TheAngle:RotateAroundAxis(TheAngle:Forward(),180)
				TheAngle:RotateAroundAxis(TheAngle:Right(),40)
				self:SetPos(Tr.HitPos+Tr.HitNormal*6)
				self:SetAngles(TheAngle)
				activator:EmitSound("Dirt.BulletImpact")
				constraint.Weld(self,Tr.Entity,0,0,2000,true)
				self:NotifySetup(activator)
			else
				local TheAngle=activator:GetAimVector():Angle()
				TheAngle:RotateAroundAxis(TheAngle:Forward(),180)
				TheAngle:RotateAroundAxis(TheAngle:Right(),40)
				self:SetPos(Tr.HitPos+Tr.HitNormal*6)
				self:SetAngles(TheAngle)
				self:NotifySetup(activator)
			end
			self:EmitSound("snd_jack_pinpull.wav")
			self.Armed=true
		end
	else
		self.Armed=false
		self:EmitSound("snd_jack_pinpush.wav")
		constraint.RemoveAll(self)
	end
end
function ENT:Think()
	self.PrettyModel:SetColor(self:GetColor())
end
function ENT:OnRemove()
	--no
end
function ENT:NotifySetup(ply)
	self.Activator=ply
	umsg.Start("JackaClaymoreNotify",ply)
	umsg.Entity(ply)
	umsg.End()
	numpad.OnDown(ply,KEY_PAD_0,"JackaClaymoreDet")
	ply.JackaClaymoresCanFire=true
end
local NextTime=0
local function DetonateClaymores(ply)
	if not(ply.JackaClaymoresCanFire)then return end
	local Time=CurTime()
	if(NextTime>Time)then return end
	NextTime=Time+1
	local FoundEm=false
	for key,lel in pairs(ents.FindByClass("ent_jack_claymore"))do
		if((lel.Activator)and(lel.Activator==ply)and(lel.Armed))then
			FoundEm=true
			timer.Simple(.7,function()
				if(IsValid(lel))then
					lel:Detonate()
				end
			end)
		end
	end
	if(FoundEm)then
		JackaGenericUseEffect(ply)
		ply:EmitSound("snd_jack_detonator.wav",70,100)
	end
end
numpad.Register("JackaClaymoreDet",DetonateClaymores)
local function CmdDetClay(...)
	local args={...}
	local ply=args[1]
	DetonateClaymores(ply)
end
concommand.Add("jacky_claymore_det",CmdDetClay)
local function Ded(ply)
	ply.JackaClaymoresCanFire=false
end
hook.Add("DoPlayerDeath","JackaClaymoresDed",Ded)