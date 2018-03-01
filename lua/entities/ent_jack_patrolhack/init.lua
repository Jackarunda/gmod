--patrolhack
--By Jackarunda
AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')
local _DEBUGMODE=true
local HULL_TARGETING={
	[HULL_TINY]=-3,
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
local PVS_NOTHING=0
local PVS_UNFOLDING=1
local PVS_HOVERING=2
local PVS_FOLDING=3
local PVS_RECHARGING=4
local PVS_SWIMMING=5
local BVS_NOTHING=0
local BVS_FOLLOWING=1
local BVS_SEARCHING=2
local BVS_PURSUING=3
local BVS_PATROLLING=4
local BVS_IDLING=5
local NatoAlphabet={"alpha","bravo","charlie","delta","echo","foxtrot","golf","hotel","india","juliet","kilo","lima","mike","november","oscar","papa","quebec","romeo","sierra","tango","uniform","victor","whiskey","xray","yankee","zulu"}
local GreekAlphabet={"alpha","beta","gamma","delta","epsilon","zeta","eta","theta","iota","kappa","lambda","mu","nu","xi","omicron","pi","rho","sigma","tau","upsilon","phi","chi","psi","omega"}
local Numbers={"one","two","three","four","five","six","seven","eight","nine","ten","eleven","twelve","thirteen","fourteen","fifteen","sixteen","seventeen","eighteen","nineteen","twenty"}
local NumbersInTens={"tenty","twenty","thirty","forty","fifty","sixty","seventy","eighty","ninety","hundred"}
ENT.AutomaticFrameAdvance=true 
ENT.PhysicalState=PVS_NOTHING
ENT.BehavioralState=BVS_NOTHING
ENT.NextSoundTime=0
ENT.DesiredPositionOverride=nil
ENT.Target=nil
ENT.Owner=nil
ENT.WillAlertOnFollowFind=false
ENT.PhrasesSaid=0
ENT.CombatReadiness=0
ENT.LightOn=false
ENT.NextTargetScanTime=0
ENT.NextFireTime=0
ENT.NextNoAmmoWhineTime=0
ENT.RoundsInMag=49
ENT.RoundInChamber=true
ENT.SweepPosition=nil
function ENT:SpawnFunction(ply,tr)
	local SpawnPos=tr.HitPos+tr.HitNormal*16
	local ent=ents.Create("ent_jack_patrolhack")
	ent:SetPos(SpawnPos)
	ent:Spawn()
	ent:Activate()
	local effectdata=EffectData()
	effectdata:SetEntity(ent)
	util.Effect("propspawn",effectdata)
	return ent
end
function ENT:Initialize()
	self.Entity:SetModel("models/manhack.mdl")
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)	
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.Entity:SetUseType(SIMPLE_USE)
	self.Entity:SetNoDraw(false)
	self.Entity:DrawShadow(true)
	local Phys=self.Entity:GetPhysicsObject()
	Phys:Wake()
	Phys:SetMass(20)
	Phys:SetDragCoefficient(.3)
	self:ManipulateBoneScale(13,Vector(2,2,2))
	self:ManipulateBoneScale(14,Vector(2,2,2))
	self:ManipulateBoneScale(2,Vector(.01,.01,.01))
	self:ManipulateBoneScale(9,Vector(.01,.01,.01))
	self:SetBodygroup(1,1)
	self:SetModelScale(.9,0)
	self:Animate("dead",1)
	self.ActiveHostiles={}
	self.PreviousBehavioralInfo={}
	self.CallSign={math.random(1,26),math.random(1,10),math.random(1,24)}
	if(_DEBUGMODE)then self:StartUp() end
end
function ENT:Use(activator)
	if(self.PhysicalState==PVS_NOTHING)then
		self:StartUp()
	end
