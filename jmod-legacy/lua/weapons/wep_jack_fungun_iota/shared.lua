SWEP.Base="wep_jack_fungun_base_master"

if(SERVER)then
	AddCSLuaFile("shared.lua")
end

if(CLIENT)then
	SWEP.PrintName="Handgun Iota"
	SWEP.Slot=1
	SWEP.WepSelectIcon=surface.GetTextureID("vgui/mat_jack_fgiota_wsi")
	killicon.Add("wep_jack_fungun_iota","vgui/mat_jack_fgiota_wsi",Color(255,255,255,255))
end

SWEP.ViewModelFOV=70
SWEP.ViewModelFlip=false
SWEP.ViewModel="models/weapons/v_halo_jeagle.mdl"
SWEP.WorldModel="models/props_junk/PopCan01a.mdl" --w_357.mdl" //not using the w_357 because it has muzzle flash and the gauss gun is a stealthy beast
SWEP.SwayScale=1.75
SWEP.BobScale=1.75

function SWEP:FrontSight()
	if not(self.DisplaysOn)then return end
	local Flicker=math.Rand(.5,1)
	if(self.dt.Energy<.01)then Flicker=math.Rand(0,.5) end
	surface.SetDrawColor(255,20,20,200*Flicker)
	surface.DrawLine(19,53,19,100)
	surface.DrawLine(8,53,-10,53)
	surface.DrawLine(30,53,45,53)
end
function SWEP:RearSight()
	if not(self.DisplaysOn)then return end
	local Flicker=math.Rand(.5,1)
	if(self.dt.Energy<.01)then Flicker=math.Rand(0,.5) end
	surface.SetDrawColor(255,255,255,100*Flicker)
	surface.DrawLine(18,55,12,75)
	surface.DrawLine(18,55,24,75)
	surface.DrawLine(12,75,24,75)
end

SWEP.SprintPos=Vector(2.539,-14.44,-0.441)
SWEP.SprintAng=Angle(74,-7,0)
SWEP.AimPos=Vector(-2.52, 2,-.5)
SWEP.AimAng=Angle(1.2,-3.5,0)
SWEP.ShowWorldModel=false
SWEP.MaxRoundCapacity=8
SWEP.TakesLargeIron=true
SWEP.ReloadNoise={"snd_jack_coilgunreload.wav",70,100}
SWEP.ViewModelBoneMods={
	["Main Frame"]={ scale=Vector(0.009, 0.009, 0.009), pos=Vector(0, 0, 0), angle=Angle(0, 0, 0) }
}
SWEP.VElements={
	["hurr"]={ type="Quad", bone="Main Frame", rel="", pos=Vector(-3, -1.6, 1), angle=Angle(0, -90, 60), size=0.025, draw_func=JackIndFunGunAmmoDisplay},
	["flarg"]={ type="Quad", bone="Main Frame", rel="", pos=Vector(-3.5, 1.1, 1.4), angle=Angle(0, -90, 90), size=0.025, draw_func=JackIndFunGunIronDisplay},
	["arf"]={ type="Quad", bone="Main Frame", rel="", pos=Vector(-4.3, 1.6, 1.55), angle=Angle(0, -90, 75), size=0.025, draw_func=JackIndFunGunIronChamberDisplay},
	["lawl"]={ type="Model", model="models/hunter/blocks/cube025x125x025.mdl", bone="Main Frame", rel="", pos=Vector(-3.4, -.5, .5), angle=Angle(0, 90, 0), size=Vector(0.05, 0.05, 0.05), color=Color(255, 255, 255, 255), surpresslightning=true, material="models/debug/debugwhite", skin=0, bodygroup={} },
	["narg"]={ type="Model", model="models/props_c17/oildrum001.mdl", bone="Main Frame", rel="", pos=Vector(7, -.2, 1.5), angle=Angle(90, 0, 0), size=Vector(.06, .06, .03), color=Color(255, 255, 255, 255), surpresslightning=true, material="models/debug/debugwhite", skin=0, bodygroup={} },
	["lol"]={ type="Model", model="models/mass_effect_3/weapons/smgs/n7 jurricane.mdl", bone="Main Frame", rel="", pos=Vector(.8, -.2, .7), angle=Angle(0, 90, 0), size=Vector(.85, .85, .85), color=Color(255, 255, 255, 255), surpresslightning=false, material="", skin=0, bodygroup={} },
	["derp"]={ type="Model", model="models/mass_effect_3/weapons/misc/jhermal clip.mdl", bone="Slide", rel="", pos=Vector(-2.3, -.25, -.3), angle=Angle(0, 0, 0), size=Vector(0.25, 0.25, 0.25), color=Color(255, 255, 255, 255), surpresslightning=false, material="", skin=0, bodygroup={} },
	["herp"]={ type="Model", model="models/mass_effect_3/weapons/misc/jeatsink.mdl", bone="Mag", rel="", pos=Vector(0.1, 0, 3), angle=Angle(180, 90, 81), size=Vector(1.299, 0.699, 1), color=Color(255, 255, 255, 255), surpresslightning=false, material="", skin=0, bodygroup={} },
	["herpitty"]={ type="Quad", bone="Main Frame", rel="", pos=Vector(10, -.72, 4.65), angle=Angle(0, -90, 90), size=0.025, draw_func=SWEP.FrontSight},
	["derpitty"]={ type="Quad", bone="Main Frame", rel="", pos=Vector(-7, -.66, 4.5), angle=Angle(0, -90, 90), size=0.025, draw_func=SWEP.RearSight}
}
SWEP.WElements={
	["lol"]={ type="Model", model="models/mass_effect_3/weapons/smgs/n7 jurricane.mdl", bone="ValveBiped.Bip01_R_Hand", rel="", pos=Vector(4.181, 1.363, -2.5), angle=Angle(180, 90, 0), size=Vector(.85, .85, .85), color=Color(255, 255, 255, 255), surpresslightning=false, material="", skin=0, bodygroup={} }
}

