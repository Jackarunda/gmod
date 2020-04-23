SWEP.Base="wep_jack_fungun_base_master"

if(SERVER)then
	AddCSLuaFile("shared.lua")
end

if(CLIENT)then
	SWEP.PrintName="Handgun Beta"
	SWEP.Slot=1
	SWEP.WepSelectIcon=surface.GetTextureID("vgui/mat_jack_fgbeta_wsi")
	killicon.Add("wep_jack_fungun_beta","vgui/mat_jack_fgbeta_ki",Color(255,255,255,255))
end

SWEP.ViewModelFOV=70
SWEP.ViewModelFlip=false
SWEP.ViewModel="models/weapons/v_halo_jeagle.mdl"
SWEP.WorldModel="models/weapons/w_357.mdl"
SWEP.SwayScale=1.75
SWEP.BobScale=1.75

function SWEP:FrontSight()
	if not(self.DisplaysOn)then return end
	local Flicker=math.Rand(.5,1)
	if(self.dt.Ammo<.01)then Flicker=math.Rand(0,.5) end
	surface.DrawCircle(20,41,360,Color(255,255,255,175*Flicker))
end
function SWEP:RearSight()
	if not(self.DisplaysOn)then return end
	local Flicker=math.Rand(.5,1)
	if(self.dt.Ammo<.01)then Flicker=math.Rand(0,.5) end
	surface.DrawCircle(20,25,145,Color(255,255,255,150*Flicker))
end

SWEP.SuitableTargetMaterialTable={"flesh","roller","metal","computer","metalpanel","canister","floating_metal_barrel","metal_barrel","chainlink","weapon","solidmetal"}

SWEP.SprintPos=Vector(2.539,-14.44,-0.441)
SWEP.SprintAng=Angle(74,-7,0)
SWEP.AimPos=Vector(-2.76, 2,-.5)
SWEP.AimAng=Angle(1.2,-3.5,0)
SWEP.ShowWorldModel=false
SWEP.ReloadNoise={"snd_jack_arcreload.wav",70,100}
SWEP.ViewModelBoneMods={
	["Main Frame"]={ scale=Vector(0.009, 0.009, 0.009), pos=Vector(0, 0, 0), angle=Angle(0, 0, 0) }
}
SWEP.VElements={
	["hurr"]={ type="Quad", bone="Main Frame", rel="", pos=Vector(-1.35, -.25, 1.5), angle=Angle(0, -90, 60.34), size=0.025, draw_func=JackIndFunGunAmmoDisplay},
	["lawl"]={ type="Model", model="models/hunter/blocks/cube025x125x025.mdl", bone="Main Frame", rel="", pos=Vector(8.199, -1.1, -0.601), angle=Angle(0, 0, 0), size=Vector(0.1, 0.052, 0.059), color=Color(255, 255, 255, 255), surpresslightning=true, material="models/debug/debugwhite", skin=0, bodygroup={} },
	["narg"]={ type="Model", model="models/mass_effect_3/weapons/misc/jeatsink.mdl", bone="Main Frame", rel="", pos=Vector(5, -.16, .15), angle=Angle(0, 90, -66.477), size=Vector(1, 1, 1), color=Color(255, 255, 255, 255), surpresslightning=true, material="models/debug/debugwhite", skin=0, bodygroup={} },
	["lol"]={ type="Model", model="models/mass_effect_3/weapons/pistols/arc jistol.mdl", bone="Main Frame", rel="", pos=Vector(0.2, -0.101, 1), angle=Angle(0, 90, 0), size=Vector(1, 1, 1), color=Color(255, 255, 255, 255), surpresslightning=false, material="", skin=0, bodygroup={} },
	["derp"]={ type="Model", model="models/hunter/blocks/cube025x125x025.mdl", bone="Slide", rel="", pos=Vector(9.149, -1.08, -1.9), angle=Angle(0, 0, 0), size=Vector(0.09, 0.05, 0.05), color=Color(255, 255, 255, 255), surpresslightning=false, material="debug/env_cubemap_model", skin=0, bodygroup={} },
	["herp"]={ type="Model", model="models/mass_effect_3/weapons/misc/jeatsink.mdl", bone="Mag", rel="", pos=Vector(0.1, 0, 2), angle=Angle(180, 90, 81), size=Vector(1.299, 0.699, 1), color=Color(255, 255, 255, 255), surpresslightning=false, material="", skin=0, bodygroup={} },
	["herpitty"]={ type="Quad", bone="Main Frame", rel="", pos=Vector(10, -.48, 3.75), angle=Angle(0, -90, 90), size=0.025, draw_func=SWEP.FrontSight},
	["derpitty"]={ type="Quad", bone="Main Frame", rel="", pos=Vector(-7, -.45, 3.5), angle=Angle(0, -90, 90), size=0.025, draw_func=SWEP.RearSight}
}
SWEP.WElements={
	["lol"]={ type="Model", model="models/mass_effect_3/weapons/pistols/arc jistol.mdl", bone="ValveBiped.Bip01_R_Hand", rel="", pos=Vector(3.181, 1.363, -3.182), angle=Angle(180, 90, 0), size=Vector(1, 1, 1), color=Color(255, 255, 255, 255), surpresslightning=false, material="", skin=0, bodygroup={} }
}

