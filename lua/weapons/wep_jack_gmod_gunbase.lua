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

SWEP.TracerNum = 1 -- tracer every X
SWEP.TracerCol = Color(255, 25, 25)
SWEP.TracerWidth = 3
SWEP.AimSwayFactor = 1

SWEP.ForceExpensiveScopes = true

SWEP.ChamberSize = 1 -- how many rounds can be chambered.
SWEP.NoFreeAmmo = true

SWEP.NPCWeaponType = {"weapon_ar2", "weapon_smg1"}
SWEP.NPCWeight = 150

SWEP.MagID = "stanag" -- the magazine pool this gun draws from

SWEP.ShootVol = 75 -- volume of shoot sound
SWEP.ShootPitch = 100 -- pitch of shoot sound

SWEP.ShootSoundExtraMult=1

SWEP.ShellTime = 100
SWEP.ShellEffect = "eff_jack_gmod_weaponshell"

SWEP.MuzzleEffectAttachment = 1 -- which attachment to put the muzzle on
SWEP.CaseEffectAttachment = 2 -- which attachment to put the case effect on

SWEP.BulletBones = { -- the bone that represents bullets in gun/mag
    -- [0] = "bulletchamber",
    -- [1] = "bullet1"
}

SWEP.ProceduralRegularFire = false
SWEP.ProceduralIronFire = false

SWEP.CaseBones = {}

SWEP.HoldtypeHolstered = "passive"
SWEP.HoldtypeActive = "ar2"
SWEP.HoldtypeSights = "ar2"

SWEP.AnimShoot = ACT_HL2MP_GESTURE_RANGE_ATTACK_AR2

SWEP.MeleeAttackTime=.35

SWEP.AttachmentElements = {
	--[[
    ["noch"] = {
        VMBodygroups = {{ind = 1, bg = 1}},
        WMBodygroups = {{ind = 2, bg = 1}},
    }
	--]]
}

SWEP.ProceduralViewBobIntensity = 1

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

-- Behavior Modifications by Jackarunda --

local WDir,StabilityStamina,BreathStatus=VectorRand(),100,false
local function BreatheIn(wep)
	if not(BreathStatus)then
		BreathStatus=true
		surface.PlaySound("snds_jack_gmod/ez_weapons/focus_inhale.wav")
	end
end
local function BreatheOut(wep)
	if(BreathStatus)then
		BreathStatus=false
		surface.PlaySound("snds_jack_gmod/ez_weapons/focus_exhale.wav")
	end
end
function SWEP:GetDamage(range)
    local num = (self:GetBuff_Override("Override_Num") or self.Num) + self:GetBuff_Add("Add_Num")
    local dmult = 1

    if num then
        dmult = self.Num / dmult
    end
	
	local RandFact=self.DamageRand or 0
	local Randomness=math.Rand(1-RandFact,1+RandFact)
	local GlobalMult = ((JMOD_CONFIG and JMOD_CONFIG.WeaponDamageMult) or 1) * .8 -- gmod kiddie factor

    local dmgmax = self.Damage * self:GetBuff_Mult("Mult_Damage") * dmult * Randomness * GlobalMult
    local dmgmin = self.DamageMin * self:GetBuff_Mult("Mult_DamageMin") * dmult * Randomness * GlobalMult

    local delta = 1

    if dmgmax < dmgmin then
        delta = range / (self.Range / self:GetBuff_Mult("Mult_Range"))
    else
        delta = range / (self.Range * self:GetBuff_Mult("Mult_Range"))
    end

    delta = math.Clamp(delta, 0, 1)

    local amt = Lerp(delta, dmgmax, dmgmin)
    return amt
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
					BreatheIn(Wep)
					Amt=Amt*.4
				else
					BreatheOut(Wep)
				end
			else
				StabilityStamina=math.Clamp(StabilityStamina+FT*30,0,100)
				BreatheOut(Wep)
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
        self.ApproachFOV = fov / irons.Magnification
		if(BreathStatus)then self.ApproachFOV=self.ApproachFOV*.95 end
    end

    self.CurrentFOV = math.Approach(self.CurrentFOV, self.ApproachFOV, FrameTime() * (self.CurrentFOV - self.ApproachFOV))
    return self.CurrentFOV
end
function SWEP:Holster()
	return true -- delayed holstering is disabled until Arctic fixes it in ArcCW