local AlreadyFired=false
local BurstCoolSoundPlayed=false
local AlertSoundPlayed=false

function SWEP:Initialize()
	self:SetWeaponHoldType("revolver")
	self.ChargingSound=CreateSound(self.Weapon,"snd_jack_highchargeloop.wav")
	self.ChargingSound:SetSoundLevel(60)
	self.CurrentCapacitorCharge=0
	self.NewCartridge=true
	self.dt.Energy=1.005
	self.dt.Mass=self.MaxRoundCapacity
	self.RoundChambered=false
	
	self:SCKInitialize()
end

function SWEP:SetupDataTables()
	self:DTVar("Int",0,"State") -- 1=drawing, 2=idle, 3=charging, 4=venting, 5=reloading, 6=holstered, 7=chambering round, 8=locked
	self:DTVar("Float",0,"Heat")
	self:DTVar("Float",1,"Energy")
	self:DTVar("Int",3,"Mass")
	self:DTVar("Int",1,"Sprint")
	self:DTVar("Int",2,"Aim")
end

function SWEP:Deploy()
	GlobalJackyFGHGDeploy(self)
end

function SWEP:PrimaryAttack()
	if(self.dt.Sprint>10)then return end
	if not(self.dt.State==2)then return end
	if(self.dt.Energy<=0)then return end
	if not(self.RoundChambered)then
		self:LoadUp()
		return
	end
	if((self.PowerType=="Radiosotope Thermoelectric Generator/Battery Module")and(self.dt.Energy<.59))then return end
	self:SetNextPrimaryFire(CurTime()+.025)
	local ShootPos=self.Owner:GetShootPos()+self.Owner:GetAimVector()*20
	self.ChargingSound:Play()
	self.dt.State=3
	if(self.CurrentCapacitorCharge<1)then self.CurrentCapacitorCharge=1 end
	self.NextChargingSoundTime=CurTime()+2
	AlreadyFired=false
	BurstCoolSoundPlayed=false
end

function SWEP:FireProjectile()
	if(self.Owner:KeyDown(IN_SPEED))then self.dt.State=2 return end
	if(AlreadyFired)then return end
	AlreadyFired=true

	self.ChargingSound:Stop()
	self.CurrentCapacitorCharge=0
	self.dt.State=8
	timer.Simple(.75,function()
		if(IsValid(self))then
			self.dt.State=2
			if(self.Owner:KeyDown(IN_ATTACK))then self:LoadUp() end
		end
	end)
	self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	self.RoundChambered=false

	self.dt.Heat=math.Clamp(self.dt.Heat+.075*self.HeatMul,0,1)
	local Loss=(((self.dt.Heat)^5/40)+.005)*self.ConsumptionMul
	self.dt.Energy=self.dt.Energy-Loss
	
	local WillBurst=false
	if(self.dt.Heat>=.99)then
		WillBurst=true
	end
	
	self:EmitSound("snd_jack_coilgunfire_"..tostring(math.random(1,3))..".wav",65,100)
	
	if(CLIENT)then return end
	
	umsg.Start("JackysFGBoolChange")
	umsg.Entity(self)
	umsg.String("RoundChambered")
	umsg.Bool(self.RoundChambered)
	umsg.End()
	
	umsg.Start("JackysFGFloatChange")
	umsg.Entity(self)
	umsg.String("CurrentCapacitorCharge")
	umsg.Float(0)
	umsg.End()
	
	//sound.Play("snd_jack_coilgunfire.wav",self:GetPos(),90,100)

	local BaseShootPos=self.Owner:GetShootPos()
	local AimVec=self.Owner:GetAimVector()
	local ShootPos=BaseShootPos+AimVec*20+self.Owner:GetRight()-self.Owner:GetUp()
	
	local CheckTraceData={start=BaseShootPos,endpos=ShootPos,filter=self.Owner}
	local CheckTrace=util.TraceLine(CheckTraceData)
	if(CheckTrace.Hit)then ShootPos=BaseShootPos end
	
	local Slam=ents.Create("ent_jack_ferrousprojectile")
	Slam:SetPos(ShootPos)
	Slam.Owner=self.Owner
	Slam.Weapon=self.Weapon
	Slam.InitialFlightDirection=AimVec
	Slam.InitialFlightSpeed=250 -- subsonic
	Slam.OverallSize=2.8
	Slam:Spawn()
	Slam:Activate()
	
	local Size=9
	self.Owner:SetEyeAngles(self.Owner:EyeAngles()+Angle(-Size,-Size/2,0))
	self.Owner:ViewPunch(Angle(-Size/2,-Size/3,0))
	local Derp=self.Owner:GetGroundEntity()
	if not((IsValid(Derp))or(Derp:IsWorld()))then
		self.Owner:SetVelocity(-AimVec*Size*25)
	end
	
	if(WillBurst)then self:BurstCool() end
