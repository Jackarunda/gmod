SWEP.Base="wep_jack_fungun_base_master"

if(SERVER)then
	AddCSLuaFile("shared.lua")
end

if(CLIENT)then
	SWEP.PrintName="Handgun Delta"
	SWEP.Slot=1
	SWEP.WepSelectIcon=surface.GetTextureID("vgui/mat_jack_fgdelta_wsi")
	killicon.Add("wep_jack_fungun_delta","vgui/mat_jack_fgdelta_ki",Color(255,255,255,255))
end

--killing people 1 GHz

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
	surface.DrawCircle(13,41,70,Color(255,255,255,150*Flicker))
	surface.DrawCircle(15,45,7,Color(255,10,10,40*Flicker))
end
function SWEP:RearSight()
	if not(self.DisplaysOn)then return end
	local Flicker=math.Rand(.5,1)
	if(self.dt.Ammo<.01)then Flicker=math.Rand(0,.5) end
	surface.DrawCircle(11,51,28,Color(255,255,255,40*Flicker))
end

SWEP.DisplaysOn=false
SWEP.AimPos=Vector(-2.5, 2,-.5)
SWEP.AimAng=Angle(1.2,-3.5,0)
SWEP.SprintPos=Vector(2.539,-14.44,-0.441)
SWEP.SprintAng=Angle(74,-7,0)
SWEP.ShowWorldModel=false
SWEP.ReloadNoise={"snd_jack_microwavereload.wav",70,100}
SWEP.ViewModelBoneMods={
	["Main Frame"]={ scale=Vector(0.009, 0.009, 0.009), pos=Vector(0, 0, 0), angle=Angle(0, 0, 0) }
}
local LastHeight=0
local LastLastHeight=0
SWEP.VElements={
	["hurr"]={ type="Quad", bone="Main Frame", rel="", pos=Vector(-.5, -1.7, 1.1), angle=Angle(0, -90, 60.34), size=0.025, draw_func=JackIndFunGunAmmoDisplay},
	["durr"]={ type="Quad", bone="Main Frame", rel="", pos=Vector(-.5, 1, 1.3), angle=Angle(0, -90, 60.34), size=0.025, draw_func=function(self)
		if not(self.DisplaysOn)then return end
		local Height=math.Clamp(self.dt.DetectorHeight*math.Rand(.8,1.2),0,1)
		local Flicker=math.Rand(.5,1)
		surface.SetDrawColor(75,75,75,125*Flicker)
		for i=0,29 do
			surface.DrawLine(-5,i,19,i)
		end
		surface.SetDrawColor(255,255,255,200*Flicker)
		local Pos=30-((30*Height)+(30*LastHeight)+(30*LastLastHeight))/3
		surface.DrawLine(-5,Pos,19,Pos)
		surface.DrawOutlinedRect(-5,0,25,30)
		LastLastHeight=LastHeight
		LastHeight=Height
	end},
	["flerp"]={ type="Quad", bone="Main Frame", rel="", pos=Vector(-.5, 2, 1.3), angle=Angle(0, -90, 60.34), size=0.025, draw_func=function(self)
		if not(self.DisplaysOn)then return end
		surface.SetDrawColor(255,255,255,255)
		surface.SetTextPos(-13,1)
		surface.SetFont("JackIndFunGunLargeFont")
		if(self.dt.Mode)then
			surface.DrawText("HEAT")
		else
			surface.DrawText("DISRUPT")
		end
	end},
	["narg"]={ type="Model", model="models/hunter/blocks/cube025x025x025.mdl", bone="Slide", rel="", pos=Vector(3.5, -0.171, 0), angle=Angle(0, 0, 0), size=Vector(0.2, 0.1, 0.05), color=Color(255, 255, 255, 255), surpresslightning=true, material="models/debug/debugwhite", skin=0, bodygroup={} },
	["lol"]={ type="Model", model="models/mass_effect_3/weapons/pistols/m6 jarnifex.mdl", bone="Main Frame", rel="", pos=Vector(0, -0.201, 1), angle=Angle(0, 90, 0), size=Vector(1, 1, 1), color=Color(255, 255, 255, 255), surpresslightning=false, material="", skin=0, bodygroup={} },
	["derp"]={ type="Model", model="models/mass_effect_3/weapons/misc/jhermal clip.mdl", bone="Slide", rel="", pos=Vector(0.219, -0.171, -0.13), angle=Angle(0, 180, 0), size=Vector(0.2, 0.2, 0.2), color=Color(255, 255, 255, 255), surpresslightning=false, material="", skin=0, bodygroup={} },
	["herp"]={ type="Model", model="models/mass_effect_3/weapons/misc/jeatsink.mdl", bone="Mag", rel="", pos=Vector(0.1, 0, 2), angle=Angle(180, 90, 81), size=Vector(1.299, 0.699, 1), color=Color(255, 255, 255, 255), surpresslightning=false, material="", skin=0, bodygroup={} },
	["lawl"]={ type="Model", model="models/props_combine/combine_mortar01b.mdl", bone="Slide", rel="", pos=Vector(-.5, -0.201, .25), angle=Angle(-90, 0, 180), size=Vector(0.02, 0.02, 0.02), color=Color(255, 255, 255, 255), surpresslightning=false, material="", skin=0, bodygroup={} },
	["herpitty"]={ type="Quad", bone="Main Frame", rel="", pos=Vector(10, -.48, 4.75), angle=Angle(0, -90, 90), size=0.025, draw_func=SWEP.FrontSight},
	["derpitty"]={ type="Quad", bone="Main Frame", rel="", pos=Vector(-7, -.45, 4.5), angle=Angle(0, -90, 90), size=0.025, draw_func=SWEP.RearSight}
}
SWEP.WElements={
	["lol"]={ type="Model", model="models/mass_effect_3/weapons/pistols/m6 jarnifex.mdl", bone="ValveBiped.Bip01_R_Hand", rel="", pos=Vector(3, 1.7, -3), angle=Angle(180, 90, 0), size=Vector(1, 1, 1), color=Color(255, 255, 255, 255), surpresslightning=false, material="", skin=0, bodygroup={} }
}

