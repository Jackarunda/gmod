SWEP.Base = "wep_jack_gmod_gunbase"
SWEP.PrintName = "Pump-Action Shotgun"
JMod.SetWepSelectIcon(SWEP, "entities/ent_jack_gmod_ezweapon_pas", true)
SWEP.Slot = 3
SWEP.ViewModel = "models/weapons/v_cod4_w1200_c.mdl"
SWEP.WorldModel = "models/weapons/w_jmod_w1200.mdl"
SWEP.ViewModelFOV = 65
SWEP.BodyHolsterSlot = "back"
SWEP.BodyHolsterAng = Angle(40, -110, 50)
SWEP.BodyHolsterAngL = Angle(180, -100, -10)
SWEP.BodyHolsterPos = Vector(.5, -11, -9)
SWEP.BodyHolsterPosL = Vector(.5, -11, 10)
SWEP.BodyHolsterScale = .85
JMod.ApplyAmmoSpecs(SWEP, "Shotgun Round", 1.1)
SWEP.DoorBreachPower = 1
SWEP.Primary.ClipSize = 6 -- DefaultClip is automatically set.
SWEP.Recoil = 2
SWEP.VisualRecoilMult = 1.5
SWEP.ShotgunReload = true
SWEP.Delay = 60 / 70 -- 60/RPM.

SWEP.Firemodes = {
	{
		Mode = 1,
		PrintName = "PUMP-ACTION"
	},
	{
		Mode = 0
	}
}

SWEP.AccuracyMOA = 20 -- accuracy in Minutes of Angle. There are 60 MOA in a degree.
SWEP.FirstShootSound = "snds_jack_gmod/ez_weapons/shotgun.ogg"
SWEP.ShootSound = "snds_jack_gmod/ez_weapons/shotgun.ogg"
SWEP.DistantShootSound = "snds_jack_gmod/ez_weapons/shotgun_far.ogg"
SWEP.ShootSoundExtraMult = 1 -- fix calcview reload bob lol
SWEP.MuzzleEffect = "muzzleflash_m3"
SWEP.ShellModel = "models/jhells/shell_12gauge.mdl"
SWEP.ShellPitch = 90
SWEP.ShellSounds = JMod.ShellSounds.plastic
SWEP.ShellScale = 3
SWEP.SpeedMult = 1
SWEP.SightedSpeedMult = .7
SWEP.SightTime = .55

SWEP.IronSightStruct = {
	Pos = Vector(-3.375, 1.5, 1.45),
	Ang = Angle(.2, 0, -5),
	Magnification = 1.1,
	SwitchToSound = JMod.GunHandlingSounds.aim.inn,
	SwitchFromSound = JMod.GunHandlingSounds.aim.out
}

SWEP.ActivePos = Vector(1, 1, 0)
SWEP.ActiveAng = Angle(1.8, 1.5, -2.5)
SWEP.HolsterPos = Vector(6, -1, 0)
SWEP.HolsterAng = Angle(-20, 50, 0)
SWEP.BarrelLength = 38

--[[
idle
reload_start
reload
reload_end
draw
shoot1
--]]
SWEP.Animations = {
	["idle"] = {
		Source = "idle",
		Time = 1
	},
	["draw"] = {
		Source = "draw",
		Time = 1.5,
		SoundTable = {
			{
				s = JMod.GunHandlingSounds.draw.longgun,
				t = 0,
				v = 60
			}
		},
		Mult = 1,
		LHIK = true,
		LHIKIn = 0,
		LHIKOut = 0.35,
	},
	["fire"] = {
		Source = "shoot1",
		Time = 1,
		TPAnim = ACT_HL2MP_GESTURE_RANGE_ATTACK_SHOTGUN,
		SoundTable = {
			{
				s = "snds_jack_gmod/ez_weapons/pas/back.ogg",
				t = .35,
				v = 60
			},
			{
				s = "snds_jack_gmod/ez_weapons/pas/forward.ogg",
				t = .55,
				v = 60
			}
		},
		ShellEjectAt = .45,
	},
	["sgreload_start"] = {
		Source = "reload_start",
		Time = 0.7,
		TPAnim = ACT_HL2MP_GESTURE_RELOAD_SHOTGUN,
		LHIK = true,
		LHIKIn = 0.5,
		LHIKOut = 0,
		SoundTable = {
			{
				s = JMod.GunHandlingSounds.cloth.quiet,
				t = 0,
				v = 65
			}
		}
	},
	["sgreload_start_empty"] = {
		Source = "reload_start",
		Time = .7,
		TPAnim = ACT_HL2MP_GESTURE_RELOAD_SHOTGUN,
		LHIK = true,
		LHIKIn = 0.5,
		LHIKOut = 0,
		RestoreAmmo = 0,
		SoundTable = {
			{
				s = JMod.GunHandlingSounds.cloth.quiet,
				t = 0,
				v = 65
			}
		}
	},
	["sgreload_insert"] = {
		Source = "reload",
		Time = .9,
		TPAnim = ACT_HL2MP_GESTURE_RELOAD_SHOTGUN,
		TPAnimStartTime = 0.3,
		LHIK = true,
		LHIKIn = 0,
		LHIKOut = 0,
		HardResetAnim = "reload_end",
		SoundTable = {
			{
				s = JMod.GunHandlingSounds.shotshell,
				t = .15,
				v = 60
			},
			{
				s = JMod.GunHandlingSounds.cloth.magpull,
				t = .8,
				v = 65,
				p = 120
			}
		}
	},
	["sgreload_finish"] = {
		Source = "reload_end",
		Time = 1.2,
		LHIK = true,
		LHIKIn = 0,
		SoundTable = {
			{
				s = JMod.GunHandlingSounds.grab,
				t = 0.1,
				v = 65
			},
			{
				s = "snds_jack_gmod/ez_weapons/pas/back.ogg",
				t = .3,
				v = 60
			},
			{
				s = "snds_jack_gmod/ez_weapons/pas/forward.ogg",
				t = .5,
				v = 60
			}
		},
		LHIKOut = 0.4,
	}
}
