SWEP.Base="wep_jack_fungun_base_master"

if(SERVER)then
	AddCSLuaFile("shared.lua")
end

if(CLIENT)then
	SWEP.PrintName="Handgun Eta"
	SWEP.Slot=1
	SWEP.WepSelectIcon=surface.GetTextureID("vgui/mat_jack_fgeta_wsi")
	killicon.Add("wep_jack_fungun_eta","vgui/mat_jack_fgeta_ki",Color(255,255,255,255))
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
	if(self.dt.Extension>0)then surface.SetDrawColor(100,100,100,255*Flicker) end
	surface.DrawLine(-35,20,93,20)
	surface.DrawLine(30,-40,30,90)
end
function SWEP:RearSight()
	if not(self.DisplaysOn)then return end
	local Flicker=math.Rand(.5,1)
	if(self.dt.Ammo<.01)then Flicker=math.Rand(0,.5) end
	surface.SetDrawColor(255,255,255,150*Flicker)
	if(self.dt.Extension>0)then surface.SetDrawColor(100,100,100,255*Flicker) end
	surface.DrawLine(-5,-18,63,52)
	surface.DrawLine(63,-18,-5,52)
end

SWEP.DisplaysOn=true
SWEP.SprintPos=Vector(2.539,-14.44,-0.441)
SWEP.SprintAng=Angle(74,-7,0)
SWEP.AimPos=Vector(-2.5, 2,-.5)
SWEP.AimAng=Angle(1.2,-3.5,0)
SWEP.ShowWorldModel=false
SWEP.ReloadNoise={"snd_jack_laserreload.wav",70,100}
SWEP.ViewModelBoneMods={
	["Main Frame"]={ scale=Vector(0.009, 0.009, 0.009), pos=Vector(0, 0, 0), angle=Angle(0, 0, 0) }
}
SWEP.VElements={
	["hurr"]={ type="Quad", bone="Main Frame", rel="", pos=Vector(-1.3, -.4, 2.5), angle=Angle(0, -90, 60.34), size=0.025, draw_func=JackIndFunGunAmmoDisplay},
	["narg"]={ type="Model", model="models/Items/AR2_Grenade.mdl", bone="Main Frame", rel="", pos=Vector(3.5, -0.2, .8), angle=Angle(2, 180, 5), size=Vector(1.1, 0.6, 0.6), color=Color(255, 255, 255, 255), surpresslightning=false, material="debug/env_cubemap_model", skin=0, bodygroup={} },
	["derp"]={ type="Model", model="models/Items/AR2_Grenade.mdl", bone="Main Frame", rel="", pos=Vector(5, -0.2, .8), angle=Angle(0, 0, 0), size=Vector(1.3, 0.5, 0.5), color=Color(255, 255, 255, 255), surpresslightning=false, material="debug/env_cubemap_model", skin=0, bodygroup={} },
	["flerp"]={ type="Model", model="models/Items/AR2_Grenade.mdl", bone="Main Frame", rel="", pos=Vector(5, -0.2, .8), angle=Angle(0, 0, 0), size=Vector(1.5, 0.4, 0.4), color=Color(255, 255, 255, 255), surpresslightning=false, material="debug/env_cubemap_model", skin=0, bodygroup={} },
	["lol"]={ type="Model", model="models/mass_effect_3/weapons/pistols/n7 eajle.mdl", bone="Main Frame", rel="", pos=Vector(-0.3, -0.2, 0.8), angle=Angle(0, 90, 0), size=Vector(1, 1, 1), color=Color(255, 255, 255, 255), surpresslightning=false, material="", skin=0, bodygroup={} },
	["lawl"]={ type="Model", model="models/Items/combine_rifle_ammo01.mdl", bone="Main Frame", rel="", pos=Vector(-1.2, -0.2, 1.2), angle=Angle(-90, 90, -90), size=Vector(.15, .15, .15), color=Color(100, 100, 100, 255), surpresslightning=false, material="phoenix_storms/gear", skin=0, bodygroup={} },
	["herp"]={ type="Model", model="models/mass_effect_3/weapons/misc/jeatsink.mdl", bone="Mag", rel="", pos=Vector(0.1, -.3, 2), angle=Angle(180, 90, 81), size=Vector(1.299, 0.699, 1), color=Color(255, 255, 255, 255), surpresslightning=false, material="", skin=0, bodygroup={} },
	["herpitty"]={ type="Quad", bone="Main Frame", rel="", pos=Vector(10, -1, 3.75), angle=Angle(0, -90, 90), size=0.025, draw_func=SWEP.FrontSight},
	["derpitty"]={ type="Quad", bone="Main Frame", rel="", pos=Vector(-7, -.98, 3.5), angle=Angle(0, -90, 90), size=0.025, draw_func=SWEP.RearSight}
}
SWEP.WElements={
	["lol"]={ type="Model", model="models/mass_effect_3/weapons/pistols/n7 eajle.mdl", bone="ValveBiped.Bip01_R_Hand", rel="", pos=Vector(3.181, 1.363, -3.182), angle=Angle(180, 90, 0), size=Vector(1, 1, 1), color=Color(255, 255, 255, 255), surpresslightning=false, material="", skin=0, bodygroup={} },
	["narg"]={ type="Model", model="models/Items/AR2_Grenade.mdl", bone="ValveBiped.Bip01_R_Hand", rel="", pos=Vector(6.75, 1.35, -3), angle=Angle(2, 180, 5), size=Vector(1.1, 0.6, 0.6), color=Color(255, 255, 255, 255), surpresslightning=false, material="debug/env_cubemap_model", skin=0, bodygroup={} },
	["derp"]={ type="Model", model="models/Items/AR2_Grenade.mdl", bone="ValveBiped.Bip01_R_Hand", rel="", pos=Vector(8.25, 1.35, -3), angle=Angle(0, 0, 0), size=Vector(1.3, 0.5, 0.5), color=Color(255, 255, 255, 255), surpresslightning=false, material="debug/env_cubemap_model", skin=0, bodygroup={} },
	["flerp"]={ type="Model", model="models/Items/AR2_Grenade.mdl", bone="ValveBiped.Bip01_R_Hand", rel="", pos=Vector(8.25, 1.35, -3), angle=Angle(0, 0, 0), size=Vector(1.3, 0.4, 0.4), color=Color(255, 255, 255, 255), surpresslightning=false, material="debug/env_cubemap_model", skin=0, bodygroup={} }
}