local BurstCoolSoundPlayed=false
local ReleaseSoundPlayed=false
local MicrowaveEndPlayed=false
local DamagableMaterialTable={MAT_FLESH,MAT_ALIENFLESH,MAT_BLOODYFLESH,MAT_ANTLION,MAT_SLOSH}
local BlockingMaterialTable={MAT_METAL,MAT_GRATE,MAT_VENT,MAT_COMPUTER}
local WetModelTable={"models/props_junk/watermelon01.mdl"}
local HasInternalElectronicsTable={"npc_clawscanner"}

local HighHealthTable={"npc_strider","npc_combinegunship"}
local NoHealthTable={"npc_rollermine","npc_helicopter","npc_turret_floor","npc_turret_ceiling","npc_turret_ground","combine_mine"}

function SWEP:Initialize()
	self:SetWeaponHoldType("revolver")
	self.KlystronSound=CreateSound(self.Weapon,"snd_jack_microwavegunhum.wav")
	self.NewCartridge=true
	self.dt.Mode=true
	self.dt.Ammo=1.005
	
	self:SCKInitialize()
end

function SWEP:SetupDataTables()
	self:DTVar("Int",0,"State") -- 1=drawing, 2=idle, 3=firing, 4=venting, 5=reloading, 6=holstered
	self:DTVar("Float",0,"Heat")
	self:DTVar("Float",1,"Ammo")
	self:DTVar("Int",1,"Sprint")
	self:DTVar("Int",2,"Aim")
	self:DTVar("Float",3,"DetectorHeight")
	self:DTVar("Bool",0,"Mode") -- true=organic, false=synthetic