end
function ENT:Think()
	local Phys=self:GetPhysicsObject()
	local Time=CurTime()
	local SelfPos=self:GetPos()
	local PState=self.PhysicalState
	local BState=self.BehavioralState
	self:SetDTInt(0,self.PhysicalState)
	local Up=self:GetUp()
	local Forward=self:GetForward()
	local Right=self:GetRight()
	local CurVel=Phys:GetVelocity()
	if((PState==PVS_HOVERING)or(PState==PVS_SWIMMING))then
		local TargPos=self:GetDesiredPosition()
		local TargetVel=self:GetDesiredVelocity(TargPos)
		local VelDiff=CurVel-TargetVel
		local SpdDiff=VelDiff:Length()
		local VelDiffDir=VelDiff:GetNormalized()
		SpdDiff=math.Clamp(SpdDiff,0,750)*.5
		VelDiff=VelDiffDir*SpdDiff
		--local Tilt=math.abs(Up:Dot(vector_up))
		Phys:AddAngleVelocity(-Phys:GetAngleVelocity()/2)
		Phys:ApplyForceOffset(Vector(0,0,14)-VelDiff/10,SelfPos+Up*100)
		Phys:ApplyForceOffset(Vector(0,0,-14)+VelDiff/10,SelfPos-Up*100)
		local Look=self:GetDesiredLookDirection()
		local LookRelDirAng=Look:Angle()
		local LocalLookRelDirAng=self:WorldToLocalAngles(LookRelDirAng)
		self:SetDTInt(1,LocalLookRelDirAng.p)
		local LookForce=2
		if(IsValid(self.Target))then
			LookForce=6
			if not(BState==BVS_PURSUING)then
				if(BState==BVS_FOLLOWING)then
					if(((self.Owner:GetPos()-self.Target:GetPos()):Length()>500)and(self.CombatReadiness==2))then
						self:BeginPursuit()
					end
				elseif(BState==BVS_PATROLLING)then
					if((self.SweepPosition-self.Target:GetPos()):Length()>500)then
						self:BeginPursuit()
					end
				end
			end
		end
		Phys:ApplyForceOffset(Look*LookForce,SelfPos+Forward*100)
		Phys:ApplyForceOffset(-Look*LookForce,SelfPos-Forward*100)
		Phys:ApplyForceCenter(VelDiff*-.5)
		--Phys:ApplyForceCenter(Up*365) --we already disabled gravity, CHEETAHS
		if(self.NextFireTime<Time)then
			self.NextFireTime=Time+1.25
			if(math.abs(LocalLookRelDirAng.y)<20)then
				self:FireAtTarget()
			end
		end
		if(self.NextSoundTime<Time)then
			self.NextSoundTime=Time+.49
			self:EmitSound("snd_jack_heli"..tostring(math.random(1,7))..".wav",70,100)
		end
		if(self.LightOn)then
			local Shine=EffectData()
			Shine:SetOrigin(SelfPos-Up*7)
			Shine:SetScale(1)
			util.Effect("eff_jack_dronelight",Shine,true,true)
		end
		if(self.NextTargetScanTime<Time)then
			self.NextTargetScanTime=Time+.1
			self.Target=self:ScanForTarget()
		end
	end
	self:NextThink(Time+.025)
	return true
end
function ENT:BeginPursuit()
	self.BehavioralState=BVS_PURSUING
	self:Speak({"pursuing"})
end
function ENT:FireAtTarget()
	if not(IsValid(self.Target))then return end
	if not(self:Visible(self.Target))then return end
	if(self.RoundInChamber)then
		local SelfPos=self:GetPos()
		local TargPos=self:GetAimPosForTarget()
		local Dir=(TargPos-SelfPos):GetNormalized()
		local Phys=self.Target:GetPhysicsObject()
		local Bellit={
			Attacker=self.Entity,
			Damage=10,
			Force=5,
			Num=1,
			Tracer=0,
			Dir=Dir,
			Spread=Vector(.05,.05,.05),
			Src=SelfPos
		}
		self:FireBullets(Bellit)
		self.RoundInChamber=false
		local Scayul=.5
		sound.Play("snd_jack_turretshootshort_close.wav",SelfPos,75,125)
		sound.Play("snd_jack_turretshootshort_far.wav",SelfPos+Vector(0,0,1),90,115)
		local effectd=EffectData()
		effectd:SetStart(SelfPos+Dir*10)
		effectd:SetNormal(Dir)
		effectd:SetScale(1)
		util.Effect("eff_jack_turretmuzzle",effectd,true,true)
		local effectdata=EffectData()
		effectdata:SetOrigin(SelfPos)
		effectdata:SetAngles(self:GetRight():Angle())
		effectdata:SetEntity(self)
		util.Effect("ShellEject",effectdata,true,true)
		self:GetPhysicsObject():ApplyForceOffset(-Dir*100,SelfPos-self:GetUp()*20)
		if(self.RoundsInMag>0)then
			self.RoundsInMag=self.RoundsInMag-1
			self.RoundInChamber=true
		end
	else
		self:EmitSound("snd_jack_turretclick.wav",70,130)
		if(self.NextNoAmmoWhineTime<CurTime())then
			self.NextNoAmmoWhineTime=CurTime()+2.5
			self:Speak({"no","ammunition"})
		end
	end