local AlreadyFired=false
local BurstCoolSoundPlayed=false
local AlertSoundPlayed=false

function SWEP:Initialize()
	self:SetWeaponHoldType("revolver")
	self.ChargingSound=CreateSound(self.Weapon,"snd_jack_chargeloop.wav")
	self.ChargingSound:SetSoundLevel(60)
	self.CurrentCapacitorCharge=0
	self.NewCartridge=true
	self.dt.Ammo=1.005
	
	self:SCKInitialize()
end

function SWEP:SetupDataTables()
	self:DTVar("Int",0,"State") -- 1=drawing, 2=idle, 3=charging, 4=venting, 5=reloading, 6=holstered
	self:DTVar("Float",0,"Heat")
	self:DTVar("Float",1,"Ammo")
	self:DTVar("Int",1,"Sprint")
	self:DTVar("Int",2,"Aim")
end

function SWEP:Deploy()
	GlobalJackyFGHGDeploy(self)
end

function SWEP:PrimaryAttack()
	if(self.Owner:WaterLevel()==3)then
		self.Weapon:EmitSound("snd_jack_arcgunwarn.wav")
		return
	end
	if(self.dt.Sprint>10)then return end
	if not(self.dt.State==2)then return end
	if(self.dt.Ammo<=0)then return end
	self:SetNextPrimaryFire(CurTime()+.025)
	local ShootPos=self.Owner:GetShootPos()+self.Owner:GetAimVector()*20
	if(self.CurrentCapacitorCharge==0)then if(SERVER)then self:EmitSound("snd_jack_chargebegin.wav",60,100) end end
	self.ChargingSound:Play()
	self.dt.State=3
	if(self.CurrentCapacitorCharge<1)then self.CurrentCapacitorCharge=1 end
	self.NextChargingSoundTime=CurTime()+2
	AlreadyFired=false
	BurstCoolSoundPlayed=false
end

