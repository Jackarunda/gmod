SWEP.Base="wep_jack_fungun_base_master"

if(SERVER)then
	AddCSLuaFile("shared.lua")
end

if(CLIENT)then
	SWEP.rtmat=Material("models/mat_jack_rendertarget")
	SWEP.FGScope=GetRenderTarget("Jacky_FG_Scope",400,400,false)
	SWEP.rtmat:SetTexture("$basetexture",SWEP.FGScope)
	SWEP.ScopeTex=surface.GetTextureID("models/mat_jack_scope")

	SWEP.PrintName="LongGun Alpha"
	SWEP.Slot=3
	SWEP.WepSelectIcon=surface.GetTextureID("vgui/mat_jack_fgalphalong_wsi")
	killicon.Add("wep_jack_fungun_alpha_long","vgui/mat_jack_fgalphalong_ki",Color(255,255,255,255))
end

SWEP.ViewModelFOV=75
SWEP.ViewModelFlip=true
SWEP.ViewModel="models/weapons/v_snip_awj.mdl"
SWEP.WorldModel="models/weapons/w_357.mdl"
SWEP.SwayScale=1.75
SWEP.BobScale=1.75

function SWEP:FrontSight()
	surface.SetDrawColor(255,255,255,255)
	surface.SetTexture(self.ScopeTex)
	surface.DrawTexturedRect(-10,-8,37,37)
end

SWEP.MouseAdjust=.5
SWEP.DefaultBobSway=2
SWEP.SprintPos=Vector(-5,-1,1)
SWEP.SprintAng=Angle(20,-50,50)
SWEP.AimPos=Vector(3.95,-2.6,.2)
SWEP.AimAng=Angle(0,0,1)
SWEP.ShowViewModel=true
SWEP.ShowWorldModel=false
SWEP.ReloadNoise={"snd_jack_heavylaserreload.wav",70,100}
SWEP.ViewModelBoneMods={
	["gun.bone"]={ scale=Vector(0.009, 0.009, 0.009), pos=Vector(0, 0, 0), angle=Angle(0, 0, 0) },
	["bone.bullet1"]={ scale=Vector(0.009, 0.009, 0.009), pos=Vector(0, 0, 0), angle=Angle(0, 0, 0) },
	["bone.bullet02"]={ scale=Vector(0.009, 0.009, 0.009), pos=Vector(0, 0, 0), angle=Angle(0, 0, 0) },
	["bone.bullet03"]={ scale=Vector(0.009, 0.009, 0.009), pos=Vector(0, 0, 0), angle=Angle(0, 0, 0) },
	["bone.bullet04"]={ scale=Vector(0.009, 0.009, 0.009), pos=Vector(0, 0, 0), angle=Angle(0, 0, 0) },
	["bone.bullet05"]={ scale=Vector(0.009, 0.009, 0.009), pos=Vector(0, 0, 0), angle=Angle(0, 0, 0) },
	["bone.bullet06"]={ scale=Vector(0.009, 0.009, 0.009), pos=Vector(0, 0, 0), angle=Angle(0, 0, 0) },
	["bone.bullet07"]={ scale=Vector(0.009, 0.009, 0.009), pos=Vector(0, 0, 0), angle=Angle(0, 0, 0) },
	["bone.bullet08"]={ scale=Vector(0.009, 0.009, 0.009), pos=Vector(0, 0, 0), angle=Angle(0, 0, 0) },
	["bone.bullet09"]={ scale=Vector(0.009, 0.009, 0.009), pos=Vector(0, 0, 0), angle=Angle(0, 0, 0) }
}
SWEP.VElements={
	["hurr"]={ type="Quad", bone="gun.bone", rel="", pos=Vector(-2.75, 2.75, -1.9), angle=Angle(90, -20, 180), size=.04, draw_func=JackIndFunGunAmmoDisplay},
	["narg"]={ type="Model", model="models/mass_effect_3/weapons/misc/jeatsink.mdl", bone="bolt.bone", rel="", pos=Vector(-5, 1.8, 0), angle=Angle(0, -90, 0), size=Vector(.7, .3, .9), color=Color(255, 255, 255, 255), surpresslightning=true, material="models/debug/debugwhite", skin=0, bodygroup={} },
	["lol"]={ type="Model", model="models/mass_effect_3/weapons/sniper_rifles/n7 jaliant.mdl", bone="gun.bone", rel="", pos=Vector(-0.7, 1.2, .2), angle=Angle(-90, 0, 90), size=Vector(1, 1, 1), color=Color(255, 255, 255, 255), surpresslightning=false, material="", skin=0, bodygroup={} },
	["herp"]={ type="Model", model="models/mass_effect_3/weapons/misc/jeatsink.mdl", bone="bone.shell1", rel="", pos=Vector(1, 0, 0), angle=Angle(-90, -90, 0), size=Vector(1, 1, 1), color=Color(255, 255, 255, 255), surpresslightning=false, material="", skin=0, bodygroup={} },
	["durr"]={ type="Model", model="models/hunter/blocks/cube1x150x1.mdl", bone="gun.bone", rel="", pos=Vector(.4, 4.725, .2), angle=Angle(90, 90, 0), size=Vector(.015, .0001, .015), color=Color(255, 255, 255, 255), surpresslightning=true, material="models/mat_jack_rendertarget", skin=0, bodygroup={} },
	["flurr"]={ type="Model", model="models/hunter/blocks/cube1x150x1.mdl", bone="gun.bone", rel="", pos=Vector(.42, 4.725, .2), angle=Angle(90, 90, 0), size=Vector(.015, .0001, .015), color=Color(255, 255, 255, 35), surpresslightning=false, material="debug/env_cubemap_model", skin=0, bodygroup={} },
	["herpitty"]={ type="Quad", bone="gun.bone", rel="", pos=Vector(.45, 4.99, -.01), angle=Angle(90, 0, 180), size=.025, draw_func=SWEP.FrontSight}
}
SWEP.WElements={
	["lol"]={ type="Model", model="models/mass_effect_3/weapons/sniper_rifles/n7 jaliant.mdl", bone="ValveBiped.Bip01_R_Hand", rel="", pos=Vector(3.181, 1.2, -3.5), angle=Angle(180, 90, 0), size=Vector(1.1, 1.1, 1.1), color=Color(255, 255, 255, 255), surpresslightning=false, material="", skin=0, bodygroup={} }
}

