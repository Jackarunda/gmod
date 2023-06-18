SWEP.Base = "arccw_base"
SWEP.Spawnable = false -- this obviously has to be set to true
SWEP.Category = "JMod - EZ Weapons" -- edit this if you like
SWEP.AdminOnly = false
----
SWEP.Trivia_Class = "Freedom Gun"
SWEP.Trivia_Desc = "Gun that maintains a healty amount of freedom, or tyranny, depending on the user"
SWEP.Trivia_Manufacturer = "Jackarunda Industries and Company"
SWEP.Trivia_Calibre = "50 cal."
SWEP.Trivia_Mechanism = "Patriotism"
SWEP.Trivia_Country = "'Murica"
SWEP.Trivia_Year = 1775
----
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
SWEP.AimSwayFactor = .9
SWEP.DamageRand = .20
SWEP.BlastRadiusRand = .1
SWEP.Num = 1
SWEP.VisualRecoilMult = 1
SWEP.RecoilSide = .5
SWEP.RecoilPunchBackMax = 2
SWEP.HipDispersion = 700 -- inaccuracy added by hip firing.
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
SWEP.ForceDefaultAmmo = 0
SWEP.MuzzleEffectAttachment = 1 -- which attachment to put the muzzle on
SWEP.CaseEffectAttachment = 2 -- which attachment to put the case effect on
SWEP.BulletBones = {} -- the bone that represents bullets in gun/mag -- [0]="bulletchamber", -- [1]="bullet1"
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
SWEP.AttachmentElements = {} --[[
    ["noch"]={
        VMBodygroups={{ind=1, bg=1}},
        WMBodygroups={{ind=2, bg=1}},
    }
	--]]
SWEP.ProceduralViewBobIntensity = .6
SWEP.ExtraSightDist = 5
SWEP.Attachments = {} --[[
    {
        PrintName="Optic", -- print name
        DefaultAttName="Iron Sights",
        Slot="optic", -- what kind of attachments can fit here, can be string or table
        Bone="v_weapon.m4_Parent", -- relevant bone any attachments will be mostly referring to
        Offset={
            vpos=Vector(0.75, -5.715, -1.609), -- offset that the attachment will be relative to the bone
            vang=Angle(-90-1.46949, 0, -85+3.64274),
            wang=Angle(-9.738, 0, 180)
        },
        SlideAmount={ -- how far this attachment can slide in both directions.
            -- overrides Offset.
            vmin=Vector(0.8, -5.715, -4),
            vmax=Vector(0.8, -5.715, -0.5),
            wmin=Vector(5.36, 0.739, -5.401),
            wmax=Vector(5.36, 0.739, -5.401),
        },
        InstalledEles={"noch"},
        -- CorrectivePos=Vector(-0.017, 0, -0.4),
        CorrectivePos=Vector(0.02, 0, 0),
        CorrectiveAng=Angle(-3, 0, 0)
    }
	--]]
SWEP.MeleeDamage = 10
SWEP.MeleeRange = 30
SWEP.Melee2Range = 30
SWEP.MeleeDamageType = DMG_CLUB
SWEP.MeleeForceAng = Angle(-30, 30, 0)
SWEP.MeleeAttackTime = .35
SWEP.MeleeTime = .5
SWEP.MeleeDelay = .3
SWEP.MeleeSwingSound = JMod.GunHandlingSounds.cloth.loud

SWEP.MeleeHitSound = {"physics/metal/weapon_impact_hard1.wav", "physics/metal/weapon_impact_hard2.wav", "physics/metal/weapon_impact_hard3.wav"}

SWEP.MeleeHitNPCSound = {"physics/body/body_medium_impact_hard2.wav", "physics/body/body_medium_impact_hard3.wav", "physics/body/body_medium_impact_hard4.wav", "physics/body/body_medium_impact_hard5.wav", "physics/body/body_medium_impact_hard6.wav"}