function SWEP:FireElectricity()
	if(self.Owner:KeyDown(IN_SPEED))then self.dt.State=2 return end
	if((self.PowerType=="Radiosotope Thermoelectric Generator/Battery Module")and(self.dt.Ammo<.03))then self.dt.State=2 return end
	if(AlreadyFired)then return end
	AlreadyFired=true
	self.dt.State=2

	local AimVec=self.Owner:GetAimVector()
	local Pos,Ang=self.Owner:GetBonePosition(self.Owner:LookupBone("ValveBiped.Bip01_R_Hand"))
	local SelfPos=Pos+AimVec*15
	
	local TrDat={start=self.Owner:GetShootPos(),endpos=SelfPos,filter=self.Owner}
	local Tr=util.TraceLine(TrDat)
	if(Tr.Hit)then return end
	
	local PotentialTargets={}
	for key,thing in pairs(ents.FindInSphere(SelfPos,850))do
		local PhysObj=thing:GetPhysicsObject()
		local WillAdd=false
		if(((thing:IsNPC())or(thing:IsPlayer()))and not(thing==self.Owner))then
			local Health=thing:Health()
			if not(thing:GetClass()=="npc_bullseye")then
				if(Health)then
					if(Health>0)then
						WillAdd=true
					end
				else
					WillAdd=true
				end
			end
		elseif(IsValid(PhysObj))then
			if((table.HasValue(self.SuitableTargetMaterialTable,PhysObj:GetMaterial()))or(thing:GetClass()=="ent_jack_target"))then
				WillAdd=true
			end
		elseif(thing:GetClass()=="prop_ragdoll")then
			WillAdd=true
		end
		if(WillAdd)then
			local TargetPos=thing:LocalToWorld(thing:OBBCenter())
			local TrDat={}
			TrDat.start=SelfPos
			TrDat.endpos=TargetPos
			TrDat.filter={self.Owner,thing}
			local Tr=util.TraceLine(TrDat)
			if not(Tr.Hit)then
				local ToVector=(TargetPos-SelfPos):GetNormalized()
				local DotProduct=ToVector:DotProduct(AimVec)
				local AngleDifference=(-math.deg(math.asin(DotProduct)))
				if(AngleDifference<-60)then
					table.ForceInsert(PotentialTargets,thing)
				end
			end
		end
	end
	local ClosestDistance=99999
	local Target=nil
	for key,thing in pairs(PotentialTargets)do
		local Dist=(thing:GetPos()-SelfPos):Length()
		if(Dist<ClosestDistance)then
			ClosestDistance=Dist
			Target=thing
		end
	end
	if(IsValid(Target))then
		local KaZap=DamageInfo()
		KaZap:SetDamage(self.CurrentCapacitorCharge*2*math.Rand(.9,1.1))
		KaZap:SetDamagePosition(Target:LocalToWorld(Target:OBBCenter()))
		KaZap:SetDamageType(DMG_SHOCK)
		KaZap:SetAttacker(self.Owner)
		KaZap:SetInflictor(self.Weapon)
		KaZap:SetDamageForce(Vector(0,0,self.CurrentCapacitorCharge*500))
		Target.JustGotZapped=true
		Target:TakeDamageInfo(KaZap)
		
		if((Target:IsPlayer())or(Target:IsNPC()))then
			if(math.random(1,200)<self.CurrentCapacitorCharge)then
				Target:Ignite(self.CurrentCapacitorCharge/10)
			end
		end
		
		timer.Simple(1,function()
			if(IsValid(Target))then
				Target.JustGotZapped=false
			end
		end)
		
		local Heat=self.dt.Heat
		local Ammo=self.dt.Ammo
		local DistFactor=math.Clamp((Target:GetPos()-SelfPos):Length()/500,.5,3) -- jumping current across greater distances is less efficient
		local Loss=((self.CurrentCapacitorCharge^1.2/11+(Heat*2)^3)*DistFactor)*.008*self.ConsumptionMul
		
		self.dt.Ammo=math.Clamp(Ammo-Loss,0,1)
		local NewHeat=Heat+(self.CurrentCapacitorCharge^1.2/200)*self.HeatMul
		self.dt.Heat=NewHeat

		self:ElectricalArcEffect(Target)
		self:ArcToGround(Target)
		self.CurrentCapacitorCharge=0
		if(SERVER)then
			umsg.Start("JackysFGFloatChange")
			umsg.Entity(self)
			umsg.String("CurrentCapacitorCharge")
			umsg.Float(self.CurrentCapacitorCharge)
			umsg.End()
		end
		self.ChargingSound:Stop()

		if(NewHeat>=1)then
			self:BurstCool()
		else
			self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
			self.Owner:GetViewModel():SetPlaybackRate(.05)
			timer.Simple(.01,function()
				if(IsValid(self))then
					self.Weapon:SendWeaponAnim(ACT_VM_IDLE)
				end
			end)
		end
	else
		//do a smattering of traces as a last-ditch effort to try to find something to arc to
		local FoundSomething=false
		local WinningTrace=nil
		for i=0,20 do
			local TrDat={}
			TrDat.start=SelfPos
			TrDat.endpos=SelfPos+AimVec*1200+VectorRand()*400
			TrDat.filter=self.Owner
			TrDat.mask=-1 -- hit water
			local Tr=util.TraceLine(TrDat)
			if(Tr.Hit)then
				if((Tr.MatType==MAT_SLOSH)or(Tr.MatType==MAT_METAL)or(Tr.MatType==MAT_GRATE)or(Tr.MatType==MAT_COMPUTER)or(Tr.MatType==MAT_VENT)or(Tr.MatType==MAT_ANTLION)or(Tr.MatType==MAT_FLESH)or(Tr.MatType==MAT_BLOODYFLESH)or(Tr.MatType==MAT_ALIENFLESH))then
					FoundSomething=true
					WinningTrace=Tr
				end
			end
		end
		if(FoundSomething)then
			self:ElectricalArcEffect(WinningTrace.HitPos)
			WinningTrace.Entity:TakeDamage(1,self.Owner,self.Weapon)
			
			for i=0,math.ceil(self.CurrentCapacitorCharge/10) do
				if(SERVER)then
					local Smelt=EffectData()
					Smelt:SetOrigin(WinningTrace.HitPos)
					Smelt:SetScale(math.ceil(self.CurrentCapacitorCharge/10))
					Smelt:SetNormal(WinningTrace.HitNormal)
					Smelt:SetStart(Vector(0,0,0))
					util.Effect("eff_jack_tinymelt",Smelt,true,true)
				end
			end
		
			local Heat=self.dt.Heat
			local Ammo=self.dt.Ammo
			local DistFactor=math.Clamp((WinningTrace.HitPos-SelfPos):Length()/600,.5,3) -- jumping current across greater distances is less efficient
			local Loss=((self.CurrentCapacitorCharge^1.1/11+(Heat*2.9)^3)*DistFactor)*.008*self.ConsumptionMul
			
			self.dt.Ammo=math.Clamp(Ammo-Loss,0,1)
			local NewHeat=(Heat+self.CurrentCapacitorCharge^1.2/200)*self.HeatMul
			self.dt.Heat=NewHeat
			
			self.CurrentCapacitorCharge=0
			if(SERVER)then
				umsg.Start("JackysFGFloatChange")
				umsg.Entity(self)
				umsg.String("CurrentCapacitorCharge")
				umsg.Float(self.CurrentCapacitorCharge)
				umsg.End()
			end
			self.ChargingSound:Stop()

			if(NewHeat>=1)then
				self:BurstCool()
			else
				self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
				self.Owner:GetViewModel():SetPlaybackRate(.05)
				timer.Simple(.01,function()
					if(IsValid(self))then
						self.Weapon:SendWeaponAnim(ACT_VM_IDLE)
					end
				end)
			end
		end
	end