end

function SWEP:LoadUp()
	if not(self.dt.Mass>0)then return end
	self.dt.State=7
	self:EmitSound("snd_jack_coilgunchamber.wav",70,100)
	if(SERVER)then self.dt.Mass=self.dt.Mass-1 end
	timer.Simple(.25,function()
		if(IsValid(self))then
			self.dt.State=2
			self.RoundChambered=true
			if(SERVER)then
				umsg.Start("JackysFGBoolChange")
				umsg.Entity(self)
				umsg.String("RoundChambered")
				umsg.Bool(self.RoundChambered)
				umsg.End()
			end
			if(self.Owner:KeyDown(IN_ATTACK))then self:PrimaryAttack() end
		end
	end)
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
		self.CurrentCapacitorCharge=math.Clamp(self.CurrentCapacitorCharge+.35,1,30)
		local Pitch=math.Clamp(((self.CurrentCapacitorCharge/2+50)/100)*255,1,250)
		self.ChargingSound:ChangePitch(Pitch,0)
		self.VElements["derp"].pos.x=-2.3
	else
		if(self.CurrentCapacitorCharge>0)then
			self.CurrentCapacitorCharge=math.Clamp(self.CurrentCapacitorCharge-2.5,0,100)
			local Pitch=math.Clamp(((self.CurrentCapacitorCharge/2+50)/100)*255,1,254)
			self.ChargingSound:ChangePitch(Pitch,0)
			if(self.CurrentCapacitorCharge==0)then self.ChargingSound:Stop() end
		end
		if(State==7)then
			self.VElements["derp"].pos.x=self.VElements["derp"].pos.x-.008
		elseif(State==2)then
			self.VElements["derp"].pos.x=-2.3
		end
	end
	self:NextThink(CurTime()+.01)
	return true
end

function SWEP:BurstCool()
	if(self.dt.State==4)then return end
	self.dt.State=4
	
	self.ChargingSound:Stop()
	self.CurrentCapacitorCharge=0
	if(SERVER)then
		umsg.Start("JackysFGFloatChange")
		umsg.Entity(self)
		umsg.String("CurrentCapacitorCharge")
		umsg.Float(self.CurrentCapacitorCharge)
		umsg.End()
	end

	self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	self.Owner:GetViewModel():SetPlaybackRate(.25)
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	if not(BurstCoolSoundPlayed)then
		BurstCoolSoundPlayed=true
		self.Weapon:EmitSound("snd_jack_coilgunvent.wav",70,100)
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
	GlobalJackyFGHGLoadEnCartNoPrim(self,cartridge,powerType,heatMul,consumptionMul,charge)
end

function SWEP:LoadIronSlug(cartridge)
	GlobalJackyLoadIronSlug(self,cartridge)
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
		if(Wep:GetClass()=="wep_jack_fungun_iota")then
			if(Wep.dt.State==3)then
				if(Wep.CurrentCapacitorCharge>20)then
					Wep:FireProjectile()
				else
					Wep.dt.State=2
				end
			end
			AlertSoundPlayed=false
		end
	end
end
hook.Add("KeyRelease","JackysIotaFungunFire",TriggerFire)

local function GunThink()	
	for key,wep in pairs(ents.FindByClass("wep_jack_fungun_iota"))do
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
hook.Add("Think","JackysIotaFunGunThinking",GunThink)