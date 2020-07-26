SWEP.Base = "wep_jack_gmod_gunbase"

SWEP.PrintName = "Bolt Action Rifle"

SWEP.Slot = 3

SWEP.ViewModel = "models/weapons/v_cod4_r700.mdl"
SWEP.WorldModel = "models/weapons/w_jmod_r700.mdl"
SWEP.ViewModelFOV = 70
SWEP.BodyHolsterSlot = "back"
SWEP.BodyHolsterAng = Angle(0,-105,0)
SWEP.BodyHolsterAngL = Angle(0,-75,190)
SWEP.BodyHolsterPos = Vector(2.5,-10,-9)
SWEP.BodyHolsterPosL = Vector(3.5,-10,9)
SWEP.BodyHolsterScale = .95

SWEP.Damage = 82
SWEP.DamageMin = 15 -- damage done at maximum range
SWEP.DamageRand = .35
SWEP.Range = 350 -- in METERS
SWEP.Penetration = 100

SWEP.Primary.ClipSize = 5 -- DefaultClip is automatically set.

SWEP.Recoil = 1.2
SWEP.RecoilSide = 0.5
SWEP.RecoilRise = 0.6

SWEP.ChamberSize = 0 -- this is so wrong, Arctic...

SWEP.Delay = 60 / 40 -- 60 / RPM.
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
SWEP.ShotgunReload = true

SWEP.AccuracyMOA = 1 -- real bolt guns are more accurate than this, but whatever... gmod
SWEP.HipDispersion = 500
SWEP.MoveDispersion = 200

SWEP.Primary.Ammo = "Medium Rifle Round" -- what ammo type the gun uses

SWEP.FirstShootSound = "snds_jack_gmod/ez_weapons/medium_rifle.wav"
SWEP.ShootSound = "snds_jack_gmod/ez_weapons/medium_rifle.wav"
SWEP.DistantShootSound = "snds_jack_gmod/ez_weapons/rifle_far.wav"
SWEP.ShootSoundExtraMult=1

SWEP.MuzzleEffect = "muzzleflash_g3"
SWEP.ShellModel = "models/jhells/shell_762nato.mdl"
SWEP.ShellPitch = 80
SWEP.ShellScale = 2

SWEP.SpeedMult = 1
SWEP.SightedSpeedMult = .65
SWEP.SightTime = .6

SWEP.IronSightStruct = {
    Pos = Vector(-3.75, 0, .5),
    Ang = Angle(-.1, 0, -5),
    Magnification = 1.1,
    SwitchToSound = "" -- sound that plays when switching to this sight
}

SWEP.ActivePos = Vector(0, 1, 1)
SWEP.ActiveAng = Angle(1.8, 1.5, -2.5)

SWEP.HolsterPos = Vector(6, -1, 0)
SWEP.HolsterAng = Angle(-20, 50, 0)

SWEP.MeleeAttackTime=.35

SWEP.BarrelLength = 48

SWEP.Attachments = {
    {
        PrintName = "Optic",
        DefaultAttName = "Iron Sights",
        Slot = {"optic_ez"},
        Bone = "tag_weapon",
        Offset = {
            vang = Angle(0, 0, 0),
			vpos = Vector(-3, 0, 2.6),
            wpos = Vector(10, .8, -6),
            wang = Angle(-10.393, 0, 180)
        },
		-- remove Slide because it ruins my life
        Installed = "optic_jack_scope_mediumlow"
    }
}

-- idle
-- reload_full
-- reload_start
-- reload_end
-- draw1
-- shoot1
SWEP.Animations = {
    ["idle"] = {
        Source = "idle",
        Time = 1
    },
    ["draw"] = {
        Source = "draw1",
        Time = 0.6,
        SoundTable = {{s = "snds_jack_gmod/ez_weapons/dmr/draw.wav", t = 0, v=60}},
		Mult=2.5,
        LHIK = true,
        LHIKIn = 0,
        LHIKOut = 0.35,
    },
    ["ready"] = {
        Source = "draw1",
        Time = 1,
        LHIK = true,
        LHIKIn = 0,
        LHIKOut = 0.25,
    },
    ["fire"] = {
        Source = "shoot1",
        Time = .9,
		Mult=1.5,
        ShellEjectAt = .4,
		SoundTable = {
			{s = "snds_jack_gmod/ez_weapons/bar/lift.wav", t = .2, v=60},
			{s = "snds_jack_gmod/ez_weapons/bar/pull.wav", t = .3, v=60},
			{s = "snds_jack_gmod/ez_weapons/bar/push.wav", t = .5, v=60},
			{s = "snds_jack_gmod/ez_weapons/bar/lock.wav", t = .6, v=60}
		}
    },
    ["fire_iron"] = {
        Source = "shoot1",
        Time = 1.2,
		Mult=1.5,
        ShellEjectAt = .5,
		SoundTable = {
			{s = "snds_jack_gmod/ez_weapons/bar/lift.wav", t = .25, v=60},
			{s = "snds_jack_gmod/ez_weapons/bar/pull.wav", t = .4, v=60},
			{s = "snds_jack_gmod/ez_weapons/bar/push.wav", t = .65, v=60},
			{s = "snds_jack_gmod/ez_weapons/bar/lock.wav", t = .75, v=60}
		}
    },
    ["sgreload_start"] = {
        Source = "reload_start",
        Time = 1.1,
        TPAnim = ACT_HL2MP_GESTURE_RELOAD_SHOTGUN,
        LHIK = true,
        LHIKIn = 0.5,
        LHIKOut = 0,
		SoundTable = {
			{s = "snds_jack_gmod/ez_weapons/bar/lift.wav", t = .2, v=60},
			{s = "snds_jack_gmod/ez_weapons/bar/pull.wav", t = .55, v=60}
		}
    },
    ["sgreload_insert"] = {
        Source = "reload_full",
        Time = .9,
        TPAnim = ACT_HL2MP_GESTURE_RELOAD_SHOTGUN,
        TPAnimStartTime = 0.3,
        LHIK = true,
        LHIKIn = 0,
        LHIKOut = 0,
		HardResetAnim = "reload_end",
		SoundTable = {
			{s = "snds_jack_gmod/ez_weapons/bar/insert.wav", t = .1, v=60}
		}
    },
    ["sgreload_finish"] = {
        Source = "reload_end",
        Time = 1.3,
        LHIK = true,
        LHIKIn = 0,
        LHIKOut = 0.4,
		SoundTable = {
			{s = "snds_jack_gmod/ez_weapons/bar/push.wav", t = .1, v=60},
			{s = "snds_jack_gmod/ez_weapons/bar/lock.wav", t = .35, v=60}
		}
    },
    ["sgreload_finish_empty"] = {
        Source = "reload_end",
        Time = 1.3,
        LHIK = true,
        LHIKIn = 0,
        LHIKOut = 1,
		SoundTable = {
			{s = "snds_jack_gmod/ez_weapons/bar/push.wav", t = .1, v=60},
			{s = "snds_jack_gmod/ez_weapons/bar/lock.wav", t = .35, v=60}
		}
    }
}