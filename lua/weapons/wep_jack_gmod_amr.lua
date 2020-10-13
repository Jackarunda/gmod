SWEP.Base = "wep_jack_gmod_gunbase"

SWEP.PrintName = "Anti-Materiel Rifle"

SWEP.Slot = 3

SWEP.ViewModel = "models/weapons/c_mw2_barrett50cal.mdl"
SWEP.WorldModel = "models/weapons/w_jmod_m107.mdl"
SWEP.ViewModelFOV = 65
SWEP.BodyHolsterSlot = "back"
SWEP.BodyHolsterAng = Angle(0,-105,0)
SWEP.BodyHolsterAngL = Angle(15,-77,180)
SWEP.BodyHolsterPos = Vector(2,-12,-10)
SWEP.BodyHolsterPosL = Vector(0,-10,11)
SWEP.BodyHolsterScale = .9

SWEP.DefaultBodygroups = "01000"

SWEP.Damage = 170
SWEP.DamageMin = 50 -- damage done at maximum range
SWEP.DamageRand = .35
SWEP.Range = 600 -- in METERS
SWEP.Penetration = 165

SWEP.Primary.ClipSize = 5 -- DefaultClip is automatically set.

SWEP.Recoil = 2.7
SWEP.RecoilSide = 0.5
SWEP.RecoilRise = 0.6

SWEP.Delay = 60 / 200 -- 60 / RPM.
SWEP.Num = 1 -- number of shots per trigger pull.
SWEP.Firemodes = {
    {
        Mode = 1,
    },
    {
        Mode = 0
    }
}

SWEP.AccuracyMOA = 4 -- accuracy in Minutes of Angle. There are 60 MOA in a degree.
SWEP.HipDispersion = 600 -- inaccuracy added by hip firing.
SWEP.MoveDispersion = 200

SWEP.Primary.Ammo = "Heavy Rifle Round" -- what ammo type the gun uses

SWEP.FirstShootSound = "snds_jack_gmod/ez_weapons/heavy_autoloader.wav"
SWEP.ShootSound = "snds_jack_gmod/ez_weapons/heavy_autoloader.wav"
SWEP.DistantShootSound = "snds_jack_gmod/ez_weapons/rifle_far.wav"
SWEP.ShootSoundExtraMult=1

SWEP.MuzzleEffect = "muzzle_center_M82"
SWEP.ShellModel = "models/jhells/shell_762nato.mdl"
SWEP.ShellPitch = 70
SWEP.ShellScale = 4

SWEP.SpeedMult = .8
SWEP.SightedSpeedMult = .4
SWEP.SightTime = 1

SWEP.IronSightStruct = {
    Pos = Vector(-2.57, -1, 1),
    Ang = Angle(-.1, 0, -5),
    Magnification = 1.1,
    SwitchToSound = JMod_GunHandlingSounds.aim.inn,
    SwitchFromSound = JMod_GunHandlingSounds.aim.out
}

SWEP.Attachments = {
    {
        PrintName = "Optic",
        DefaultAttName = "Iron Sights",
        Slot = {"ez_optic"},
        Bone = "tag_weapon",
        Offset = {
            vang = Angle(0, 0, 0),
			vpos = Vector(3.6, 0, 4.5),
            wpos = Vector(8, .8, -7.5),
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
			vpos = Vector(16, 0, 1.3),
            vang = Angle(0, 0, 0),
			wpos = Vector(31, .6, -8.5),
            wang = Angle(170, 0, 0)
        },
        -- remove Slide because it ruins my life
		Installed = "underbarrel_jack_bipod"
    }
}

SWEP.ActivePos = Vector(1, 0, -.5)
SWEP.ActiveAng = Angle(1.8, 1.5, -2.5)

SWEP.HolsterPos = Vector(6, -1, 0)
SWEP.HolsterAng = Angle(-20, 50, 0)

SWEP.BarrelLength = 50

