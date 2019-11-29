--LayundMahn
--By Jackarunda
AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')
local STATE_OFF=0
local STATE_ARMING=1
local STATE_ARMED=2
function ENT:SpawnFunction(ply, tr)
	local SpawnPos=tr.HitPos+tr.HitNormal*20
	local ent=ents.Create("ent_jack_warmine")
	ent:SetAngles(Angle(0,0,0))
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
	self.Entity:SetModel("models/props_combine/combine_mine01.mdl")
	self.Entity:SetMaterial("models/mat_jack_warmine")
	self.Entity:SetColor(Color(50,50,50))
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)	
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.Entity:DrawShadow(true)
	self.Exploded=false
	local phys=self.Entity:GetPhysicsObject()
	if phys:IsValid()then
		phys:Wake()
		phys:SetMass(75)
	end
	self:SetUseType(SIMPLE_USE)
	self.State=STATE_OFF
	self.Patience=100
	self.ClawsOut=0
	self.NextWarnTime=0
	self.NextFriendlyWarnTime=0
	self:SetLegs(110)
	self:SetClaws(40)
	self:SetNetworkedInt("JackIndex",self:EntIndex())
	self.MenuOpen=false
	self.IFFTags={}
end
function ENT:Detonate()
	local SelfPos=self:GetPos()+self:GetUp()*10
	local Boom=EffectData()
	Boom:SetOrigin(SelfPos)
	Boom:SetScale(3)
	util.Effect("eff_jack_lightboom",Boom,true,true)
	--util.Effect("eff_jack_genericboom",Boom,true,true)
	ParticleEffect("pcf_jack_groundsplode_large",SelfPos,vector_up:Angle())
	sound.Play("snd_jack_bigsplodeclose.wav",SelfPos,110,100)
	sound.Play("snd_jack_bigsplodeclose.wav",SelfPos,110,100)
	for key,ent in pairs(ents.FindInSphere(SelfPos,150))do
		if(IsValid(ent:GetPhysicsObject()))then
			if((ent:Visible(self))and not(ent.JackyArmoredPanel))then
				constraint.RemoveAll(ent)
			end
		end
	end
	util.BlastDamage(self.Entity,self.Entity,SelfPos,800,400)
	util.ScreenShake(SelfPos,99999,99999,1,1000)
	self:EmitSound("snd_jack_fragsplodeclose.wav",80,100)
	sound.Play("snd_jack_fragsplodeclose.wav",SelfPos+Vector(0,0,1),75,80)
	sound.Play("snd_jack_fragsplodefar.wav",SelfPos+Vector(0,0,2),100,80)
	sound.Play("snd_jack_bigsplodeclose.wav",SelfPos+Vector(0,0,3),81,90)
	sound.Play("snd_jack_debris"..tostring(math.random(1,2))..".mp3",SelfPos,80,90)
	for i=0,30 do
		local Trayuss=util.QuickTrace(SelfPos,VectorRand()*200,{self.Entity})
		if(Trayuss.Hit)then
			util.Decal("Scorch",Trayuss.HitPos+Trayuss.HitNormal,Trayuss.HitPos-Trayuss.HitNormal)
		end
	end
	self:Remove()
end
function ENT:PhysicsCollide(data, physobj)
	if((data.Speed>80)and(data.DeltaTime>0.2))then
		self.Entity:EmitSound("Canister.ImpactHard")
	end
end
--[[
function ENT:StartTouch(ent)
	//nothin
end
function ENT:EndTouch(ent)
	//nothin
end
--]]
function ENT:OnTakeDamage(dmginfo)
	if(self)then self:TakePhysicsDamage(dmginfo) end
end
function ENT:Use(activator,caller)
	if(self.State==STATE_OFF)then
		umsg.Start("JackaWarMineOpenMenu",activator)
		umsg.Entity(self)
		umsg.Bool(table.HasValue(self.IFFTags,activator:GetNetworkedInt("JackyIFFTag")))
		umsg.End()
	end
end
function ENT:SetLegs(angle)
	self:ManipulateBoneAngles(1,Angle(0,0,angle))
	self:ManipulateBoneAngles(3,Angle(0,0,angle))
	self:ManipulateBoneAngles(5,Angle(0,0,angle))
end
function ENT:SetClaws(angle)
	self:ManipulateBoneAngles(2,Angle(0,angle,0))
	self:ManipulateBoneAngles(4,Angle(0,angle,0))
	self:ManipulateBoneAngles(6,Angle(0,angle,0))
	sound.Play("snd_jack_metallicclick.wav",self:GetPos(),70,110)