end

if(SERVER)then
	local function ElectriTwitchServer(npc,killer,wep)
		if(npc.JustGotZapped)then
			local Pos=npc:GetPos()
			timer.Simple(.1,function()
				for key,rag in pairs(ents.FindInSphere(Pos,40))do
					if(rag:GetClass()=="prop_ragdoll")then
						for i=1,60 do
							timer.Simple(i/20,function()
								if(IsValid(rag))then
									local Bones=rag:GetPhysicsObjectCount()-1
									local Obj=rag:GetPhysicsObjectNum(math.random(2,Bones))
									if(Obj)then
										Obj:ApplyForceCenter(VectorRand()*(60-i)*Obj:GetMass()*8)
									end
								end
							end)
						end
					end
				end
				umsg.Start("JackysElectriTwitchClient")
				umsg.Vector(Pos)
				umsg.End()
			end)
		end
	end
	hook.Add("OnNPCKilled","JackysElectriTwitchServer",ElectriTwitchServer)
elseif(CLIENT)then
	local function ElectriTwitchClient(data)
		local Pos=data:ReadVector()
		for key,rag in pairs(ents.FindInSphere(Pos,40))do
			if(rag:GetClass()=="class C_ClientRagdoll")then
				for i=1,60 do
					timer.Simple(i/20,function()
						if(IsValid(rag))then
							local Bones=rag:GetPhysicsObjectCount()-1
							local Obj=rag:GetPhysicsObjectNum(math.random(2,Bones))
							if(Obj)then
								Obj:ApplyForceCenter(VectorRand()*(60-i)*Obj:GetMass()*8)
							end
						end
					end)
				end
			end
		end
	end
	usermessage.Hook("JackysElectriTwitchClient",ElectriTwitchClient)
