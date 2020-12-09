SWEP.Base = "wep_jack_gmod_gunbase"

SWEP.PrintName = "Multiple Grenade Launcher"

SWEP.Slot = 4

SWEP.ViewModel = "models/weapons/v_jmod_milkormgl.mdl"
SWEP.WorldModel = "models/weapons/w_jmod_milkormgl.mdl"
SWEP.ViewModelFOV = 75
SWEP.BodyHolsterSlot = "back"
SWEP.BodyHolsterAng = Angle(0,-105,0)
SWEP.BodyHolsterAngL = Angle(0,-75,160)
SWEP.BodyHolsterPos = Vector(1,-14,-11)
SWEP.BodyHolsterPosL = Vector(-2.5,-15,11)
SWEP.BodyHolsterScale = 1.1

JMod_ApplyAmmoSpecs(SWEP,"40mm Grenade",.9)
SWEP.DamageRand = .1
SWEP.ShootEntity = "ent_jack_gmod_ezprojectilenade"
SWEP.MuzzleVelocity = 3000

SWEP.Primary.ClipSize = 6 -- DefaultClip is automatically set.
SWEP.ChamberSize = 0 -- sigh

SWEP.Recoil = 2

SWEP.ShotgunReload = true

SWEP.Delay = 60 / 180 -- 60 / RPM.
SWEP.Firemodes = {
    {
        Mode = 1,
		PrintName = "DOUBLE-ACTION"
    },
    {
        Mode = 0
    }
}

SWEP.AccuracyMOA = 10 -- accuracy in Minutes of Angle. There are 60 MOA in a degree.

SWEP.Primary.Ammo = "40mm Grenade" -- what ammo type the gun uses

SWEP.FirstShootSound = "snds_jack_gmod/ez_weapons/40mm_grenade_auto.wav"
SWEP.ShootSound = "snds_jack_gmod/ez_weapons/40mm_grenade_auto.wav"
SWEP.DistantShootSound = "snds_jack_gmod/ez_weapons/rifle_far.wav"
SWEP.ShootSoundExtraMult=1

SWEP.MuzzleEffect = "muzzleflash_m79"
SWEP.ShellModel = "models/jhells/shell_9mm.mdl"
SWEP.ShellPitch = 60
SWEP.ShellScale = 7

SWEP.SpeedMult = .95
SWEP.SightedSpeedMult = .7
SWEP.SightTime = .7

SWEP.IronSightStruct = {
    Pos = Vector(-3.15, 0, 1.32),
    Ang = Angle(2.2, 0, -2),
    Magnification = 1.1,
    SwitchToSound = JMod_GunHandlingSounds.aim.inn,
    SwitchFromSound = JMod_GunHandlingSounds.aim.out
}

SWEP.ActivePos = Vector(1, 0, 0)
SWEP.ActiveAng = Angle(1.8, 1.5, -2.5)

SWEP.HolsterPos = Vector(6, 2, 0)
SWEP.HolsterAng = Angle(-20, 50, 0)

SWEP.BarrelLength = 30

SWEP.RevolverReload=true

SWEP.Attachments = {
    {
        PrintName = "Optic",
        DefaultAttName = "Iron Sights",
        Slot = {"ez_optic"},
        Bone = "tag_weapon",
        Offset = {
            vang = Angle(0, 0, 0),
			vpos = Vector(5.7, 0, 4.9),
            wpos = Vector(10, .5, -7),
            wang = Angle(-10.393, 0, 180)
        },
		-- remove Slide because it ruins my life
        Installed = "optic_jack_scope_acog"
    }
}