end

function SWEP:Deploy()
	GlobalJackyFGHGDeploy(self)
	self.dt.DetectorHeight=1
end

function SWEP:PrimaryAttack()
	if(self.dt.Sprint>10)then return end
	if not(self.dt.State==2)then return end
	if(self.Owner:KeyDown(IN_USE))then
		self.dt.Mode=not(self.dt.Mode)
		self.Weapon:EmitSound("snd_jack_microwaveswitch.wav",70,100)
		return
	end
	if(self.dt.Ammo<=0)then return end
	self:SetNextPrimaryFire(CurTime()+.2)
	local ShootPos=self.Owner:GetShootPos()+self.Owner:GetAimVector()*20
	if(SERVER)then self:EmitSound("snd_jack_microwaveclick.wav",70,100) end
	self.KlystronSound:Play()
	self.dt.State=3
	ReleaseSoundPlayed=false
	BurstCoolSoundPlayed=false
	MicrowaveEndPlayed=false
end

function SWEP:FireMicroWaves() -- also radio waves :D
	if(CLIENT)then return end

	local SelfPos=self.Owner:GetShootPos()
	local AimVec=self.Owner:GetAimVector()
	local RandomDirection=(AimVec+VectorRand()*.06):GetNormalized()
	
	local Synthetic=1
	local Organic=1
	if(self.dt.Mode)then
		Synthetic=.025
	else
		Organic=.025
	end
	
	local CurrentTraceFromPosition=SelfPos
	local MaxDist=math.random(1200,1700)
	
	local HitWet=false
	local HitMeh=false
	local HitMetal=false
	local WeHitSomething=false
	while not(WeHitSomething)do
		local NewEndPos=CurrentTraceFromPosition+RandomDirection*20
	
		local TrDat={}
		TrDat.start=CurrentTraceFromPosition
		TrDat.endpos=NewEndPos
		TrDat.filter=self.Owner
		TrDat.mask=-1 -- hit water
		local Tr=util.TraceLine(TrDat)
		
		local TrDist=(CurrentTraceFromPosition-SelfPos):Length()
		if(TrDist>MaxDist)then break end -- limited range
		local Boost=(TrDist/MaxDist)*1.4 -- distance power attenuation is already reflected in how difficult it is for a trace to hit at longer distance
		
		local DamMod=1
		if(Tr.HitGroup==HITGROUP_HEAD)then -- brain fryin is very effective
			DamMod=3
		elseif((Tr.HitGroup==HITGROUP_LEFTLEG)or(Tr.HitGroup==HITGROUP_RIGHTLEG)or(Tr.HitGroup==HITGROUP_LEFTARM)or(Tr.HitGroup==HITGROUP_RIGHTARM))then
			DamMod=.5
		end
		
		if(Tr.Hit)then
			//print(Tr.MatType,Tr.Entity)
			if((Tr.MatType==83)and(Tr.HitWorld)and(self.dt.Mode))then
				local Splach=EffectData()
				Splach:SetOrigin(Tr.HitPos)
				Splach:SetNormal(Vector(0,0,1))
				Splach:SetScale(math.Rand(2,7))
				util.Effect("WaterSplash",Splach)
			end
			local Class=Tr.Entity:GetClass()
			if(table.HasValue(DamagableMaterialTable,Tr.MatType))then
				local WantSomeIceWithThatBurn=DamageInfo()
				local Dm=math.Rand(.2,.3)+Boost
				WantSomeIceWithThatBurn:SetDamage(Dm*DamMod*Organic)
				WantSomeIceWithThatBurn:SetDamagePosition(Tr.HitPos)
				WantSomeIceWithThatBurn:SetDamageForce(Vector(0,0,0))
				WantSomeIceWithThatBurn:SetAttacker(self.Owner)
				WantSomeIceWithThatBurn:SetInflictor(self.Weapon)
				WantSomeIceWithThatBurn:SetDamageType(DMG_DIRECT)
				Tr.Entity:TakeDamageInfo(WantSomeIceWithThatBurn)
				
				if(math.random(1,2)==2)then sound.Play("snd_jack_microwaveburn.wav",Tr.HitPos,60,math.Rand(80,120)) end
				
				WeHitSomething=true
				HitWet=true
			elseif((table.HasValue(BlockingMaterialTable,Tr.MatType))or(table.HasValue(HasInternalElectronicsTable,Class)))then
				if(math.random(1,4)==2)then
					if(SERVER)then
						local Eff=EffectData()
						Eff:SetStart(Tr.HitPos)
						Eff:SetOrigin(Tr.HitPos+VectorRand()*math.Rand(1,5))
						Eff:SetScale(.1)
						util.Effect("eff_jack_plasmaarc",Eff,true,true)
						
						sound.Play("snd_jack_peep.wav",Tr.HitPos,60,math.Rand(90,110))
					end
				end
				
				if not(self.dt.Mode)then
					if(table.HasValue(HighHealthTable,Class))then
						if(math.random(1,600)==49)then
							util.BlastDamage(self.Weapon,self.Owner,Tr.Entity:GetPos(),50,100)
						end
					elseif(table.HasValue(NoHealthTable,Class))then
						if(math.random(1,250)==2)then
							Tr.Entity:Fire("selfdestruct","",0)
							Tr.Entity:Fire("respondtoexplodechirp","",0)
							Tr.Entity:Fire("disarm","",0)
						end
					else
						local WantSomeIceWithThatBurn=DamageInfo()
						local Dm=math.Rand(.2,.3)+Boost
						WantSomeIceWithThatBurn:SetDamage(Dm*DamMod*Synthetic)
						WantSomeIceWithThatBurn:SetDamagePosition(Tr.HitPos)
						WantSomeIceWithThatBurn:SetDamageForce(Vector(0,0,0))
						WantSomeIceWithThatBurn:SetAttacker(self.Owner)
						WantSomeIceWithThatBurn:SetInflictor(self.Weapon)
						WantSomeIceWithThatBurn:SetDamageType(DMG_DIRECT)
						Tr.Entity:TakeDamageInfo(WantSomeIceWithThatBurn)
					end
				end
				
				WeHitSomething=true
				HitMetal=true
			elseif(table.HasValue(WetModelTable,Tr.Entity:GetModel()))then
				if(math.random(1,10)==1)then
					local WantSomeIceWithThatBurn=DamageInfo()
					WantSomeIceWithThatBurn:SetDamage(5*Organic)
					WantSomeIceWithThatBurn:SetDamagePosition(Tr.HitPos)
					WantSomeIceWithThatBurn:SetDamageForce(Vector(0,0,0))
					WantSomeIceWithThatBurn:SetAttacker(self.Owner)
					WantSomeIceWithThatBurn:SetInflictor(self.Weapon)
					WantSomeIceWithThatBurn:SetDamageType(DMG_DIRECT)
					Tr.Entity:TakeDamageInfo(WantSomeIceWithThatBurn)
				end
				if(math.random(1,2)==2)then sound.Play("snd_jack_microwaveburn.wav",Tr.HitPos,60,math.Rand(80,120)) end
				
				WeHitSomething=true
				HitWet=true
			elseif(Class=="ent_jack_target")then
				Tr.Entity:TakeDamage(1,self.Owner,self.Weapon)
			end
		else
			HitMeh=true
		end
		
		CurrentTraceFromPosition=NewEndPos
	end
	
	if(HitWet)then
		self.dt.DetectorHeight=.1
	elseif(HitMetal)then
		self.dt.DetectorHeight=1
	elseif(HitMeh)then
		self.dt.DetectorHeight=.5
	end