local LockPlayed=false
local AlreadyFired=false
local HardnessTable={
	[MAT_CONCRETE]=1,
	[MAT_METAL]=.9,
	[MAT_GRATE]=.8,
	[MAT_TILE]=1,
	[MAT_GLASS]=1,
	[MAT_WOOD]=.5,
	[MAT_DIRT]=.2,
	[MAT_FLESH]=.1,
	[MAT_ALIENFLESH]=.1,
	[MAT_ANTLION]=.1,
	[MAT_BLOODYFLESH]=.1,
	[MAT_PLASTIC]=.5,
	[MAT_COMPUTER]=.8,
	[MAT_VENT]=.8,
	[MAT_SAND]=.1,
	[MAT_CLIP]=.5,
	[MAT_FOLIAGE]=.25,
	[MAT_SLOSH]=.09
}

function SWEP:Initialize()
	self:SetWeaponHoldType("revolver")
	
	self.NewCartridge=true
	self.dt.Ammo=1.005
	
	self:SCKInitialize()
end

function SWEP:SetupDataTables()
	self:DTVar("Int",0,"State") -- 1=drawing, 2=idle, 3=charging, 4=venting, 5=reloading, 6=holstered
	self:DTVar("Float",0,"Extension")
	self:DTVar("Float",1,"Ammo")
	self:DTVar("Int",1,"Sprint")
	self:DTVar("Int",2,"Aim")
end

function SWEP:Deploy()
	GlobalJackyFGHGDeploy(self)
end

function SWEP:ReloadPile()
	if(self.dt.Ammo<=0)then return end
	self:SetNextPrimaryFire(CurTime()+3)
	timer.Simple(.75,function()
		if(IsValid(self))then
			self.dt.State=3
			self.Weapon:EmitSound("snd_jack_pilereload.wav",70,100)
			self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
			self.Owner:GetViewModel():SetPlaybackRate(.15)
			if(SERVER)then
				local Poof=EffectData()
				Poof:SetOrigin(self.Owner:GetShootPos()+self.Owner:GetAimVector()*20+self.Owner:GetRight()*3-self.Owner:GetUp()*3)
				Poof:SetStart(self.Owner:GetVelocity()+self.Owner:GetRight()*100)
				util.Effect("eff_jack_smallvent",Poof,true,true)
				
				Poof=EffectData()
				Poof:SetOrigin(self.Owner:GetShootPos()+self.Owner:GetAimVector()*20+self.Owner:GetRight()*3-self.Owner:GetUp()*3)
				Poof:SetStart(self.Owner:GetVelocity()-self.Owner:GetRight()*100)
				util.Effect("eff_jack_smallvent",Poof,true,true)

				umsg.Start("JackysFGFloatChange")
				umsg.Entity(self)
				umsg.String("Spinniness")
				umsg.Float(1)
				umsg.End()
			end
		end
	end)
	timer.Simple(2.3,function()
		if(IsValid(self))then
			if(SERVER)then
				if(self.dt.Ammo>0)then
					umsg.Start("JackysFGFloatChange")
					umsg.Entity(self)
					umsg.String("Spinniness")
					umsg.Float(-1)
					umsg.End()
				end
			end
		end
	end)
	timer.Simple(2.8,function()
		if(IsValid(self))then
			self.dt.State=2
			if(self.Owner:KeyDown(IN_ATTACK))then self:PrimaryAttack() end
		end
	end)