--[[
idle
draw
draw_first
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
    ["ready"] = {
        Source = "draw_first",
        Time = 2,
        SoundTable = {
			{s = JMod_GunHandlingSounds.draw.longgun, t = 0, v=60},
			{s = "snds_jack_gmod/ez_weapons/mgl/click.wav", t = 1, v=60},
			{s = "snds_jack_gmod/ez_weapons/mgl/close.wav", t = 1.2, v=60, p=120}
		},
		Mult=1,
        LHIK = true,
        LHIKIn = 0,
        LHIKOut = 0.25,
    },
    ["fire"] = {
        Source = "fire",
        Time = 0.4
    },
    ["sgreload_start"] = {
        Source = "reload_start",
        Time = 3.5,
        TPAnim = ACT_HL2MP_GESTURE_RELOAD_SHOTGUN,
        LHIK = true,
        LHIKIn = 0.5,
        LHIKOut = 0,
		ShellEjectAt = 1.5,
		ShellEjectDynamic=true,
		SoundTable = {
			{s = JMod_GunHandlingSounds.cloth.quiet, t = 0, v=65},
			{s = "snds_jack_gmod/ez_weapons/mgl/open.wav", t = .15, v=65},
			{s = JMod_GunHandlingSounds.cloth.move, t = .6, v=65},
			{s = "snds_jack_gmod/ez_weapons/gl/out.wav", t = .95, v=65},
			{s = "snds_jack_gmod/ez_weapons/mgl/out.wav", t = 1.2, v=60},
			{s = JMod_GunHandlingSounds.grab, t = 2.025, v=55},
			{s = "snds_jack_gmod/ez_weapons/mgl/click.wav", t = 2.425, v=55, p=100},
			{s = "snds_jack_gmod/ez_weapons/mgl/click.wav", t = 2.475, v=55, p=110},
			{s = "snds_jack_gmod/ez_weapons/mgl/click.wav", t = 2.525, v=55, p=120},
			{s = "snds_jack_gmod/ez_weapons/mgl/click.wav", t = 2.575, v=55, p=130}
		}
    },
    ["sgreload_start_empty"] = {
        Source = "reload_start",
        Time = 4,
        TPAnim = ACT_HL2MP_GESTURE_RELOAD_SHOTGUN,
        LHIK = true,
        LHIKIn = 3.5,
        LHIKOut = 0,
		ShellEjectAt = 1.5,
		ShellEjectCount=6,
		RestoreAmmo=0,
		SoundTable = {
			{s = JMod_GunHandlingSounds.cloth.quiet, t = 0, v=65},
			{s = "snds_jack_gmod/ez_weapons/mgl/open.wav", t = .2, v=65},
			{s = JMod_GunHandlingSounds.cloth.move, t = .8, v=65},
			{s = "snds_jack_gmod/ez_weapons/gl/out.wav", t = 1.05, v=65},
			{s = "snds_jack_gmod/ez_weapons/mgl/out.wav", t = 1.2, v=60},
			{s = JMod_GunHandlingSounds.grab, t = 2.3, v=55},
			{s = "snds_jack_gmod/ez_weapons/mgl/click.wav", t = 2.55, v=55, p=100},
			{s = "snds_jack_gmod/ez_weapons/mgl/click.wav", t = 2.6, v=55, p=110},
			{s = "snds_jack_gmod/ez_weapons/mgl/click.wav", t = 2.65, v=55, p=120},
			{s = "snds_jack_gmod/ez_weapons/mgl/click.wav", t = 2.7, v=55, p=130}
		}
    },
    ["sgreload_insert"] = {
        Source = "reload_loop",
        Time = 1,
        TPAnim = ACT_HL2MP_GESTURE_RELOAD_SHOTGUN,
        TPAnimStartTime = 0.3,
        LHIK = true,
        LHIKIn = 0,
        LHIKOut = 0,
		HardResetAnim = "reload_end",
		SoundTable = {
			{s = JMod_GunHandlingSounds.cloth.magpull, t = .01, v=65, p=120},
			{s = "snds_jack_gmod/ez_weapons/mgl/in.wav", t = .325, v=65}
		}
    },
    ["sgreload_finish"] = {
        Source = "reload_end",
        Time = 2,
        LHIK = true,
        LHIKIn = 0,
        LHIKOut = 0.4,
		SoundTable = {
			{s = JMod_GunHandlingSounds.cloth.quiet, t = 0, v=65},
			{s = JMod_GunHandlingSounds.grab, t = .1, v=60},
			{s = "snds_jack_gmod/ez_weapons/mgl/close.wav", t = .225, v=65}
		}
    }
}