AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')
ENT.Base="ent_jack_turret_base"
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
ENT.TargetDrones=true
ENT.TrackRate=.4
ENT.MaxTrackRange=35000
ENT.FireRate=2
ENT.ShotPower=150
ENT.ScanRate=.75
ENT.ShotSpread=.017
ENT.RoundsOnBelt=0
ENT.RoundInChamber=false
ENT.MaxCharge=3000
ENT.ShellEffect="RifleShellEject"
ENT.ProjectilesPerShot=1
ENT.TurretSkin="models/mat_jack_missileturret"
ENT.ShotPitch=100
ENT.NearShotNoise="snd_jack_turretmissilelaunch_close.wav"
ENT.FarShotNoise="snd_jack_turretmissilelaunch_far.wav"
ENT.AmmoType="AAmissile"
ENT.Automatic=true
ENT.MuzzEff="muzzle_center_M82"
ENT.BarrelSizeMod=Vector(.01,.01,.01)
ENT.Autoloading=false
ENT.CycleSound="snd_jack_glcycle.wav"
ENT.MechanicsSizeMod=2.2
ENT.TargetOrganics=false
ENT.TargetSynthetics=true
ENT.MissileLocked=false
function ENT:SpawnFunction(ply,tr)
	local SpawnPos=tr.HitPos+tr.HitNormal*16
	local ent=ents.Create("ent_jack_turret_missile")
	ent:SetPos(SpawnPos)
	ent:SetNetworkedEntity("Owenur",ply)
	ent.TargetingGroup={5,9,7,8}
	ent:Spawn()
	ent:Activate()
	local effectdata=EffectData()
	effectdata:SetEntity(ent)
	util.Effect("propspawn",effectdata)
	//HA GARRY I FUCKING BEAT YOU AND YOUR STUPID RULES
	local Settings=physenv.GetPerformanceSettings()
	if(Settings.MaxVelocity<7500)then
		Settings.MaxVelocity=7500
	end
	physenv.SetPerformanceSettings(Settings)
	return ent
end
local function GetCenterMass(ent)
	if not(IsValid(ent))then return Vector(0,0,0) end
	local Pos=ent:LocalToWorld(ent:OBBCenter())
	local Hull
	if not(ent.GetHullType)then
		Hull=HULL_HUMAN
	else
		Hull=ent:GetHullType()
	end
	local Add=Vector(0,0,HULL_TARGETING[Hull])
	if((string.find(ent:GetClass(),"vehicle",1,false))or(string.find(ent:GetClass(),"car",1,false))or(string.find(ent:GetClass(),"hoverball",1,false))or(string.find(ent:GetClass(),"thruster",1,false)))then
		Add=Vector(0,0,0)
	end
	Pos=Pos+Add
	if((ent:IsPlayer())and(ent:Crouching()))then
		Pos=Pos-Vector(0,0,20)
	end
	return Pos
end
function ENT:FireShot()
	if(self.MissileLocked)then return end
	if((not(IsValid(self.CurrentTarget)))and(not(self.ControllingPly)))then self:StandBy() return end
	self.BatteryCharge=self.BatteryCharge-.1
	if((self.WillWarn)and not(self.ControllingPly))then
		if not(self.NextAlrightFuckYouTime<CurTime())then
			if(self.NextWarnTime<CurTime())then
				self:HostileAlert()
				self.NextWarnTime=CurTime()+1
			end
			return
		end
	end
	if(self.RoundInChamber)then
		local LockChance=.25
		if(math.Rand(0,1)<LockChance)then
			if(self.ControllingPly)then
				local Ent=util.QuickTrace(self:GetShootPos(),self:GetAttachment(1).Ang:Forward()*40000,{self}).Entity
				if((IsValid(Ent))and not(Ent:IsWorld()))then
					self.CurrentTarget=Ent
					self:EmitSound("snd_jack_missilelock.wav",75,100)
					self.MissileLocked=true
					timer.Simple(1,function()
						if(IsValid(self))then
							if(IsValid(self.CurrentTarget))then
								self:FireMissal()
							end
							self.MissileLocked=false
						end
					end)
				end
			else
				if(IsValid(self.CurrentTarget))then
					self:EmitSound("snd_jack_missilelock.wav",75,100)
					self.MissileLocked=true
					timer.Simple(1,function()
						if(IsValid(self))then
							if(IsValid(self.CurrentTarget))then
								self:FireMissal()
							end
							self.MissileLocked=false
						end
					end)
				end
			end
		else
			self:EmitSound("snd_jack_missilesearch.wav",75,100)
			self.BatteryCharge=self.BatteryCharge-15
		end
	else
		if(self.NextWhineTime<CurTime())then
			self:Whine()
			self.NextWhineTime=CurTime()+2.25
		end
	end
