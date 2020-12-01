SWEP.Base = "wep_jack_gmod_gunbase"

SWEP.PrintName = "Crossbow"

SWEP.Slot = 3

SWEP.ViewModel = "models/weapons/c_jmod_crossbow.mdl"
SWEP.WorldModel = "models/weapons/w_jmod_crossbow.mdl"
SWEP.ViewModelFOV = 70
SWEP.BodyHolsterSlot = "back"
SWEP.BodyHolsterAng = Angle(90,-103,10)
SWEP.BodyHolsterAngL = Angle(90,-103,-10)
SWEP.BodyHolsterPos = Vector(11.5,-10,-6)
SWEP.BodyHolsterPosL = Vector(10.5,-11,6)
SWEP.BodyHolsterScale = .9

--[[
3:
	id	=	2
	name	=	exptip
	num	=	2
	submodels:
			0	=	
			1	=	c_bo1_crossbow_exptip_bg.smd
--]]

SWEP.Damage = 40
SWEP.DamageRand = .4
SWEP.ShootEntity = "ent_jack_gmod_ezarrow"
SWEP.MuzzleVelocity = 7000
SWEP.ShootEntityOffset = Vector(-1,0,-2)
SWEP.ShootEntityAngle = Angle(0,0,0)
SWEP.ShootEntityAngleCorrection = Angle(0,0,0)

SWEP.MuzzleEffect=nil
SWEP.NoFlash=true

SWEP.Primary.ClipSize = 1 -- DefaultClip is automatically set.
SWEP.ChamberSize = 0

SWEP.Recoil = .8

SWEP.Delay = 60 / 100 -- 60 / RPM.
SWEP.Num = 1 -- number of shots per trigger pull.
SWEP.Firemodes = {
    {
        Mode = 1,
		PrintName = "SINGLE"
    },
    {
        Mode = 0
    }
}

SWEP.AccuracyMOA = 9 -- accuracy in Minutes of Angle. There are 60 MOA in a degree. No shit, sherlock
SWEP.HipDispersion = 600 -- inaccuracy added by hip firing.
SWEP.MoveDispersion = 200

SWEP.Primary.Ammo = "Arrow" -- become an penis

SWEP.FirstShootSound = {"snds_jack_gmod/ez_weapons/crossbow/fire1.wav","snds_jack_gmod/ez_weapons/crossbow/fire2.wav","snds_jack_gmod/ez_weapons/crossbow/fire3.wav"}
SWEP.ShootSound = {"snds_jack_gmod/ez_weapons/crossbow/fire1.wav","snds_jack_gmod/ez_weapons/crossbow/fire2.wav","snds_jack_gmod/ez_weapons/crossbow/fire3.wav"}
SWEP.DistantShootSound = ""
SWEP.ShootSoundExtraMult = 0
SWEP.ShootVol = 55

--[[
SWEP.MuzzleEffect = "muzzleflash_m14"
SWEP.ShellModel = "models/jhells/shell_762nato.mdl"
SWEP.ShellPitch = 80
SWEP.ShellScale = 2
--]]

SWEP.SpeedMult = 1
SWEP.SightedSpeedMult = .7
SWEP.SightTime = .5

SWEP.BulletBones = { -- arctic, don't ever write descriptions again
    [1] = "tag_clip"
}

SWEP.IronSightStruct = {
    Pos = Vector(-2.22, 4, .6),
    Ang = Angle(-.15, 0, -2),
    Magnification = 1.2,
    SwitchToSound = JMod_GunHandlingSounds.aim.inn,
    SwitchFromSound = JMod_GunHandlingSounds.aim.out
}

SWEP.ActivePos = Vector(0, 0, 0)
SWEP.ActiveAng = Angle(0, 0, 0)

SWEP.HolsterPos = Vector(8, 3, -4)
SWEP.HolsterAng = Angle(-10, 50, 0)

SWEP.BarrelLength = 30

--[[
idle
idle_empty
draw
shoot
reload
holster
sprint
--]]
SWEP.Animations = {
    ["idle"] = {
        Source = "idle",
        Time = 1
    },
    ["idle_empty"] = {
        Source = "idle_empty",
        Time = 10
    },
    ["draw"] = {
        Source = "draw",
        Time = 1,
        SoundTable = {{s = JMod_GunHandlingSounds.draw.longgun, t = 0, v=50}},
		Mult=1,
        LHIK = true,
        LHIKIn = 0,
        LHIKOut = 0.35,
    },
    ["fire"] = {
        Source = "shoot",
        Time = .5
    },
    ["reload_empty"] = {
        Source = "reload",
        Time = 4,
        TPAnim = ACT_HL2MP_GESTURE_RELOAD_AR2,
        Checkpoints = {24, 42, 59, 71, 89},
        FrameRate = 37,
		Mult=1,
        LHIK = true,
        LHIKIn = 0.5,
        LHIKOut = 0.5,
		SoundTable = {
			{s = JMod_GunHandlingSounds.cloth.loud, t = 0, v=60},
			{s = JMod_GunHandlingSounds.cloth.quiet, t = .5, v=60},
			{s = "snds_jack_gmod/ez_weapons/crossbow/pull.wav", t = .7, v=55},
			{s = JMod_GunHandlingSounds.cloth.magpull, t = 1.4, v=60, p=110},
			{s = "snds_jack_gmod/ez_weapons/crossbow/in.wav", t = 2.2, v=55, p=120},
			{s = "snds_jack_gmod/ez_weapons/crossbow/clack.wav", t = 3, v=55},
			{s = JMod_GunHandlingSounds.grab, t = 3.7, v=55}
		}
    },
}