end

function SWEP:ElectricalArcEffect(Victim)
	local TargetType=type(Victim)
	local VictimPos
	if(TargetType=="Vector")then
		VictimPos=Victim
	else
		VictimPos=Victim:LocalToWorld(Victim:OBBCenter())
	end
	
	local BaseShootPos=self.Owner:GetShootPos()
	local AimVec=self.Owner:GetAimVector()
	local Aim=self.dt.Aim/100
	local SelfPos=BaseShootPos+self.Owner:GetRight()*(3-3*Aim)-self.Owner:GetUp()*(5-3*Aim)+AimVec*25

	local ToVector=(VictimPos-SelfPos)
	local Dist=ToVector:Length()
	local Dir=ToVector:GetNormalized()
	
	local PrettyStartDirection --make it start out to the side so the user can see the arc better
	local Chance=math.random(1,5)
	if(Chance==1)then PrettyStartDirection=self.Owner:GetUp() elseif(Chance==2)then PrettyStartDirection=-self.Owner:GetUp() elseif(Chance==3)then PrettyStartDirection=self.Owner:GetRight() elseif(Chance==4)then PrettyStartDirection=-self.Owner:GetRight() else PrettyStartDirection=self.Owner:GetForward() end
	
	local WanderDirection=(Dir+PrettyStartDirection*math.Rand(0,1)):GetNormalized()
	
	local NumPoints=math.Clamp((math.ceil(60*(Dist/1000))+1),1,60)
	local PointTable={}
	PointTable[1]=SelfPos
	for i=2,NumPoints do
		local NewPoint
		local WeCantGoThere=true
		local C_P_I_L=0
		while(WeCantGoThere)do
			NewPoint=PointTable[i-1]+WanderDirection*Dist/NumPoints
			local CheckTr={}
			CheckTr.start=PointTable[i-1]
			CheckTr.endpos=NewPoint
			CheckTr.filter={self.Owner,Victim}
			local CheckTra=util.TraceLine(CheckTr)
			if(CheckTra.Hit)then
				WanderDirection=(WanderDirection+CheckTra.HitNormal*0.5):GetNormalized()
			else
				WeCantGoThere=false
			end
			C_P_I_L=C_P_I_L+1;if(C_P_I_L>=200)then print("CRASH PREVENTION") break end
		end
		PointTable[i]=NewPoint
		WanderDirection=(WanderDirection+VectorRand()*0.35+(VictimPos-NewPoint):GetNormalized()*0.2):GetNormalized()
	end
	PointTable[NumPoints+1]=VictimPos
	
	for key,point in pairs(PointTable)do
		if not(key==NumPoints+1)then
			if(SERVER)then
				local Harg=EffectData()
				Harg:SetStart(point)
				Harg:SetOrigin(PointTable[key+1])
				Harg:SetScale(self.CurrentCapacitorCharge/50)
				util.Effect("eff_jack_plasmaarc",Harg,true,true)
			end
		end
	end
	
	local Randim=math.Rand(0.95,1.05)
	local SoundMod=math.Clamp((((50-self.CurrentCapacitorCharge)/50)*30),-40,40)
	for i=1,math.ceil(self.CurrentCapacitorCharge/10)do
		local Snd="snd_jack_zapang.wav"
		if(math.random(1,3)==2)then Snd="snd_jack_plasmaburst.wav" end
		self:EmitSound(Snd,80-SoundMod/2,110*Randim+SoundMod)
		sound.Play(Snd,VictimPos,80-SoundMod/2,110*Randim+SoundMod)
	end
