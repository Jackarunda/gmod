SWEP.Base = "wep_jack_gmod_gunbase"
SWEP.PrintName = "Magnum Pistol"
JMod.SetWepSelectIcon(SWEP, "entities/ent_jack_gmod_ezweapon_magpistol", true)
SWEP.Slot = 1
SWEP.ViewModel = "models/weapons/c_mw2_deagle.mdl"
SWEP.WorldModel = "models/weapons/w_jmod_deagle.mdl"
SWEP.ViewModelFOV = 75
SWEP.BodyHolsterSlot = "thighs"
SWEP.BodyHolsterAng = Angle(90, 90, -20)
SWEP.BodyHolsterAngL = Angle(90, 90, -20)
SWEP.BodyHolsterPos = Vector(-5, 17, -6)
SWEP.BodyHolsterPosL = Vector(-7, 17, 2.25)
SWEP.BodyHolsterScale = 1.2
SWEP.HoldtypeHolstered = "normal"
SWEP.HoldtypeActive = "pistol"
SWEP.HoldtypeSights = "revolver"
JMod.ApplyAmmoSpecs(SWEP, "Magnum Pistol Round", 1.15)
SWEP.HipDispersion = 1100
SWEP.Primary.ClipSize = 9 -- DefaultClip is automatically set.
SWEP.Recoil = 2
SWEP.VisualRecoilMult = 2
SWEP.Delay = 60 / 200 -- 60/RPM.

SWEP.Firemodes = {
	{
		Mode = 1,
		PrintName = "SEMI-AUTO"
	},
	{
		Mode = 0
	}
}

SWEP.AccuracyMOA = 7 -- accuracy in Minutes of Angle. There are 60 MOA in a degree.
SWEP.FirstShootSound = "snds_jack_gmod/ez_weapons/magnum_pistol.ogg"
SWEP.ShootSound = "snds_jack_gmod/ez_weapons/magnum_pistol.ogg"
SWEP.DistantShootSound = "snds_jack_gmod/ez_weapons/pistol_far.ogg"
SWEP.ShootSoundExtraMult = 1
SWEP.MuzzleEffect = "muzzleflash_pistol_deagle"
SWEP.ShellModel = "models/jhells/shell_9mm.mdl"
SWEP.ShellPitch = 80
SWEP.ShellScale = 3.5
SWEP.ShellSounds = JMod.ShellSounds.metal
SWEP.SpeedMult = 1
SWEP.SightedSpeedMult = .9
SWEP.SightTime = .5

SWEP.IronSightStruct = {
	Pos = Vector(-1.71, 15, .94),
	Ang = Angle(-.1, 0, -2),
	Magnification = 1.1,
	SwitchToSound = JMod.GunHandlingSounds.aim.minor,
	SwitchFromSound = JMod.GunHandlingSounds.aim.minor
}

SWEP.ActivePos = Vector(0, 0, 0)
SWEP.ActiveAng = Angle(1.8, 1.5, -2.5)
SWEP.HolsterPos = Vector(0, 0, 0)
SWEP.HolsterAng = Angle(-45, 0, 0)
SWEP.MeleePitch = 1.1
SWEP.MeleeDamage = 7
SWEP.MeleeTime = .4
SWEP.BarrelLength = 20

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
		Time = .7,
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
	["fire"] = {
		Source = "fire",
		Time = 0.4,
		ShellEjectAt = 0,
		TPAnim = ACT_HL2MP_GESTURE_RANGE_ATTACK_PISTOL
	},
	["reload"] = {
		Source = "reload_tac",
		Time = 3,
		TPAnim = ACT_HL2MP_GESTURE_RELOAD_AR2,
		Checkpoints = {24, 42, 59, 71},
		FrameRate = 37,
		LHIK = true,
		LHIKIn = 0.5,
		LHIKOut = 0.5,
		SoundTable = {
			{
				s = JMod.GunHandlingSounds.cloth.move,
				t = .05,
				v = 60,
				p = 110
			},
			{
				s = "snds_jack_gmod/ez_weapons/magnumpistol/out.ogg",
				t = .3,
				v = 60
			},
			{
				s = JMod.GunHandlingSounds.cloth.magpull,
				t = 1,
				v = 60,
				p = 110
			},
			{
				s = JMod.GunHandlingSounds.tap.magwell,
				t = 1.6,
				v = 60,
				p = 110
			},
			{
				s = "snds_jack_gmod/ez_weapons/magnumpistol/in.ogg",
				t = 1.85,
				v = 60
			},
			{
				s = JMod.GunHandlingSounds.grab,
				t = 2.3,
				v = 55,
				p = 110
			}
		}
	},
	["reload_empty"] = {
		Source = "reload_empty",
		Time = 3.5,
		TPAnim = ACT_HL2MP_GESTURE_RELOAD_AR2,
		Checkpoints = {24, 42, 59, 71, 89},
		FrameRate = 37,
		LHIK = true,
		LHIKIn = 0.5,
		LHIKOut = 0.5,
		SoundTable = {
			{
				s = JMod.GunHandlingSounds.cloth.move,
				t = .05,
				v = 60,
				p = 110
			},
			{
				s = "snds_jack_gmod/ez_weapons/magnumpistol/out.ogg",
				t = .4,
				v = 60
			},
			{
				s = JMod.GunHandlingSounds.cloth.magpull,
				t = 1.1,
				v = 60,
				p = 110
			},
			{
				s = JMod.GunHandlingSounds.tap.magwell,
				t = 2,
				v = 60,
				p = 110
			},
			{
				s = "snds_jack_gmod/ez_weapons/magnumpistol/in.ogg",
				t = 2.1,
				v = 60
			},
			{
				s = "snds_jack_gmod/ez_weapons/magnumpistol/release.ogg",
				t = 2.4,
				v = 60
			},
			{
				s = JMod.GunHandlingSounds.grab,
				t = 2.9,
				v = 55,
				p = 110
			}
		}
	}
}
