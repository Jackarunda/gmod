SWEP.Base = "wep_jack_gmod_gunbase"
SWEP.PrintName = "Pistol"
JMod.SetWepSelectIcon(SWEP, "entities/ent_jack_gmod_ezweapon_pistol", true)
SWEP.Slot = 1
SWEP.ViewModel = "models/weapons/c_bo2_b23r_1.mdl"
SWEP.WorldModel = "models/weapons/w_jmod_b23r.mdl"
SWEP.ViewModelFOV = 80
SWEP.BodyHolsterSlot = "thighs"
SWEP.BodyHolsterAng = Angle(90, 90, -20)
SWEP.BodyHolsterAngL = Angle(90, 90, -20)
SWEP.BodyHolsterPos = Vector(-5, 17, -6)
SWEP.BodyHolsterPosL = Vector(-7, 17, 1.5)
SWEP.BodyHolsterScale = 1.1
SWEP.HoldtypeHolstered = "normal"
SWEP.HoldtypeActive = "pistol"
SWEP.HoldtypeSights = "revolver"
JMod.ApplyAmmoSpecs(SWEP, "Pistol Round")
SWEP.HipDispersion = 1100
SWEP.Primary.ClipSize = 15 -- DefaultClip is automatically set.
SWEP.Recoil = .5
SWEP.Delay = 60 / 400 -- 60/RPM.

SWEP.Firemodes = {
	{
		Mode = 1,
		PrintName = "SEMI-AUTO"
	},
	{
		Mode = 0
	}
}

SWEP.AccuracyMOA = 9 -- accuracy in Minutes of Angle. There are 60 MOA in a degree.
SWEP.FirstShootSound = "snds_jack_gmod/ez_weapons/pistol.ogg"
SWEP.ShootSound = "snds_jack_gmod/ez_weapons/pistol.ogg"
SWEP.DistantShootSound = "snds_jack_gmod/ez_weapons/pistol_far.ogg"
SWEP.ShootSoundExtraMult = 1
SWEP.MuzzleEffect = "muzzleflash_pistol"
SWEP.ShellModel = "models/jhells/shell_9mm.mdl"
SWEP.ShellPitch = 95
SWEP.ShellScale = 2
SWEP.ShellSounds = JMod.ShellSounds.metal
SWEP.SpeedMult = 1
SWEP.SightedSpeedMult = .9
SWEP.SightTime = .25

SWEP.IronSightStruct = {
	Pos = Vector(-2.4, 14, .5),
	Ang = Angle(-.1, 0, -2),
	Magnification = 1.1,
	SwitchToSound = JMod.GunHandlingSounds.aim.minor,
	SwitchFromSound = JMod.GunHandlingSounds.aim.minor
}

SWEP.ActivePos = Vector(1, 0, 0)
SWEP.ActiveAng = Angle(1.8, 1.5, -2.5)
SWEP.MeleePitch = 1.1
SWEP.MeleeDamage = 7
SWEP.MeleeTime = .4
SWEP.HolsterPos = Vector(0, 0, 0)
SWEP.HolsterAng = Angle(-45, 0, 0)
SWEP.BarrelLength = 20

--[[
idle
draw
draw_first
reload_empty
reload_tac
fire
holster
sprint
idle_empty
holster_empty
draw_empty
fire_last
reload_fm_empty
reload_fm_tac
--]]
SWEP.Animations = {
	["idle"] = {
		Source = "idle",
		Time = 1
	},
	["idle_empty"] = {
		Source = "idle_empty",
		Time = 1
	},
	["draw"] = {
		Source = "draw",
		Time = .4,
		SoundTable = {
			{
				s = JMod.GunHandlingSounds.draw.handgun,
				t = 0,
				v = 60,
				p = 120
			}
		},
		Mult = 1,
		LHIK = true,
		LHIKIn = 0,
		LHIKOut = 0.35,
	},
	["draw_empty"] = {
		Source = "draw_empty",
		Time = .4,
		SoundTable = {
			{
				s = JMod.GunHandlingSounds.draw.handgun,
				t = 0,
				v = 60,
				p = 120
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
				t = 0,
				v = 60,
				p = 120
			},
			{
				s = "snds_jack_gmod/ez_weapons/pistol/safety.ogg",
				t = .25,
				v = 60
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
		Time = 0.3,
		ShellEjectAt = 0,
		TPAnim = ACT_HL2MP_GESTURE_RANGE_ATTACK_PISTOL
	},
	["fire_empty"] = {
		Source = "fire_last",
		Time = 0.3,
		ShellEjectAt = 0,
		TPAnim = ACT_HL2MP_GESTURE_RANGE_ATTACK_PISTOL
	},
	["reload"] = {
		Source = "reload_tac",
		Time = 2,
		TPAnim = ACT_HL2MP_GESTURE_RELOAD_AR2,
		Checkpoints = {24, 42, 59, 71},
		FrameRate = 37,
		LHIK = true,
		LHIKIn = 0.5,
		LHIKOut = 0.5,
		SoundTable = {
			{
				s = "snds_jack_gmod/ez_weapons/pistol/out.ogg",
				t = 0,
				v = 60
			},
			{
				s = JMod.GunHandlingSounds.cloth.magpull,
				t = .2,
				v = 60,
				p = 110
			},
			{
				s = "snds_jack_gmod/ez_weapons/pistol/tap.ogg",
				t = .7,
				v = 60
			},
			{
				s = "snds_jack_gmod/ez_weapons/pistol/in.ogg",
				t = .65,
				v = 60
			}
		}
	},
	["reload_empty"] = {
		Source = "reload_empty",
		Time = 2.5,
		TPAnim = ACT_HL2MP_GESTURE_RELOAD_AR2,
		Checkpoints = {24, 42, 59, 71, 89},
		FrameRate = 37,
		LHIK = true,
		LHIKIn = 0.5,
		LHIKOut = 0.5,
		SoundTable = {
			{
				s = "snds_jack_gmod/ez_weapons/pistol/out.ogg",
				t = 0,
				v = 60
			},
			{
				s = JMod.GunHandlingSounds.cloth.magpull,
				t = .2,
				v = 60,
				p = 110
			},
			{
				s = "snds_jack_gmod/ez_weapons/pistol/tap.ogg",
				t = .7,
				v = 60
			},
			{
				s = "snds_jack_gmod/ez_weapons/pistol/in.ogg",
				t = .75,
				v = 60
			},
			{
				s = "snds_jack_gmod/ez_weapons/pistol/release.ogg",
				t = 1.575,
				v = 60,
				p = 90
			}
		}
	}
}