end

function SWEP:PrimaryAttack()
	if not(IsFirstTimePredicted())then return end -- this seems to keep shit from fuckin up
	if(self.dt.Sprint>10)then return end
	if not(self.dt.State==2)then return end
	if(self.dt.Extension>0)then self:ReloadPile() return end
	self:ReloadPile()
	AlreadyFired=false
	
	local BaseShootPos=self.Owner:GetShootPos()
	local AimVec=self.Owner:GetAimVector()
	local ShootPos=BaseShootPos+self.Owner:GetRight()-self.Owner:GetUp()
	
	local PreTraceData={start=BaseShootPos,endpos=ShootPos,filter=self.Owner}
	local PreTrace=util.TraceLine(PreTraceData)
	if(PreTrace.Hit)then ShootPos=BaseShootPos end
	
	local MainTraceData={}
	MainTraceData.start=ShootPos
	MainTraceData.endpos=ShootPos+AimVec*75
	MainTraceData.filter=self.Owner
	MainTraceData.mask=MASK_SHOT
	local MainTrace=util.TraceLine(MainTraceData)
	
	sound.Play("snd_jack_pilefire.wav",self.Owner:GetShootPos(),75,100)
	self.dt.Extension=1
	self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	self.Owner:GetViewModel():SetPlaybackRate(.05)
	timer.Simple(.05,function()
		if(IsValid(self))then
			self.Weapon:SendWeaponAnim(ACT_VM_IDLE)
		end
	end)
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	self.Owner:ViewPunch(Angle(math.Rand(-.5,.5),math.Rand(-.5,.5),math.Rand(-.5,.5)))
	
	if(MainTrace.Hit)then
		MainTrace.Entity:SetMaterial("models/mat_jack_gearblood")
		local Proximity=1-((MainTrace.HitPos-ShootPos):Length()/75)
	
		local Hardness=HardnessTable[MainTrace.MatType]
		if not(Hardness)then Hardness=.5 end
		local Damage=((225*(1-Hardness))+10)*Proximity
		local Force=((100000*Hardness)+10000)*Proximity
		if(MainTrace.HitGroup==HITGROUP_HEAD)then Damage=Damage*2 end
		
		if((MainTrace.Entity:IsPlayer())or(MainTrace.Entity:IsNPC()))then
			local ActualVel=(AimVec*Force)/3
			local ProperVel=Vector(ActualVel.x,ActualVel.y,ActualVel.z/25)
			MainTrace.Entity:SetVelocity(ProperVel)
		end
		
		self:MakeImpactEffect(ShootPos,AimVec,Proximity*8)
		
		if(SERVER)then		
			local Dammej=DamageInfo()
			Dammej:SetDamage(Damage)
			Dammej:SetDamageType(DMG_SLASH)
			Dammej:SetDamagePosition(MainTrace.HitPos)
			Dammej:SetAttacker(self.Owner)
			Dammej:SetInflictor(self.Weapon)
			Dammej:SetDamageForce(AimVec*Force)
			MainTrace.Entity:TakeDamageInfo(Dammej)
		end
		
		if(Hardness>.7)then
			self.Weapon:EmitSound("snd_jack_pileresonate_loud.wav",70,100)
			self.HeldBackAmount=1.5
			self.Owner:SetVelocity(-AimVec*225*Proximity)
		else
			self.HeldBackAmount=1.2
			if not((MainTrace.Entity:IsPlayer())or(MainTrace.Entity:IsNPC()))then
				self.Owner:SetVelocity(-AimVec*150*Proximity)
			end
		end
	else
		self.Weapon:EmitSound("snd_jack_pileresonate_quiet.wav",70,100)
		self.HeldBackAmount=.3
		if(SERVER)then
			umsg.Start("JackysFGFloatChange")
			umsg.Entity(self)
			umsg.String("HeldBackAmount")
			umsg.Float(self.HeldBackAmount)
			umsg.End()
		end
		timer.Simple(.025,function()
			if(IsValid(self))then
				self.HeldBackAmount=0
				if(SERVER)then
					umsg.Start("JackysFGFloatChange")
					umsg.Entity(self)
					umsg.String("HeldBackAmount")
					umsg.Float(self.HeldBackAmount)
					umsg.End()
				end
			end
		end)
	end
	
	if(SERVER)then
		umsg.Start("JackysFGFloatChange")
		umsg.Entity(self)
		umsg.String("HeldBackAmount")
		umsg.Float(self.HeldBackAmount)
		umsg.End()
	end