end

function SWEP:Think()
	self.MagnetronShake=VectorRand()*math.Rand(.01,.02) -- cyclotron, magnetron, klystron, whatever
	
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
			self.KlystronSound:Stop()
			self.dt.State=2
			self.dt.DetectorHeight=0
		end
		return
	end

	local BaseShootPos=self.Owner:GetShootPos()
	local ShootPos=BaseShootPos+self.Owner:GetRight()*4-self.Owner:GetUp()*5
	local AimVec=self.Owner:GetAimVector()
	self.CurrentAimVector=AimVec -- used by the drawing functions, stored for efficiency
	
	if(State==3)then
		self.dt.Heat=math.Clamp(Heat+.00165*self.HeatMul,0,1)
		local Ammo=self.dt.Ammo
		local BaseLoss=.0125
		if not(self.dt.Mode)then BaseLoss=.0075 end
		local Loss=(.0028+.18*Heat^4)*BaseLoss*self.ConsumptionMul
		//self.Owner:PrintMessage(HUD_PRINTCENTER,Loss)
		self.dt.Ammo=Ammo-Loss
		if not(self.NextKlystronSoundTime)then self.NextKlystronSoundTime=CurTime()+.1 end
		if(self.NextKlystronSoundTime<CurTime())then
			self.KlystronSound:Stop()
			self.KlystronSound:Play()
			self.NextKlystronSoundTime=CurTime()+4.9
		end
		self:FireMicroWaves()
		self.Owner:ViewPunch(Angle(math.Rand(-.05,.05),math.Rand(-.05,.05),math.Rand(-.05,.05)))
	end
