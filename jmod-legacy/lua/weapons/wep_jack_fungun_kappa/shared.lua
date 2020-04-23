SWEP.Base="wep_jack_fungun_base_master"

if(SERVER)then
	AddCSLuaFile("shared.lua")
end

if(CLIENT)then
	SWEP.PrintName="Handgun Kappa"
	SWEP.Slot=1
	SWEP.WepSelectIcon=surface.GetTextureID("vgui/mat_jack_fgkappa_wsi")
	killicon.Add("wep_jack_fungun_kappa","vgui/mat_jack_fgkappa_wsi",Color(255,255,255,255))
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
	surface.SetDrawColor(255,80,75,200*Flicker)
	surface.DrawRect(21,18,2,2)
	surface.SetDrawColor(255,255,255,150*Flicker)
	surface.DrawLine(5,30,15,22)
	surface.DrawLine(35,30,26,22)
end
function SWEP:RearSight()
	if not(self.DisplaysOn)then return end
	local Flicker=math.Rand(.5,1)
	if(self.dt.Ammo<.01)then Flicker=math.Rand(0,.5) end
	surface.SetDrawColor(255,255,255,150*Flicker)
	surface.DrawLine(6,14,15,14)
	surface.DrawLine(26,14,35,14)
	surface.DrawLine(20,3,20,9)
end

SWEP.ReloadNoise={"snd_jack_laserreload.wav",70,100}
SWEP.DefaultBobSway=2
SWEP.SprintPos=Vector(2.539,-14.44,-0.441)
SWEP.SprintAng=Angle(74,-7,0)
SWEP.AimPos=Vector(-2.76, 2,-.5)
SWEP.AimAng=Angle(1.2,-3.5,0)
SWEP.ShowWorldModel=false
SWEP.ViewModelBoneMods={
	["Main Frame"]={ scale=Vector(0.009, 0.009, 0.009), pos=Vector(0, 0, 0), angle=Angle(0, 0, 0) }
}
SWEP.VElements={
	["hurr"]={ type="Quad", bone="Main Frame", rel="", pos=Vector(1, -1.65, 1.1), angle=Angle(0, -90, 60.34), size=0.025, draw_func=JackIndFunGunAmmoDisplay},
	["narg"]={ type="Model", model="models/mass_effect_3/weapons/misc/jeatsink.mdl", bone="Main Frame", rel="", pos=Vector(-1, 0, 1.5), angle=Angle(0, -90, 0), size=Vector(0.5, 0.5, 0.5), color=Color(255, 255, 255, 255), surpresslightning=true, material="models/debug/debugwhite", skin=0, bodygroup={} },
	["lol"]={ type="Model", model="models/mass_effect_3/weapons/pistols/m-3 jredator.mdl", bone="Main Frame", rel="", pos=Vector(0.455, 0, 1.363), angle=Angle(0, 90, 0), size=Vector(1, 1, 1), color=Color(255, 255, 255, 255), surpresslightning=false, material="", skin=0, bodygroup={} },
	["derp"]={ type="Model", model="models/mass_effect_3/weapons/misc/jhermal clip.mdl", bone="Slide", rel="", pos=Vector(1, 0, -1.101), angle=Angle(0, 0, 0), size=Vector(0.5, 0.5, 0.5), color=Color(255, 255, 255, 255), surpresslightning=false, material="", skin=0, bodygroup={} },
	["herp"]={ type="Model", model="models/mass_effect_3/weapons/misc/jeatsink.mdl", bone="Mag", rel="", pos=Vector(0.1, 0, 2), angle=Angle(180, 90, 81), size=Vector(1.299, 0.699, 1), color=Color(255, 255, 255, 255), surpresslightning=false, material="", skin=0, bodygroup={} },
	["herpitty"]={ type="Quad", bone="Main Frame", rel="", pos=Vector(10, -.48, 3.75), angle=Angle(0, -90, 90), size=0.025, draw_func=SWEP.FrontSight},
	["derpitty"]={ type="Quad", bone="Main Frame", rel="", pos=Vector(-5, -.45, 3.5), angle=Angle(0, -90, 90), size=0.025, draw_func=SWEP.RearSight}
}
SWEP.WElements={
	["lol"]={ type="Model", model="models/mass_effect_3/weapons/pistols/m-3 jredator.mdl", bone="ValveBiped.Bip01_R_Hand", rel="", pos=Vector(3.181, 1.2, -3.5), angle=Angle(180, 90, 0), size=Vector(1, 1, 1), color=Color(255, 255, 255, 255), surpresslightning=false, material="", skin=0, bodygroup={} }
}