end

function SWEP:ArcToGround(Victim)
	if(Victim:IsWorld())then return end
	local Trayuss=util.QuickTrace(Victim:GetPos()+Vector(0,0,5),Vector(0,0,-30000),Victim)
	if(Trayuss.Hit)then
		local NewStart=Victim:GetPos()+Vector(0,0,5)
		ToVector=Trayuss.HitPos-NewStart
		Dist=ToVector:Length()	
		if(Dist>150)then
			WanderDirection=Vector(0,0,-1)
			NumPoints=math.Clamp((math.ceil(30*(Dist/1000))+1),1,50)
			PointTable={}
			PointTable[1]=NewStart
			for i=2,NumPoints do
				local NewPoint
				local WeCantGoThere=true
				C_P_I_L=0
				while(WeCantGoThere)do
					NewPoint=PointTable[i-1]+WanderDirection*Dist/NumPoints
					local CheckTr={}
					CheckTr.start=PointTable[i-1]
					CheckTr.endpos=NewPoint
					CheckTr.filter=Victim
					local CheckTra=util.TraceLine(CheckTr)
					if(CheckTra.Hit)then
						WanderDirection=(WanderDirection+CheckTra.HitNormal*0.5):GetNormalized()
					else
						WeCantGoThere=false
					end
					C_P_I_L=C_P_I_L+1;if(C_P_I_L>=200)then print("CRASH PREVENTION; There's probably a world-clipping entity nearby.") break end
				end
				PointTable[i]=NewPoint
				WanderDirection=(WanderDirection+VectorRand()*0.3+(Trayuss.HitPos-NewPoint):GetNormalized()*0.2):GetNormalized()
			end
			PointTable[NumPoints+1]=Trayuss.HitPos
			for key,point in pairs(PointTable)do
				if not(key==NumPoints+1)then
					if(SERVER)then
						local Harg=EffectData()
						Harg:SetStart(point)
						Harg:SetOrigin(PointTable[key+1])
						Harg:SetScale(self.CurrentCapacitorCharge/50)
						util.Effect("eff_jack_plasmaarc",Harg,true,true)
					end
				end
			end
		else
			if(SERVER)then
				local Harg=EffectData()
				Harg:SetStart(NewStart)
				Harg:SetOrigin(Trayuss.HitPos)
				Harg:SetScale(self.CurrentCapacitorCharge/50)
				util.Effect("eff_jack_plasmaarc",Harg,true,true)
			end
		end
		local Randim=math.Rand(0.95,1.05)
		local SoundMod=math.Clamp((((50-self.CurrentCapacitorCharge)/50)*30),-40,40)
		sound.Play("snd_jack_zapang.wav",Trayuss.HitPos,80-SoundMod/2,110*Randim+SoundMod)
		if(self.CurrentCapacitorCharge>=50)then
			util.Decal("Scorch",Trayuss.HitPos+Trayuss.HitNormal,Trayuss.HitPos-Trayuss.HitNormal)
		else
			util.Decal("FadingScorch",Trayuss.HitPos+Trayuss.HitNormal,Trayuss.HitPos-Trayuss.HitNormal)
		end
	end
end

