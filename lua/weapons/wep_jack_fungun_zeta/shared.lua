SWEP.Base="wep_jack_fungun_base_master"

if(SERVER)then
	AddCSLuaFile("shared.lua")
end

if(CLIENT)then
	SWEP.PrintName="Handgun Zeta"
	SWEP.Slot=1
	SWEP.WepSelectIcon=surface.GetTextureID("vgui/mat_jack_fgzeta_wsi")
	killicon.Add("wep_jack_fungun_zeta","vgui/mat_jack_fgzeta_wsi",Color(255,255,255,255))
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
	surface.SetDrawColor(255,80,75,255*Flicker)
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

SWEP.SprintPos=Vector(2.539,-14.44,-0.441)
SWEP.SprintAng=Angle(74,-7,0)
SWEP.AimPos=Vector(-2.2, 2,-.5)
SWEP.AimAng=Angle(1.2,-3.5,0)
SWEP.ShowWorldModel=false
SWEP.ReloadNoise={"snd_jack_laserreload.wav",70,100}
SWEP.ViewModelBoneMods={
	["Main Frame"]={ scale=Vector(0.009, 0.009, 0.009), pos=Vector(0, 0, 0), angle=Angle(0, 0, 0) }
}
SWEP.VElements={
	["hurr"]={ type="Quad", bone="Main Frame", rel="", pos=Vector(-1.35, -2, 1.5), angle=Angle(0, -90, 60.34), size=0.025, draw_func=JackIndFunGunAmmoDisplay},
	["lawl"]={ type="Model", model="models/mass_effect_3/weapons/misc/jhermal clip.mdl", bone="Main Frame", rel="", pos=Vector(-1.5, -0.5, 0.1), angle=Angle(0, 180, 0), size=Vector(0.4, 0.4, 0.4), color=Color(255, 255, 255, 255), surpresslightning=true, material="models/debug/debugwhite", skin=0, bodygroup={} },
	["narg"]={ type="Model", model="models/mass_effect_3/weapons/misc/jeatsink.mdl", bone="Main Frame", rel="", pos=Vector(-2, -0.5, 1), angle=Angle(0, 90, 0), size=Vector(0.5, 0.8, 0.5), color=Color(255, 255, 255, 255), surpresslightning=true, material="models/debug/debugwhite", skin=0, bodygroup={} },
	["lol"]={ type="Model", model="models/mass_effect_3/weapons/pistols/sjorpion.mdl", bone="Main Frame", rel="", pos=Vector(-0.7, -0.5, 0.8), angle=Angle(0, 90, 0), size=Vector(1, 1, 1), color=Color(255, 255, 255, 255), surpresslightning=false, material="", skin=0, bodygroup={} },
	["derp"]={ type="Model", model="models/mass_effect_3/weapons/misc/jhermal clip.mdl", bone="Slide", rel="", pos=Vector(0, -0.5, -0.201), angle=Angle(0, 0, 0), size=Vector(0.4, 0.4, 0.4), color=Color(255, 255, 255, 255), surpresslightning=false, material="", skin=0, bodygroup={} },
	["herp"]={ type="Model", model="models/mass_effect_3/weapons/misc/jeatsink.mdl", bone="Mag", rel="", pos=Vector(0.1, -.3, 2), angle=Angle(180, 90, 81), size=Vector(1.299, 0.699, 1), color=Color(255, 255, 255, 255), surpresslightning=false, material="", skin=0, bodygroup={} },
	["herpitty"]={ type="Quad", bone="Main Frame", rel="", pos=Vector(10, -1, 3.75), angle=Angle(0, -90, 90), size=0.025, draw_func=SWEP.FrontSight},
	["derpitty"]={ type="Quad", bone="Main Frame", rel="", pos=Vector(-7, -.98, 3.5), angle=Angle(0, -90, 90), size=0.025, draw_func=SWEP.RearSight}
}
SWEP.WElements={
	["lol"]={ type="Model", model="models/mass_effect_3/weapons/pistols/sjorpion.mdl", bone="ValveBiped.Bip01_R_Hand", rel="", pos=Vector(3.181, 1.363, -3.182), angle=Angle(180, 90, 0), size=Vector(1, 1, 1), color=Color(255, 255, 255, 255), surpresslightning=false, material="", skin=0, bodygroup={} }
}

