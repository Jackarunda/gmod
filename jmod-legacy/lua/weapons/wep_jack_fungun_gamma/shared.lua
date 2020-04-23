SWEP.Base="wep_jack_fungun_base_master"

if(SERVER)then
	AddCSLuaFile("shared.lua")
end

if(CLIENT)then
	SWEP.PrintName="Handgun Gamma"
	SWEP.Slot=1
	SWEP.WepSelectIcon=surface.GetTextureID("vgui/mat_jack_fggamma_wsi")
	killicon.Add("wep_jack_fungun_gamma","vgui/mat_jack_fggamma_wsi",Color(255,255,255,255))
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
	surface.DrawCircle(20,41,160,Color(255,255,255,150*Flicker))
end
function SWEP:RearSight()
	if not(self.DisplaysOn)then return end
	local Flicker=math.Rand(.5,1)
	if(self.dt.Ammo<.01)then Flicker=math.Rand(0,.5) end
	surface.DrawCircle(15,27,67,Color(255,255,255,70*Flicker))
	surface.DrawCircle(15,30,10,Color(255,10,10,20*Flicker))
end

SWEP.AimPos=Vector(-2.5, 3,-1.5)
SWEP.AimAng=Angle(1.2,-3.5,0)
SWEP.SprintPos=Vector(2.539,-14.44,-0.441)
SWEP.SprintAng=Angle(74,-7,0)
SWEP.ShowWorldModel=false
SWEP.ReloadNoise={"snd_jack_plasmareload.wav",70,100}
SWEP.ViewModelBoneMods={
	["Main Frame"]={ scale=Vector(0.009, 0.009, 0.009), pos=Vector(0, 0, 0), angle=Angle(0, 0, 0) }
}
SWEP.VElements={
	["hurr"]={ type="Quad", bone="Main Frame", rel="", pos=Vector(.5, -1, 1.1), angle=Angle(0, -90, 60.34), size=0.025, draw_func=JackIndFunGunAmmoDisplay},
	["lol"]={ type="Model", model="models/mass_effect_3/weapons/pistols/m-358 jalon.mdl", bone="Main Frame", rel="", pos=Vector(0.5, 0, 0.5), angle=Angle(0, 90, 0), size=Vector(1, 1, 1), color=Color(255, 255, 255, 255), surpresslightning=false, material="", skin=0, bodygroup={} },
	["derp"]={ type="Model", model="models/mass_effect_3/weapons/misc/jhermal clip.mdl", bone="Slide", rel="", pos=Vector(1, 0, -1.101), angle=Angle(0, 0, 0), size=Vector(0.37, 0.65, 0.37), color=Color(255, 255, 255, 255), surpresslightning=false, material="", skin=0, bodygroup={} },
	["herp"]={ type="Model", model="models/mass_effect_3/weapons/misc/jeatsink.mdl", bone="Mag", rel="", pos=Vector(0.1, 0, 2), angle=Angle(180, 90, 81), size=Vector(1.299, 0.65, 1), color=Color(255, 255, 255, 255), surpresslightning=false, material="", skin=0, bodygroup={} },
	["flarg"]={ type="Model", model="models/Mechanics/wheels/wheel_smooth_24f.mdl", bone="Main Frame", rel="", pos=Vector(2.273, 0, 2.9), angle=Angle(90, 0, 0), size=Vector(0.039, 0.039, 0.25), color=Color(50, 50, 50, 255), surpresslightning=false, material="models/shiny", skin=0, bodygroup={} },
	["narg"]={ type="Model", model="models/props_phx/construct/metal_dome360.mdl", bone="Main Frame", rel="", pos=Vector(1.7, 0, 2.9), angle=Angle(90, 180, 0), size=Vector(0.009, 0.009, 0.009), color=Color(0, 0, 0, 255), surpresslightning=true, material="models/debug/debugwhite", skin=0, bodygroup={} },
	["herpitty"]={ type="Quad", bone="Main Frame", rel="", pos=Vector(10, -.48, 4.75), angle=Angle(0, -90, 90), size=0.025, draw_func=SWEP.FrontSight},
	["derpitty"]={ type="Quad", bone="Main Frame", rel="", pos=Vector(-7, -.45, 4.5), angle=Angle(0, -90, 90), size=0.025, draw_func=SWEP.RearSight}
}
SWEP.WElements={
	["lol"]={ type="Model", model="models/mass_effect_3/weapons/pistols/m-358 jalon.mdl", bone="ValveBiped.Bip01_R_Hand", rel="", pos=Vector(3.181, 1.363, -2.274), angle=Angle(180, 90, 0), size=Vector(1, 1, 1), color=Color(255, 255, 255, 255), surpresslightning=false, material="", skin=0, bodygroup={} }
}

