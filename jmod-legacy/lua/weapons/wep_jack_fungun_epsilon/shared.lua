SWEP.Base="wep_jack_fungun_base_master"

if(SERVER)then
	AddCSLuaFile("shared.lua")
end

if(CLIENT)then
	SWEP.PrintName="Handgun Epsilon"
	SWEP.Slot=1
	SWEP.WepSelectIcon=surface.GetTextureID("vgui/mat_jack_fgepsilon_wsi")
	killicon.Add("wep_jack_fungun_epsilon","vgui/mat_jack_fgepsilon_wsi",Color(255,255,255,255))
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
	surface.SetDrawColor(255,20,20,200*Flicker)
	surface.DrawLine(19,53,19,100)
	surface.DrawLine(8,53,-10,53)
	surface.DrawLine(30,53,45,53)
end
function SWEP:RearSight()
	if not(self.DisplaysOn)then return end
	local Flicker=math.Rand(.5,1)
	if(self.dt.Ammo<.01)then Flicker=math.Rand(0,.5) end
	surface.SetDrawColor(255,255,255,100*Flicker)
	surface.DrawLine(18,55,12,75)
	surface.DrawLine(18,55,24,75)
	surface.DrawLine(12,75,24,75)
end

SWEP.NextChargeTime=CurTime()
SWEP.DisplaysOn=false
SWEP.AimPos=Vector(-2.7, 2,-1)
SWEP.AimAng=Angle(1.2,-3.5,0)
SWEP.SprintPos=Vector(2.539,-14.44,-0.441)
SWEP.SprintAng=Angle(74,-7,0)
SWEP.ShowWorldModel=false
SWEP.ReloadNoise={"snd_jack_icereload.wav",70,100}
if(CLIENT)then
	SWEP.ScrT=surface.GetTextureID("models/shadertest/shader4")
end
SWEP.ViewModelBoneMods={
	["Main Frame"]={ scale=Vector(0.009, 0.009, 0.009), pos=Vector(0, 0, 0), angle=Angle(0, 0, 0) }
}
SWEP.VElements={
	["hurr"]={ type="Quad", bone="Main Frame", rel="", pos=Vector(0, -1.4, 1.25), angle=Angle(0, -90, 60.34), size=0.025, draw_func=JackIndFunGunAmmoDisplay},
	//["murr"]={ type="Quad", bone="Main Frame", rel="", pos=Vector(-.65, -.38, 2.7), angle=Angle(0, -90, 60), size=0.03, draw_func=function(self)
	//	surface.SetDrawColor(128,128,128,math.Rand(10,70))
	//	surface.DrawRect(1,1,24,25)
	//	surface.SetDrawColor(255,255,255,255)
	//	surface.DrawLine(0,13,3,13)
	//	surface.DrawLine(12,0,12,3)
	//	surface.DrawLine(24,13,21,13)
	//	surface.DrawLine(12,25,12,22)
	//	if(self.dt.Size>=5)then surface.DrawRect(12,13,1,1) end
	//	surface.DrawOutlinedRect(0,0,25,26)
	//end},
	["narg"]={ type="Model", model="models/mass_effect_3/weapons/misc/battery jack.mdl", bone="Main Frame", rel="", pos=Vector(4.5, 0, -0.2), angle=Angle(0, 180, 0), size=Vector(0.2, 0.2, 0.2), color=Color(255, 255, 255, 255), surpresslightning=false, material="", skin=0, bodygroup={} },
	["blarg"]={ type="Model", model="models/mass_effect_3/weapons/misc/battery jack.mdl", bone="Main Frame", rel="", pos=Vector(4.5, 0, -0.2), angle=Angle(0, 180, 0), size=Vector(0.35, 0.2, 0.1), color=Color(255, 255, 255, 255), surpresslightning=false, material="", skin=0, bodygroup={} },
	["flarg"]={ type="Model", model="models/mass_effect_3/weapons/misc/battery jack.mdl", bone="Main Frame", rel="", pos=Vector(4.5, 0, -0.2), angle=Angle(0, 180, 0), size=Vector(0.35, 0.2, 0.1), color=Color(255, 255, 255, 255), surpresslightning=false, material="", skin=0, bodygroup={} },
	["lol"]={ type="Model", model="models/mass_effect_3/weapons/pistols/m-5 jhalanx.mdl", bone="Main Frame", rel="", pos=Vector(0, 0, 1), angle=Angle(0, 90, 0), size=Vector(1, 1, 1), color=Color(255, 255, 255, 255), surpresslightning=false, material="", skin=0, bodygroup={} },
	["derp"]={ type="Model", model="models/mass_effect_3/weapons/misc/battery jack.mdl", bone="Slide", rel="", pos=Vector(1.5, 0, -1), angle=Angle(0, 0, 0), size=Vector(0.3, 0.2, 0.1), color=Color(255, 255, 255, 255), surpresslightning=false, material="", skin=0, bodygroup={} },
	["herp"]={ type="Model", model="models/mass_effect_3/weapons/misc/jeatsink.mdl", bone="Mag", rel="", pos=Vector(0.1, 0, 2), angle=Angle(180, 90, 81), size=Vector(1.299, 0.699, 1), color=Color(255, 255, 255, 255), surpresslightning=false, material="", skin=0, bodygroup={} },
	//["durr"]={ type="Model", model="models/hunter/blocks/cube1x150x1.mdl", bone="Main Frame", rel="", pos=Vector(-.8, 0, 2.35), angle=Angle(0, 90, 30), size=Vector(.015, .001, .015), color=Color(255, 255, 255, 255), surpresslightning=true, material="models/screenspacewithzoom", skin=0, bodygroup={} },
	//["lawl"]={ type="Model", model="models/hunter/blocks/cube1x150x1.mdl", bone="Main Frame", rel="", pos=Vector(-.5, 0, 2.175), angle=Angle(0, 90, 30), size=Vector(.018, .01, .018), color=Color(175, 175, 175, 255), surpresslightning=false, material="phoenix_storms/gear", skin=0, bodygroup={} },
	["herpitty"]={ type="Quad", bone="Main Frame", rel="", pos=Vector(10, -.48, 5.25), angle=Angle(0, -90, 90), size=0.025, draw_func=SWEP.FrontSight},
	["derpitty"]={ type="Quad", bone="Main Frame", rel="", pos=Vector(-7, -.45, 5), angle=Angle(0, -90, 90), size=0.025, draw_func=SWEP.RearSight}
}
SWEP.WElements={
	["lol"]={ type="Model", model="models/mass_effect_3/weapons/pistols/m-5 jhalanx.mdl", bone="ValveBiped.Bip01_R_Hand", rel="", pos=Vector(3.5, 1, -3), angle=Angle(180, 90, 0), size=Vector(1, 1, 1), color=Color(255, 255, 255, 255), surpresslightning=false, material="", skin=0, bodygroup={} }
}