--[[
idle
reload_empty
reload_tac
draw
fire
holster
sprint
--]]
SWEP.Animations = {
    ["idle"] = {
        Source = "idle",
        Time = 1
    },
    ["draw"] = {
        Source = "draw",
        Time = 1,
        SoundTable = {
			{s = JMod_GunHandlingSounds.draw.longgun, t = 0, v=60, p=90},
			{s = "snds_jack_gmod/ez_weapons/amr/bigmove.wav", t = 0, v=60}
		},
		Mult=2.5,
        LHIK = true,
        LHIKIn = 0,
        LHIKOut = 0.35,
    },
    ["ready"] = {
        Source = "draw",
        Time = 1,
        SoundTable = {
			{s = JMod_GunHandlingSounds.draw.longgun, t = 0, v=60, p=90},
			{s = "snds_jack_gmod/ez_weapons/amr/bigmove.wav", t = 0, v=60}
		},
		Mult=2.5,
        LHIK = true,
        LHIKIn = 0,
        LHIKOut = 0.25,
    },
    ["fire"] = {
        Source = "fire",
        Time = 0.6,
        ShellEjectAt = .05,
    },
    ["fire_iron"] = {
        Source = "fire",
        Time = 0.6,
        ShellEjectAt = .05,
    },
    ["reload"] = {
        Source = "reload_tac",
        Time = 5,
        TPAnim = ACT_HL2MP_GESTURE_RELOAD_AR2,
        Checkpoints = {24, 42, 59, 71},
        FrameRate = 37,
		Mult=1.2,
        LHIK = true,
        LHIKIn = 0.5,
        LHIKOut = 0.5,
		SoundTable = {
			{s = JMod_GunHandlingSounds.cloth.loud, t = 0, v=60},
			{s = "snds_jack_gmod/ez_weapons/amr/move.wav", t = .2, v=60},
			{s = "snds_jack_gmod/ez_weapons/amr/magrelease.wav", t = 1.15, v=65},
			{s = "snds_jack_gmod/ez_weapons/amr/magtoss.wav", t = 1, v=65},
			{s = JMod_GunHandlingSounds.cloth.magpull, t = 2, v=65},
			{s = "snds_jack_gmod/ez_weapons/amr/magmove.wav", t = 2, v=65},
			{s = JMod_GunHandlingSounds.tap.magwell, t = 2.65, v=65, p=80},
			{s = "snds_jack_gmod/ez_weapons/amr/in.wav", t = 3.15, v=65},
			{s = JMod_GunHandlingSounds.cloth.quiet, t = 3.8, v=60},
			{s = JMod_GunHandlingSounds.grab, t = 3.75, v=60}
		}
    },
    ["reload_empty"] = {
        Source = "reload_empty",
        Time = 6,
        TPAnim = ACT_HL2MP_GESTURE_RELOAD_AR2,
        Checkpoints = {24, 42, 59, 71, 89},
        FrameRate = 37,
		Mult=1.2,
        LHIK = true,
        LHIKIn = 0.5,
        LHIKOut = 0.5,
		SoundTable = {
			{s = JMod_GunHandlingSounds.cloth.loud, t = 0, v=60},
			{s = "snds_jack_gmod/ez_weapons/amr/move.wav", t = .2, v=60},
			{s = "snds_jack_gmod/ez_weapons/amr/magrelease.wav", t = 1.3, v=65},
			{s = "snds_jack_gmod/ez_weapons/amr/magtoss.wav", t = 1.4, v=65},
			{s = JMod_GunHandlingSounds.cloth.magpull, t = 2.3, v=65},
			{s = "snds_jack_gmod/ez_weapons/amr/magmove.wav", t = 2.3, v=65},
			{s = JMod_GunHandlingSounds.tap.magwell, t = 3, v=65, p=80},
			{s = "snds_jack_gmod/ez_weapons/amr/in.wav", t = 3.65, v=65},
			{s = JMod_GunHandlingSounds.cloth.quiet, t = 4, v=60},
			{s = JMod_GunHandlingSounds.grab, t = 4.35, v=60},
			{s = "snds_jack_gmod/ez_weapons/amr/pull.wav", t = 5.05, v=65},
			{s = "snds_jack_gmod/ez_weapons/amr/release.wav", t = 5.3, v=65},
			{s = JMod_GunHandlingSounds.grab, t = 5.8, v=60}
		}
    },
}