local BurstCoolSoundPlayed=false

function SWEP:Initialize()
	self:SetWeaponHoldType("revolver")
	self.NewCartridge=true
	self.dt.Ammo=1.005

	self:SCKInitialize()
end

function SWEP:SetupDataTables()
	self:DTVar("Int",0,"State") -- 1=drawing, 2=idle, 3=firing, 4=venting, 5=reloading, 6=holstered
	self:DTVar("Float",0,"Heat")
	self:DTVar("Float",1,"Ammo")
	self:DTVar("Int",1,"Sprint")
	self:DTVar("Int",2,"Aim")
end

function SWEP:Deploy()
	GlobalJackyFGHGDeploy(self)
end

function SWEP:PrimaryAttack()
	if(self.dt.Sprint>10)then return end
	if not(self.dt.State==2)then return end
	if(self.dt.Ammo<=0)then return end
	self:SetNextPrimaryFire(CurTime()+.2)
	local ShootPos=self.Owner:GetShootPos()+self.Owner:GetAimVector()*20
	if not(self.ChargingSound)then self.ChargingSound=CreateSound(self.Weapon,"snd_jack_electrolasercharge.wav");self.ChargingSound:SetSoundLevel(80) end
	self.ChargingSound:Stop()
	self.ChargingSound:Play()
	self.dt.State=3
	BurstCoolSoundPlayed=false
	timer.Simple(1,function()
		if(IsValid(self))then
			self.dt.State=2
			local Aim=1-self.dt.Aim/100
			local BaseShootPos=self.Owner:GetShootPos()
			local AimVec=self.Owner:GetAimVector()
			local ShootPos=BaseShootPos+AimVec*20-self.Owner:GetUp()*3+self.Owner:GetRight()*2*Aim
			local TrDat={start=BaseShootPos,endpos=ShootPos,filter=self.Owner}
			local Tr=util.TraceLine(TrDat)
			if(Tr.Hit)then ShootPos=BaseShootPos end
			if(self.Owner:KeyDown(IN_SPEED))then AimVec=self.Owner:EyeAngles():Up();ShootPos=BaseShootPos+AimVec*20 end
			self:LaserTrace(ShootPos,ShootPos+AimVec*40000,self.Owner,1)
		end
	end)
end

//FOR INSTANCE, THIS MASK ALLOWS THE TRACE TO SEE THROUGH WINDOWS fuck that shit

