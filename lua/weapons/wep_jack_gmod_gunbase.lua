SWEP.Base = "arccw_base"
SWEP.Spawnable = false -- this obviously has to be set to true
SWEP.Category = "JMod - EZ Weapons" -- edit this if you like
SWEP.AdminOnly = false
SWEP.EZdroppable = true

SWEP.UseHands = true

SWEP.DefaultBodygroups = "000000"

SWEP.DamageType = DMG_BULLET
SWEP.ShootEntity = nil -- entity to fire, if any
SWEP.MuzzleVelocity = 900 -- projectile or phys bullet muzzle velocity
-- IN M/S

SWEP.TracerNum = 0 -- tracer every X
SWEP.TracerCol = Color(255, 25, 25)
SWEP.TracerWidth = 3
SWEP.AimSwayFactor = 1

SWEP.VisualRecoilMult = 1
SWEP.RecoilSide = 1

SWEP.HipDispersion = 800 -- inaccuracy added by hip firing.
SWEP.MoveDispersion = 300

SWEP.ChamberSize = 1 -- this is so wrong, Arctic...
SWEP.Primary.DefaultClip = 0

SWEP.NPCWeaponType = {"weapon_ar2", "weapon_smg1"}
SWEP.NPCWeight = 150

SWEP.MagID = "stanag" -- the magazine pool this gun draws from

SWEP.ShootVol = 75 -- volume of shoot sound
SWEP.ShootPitch = 100 -- pitch of shoot sound

SWEP.ShellTime = 100
SWEP.ShellEffect = "eff_jack_gmod_weaponshell"

SWEP.MuzzleEffectAttachment = 1 -- which attachment to put the muzzle on
SWEP.CaseEffectAttachment = 2 -- which attachment to put the case effect on

SWEP.BulletBones = { -- the bone that represents bullets in gun/mag
    -- [0] = "bulletchamber",
    -- [1] = "bullet1"
}

SWEP.ShootSoundWorldCount = 1
--SWEP.Hook_PostFireBullets -- todo

SWEP.ProceduralRegularFire = false
SWEP.ProceduralIronFire = false

SWEP.AlwaysPhysBullet = false
SWEP.NeverPhysBullet = true

SWEP.CaseBones = {}

SWEP.HoldtypeHolstered = "passive"
SWEP.HoldtypeActive = "ar2"
SWEP.HoldtypeSights = "ar2"

SWEP.AnimShoot = ACT_HL2MP_GESTURE_RANGE_ATTACK_AR2

SWEP.AttachmentElements = {
	--[[
    ["noch"] = {
        VMBodygroups = {{ind = 1, bg = 1}},
        WMBodygroups = {{ind = 2, bg = 1}},
    }
	--]]
}

SWEP.ProceduralViewBobIntensity = .6

SWEP.ExtraSightDist = 5

SWEP.Attachments = {
	--[[
    {
        PrintName = "Optic", -- print name
        DefaultAttName = "Iron Sights",
        Slot = "optic", -- what kind of attachments can fit here, can be string or table
        Bone = "v_weapon.m4_Parent", -- relevant bone any attachments will be mostly referring to
        Offset = {
            vpos = Vector(0.75, -5.715, -1.609), -- offset that the attachment will be relative to the bone
            vang = Angle(-90 - 1.46949, 0, -85 + 3.64274),
            wang = Angle(-9.738, 0, 180)
        },
        SlideAmount = { -- how far this attachment can slide in both directions.
            -- overrides Offset.
            vmin = Vector(0.8, -5.715, -4),
            vmax = Vector(0.8, -5.715, -0.5),
            wmin = Vector(5.36, 0.739, -5.401),
            wmax = Vector(5.36, 0.739, -5.401),
        },
        InstalledEles = {"noch"},
        -- CorrectivePos = Vector(-0.017, 0, -0.4),
        CorrectivePos = Vector(0.02, 0, 0),
        CorrectiveAng = Angle(-3, 0, 0)
    }
	--]]
}