local BurstCoolSoundPlayed=false
local ReleaseSoundPlayed=false
local LaserEndPlayed=false

function SWEP:Initialize()
	self:SetWeaponHoldType("ar2")
	self.LasingSound=CreateSound(self.Weapon,"snd_jack_heavylaserloop.wav")
	self.NewCartridge=true
	self.dt.Ammo=1.005

	self:SCKInitialize()
end

function SWEP:Deploy()
	GlobalJackyFGLGDeploy(self)
end

function SWEP:SetupDataTables()
	self:DTVar("Int",0,"State") -- 1=drawing, 2=idle, 3=firing, 4=venting, 5=reloading, 6=holstered
	self:DTVar("Float",0,"Heat")
	self:DTVar("Float",1,"Ammo")
	self:DTVar("Int",1,"Sprint")
	self:DTVar("Int",2,"Aim")
end

function SWEP:PrimaryAttack()
	if(self.dt.Sprint>10)then return end
	if not(self.dt.State==2)then return end
	if(self.dt.Ammo<=0)then return end
	self:SetNextPrimaryFire(CurTime()+.2)
	local ShootPos=self.Owner:GetShootPos()+self.Owner:GetAimVector()*20
	if(SERVER)then self:EmitSound("snd_jack_laserbegin.wav",70,85) end
	self.LasingSound:Play()
	self.dt.State=3
	ReleaseSoundPlayed=false
	BurstCoolSoundPlayed=false
	LaserEndPlayed=false
	if(SERVER)then
		umsg.Start("JackysDynamicFGBobSwayScaling")
		umsg.Entity(self)
		umsg.Float(.5)
		umsg.End()
	end
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
				WantSomeIceWithThatBurn:SetDamage(math.Rand(.7,1))
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
				
				if not(self.NextBurnSoundEmitTime)then self.NextBurnSoundEmitTime=CurTime() end
				if(self.NextBurnSoundEmitTime<CurTime())then
					sound.Play("snd_jack_heavylaserburn.wav",Tress.HitPos,70,100)
					self.NextBurnSoundEmitTime=CurTime()+.075
				end
				if(math.random(1,2)==1)then
					local Poof=EffectData()
					Poof:SetOrigin(Tress.HitPos)
					Poof:SetScale(1)
					Poof:SetNormal(Tress.HitNormal)
					if((Tress.MatType==MAT_CONCRETE)or(Tress.MatType==MAT_METAL)or(Tress.MatType==MAT_COMPUTER)or(Tress.MatType==MAT_GRATE)or(Tress.MatType==MAT_TILE)or(Tress.MatType==MAT_GLASS)or(Tress.MatType==MAT_SAND))then
						Poof:SetStart(Tress.Entity:GetVelocity())
						util.Effect("eff_jack_tinymelt",Poof,true,true)
						Poof:SetScale(.06)
						util.Effect("eff_jack_heavyfadingmelt",Poof,true,true)
					else
						util.Effect("eff_jack_tinyburn",Poof,true,true)
					end
				end
				local Derp=EffectData()
				Derp:SetOrigin(Tress.HitPos)
				Derp:SetScale(1)
				Derp:SetNormal(Tress.HitNormal)
				util.Effect("eff_jack_heavylaserbeamimpact",Derp,true,true)
			end
		end
		local Derp=EffectData()
		Derp:SetStart(stert)
		Derp:SetOrigin(Tress.HitPos)
		Derp:SetScale(1)
		util.Effect("eff_jack_heavylaserbeam",Derp,true,true)
	end