end

function SWEP:MakeImpactEffect(pos,dir,num)
	local EffectBullet={}
	EffectBullet.Num=math.ceil(num)
	EffectBullet.Src=pos
	EffectBullet.Dir=dir
	EffectBullet.Spread=Vector(0,0,0)
	EffectBullet.Tracer=0
	EffectBullet.Damage=1
	EffectBullet.Force=1
	self.Owner:FireBullets(EffectBullet)
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
	//self.Owner:PrintMessage(HUD_PRINTCENTER,State)
	if((State==4)or(State==5))then return end
	if((self.Owner:InVehicle())or(self.Owner:KeyDown(IN_ZOOM)))then
		if(State==3)then
			self.dt.State=2
		end
		return
	end
	
	if not(self.Spinniness)then self.Spinniness=0 end
	if(self.Spinniness>0)then
		self.VElements["lawl"].angle:RotateAroundAxis(Vector(1,0,0),self.Spinniness*10)
		self.Spinniness=math.Clamp(self.Spinniness-.01,0,1)
	elseif(self.Spinniness<0)then
		self.VElements["lawl"].angle:RotateAroundAxis(Vector(1,0,0),-4)
		self.Spinniness=math.Clamp(self.Spinniness+.02,-1,0)
	end
	
	local Extension=self.dt.Extension
	if(Extension>0)then
		LockPlayed=false
		if(State==3)then
			self.dt.Extension=Extension-.01
		end
		self.VElements["narg"].pos.x=3.5+Extension*9
		self.VElements["derp"].pos.x=5+Extension*17
		self.VElements["flerp"].pos.x=6+Extension*25
	else
		if not(LockPlayed)then
			LockPlayed=true
			if(SERVER)then self.Weapon:EmitSound("snd_jack_pilelock.wav") end
		end
	end
	
	
	if not(self.HeldBackAmount)then self.HeldBackAmount=0 end
	if(self.HeldBackAmount>0)then self.HeldBackAmount=self.HeldBackAmount-.01 end
	
	local Ammo=self.dt.Ammo

	local BaseShootPos=self.Owner:GetShootPos()
	local ShootPos=BaseShootPos+self.Owner:GetRight()*4-self.Owner:GetUp()*5
	local AimVec=self.Owner:GetAimVector()
	
	if(State==3)then
		local Amount=.00009
		if(self.PowerType=="Radiosotope Thermoelectric Generator/Battery Module")then Amount=.00005 end
		local NewAmmo=Ammo-Amount*self.ConsumptionMul
		if not(LockPlayed)then self.dt.Ammo=NewAmmo end
		if(NewAmmo<=0)then self.dt.State=2 end
	end
	self:NextThink(CurTime()+.01)
	return true
end

if(CLIENT)then
	local function DrawExtension()
		for key,wep in pairs(ents.FindByClass("wep_jack_fungun_eta"))do
			local Extension=wep.dt.Extension
			if(Extension)then
				if(Extension>0)then
					wep.WElements["narg"].pos.x=6.75+Extension*9
					wep.WElements["derp"].pos.x=8.25+Extension*17
					wep.WElements["flerp"].pos.x=9+Extension*25
				end
			end
		end
	end
	hook.Add("Think","JackysFunGunEtaWorldSpikeDrawing",DrawExtension)
end

function SWEP:Reload()
	//uh iunno lol
end

function SWEP:LoadEnergyCartridge(cartridge,powerType,heatMul,consumptionMul,charge)
	GlobalJackyFGHGLoadEnCart(self,cartridge,powerType,heatMul,consumptionMul,charge)
end

function SWEP:Holster()
	if not(self.dt.State==2)then return false end
	self.dt.State=6
	self.dt.Sprint=0
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

		local Held=self.dt.Sprint/100
		if(Held>0)then
			pos=pos+self.SprintPos.x*Right*Held+self.SprintPos.y*Up*Held+self.SprintPos.z*Forward*Held
			ang:RotateAroundAxis(Right,self.SprintAng.p*Held)
			ang:RotateAroundAxis(Up,self.SprintAng.y*Held)
			ang:RotateAroundAxis(Forward,self.SprintAng.r*Held)
		end
		
		if(self.HeldBackAmount)then
			if(self.HeldBackAmount>0)then
				local Forward=ang:Forward()
				pos=pos-Forward*self.HeldBackAmount*7
			end
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