SWEP.MeleeDamage = 10
SWEP.MeleeRange = 30
SWEP.Melee2Range = 30
SWEP.MeleeDamageType = DMG_CLUB
SWEP.MeleeForceAng = Angle(-30,30,0)
SWEP.MeleeAttackTime = .35
SWEP.MeleeTime = .5
SWEP.MeleeDelay = .3
SWEP.MeleeSwingSound = JMod_GunHandlingSounds.cloth.loud
SWEP.MeleeHitSound = {"physics/metal/weapon_impact_hard1.wav","physics/metal/weapon_impact_hard2.wav","physics/metal/weapon_impact_hard3.wav"}
SWEP.MeleeHitNPCSound = {"physics/body/body_medium_impact_hard2.wav","physics/body/body_medium_impact_hard3.wav","physics/body/body_medium_impact_hard4.wav","physics/body/body_medium_impact_hard5.wav","physics/body/body_medium_impact_hard6.wav"}
SWEP.MeleeMissSound = "weapons/iceaxe/iceaxe_swing1.wav"
SWEP.MeleeVolume = 65
SWEP.MeleePitch = 1
SWEP.MeleeHitEffect = nil -- "BloodImpact"
SWEP.MeleeHitBullet = false
SWEP.BackHitDmgMult = nil
SWEP.MeleeDmgRand = .1
SWEP.MeleeViewMovements = {
	{t = .05, ang = Angle(-2,-2,0)},
	{t = .35, ang = Angle(10,10,0)}
}

-- arccw hooks to do extra stuff --
SWEP.Hook_AddShootSound = function(self, fsound, volume, pitch)
	if(self.ShootSoundWorldCount>0)then
		for i=1,self.ShootSoundWorldCount do
			if(SERVER)then self:MyEmitSound(fsound, volume, pitch, 1, CHAN_WEAPON - 1, true) end
		end
	end
end
SWEP.Hook_PostFireBullets = function(self)
	local SelfPos=self:GetPos()
	local RPos,RDir=self.Owner:GetShootPos(),self.Owner:GetAimVector()
	if(self.BackBlast)then
		if(self.ShootEntityOffset)then
			local ang=RDir:Angle()
			local Up,Right,Forward=ang:Up(),ang:Right(),ang:Forward()
			RPos=RPos+Up*self.ShootEntityOffset.z+Right*self.ShootEntityOffset.x+Forward*self.ShootEntityOffset.y
		end
		local Dist=230
		local Tr=util.QuickTrace(RPos,-RDir*Dist,function(fuck)
			if((fuck:IsPlayer())or(fuck:IsNPC()))then return false end
			local Class=fuck:GetClass()
			if(Class=="ent_jack_gmod_ezminirocket")then return false end
			return true
		end)
		if(Tr.Hit)then
			Dist=RPos:Distance(Tr.HitPos)
			if(SERVER)then JMod_Hint(self.Owner,"backblast wall") end
		end
		for i=1,4 do
			util.BlastDamage(self,self.Owner or self,RPos+RDir*(i*40-Dist)*self.BackBlast,70*self.BackBlast,30*self.BackBlast)
		end
		if(SERVER)then
			local FooF=EffectData()
			FooF:SetOrigin(RPos)
			FooF:SetScale(self.BackBlast)
			FooF:SetNormal(-RDir)
			util.Effect("eff_jack_gmod_smalldustshock",FooF,true,true)
			local Ploom=EffectData()
			Ploom:SetOrigin(RPos)
			Ploom:SetScale(self.BackBlast)
			Ploom:SetNormal(-RDir)
			util.Effect("eff_jack_gmod_ezbackblast",Ploom,true,true)
		end
		if(self.ShakeOnShoot)then
			util.ScreenShake(SelfPos,7*self.ShakeOnShoot,255,.75*self.ShakeOnShoot,200*self.ShakeOnShoot)
		end
		
		local Info=self:GetAttachment(self.MuzzleEffectAttachment or 1)
		if(CLIENT)then
			Info=self.Owner:GetViewModel():GetAttachment(self.MuzzleEffectAttachment or 1)
		end
		if(self.ExtraMuzzleLua)then
			local Eff=EffectData()
			Eff:SetOrigin(Info.Pos)
			Eff:SetNormal(self.Owner:GetAimVector())
			Eff:SetScale(self.ExtraMuzzleLuaScale or 1)
			util.Effect(self.ExtraMuzzleLua,Eff,true)
		end
	end
	if(self.ExtraMuzzleLua)then
		local Eff=EffectData()
		Eff:SetOrigin(RPos)
		Eff:SetNormal(RDir)
		Eff:SetScale(self.ExtraMuzzleLuaScale)
		util.Effect(self.ExtraMuzzleLua,Eff,true,true)
	end