function SWEP:Think()
	if(SERVER)then
		local Held=self.dt.Sprint
		if(self.Owner:KeyDown(IN_SPEED))then
			if(Held<100)then self.dt.Sprint=Held+6 end
		else
			if(Held>0)then self.dt.Sprint=Held-6 end
		end
		
		local Aim=self.dt.Aim
		if(self.Owner:KeyDown(IN_ATTACK2))then
			if(Aim<100)then self.dt.Aim=Aim+6 end
		else
			if(Aim>0)then self.dt.Aim=Aim-6 end
		end
	end
	
	local Heat=self.dt.Heat
	local Red=math.Clamp(Heat*463-69,0,255)
	local Green=math.Clamp(Heat*1275-1020,0,255)
	local Blue=math.Clamp(Heat*2550-2295,0,255)
	//self.Owner:PrintMessage(HUD_PRINTCENTER,tostring(math.Round(Red)).." "..tostring(math.Round(Green)).." "..tostring(math.Round(Blue)))
	self.VElements["narg"].color=Color(Red,Green,Blue,255)
	if not(self.CurrentCapacitorCharge)then self.CurrentCapacitorCharge=0 end
	local Culler=self.CurrentCapacitorCharge/100*255
	self.VElements["lawl"].color=Color(Culler,Culler,Culler,255)

	local State=self.dt.State
	//self.Owner:PrintMessage(HUD_PRINTCENTER,State)
	if((State==4)or(State==5))then return end
	if((self.Owner:InVehicle())or(self.Owner:KeyDown(IN_ZOOM)))then
		if(State==3)then
			self.ChargingSound:Stop()
			self.CurrentCapacitorCharge=0
			self.dt.State=2
		end
		return
	end
	
	local Ammo=self.dt.Ammo

	local BaseShootPos=self.Owner:GetShootPos()
	local ShootPos=BaseShootPos+self.Owner:GetRight()*4-self.Owner:GetUp()*5
	local AimVec=self.Owner:GetAimVector()
	
	if(State==3)then
		if not(self.NextChargingSoundTime)then self.NextChargingSoundTime=CurTime()+.1 end
		if(self.NextChargingSoundTime<CurTime())then
			self.ChargingSound:Stop()
			self.ChargingSound:Play()
			self.NextChargingSoundTime=CurTime()+2
		end
		self.CurrentCapacitorCharge=math.Clamp(self.CurrentCapacitorCharge+.25,1,100)
		local Pitch=math.Clamp(((self.CurrentCapacitorCharge/2+50)/100)*255,1,250)
		self.ChargingSound:ChangePitch(Pitch,0)
		//self.Owner:PrintMessage(HUD_PRINTCENTER,self.CurrentCapacitorCharge)
		local Drain=1
		if(self.PowerType=="Radiosotope Thermoelectric Generator/Battery Module")then Drain=100 end
		local NewAmmo=Ammo-.000025*Drain -- whenever the trigger is being held down, the weapon is maintaining an EM field
		if(NewAmmo<=0)then if(SERVER)then self:FireElectricity() end end -- such that the discharged shot will arc to a target within
		self.dt.Ammo=NewAmmo -- the proper range in front of the weapon. Holding up this guiding EM field requires energy
		if(self.Owner:WaterLevel()==3)then
			if not(AlertSoundPlayed)then
				AlertSoundPlayed=true
				self.Weapon:EmitSound("snd_jack_arcgunwarn.wav")
				self.dt.State=2
			end
		end
	else
		if(self.CurrentCapacitorCharge>0)then
			self.CurrentCapacitorCharge=math.Clamp(self.CurrentCapacitorCharge-2.5,0,100)
			local Pitch=math.Clamp(((self.CurrentCapacitorCharge/2+50)/100)*255,1,254)
			self.ChargingSound:ChangePitch(Pitch,0)
			if(self.CurrentCapacitorCharge==0)then self.ChargingSound:Stop() end
		end
	end
	self:NextThink(CurTime()+.01)
	return true
end

function SWEP:BurstCool()
	if(self.dt.State==4)then return end
	self.dt.State=4

	self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	self.Owner:GetViewModel():SetPlaybackRate(.25)
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	if not(BurstCoolSoundPlayed)then
		BurstCoolSoundPlayed=true
		self.Weapon:EmitSound("snd_jack_arcvent.wav",70,100)
	end
	if(SERVER)then
		local Pewf=EffectData()
		Pewf:SetOrigin(self.Owner:GetShootPos()+self.Owner:GetAimVector()*20+self.Owner:GetRight()*4)
		Pewf:SetStart(self.Owner:GetVelocity())
		util.Effect("eff_jack_instantvent",Pewf,true,true)
	end
	timer.Simple(.2,function()
		if(IsValid(self))then
			if(SERVER)then
				local Pewf=EffectData()
				Pewf:SetOrigin(self.Owner:GetShootPos()+self.Owner:GetAimVector()*20+self.Owner:GetRight()*4)
				Pewf:SetStart(self.Owner:GetVelocity())
				util.Effect("eff_jack_instantvent",Pewf,true,true)
			end
		end
	end)
	timer.Simple(.4,function()
		if(IsValid(self))then
			if(SERVER)then
				local Pewf=EffectData()
				Pewf:SetOrigin(self.Owner:GetShootPos()+self.Owner:GetAimVector()*20+self.Owner:GetRight()*4)
				Pewf:SetStart(self.Owner:GetVelocity())
				util.Effect("eff_jack_instantvent",Pewf,true,true)
			end
		end
	end)
	timer.Simple(1.6,function()
		if(IsValid(self))then
			self.dt.State=2
			BurstCoolSoundPlayed=false
		end
	end)