end
function ENT:FireMissal()
	local SelfPos=self:GetPos()+self:GetUp()*55
	local TargPos=GetCenterMass(self.CurrentTarget)
	local Dist=(self:GetPos()-self.CurrentTarget:GetPos()):Length()
	if(Dist<=1250)then
		self:HostileAlert()
		self.MissileLocked=false
		return
	end
	TargPos=TargPos+Vector(0,0,Dist/60)
	local Vec=(TargPos-SelfPos)
	local Dir=Vec:GetNormalized()
	Dir=(Dir+Vector(0,0,.5)):GetNormalized()
	local Spred=self.ShotSpread
	--fire round
	local Miss=ents.Create("ent_jack_turretmissile")
	Miss.ParentLauncher=self.Entity
	Miss:SetNetworkedEntity("Owenur",self.Entity)
	Miss:SetPos(SelfPos-self:GetRight()*5)
	local Ang=Dir:Angle()
	Ang:RotateAroundAxis(Ang:Up(),90)
	Miss:SetAngles(Ang)
	Miss.InitialAng=Ang
	Miss.Target=self.CurrentTarget -- go get em tiger
	Miss:Spawn()
	Miss:Activate()
	constraint.NoCollide(self.Entity,Miss)
	Miss:GetPhysicsObject():SetVelocity(self:GetPhysicsObject():GetVelocity()+Dir*400)
	self.FiredAtCurrentTarget=true
	self.RoundInChamber=false
	self.NextNoMovementCheckTime=CurTime()+5
	self:SetDTBool(2,self.RoundInChamber)
	self.RoundsOnBelt=0
	local Scayul=2
	sound.Play(self.NearShotNoise,SelfPos,70,self.ShotPitch)
	sound.Play(self.FarShotNoise,SelfPos+Vector(0,0,1),90,self.ShotPitch-10)
	sound.Play(self.NearShotNoise,SelfPos,75,self.ShotPitch)
	sound.Play(self.FarShotNoise,SelfPos+Vector(0,0,2),110,self.ShotPitch-10)
	local PosAng=self:GetAttachment(1)
	PosAng.Ang:RotateAroundAxis(PosAng.Ang:Right(),30)
	local ThePos=PosAng.Pos+PosAng.Ang:Forward()*25
	ParticleEffect(self.MuzzEff,ThePos,PosAng.Ang,self)
	local effectd=EffectData()
	effectd:SetStart(ThePos)
	effectd:SetNormal(PosAng.Ang:Forward())
	effectd:SetScale(1)
	util.Effect("eff_jack_turretmuzzlelight",effectd,true,true)
	PosAng.Ang:RotateAroundAxis(PosAng.Ang:Right(),180)
	ThePos=PosAng.Pos+PosAng.Ang:Forward()*40
	ParticleEffect(self.MuzzEff,ThePos,PosAng.Ang,self)
	local effectd=EffectData()
	effectd:SetStart(ThePos)
	effectd:SetNormal(PosAng.Ang:Forward())
	effectd:SetScale(1)
	util.Effect("eff_jack_turretmuzzlelight",effectd,true,true)
	util.BlastDamage(self.Entity,self.Entity,SelfPos-Dir*50,20,20)
	self:GetPhysicsObject():ApplyForceOffset(-Dir*self.ShotPower*6*self.ProjectilesPerShot,SelfPos+self:GetUp()*20)
end
function ENT:DetachAmmoBox()
	self.RoundsOnBelt=0
	self.HasAmmoBox=false
	self:SetDTBool(0,self.HasAmmoBox)
	local Box=ents.Create("ent_jack_turretmissilepod")
	Box.AmmoType=self.AmmoType
	Box.Empty=true
	Box:SetPos(self:GetPos()-self:GetRight()*10+self:GetUp()*30-self:GetForward()*10)
	Box:SetAngles(self:GetUp():Angle())
	Box:Spawn()
	Box:Activate()
	Box:GetPhysicsObject():SetVelocity(self:GetPhysicsObject():GetVelocity()-self:GetForward()*20-self:GetRight()*20)
	self:EmitSound("snd_jack_missileunload.wav")
	SafeRemoveEntityDelayed(Box,30)
end
function ENT:RefillAmmo(box)
	self.HasAmmoBox=true
	self:SetDTBool(0,self.HasAmmoBox)
	self.RoundInChamber=true
	self:SetDTBool(2,self.RoundInChamber)
	self.RoundsOnBelt=1
	self:EmitSound("snd_jack_missileload.wav")
	SafeRemoveEntity(box)
end