SWEP.Base = "wep_jack_gmod_gunbase"
SWEP.PrintName = "Shot Revolver"
JMod.SetWepSelectIcon(SWEP, "entities/ent_jack_gmod_ezweapon_shotrevolver", true)
SWEP.Slot = 1
SWEP.ViewModel = "models/weapons/c_bo2_executioner1.mdl"
SWEP.WorldModel = "models/weapons/w_jmod_shotrevolver.mdl"
SWEP.ViewModelFOV = 80
SWEP.BodyHolsterSlot = "thighs"
SWEP.BodyHolsterAng = Angle(90, 90, -20)
SWEP.BodyHolsterAngL = Angle(90, 90, -20)
SWEP.BodyHolsterPos = Vector(-5, 17, -6.5)
SWEP.BodyHolsterPosL = Vector(-7, 17, 1.5)
SWEP.BodyHolsterScale = 1
SWEP.HoldtypeHolstered = "normal"
SWEP.HoldtypeActive = "pistol"
SWEP.HoldtypeSights = "revolver"
JMod.ApplyAmmoSpecs(SWEP, "Small Shotgun Round")
SWEP.HipDispersion = 1100
SWEP.Primary.ClipSize = 5 -- DefaultClip is automatically set.
SWEP.ChamberSize = 0 -- revolver lol
SWEP.Recoil = 2
SWEP.VisualRecoilMult = 2
SWEP.ShotgunReload = true
SWEP.Delay = 60 / 180 -- 60/RPM.

SWEP.Firemodes = {
	{
		Mode = 1,
		PrintName = "DOUBLE-ACTION"
	},
	{
		Mode = 0
	}
}

SWEP.AccuracyMOA = 50 -- accuracy in Minutes of Angle. There are 60 MOA in a degree.
SWEP.FirstShootSound = "snds_jack_gmod/ez_weapons/small_shotgun.ogg"
SWEP.ShootSound = "snds_jack_gmod/ez_weapons/small_shotgun.ogg"
SWEP.DistantShootSound = "snds_jack_gmod/ez_weapons/pistol_far.ogg"
SWEP.ShootSoundExtraMult = 1
SWEP.MuzzleEffect = "muzzleflash_pistol_rbull"
SWEP.ShellModel = "models/jhells/shell_12gauge.mdl"
SWEP.ShellSounds = JMod.ShellSounds.plastic
SWEP.ShellPitch = 130
SWEP.ShellScale = 1.5
SWEP.SpeedMult = 1
SWEP.SightedSpeedMult = .9
SWEP.SightTime = .35

SWEP.IronSightStruct = {
	Pos = Vector(-2.23, 14, .1),
	Ang = Angle(-.7, -.15, -2),
	Magnification = 1.1,
	SwitchToSound = JMod.GunHandlingSounds.aim.minor,
	SwitchFromSound = JMod.GunHandlingSounds.aim.minor
}

SWEP.ActivePos = Vector(0, 1, -1)
SWEP.ActiveAng = Angle(1.8, 1.5, -2.5)
SWEP.MeleePitch = 1.1
SWEP.MeleeDamage = 7
SWEP.MeleeTime = .4
SWEP.HolsterPos = Vector(0, 0, 0)
SWEP.HolsterAng = Angle(-45, 0, 0)
SWEP.RevolverReload = true
SWEP.BarrelLength = 20

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
		Time = 0.5,
		SoundTable = {
			{
				s = JMod.GunHandlingSounds.draw.handgun,
				t = 0,
				v = 60,
				p = 110
			}
		},
		Mult = 1,
		LHIK = true,
		LHIKIn = 0,
		LHIKOut = 0.35,
	},
	["ready"] = {
		Source = "draw_first",
		SoundTable = {
			{
				s = JMod.GunHandlingSounds.draw.handgun,
				t = .3,
				v = 60,
				p = 110
			}
		},
		Time = 1.5,
		Mult = 1,
		LHIK = true,
		LHIKIn = 0,
		LHIKOut = 0.25,
	},
	["fire"] = {
		Source = "fire",
		Time = 0.4,
		TPAnim = ACT_HL2MP_GESTURE_RANGE_ATTACK_PISTOL
	},
	["sgreload_start"] = {
		Source = "reload_start",
		Time = 2.5,
		TPAnim = ACT_HL2MP_GESTURE_RELOAD_SHOTGUN,
		LHIK = true,
		LHIKIn = 0.5,
		LHIKOut = 0,
		ShellEjectAt = 1.2,
		ShellEjectDynamic = true,
		RestoreAmmo = 1,
		SoundTable = {
			{
				s = JMod.GunHandlingSounds.cloth.move,
				t = 0,
				v = 65
			},
			{
				s = "snds_jack_gmod/ez_weapons/shotrevolver/open.ogg",
				t = .5,
				v = 60
			},
			{
				s = "snds_jack_gmod/ez_weapons/shotrevolver/eject.ogg",
				t = 1.1,
				v = 60
			},
			{
				s = "snds_jack_gmod/ez_weapons/shotrevolver/out.ogg",
				t = 1.4,
				v = 60
			},
			{
				s = JMod.GunHandlingSounds.cloth.magpull,
				t = 1.9,
				v = 65,
				p = 120
			},
			{
				s = "snds_jack_gmod/ez_weapons/shotrevolver/in.ogg",
				t = 2.3,
				v = 60
			}
		}
	},
	["sgreload_start_empty"] = {
		Source = "reload_start",
		Time = 2.5,
		TPAnim = ACT_HL2MP_GESTURE_RELOAD_SHOTGUN,
		LHIK = true,
		LHIKIn = 0.5,
		LHIKOut = 0,
		ShellEjectAt = 1.2,
		ShellEjectCount = 5,
		SoundTable = {
			{
				s = JMod.GunHandlingSounds.cloth.move,
				t = 0,
				v = 65
			},
			{
				s = "snds_jack_gmod/ez_weapons/shotrevolver/open.ogg",
				t = .5,
				v = 60
			},
			{
				s = "snds_jack_gmod/ez_weapons/shotrevolver/eject.ogg",
				t = 1.1,
				v = 60
			},
			{
				s = "snds_jack_gmod/ez_weapons/shotrevolver/out.ogg",
				t = 1.4,
				v = 60
			},
			{
				s = JMod.GunHandlingSounds.cloth.magpull,
				t = 1.9,
				v = 65,
				p = 120
			},
			{
				s = "snds_jack_gmod/ez_weapons/shotrevolver/in.ogg",
				t = 2.3,
				v = 60
			}
		}
	},
	["sgreload_insert"] = {
		Source = "reload_loop",
		Time = 1.1,
		TPAnim = ACT_HL2MP_GESTURE_RELOAD_SHOTGUN,
		TPAnimStartTime = 0.3,
		LHIK = true,
		LHIKIn = 0,
		LHIKOut = 0,
		HardResetAnim = "reload_end",
		SoundTable = {
			{
				s = JMod.GunHandlingSounds.cloth.magpull,
				t = .3,
				v = 65,
				p = 120
			},
			{
				s = "snds_jack_gmod/ez_weapons/shotrevolver/in.ogg",
				t = .8,
				v = 60
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
				s = "snds_jack_gmod/ez_weapons/shotrevolver/close.ogg",
				t = .4,
				v = 60
			},
			{
				s = JMod.GunHandlingSounds.grab,
				t = 1,
				v = 55
			}
		},
		LHIKOut = 0.4,
	}
}
