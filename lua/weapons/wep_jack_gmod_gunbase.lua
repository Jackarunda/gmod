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

SWEP.ForceExpensiveScopes = true

SWEP.ChamberSize = 1 -- this is so wrong, Arctic...
SWEP.Primary.DefaultClip = 0
SWEP.Unobtrusive3DHUD = true

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
	if(self.BackBlast)then
		local SelfPos=self:GetPos()
		local RPos,RDir=self.Owner:GetShootPos(),self.Owner:GetAimVector()
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

        -- Check for incompatible addons once
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

    -- i got an idea, howabout you eat shit and die
	-- nothing is free, retard

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
function SWEP:ToggleCustomizeHUD(ic)
	-- jmod will have its own customization system
end
-- arctic's bash code is REALLY bad tbh
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
if(CLIENT)then
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
--[[
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
				if(angpos)then
					angpos.Pos=angpos.Pos-Vector(0,0,5)-EyeAngles():Right()*4
				end
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

				if alpha > 0 and not self.NoInfoDisplay then

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
					MyDrawText({
						x = apan_bg.x + apan_bg.w - airgap,
						y = wammo.y + wammo.h*1.6,
						font = "ArcCW_6",
						text = self.Primary.Ammo,
						col = col2,
						align = 1,
						shadow = true,
						alpha = alpha,
					})
				end
			end

		end
		
		-- health + armor

		if ArcCW:ShouldDrawHUDElement("CHudHealth") then

			local colhp = Color(255, 255, 255, 255)

			if LocalPlayer():Health() <= 30 then
				colhp = col3
			end

			local whp = {
				x = airgap,
				y = ScrH() - ScreenScale(26) - ScreenScale(16) - airgap,
				font = "ArcCW_26",
				text = "HP: " .. tostring(math.Round(vhp)),
				col = colhp,
				shadow = true
			}

			MyDrawText(whp)

			if LocalPlayer():Armor() > 0 then
				local war = {
					x = airgap,
					y = ScrH() - ScreenScale(16) - airgap,
					font = "ArcCW_16",
					text = "ARMOR: " .. tostring(math.Round(varmor)),
					col = col2,
					shadow = true
				}

				MyDrawText(war)
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
--]]
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
		
		local ProceduralRecoilMult = 1
		
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
		
		if(self.ReloadActivePos)then
			if(self:GetNWBool("reloading", false))then
				target.pos=self.ReloadActivePos
				target.ang=self.ReloadActiveAng
			end
		end

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
			ProceduralRecoilMult = ProceduralRecoilMult * .7
		
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

		pos = pos + self.RecoilPunchBack * -oldang:Forward() * ProceduralRecoilMult
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