end

function SWEP:Think()
	self.LaserShake=VectorRand()*math.Rand(.0033,.017)
	
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
			self.LasingSound:Stop()
			self.dt.State=2
		end
		return
	end

	local BaseShootPos=self.Owner:GetShootPos()
	local AimVec=self.Owner:GetAimVector()
	local Aim=self.dt.Aim/100
	local ShootPos=BaseShootPos+self.Owner:GetRight()*(6.5-6.5*Aim)-self.Owner:GetUp()*(3)+AimVec*30
	
	if(State==3)then
		self.dt.Heat=math.Clamp(Heat+.0012*self.HeatMul,0,1)
		local Ammo=self.dt.Ammo
		local Loss=((.0028+.18*Heat^4)*.01)*2*self.ConsumptionMul //longguns use energy at double the rate
		//self.Owner:PrintMessage(HUD_PRINTCENTER,Loss)
		self.dt.Ammo=Ammo-Loss
		if not(self.NextLasingSoundTime)then self.NextLasingSoundTime=CurTime()+.1 end
		if(self.NextLasingSoundTime<CurTime())then
			self.LasingSound:Stop()
			self.LasingSound:Play()
			self.NextLasingSoundTime=CurTime()+3.15
		end
		self:LaserTrace(ShootPos,BaseShootPos+AimVec*40000,{self.Owner},1)
	end
end

function SWEP:BurstCool()
	if((self.dt.State==4)or(self.dt.State==5))then return end
	self.dt.State=5

	self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	self.Owner:GetViewModel():SetPlaybackRate(.4)
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	if not(BurstCoolSoundPlayed)then
		BurstCoolSoundPlayed=true
		self.Weapon:EmitSound("snd_jack_heavylaservent.wav",70,100)
	end
	timer.Simple(1.4,function()
		if(IsValid(self))then
			self.dt.State=4
			local Pewf=EffectData()
			Pewf:SetOrigin(self.Owner:GetShootPos()+self.Owner:GetAimVector()*20+self.Owner:GetRight()*4)
			Pewf:SetStart(self.Owner:GetVelocity())
			util.Effect("eff_jack_instantvent",Pewf,true,true)
		end
	end)
	timer.Simple(2.4,function()
		if(IsValid(self))then
			local Pewf=EffectData()
			Pewf:SetOrigin(self.Owner:GetShootPos()+self.Owner:GetAimVector()*20+self.Owner:GetRight()*4)
			Pewf:SetStart(self.Owner:GetVelocity())
			util.Effect("eff_jack_instantvent",Pewf,true,true)
		end
	end)
	timer.Simple(2.9,function()
		if(IsValid(self))then
			local Pewf=EffectData()
			Pewf:SetOrigin(self.Owner:GetShootPos()+self.Owner:GetAimVector()*20+self.Owner:GetRight()*4)
			Pewf:SetStart(self.Owner:GetVelocity())
			util.Effect("eff_jack_instantvent",Pewf,true,true)
		end
	end)
	timer.Simple(3.3,function()
		if(IsValid(self))then
			self.dt.State=2
			BurstCoolSoundPlayed=false
		end
	end)
end

function SWEP:Reload()
	GlobalJackyFGLongReloadKey(self)
end

function SWEP:LoadEnergyCartridge(cartridge,powerType,heatMul,consumptionMul,charge)
	GlobalJackyFGLGLoadEnCart(self,cartridge,powerType,heatMul,consumptionMul,charge,1)