local AlreadyFired=false
local BurstCoolSoundPlayed=false
local MeltTable={MAT_METAL,MAT_GRATE,MAT_VENT,MAT_COMPUTER,MAT_CONCRETE,MAT_TILE,MAT_GLASS}

function SWEP:Initialize()
	self:SetWeaponHoldType("revolver")
	self.ChargingSound=CreateSound(self.Weapon,"snd_jack_zetachargeloop.wav")
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
	if(self.dt.Sprint>10)then return end
	if not(self.dt.State==2)then return end
	if(self.dt.Ammo<=0)then return end
	self:SetNextPrimaryFire(CurTime()+.025)
	local ShootPos=self.Owner:GetShootPos()+self.Owner:GetAimVector()*20
	if(self.CurrentCapacitorCharge==0)then self:EmitSound("snd_jack_chargebegin.wav",60,120) end
	self.ChargingSound:Play()
	self.dt.State=3
	if(self.CurrentCapacitorCharge<1)then self.CurrentCapacitorCharge=1 end
	self.NextChargingSoundTime=CurTime()+2
	AlreadyFired=false
	BurstCoolSoundPlayed=false
end

function SWEP:FireLaser()
	if(self.Owner:KeyDown(IN_SPEED))then self.dt.State=2 return end
	if(CLIENT)then self.CurrentCapacitorCharge=0;self.ChargingSound:Stop() return end
	if(AlreadyFired)then return end
	AlreadyFired=true
	
	self.Weapon:EmitSound("snd_jack_laserpulse.wav",70,100)
	
	umsg.Start("JackysFGFloatChange")
	umsg.Entity(self)
	umsg.String("CurrentCapacitorCharge")
	umsg.Bool(0)
	umsg.End()
	
	local BaseShootPos=self.Owner:GetShootPos()
	local AimVec=self.Owner:GetAimVector()
	
	local TraceData={}
	TraceData.start=BaseShootPos
	TraceData.endpos=BaseShootPos+AimVec*8000
	TraceData.filter=self.Owner
	TraceData.mask=MASK_SHOT+CONTENTS_WATER
	local Trace=util.TraceLine(TraceData)
	
	if(Trace.Hit)then
		local Dist=(Trace.HitPos-BaseShootPos):Length()
		local Power=(1-(Dist/8000))*self.CurrentCapacitorCharge

		util.ScreenShake(Trace.HitPos,50,50,Power/35,Power*12)
		util.BlastDamage(self.Weapon,self.Owner,Trace.HitPos,Power*6,Power*1)
		local Derp=DamageInfo()
		Derp:SetDamage(Power/2)
		Derp:SetDamageType(DMG_DIRECT)
		Derp:SetDamageForce(AimVec*Power*8000)
		Derp:SetAttacker(self.Owner)
		Derp:SetInflictor(self.Weapon)
		Derp:SetDamagePosition(Trace.HitPos)
		Trace.Entity:TakeDamageInfo(Derp)
		
		local Pow=EffectData()
		Pow:SetOrigin(Trace.HitPos)
		Pow:SetNormal(Trace.HitNormal)
		Pow:SetScale(Power^.6/30)
		Pow:SetRadius(Power)
		util.Effect("eff_jack_plasmaburst",Pow,true,true)
		
		if(table.HasValue(MeltTable,Trace.MatType))then
			local Melt=EffectData()
			Melt:SetOrigin(Trace.HitPos)
			Melt:SetNormal(Trace.HitNormal)
			Melt:SetScale(Power^.6/30)
			util.Effect("eff_jack_fadingmelt",Pow,true,true)
			
			local effectdata=EffectData()
			effectdata:SetOrigin(Trace.HitPos)
			effectdata:SetNormal(Trace.HitNormal)
			effectdata:SetMagnitude(Power^.6) --amount and shoot hardness
			effectdata:SetScale(Power^.6/2) --length of strands
			effectdata:SetRadius(Power^.6/2) --thickness of strands
			util.Effect("Sparks",effectdata,true,true)
		end
		
		if(self.Owner:WaterLevel()==3)then
			local Blamo=EffectData()
			Blamo:SetOrigin(BaseShootPos+AimVec*30)
			Blamo:SetStart(AimVec)
			util.Effect("eff_jack_plasmajetwater",Blamo,true)
			util.Effect("eff_jack_plasmajetwater",Blamo,true)
		elseif(Trace.MatType==MAT_SLOSH)then
			local Blamo=EffectData()
			Blamo:SetOrigin(Trace.HitPos+Trace.HitNormal)
			Blamo:SetStart(AimVec)
			util.Effect("eff_jack_plasmajetwater",Blamo,true,true)
			util.Effect("eff_jack_plasmajetwater",Blamo,true,true)
		end
		
		for i=1,math.ceil(Power/4)do
			local Dist=math.Clamp(50+i*13,70,150)
			local Pitch=math.Clamp(150-i*13,60,150)
			local Snd="snd_jack_plasmaburst.wav"
			if(math.random(1,3)==1)then Snd="snd_jack_zapang.wav" end
			sound.Play(Snd,Trace.HitPos,Dist,Pitch)
		end
		
		for key,ply in pairs(ents.FindInSphere(Trace.HitPos,Power*4))do
			if(ply:IsPlayer())then
				ply:ViewPunch(Angle(math.Rand(-1.5,1.5)*Power,math.Rand(-1.5,1.5)*Power,math.Rand(-1.5,1.5)*Power))
			end
		end
	end
	
	local Heat=self.dt.Heat
	local Ammo=self.dt.Ammo
	local Loss=((self.CurrentCapacitorCharge^1.2/11+(Heat*2)^3)*.002)*self.ConsumptionMul
	
	self.dt.Ammo=math.Clamp(Ammo-Loss,0,1)
	local NewHeat=Heat+(self.CurrentCapacitorCharge^1.2/160)*self.HeatMul
	self.dt.Heat=NewHeat
	
	self.CurrentCapacitorCharge=0
	self.dt.State=2
	self.ChargingSound:Stop()
	
	if(NewHeat>=1)then
		self:BurstCool()
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
	local Culler=(self.CurrentCapacitorCharge/75)*255
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
			self.NextChargingSoundTime=CurTime()+3.4
		end
		self.CurrentCapacitorCharge=math.Clamp(self.CurrentCapacitorCharge+.25,1,75)
		local Pitch=math.Clamp(((self.CurrentCapacitorCharge/2+50)/100)*255,1,250)
		self.ChargingSound:ChangePitch(Pitch,0)
		//self.Owner:PrintMessage(HUD_PRINTCENTER,self.CurrentCapacitorCharge)
		local Amount=.000025
		if(self.PowerType=="Radiosotope Thermoelectric Generator/Battery Module")then Amount=.0037 end
		local NewAmmo=Ammo-Amount
		if(NewAmmo<=0)then if(SERVER)then self:FireLaser() end end
		self.dt.Ammo=NewAmmo
	else
		if(self.CurrentCapacitorCharge>0)then
			self.CurrentCapacitorCharge=math.Clamp(self.CurrentCapacitorCharge-2.5,0,100)
			if(SERVER)then
				local Pitch=math.Clamp(((self.CurrentCapacitorCharge/2+50)/100)*255,1,254)
				self.ChargingSound:ChangePitch(Pitch,0)
			end
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
		self.Weapon:EmitSound("snd_jack_laservent.wav",70,100)
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
		if(self.dt.State==3)then pos=pos+VectorRand()*.015 end
	
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
		if(Wep:GetClass()=="wep_jack_fungun_zeta")then
			if(Wep.dt.State==3)then
				if(SERVER)then
					Wep:FireLaser()
				end
			end
		end
	end
end
hook.Add("KeyRelease","JackysZetaFungunFire",TriggerFire)

local function GunThink()	
	for key,wep in pairs(ents.FindByClass("wep_jack_fungun_zeta"))do
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
hook.Add("Think","JackysZetaFunGunThinking",GunThink)