end
function ENT:ScanForTarget()
	if(self.BehavioralState==BVS_SEARCHING)then return nil end
	local SelfPos=self:GetPos()
	local BestCandidate=nil
	local ScanPos=self.SweepPosition
	local ScanRange=1750
	if((self.BehavioralState==BVS_FOLLOWING)or(self.BehavioralState==BVS_PURSUING))then
		ScanPos=self.Owner:GetShootPos()
		if(self.CombatReadiness==1)then
			ScanRange=200
		elseif(self.CombatReadiness==2)then
			ScanRange=1250
		end
	end
	local Closest=ScanRange
	for key,potential in pairs(ents.FindInSphere(ScanPos,ScanRange))do
		local HullType=nil
		if(potential:IsPlayer())then --why the fuck doesn't GetConVar("ai_ignoreplayers") work
			HullType=0
		elseif(potential:IsNPC())then
			HullType=potential:GetHullType()
		end
		local Class=potential:GetClass()
		if(((potential:IsNPC())or(potential:IsPlayer()))and not((potential==self)or(potential==self.Owner)))then
			if(self:Visible(potential))then
				if not((potential:IsPlayer())and not(potential:Alive()))then
					print(tostring(CurTime()).." tried for "..tostring(potential))
					if(self:TargetMovin(potential))then
						print(tostring(CurTime()).." got "..tostring(potential))
						local TargPos=potential:GetPos()
						local Dist=(TargPos-SelfPos):Length()
						if(Dist<Closest)then
							BestCandidate=potential
							Closest=Dist
						end
					end
				end
			end
		end
	end
	if(self.CombatReadiness>0)then
		return BestCandidate
	else
		return nil
	end
end
function ENT:TargetMovin(targ)
	local SelfVel=self:GetPhysicsObject():GetVelocity()
	local TargVel=targ:GetVelocity()
	local Phys=targ:GetPhysicsObject()
	if(IsValid(Phys))then TargVel=Phys:GetVelocity() end
	local TWDiff=(TargVel):Length()
	local TSDiff=(TargVel-SelfVel):Length()
	if((self.BehavioralState==BVS_FOLLOWING)or(self.BehavioralState==BVS_PURSUING))then
		local OwnVel=self.Owner:GetVelocity()
		local TODiff=(TargVel-OwnVel):Length()
		return ((TODiff>10)and(TSDiff>10)and(TWDiff>10))
	elseif(self.BehavioralState==BVS_PATROLLING)then
		return ((TSDiff>10)and(TWDiff>10))
	end
	return false
end
function ENT:GetDesiredPosition()
	if(self.DesiredPositionOverride)then return self.DesiredPositionOverride end
	local SelfPos=self:GetPos()
	local BState=self.BehavioralState
	if((BState==BVS_FOLLOWING)or(BState==BVS_SEARCHING))then
		if(IsValid(self.Owner))then
			local OwnPos=self.Owner:GetShootPos()
			local OwnVec=self.Owner:GetAimVector()
			local OwnVel=self.Owner:GetVelocity()
			local Pos=OwnPos-OwnVec*20+Vector(0,0,75)
			if not(self:ClearBetween(self.Owner,Pos))then Pos=OwnPos+Vector(0,0,30)-OwnVec*10 end
			if(self:ClearBetween(self,Pos))then
				if(BState==BVS_SEARCHING)then
					self.BehavioralState=BVS_FOLLOWING
					if(self.WillAlertOnFollowFind)then
						self:Speak({"follow","target","found"})
						self.WillAlertOnFollowFind=false
					end
				end
				return Pos
			else
				self:SearchForFollowTarget(Pos)
			end
		else
			self.Owner=nil
			self.BehavioralState=BVS_IDLING
		end
	elseif(BState==BVS_PURSUING)then
		if(IsValid(self.Owner))then
			if(IsValid(self.Target))then
				local OwnPos=self.Owner:GetShootPos()
				local TargPos=self.Target:GetPos()
				local ToVec=(TargPos-OwnPos)
				return OwnPos+ToVec/2
			else
				self.Target=nil
				self.BehavioralState=BVS_FOLLOWING
			end
		else
			self.Owner=nil
			self.BehavioralState=BVS_IDLING
		end
	end
	return SelfPos