function SWEP:LaserTrace(stert,ayund,filtah,stack)
	if(stack>=30)then print("CRASH PREVENTION: You're shooting the laser at something that's confusing the logic.") return end -- prevent errors
	if(CLIENT)then return end
	local TressDat={}
	TressDat.start=stert
	TressDat.endpos=ayund
	TressDat.filter=filtah
	TressDat.mask=MASK_SHOT
	local Tress=util.TraceLine(TressDat)
	if(Tress.Hit)then
		local Mat=Tress.Entity:GetMaterial()
		if((Mat=="debug/env_cubemap_model")or(Mat=="phoenix_storms/scrnspace")or(Tress.HitTexture=="GLASS/REFLECTIVEGLASS001"))then
			local TheAngle=Tress.Normal:Angle()
			TheAngle:RotateAroundAxis(Tress.HitNormal,180)
			local DepartVector=-TheAngle:Forward()
			
			local NewBeginning=Tress.HitPos
			local NewEnd=Tress.HitPos+DepartVector*40000
			self:LaserTrace(NewBeginning,NewEnd,{},stack+1)
		elseif((Tress.Entity:GetColor().a<=150)or(Tress.MatType==MAT_GLASS))then
			if(Tress.Entity:IsWorld())then
				self:LaserTrace(Tress.HitPos+Tress.Normal*5,Tress.HitPos+Tress.Normal*40000,{},stack+1)
			else
				self:LaserTrace(Tress.HitPos,Tress.HitPos+Tress.Normal*40000,{Tress.Entity},stack+1)
			end
		else
			if(SERVER)then
				local WantSomeIceWithThatBurn=DamageInfo()
				WantSomeIceWithThatBurn:SetDamage(math.Rand(5,10))
				WantSomeIceWithThatBurn:SetDamagePosition(Tress.HitPos)
				WantSomeIceWithThatBurn:SetDamageForce(Vector(0,0,0))
				WantSomeIceWithThatBurn:SetAttacker(self.Owner)
				WantSomeIceWithThatBurn:SetInflictor(self.Weapon)
				if(Tress.Entity:IsOnFire())then
					WantSomeIceWithThatBurn:SetDamageType(DMG_GENERIC)
				elseif(math.random(1,9)==5)then
					WantSomeIceWithThatBurn:SetDamageType(DMG_BURN)
				else
					WantSomeIceWithThatBurn:SetDamageType(DMG_DIRECT)
				end
				Tress.Entity:TakeDamageInfo(WantSomeIceWithThatBurn)
				sound.Play("snd_jack_heavylaserburn.wav",Tress.HitPos+Tress.HitNormal,80,100)
				sound.Play("snd_jack_electrolaserfire.wav",stert,100,100)
				local Poof=EffectData()
				Poof:SetOrigin(Tress.HitPos)
				Poof:SetScale(2)
				Poof:SetNormal(Tress.HitNormal)
				if((Tress.MatType==MAT_CONCRETE)or(Tress.MatType==MAT_METAL)or(Tress.MatType==MAT_COMPUTER)or(Tress.MatType==MAT_GRATE)or(Tress.MatType==MAT_TILE)or(Tress.MatType==MAT_GLASS)or(Tress.MatType==MAT_SAND))then
					Poof:SetStart(Tress.Entity:GetVelocity())
					util.Effect("eff_jack_tinymelt",Poof,true,true)
					Poof:SetScale(.12)
					util.Effect("eff_jack_heavyfadingmelt",Poof,true,true)
				else
					util.Effect("eff_jack_tinyburn",Poof,true,true)
				end
				local Derp=EffectData()
				Derp:SetOrigin(Tress.HitPos)
				Derp:SetScale(1)
				Derp:SetNormal(Tress.HitNormal)
				util.Effect("eff_jack_heavylaserbeamimpact",Derp,true,true)
			end
			
			timer.Simple(.05,function()
				if(IsValid(self))then
					local DerPosition=self.Owner:GetShootPos()+self.Owner:GetAimVector()*20-self.Owner:GetUp()*3+self.Owner:GetRight()*2*(self.dt.Aim/100)
					if(self.Owner:KeyDown(IN_SPEED))then DerPosition=self.Owner:GetShootPos()+self.Owner:EyeAngles():Up()*20 end
					local Derp=EffectData()
					Derp:SetStart(DerPosition)
					Derp:SetOrigin(stert)
					Derp:SetScale(1)
					util.Effect("eff_jack_heavyplasmaarc",Derp,true,true)
					self:ElectriTrace(stert,ayund,filtah,stack)
				end
			end)
		end
		local Derp=EffectData()
		Derp:SetStart(stert)
		Derp:SetOrigin(Tress.HitPos)
		Derp:SetScale(1)
		util.Effect("eff_jack_heavylaserbeam",Derp,true,true)
	end
end