end

-- Behavior Modifications by Jackarunda --
function SWEP:TryBustDoor(ent,dmg)
	local RealDist=(ent:GetPos() - self:GetPos()):Length()
	if((SERVER)and(self.DoorBreachPower)and(self.DoorBreachPower>0)and(RealDist<100)and(JMod_IsDoor(ent)))then
		ent.JModDoorBreachedness=(ent.JModDoorBreachedness or 0)+self.DoorBreachPower/self.Num
		if(ent.JModDoorBreachedness>=1)then
			JMod_BlastThatDoor(ent, (ent:LocalToWorld(ent:OBBCenter()) - self:GetPos()):GetNormalized() * 100)
		end
	end
end
local WDir,StabilityStamina,BreathStatus=VectorRand(),100,false
local function FocusIn(wep)
	if not(BreathStatus)then
		BreathStatus=true
		surface.PlaySound("snds_jack_gmod/ez_weapons/focus_in.wav")
	end
end
local function FocusOut(wep)
	if(BreathStatus)then
		BreathStatus=false
		surface.PlaySound("snds_jack_gmod/ez_weapons/focus_out.wav")
	end
end
hook.Add("CreateMove","JMod_CreateMove",function(cmd)
	local ply=LocalPlayer()
	if not(ply:Alive())then return end
	local Wep=ply:GetActiveWeapon()
	if((Wep)and(IsValid(Wep))and(Wep.AimSwayFactor)and(Wep.GetState)and(Wep:GetState() == ArcCW.STATE_SIGHTS))then
		local GlobalMult=(JMOD_CONFIG and JMOD_CONFIG.WeaponSwayMult) or 1
		local Amt,Sporadicness,FT=20*Wep.AimSwayFactor*GlobalMult,20,FrameTime()
		if(ply:Crouching())then Amt=Amt*.65 end
		if((Wep.InBipod)and(Wep:InBipod()))then Amt=Amt*.25 end
		if((ply:KeyDown(IN_FORWARD))or(ply:KeyDown(IN_BACK))or(ply:KeyDown(IN_MOVELEFT))or(ply:KeyDown(IN_MOVERIGHT)))then
			Sporadicness=Sporadicness*1.5
			Amt=Amt*2
		else
			local Key=(JMOD_CONFIG and JMOD_CONFIG.AltFunctionKey) or IN_WALK
			if(ply:KeyDown(Key))then
				StabilityStamina=math.Clamp(StabilityStamina-FT*40,0,100)
				if(StabilityStamina>0)then
					FocusIn(Wep)
					Amt=Amt*.4
				else
					FocusOut(Wep)
				end
			else
				StabilityStamina=math.Clamp(StabilityStamina+FT*30,0,100)
				FocusOut(Wep)
			end
		end
		local S,EAng=.05,cmd:GetViewAngles()
		WDir=(WDir+FT*VectorRand()*Sporadicness):GetNormalized()
		EAng.pitch=math.NormalizeAngle(EAng.pitch+WDir.z*FT*Amt*S)
		EAng.yaw=math.NormalizeAngle(EAng.yaw+WDir.x*FT*Amt*S)
		cmd:SetViewAngles(EAng)
	end
	if(input.WasKeyPressed(KEY_BACKSPACE))then
		if not((ply:IsTyping())or(gui.IsConsoleVisible()))then
			RunConsoleCommand("jmod_ez_dropweapon")
		end
	end
end)
function SWEP:TranslateFOV(fov)
    local irons = self:GetActiveSights()
    if !irons then return end
    if !irons.Magnification then return fov end
    if irons.Magnification == 1 then return fov end

    self.ApproachFOV = self.ApproachFOV or fov
    self.CurrentFOV = self.CurrentFOV or fov

    if self:GetState() != ArcCW.STATE_SIGHTS then
        self.ApproachFOV = fov
    else
        if CLIENT and self:ShouldFlatScope() then
            self.ApproachFOV = fov / (irons.Magnification + irons.ScopeMagnification)
        else
            self.ApproachFOV = fov / irons.Magnification
        end
		if(BreathStatus)then self.ApproachFOV=self.ApproachFOV*.95 end -- JACKARUNDA
    end

    self.CurrentFOV = math.Approach(self.CurrentFOV, self.ApproachFOV, FrameTime() * (self.CurrentFOV - self.ApproachFOV))
    return self.CurrentFOV