end

function SWEP:Holster()
	if not(self.dt.State==2)then return false end
	self.LasingSound:Stop()
	self.dt.State=6
	self.dt.Sprint=0
	self.dt.Aim=0
	self:SCKHolster()
	return true
end

function SWEP:OnDrop()
	self.LasingSound:Stop()
end

if(CLIENT)then
	function SWEP:DrawHUD()
		-- *overwrite*  :3
	end
	local OldSprint,OldAim=0,0
	function SWEP:GetViewModelPosition(pos,ang)
		OldAim=Lerp(FrameTime()*10,OldAim,self.dt.Aim)
		local Aim=OldAim/100
		local AimInv=1-Aim
		
		local Right=ang:Right()
		local Up=ang:Up()
		local Forward=ang:Forward()

		pos=pos-Right*1-Up*1
		
		if(Aim>0)then
			pos=pos+Right*self.AimPos.x*Aim+Forward*self.AimPos.y*Aim+Up*self.AimPos.z*Aim
			ang:RotateAroundAxis(Right,self.AimAng.p*Aim)
			ang:RotateAroundAxis(Up,self.AimAng.y*Aim)
			ang:RotateAroundAxis(Forward,self.AimAng.r*Aim)
		end
		
		if(self.dt.State==3)then
			pos=pos+self.LaserShake/3
		end
		OldSprint=Lerp(FrameTime()*10,OldSprint,self.dt.Sprint)
		local Held=OldSprint/100
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
		
		--This is under the ViewModelDrawn in the shared lua
		self.Jack_FG_Scoped=true
		
		self:SCKViewModelDrawn()
	end
	function SWEP:DrawWorldModel()
		self:SCKDrawWorldModel()
	end
end

/*---------------- These things operate OUTSIDE of the weapon --------------------------*/

local function PlayEndSound(ply,key)
	if not(key==IN_ATTACK)then return end
	local Wep=ply:GetActiveWeapon()
	if(IsValid(Wep))then
		if(Wep:GetClass()=="wep_jack_fungun_alpha_long")then
			if(Wep.dt.State==3)then
				if not(ReleaseSoundPlayed)then
					ReleaseSoundPlayed=true
					if(SERVER)then Wep:EmitSound("snd_jack_laserend.wav",70,85) end
				end
				if(SERVER)then
					umsg.Start("JackysDynamicFGBobSwayScaling")
					umsg.Entity(Wep)
					umsg.Float(Wep.DefaultBobSway)
					umsg.End()
				end
				Wep.LasingSound:Stop()
				Wep.dt.State=2
			end
		end
	end
end
hook.Add("KeyRelease","JackysAlphaLongLaserReleaseSound",PlayEndSound)

local function GunThink()
	for key,wep in pairs(ents.FindByClass("wep_jack_fungun_alpha_long"))do
		local Heat=wep.dt.Heat
		if(Heat)then
			local State=wep.dt.State
			if(State==3)then
				if((wep.dt.Ammo<=0)or(wep.Owner:KeyDown(IN_SPEED)))then
					if not(LaserEndPlayed)then
						LaserEndPlayed=true
						if(SERVER)then wep:EmitSound("snd_jack_laserend.wav",70,85) end
					end
					if(SERVER)then
						umsg.Start("JackysDynamicFGBobSwayScaling")
						umsg.Entity(wep)
						umsg.Float(wep.DefaultBobSway)
						umsg.End()
					end
					wep.LasingSound:Stop()
					wep.dt.State=2
				elseif(Heat==1)then
					if not(LaserEndPlayed)then
						LaserEndPlayed=true
						if(SERVER)then wep:EmitSound("snd_jack_laserend.wav",70,85) end
					end
					if(SERVER)then
						umsg.Start("JackysDynamicFGBobSwayScaling")
						umsg.Entity(wep)
						umsg.Float(wep.DefaultBobSway)
						umsg.End()
					end
					wep.LasingSound:Stop()
					wep:BurstCool() -- emergency cooling interrupt, protect the weapon from dumbass users
					wep.dt.Heat=.9999
				end
			end
			if(State==4)then
				wep.dt.Heat=math.Clamp(Heat-.0075,0,1)
			else
				wep.dt.Heat=math.Clamp(Heat-.0001,0,1)
			end
		end
	end
end
hook.Add("Think","JackysAlphaLongFunGunThinking",GunThink)