end

function SWEP:BurstCool()
	if(self.dt.State==4)then return end
	self.dt.State=4
	
	if not(IsValid(self))then return end
	
	self.Weapon:SetDTFloat(3,0)
	self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	self.Owner:GetViewModel():SetPlaybackRate(.25)
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	if not(BurstCoolSoundPlayed)then
		BurstCoolSoundPlayed=true
		self.Weapon:EmitSound("snd_jack_microwavevent.wav",70,100)
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
	self.KlystronSound:Stop()
	self.dt.State=6
	self.dt.Sprint=0
	self:SCKHolster()
	return true
end

function SWEP:OnDrop()
	self.KlystronSound:Stop()
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
			pos=pos+self.MagnetronShake
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

local function PlayEndSound(ply,key)
	if not(key==IN_ATTACK)then return end
	local Wep=ply:GetActiveWeapon()
	if(IsValid(Wep))then
		if(Wep:GetClass()=="wep_jack_fungun_delta")then
			if(Wep.dt.State==3)then
				if not(ReleaseSoundPlayed)then
					ReleaseSoundPlayed=true
					Wep:EmitSound("snd_jack_microwaveclick.wav",70,100)
				end
				Wep.KlystronSound:Stop()
				Wep.dt.State=2
				Wep.dt.DetectorHeight=0
			end
		end
	end
end
hook.Add("KeyRelease","JackysDeltaReleaseSound",PlayEndSound)

local function GunThink()	
	for key,wep in pairs(ents.FindByClass("wep_jack_fungun_delta"))do
		local Heat=wep.dt.Heat
		if(Heat)then
			local State=wep.dt.State
			if(State==3)then
				if((wep.dt.Ammo<=0)or(wep.Owner:KeyDown(IN_SPEED)))then
					if not(MicrowaveEndPlayed)then
						MicrowaveEndPlayed=true
						if(SERVER)then wep:EmitSound("snd_jack_microwaveclick.wav",70,90) end
					end
					wep.KlystronSound:Stop()
					wep.dt.State=2
					wep.dt.DetectorHeight=0
				elseif(Heat==1)then
					if not(MicrowaveEndPlayed)then
						MicrowaveEndPlayed=true
						if(SERVER)then wep:EmitSound("snd_jack_ microwaveclick.wav",70,90) end
					end
					wep.KlystronSound:Stop()
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
hook.Add("Think","JackysDeltaFunGunThinking",GunThink)