SWEP.MeleeMissSound = "weapons/iceaxe/iceaxe_swing1.wav"
SWEP.MeleeVolume = 65
SWEP.MeleePitch = 1
SWEP.MeleeHitEffect = nil -- "BloodImpact"
SWEP.MeleeHitBullet = false
SWEP.BackHitDmgMult = nil
SWEP.MeleeDmgRand = .1

SWEP.MeleeViewMovements = {
	{
		t = .05,
		ang = Angle(-2, -2, 0)
	},
	{
		t = .35,
		ang = Angle(10, 10, 0)
	}
}

SWEP.CustomToggleCustomizeHUD = true

-- teehee --
hook.Add("InitPostEntity", "JMod_ArcCW_InitPostEntity", function()
	if not ArcCW then return end

	-- the default arccw ricochet sounds are fucking deafening
	ArcCW.RicochetSounds = {"weapons/arccw/ricochet01_quiet.wav", "weapons/arccw/ricochet02_quiet.wav", "weapons/arccw/ricochet03_quiet.wav", "weapons/arccw/ricochet04_quiet.wav", "weapons/arccw/ricochet05_quiet.wav"}
end)

-- arccw hooks to do extra stuff --
SWEP.Hook_AddShootSound = function(self, data) end --[[
	if(self.ShootSoundWorldCount>0)then
		for i=1,self.ShootSoundWorldCount do
			if(SERVER)then
				self:MyEmitSound(data.sound, data.volume, data.pitch, 1, CHAN_WEAPON-1, true)
			end
		end
	end
	--]]

SWEP.Hook_PostFireBullets = function(self)
	local SelfPos = self:GetPos()
	if not IsValid(self.Owner) then return end
	local RPos, RDir = self.Owner:GetShootPos(), self.Owner:GetAimVector()

	if self.BackBlast then
		if self.ShootEntityOffset then
			local ang = RDir:Angle()
			local Up, Right, Forward = ang:Up(), ang:Right(), ang:Forward()
			RPos = RPos + Up * self.ShootEntityOffset.z + Right * self.ShootEntityOffset.x + Forward * self.ShootEntityOffset.y
		end

		local Dist = 230

		local Tr = util.QuickTrace(RPos, -RDir * Dist, function(fuck)
			if fuck:IsPlayer() or fuck:IsNPC() then return false end
			if fuck.IsEZrocket == true then return false end

			return true
		end)

		if Tr.Hit then
			Dist = RPos:Distance(Tr.HitPos)

			if SERVER then
				JMod.Hint(self.Owner, "backblast wall")
			end
		end

		for i = 1, 4 do
			util.BlastDamage(self, self.Owner or self, RPos + RDir * (i * 40 - Dist) * self.BackBlast, 70 * self.BackBlast, 30 * self.BackBlast)
		end

		if SERVER then
			local FooF = EffectData()
			FooF:SetOrigin(RPos)
			FooF:SetScale(self.BackBlast)
			FooF:SetNormal(-RDir)
			util.Effect("eff_jack_gmod_smalldustshock", FooF, true, true)
			local Ploom = EffectData()
			Ploom:SetOrigin(RPos)
			Ploom:SetScale(self.BackBlast)
			Ploom:SetNormal(-RDir)
			util.Effect("eff_jack_gmod_ezbackblast", Ploom, true, true)
		end

		if self.ShakeOnShoot then
			util.ScreenShake(SelfPos, 7 * self.ShakeOnShoot, 255, .75 * self.ShakeOnShoot, 200 * self.ShakeOnShoot)
		end

		local Info = self:GetAttachment(self.MuzzleEffectAttachment or 1)

		if CLIENT then
			Info = self.Owner:GetViewModel():GetAttachment(self.MuzzleEffectAttachment or 1)
		end

		if self.ExtraMuzzleLua then
			local Eff = EffectData()
			Eff:SetOrigin(Info.Pos)
			Eff:SetNormal(self.Owner:GetAimVector())
			Eff:SetScale(self.ExtraMuzzleLuaScale or 1)
			util.Effect(self.ExtraMuzzleLua, Eff, true)
		end
	end

	if self.ExtraMuzzleLua then
		local Eff = EffectData()
		Eff:SetOrigin(RPos)
		Eff:SetNormal(RDir)
		Eff:SetScale(self.ExtraMuzzleLuaScale)
		util.Effect(self.ExtraMuzzleLua, Eff, true, true)
	end

	if self.RecoilDamage and SERVER then
		local Dmg = DamageInfo()
		Dmg:SetDamagePosition(self.Owner:GetShootPos())
		Dmg:SetDamage(self.RecoilDamage)
		Dmg:SetDamageType(DMG_CLUB)
		Dmg:SetAttacker(self.Owner)
		Dmg:SetInflictor(self)
		Dmg:SetDamageForce(-self.Owner:GetAimVector() * self.RecoilDamage * 200)
		self.Owner:SetVelocity(-self.Owner:GetAimVector() * self.RecoilDamage * 200)
		self.Owner:TakeDamageInfo(Dmg)
	end