end

function SWEP:LoadEnergyCartridge(cartridge,powerType,heatMul,consumptionMul,charge)
	GlobalJackyFGHGLoadEnCart(self,cartridge,powerType,heatMul,consumptionMul,charge)
end

function SWEP:Holster()
	if not(self.dt.State==2)then return false end
	self.ChargingSound:Stop()
	self.dt.State=6
	self.dt.Sprint=0
	self:SCKHolster()
	return true
end

function SWEP:OnDrop()
	self.ChargingSound:Stop()
end

if(CLIENT)then
	function SWEP:DrawHUD()
		-- *overwrite*  :3
	end
	function SWEP:GetViewModelPosition(pos,ang)
		local Aim=self.dt.Aim/100
		local AimInv=1-Aim
		
		local Right=ang:Right()
		local Up=ang:Up()
		local Forward=ang:Forward()
		
		ang:RotateAroundAxis(Right,5*AimInv)
		ang:RotateAroundAxis(Up,-AimInv)
		pos=pos+Right*.5*AimInv-Up*AimInv*2
		
		if(Aim>0)then
			pos=pos+Right*self.AimPos.x*Aim+Forward*self.AimPos.y*Aim+Up*self.AimPos.z*Aim
			ang:RotateAroundAxis(Right,self.AimAng.p*Aim)
			ang:RotateAroundAxis(Up,self.AimAng.y*Aim)
			ang:RotateAroundAxis(Forward,self.AimAng.r*Aim)
		end

		local Held=self.dt.Sprint/100
		if(Held>0)then
			pos=pos+self.SprintPos.x*Right*Held+self.SprintPos.y*Up*Held+self.SprintPos.z*Forward*Held
			ang:RotateAroundAxis(Right,self.SprintAng.p*Held)
			ang:RotateAroundAxis(Up,self.SprintAng.y*Held)
			ang:RotateAroundAxis(Forward,self.SprintAng.r*Held)
		end
		return pos,ang
	end
	function SWEP:ViewModelDrawn()
		self:SCKViewModelDrawn()
	end
	function SWEP:DrawWorldModel()
		self:SCKDrawWorldModel()
	end
end

/*---------------- These things operate OUTSIDE of the weapon --------------------------*/

local function TriggerFire(ply,key)
	if not(key==IN_ATTACK)then return end
	local Wep=ply:GetActiveWeapon()
	if(IsValid(Wep))then
		if(Wep:GetClass()=="wep_jack_fungun_beta")then
			if(Wep.dt.State==3)then
				if(SERVER)then
					Wep:FireElectricity()
				end
			end
			AlertSoundPlayed=false
		end
	end
end
hook.Add("KeyRelease","JackysBetaFungunFire",TriggerFire)

local function GunThink()	
	for key,wep in pairs(ents.FindByClass("wep_jack_fungun_beta"))do
		local Heat=wep:GetDTFloat(0)
		if(Heat)then
			local State=wep:GetDTInt(0)
			if(State==4)then
				wep:SetDTFloat(0,math.Clamp(Heat-.0075,0,1))
			else
				wep:SetDTFloat(0,math.Clamp(Heat-.0003,0,1))
			end
		end
	end
end
hook.Add("Think","JackysBetaFunGunThinking",GunThink)