local Glow=Material("sprites/mat_jack_glowything")
local Distort=Material("sprites/heatwave")
local BurstCoolSoundPlayed=false
local ReleaseSoundPlayed=false
local BlastEndPlayed=false

function SWEP:Initialize()
	self:SetWeaponHoldType("revolver")
	self.BlastingSound=CreateSound(self.Weapon,"snd_jack_plasmaloop.wav")
	self.AccentSound=CreateSound(self,"snd_jack_plasmaloop_reversed.wav")
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
	self:EmitSound("snd_jack_plasmapop.wav",80,100)
	self:EmitSound("snd_jack_plasmapop.wav",70,100)
	self.BlastingSound:Play()
	self.AccentSound:Play()
	self.dt.State=3
	ReleaseSoundPlayed=false
	BurstCoolSoundPlayed=false
	BlastEndPlayed=false
end

function SWEP:Think()
	self.BlasterShake=VectorRand()*math.Rand(.02,.06)
	
	if not(self.TurbineSpin)then self.TurbineSpin=0 end
	if(self.TurbineSpin>0)then
		self.VElements["flarg"].angle:RotateAroundAxis(Vector(1,0,0),self.TurbineSpin*100)
	end
	
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
			self.BlastingSound:Stop()
			self.AccentSound:Stop()
			self.dt.State=2
		end
		return
	end

	local BaseShootPos=self.Owner:GetShootPos()
	local ShootPos=BaseShootPos+self.Owner:GetRight()*4-self.Owner:GetUp()*5
	local AimVec=self.Owner:GetAimVector()
	
	if not(self.HeldBackAmount)then self.HeldBackAmount=0 end
	
	if(State==3)then
		self.TurbineSpin=1
		//self.HeldBackAmount=math.Clamp(self.HeldBackAmount*.95+.001,0,1)
		self.HeldBackAmount=math.Clamp(self.HeldBackAmount+.05-self.HeldBackAmount*.1,0,1)
		self.dt.Heat=math.Clamp(Heat+.002*self.HeatMul,0,1)
		local Ammo=self.dt.Ammo
		local Loss=(.0122+.17*Heat^4)*.007*self.ConsumptionMul
		//self.Owner:PrintMessage(HUD_PRINTCENTER,Loss)
		self.dt.Ammo=Ammo-Loss
		if not(self.NextBlastingSoundTime)then self.NextBlastingSoundTime=CurTime()+.1 end
		if(self.NextBlastingSoundTime<CurTime())then
			self.BlastingSound:Stop()
			self.BlastingSound:Play()
			self.AccentSound:Stop()
			self.AccentSound:Play()
			self.NextBlastingSoundTime=CurTime()+1.69
		end
		if(SERVER)then
			local WeldTable={}
			local WeldPos=nil
			local WeldNorm=nil
			for i=1,2 do
				local TressDat={start=BaseShootPos,endpos=ShootPos+AimVec*math.Rand(100,110)+VectorRand()*math.Rand(0,20),filter=self.Owner,mask=MASK_SHOT}
				local Tress=util.TraceLine(TressDat)
				if(Tress.Hit)then
					local WantSomeIceWithThatBurn=DamageInfo()
					WantSomeIceWithThatBurn:SetDamage(math.Rand(.2,.4))
					WantSomeIceWithThatBurn:SetDamagePosition(Tress.HitPos)
					WantSomeIceWithThatBurn:SetDamageForce(AimVec*900)
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
						self.NextBurnSoundEmitTime=CurTime()+.075
					end
					
					if(math.random(1,2)==1)then
						local Poof=EffectData()
						Poof:SetOrigin(Tress.HitPos)
						Poof:SetScale(2)
						Poof:SetNormal(Tress.HitNormal)
						if((Tress.MatType==MAT_CONCRETE)or(Tress.MatType==MAT_METAL)or(Tress.MatType==MAT_COMPUTER)or(Tress.MatType==MAT_GRATE)or(Tress.MatType==MAT_TILE)or(Tress.MatType==MAT_GLASS)or(Tress.MatType==MAT_SAND))then
							Poof:SetStart(Tress.Entity:GetVelocity())
							Poof:SetNormal(Tress.HitNormal)
							util.Effect("eff_jack_tinymelt",Poof,true,true)
							Poof:SetScale(.07)
							util.Effect("eff_jack_fadingmelt",Poof,true,true)
						else
							util.Effect("eff_jack_tinyburn",Poof,true,true)
						end
					end
					
					if((Tress.MatType==MAT_METAL)or(Tress.MatType==MAT_VENT)or(Tress.MatType==MAT_GRATE))then
						WeldTable[i]=Tress.Entity
						WeldPos=Tress.HitPos
						WeldNorm=Tress.HitNormal
					end
				end	
			end
			if(math.random(1,3)==2)then
				local EntOne=WeldTable[1]
				local EntTwo=WeldTable[2]
				if((IsValid(EntOne))and(IsValid(EntOne)))then
					if not(EntOne==EntTwo)then
						local Strength=math.random(1,20000)
						Strength=Strength+math.random(1,20000)
						Strength=Strength+math.random(1,20000)
						Strength=Strength+math.random(1,20000)
						Strength=Strength+math.random(1,20000)
						constraint.Weld(EntOne,EntTwo,0,0,Strength,false)
						local effectdata=EffectData()
						effectdata:SetOrigin(WeldPos)
						effectdata:SetNormal(WeldNorm)
						effectdata:SetMagnitude(8) --amount and shoot hardness
						effectdata:SetScale(2) --length of strands
						effectdata:SetRadius(2) --thickness of strands
						util.Effect("Sparks",effectdata,true,true)
					end
				end
			end
			if(math.random(1,2)==2)then
				if(self.Owner:WaterLevel()==3)then
					local Blamo=EffectData()
					Blamo:SetOrigin(ShootPos+AimVec*30)
					Blamo:SetStart(AimVec)
					util.Effect("eff_jack_plasmajetwater",Blamo,true,true)
				end
			end
		end
		self.Owner:ViewPunch(Angle(math.Rand(-.05,.05),math.Rand(-.05,.05),math.Rand(-.05,.05)))
		self.Owner:SetVelocity(-AimVec*.5)
	else
		self.HeldBackAmount=math.Clamp(self.HeldBackAmount*.95-.0001,0,1)
		self.TurbineSpin=math.Clamp(self.TurbineSpin*.98-.0001,0,1)
	end
	
	self:NextThink(CurTime())
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
		self.Weapon:EmitSound("snd_jack_plasmavent.wav",70,100)
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
	self.BlastingSound:Stop()
	self.AccentSound:Stop()
	self.dt.State=6
	self.dt.Sprint=0
	self:SCKHolster()
	return true