end

-- Behavior Modifications by Jackarunda --
SWEP.NextDoorShot = 0

function SWEP:TryBustDoor(ent, dmginfo)
	if not self.DoorBreachPower then return end
	if self.NextDoorShot > CurTime() then return end
	if GetConVar("arccw_doorbust"):GetInt() == 0 or not IsValid(ent) or not JMod.IsDoor(ent) then return end
	if ent:GetNoDraw() or ent.ArcCW_NoBust or ent.ArcCW_DoorBusted then return end
	if ent:GetPos():Distance(self:GetPos()) > 150 then return end -- ugh, arctic, lol
	self.NextDoorShot = CurTime() + .05 -- we only want this to run once per shot
	-- Magic number: 119.506 is the size of door01_left
	-- The bigger the door is, the harder it is to bust
	local threshold = GetConVar("arccw_doorbust_threshold"):GetInt() * math.pow((ent:OBBMaxs() - ent:OBBMins()):Length() / 119.506, 2)
	JMod.Hint(self.Owner, "shotgun breach")
	local WorkSpread = JMod.CalcWorkSpreadMult(ent, dmginfo:GetDamagePosition()) ^ 1.1
	local Amt = dmginfo:GetDamage() * self.DoorBreachPower * WorkSpread
	ent.ArcCW_BustDamage = (ent.ArcCW_BustDamage or 0) + Amt

	if ent.ArcCW_BustDamage > threshold then
		JMod.BlastThatDoor(ent, (ent:LocalToWorld(ent:OBBCenter()) - self:GetPos()):GetNormalized() * 100)
		ent.ArcCW_BustDamage = nil

		-- Double doors are usually linked to the same areaportal. We must destroy the second half of the double door no matter what
		for _, otherDoor in pairs(ents.FindInSphere(ent:GetPos(), 64)) do
			if ent ~= otherDoor and otherDoor:GetClass() == ent:GetClass() and not otherDoor:GetNoDraw() then
				JMod.BlastThatDoor(otherDoor, (ent:LocalToWorld(ent:OBBCenter()) - self:GetPos()):GetNormalized() * 100)
				otherDoor.ArcCW_BustDamage = nil
				break
			end
		end
	end
end

local WDir, StabilityStamina, BreathStatus = VectorRand(), 100, false

local function FocusIn(wep)
	if not BreathStatus then
		BreathStatus = true
		surface.PlaySound("snds_jack_gmod/ez_weapons/focus_in.wav")
	end
end

local function FocusOut(wep)
	if BreathStatus then
		BreathStatus = false
		surface.PlaySound("snds_jack_gmod/ez_weapons/focus_out.wav")
	end
end