end
function ENT:SearchForFollowTarget(pos)
	local SelfPos=self:GetPos()
	if not(self.BehavioralState==BVS_SEARCHING)then
		self.BehavioralState=BVS_SEARCHING
		timer.Simple(3,function()
			if((IsValid(self))and(self.BehavioralState==BVS_SEARCHING))then
				self:Speak({"follow","target","lost",",","searching"})
				self.WillAlertOnFollowFind=true
			end
		end)
	end
	local Dist=(SelfPos-pos):Length()
	for i=1,20 do
		local Travel=math.Rand(1,Dist)
		local RandomPos=SelfPos+VectorRand()*Travel
		if((self:ClearBetween(self,RandomPos))and(self:KleerButween(pos,RandomPos)))then
			self.DesiredPositionOverride=RandomPos
			timer.Simple(Travel/200,function()
				if(IsValid(self))then
					self.DesiredPositionOverride=nil
				end
			end)
			return RandomPos
		end
	end
end
function ENT:GetDesiredVelocity(pos)
	local SelfPos=self:GetPos()
	local DesVec=(pos-SelfPos)
	local DesDir=DesVec:GetNormalized()
	local DesSpd=DesVec:Length()
	return DesDir*DesSpd^2/100
end
function ENT:GetDesiredLookDirection()
	local SelfPos=self:GetPos()
	local BState=self.BehavioralState
	if((BState==BVS_FOLLOWING)or(BState==BVS_PURSUING))then
		if(IsValid(self.Owner))then
			local OwnPos=self.Owner:GetShootPos()
			if not(IsValid(self.Target))then
				return (OwnPos-SelfPos):GetNormalized()
			else
				return (self:GetAimPosForTarget()-SelfPos):GetNormalized()
			end
		else
			self.BehavioralState=BVS_IDLING
			self.Owner=nil
		end
	end
	return self:GetForward()
end
function ENT:GetAimPosForTarget()
	local ent=self.Target
	local Pos=ent:LocalToWorld(ent:OBBCenter())
	local Hull
	if not(ent.GetHullType)then
		Hull=HULL_HUMAN
	else
		Hull=ent:GetHullType()
	end
	JPrint(Hull)
	local Add=Vector(0,0,HULL_TARGETING[Hull])
	Pos=Pos+Add
	if((ent:IsPlayer())and(ent:Crouching()))then
		Pos=Pos-Vector(0,0,20)
	end
	return Pos
end
function ENT:Animate(anim,spd)
	self:ResetSequence(self:LookupSequence(anim))
	self:SetPlaybackRate(spd)
end
function ENT:Wanimate(anim,spd)
	timer.Simple(self:SequenceDuration(),function()
		if(IsValid(self))then
			self:Animate(anim,spd)
		end
	end)
end
function ENT:Tanimate(dly,anim,spd)
	timer.Simple(dly,function()
		if(IsValid(self))then
			self:Animate(anim,spd)
		end
	end)
end
function ENT:StartUp()
	self.PhysicalState=PVS_UNFOLDING
	self.BehavioralState=BVS_IDLING
	self:Animate("PanelPoses",.5)
	if(_DEBUGMODE)then self.Owner=player.GetAll()[1] end
	timer.Simple(3,function()
		if(IsValid(self))then
			self:SetBodygroup(2,1)
			self:SetBodygroup(1,0)
			self.PhysicalState=PVS_HOVERING
			if(_DEBUGMODE)then
				self.BehavioralState=BVS_FOLLOWING
				self.CombatReadiness=2
			end
			self:Animate("fly",7)
			self:Speak({"unit",NatoAlphabet[self.CallSign[1]],Numbers[self.CallSign[2]],GreekAlphabet[self.CallSign[3]],"online"})
			self:GetPhysicsObject():EnableGravity(false)
			if((self.PreviousBehavioralInfo)and(table.maxn(self.PreviousBehavioralInfo)>0))then
				self.BehavioralState=self.PreviousBehavioralInfo[1]
				self.Owner=self.PreviousBehavioralInfo[2]
				self.Target=self.PreviousBehavioralInfo[3]
			end
		end
	end)