end

function SWEP:OnDrop()
	self.BlastingSound:Stop()
	self.AccentSound:Stop()
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
			pos=pos+self.BlasterShake
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
		if(self.dt.State==3)then
			local VM=self.Owner:GetViewModel()
			local Pos,Ang=VM:GetBonePosition(VM:LookupBone("Main Frame"))
			Pos=Pos+Ang:Right()*3-Ang:Up()*2
			local Dir=self.Owner:GetAimVector()
			render.SetMaterial(Distort)
			render.DrawSprite(Pos+Dir*50*math.Rand(.8,1.2),60*math.Rand(.8,1.2),60*math.Rand(.8,1.2),Color(175,200,255,255*math.Rand(.8,1.2)))
			render.SetMaterial(Glow)
			render.DrawSprite(Pos+Dir*40*math.Rand(.8,1.2),30*math.Rand(.8,1.2),30*math.Rand(.8,1.2),Color(175,200,255,255*math.Rand(.8,1.2)))
			render.DrawSprite(Pos+Dir*30*math.Rand(.8,1.2),20*math.Rand(.8,1.2),20*math.Rand(.8,1.2),Color(175,200,255,255*math.Rand(.8,1.2)))
			
			local dlight=DynamicLight(self:EntIndex())
			if(dlight)then
				dlight.MinLight=0
				dlight.Pos=Pos+Dir*30
				dlight.r=175
				dlight.g=200
				dlight.b=255
				dlight.Brightness=6
				dlight.Size=500
				dlight.Decay=10000
				dlight.DieTime=CurTime()+.1
				dlight.Style=0
			end
		end
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
		if(Wep:GetClass()=="wep_jack_fungun_gamma")then
			if(Wep.dt.State==3)then
				if not(ReleaseSoundPlayed)then
					ReleaseSoundPlayed=true
					if(SERVER)then
						Wep:EmitSound("snd_jack_plasmapop.wav",70,100)
					end
				end
				Wep.Owner:SetAnimation(PLAYER_ATTACK1)
				Wep.BlastingSound:Stop()
				Wep.AccentSound:Stop()
				Wep.dt.State=2
			end
		end
	end