end
local ToyTownAmt=0
hook.Add("RenderScreenspaceEffects","JMod_WeaponScreenEffects",function()
	local ply,FT=LocalPlayer(),FrameTime()
	if not(ply:ShouldDrawLocalPlayer())then
		local Wep=ply:GetActiveWeapon()
		if((IsValid(Wep))and(Wep.AimSwayFactor)and(Wep.GetState)and(Wep:GetState() == ArcCW.STATE_SIGHTS))then
			ToyTownAmt=Lerp(FT*5,ToyTownAmt,1)
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
		Ent:GetPhysicsObject():SetVelocity(self:GetPhysicsObject():GetVelocity()/2)
		self:Remove()
	end
end
function SWEP:PlaySoundTable(soundtable, mult, startfrom)
    if CLIENT and game.SinglePlayer() then return end
    mult = mult or 1
    mult = 1 / mult
    startfrom = startfrom or 0

    self:KillTimer("soundtable")
    for k, v in pairs(soundtable) do

        if !v.t then continue end

        local pitch = 100
        local vol = 75

        if v.p then
            pitch = v.p
        end

        if v.v then
            vol = v.v
        end

        local st = (v.t * mult) - startfrom

        if isnumber(v.t) then
            if st < 0 then continue end
            if self:GetOwner():IsNPC() then
                timer.Simple(st, function()
                    if !IsValid(self) then return end
                    if !IsValid(self:GetOwner()) then return end
                    --self:EmitSound(v.s, vol, pitch, 1, CHAN_AUTO)
					if(SERVER)then sound.Play(v.s,self:GetPos(),vol,pitch,1) end
                end)
            else
                self:SetTimer(st, function()
					--self:EmitSound(v.s, vol, pitch, 1, v.c or CHAN_AUTO)
					if(SERVER)then sound.Play(v.s,self:GetPos(),vol,pitch,1) end
				end, "soundtable")
            end
        end
    end
end
-- firing
function SWEP:PrimaryAttack()
    if self:GetOwner():IsNPC() then
        self:NPC_Shoot()
        return
    end

    if self:GetNextPrimaryFire() >= CurTime() then return end

    if self:GetState() == ArcCW.STATE_CUSTOMIZE then return end

    if self:GetState() != ArcCW.STATE_SIGHTS and self:GetOwner():KeyDown(IN_USE) or self.PrimaryBash then
        self:Bash()
        return
    end

    if self.Throwing then
        self:PreThrow()
        return
    end

    if self:BarrelHitWall() > 0 then return end
    if self:GetState() == ArcCW.STATE_SPRINT and !(self:GetBuff_Override("Override_ShootWhileSprint") or self.ShootWhileSprint) then return end

    if self:GetNWBool("ubgl") then
        self:ShootUBGL()
        return
    end

    if self:Clip1() <= 0 then self.BurstCount = 0 self:DryFire() return end
    if self:GetNWBool("cycle", false) then return end
    if self.BurstCount >= self:GetBurstLength() then return end
    if self:GetCurrentFiremode().Mode == 0 then
        self:ChangeFiremode(false)
        self.Primary.Automatic = false
        return
    end

    if self:GetBuff_Hook("Hook_ShouldNotFire") then return end

    math.randomseed(self:GetOwner():GetCurrentCommand():CommandNumber() + (self:EntIndex() % 30241))

    self.Primary.Automatic = self:ShouldBeAutomatic()

    local ss = self.ShootSound

    if self:GetBuff_Override("Silencer") then
        ss = self.ShootSoundSilenced
    end

    if self.BurstCount == 0 and self.FirstShootSound then
        ss = self.FirstShootSound

        if self:GetBuff_Override("Silencer") then
            if self.FirstShootSoundSilenced then
                ss = self.FirstShootSoundSilenced
            else
                ss = self.ShootSoundSilenced
            end
        end
    end

    if self:Clip1() == 1 and self.LastShootSound then
        ss = self.LastShootSound

        if self:GetBuff_Override("Silencer") then
            if self.LastShootSoundSilenced then
                ss = self.LastShootSoundSilenced
            else
                ss = self.ShootSoundSilenced
            end
        end
    end

    ss = self:GetBuff_Hook("Hook_GetShootSound", ss)

    local dss = self.DistantShootSound

    if self:GetBuff_Override("Silencer") then
        dss = nil
    end

    dss = self:GetBuff_Hook("Hook_GetDistantShootSound", dss)

    local dir = self:GetOwner():EyeAngles()

    local src = self:GetShootSrc()

    if bit.band( util.PointContents( src ), CONTENTS_WATER ) == CONTENTS_WATER and !(self.CanFireUnderwater or self:GetBuff_Override("Override_CanFireUnderwater")) then
        self:DryFire()
        return
    end

    local spread = ArcCW.MOAToAcc * self.AccuracyMOA * self:GetBuff_Mult("Mult_AccuracyMOA")

    dir = dir + (AngleRand() * self:GetDispersion() / 360 / 60)

    local delay = (self.Delay * (1 / self:GetBuff_Mult("Mult_RPM")))

    delay = self:GetBuff_Hook("Hook_ModifyRPM", delay) or delay

    self:SetNextPrimaryFire(CurTime() + delay)

    -- if IsFirstTimePredicted() then

        local num = self:GetBuff_Override("Override_Num")

        if !num then
            num = self.Num
        end

        num = num + self:GetBuff_Add("Add_Num")

        local btabl = {
            Attacker = self:GetOwner(),
            Damage = 0,
            Force = 5 / num,
            Distance = 33000,
            Num = num,
            Tracer = self:GetBuff_Override("Override_TracerNum") or self.TracerNum,
            TracerName = self:GetBuff_Override("Override_Tracer") or self.Tracer,
            AmmoType = self.Primary.Ammo,
            Dir = dir:Forward(),
            Src = src,
            Spread = Vector(spread, spread, spread),
            Callback = function(att, tr, dmg)
                local dist = (tr.HitPos - src):Length() * ArcCW.HUToM

                local pen = self.Penetration * self:GetBuff_Mult("Mult_Penetration")

                -- local frags = math.random(1, self.Frangibility)

                -- for i = 1, frags do
                --     self:DoPenetration(tr, (self.Penetration / frags) - 0.5, tr.Entity)
                -- end

                local ret = self:GetBuff_Hook("Hook_BulletHit", {
                    range = dist,
                    damage = self:GetDamage(dist),
                    dmgtype = self:GetBuff_Override("Override_DamageType") or self.DamageType,
                    penleft = pen,
                    att = att,
                    tr = tr,
                    dmg = dmg
                })

                if !ret then return end

                dmg:SetDamageType(ret.dmgtype)
                dmg:SetDamage(ret.damage)

                if dmg:GetDamageType() == DMG_BURN and ret.range <= self.Range then
                    if num == 1 then
                        dmg:SetDamageType(DMG_BULLET)
                    else
                        dmg:SetDamageType(DMG_BUCKSHOT)
                    end
                    local fx = EffectData()
                    fx:SetOrigin(tr.HitPos)
                    util.Effect("arccw_incendiaryround", fx)

                    util.Decal("FadingScorch", tr.StartPos, tr.HitPos - (tr.HitNormal * 16), self:GetOwner())

                    if SERVER then
                        if vFireInstalled then
                            CreateVFire(tr.Entity, tr.HitPos, tr.HitNormal, ret.damage * 0.02)
                        else
                            tr.Entity:Ignite(1, 0)
                        end
                    end
                end

                self:DoPenetration(tr, ret.penleft, {tr.Entity})
            end
        }

        local se = self:GetBuff_Override("Override_ShootEntity") or self.ShootEntity

        local sp = self:GetBuff_Override("Override_ShotgunSpreadPattern") or self.ShotgunSpreadPattern
        local spo = self:GetBuff_Override("Override_ShotgunSpreadPatternOverrun") or self.ShotgunSpreadPatternOverrun

        if sp or spo then
            btabl = self:GetBuff_Hook("Hook_FireBullets", btabl)

            if !btabl then return end
            -- if btabl.Num == 0 then return end

            local spd = AngleRand() * self:GetDispersion() / 360 / 60

            if btabl.Num > 0 then
                for n = 1, btabl.Num do
                    btabl.Num = 1
                    local ang
                    if self:GetBuff_Override("Override_ShotgunSpreadDispersion") or self.ShotgunSpreadDispersion then
                        ang = self:GetOwner():EyeAngles() + (self:GetShotgunSpreadOffset(n) * self:GetDispersion() / 60)
                    else
                        ang = self:GetOwner():EyeAngles() + self:GetShotgunSpreadOffset(n) + spd
                    end

                    ang = ang + AngleRand() * spread / 10

                    btabl.Dir = ang:Forward()

                    self:GetOwner():LagCompensation(true)

                    self:GetOwner():FireBullets(btabl)

                    self:GetOwner():LagCompensation(false)
                end
            end
        elseif se then
            if num > 1 then
                local spd = AngleRand() * self:GetDispersion() / 360 / 60

                for n = 1, btabl.Num do
                    btabl.Num = 1
                    local ang
                    if self:GetBuff_Hook("Override_ShotgunSpreadDispersion") or self.ShotgunSpreadDispersion then
                        ang = self:GetOwner():EyeAngles() + (self:GetShotgunSpreadOffset(n) * self:GetDispersion() / 360 / 60)
                    else
                        ang = self:GetOwner():EyeAngles() + self:GetShotgunSpreadOffset(n) + spd
                    end

                    ang = ang + AngleRand() * spread / 10

                    self:FireRocket(se, self.MuzzleVelocity * ArcCW.HUToM * self:GetBuff_Mult("Mult_MuzzleVelocity"), ang)
                end
            elseif num > 0 then
                local spd = AngleRand() * self:GetDispersion() / 360 / 60
                local ang = self:GetOwner():EyeAngles() + (AngleRand() * spread / 10)

                self:FireRocket(se, self.MuzzleVelocity * ArcCW.HUToM * self:GetBuff_Mult("Mult_MuzzleVelocity"), ang + spd)
            end
        else
            btabl = self:GetBuff_Hook("Hook_FireBullets", btabl)

            if !btabl then return end
            if btabl.Num > 0 then

                self:GetOwner():LagCompensation(true)

                self:GetOwner():FireBullets(btabl)

                self:GetOwner():LagCompensation(false)

            end
        end

        self:DoRecoil()

        self:GetOwner():DoAnimationEvent(self:GetBuff_Override("Override_AnimShoot") or self.AnimShoot)

        local svol = self.ShootVol * self:GetBuff_Mult("Mult_ShootVol")
        local spitch = self.ShootPitch * math.Rand(0.95, 1.05) * self:GetBuff_Mult("Mult_ShootPitch")

        svol = math.Clamp(svol, 51, 149)
        spitch = math.Clamp(spitch, 51, 149)

        if SERVER and !game.SinglePlayer() then
            SuppressHostEvents(self:GetOwner())
        end

        self:DoEffects()

        if dss then
            -- sound.Play(self.DistantShootSound, self:GetPos(), 149, self.ShootPitch * math.Rand(0.95, 1.05), 1)
            self:EmitSound(dss, 149, spitch, 0.5, CHAN_WEAPON + 1)
        end

        if ss then
			local SelfPos=self:GetPos()
			if((SERVER)or(CLIENT and IsFirstTimePredicted()))then
				self:EmitSound(ss, svol, spitch, 1, CHAN_WEAPON)
				if((self.ShootSoundExtraMult)and(self.ShootSoundExtraMult>0))then
					for i=1,self.ShootSoundExtraMult do
						sound.Play(ss,SelfPos,svol+i,spitch,1)
					end
				end
			end
        end

        if IsFirstTimePredicted() then
            self.BurstCount = self.BurstCount + 1
        end

        self:TakePrimaryAmmo(1)

        local ret = "fire"

        if self:Clip1() == 0 and self.Animations.fire_iron_empty and self:GetState() == ArcCW.STATE_SIGHTS then
            ret = "fire_iron_empty"
        elseif self:Clip1() == 0 and self.Animations.fire_empty and self:GetState() != ArcCW.STATE_SIGHTS then
            ret = "fire_empty"
        else
            if self:GetState() == ArcCW.STATE_SIGHTS and self.Animations.fire_iron then
                ret = "fire_iron"
            else
                ret = "fire"
            end
        end

        if self.ProceduralIronFire and self:GetState() == ArcCW.STATE_SIGHTS then
            ret = nil
        elseif self.ProceduralRegularFire and self:GetState() != ArcCW.STATE_SIGHTS then
            ret = nil
        end


        ret = ret or self:GetBuff_Hook("Hook_SelectFireAnimation", ret)

        if ret then
            self:PlayAnimation(ret, 1, true, 0, false)
        end

        if self.ManualAction or self:GetBuff_Override("Override_ManualAction") then
            if !(self.NoLastCycle and self:Clip1() == 0) then
                self:SetNWBool("cycle", true)
            end
        end

        if self:GetCurrentFiremode().Mode < 0 and self.BurstCount == -self:GetCurrentFiremode().Mode then
            local postburst = self:GetCurrentFiremode().PostBurstDelay or 0

            self:SetNextPrimaryFire(CurTime() + postburst)
        end

        self:GetBuff_Hook("Hook_PostFireBullets")

        if SERVER and !game.SinglePlayer() then
            SuppressHostEvents(nil)
        end
    -- end

    math.randomseed(CurTime() + (self:EntIndex() % 31259))
end
-- think
local lastUBGL = 0
function SWEP:Think()
    if !IsValid(self:GetOwner()) or self:GetOwner():IsNPC() then return end

    local vm = self:GetOwner():GetViewModel()

    if self:GetOwner():KeyPressed(IN_ATTACK) then
        self:SetNWBool("reqend", true)
    end

    if CLIENT then
        if ArcCW.LastWeapon != self then
            self:LoadPreset("autosave")
        end

        ArcCW.LastWeapon = self
    end

    self:InBipod()

    if (self:GetCurrentFiremode().Mode == 2 or !self:GetOwner():KeyDown(IN_ATTACK)) and self:GetNWBool("cycle", false) and !self:GetNWBool("reloading", false) then
        local anim = "cycle"
        if self:GetState() == ArcCW.STATE_SIGHTS and self.Animations.cycle_iron then
            anim = "cycle_iron"
        end
        anim = self:GetBuff_Hook("Hook_SelectCycleAnimation", anim) or anim
        local mult = self:GetBuff_Mult("Mult_CycleTime")
        self:PlayAnimation(anim, mult, true, 0, true)
        self:SetNWBool("cycle", false)
    end

    if self:GetNWBool("grenadeprimed") and !self:GetOwner():KeyDown(IN_ATTACK) then
        self:Throw()
    end

    if self:GetNWBool("grenadeprimed") and self.GrenadePrimeTime > 0 then
        local heldtime = (CurTime() - self.GrenadePrimeTime)

        if self.FuseTime and (heldtime >= self.FuseTime) then
            self:Throw()
        end
    end

    if self:GetOwner():KeyPressed(IN_USE) then
        if self:InBipod() then
            self:ExitBipod()
        else
            self:EnterBipod()
        end
    end

    if self:GetCurrentFiremode().RunawayBurst and self:Clip1() > 0 then
        if self.BurstCount > 0 then
            self:PrimaryAttack()
        end

        if self.BurstCount == self:GetBurstLength() then
            self.Primary.Automatic = false
            self.BurstCount = 0
        end
    end

    if self:GetOwner():KeyReleased(IN_ATTACK) then
        if !self:GetCurrentFiremode().RunawayBurst then
            self.BurstCount = 0
        end

        if self:GetCurrentFiremode().Mode < 0 and !self:GetCurrentFiremode().RunawayBurst then
            local postburst = self:GetCurrentFiremode().PostBurstDelay or 0

            if (CurTime() + postburst) > self:GetNextPrimaryFire() then
            self:SetNextPrimaryFire(CurTime() + postburst)
            end
        end
    end

    if self:InSprint() and (!self.Sprinted or self:GetState() != ArcCW.STATE_SPRINT) then
        self:EnterSprint()
    elseif !self:InSprint() and (self.Sprinted or self:GetState() == ArcCW.STATE_SPRINT) then
        self:ExitSprint()
    end

    if !(self.ReloadInSights and (self:GetNWBool("reloading", false) or self:GetOwner():KeyDown(IN_RELOAD))) then
        if self:GetOwner():GetInfoNum("arccw_altubglkey", 0) == 1 and self:GetBuff_Override("UBGL") and self:GetOwner():KeyDown(IN_USE) then
            if self:GetOwner():KeyPressed(IN_ATTACK2) and CLIENT then
                if (lastUBGL or 0) + 0.25 > CurTime() then return end
                lastUBGL = CurTime()
                if self:GetNWBool("ubgl") then
                    net.Start("arccw_ubgl")
                    net.WriteBool(false)
                    net.SendToServer()

                    self:DeselectUBGL()
                else
                    net.Start("arccw_ubgl")
                    net.WriteBool(true)
                    net.SendToServer()

                    self:SelectUBGL()
                end
            end
        elseif self:GetOwner():GetInfoNum("arccw_toggleads", 0) == 0 then
            if (self:GetOwner():KeyPressed(IN_ATTACK2) or self.IronSightStruct.debugSights) and (!self.Sighted or self:GetState() != ArcCW.STATE_SIGHTS) then
                self:EnterSights()
            elseif self:GetOwner():KeyReleased(IN_ATTACK2) and (self.Sighted or self:GetState() == ArcCW.STATE_SIGHTS) then
                self:ExitSights()
            end
        else
            if self:GetOwner():KeyPressed(IN_ATTACK2) then
                if !self.Sighted or self:GetState() != ArcCW.STATE_SIGHTS then
                    self:EnterSights()
                else
                    self:ExitSights()
                end
            end
        end
    end

    if (CLIENT or game.SinglePlayer()) and (IsFirstTimePredicted() or game.SinglePlayer()) then
        local ft = FrameTime()
        -- if CLIENT then
        --    ft = RealFrameTime()
        -- end

        local newang = self:GetOwner():EyeAngles()
        local r = self.RecoilAmount -- self:GetNWFloat("recoil", 0)
        local rs = self.RecoilAmountSide -- self:GetNWFloat("recoilside", 0)

        local ra = Angle(0, 0, 0)

        ra = ra + ((self:GetBuff_Override("Override_RecoilDirection") or self.RecoilDirection) * self.RecoilAmount * 0.5)
        ra = ra + ((self:GetBuff_Override("Override_RecoilDirectionSide") or self.RecoilDirectionSide) * self.RecoilAmountSide * 0.5)

        newang = newang - ra

        self.RecoilAmount = r - (ft * r * 20)
        self.RecoilAmountSide = rs - (ft * rs * 20)

        self.RecoilAmount = math.Approach(self.RecoilAmount, 0, ft * 0.1)
        self.RecoilAmountSide = math.Approach(self.RecoilAmountSide, 0, ft * 0.1)

        -- self:SetNWFloat("recoil", r - (FrameTime() * r * 50))
        -- self:SetNWFloat("recoilside", rs - (FrameTime() * rs * 50))

        self:GetOwner():SetEyeAngles(newang)

        local rpb = self.RecoilPunchBack
        local rps = self.RecoilPunchSide
        local rpu = self.RecoilPunchUp

        if rpb != 0 then
            self.RecoilPunchBack = math.Approach(rpb, 0, ft * rpb * 2.5)
        end

        if rps != 0 then
            self.RecoilPunchSide = math.Approach(rps, 0, ft * rps * 5)
        end

        if rpu != 0 then
            self.RecoilPunchUp = math.Approach(rpu, 0, ft * rpu * 5)
        end

        if IsValid(vm) then
            local vec1 = Vector(1, 1, 1)
            local vec0 = vec1 * 0

            for i = 1, vm:GetBoneCount() do
                vm:ManipulateBoneScale(i, vec1 )
            end

            for i, k in pairs(self.CaseBones or {}) do
                if !isnumber(i) then continue end
                local bone = vm:LookupBone(k)

                if !bone then continue end

                vm:ManipulateBoneScale(bone, vec0)
            end

            for i, k in pairs(self.BulletBones or {}) do
                if !isnumber(i) then continue end
                local bone = vm:LookupBone(k)

                if !bone then continue end

                vm:ManipulateBoneScale(bone, vec0)
            end

            for i, k in pairs(self.CaseBones or {}) do
                if !isnumber(i) then continue end
                local bone = vm:LookupBone(k)

                if !bone then continue end

                if self:GetVisualClip() >= i then
                vm:ManipulateBoneScale(bone, vec1)
                end
            end

            for i, k in pairs(self.BulletBones or {}) do
                if !isnumber(i) then continue end
                local bone = vm:LookupBone(k)

                if !bone then continue end

                if self:GetVisualBullets() >= i then
                vm:ManipulateBoneScale(bone, vec1)
                end
            end
        end
    end

    -- if CLIENT then
        -- if !IsValid(ArcCW.InvHUD) then
        --     gui.EnableScreenClicker(false)
        -- end

        -- if self:GetState() != ArcCW.STATE_CUSTOMIZE then
        --     self:CloseCustomizeHUD()
        -- else
        --     self:OpenCustomizeHUD()
        -- end
    -- end

    if SERVER and self.Throwing and self:Clip1() == 0 and self:Ammo1() > 0 then
        self:SetClip1(1)
        self:GetOwner():SetAmmo(self:Ammo1() - 1, self.Primary.Ammo)
    end

    -- self:RefreshBGs()

    self:GetBuff_Override("Hook_Think")

    -- Running this only serverside in SP breaks animation processing and causes CheckpointAnimation to not reset.
    --if SERVER or !game.SinglePlayer() then
        self:ProcessTimers()
    --end
end
-- initialize
function SWEP:Initialize()
    if (!IsValid(self:GetOwner()) or self:GetOwner():IsNPC()) and self:IsValid() and self.NPC_Initialize and SERVER then
        self:NPC_Initialize()
    end

    if game.SinglePlayer() and self:GetOwner():IsValid() and SERVER then
        self:CallOnClient("Initialize")
    end

    if CLIENT then
        local class = self:GetClass()

        if self.KillIconAlias then
            killicon.AddAlias(class, self.KillIconAlias)
            class = self.KillIconAlias
        end

        local path = "arccw/weaponicons/" .. class
        local mat = Material(path)

        if !mat:IsError() then

            local tex = mat:GetTexture("$basetexture")
            local texpath = tex:GetName()
            killicon.Add(class, texpath, Color(255, 255, 255))
            self.WepSelectIcon = surface.GetTextureID(texpath)

            if self.ShootEntity then
            killicon.Add(self.ShootEntity, texpath, Color(255, 255, 255))
            end

        end

        -- Check for incompatibile addons once 
        if LocalPlayer().ArcCW_IncompatibilityCheck ~= true then
            LocalPlayer().ArcCW_IncompatibilityCheck = true
            local incompatList = {}
            local addons = engine.GetAddons()
            for _, addon in pairs(addons) do
                if ArcCW.IncompatibleAddons[tostring(addon.wsid)] and addon.mounted then
                    incompatList[tostring(addon.wsid)] = addon
                end
            end
            local shouldDo = true
            -- If never show again is on, verify we have no new addons
            if file.Exists("arccw_incompatible.txt", "DATA") then
                shouldDo = false
                local oldTbl = util.JSONToTable(file.Read("arccw_incompatible.txt"))
                for id, addon in pairs(incompatList) do
                    if !oldTbl[id] then shouldDo = true break end
                end
                if shouldDo then file.Delete("arccw_incompatible.txt") end
            end
            if shouldDo and table.Count(incompatList) > 0 then
                ArcCW.MakeIncompatibleWindow(incompatList)
            end
        end
    end

    if GetConVar("arccw_equipmentsingleton"):GetBool() and self.Throwing then
        self.Singleton = true
        self.Primary.ClipSize = -1
        self.Primary.Ammo = ""
    end

    self:SetState(0)
    self:SetClip2(0)

    self.Attachments["BaseClass"] = nil

    if GetConVar("arccw_mult_defaultclip"):GetInt() < 0 then
        self.Primary.DefaultClip = self.Primary.ClipSize * 3
        if self.Primary.ClipSize >= 100 then
            self.Primary.DefaultClip = self.Primary.ClipSize * 2
        end
    else
        self.Primary.DefaultClip = self.Primary.ClipSize * GetConVar("arccw_mult_defaultclip"):GetInt()
    end
	if(self.NoFreeAmmo)then self.Primary.DefaultClip = 0 end

    self:SetHoldType(self.HoldtypeActive)

    local og = weapons.Get(self:GetClass())

    self.RegularClipSize = og.Primary.ClipSize

    self.OldPrintName = self.PrintName

    self:InitTimers()

    if engine.ActiveGamemode() == "terrortown" then
        self:TTT_Init()
    end
end
-- customization
function SWEP:ToggleCustomizeHUD(ic) -- jmod will have its own customization system
	--[[
    if ic and self:GetState() == ArcCW.STATE_SPRINT then return end

    if ic then
        if (self:GetNextPrimaryFire() + 0.1) >= CurTime() then return end

        self:SetState(ArcCW.STATE_CUSTOMIZE)
        self:ExitSights()
        self:SetShouldHoldType()
        self:ExitBipod()
        if CLIENT then
            self:OpenCustomizeHUD()
        end
    else
        self:SetState(ArcCW.STATE_IDLE)
        self.Sighted = false
        self.Sprinted = false
        self:SetShouldHoldType()
        if CLIENT then
            self:CloseCustomizeHUD()
            self:SendAllDetails()
        end
    end
	--]]
end
if(CLIENT)then
	--[[
	-- viewbob during reload and firing shake
	SWEP.ProceduralViewOffset = Angle(0, 0, 0)
	local procedural_spdlimit = 5
	local oldangtmp, oldpostmp
	local mzang_fixed,mzang_fixed_last
	local mzang_velocity = Angle()
	local progress = 0
	local targint,targbool,oldBipodTxt
	local bipodTxtTime = 0
	function SWEP:CalcView(ply, pos, ang, fov)
		if not(self.ProceduralViewBobIntensity)then return end
		if not ang then return end
		if ply ~= LocalPlayer() then return end
		if(ply:ShouldDrawLocalPlayer())then return end
		local vm = ply:GetViewModel()
		if not IsValid(vm) then return end
		if not CLIENT then return end
		local ftv = math.max(FrameTime(), 0.001)
		local viewbobintensity = 0.2 * 5

		oldpostmp = pos * 1
		oldangtmp = ang * 1

		targbool = self:GetNextPrimaryFire() - .1 > CurTime()
		targint = targbool and 1 or 0
		targint = math.min(targint, 1-math.pow( vm:GetCycle(), 2 ) )
		progress = Lerp(ftv * 15, progress, targint)
		
		local angpos = vm:GetAttachment(self.ProceduralViewBobAttachment or 1)

		if angpos then
			mzang_fixed = vm:WorldToLocalAngles(angpos.Ang)
			mzang_fixed:Normalize()
		end

		self.ProceduralViewOffset:Normalize()

		if mzang_fixed_last then
			local delta = mzang_fixed - mzang_fixed_last
			delta:Normalize()
			mzang_velocity = mzang_velocity + delta * 2
			mzang_velocity.p = math.Approach(mzang_velocity.p, -self.ProceduralViewOffset.p * 2, ftv * 20)
			mzang_velocity.p = math.Clamp(mzang_velocity.p, -procedural_spdlimit, procedural_spdlimit)
			self.ProceduralViewOffset.p = self.ProceduralViewOffset.p + mzang_velocity.p * ftv
			self.ProceduralViewOffset.p = math.Clamp(self.ProceduralViewOffset.p, -90, 90)
			mzang_velocity.y = math.Approach(mzang_velocity.y, -self.ProceduralViewOffset.y * 2, ftv * 20)
			mzang_velocity.y = math.Clamp(mzang_velocity.y, -procedural_spdlimit, procedural_spdlimit)
			self.ProceduralViewOffset.y = self.ProceduralViewOffset.y + mzang_velocity.y * ftv
			self.ProceduralViewOffset.y = math.Clamp(self.ProceduralViewOffset.y, -90, 90)
			mzang_velocity.r = math.Approach(mzang_velocity.r, -self.ProceduralViewOffset.r * 2, ftv * 20)
			mzang_velocity.r = math.Clamp(mzang_velocity.r, -procedural_spdlimit, procedural_spdlimit)
			self.ProceduralViewOffset.r = self.ProceduralViewOffset.r + mzang_velocity.r * ftv
			self.ProceduralViewOffset.r = math.Clamp(self.ProceduralViewOffset.r, -90, 90)
		end

		self.ProceduralViewOffset.p = math.Approach(self.ProceduralViewOffset.p, 0, (1 - progress) * ftv * -self.ProceduralViewOffset.p)
		self.ProceduralViewOffset.y = math.Approach(self.ProceduralViewOffset.y, 0, (1 - progress) * ftv * -self.ProceduralViewOffset.y)
		self.ProceduralViewOffset.r = math.Approach(self.ProceduralViewOffset.r, 0, (1 - progress) * ftv * -self.ProceduralViewOffset.r)
		mzang_fixed_last = mzang_fixed
		local ints = 3 * -self.ProceduralViewBobIntensity
		ang:RotateAroundAxis(ang:Right(), Lerp(progress, 0, -self.ProceduralViewOffset.p) * ints)
		ang:RotateAroundAxis(ang:Up(), Lerp(progress, 0, self.ProceduralViewOffset.y / 2) * ints)
		ang:RotateAroundAxis(ang:Forward(), Lerp(progress, 0, self.ProceduralViewOffset.r / 3) * ints)

		return pos, LerpAngle(0, ang, oldangtmp) + (AngleRand() * self.RecoilAmount * 0.008), fov
	end
	--]]
	-- expensive scopes
	local rtsize = ScrH()
	local rtmat = GetRenderTarget("arccw_rtmat", rtsize, rtsize, false)
	local black = Material("hud/black.png")
	local defaultdot = Material("hud/scopes/dot.png")
	function SWEP:DrawHolosight(hs, hsm, hsp)
		-- holosight structure
		-- holosight model

		local asight = self:GetActiveSights()
		local delta = self:GetSightDelta()

		if asight.HolosightData then
			hs = asight.HolosightData
		end

		if delta == 1 then return end

		if !hs then return end

		local hsc = Color(255, 255, 255)

		if hs.Colorable then
			hsc.r = GetConVar("arccw_scope_r"):GetInt()
			hsc.g = GetConVar("arccw_scope_g"):GetInt()
			hsc.b = GetConVar("arccw_scope_b"):GetInt()
		else
			hsc = hs.HolosightColor or hsc
		end

		local attid = 0

		if hsm then

			attid = hsm:LookupAttachment(asight.HolosightBone or hs.HolosightBone or "holosight")

			if attid == 0 then
				attid = hsm:LookupAttachment("holosight")
			end

		end

		local ret, pos, ang

		if attid != 0 then

			ret = hsm:GetAttachment(attid)
			pos = ret.Pos
			ang = ret.Ang

		else

			pos = EyePos()
			ang = EyeAngles()

		end

		local size = hs.HolosightSize or 1

		local hsmag = asight.ScopeMagnification or 1

		-- if asight.NightVision then

		if hsmag and hsmag > 1 and delta < 1 and asight.NVScope then
			local screen = rtmat
			self:FormNightVision(screen)
		end

		render.UpdateScreenEffectTexture()
		render.ClearStencil()
		render.SetStencilEnable(true)
		render.SetStencilCompareFunction(STENCIL_ALWAYS)
		render.SetStencilPassOperation(STENCIL_REPLACE)
		render.SetStencilFailOperation(STENCIL_KEEP)
		render.SetStencilZFailOperation(STENCIL_REPLACE)
		render.SetStencilWriteMask(255)
		render.SetStencilTestMask(255)

		render.SetBlend(0)

			render.SetStencilReferenceValue(55)

			ArcCW.Overdraw = true

			render.OverrideDepthEnable( true, true )

			if !hsm then
				hsp:DrawModel()
			else

				if !hsp or hs.HolosightNoHSP then
					hsm:DrawModel()
				end

				render.MaterialOverride()

				render.SetStencilReferenceValue(0)

				hsm:SetBodygroup(1, 1)
				-- hsm:SetSubMaterial(0, "dev/no_pixel_write")
				hsm:DrawModel()
				-- hsm:SetSubMaterial()
				hsm:SetBodygroup(1, 0)

				-- local vm = self:GetOwner():GetViewModel()

				-- ArcCW.Overdraw = true
				-- vm:DrawModel()

				-- ArcCW.Overdraw = false

				render.SetStencilReferenceValue(55)

				if hsp then
					hsp:DrawModel()
				end
			end

			render.MaterialOverride()

			render.OverrideDepthEnable( false, true )

			ArcCW.Overdraw = false

		render.SetBlend(1)

		render.SetStencilPassOperation(STENCIL_REPLACE)
		render.SetStencilCompareFunction(STENCIL_EQUAL)

		-- local pos = EyePos()
		-- local ang = EyeAngles()

		ang:RotateAroundAxis(ang:Forward(), -90)

		ang = ang + (self:GetOwner():GetViewPunchAngles() * 0.25)

		local dir = ang:Up()

		local pdiff = (pos - EyePos()):Length()

		pos = LerpVector(delta, EyePos(), pos)

		local eyeangs = self:GetOwner():EyeAngles() - (self:GetOwner():GetViewPunchAngles() * 0.25)

		-- local vm = hsm or hsp

		-- eyeangs = eyeangs + (eyeangs - vm:GetAngles())

		dir = LerpVector(delta, eyeangs:Forward(), dir:GetNormalized())

		pdiff = Lerp(delta, pdiff, 0)

		local d = (8 + pdiff)

		d = hs.HolosightConstDist or d

		local vmscale = (self.Attachments[asight.Slot] or {}).VMScale or Vector(1, 1, 1)

		if hs.HolosightConstDist then
			vmscale = Vector(1, 1, 1)
		end

		local hsx = vmscale[2] or 1
		local hsy = vmscale[3] or 1

		pos = pos + (dir * d)

		-- local corner1, corner2, corner3, corner4

		-- corner2 = pos + (ang:Right() * (-0.5 * size)) + (ang:Forward() * (0.5 * size))
		-- corner1 = pos + (ang:Right() * (-0.5 * size)) + (ang:Forward() * (-0.5 * size))
		-- corner4 = pos + (ang:Right() * (0.5 * size)) + (ang:Forward() * (-0.5 * size))
		-- corner3 = pos + (ang:Right() * (0.5 * size)) + (ang:Forward() * (0.5 * size))

		-- render.SetColorMaterialIgnoreZ()
		-- render.DrawScreenQuad()

		-- render.SetStencilEnable( false )
		-- local fovmag = asight.Magnification or 1

		if hsmag and hsmag > 1 and delta < 1 then
			local screen = rtmat

			-- local sw2 = ScrH()
			-- local sh2 = sw2

			-- local sx2 = (ScrW() - sw2) / 2
			-- local sy2 = (ScrH() - sh2) / 2

			-- render.SetScissorRect( sx2, sy2, sx2 + sw2, sy2 + sh2, true )

			local sw = ScrH()
			local sh = sw

			local sx = (ScrW() - sw) / 2
			local sy = (ScrH() - sh) / 2

			render.SetMaterial(black)
			render.DrawScreenQuad()

			render.DrawTextureToScreenRect(screen, sx, sy, sw, sh)

			-- warp:SetFloat("$refractamount", -0.015)
			-- render.UpdateRefractTexture()
			-- render.SetMaterial(warp)
			-- render.DrawScreenQuad()

			-- render.SetScissorRect( sx2, sy2, sx2 + sw2, sy2 + sh2, false )
		end

		cam.Start3D()

		-- render.SetColorMaterialIgnoreZ()
		-- render.DrawScreenQuad()

		-- render.DrawQuad( corner1, corner2, corner3, corner4, hsc or hs.HolosightColor )
		cam.IgnoreZ( true )

		if hs.HolosightBlackbox then
			render.SetStencilPassOperation(STENCIL_ZERO)
			render.SetStencilCompareFunction(STENCIL_EQUAL)

			render.SetStencilReferenceValue(55)

			render.SetMaterial(hs.HolosightReticle or defaultdot)
			render.DrawSprite(pos, size * hsx, size * hsy, hsc or Color(255, 255, 255))

			if !hs.HolosightNoFlare then
				render.SetMaterial(hs.HolosightFlare or hs.HolosightReticle)
				render.DrawSprite(pos, size * 0.5 * hsx, size * 0.5 * hsy, Color(255, 255, 255))
			end

			render.SetStencilPassOperation(STENCIL_REPLACE)
			render.SetStencilCompareFunction(STENCIL_EQUAL)

			render.SetMaterial(black)
			render.DrawScreenQuad()
		else
			render.SetStencilReferenceValue(55)

			render.SetMaterial(hs.HolosightReticle or defaultdot)
			render.DrawSprite( pos, size * hsx, size * hsy, hsc or Color(255, 255, 255) )
			if !hs.HolosightNoFlare then
				render.SetMaterial(hs.HolosightFlare or hs.HolosightReticle or defaultdot)
				local hss = 0.75
				if hs.HolosightFlare then
					hss = 1
				end
				render.DrawSprite( pos, size * hss * hsx, size * hss * hsy, Color(255, 255, 255, 255) )
			end
		end

		render.SetStencilEnable( false )

		cam.IgnoreZ( false )

		cam.End3D()

		if hsp then

			cam.IgnoreZ(true)
			render.SetBlend(delta + 0.1)
			hsp:DrawModel()
			render.SetBlend(1)

			cam.IgnoreZ( false )

		end
	end
	-- HUD time baby
	local function MyDrawText(tbl)
		local x = tbl.x
		local y = tbl.y
		surface.SetFont(tbl.font)

		if tbl.alpha then
			tbl.col.a = tbl.alpha
		end

		if tbl.align or tbl.yalign then
			local w, h = surface.GetTextSize(tbl.text)
			if tbl.align == 1 then
				x = x - w
			elseif tbl.align == 2 then
				x = x - (w / 2)
			end
			if tbl.yalign == 1 then
				y = y - h
			elseif tbl.yalign == 2 then
				y = y - h / 2
			end
		end

		if tbl.shadow then
			surface.SetTextColor(Color(0, 0, 0, tbl.alpha or 255))
			surface.SetTextPos(x, y)
			surface.SetFont(tbl.font .. "_Glow")
			surface.DrawText(tbl.text)
		end

		surface.SetTextColor(tbl.col)
		surface.SetTextPos(x, y)
		surface.SetFont(tbl.font)
		surface.DrawText(tbl.text)
	end

	local vhp = 0
	local varmor = 0
	local vclip = 0
	local vreserve = 0
	local lastwpn = ""
	local lastinfo = {ammo = 0, clip = 0, firemode = "", plus = 0}
	local lastinfotime = 0

	function SWEP:DrawHUD()
		-- info panel
		local Time = CurTime()

		local col1 = Color(0, 0, 0, 100)
		local col2 = Color(255, 255, 255, 255)
		local col3 = Color(255, 0, 0, 255)

		local airgap = ScreenScale(8)

		local apan_bg = {
			w = ScreenScale(128),
			h = ScreenScale(48),
		}

		local bargap = ScreenScale(2)
		
		if(self.IronSightStruct and self.IronSightStruct.debugSights)then
			surface.SetDrawColor(255,0,0,200)
			surface.DrawRect(ScrW()/2,ScrH()/2,2,2)
		end

		if self:CanBipod() then
			local txt = "[" .. string.upper(ArcCW:GetBind("+use")) .. "]"

			if self:InBipod() then
				txt = txt .. " Retract Bipod"
			else
				txt = txt .. " Deploy Bipod"
			end

			if(oldBipodTxt ~= txt)then
				bipodTxtTime = Time + 3
			end
			
			if(bipodTxtTime > Time)then
				local bip = {
					shadow = true,
					x = ScrW() / 2,
					y = (ScrH() / 2) + ScreenScale(36),
					font = "ArcCW_12",
					text = txt,
					col = col2,
					align = 2
				}
				MyDrawText(bip)
				oldBipodTxt = txt
			end
		end

		if not LocalPlayer():ShouldDrawLocalPlayer() then

			local curTime = CurTime()
			local ammo = math.Round(vreserve)
			local clip = math.Round(vclip)
			local plus = 0
			local mode = self:GetFiremodeName()

			if clip > self:GetCapacity() then
				plus = clip - self:GetCapacity()
				clip = clip - plus
			end

			local muzz = self:GetBuff_Override("Override_MuzzleEffectAttachment") or self.MuzzleEffectAttachment or 1

			local vm = self.Owner:GetViewModel()

			local angpos

			if vm and vm:IsValid() then
				angpos = vm:GetAttachment(muzz)
				angpos.Pos=angpos.Pos-Vector(0,0,5)-EyeAngles():Right()*4
			end

			if muzz and angpos then

				local visible = (lastinfotime + 4 > curTime or lastinfotime - 0.5 > curTime)

				-- Detect changes to stuff drawn in HUD
				local curInfo = {ammo = ammo, clip = clip, plus = plus, firemode = mode}
				for i, v in pairs(curInfo) do
					if v != lastinfo[i] then
						if(i=="clip" and v>0)then
							-- don't show
						elseif(i=="plus")then
							-- don't show either
						else
							lastinfotime = visible and (curTime - 0.5) or curTime
						end
						lastinfo = curInfo
						break
					end
				end

				-- TODO: There's an issue where this won't ping the HUD when switching in from non-ArcCW weapons
				if LocalPlayer():KeyDown(IN_RELOAD) or lastwpn != self then lastinfotime = visible and (curTime - 0.5) or curTime end

				local alpha
				if lastinfotime + 3 < curTime then
					alpha = 255 - (curTime - lastinfotime - 3) * 255
				elseif lastinfotime + 0.5 > curTime then
					alpha = 255 - (lastinfotime + 0.5 - curTime) * 255
				else
					alpha = 255
				end

				if alpha > 0 then

					cam.Start3D()
						local toscreen = angpos.Pos:ToScreen()
					cam.End3D()

					apan_bg.x = toscreen.x - apan_bg.w - ScreenScale(8)
					apan_bg.y = toscreen.y - apan_bg.h * 0.5

					if self.PrimaryBash or self:Clip1() == -1 or self:GetCapacity() == 0 or self.Primary.ClipSize == -1 then
						clip = "-"
					end

					local wammo = {
						x = apan_bg.x + apan_bg.w - airgap,
						y = apan_bg.y,
						text = tostring(clip),
						font = "ArcCW_26",
						col = col2,
						align = 1,
						shadow = true,
						alpha = alpha,
					}

					wammo.col = col2

					if self:Clip1() == 0 then
						wammo.col = col3
					end

					if self:GetNWBool("ubgl") then
						wammo.col = col2
						wammo.text = self:Clip2()
					end

					MyDrawText(wammo)
					wammo.w, wammo.h = surface.GetTextSize(wammo.text)

					if plus > 0 and !self:GetNWBool("ubgl") then
						local wplus = {
							x = wammo.x,
							y = wammo.y,
							text = "+" .. tostring(plus),
							font = "ArcCW_16",
							col = col2,
							shadow = true,
							alpha = alpha,
						}

						MyDrawText(wplus)
					end


					local wreserve = {
						x = wammo.x - wammo.w - ScreenScale(4),
						y = apan_bg.y + ScreenScale(26 - 12),
						text = tostring(ammo) .. " /",
						font = "ArcCW_12",
						col = col2,
						align = 1,
						yalign = 2,
						shadow = true,
						alpha = alpha,
					}

					if self:GetNWBool("ubgl") then
						local ubglammo = self:GetBuff_Override("UBGL_Ammo")

						if ubglammo then
							wreserve.text = tostring(self:GetOwner():GetAmmoCount(ubglammo)) .. " /"
						end
					end

					if self.PrimaryBash then
						wreserve.text = ""
					end

					MyDrawText(wreserve)
					wreserve.w, wreserve.h = surface.GetTextSize(wreserve.text)

					local wmode = {
						x = apan_bg.x + apan_bg.w - airgap,
						y = wammo.y + wammo.h,
						font = "ArcCW_12",
						text = mode,
						col = col2,
						align = 1,
						shadow = true,
						alpha = alpha,
					}
					MyDrawText(wmode)

				end
			end

		end

		vhp = math.Approach(vhp, self:GetOwner():Health(), RealFrameTime() * 100)
		varmor = math.Approach(varmor, self:GetOwner():Armor(), RealFrameTime() * 100)

		local clipdiff = math.abs(vclip - self:Clip1())
		local reservediff = math.abs(vreserve - self:Ammo1())

		if clipdiff == 1 then
			vclip = self:Clip1()
		end

		vclip = math.Approach(vclip, self:Clip1(), RealFrameTime() * 30 * clipdiff)
		vreserve = math.Approach(vreserve, self:Ammo1(), RealFrameTime() * 30 * reservediff)

		if lastwpn != self then
			vclip = self:Clip1()
			vreserve = self:Ammo1()
			vhp = self:GetOwner():Health()
			varmor = self:GetOwner():Armor()
		end

		lastwpn = self
	end
	function SWEP:ShouldDrawCrosshair()
		return false
	end
	-- viewmodel positioning and Lerp
	SWEP.ActualVMData = false

	local function ApproachVector(vec1, vec2, d)
		local vec3 = Vector()
		vec3[1] = math.Approach(vec1[1], vec2[1], d)
		vec3[2] = math.Approach(vec1[2], vec2[2], d)
		vec3[3] = math.Approach(vec1[3], vec2[3], d)

		return vec3
	end

	local function ApproachAngleA(vec1, vec2, d)
		local vec3 = Angle()
		vec3[1] = math.ApproachAngle(vec1[1], vec2[1], d)
		vec3[2] = math.ApproachAngle(vec1[2], vec2[2], d)
		vec3[3] = math.ApproachAngle(vec1[3], vec2[3], d)

		return vec3
	end

	function SWEP:GetViewModelPosition(pos, ang)
		if !self:GetOwner():IsValid() or !self:GetOwner():Alive() then return end
		local oldpos = Vector()
		local oldang = Angle()

		local ft = RealFrameTime()
		local ct = UnPredictedCurTime()

		local asight = self:GetActiveSights()

		oldpos:Set(pos)
		oldang:Set(ang)

		ang = ang - (self:GetOwner():GetViewPunchAngles() * 0.5)

		actual = self.ActualVMData or {pos = Vector(0, 0, 0), ang = Angle(0, 0, 0), down = 1, sway = 1, bob = 1}

		local target = {
			pos = self:GetBuff_Override("Override_ActivePos") or self.ActivePos,
			ang = self:GetBuff_Override("Override_ActiveAng") or self.ActiveAng,
			down = 1,
			sway = 2,
			bob = 2,
		}

		local vm_right = GetConVar("arccw_vm_right"):GetFloat()
		local vm_up = GetConVar("arccw_vm_up"):GetFloat()
		local vm_forward = GetConVar("arccw_vm_forward"):GetFloat()

		local state = self:GetState()

		if self:GetOwner():Crouching() then
			target.down = 0
			if self.CrouchPos then
				target.pos = self.CrouchPos
				target.ang = self.CrouchAng
			end
		end

		if self:InBipod() then
			target.pos = target.pos + ((self.BipodAngle - self:GetOwner():EyeAngles()):Right() * -4)
			target.sway = 0.2
		end

		target.pos = target.pos + Vector(vm_right, vm_forward, vm_up)

		local sighted = self.Sighted or state == ArcCW.STATE_SIGHTS
		if game.SinglePlayer() then
			sighted = state == ArcCW.STATE_SIGHTS
		end

		local sprinted = self.Sprinted or state == ArcCW.STATE_SPRINT
		if game.SinglePlayer() then
			sprinted = state == ArcCW.STATE_SPRINT
		end

		if state == ArcCW.STATE_CUSTOMIZE then
			target = {
				pos = Vector(),
				ang = Angle(),
				down = 1,
				sway = 3,
				bob = 1,
			}

			local mx, my = input.GetCursorPos()

			mx = 2 * mx / ScrW()
			my = 2 * my / ScrH()

			target.pos:Set(self.CustomizePos)
			target.ang:Set(self.CustomizeAng)

			target.pos = target.pos + Vector(mx, 0, my)
			target.ang = target.ang + Angle(0, my * 2, mx * 2)

			if self.InAttMenu then
				target.ang = target.ang + Angle(0, -5, 0)
			end

		elseif (sprinted or (self:GetCurrentFiremode().Mode == 0 and !sighted)) and !(self:GetBuff_Override("Override_ShootWhileSprint") or self.ShootWhileSprint) then
			target = {
				pos = Vector(),
				ang = Angle(),
				down = 1,
				sway = GetConVar("arccw_vm_sway_sprint"):GetInt(),
				bob = GetConVar("arccw_vm_bob_sprint"):GetInt(),
			}

			target.pos:Set(self.HolsterPos)

			target.pos = target.pos + Vector(vm_right, vm_forward, vm_up)

			target.ang:Set(self.HolsterAng)

			if ang.p < -15 then
				target.ang.p = target.ang.p + ang.p + 15
			end

			target.ang.p = math.Clamp(target.ang.p, -80, 80)
		elseif sighted then
			local irons = self:GetActiveSights()

			target = {
				pos = irons.Pos,
				ang = irons.Ang,
				evpos = irons.EVPos or Vector(0, 0, 0),
				evang = irons.EVAng or Angle(0, 0, 0),
				down = 0,
				sway = 0.1,
				bob = 0.1,
			}

			local sr = self:GetBuff_Override("Override_AddSightRoll")

			if sr then
				target.ang = Angle()

				target.ang:Set(irons.Ang)
				target.ang.r = sr
			end

			-- local anchor = irons.AnchorBone

			-- if anchor then
			--     local vm = self:GetOwner():GetViewModel()
			--     local bone = vm:LookupBone(anchor)
			--     local bpos, bang = vm:GetBonePosition(bone)

			--     print(bpos)
			-- end
		end

		local deg = self:BarrelHitWall()

		if deg > 0 then
			target = {
				pos = LerpVector(deg, target.pos, self.HolsterPos),
				ang = LerpAngle(deg, target.ang, self.HolsterAng),
				down = 2,
				sway = 2,
				bob = 2,
			}
		end

		if isangle(target.ang) then
			target.ang = Angle(target.ang)
		end

		if self.InProcDraw then
			self.InProcHolster = false
			local delta = math.Clamp((ct - self.ProcDrawTime) / (0.25 * self:GetBuff_Mult("Mult_DrawTime")), 0, 1)
			target = {
				pos = LerpVector(delta, Vector(0, -30, -30), target.pos),
				ang = LerpAngle(delta, Angle(40, 30, 0), target.ang),
				down = target.down,
				sway = target.sway,
				bob = target.bob,
			}

			if delta == 1 then
				self.InProcDraw = false
			end
		end

		if self.InProcHolster then
			self.InProcDraw = false
			local delta = 1 - math.Clamp((ct - self.ProcHolsterTime) / (0.25 * self:GetBuff_Mult("Mult_DrawTime")), 0, 1)
			target = {
				pos = LerpVector(delta, Vector(0, -30, -30), target.pos),
				ang = LerpAngle(delta, Angle(40, 30, 0), target.ang),
				down = target.down,
				sway = target.sway,
				bob = target.bob,
			}

			if delta == 0 then
				self.InProcHolster = false
			end
		end

		if self.InProcBash then
			self.InProcDraw = false

			local mult = self:GetBuff_Mult("Mult_MeleeTime")
			local mt = self.MeleeTime * mult

			local delta = 1 - math.Clamp((ct - self.ProcBashTime) / mt, 0, 1)

			local bp = self.BashPos
			local ba = self.BashAng

			if delta > 0.3 then
				bp = self.BashPreparePos
				ba = self.BashPrepareAng
				delta = (delta - 0.5) * 2
			else
				delta = delta * 2
			end

			target = {
				pos = LerpVector(delta, bp, target.pos),
				ang = LerpAngle(delta, ba, target.ang),
				down = target.down,
				sway = target.sway,
				bob = target.bob,
				speed = 10
			}

			if delta == 0 then
				self.InProcBash = false
			end
		end

		if self.ViewModel_Hit then
			local nap = Vector()

			nap[1] = self.ViewModel_Hit[1]
			nap[2] = self.ViewModel_Hit[2]
			nap[3] = self.ViewModel_Hit[3]

			nap[1] = math.Clamp(nap[1], -1, 1)
			nap[2] = math.Clamp(nap[2], -1, 1)
			nap[3] = math.Clamp(nap[3], -1, 1)

			target.pos = target.pos + nap

			if !self.ViewModel_Hit:IsZero() then
				local naa = Angle()

				naa[1] = self.ViewModel_Hit[1]
				naa[2] = self.ViewModel_Hit[2]
				naa[3] = self.ViewModel_Hit[3]

				naa[1] = math.Clamp(naa[1], -1, 1)
				naa[2] = math.Clamp(naa[2], -1, 1)
				naa[3] = math.Clamp(naa[3], -1, 1)

				target.ang = target.ang + (naa * 10)
			end

			local nvmh = Vector(0, 0, 0)

			local spd = self.ViewModel_Hit:Length()

			nvmh[1] = math.Approach(self.ViewModel_Hit[1], 0, ft * 5 * spd)
			nvmh[2] = math.Approach(self.ViewModel_Hit[2], 0, ft * 5 * spd)
			nvmh[3] = math.Approach(self.ViewModel_Hit[3], 0, ft * 5 * spd)

			self.ViewModel_Hit = nvmh

			-- local nvma = Angle(0, 0, 0)

			-- local spd2 = 360

			-- nvma[1] = math.ApproachAngle(self.ViewModel_HitAng[1], 0, ft * 5 * spd2)
			-- nvma[2] = math.ApproachAngle(self.ViewModel_HitAng[2], 0, ft * 5 * spd2)
			-- nvma[3] = math.ApproachAngle(self.ViewModel_HitAng[3], 0, ft * 5 * spd2)

			-- self.ViewModel_HitAng = nvma
		end

		target.pos = target.pos + (VectorRand() * self.RecoilAmount * 0.2)

		local speed = target.speed or 3

		speed = 1 / self:GetSightTime() * speed * ft

		actual.pos = LerpVector(speed*.7, actual.pos, target.pos)
		actual.ang = LerpAngle(speed*.7, actual.ang, target.ang)
		actual.down = Lerp(speed, actual.down, target.down)
		actual.sway = Lerp(speed, actual.sway, target.sway)
		actual.bob = Lerp(speed, actual.bob, target.bob)
		actual.evpos = Lerp(speed, actual.evpos or Vector(0, 0, 0), target.evpos or Vector(0, 0, 0))
		actual.evang = Lerp(speed, actual.evang or Angle(0, 0, 0), target.evang or Angle(0, 0, 0))

		actual.pos = ApproachVector(actual.pos, target.pos, speed * 0.1)
		actual.ang = ApproachAngleA(actual.ang, target.ang, speed * 0.1)
		actual.down = math.Approach(actual.down, target.down, speed * 0.1)

		self.SwayScale = actual.sway
		self.BobScale = actual.bob

		pos = pos + self.RecoilPunchBack * -oldang:Forward()
		pos = pos + self.RecoilPunchSide * oldang:Right()
		pos = pos + self.RecoilPunchUp * -oldang:Up()

		ang:RotateAroundAxis( oldang:Right(), actual.ang.x )
		ang:RotateAroundAxis( oldang:Up(), actual.ang.y )
		ang:RotateAroundAxis( oldang:Forward(), actual.ang.z )

		ang:RotateAroundAxis( oldang:Right(), actual.evang.x )
		ang:RotateAroundAxis( oldang:Up(), actual.evang.y )
		ang:RotateAroundAxis( oldang:Forward(), actual.evang.z )

		pos = pos + (oldang:Right() * actual.evpos.x)
		pos = pos + (oldang:Forward() * actual.evpos.y)
		pos = pos + (oldang:Up() * actual.evpos.z)

		pos = pos + actual.pos.x * ang:Right()
		pos = pos + actual.pos.y * ang:Forward()
		pos = pos + actual.pos.z * ang:Up()

		pos = pos - Vector(0, 0, actual.down)

		if asight and asight.Holosight then
			ang = ang - (self:GetOwner():GetViewPunchAngles() * 0.5)
		end

		self.ActualVMData = actual

		return pos, ang
	end
end