function SWEP:ElectriTrace(stert,ayund,filtah,stack)
	if(stack>=30)then print("CRASH PREVENTION: You're shooting the laser at something that's confusing the logic.") return end -- prevent errors
	if(CLIENT)then return end
	local TressDat={}
	TressDat.start=stert
	TressDat.endpos=ayund
	TressDat.filter=filtah
	TressDat.mask=MASK_SHOT
	local Tress=util.TraceLine(TressDat)
	if(Tress.Hit)then
		local Mat=Tress.Entity:GetMaterial()
		if((Mat=="debug/env_cubemap_model")or(Mat=="phoenix_storms/scrnspace")or(Tress.HitTexture=="GLASS/REFLECTIVEGLASS001"))then
			local TheAngle=Tress.Normal:Angle()
			TheAngle:RotateAroundAxis(Tress.HitNormal,180)
			local DepartVector=-TheAngle:Forward()
			
			local NewBeginning=Tress.HitPos
			local NewEnd=Tress.HitPos+DepartVector*40000
			self:ElectriTrace(NewBeginning,NewEnd,{},stack+1)
		elseif((Tress.Entity:GetColor().a<=150)or(Tress.MatType==MAT_GLASS))then
			if(Tress.Entity:IsWorld())then
				self:ElectriTrace(Tress.HitPos+Tress.Normal*5,Tress.HitPos+Tress.Normal*40000,{},stack+1)
			else
				self:ElectriTrace(Tress.HitPos,Tress.HitPos+Tress.Normal*40000,{Tress.Entity},stack+1)
			end
		else
			self:ArcToGround(Tress.Entity)
			if(SERVER)then
				local WantSomeIceWithThatBurn=DamageInfo()
				WantSomeIceWithThatBurn:SetDamage(math.Rand(20,30))
				WantSomeIceWithThatBurn:SetDamagePosition(Tress.HitPos)
				WantSomeIceWithThatBurn:SetDamageForce(Vector(0,0,0))
				WantSomeIceWithThatBurn:SetAttacker(self.Owner)
				WantSomeIceWithThatBurn:SetInflictor(self.Weapon)
				WantSomeIceWithThatBurn:SetDamageType(DMG_SHOCK)
				Tress.Entity.JustGotZapped=true
				Tress.Entity:TakeDamageInfo(WantSomeIceWithThatBurn)
				timer.Simple(1,function() if(IsValid(Tress.Entity))then Tress.Entity.JustGotZapped=false end end)
				sound.Play("snd_jack_zapang.wav",Tress.HitPos+Tress.HitNormal,90,100)
			end
		end
		local Derp=EffectData()
		Derp:SetStart(stert)
		Derp:SetOrigin(Tress.HitPos)
		Derp:SetScale(1)
		util.Effect("eff_jack_heavyplasmaarc",Derp,true,true)
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
						Harg:SetScale(.5)
						util.Effect("eff_jack_plasmaarc",Harg,true,true)
					end
				end
			end
		else
			if(SERVER)then
				local Harg=EffectData()
				Harg:SetStart(NewStart)
				Harg:SetOrigin(Trayuss.HitPos)
				Harg:SetScale(.5)
				util.Effect("eff_jack_plasmaarc",Harg,true,true)
			end
		end
		local Randim=math.Rand(0.95,1.05)
		local SoundMod=0
		sound.Play("snd_jack_zapang.wav",Trayuss.HitPos,80-SoundMod/2,110*Randim+SoundMod)
		util.Decal("FadingScorch",Trayuss.HitPos+Trayuss.HitNormal,Trayuss.HitPos-Trayuss.HitNormal)
	end
end

function SWEP:Think()
	self.LaserShake=VectorRand()*math.Rand(.01,.05)
	
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

	local State=self.dt.State
	//self.Owner:PrintMessage(HUD_PRINTCENTER,State)
	if((State==4)or(State==5))then return end
	if((self.Owner:InVehicle())or(self.Owner:KeyDown(IN_ZOOM)))then
		if(State==3)then
			self.dt.State=2
		end
		return
	end

	local BaseShootPos=self.Owner:GetShootPos()
	local AimVec=self.Owner:GetAimVector()
	local Aim=self.dt.Aim/100
	local ShootPos=BaseShootPos+self.Owner:GetRight()*(3-3*Aim)-self.Owner:GetUp()*(5-3*Aim)+AimVec*25