end
hook.Add("KeyRelease","JackysGammaBlasterReleaseSound",PlayEndSound)

local function GunThink()	
	for key,wep in pairs(ents.FindByClass("wep_jack_fungun_gamma"))do
		local Heat=wep.dt.Heat
		if(Heat)then
			local State=wep.dt.State
			if(State==3)then
				if((wep.dt.Ammo<=0)or(wep.Owner:KeyDown(IN_SPEED)))then
					if not(BlastEndPlayed)then
						BlastEndPlayed=true
						wep:EmitSound("snd_jack_plasmapop.wav",70,100)
					end
					wep.BlastingSound:Stop()
					wep.AccentSound:Stop()
					wep.dt.State=2
				elseif(Heat==1)then
					if not(BlastEndPlayed)then
						BlastEndPlayed=true
						wep:EmitSound("snd_jack_plasmapop.wav",70,100)
					end
					wep.BlastingSound:Stop()
					wep.AccentSound:Stop()
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
hook.Add("Think","JackysGammaFunGunThinking",GunThink)

if(CLIENT)then
	local function DrawFlame(ply)
		local self=ply:GetActiveWeapon()
		if(IsValid(self))then
			if(self:GetClass()=="wep_jack_fungun_gamma")then
				if(self.dt.State==3)then
					local Pos,Ang=self.Owner:GetBonePosition(self.Owner:LookupBone("ValveBiped.Bip01_R_Hand"))
					local Dir=self.Owner:GetAimVector()
					
					local Mat=math.random(1,2)
						if(Mat==2)then
							render.SetMaterial(Distort)
						else
							render.SetMaterial(Glow)
						end
					for i=1,15 do
						render.DrawSprite(Pos+Dir*(20+i*4.5)*math.Rand(.8,1.2),(30-i*2)*math.Rand(.8,1.2)*Mat,(30-i*2)*math.Rand(.8,1.2)*Mat,Color(175,200,255,255*math.Rand(.8,1.2)))
					end
					
					local dlight=DynamicLight(self:EntIndex())
					if(dlight)then
						dlight.MinLight=0
						dlight.Pos=Pos+Dir*30
						dlight.r=175
						dlight.g=200
						dlight.b=255
						dlight.Brightness=6
						dlight.Size=500
						dlight.Decay=10000
						dlight.DieTime=CurTime()+.1
						dlight.Style=0
					end
				end
			end
		end
	end
	hook.Add("PostPlayerDraw","JackysGammaFlameDrawing",DrawFlame)
end