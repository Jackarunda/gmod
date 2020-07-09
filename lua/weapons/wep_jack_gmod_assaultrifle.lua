SWEP.Base = "arccw_base"
SWEP.Spawnable = true -- this obviously has to be set to true
SWEP.Category = "ArcCW - Firearms" -- edit this if you like
SWEP.AdminOnly = false

SWEP.PrintName = "Assault Rifle"

SWEP.Slot = 2

if GetConVar("arccw_truenames"):GetBool() then SWEP.PrintName = SWEP.TrueName end

SWEP.UseHands = true

SWEP.ViewModel = "models/weapons/v_cod4_m16a4.mdl"
SWEP.WorldModel = "models/weapons/w_cod4_m16a4.mdl"
SWEP.ViewModelFOV = 65

SWEP.DefaultBodygroups = "000000"

SWEP.Damage = 48
SWEP.DamageMin = 5 -- damage done at maximum range
SWEP.DamageRand = .3
SWEP.Range = 200 -- in METERS
SWEP.Penetration = 55
SWEP.DamageType = DMG_BULLET
SWEP.ShootEntity = nil -- entity to fire, if any
SWEP.MuzzleVelocity = 900 -- projectile or phys bullet muzzle velocity
-- IN M/S

SWEP.TracerNum = 1 -- tracer every X
SWEP.TracerCol = Color(255, 25, 25)
SWEP.TracerWidth = 3

SWEP.ChamberSize = 1 -- how many rounds can be chambered.
SWEP.Primary.ClipSize = 30 -- DefaultClip is automatically set.

SWEP.Recoil = .5
SWEP.RecoilSide = 0.5
SWEP.RecoilRise = 0.6

SWEP.Delay = 60 / 750 -- 60 / RPM.
SWEP.Num = 1 -- number of shots per trigger pull.
SWEP.Firemodes = {
    {
        Mode = 2,
    },
    {
        Mode = 1,
    },
    {
        Mode = 0
    }
}

SWEP.NPCWeaponType = {"weapon_ar2", "weapon_smg1"}
SWEP.NPCWeight = 150

SWEP.AccuracyMOA = 4 -- accuracy in Minutes of Angle. There are 60 MOA in a degree.
SWEP.HipDispersion = 500 -- inaccuracy added by hip firing.
SWEP.MoveDispersion = 200

SWEP.Primary.Ammo = "Light Rifle Round" -- what ammo type the gun uses
SWEP.MagID = "stanag" -- the magazine pool this gun draws from

SWEP.ShootVol = 75 -- volume of shoot sound
SWEP.ShootPitch = 100 -- pitch of shoot sound

SWEP.FirstShootSound = "snds_jack_gmod/weapons/light_rifle.wav"
SWEP.ShootSound = "snds_jack_gmod/weapons/light_rifle.wav"
SWEP.DistantShootSound = "snds_jack_gmod/weapons/light_rifle_far.wav"
SWEP.ShootSoundExtraMult=1

SWEP.MuzzleEffect = "muzzleflash_4"
SWEP.ShellModel = "models/shells/shell_556.mdl"
SWEP.ShellPitch = 95
SWEP.ShellScale = 1.5

SWEP.MuzzleEffectAttachment = 1 -- which attachment to put the muzzle on
SWEP.CaseEffectAttachment = 2 -- which attachment to put the case effect on

SWEP.SpeedMult = 1
SWEP.SightedSpeedMult = .7
SWEP.SightTime = .5

SWEP.BulletBones = { -- the bone that represents bullets in gun/mag
    -- [0] = "bulletchamber",
    -- [1] = "bullet1"
}

SWEP.ProceduralRegularFire = false
SWEP.ProceduralIronFire = false

SWEP.CaseBones = {}

SWEP.IronSightStruct = {
    Pos = Vector(-3.035, -1, -.025),
    Ang = Angle(.75, 0, -5),
    Magnification = 1.1,
    SwitchToSound = "", -- sound that plays when switching to this sight
}

SWEP.HoldtypeHolstered = "passive"
SWEP.HoldtypeActive = "ar2"
SWEP.HoldtypeSights = "rpg"

SWEP.AnimShoot = ACT_HL2MP_GESTURE_RANGE_ATTACK_AR2

SWEP.ActivePos = Vector(.7, 0, .5)
SWEP.ActiveAng = Angle(1.8, 1.5, -2.5)

SWEP.HolsterPos = Vector(6, -4, 0)
SWEP.HolsterAng = Angle(-20, 50, 0)

SWEP.BarrelOffsetSighted = Vector(0, 0, -1)
SWEP.BarrelOffsetHip = Vector(2, 0, -2)

SWEP.MeleeAttackTime=.35

SWEP.BarrelLength = 40

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

SWEP.Animations = {
    ["idle"] = {
        Source = "idle",
        Time = 1
    },
    ["draw"] = {
        Source = "draw1",
        Time = 0.45,
        SoundTable = {{s = "snds_jack_gmod/weapons/assault_rifle/draw.wav", t = 0, v=60}},
        LHIK = true,
        LHIKIn = 0,
        LHIKOut = 0.35,
    },
    ["ready"] = {
        Source = "draw2",
        Time = 1,
        LHIK = true,
        LHIKIn = 0,
        LHIKOut = 0.25,
    },
    ["fire"] = {
        Source = "shoot1",
        Time = 0.4,
        ShellEjectAt = 0,
    },
    ["fire_iron"] = {
        Source = "shoot1",
        Time = 0.4,
        ShellEjectAt = 0,
    },
    ["reload"] = {
        Source = "reload_full",
        Time = 2.5,
        TPAnim = ACT_HL2MP_GESTURE_RELOAD_AR2,
        Checkpoints = {24, 42, 59, 71},
        FrameRate = 37,
		Mult=1.2,
        LHIK = true,
        LHIKIn = 0.5,
        LHIKOut = 0.5,
		SoundTable = {
			{s = "snds_jack_gmod/weapons/assault_rifle/mag_out.wav", t = .3, v=60},
			{s = "snds_jack_gmod/weapons/tap1.wav", t = 1.1, v=60},
			{s = "snds_jack_gmod/weapons/tap2.wav", t = 1.4, v=60},
			{s = "snds_jack_gmod/weapons/assault_rifle/mag_in.wav", t = 1.6, v=60}
		}
    },
    ["reload_empty"] = {
        Source = "reload_empty",
        Time = 3.1,
        TPAnim = ACT_HL2MP_GESTURE_RELOAD_AR2,
        Checkpoints = {24, 42, 59, 71, 89},
        FrameRate = 37,
		Mult=1.2,
        LHIK = true,
        LHIKIn = 0.5,
        LHIKOut = 0.5,
		SoundTable = {
			{s = "snds_jack_gmod/weapons/assault_rifle/mag_out.wav", t = .3, v=60},
			{s = "snds_jack_gmod/weapons/tap1.wav", t = 1.3, v=60},
			{s = "snds_jack_gmod/weapons/tap2.wav", t = 1.45, v=60},
			{s = "snds_jack_gmod/weapons/assault_rifle/mag_in.wav", t = 1.6, v=60},
			{s = "snds_jack_gmod/weapons/assault_rifle/bolt_release.wav", t = 2.1, v=60}
		}
    },
}