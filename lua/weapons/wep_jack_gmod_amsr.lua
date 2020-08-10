SWEP.Base = "wep_jack_gmod_gunbase"

SWEP.PrintName = "Anti-Materiel Sniper Rifle"

SWEP.Slot = 3

SWEP.ViewModel = "models/weapons/c_mw2_intervention.mdl"
SWEP.WorldModel = "models/weapons/w_jmod_intervention.mdl"
SWEP.ViewModelFOV = 75
SWEP.BodyHolsterSlot = "back"
SWEP.BodyHolsterAng = Angle(0,-105,0)
SWEP.BodyHolsterAngL = Angle(0,-75,190)
SWEP.BodyHolsterPos = Vector(2.5,-10,-9)
SWEP.BodyHolsterPosL = Vector(3.5,-10,9)
SWEP.BodyHolsterScale = 1

SWEP.DefaultBodygroups = "01000"

SWEP.Damage = 190
SWEP.DamageMin = 50 -- damage done at maximum range
SWEP.DamageRand = .35
SWEP.Range = 600 -- in METERS
SWEP.Penetration = 180

SWEP.Primary.ClipSize = 3 -- DefaultClip is automatically set.

SWEP.Recoil = 3
SWEP.RecoilSide = 0.5
SWEP.RecoilRise = 0.6

SWEP.ChamberSize = 0 -- this is so wrong, Arctic...

SWEP.Delay = 60 / 24 -- 60 / RPM.
SWEP.Num = 1 -- number of shots per trigger pull.
SWEP.Firemodes = {
    {
        PrintName = "BOLT",
        Mode = 1,
    },
    {
        Mode = 0
    }
}

SWEP.AccuracyMOA = 1 -- real bolt guns are more accurate than this, but whatever... gmod
SWEP.HipDispersion = 500
SWEP.MoveDispersion = 200

SWEP.Primary.Ammo = "Heavy Rifle Round" -- what ammo type the gun uses

SWEP.FirstShootSound = "snds_jack_gmod/ez_weapons/heavy_rifle.wav"
SWEP.ShootSound = "snds_jack_gmod/ez_weapons/heavy_rifle.wav"
SWEP.DistantShootSound = "snds_jack_gmod/ez_weapons/rifle_far.wav"
SWEP.ShootSoundExtraMult=2

SWEP.MuzzleEffect = "muzzle_center_M82"
SWEP.ShellModel = "models/jhells/shell_762nato.mdl"
SWEP.ShellPitch = 80
SWEP.ShellScale = 4

SWEP.SpeedMult = .9
SWEP.SightedSpeedMult = .5
SWEP.SightTime = .65

SWEP.IronSightStruct = {
    Pos = Vector(-3.75, 0, .5),
    Ang = Angle(-.1, 0, -5),
    Magnification = 1.1,
    SwitchToSound = "" -- sound that plays when switching to this sight
}

SWEP.ActivePos = Vector(.5, -.8, 2)
SWEP.ActiveAng = Angle(1.8, 1.5, -2.5)

SWEP.HolsterPos = Vector(6, -6, 0)
SWEP.HolsterAng = Angle(-20, 60, 0)

SWEP.MeleeAttackTime=.35

SWEP.BarrelLength = 65

SWEP.Attachments = {
    {
        PrintName = "Optic",
        DefaultAttName = "Iron Sights",
        Slot = {"optic_ez"},
        Bone = "tag_weapon",
        Offset = {
            vang = Angle(0, 0, 0),
			vpos = Vector(4.3, 0, 3.1),
            wpos = Vector(10, .5, -7),
            wang = Angle(-10.393, 0, 180)
        },
		-- remove Slide because it ruins my life
        Installed = "optic_jack_scope_medium"
    },
	{
        PrintName = "Underbarrel",
        Slot = {"ez_bipod"},
        Bone = "tag_weapon",
        Offset = {
			vpos = Vector(16, 0, -2),
            vang = Angle(0, 0, 0),
			wpos = Vector(31, .6, -7),
            wang = Angle(170, 0, 0)
        },
        -- remove Slide because it ruins my life
		Installed = "underbarrel_jack_bipod"
    }
}