local AlreadyFired=false
local BurstCoolSoundPlayed=false
local AlertSoundPlayed=false

function SWEP:Initialize()
	self:SetWeaponHoldType("revolver")
	self.FreezingSound=CreateSound(self.Weapon,"snd_jack_iceloop.wav")
	self.FreezingSound:SetSoundLevel(60)
	self.CurrentProjectileSize=0
	self.NewCartridge=true
	self.dt.Ammo=1.005
	
	self:SCKInitialize()
end

function SWEP:SetupDataTables()
	self:DTVar("Int",0,"State") -- 1=drawing, 2=idle, 3=freezing, 4=resetting, 5=reloading, 6=holstered
	self:DTVar("Float",0,"Size")
	self:DTVar("Float",1,"Ammo")
	self:DTVar("Int",1,"Sprint")
	self:DTVar("Int",2,"Aim")
end

function SWEP:Deploy()
	GlobalJackyFGHGDeploy(self)
end

function SWEP:PrimaryAttack()
	if(self.dt.State==3)then
		self:FinishFreezing()
		return
	end
	if not(self.dt.Size>5)then return end
	if not(self.dt.State==2)then return end
	if(self.dt.Sprint>15)then return end
	
	local BaseShootPos=self.Owner:GetShootPos()
	local AimVec=self.Owner:GetAimVector()
	local ShootPos=BaseShootPos+AimVec*20
	local CtD={start=BaseShootPos,endpos=ShootPos,filter=self.Owner}
	local Ct=util.TraceLine(CtD)
	if(Ct.Hit)then ShootPos=BaseShootPos end
	
	self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	
	self.dt.Ammo=math.Clamp(self.dt.Ammo-.0025,0,1)
	
	if(SERVER)then
		self.Weapon:EmitSound("snd_jack_iceshot.wav",70,100)
		self:EmitSound("snd_jack_iceshot.wav",100,80)
		self:EmitSound("snd_jack_iceshot.wav",60,120)
		
		local Size=self.dt.Size
		local Spike=ents.Create("ent_jack_projecticle")
		Spike:SetPos(ShootPos)
		Spike.Weapon=self.Weapon
		Spike.Owner=self.Owner
		Spike.InitialFlightDirection=(AimVec+self.Owner:GetVelocity():GetNormalized()*.1):GetNormalized()
		Spike.InitialFlightSpeed=160 -- about 184 mps
		Spike:SetDTFloat(0,Size)
		Spike:Spawn()
		Spike:Activate()
		
		Size=Size/7.5
		self.Owner:SetEyeAngles(self.Owner:EyeAngles()+Angle(-Size,-Size/2,0))
		self.Owner:ViewPunch(Angle(-Size/2,-Size/3,0))
		
		local Derp=self.Owner:GetGroundEntity()
		if not((IsValid(Derp))or(Derp:IsWorld()))then
			self.Owner:SetVelocity(-AimVec*Size*25)
		end
	end

	if(SERVER)then
		local Poof=EffectData()
		Poof:SetScale(1)
		Poof:SetNormal(AimVec)
		Poof:SetStart(self.Owner:GetVelocity())
		Poof:SetOrigin(ShootPos)
		util.Effect("eff_jack_coldmuzzle",Poof,true,true)

		umsg.Start("JackysEpsilonSetSizeZero")
		umsg.Entity(self)
		umsg.End()
	end
	self.CurrentProjectileSize=0
	self.dt.Size=0
	self.dt.State=4
	timer.Simple(.5,function()
		if(IsValid(self))then
			self.dt.State=2
			if(self.Owner:KeyDown(IN_ATTACK))then
				self:PrimaryAttack()
			elseif(self.Owner:KeyDown(IN_RELOAD))then
				self:Reload()
			end
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

	local State=self.dt.State
	local Size=self.dt.Size

	if((State==4)or(State==5))then return end
	if(self.Owner:InVehicle())then
		if(State==3)then
			self.FreezingSound:Stop()
			self.dt.State=2
		end
		return
	end
	
	local SizeAdd=-.05
	if(Size>5)then SizeAdd=.1 end
	self.VElements["narg"].pos=Vector(5+Size/90+SizeAdd,0,0)
	self.VElements["blarg"].pos=Vector(5,Size/110+SizeAdd,.5)
	self.VElements["flarg"].pos=Vector(5,-Size/110-SizeAdd,.5)
	
	local Ammo=self.dt.Ammo
	local Sprin=self.dt.Sprint/100

	local BaseShootPos=self.Owner:GetShootPos()
	local AimVec=self.Owner:GetAimVector()
	local ShootPos=BaseShootPos+self.Owner:GetRight()*4-self.Owner:GetUp()*(5-7*Sprin)+AimVec*(30-25*Sprin)
	
	if(State==3)then
		if not(self.NextFreezingSoundTime)then self.NextFreezingSoundTime=CurTime()+.1 end
		if(self.NextFreezingSoundTime<CurTime())then
			self.FreezingSound:Stop()
			self.FreezingSound:Play()
			self.FreezingSound:SetSoundLevel(50)
			self.NextFreezingSoundTime=CurTime()+1.5
		end
		local Add=.05
		if(self.Owner:WaterLevel()==3)then Add=.25 end
		self.CurrentProjectileSize=math.Clamp(Size+Add,1,100)
		self.dt.Size=self.CurrentProjectileSize
		
		if(math.random(1,4)==2)then
			if(SERVER)then
				local Shh=EffectData()
				Shh:SetOrigin(ShootPos+VectorRand()*math.Rand(0,5))
				Shh:SetStart(self.Owner:GetVelocity()+VectorRand()*math.Rand(0,10))
				Shh:SetScale(1)
				util.Effect("eff_jack_cold",Shh,true,true)
			end
		end
		
		local NewAmmo=Ammo-.00003*self.ConsumptionMul
		if(NewAmmo<=0)then self:FinishFreezing() end
		if(Size>=100)then self:FinishFreezing() end
		self.dt.Ammo=NewAmmo
	end
	self:NextThink(CurTime()+.01)
	return true
end

function SWEP:LoadEnergyCartridge(cartridge,powerType,heatMul,consumptionMul,charge)
	GlobalJackyFGHGLoadEnCart(self,cartridge,powerType,heatMul,consumptionMul,charge)
end

function SWEP:StartFreezing()
	if not(self.dt.State==2)then return end
	self.dt.State=4
	self.Weapon:EmitSound("snd_jack_beginice.wav",55,100)
	timer.Simple(.5,function()
		if(IsValid(self))then
			self.dt.State=3
		end
	end)
end

function SWEP:FinishFreezing()
	if not(self.dt.State==3)then return end
	self.FreezingSound:Stop()
	self.dt.State=4
	self.Weapon:EmitSound("snd_jack_endice.wav",55,100)
	timer.Simple(.75,function()
		if(IsValid(self))then
			self.dt.State=2
			if(self.Owner:KeyDown(IN_ATTACK))then
				self:PrimaryAttack()
			elseif(self.Owner:KeyDown(IN_RELOAD))then
				self:Reload()
			end
		end
	end)
end

if(CLIENT)then
	local function KillSize(data)
		local Wep=data:ReadEntity()
		Wep.CurrentProjectileSize=0
		if not(Wep.VElements)then return end
		Wep.VElements["narg"].pos=Vector(5,0,-.05)
		Wep.VElements["blarg"].pos=Vector(5,-.05,.5)
		Wep.VElements["flarg"].pos=Vector(5,.05,.5)
	end
	usermessage.Hook("JackysEpsilonSetSizeZero",KillSize)
end

function SWEP:Reload()
	if(self.dt.State==3)then
		self:FinishFreezing()
	else
		if(self.dt.Ammo>0)then
			if not(self.dt.Size>=100)then
				if(self.NextChargeTime<CurTime())then
					self.NextChargeTime=CurTime()+.6
					self:StartFreezing()
				end
			end
		end
	end
end

function SWEP:Holster()
	if not(self.dt.State==2)then return false end
	self.FreezingSound:Stop()
	self.dt.State=6
	self.dt.Sprint=0
	if(self.dt.State==3)then
		self:FinishFreezing()
	end
	self:SCKHolster()
	return true
end

function SWEP:OnDrop()
	self.FreezingSound:Stop()
end

if(CLIENT)then
	function SWEP:DrawHUD()
		//shit
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