hook.Add("CreateMove", "JMod_CreateMove", function(cmd)
	local ply = LocalPlayer()
	if not ply:Alive() then return end
	local Wep = ply:GetActiveWeapon()

	if Wep and IsValid(Wep) and Wep.AimSwayFactor and Wep.GetState and (Wep:GetState() == ArcCW.STATE_SIGHTS) then
		local GlobalMult = (JMod.Config and JMod.Config.Weapons.SwayMult) or 1
		local Amt, Sporadicness, FT = 20 * Wep.AimSwayFactor * GlobalMult, 20, FrameTime()

		if ply:Crouching() then
			Amt = Amt * .65
		end

		if Wep.InBipod and Wep:InBipod() then
			Amt = Amt * .25
		end

		if ply:KeyDown(IN_FORWARD) or ply:KeyDown(IN_BACK) or ply:KeyDown(IN_MOVELEFT) or ply:KeyDown(IN_MOVERIGHT) then
			Sporadicness = Sporadicness * 1.5
			Amt = Amt * 2
		else
			local Key = (JMod.Config and JMod.Config.General.AltFunctionKey) or IN_WALK

			if ply:KeyDown(Key) then
				StabilityStamina = math.Clamp(StabilityStamina - FT * 20, 0, 100)

				if StabilityStamina > 0 then
					FocusIn(Wep)
					Amt = Amt * .3
				else
					FocusOut(Wep)
				end
			else
				StabilityStamina = math.Clamp(StabilityStamina + FT * 30, 0, 100)
				FocusOut(Wep)
			end
		end

		local S, EAng = .05, cmd:GetViewAngles()
		WDir = (WDir + FT * VectorRand() * Sporadicness):GetNormalized()
		EAng.pitch = math.NormalizeAngle(EAng.pitch + WDir.z * FT * Amt * S)
		EAng.yaw = math.NormalizeAngle(EAng.yaw + WDir.x * FT * Amt * S)
		cmd:SetViewAngles(EAng)
	end

	if input.WasKeyPressed(KEY_BACKSPACE) then
		if not (ply:IsTyping() or gui.IsConsoleVisible()) then
			local Time = CurTime()
			if not(ply.NextDropTime) or ply.NextDropTime < Time then
				RunConsoleCommand("jmod_ez_dropweapon")
				ply.NextDropTime = Time + .1 --Prevent drop spamming
			end
		end
	end
end)

SWEP.LastTranslateFOV = 0
function SWEP:TranslateFOV(fov)
    local irons = self:GetActiveSights()

    if CLIENT and GetConVar("arccw_dev_benchgun"):GetBool() then self.CurrentFOV = fov self.CurrentViewModelFOV = fov return fov end

    self.ApproachFOV = self.ApproachFOV or fov
    self.CurrentFOV = self.CurrentFOV or fov

    -- Only update every tick (this function is called multiple times per tick)
    if self.LastTranslateFOV == UnPredictedCurTime() then return self.CurrentFOV end
    local timed = UnPredictedCurTime() - self.LastTranslateFOV
    self.LastTranslateFOV = UnPredictedCurTime()

    local app_vm = self.ViewModelFOV + self:GetOwner():GetInfoNum("arccw_vm_fov", 0)
    if CLIENT then
        app_vm = app_vm * (LocalPlayer():GetFOV()/GetConVar("fov_desired"):GetInt())
    end

    if self:GetState() == ArcCW.STATE_SIGHTS then
        local asight = self:GetActiveSights()
        local mag = asight and asight.ScopeMagnification or 1

        local delta = math.pow(self:GetSightDelta(), 2)

        if CLIENT then
            local addads = math.Clamp(GetConVar("arccw_vm_add_ads"):GetFloat() or 0, -2, 14)
            local csratio = math.Clamp(GetConVar("arccw_cheapscopesv2_ratio"):GetFloat() or 0, 0, 1)
            local pfov = GetConVar("fov_desired"):GetInt()

            if GetConVar("arccw_cheapscopes"):GetBool() and mag > 1 then
                fov = (pfov / (asight and asight.Magnification or 1)) / (mag / (1 + csratio * mag) + (addads or 0) / 3)
            else
                fov = ( (pfov / (asight and asight.Magnification or 1)) * (1 - delta)) + (GetConVar("fov_desired"):GetInt() * delta)
            end

            app_vm = irons.ViewModelFOV or 45

            app_vm = app_vm - (asight.MagnifiedOptic and (addads or 0) * 3 or 0)
        end
    end

    self.ApproachFOV = fov

	-- JACKARUNDA
	if BreathStatus then
		self.ApproachFOV = self.ApproachFOV * .9
	end

    -- magic number? multiplier of 10 seems similar to previous behavior
    self.CurrentFOV = math.Approach(self.CurrentFOV, self.ApproachFOV, timed * 10 * (self.CurrentFOV - self.ApproachFOV))

    self.CurrentViewModelFOV = self.CurrentViewModelFOV or self.ViewModelFOV
    self.CurrentViewModelFOV = math.Approach(self.CurrentViewModelFOV, app_vm, timed * 10 * (self.CurrentViewModelFOV - app_vm))

    return self.CurrentFOV