--idle
--reload_empty
--reload_tac
--draw
--fire
--holster
--sprint
SWEP.Animations = {
    ["idle"] = {
        Source = "idle",
        Time = 1
    },
    ["draw"] = {
        Source = "draw",
        Time = 0.9,
        SoundTable = {{s = "snds_jack_gmod/ez_weapons/amsr/draw.wav", t = 0, v=60}},
		Mult=2.5,
        LHIK = true,
        LHIKIn = 0,
        LHIKOut = 0.35,
    },
    ["ready"] = {
        Source = "draw",
        Time = 0.9,
        SoundTable = {{s = "snds_jack_gmod/ez_weapons/amsr/draw.wav", t = 0, v=60}},
		Mult=2.5,
        LHIK = true,
        LHIKIn = 0,
        LHIKOut = 0.25,
    },
    ["fire"] = {
        Source = "fire",
        Time = 2.5,
		Mult = 1,
        ShellEjectAt = 1.1,
		SoundTable = {
			{s = "snds_jack_gmod/ez_weapons/amsr/up.wav", t = .5, v=60, p=90},
			{s = "snds_jack_gmod/ez_weapons/amsr/back.wav", t = .7, v=60, p=90},
			{s = "snds_jack_gmod/ez_weapons/amsr/forward.wav", t = 1.5, v=60, p=90},
			{s = "snds_jack_gmod/ez_weapons/amsr/down.wav", t = 1.6, v=60, p=90}
		}
    },
    ["fire_iron"] = {
        Source = "fire",
        Time = 2.5,
		Mult = 1,
        ShellEjectAt = 1.1,
		SoundTable = {
			{s = "snds_jack_gmod/ez_weapons/amsr/up.wav", t = .5, v=60},
			{s = "snds_jack_gmod/ez_weapons/amsr/back.wav", t = .7, v=60},
			{s = "snds_jack_gmod/ez_weapons/amsr/forward.wav", t = 1.5, v=60},
			{s = "snds_jack_gmod/ez_weapons/amsr/down.wav", t = 1.6, v=60}
		}
    },
	["reload"] = {
        Source = "reload_tac",
        Time = 3,
        TPAnim = ACT_HL2MP_GESTURE_RELOAD_AR2,
        Checkpoints = {24, 42, 59, 71},
        FrameRate = 37,
		Mult=1,
        LHIK = true,
        LHIKIn = 0.5,
        LHIKOut = 0.5,
		SoundTable = {
			{s = "snds_jack_gmod/ez_weapons/amsr/out.wav", t = .55, v=60},
			{s = "snds_jack_gmod/ez_weapons/amsr/in.wav", t = 1.6, v=60}
		}
    },
    ["reload_empty"] = {
        Source = "reload_empty",
        Time = 6,
        TPAnim = ACT_HL2MP_GESTURE_RELOAD_AR2,
        Checkpoints = {24, 42, 59, 71, 89},
        FrameRate = 37,
		Mult=1,
        LHIK = true,
        LHIKIn = 0.5,
        LHIKOut = 0.5,
		SoundTable = {
			{s = "snds_jack_gmod/ez_weapons/amsr/up.wav", t = .5, v=60},
			{s = "snds_jack_gmod/ez_weapons/amsr/back.wav", t = .65, v=60},
			{s = "snds_jack_gmod/ez_weapons/amsr/out.wav", t = 2.5, v=60},
			{s = "snds_jack_gmod/ez_weapons/amsr/in.wav", t = 3.9, v=60},
			{s = "snds_jack_gmod/ez_weapons/amsr/forward.wav", t = 4.8, v=60},
			{s = "snds_jack_gmod/ez_weapons/amsr/down.wav", t = 4.9, v=60}
		}
    }
}