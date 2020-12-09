SWEP.Base = "wep_jack_gmod_gunbase"

SWEP.PrintName = "Semi-Automatic Shotgun"

SWEP.Slot = 3

SWEP.ViewModel = "models/weapons/c_mw2_m1014.mdl"
SWEP.WorldModel = "models/weapons/w_jmod_m1014.mdl"
SWEP.ViewModelFOV = 70
SWEP.BodyHolsterSlot = "back"
SWEP.BodyHolsterAng = Angle(40,-110,50)
SWEP.BodyHolsterAngL = Angle(180,-100,-10)
SWEP.BodyHolsterPos = Vector(.5,-11,-9)
SWEP.BodyHolsterPosL = Vector(.5,-11,10)
SWEP.BodyHolsterScale = .85

JMod_ApplyAmmoSpecs(SWEP,"Shotgun Round",.9)
SWEP.DoorBreachPower = .2

SWEP.Primary.ClipSize = 7 -- DefaultClip is automatically set.

SWEP.Recoil = 3
SWEP.VisualRecoilMult = 1.5

SWEP.ShotgunReload = true

SWEP.Delay = 60 / 250 -- 60 / RPM.
SWEP.Firemodes = {
    {
        Mode = 1,
		PrintName = "SEMI-AUTO"
    },
    {
        Mode = 0
    }
}

SWEP.AccuracyMOA = 20 -- accuracy in Minutes of Angle. There are 60 MOA in a degree.

SWEP.Primary.Ammo = "Shotgun Round" -- what ammo type the gun uses

SWEP.FirstShootSound = "snds_jack_gmod/ez_weapons/auto_shotgun.wav"
SWEP.ShootSound = "snds_jack_gmod/ez_weapons/auto_shotgun.wav"
SWEP.DistantShootSound = "snds_jack_gmod/ez_weapons/shotgun_far.wav"
SWEP.ShootSoundExtraMult=1

SWEP.MuzzleEffect = "muzzleflash_m3"
SWEP.ShellModel = "models/jhells/shell_12gauge.mdl"
SWEP.ShellPitch = 90
if(ArcCW)then SWEP.ShellSounds = ArcCW.ShotgunShellSoundsTable end
SWEP.ShellScale = 3

SWEP.SpeedMult = 1
SWEP.SightedSpeedMult = .7
SWEP.SightTime = .55

SWEP.IronSightStruct = {
    Pos = Vector(-3.1, 1.5, 1.45),
    Ang = Angle(.2, 0, -5),
    Magnification = 1.1,
    SwitchToSound = JMod_GunHandlingSounds.aim.inn,
    SwitchFromSound = JMod_GunHandlingSounds.aim.out
}

SWEP.ActivePos = Vector(1, 1, 1)
SWEP.ActiveAng = Angle(1.8, 1.5, -2.5)

SWEP.HolsterPos = Vector(6, -1, 0)
SWEP.HolsterAng = Angle(-20, 50, 0)

SWEP.BarrelLength = 38

--[[
idle
draw
fire
holster
sprint
reload_start
reload_loop
reload_end
--]]
SWEP.Animations = {
    ["idle"] = {
        Source = "idle",
        Time = 1
    },
    ["draw"] = {
        Source = "draw",
        Time = 2,
       SoundTable = {{s = JMod_GunHandlingSounds.draw.longgun, t = 0, v=60}},
		Mult=1,
        LHIK = true,
        LHIKIn = 0,
        LHIKOut = 0.35,
    },
    ["fire"] = {
        Source = "fire",
        Time = 0.3,
        ShellEjectAt = .05,
    },
    ["sgreload_start"] = {
        Source = "reload_start",
        Time = 0.7,
        TPAnim = ACT_HL2MP_GESTURE_RELOAD_SHOTGUN,
        LHIK = true,
        LHIKIn = 0.5,
        LHIKOut = 0,
		SoundTable = {
			{s = JMod_GunHandlingSounds.cloth.quiet, t = 0, v=65}
		}
    },
    ["sgreload_insert"] = {
        Source = "reload_loop",
        Time = .9,
        TPAnim = ACT_HL2MP_GESTURE_RELOAD_SHOTGUN,
        TPAnimStartTime = 0.3,
        LHIK = true,
        LHIKIn = 0,
        LHIKOut = 0,
		HardResetAnim = "reload_end",
		SoundTable = {
			{s = JMod_GunHandlingSounds.shotshell, t = .175, v=60},
			{s = JMod_GunHandlingSounds.cloth.magpull, t = .8, v=65, p=120}
		}
    },
    ["sgreload_finish"] = {
        Source = "reload_end",
        Time = 1,
        LHIK = true,
        LHIKIn = 0,
        LHIKOut = 0.4,
		SoundTable = {
			{s = JMod_GunHandlingSounds.grab, t = 0.5, v=60}
		}
    }
}