end
function ENT:ShutDown()
	self.PreviousBehavioralInfo={self.BehavioralState,self.Owner,self.Target}
	self.PhysicalState=PVS_FOLDING
	self.BehavioralState=BVS_IDLING
	self:Animate("PanelPoses",-.5)
	self:GetPhysicsObject():EnableGravity(true)
	timer.Simple(1,function()
		if(IsValid(self))then
			self:SetBodygroup(2,0)
			self:SetBodygroup(1,1)
			self.PhysicalState=PVS_NOTHING
			self.BehavioralState=PVS_NOTHING
			self:Animate("dead",1)
		end
	end)
end
function ENT:ClearBetween(ent,pos)
	local TrDat={}
	TrDat.start=ent:LocalToWorld(ent:OBBCenter())
	TrDat.endpos=pos
	TrDat.filter={ent,self,self.Owner,self.Target}
	return (!util.TraceLine(TrDat).Hit)
end
function ENT:KleerButween(posOne,posTwo)
	local TrDat={}
	TrDat.start=posOne
	TrDat.endpos=posTwo
	TrDat.filter={self,self.Owner,self.Target}
	return (!util.TraceLine(TrDat).Hit)
end
function ENT:GetNewMaster(ply)
	self.Owner=ply
	self.BehavioralState=BVS_IDLING
	self:Speak({"acknowledged"})
end
function ENT:BeginFollowing()
	self.BehavioralState=BVS_FOLLOWING
	self:Speak({"roger","following"})
end
function ENT:ChangeCombatReadiness(red)
	self.CombatReadiness=red
	if(red==0)then
		self:Speak({"roger","standing","down"})
	elseif(red==1)then
		self:Speak({"roger","protecting"})
	elseif(red==2)then
		self:Speak({"roger","going","loud"})
	end
end
function ENT:ToggleLight(tog)
	if(self.LightOn)then
		if not(tog)then
			self:Speak({"roger","light","off"})
		end
	else
		if(tog)then
			self:Speak({"roger","light","on"})
		end
	end
	self.LightOn=tog
end
function ENT:Speak(words)
	self.PhrasesSaid=self.PhrasesSaid+1
	local ThisPhrase=self.PhrasesSaid
	self.MostRecentSpeech=table.Copy(words)
	self:Say("snd_jack_dronebeep.wav")
	local Delay=.25
	for key,word in pairs(words)do
		if(type(word)=="string")then
			local ProperWord="snds_jack_autovoice/"..word..".wav"
			local Len=SoundDuration(ProperWord)
			timer.Simple(Delay,function()
				if((IsValid(self))and(self.PhrasesSaid==ThisPhrase))then
					self:Say(ProperWord)
				end
			end)
			Delay=Delay+Len+.01
		elseif(type(word)=="number")then
			for key,werd in pairs(self:NumberToWords(word))do
				local ProperWerd="snds_jack_autovoice/"..werd..".wav"
				local Len=SoundDuration(ProperWerd)
				timer.Simple(Delay,function()
					if((IsValid(self))and(self.PhrasesSaid==ThisPhrase))then
						self:Say(ProperWerd)
					end
				end)
				Delay=Delay+Len+.01
			end
		end
	end
end
function ENT:NumberToWords(num) -- only accepts integers from zero to a thousand
	if(num==0)then
		return {"zero"}
	elseif(num<21)then
		return {Numbers[num]}
	elseif(num<100)then
		return {NumbersInTens[math.floor(num/10)],Numbers[num%10]}
	elseif(num==100)then
		return {"one","hundred"}
	elseif(num<1000)then
		return {Numbers[math.floor(num/100)],"hundred",NumbersInTens[math.floor((num%100)/10)],Numbers[num%10]}
	end