end

--[[
function SWEP:Holster()
	return true -- delayed holstering is disabled until Arctic fixes it in ArcCW
end
--]]
function SWEP:OnDrop()
	local Specs = JMod.WeaponTable[self.PrintName]

	if Specs then
		local Ent = ents.Create(Specs.ent)
		Ent:SetPos(self:GetPos())
		Ent:SetAngles(self:GetAngles())
		Ent.MagRounds = self:Clip1()
		Ent:Spawn()
		Ent:Activate()
		local Phys = Ent:GetPhysicsObject()

		if Phys and self and IsValid(Phys) and IsValid(self) and IsValid(self:GetPhysicsObject()) then
			Phys:SetVelocity(self:GetPhysicsObject():GetVelocity() / 2)
		end

		self:Remove()
	end
end

-- customization
function SWEP:ToggleCustomizeHUD(ic)
	if self.CustomToggleCustomizeHUD == true then return end
	if ic and self:GetState() == ArcCW.STATE_SPRINT then return end
	if self:GetReloading() then ic = false end

	noinspect = noinspect or GetConVar("arccw_noinspect")
	if ic then
		if (self:GetNextPrimaryFire() + 0.1) >= CurTime() then return end

		self:SetState(ArcCW.STATE_CUSTOMIZE)
		self:ExitSights()
		self:SetShouldHoldType()
		self:ExitBipod()
		if noinspect and !noinspect:GetBool() then
			self:PlayAnimation(self:SelectAnimation("enter_inspect"), nil, true, nil, nil, true, false)
		end

		if CLIENT then
			self:OpenCustomizeHUD()
		end
	else
		self:SetState(ArcCW.STATE_IDLE)
		self.Sighted = false
		self.Sprinted = false
		self:SetShouldHoldType()

		if noinspect and !noinspect:GetBool() then
			self:PlayAnimation(self:SelectAnimation("exit_inspect"), nil, true, nil, nil, true, false)
		end

		if CLIENT then
			self:CloseCustomizeHUD()
			self:SendAllDetails()
		end
	end
end