end
function ENT:Think()
	local Time=CurTime()
	if(self.State==STATE_ARMED)then
		local Aggravated=false
		local SelfPos=self:GetPos()+self:GetUp()*10
		local Fastest=20
		local DangerClose=false
		for key,found in pairs(ents.FindInSphere(SelfPos,500))do
			local Phys=found:GetPhysicsObject()
			local MyPhys=self:GetPhysicsObject()
			if(IsValid(Phys))then
				local SpeedDiff=(Phys:GetVelocity()-MyPhys:GetVelocity()):Length()
				if(self:Visible(found))then
					if(found:IsPlayer())then
						if(table.HasValue(self.IFFTags,found:GetNetworkedInt("JackyIFFTag")))then
							DangerClose=true
						end
					end
					if(SpeedDiff>Fastest)then
						local Vol=Phys:GetVolume()
						if((Vol)and(Vol>14000))then
							Fastest=SpeedDiff
							Aggravated=true
						end
					end
				end
			end
		end
		if not(Aggravated)then
			self.Patience=self.Patience+.25
			if(self.Patience>100)then self.Patience=100 end
		else
			if not(DangerClose)then
				self.Patience=self.Patience-(Fastest/20)
				if(self.Patience>0)then
					self:Warn()
				else
					self:Detonate()
					return
				end
			elseif(self.NextFriendlyWarnTime<CurTime())then
				self.NextFriendlyWarnTime=CurTime()+.5
				self:FriendlyWarn()
			end
		end
		self:NextThink(CurTime()+.25)
		return true
	elseif(self.State==STATE_ARMING)then
		if(self.NextWarnTime<Time)then
			self:Alert()
			self.NextWarnTime=Time+1
		end
		self:NextThink(CurTime()+.05)
		if not(self.ClawsOut>=90)then
			self.ClawsOut=self.ClawsOut+1
			self:SetClaws(40-self.ClawsOut)
			if(self.ClawsOut>=90)then
				self:ArmFire()
			end
		end
		return true
	end
end
function ENT:FriendlyWarn()
	local Flash=EffectData()
	Flash:SetOrigin(self:GetPos()+self:GetUp()*25)
	Flash:SetScale(.7)
	util.Effect("eff_jack_cyanflash",Flash,true,true)
	self:EmitSound("snd_jack_turrethi.wav",80,100)
end
function ENT:OnRemove()
	//nothin
end
function ENT:BeginArming()
	self.State=STATE_ARMING
end
function ENT:ArmFire()
	self:EmitSound("snd_jack_warmineprepare.wav")
	timer.Simple(1.7,function()
		if(IsValid(self))then
			self:Attach()
		end
	end)
end
function ENT:Attach()
	self:SetLegs(-10)
	self:EmitSound("snd_jack_turretshootshot_close.wav",75,100)
	local TrDat={}
	TrDat.start=self:GetPos()+self:GetUp()*5
	TrDat.endpos=self:GetPos()-self:GetUp()*10
	TrDat.filter={self}
	local Tr=util.TraceLine(TrDat)
	if(Tr.Hit)then
		if((IsValid(Tr.Entity:GetPhysicsObject()))or(Tr.Entity:IsWorld()))then
			constraint.Weld(self,Tr.Entity,0,0,0,true)
			constraint.Weld(self,Tr.Entity,0,0,9000,true)
		end
		self:PlantEffect(15,-10)
		self:PlantEffect(-17,-8)
		self:PlantEffect(1.5,19)
	end
	timer.Simple(5,function()
		if(IsValid(self))then
			self:Arm()
		end
	end)
end
function ENT:Arm()
	self.State=STATE_ARMED
end
function ENT:PlantEffect(x,y)
	local Bellit={
		Attacker=self.Entity,
		Damage=3,
		Force=2,
		Num=8,
		Tracer=0,
		Dir=-self:GetUp(),
		Spread=Vector(.5,.5,.5),
		Src=self:GetPos()+self:GetUp()*5+self:GetForward()*x+self:GetRight()*y
	}
	self:FireBullets(Bellit)
end
function ENT:Warn()
	local Flash=EffectData()
	Flash:SetOrigin(self:GetPos()+self:GetUp()*20)
	Flash:SetScale(.5)
	util.Effect("eff_jack_redflash",Flash,true,true)
	self:EmitSound("snd_jack_turretwarn.wav",75,110)
	sound.Play("snd_jack_turretwarn.wav",self:GetPos(),80,110)
end
function ENT:Alert()
	local Flash=EffectData()
	Flash:SetOrigin(self:GetPos()+self:GetUp()*20)
	Flash:SetScale(.5)
	util.Effect("eff_jack_redflash",Flash,true,true)
	self:EmitSound("snd_jack_friendlylarm.wav",75,100)
	sound.Play("snd_jack_friendlylarm.wav",self:GetPos(),80,100)
end
local function MenuCloseSync(...)
	local args={...}
	local ply=args[1]
	local self=Entity(tonumber(args[3][1]))
	local Tag=ply:GetNetworkedInt("JackyIFFTag")
	if(Tag==0)then
		ply:PrintMessage(HUD_PRINTCENTER,"You don't have an IFF tag equipped.")
	elseif((self.IFFTags)and(table.HasValue(self.IFFTags,Tag)))then
		ply:PrintMessage(HUD_PRINTTALK,"IFF tag ID forgotten.")
		table.remove(self.IFFTags,table.KeyFromValue(self.IFFTags,Tag))
	else
		if not(Tag==0)then table.ForceInsert(self.IFFTags,Tag) end
		ply:PrintMessage(HUD_PRINTTALK,"IFF tag ID recorded.")
	end
	self.MenuOpen=false
end
concommand.Add("JackaWarMineSync",MenuCloseSync)
local function MenuCloseArm(...)
	local args={...}
	local self=Entity(tonumber(args[3][1]))
	self.MenuOpen=false
	if(self.BeginArming)then
		self:BeginArming()
	end
end
concommand.Add("JackaWarMineArm",MenuCloseArm)
local function MenuClose(...)
	local args={...}
	local self=Entity(tonumber(args[3][1]))
	self.MenuOpen=false
end
concommand.Add("JackaWarMineExit",MenuClose)