end
function ENT:Say(snd)
	if(IsValid(self.Owner))then
		local Dist=(self:GetPos()-self.Owner:GetShootPos()):Length()
		if(Dist<100)then
			self:EmitSound(snd,60,100)
			sound.Play(snd,self.Owner:GetShootPos(),40,100)
			return
		end
	end
	self:EmitSound(snd,70,100)
	self:EmitSound(snd,40,100)
end
function ENT:RepeatSpeak()
	self.PhrasesSaid=self.PhrasesSaid+1
	local ThisPhrase=self.PhrasesSaid
	self:Say("snd_jack_dronebeep.wav")
	local words=table.Copy(self.MostRecentSpeech)
	table.insert(words,1,",")
	table.insert(words,1,"repeating")
	local Delay=.25
	for key,word in pairs(words)do
		local ProperWord="snds_jack_autovoice/"..word..".wav"
		local Len=SoundDuration(ProperWord)
		timer.Simple(Delay,function()
			if((IsValid(self))and(self.PhrasesSaid==ThisPhrase))then
				self:Say(ProperWord)
			end
		end)
		Delay=Delay+Len+.01
	end
end
function ENT:Listen(ply,tlk)
	if(self.PhysicalState==PVS_NOTHING)then return end
	if(self.BehavioralState==BVS_NOTHING)then return end
	local Dist=(self:GetPos()-ply:GetPos()):Length()
	if(Dist>500)then return end
	local Str=string.lower(tlk)
	if not(string.sub(Str,1,6)=="drone,")then return end
	Str=string.sub(Str,7)
	if(IsValid(self.Owner))then
		if(string.find(Str,"follow"))then
			self:BeginFollowing()
		elseif(string.find(Str,"say again"))then
			self:RepeatSpeak()
		elseif(string.find(Str,"report callsign"))then
			self:Speak({"callsign",NatoAlphabet[self.CallSign[1]],Numbers[self.CallSign[2]],GreekAlphabet[self.CallSign[3]]})
		elseif(string.find(Str,"go loud"))then
			self:ChangeCombatReadiness(2)
		elseif(string.find(Str,"protect"))then
			self:ChangeCombatReadiness(1)
		elseif(string.find(Str,"stand down"))then
			self:ChangeCombatReadiness(0)
		elseif(string.find(Str,"light on"))then
			self:ToggleLight(true)
		elseif(string.find(Str,"light off"))then
			self:ToggleLight(false)
		elseif(string.find(Str,"report ammo"))then
			self:Speak({"ammunition",self.RoundsInMag,"rounds"})
		end
	else
		if((string.find(Str,NatoAlphabet[self.CallSign[1]]))and(string.find(Str,Numbers[self.CallSign[2]]))and(string.find(Str,GreekAlphabet[self.CallSign[3]])))then
			if(string.find(Str,"on me"))then
				self:GetNewMaster(ply)
			end
		elseif(string.find(Str,"report callsign"))then
			self:Speak({"callsign",NatoAlphabet[self.CallSign[1]],Numbers[self.CallSign[2]],GreekAlphabet[self.CallSign[3]]})
		end
	end
end
local function ChatListen(ply,txt)
	timer.Simple(.25,function()
		if(IsValid(ply))then
			for key,drone in pairs(ents.FindByClass("ent_jack_patrolhack"))do
				drone:Listen(ply,txt)
			end
		end
	end)
end
hook.Add("PlayerSay","JackyDroneChatListen",ChatListen)
--[[
--ANIMS--
0	idle
1	fly
2	fly2
3	fly3
4	Deploy
5	dead
6	panel1
7	panel2
8	panel3
9	panel4
10	pincertop
11	pincerbottom
12	PanelPoses
13	ragdoll
--BONES--
0	Manhack.MH_Control
1	Manhack.MH_ControlBodyUpper
2	Manhack.MH_ControlPincerTop
3	Manhack.MH_ControlPanel6
4	Manhack.MH_ControlPanel1
5	Manhack.MH_ControlPanel2
6	Manhack.MH_ControlPanel3
7	Manhack.MH_ControlExhaust
8	Manhack.MH_ControlBodyLower
9	Manhack.MH_ControlPincerBottom
10	Manhack.MH_ControlPanel4
11	Manhack.MH_ControlPanel5
12	Manhack.MH_ControlCamera
13	Manhack.MH_ControlBlade
14	Manhack.MH_ControlBlade1
--]]