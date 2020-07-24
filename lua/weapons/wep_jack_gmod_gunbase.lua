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
	local GlobalMult = (JMOD_CONFIG and JMOD_CONFIG.WeaponDamageMult) or 1

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
		local Amt,Sporadicness,FT=30*Wep.AimSwayFactor*GlobalMult,20,FrameTime()
		if(ply:Crouching())then Amt=Amt*.65 end
		if((Wep.InBipod)and(Wep:InBipod()))then Amt=Amt*.4 end
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
concommand.Add("jmod_ez_dropweapon",function(ply,cmd,args)
	if not(ply:Alive())then return end
	local Wep=ply:GetActiveWeapon()
	if((IsValid(Wep))and(Wep.EZdroppable))then ply:DropWeapon(Wep) end
end)