-- arctic's bash code is REALLY bad tbh
--[[ -- TODO: do this when we introduce melee weps
function SWEP:Bash(melee2)
    melee2=melee2 or false
    if self:GetState() == ArcCW.STATE_SIGHTS then return end
    if self:GetNextPrimaryFire() > CurTime() then return end

    if !self.CanBash and !self:GetBuff_Override("Override_CanBash") then return end

    self.Primary.Automatic=true

    local mult=self:GetBuff_Mult("Mult_MeleeTime")
    local mt=self.MeleeTime*mult

    if melee2 then
        mt=self.Melee2Time*mult
    end

    local bashanim="bash"

    if melee2 then
        if self.Animations.bash2_empty and self:Clip1() == 0 then
            bashanim="bash2_empty"
        else
            bashanim="bash2"
        end
    elseif self.Animations.bash then
        if self.Animations.bash_empty and self:Clip1() == 0 then
            bashanim="bash_empty"
        else
            bashanim="bash"
        end
    end

    bashanim=self:GetBuff_Hook("Hook_SelectBashAnim", bashanim) or bashanim

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
        self:OurViewPunch(-self.BashPrepareAng*0.05)
    end
    self:SetNextPrimaryFire(CurTime()+mt+(self.MeleeDelay or 0))

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

    local mat=self.MeleeAttackTime

    if melee2 then
        mat=self.Melee2AttackTime
    end

    mat=mat*self:GetBuff_Mult("Mult_MeleeAttackTime")

    self:SetTimer(mat or (0.125*mt), function()
        if !IsValid(self) then return end
        if !IsValid(self:GetOwner()) then return end
        if self:GetOwner():GetActiveWeapon() != self then return end

        if CLIENT then
            self:OurViewPunch(-self.BashAng*0.05)
        end

        self:MeleeAttack(melee2)
    end)
end
function SWEP:MeleeAttack(melee2)
    local reach=10+self:GetBuff_Add("Add_MeleeRange")+self.MeleeRange
    local dmg=self:GetBuff_Override("Override_MeleeDamage") or self.MeleeDamage or 20

    if melee2 then
        reach=10+self:GetBuff_Add("Add_MeleeRange")+self.Melee2Range
        dmg=self:GetBuff_Override("Override_MeleeDamage") or self.Melee2Damage or 20
    end

    dmg=dmg*self:GetBuff_Mult("Mult_MeleeDamage")

    self:GetOwner():LagCompensation(true)

    local tr=util.TraceLine({
        start=self:GetOwner():GetShootPos(),
        endpos=self:GetOwner():GetShootPos()+self:GetOwner():GetAimVector()*reach,
        filter=self:GetOwner(),
        mask=MASK_SHOT_HULL
    })

    if (!IsValid(tr.Entity)) then
        tr=util.TraceHull({
            start=self:GetOwner():GetShootPos(),
            endpos=self:GetOwner():GetShootPos()+self:GetOwner():GetAimVector()*reach,
            filter=self:GetOwner(),
            mins=Vector(-16, -16, -8),
            maxs=Vector(16, 16, 8),
            mask=MASK_SHOT_HULL
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
					local fx=EffectData()
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
        local dmginfo=DamageInfo()

        local attacker=self:GetOwner()
        if !IsValid(attacker) then attacker=self end
        dmginfo:SetAttacker(attacker)

        local relspeed=(tr.Entity:GetVelocity()-self:GetOwner():GetAbsVelocity()):Length()

        relspeed=relspeed/225

        relspeed=math.Clamp(relspeed, 1, 1.5)

		local RandFact=self.MeleeDmgRand or 0
		local Randomness=math.Rand(1-RandFact,1+RandFact)
		local GlobalMult=((JMod.Config and JMod.Config.Weapons.DamageMult) or 1)*.8 -- gmod kiddie factor

        dmginfo:SetInflictor(self)
        dmginfo:SetDamage(dmg*relspeed*Randomness*GlobalMult)
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
        local phys=tr.Entity:GetPhysicsObject()
        if IsValid(phys) then
            phys:ApplyForceOffset(self:GetOwner():GetAimVector()*80*phys:GetMass(), tr.HitPos)
        end
    end

    self:GetBuff_Hook("Hook_PostBash", {tr=tr, dmg=dmg})

    self:GetOwner():LagCompensation(false)
end
--]]
if CLIENT then end -- TODO: override Arctic's expensive-as-shit thermal code once we implement thermal scopes -- HUD time baby
--[[
	function SWEP:ShouldDrawCrosshair()
		return false
	end
	--]] -- viewmodel positioning and Lerp