end
function SWEP:Holster()
	return true -- delayed holstering is disabled until Arctic fixes it in ArcCW
end
local ToyTownAmt=0
hook.Add("RenderScreenspaceEffects","JMod_WeaponScreenEffects",function()
	if not(GetConVar("jmod_weapon_blur"):GetBool())then return end
	local ArcticsShit=GetConVar("arccw_blur_toytown")
	if(ArcticsShit and ArcticsShit:GetBool())then return end
	local ply,FT=LocalPlayer(),FrameTime()
	if not(ply:ShouldDrawLocalPlayer())then
		local Wep=ply:GetActiveWeapon()
		if((IsValid(Wep))and(Wep.AimSwayFactor)and(Wep.GetState)and(Wep:GetState() == ArcCW.STATE_SIGHTS))then
			ToyTownAmt=Lerp(FT*5,ToyTownAmt,.99)
		else
			ToyTownAmt=Lerp(FT*7,ToyTownAmt,0)
		end
		if(ToyTownAmt>.01)then
			DrawToyTown(10*ToyTownAmt,ScrH()/2*ToyTownAmt)
		end
	end
end)
function SWEP:OnDrop()
	local Specs=JMod_WeaponTable[self.PrintName]
	if(Specs)then
		local Ent=ents.Create(Specs.ent)
		Ent:SetPos(self:GetPos())
		Ent:SetAngles(self:GetAngles())
		Ent.MagRounds=self:Clip1()
		Ent:Spawn()
		Ent:Activate()
		local Phys=Ent:GetPhysicsObject()
		if(Phys)then
			Phys:SetVelocity(self:GetPhysicsObject():GetVelocity()/2)
		end
		self:Remove()
	end
end
-- customization
function SWEP:ToggleCustomizeHUD(ic)
	-- jmod will have its own customization system