end

function SWEP:BurstCool()
	if(self.dt.State==4)then return end
	self.dt.State=4

	self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	self.Owner:GetViewModel():SetPlaybackRate(.25)
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	if not(BurstCoolSoundPlayed)then
		BurstCoolSoundPlayed=true
		self.Weapon:EmitSound("snd_jack_laservent.wav",70,100)
	end
	local Pewf=EffectData()
	Pewf:SetOrigin(self.Owner:GetShootPos()+self.Owner:GetAimVector()*20+self.Owner:GetRight()*4)
	Pewf:SetStart(self.Owner:GetVelocity())
	util.Effect("eff_jack_instantvent",Pewf,true,true)
	timer.Simple(.2,function()
		if(IsValid(self))then
			local Pewf=EffectData()
			Pewf:SetOrigin(self.Owner:GetShootPos()+self.Owner:GetAimVector()*20+self.Owner:GetRight()*4)
			Pewf:SetStart(self.Owner:GetVelocity())
			util.Effect("eff_jack_instantvent",Pewf,true,true)
		end
	end)
	timer.Simple(.4,function()
		if(IsValid(self))then
			local Pewf=EffectData()
			Pewf:SetOrigin(self.Owner:GetShootPos()+self.Owner:GetAimVector()*20+self.Owner:GetRight()*4)
			Pewf:SetStart(self.Owner:GetVelocity())
			util.Effect("eff_jack_instantvent",Pewf,true,true)
		end
	end)
	timer.Simple(1.6,function()
		if(IsValid(self))then
			self.dt.State=2
			BurstCoolSoundPlayed=false
		end
	end)
end

function SWEP:LoadEnergyCartridge(cartridge)
	GlobalJackyFGHGLoadEnCart(self,cartridge,powerType,heatMul,consumptionMul,charge)
end

function SWEP:Holster()
	if not(self.dt.State==2)then return false end
	self.dt.State=6
	self.dt.Sprint=0
	self.dt.Aim=0
	self:SCKHolster()
	return true
end

function SWEP:OnDrop()
	//derp
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
		
		if(self.dt.State==3)then
			pos=pos+self.LaserShake
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
		// very nice beam/sprite drawing, Rest In Peace ;_;
		self:SCKViewModelDrawn()
	end
	function SWEP:DrawWorldModel()
		self:SCKDrawWorldModel()
	end
end

/*---------------- These things operate OUTSIDE of the weapon --------------------------*/

local function GunThink()
	for key,wep in pairs(ents.FindByClass("wep_jack_fungun_kappa"))do
		local Heat=wep.dt.Heat
		if(Heat)then
			local State=wep.dt.State
			if(State==3)then
				if((wep.dt.Ammo<=0)or(wep.Owner:KeyDown(IN_SPEED)))then
					if not(LaserEndPlayed)then
						LaserEndPlayed=true
						if(SERVER)then wep:EmitSound("snd_jack_laserend.wav",70,100) end
					end
					if(SERVER)then
						umsg.Start("JackysDynamicFGBobSwayScaling")
						umsg.Entity(wep)
						umsg.Float(wep.DefaultBobSway)
						umsg.End()
					end
					wep.dt.State=2
				elseif(Heat==1)then
					if not(LaserEndPlayed)then
						LaserEndPlayed=true
						if(SERVER)then wep:EmitSound("snd_jack_laserend.wav",70,100) end
					end
					if(SERVER)then
						umsg.Start("JackysDynamicFGBobSwayScaling")
						umsg.Entity(wep)
						umsg.Float(wep.DefaultBobSway)
						umsg.End()
					end
					wep:BurstCool() -- emergency cooling interrupt, protect the pistol from dumbass users
					wep.dt.Heat=.9999
				end
			end
			if(State==4)then
				wep.dt.Heat=math.Clamp(Heat-.0075,0,1)
			else
				wep.dt.Heat=math.Clamp(Heat-.0003,0,1)
			end
		end
	end
end
hook.Add("Think","JackysKappaFunGunThinking",GunThink)