end
-- arctic's bash code is REALLY bad tbh
--[[ -- TODO: do this when we introduce melee weps
function SWEP:Bash(melee2)
    melee2 = melee2 or false
    if self:GetState() == ArcCW.STATE_SIGHTS then return end
    if self:GetNextPrimaryFire() > CurTime() then return end

    if !self.CanBash and !self:GetBuff_Override("Override_CanBash") then return end

    self.Primary.Automatic = true

    local mult = self:GetBuff_Mult("Mult_MeleeTime")
    local mt = self.MeleeTime * mult

    if melee2 then
        mt = self.Melee2Time * mult
    end

    local bashanim = "bash"

    if melee2 then
        if self.Animations.bash2_empty and self:Clip1() == 0 then
            bashanim = "bash2_empty"
        else
            bashanim = "bash2"
        end
    elseif self.Animations.bash then
        if self.Animations.bash_empty and self:Clip1() == 0 then
            bashanim = "bash_empty"
        else
            bashanim = "bash"
        end
    end

    bashanim = self:GetBuff_Hook("Hook_SelectBashAnim", bashanim) or bashanim

    if bashanim and self.Animations[bashanim] then
        self:PlayAnimation(bashanim, mult, true, 0, true)
    else
        self:ProceduralBash()

		local s=self.MeleeSwingSound
		if(type(s)=="table")then
			s.BaseClass=nil
			s=table.Random(s)
		end
		if(CLIENT and IsFirstTimePredicted())then sound.Play(s,self:GetPos(),75,100) end
    end

	--self.MeleeViewMovements.BaseClass=nil -- fucking lua...
	for k,v in pairs(self.MeleeViewMovements)do
		if(k~="BaseClass")then
			timer.Simple(v.t,function()
				if(IsValid(self))then
					self.Owner:ViewPunch(v.ang)
				end
			end)
		end
	end

    self:GetBuff_Hook("Hook_PreBash")

    if CLIENT then
        self:OurViewPunch(-self.BashPrepareAng * 0.05)
    end
    self:SetNextPrimaryFire(CurTime() + mt + (self.MeleeDelay or 0))

    if melee2 then
        if self.HoldtypeActive == "pistol" or self.HoldtypeActive == "revolver" then
            self:GetOwner():DoAnimationEvent(self.Melee2Gesture or ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE)
        else
            self:GetOwner():DoAnimationEvent(self.Melee2Gesture or ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE2)
        end
    else
        if self.HoldtypeActive == "pistol" or self.HoldtypeActive == "revolver" then
            self:GetOwner():DoAnimationEvent(self.MeleeGesture or ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE)
        else
            self:GetOwner():DoAnimationEvent(self.MeleeGesture or ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE2)
        end
    end

    local mat = self.MeleeAttackTime

    if melee2 then
        mat = self.Melee2AttackTime
    end

    mat = mat * self:GetBuff_Mult("Mult_MeleeAttackTime")

    self:SetTimer(mat or (0.125 * mt), function()
        if !IsValid(self) then return end
        if !IsValid(self:GetOwner()) then return end
        if self:GetOwner():GetActiveWeapon() != self then return end

        if CLIENT then
            self:OurViewPunch(-self.BashAng * 0.05)
        end

        self:MeleeAttack(melee2)
    end)
end
function SWEP:MeleeAttack(melee2)
    local reach = 10 + self:GetBuff_Add("Add_MeleeRange") + self.MeleeRange
    local dmg = self:GetBuff_Override("Override_MeleeDamage") or self.MeleeDamage or 20

    if melee2 then
        reach = 10 + self:GetBuff_Add("Add_MeleeRange") + self.Melee2Range
        dmg = self:GetBuff_Override("Override_MeleeDamage") or self.Melee2Damage or 20
    end

    dmg = dmg * self:GetBuff_Mult("Mult_MeleeDamage")

    self:GetOwner():LagCompensation(true)

    local tr = util.TraceLine({
        start = self:GetOwner():GetShootPos(),
        endpos = self:GetOwner():GetShootPos() + self:GetOwner():GetAimVector() * reach,
        filter = self:GetOwner(),
        mask = MASK_SHOT_HULL
    })

    if (!IsValid(tr.Entity)) then
        tr = util.TraceHull({
            start = self:GetOwner():GetShootPos(),
            endpos = self:GetOwner():GetShootPos() + self:GetOwner():GetAimVector() * reach,
            filter = self:GetOwner(),
            mins = Vector(-16, -16, -8),
            maxs = Vector(16, 16, 8),
            mask = MASK_SHOT_HULL
        })
    end
	
	if(self.MeleeHitBullet)then
		self:FireBullets({
			Src=self.Owner:GetShootPos(),
			Dir=self.Owner:GetAimVector(),
			Damage=1,
			Force=Vector(0,0,0),
			Attacker=self.Owner,
			Tracer=0,
			Distance=reach*1.2
		})
	end

    if (CLIENT) then
        if tr.Hit then
            if tr.Entity:IsNPC() or tr.Entity:IsNextBot() or tr.Entity:IsPlayer() then
				self.MeleeHitNPCSound.BaseClass=nil
				local s=self.MeleeHitNPCSound
				if(type(s)=="table")then
					s.BaseClass=nil
					s=table.Random(s)
				end
				sound.Play(s,self:GetPos(),self.MeleeVolume or 65,math.random(90,110)*(self.MeleePitch or 1))
            else
				local s=self.MeleeHitSound
				if(type(s)=="table")then
					s.BaseClass=nil
					s=table.Random(s)
				end
				sound.Play(s,self:GetPos(),self.MeleeVolume or 65,math.random(90,110)*(self.MeleePitch or 1))
            end

			if(self.MeleeHitEffect)then
				if tr.MatType == MAT_FLESH or tr.MatType == MAT_ALIENFLESH or tr.MatType == MAT_ANTLION or tr.MatType == MAT_BLOODYFLESH then
					local fx = EffectData()
					fx:SetOrigin(tr.HitPos)

					util.Effect(self.MeleeHitEffect, fx)
				end
			end
        else
			local s=self.MeleeMissSound
			if(type(s)=="table")then
				s.BaseClass=nil
				s=table.Random(s)
			end
			sound.Play(s,self:GetPos(),self.MeleeVolume or 65,math.random(90,110)*(self.MeleePitch or 1))
        end
    end

    if SERVER and IsValid(tr.Entity) and (tr.Entity:IsNPC() or tr.Entity:IsPlayer() or tr.Entity:Health() > 0) then
        local dmginfo = DamageInfo()

        local attacker = self:GetOwner()
        if !IsValid(attacker) then attacker = self end
        dmginfo:SetAttacker(attacker)

        local relspeed = (tr.Entity:GetVelocity() - self:GetOwner():GetAbsVelocity()):Length()

        relspeed = relspeed / 225

        relspeed = math.Clamp(relspeed, 1, 1.5)

		local RandFact=self.MeleeDmgRand or 0
		local Randomness=math.Rand(1-RandFact,1+RandFact)
		local GlobalMult = ((JMOD_CONFIG and JMOD_CONFIG.WeaponDamageMult) or 1) * .8 -- gmod kiddie factor

        dmginfo:SetInflictor(self)
        dmginfo:SetDamage(dmg * relspeed * Randomness * GlobalMult)
        dmginfo:SetDamageType(self.MeleeDamageType or DMG_CLUB)

		local ForceVec=self.Owner:EyeAngles()
		local U,R,F=ForceVec:Up(),ForceVec:Right(),ForceVec:Forward()
		ForceVec:RotateAroundAxis(R,self.MeleeForceAng.p)
		ForceVec:RotateAroundAxis(U,self.MeleeForceAng.y)
		ForceVec:RotateAroundAxis(F,self.MeleeForceAng.r)
		ForceVec=ForceVec:Forward()
		dmginfo:SetDamageForce(ForceVec*10000)

        SuppressHostEvents(NULL)
        tr.Entity:TakeDamageInfo(dmginfo)
        SuppressHostEvents(self:GetOwner())

        if tr.Entity:GetClass() == "func_breakable_surf" then
            tr.Entity:Fire("Shatter", "0.5 0.5 256")
        end

    end

    if SERVER and IsValid(tr.Entity) then
        local phys = tr.Entity:GetPhysicsObject()
        if IsValid(phys) then
            phys:ApplyForceOffset(self:GetOwner():GetAimVector() * 80 * phys:GetMass(), tr.HitPos)
        end
    end

    self:GetBuff_Hook("Hook_PostBash", {tr = tr, dmg = dmg})

    self:GetOwner():LagCompensation(false)
end
--]]
if(CLIENT)then
	-- TODO: override Arctic's expensive-as-shit thermal code once we implement thermal scopes
	-- HUD time baby
	--[[
	function SWEP:ShouldDrawCrosshair()
		return false
	end
	--]]
	-- viewmodel positioning and Lerp
end