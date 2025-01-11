SWEP.Base = "wep_jack_gmod_gunbase"
SWEP.PrintName = "Machine Pistol"
JMod.SetWepSelectIcon(SWEP, "entities/ent_jack_gmod_ezweapon_machinepistol", true)
SWEP.Slot = 1
SWEP.ViewModel = "models/weapons/c_bo1_mac11.mdl"
SWEP.WorldModel = "models/weapons/w_jmod_mac11.mdl"
SWEP.ViewModelFOV = 75
SWEP.BodyHolsterSlot = "thighs"
SWEP.BodyHolsterAng = Angle(90, 90, -20)
SWEP.BodyHolsterAngL = Angle(90, 90, -20)
SWEP.BodyHolsterPos = Vector(-5, 17, -6)
SWEP.BodyHolsterPosL = Vector(-7, 17, 2.25)
SWEP.BodyHolsterScale = 1.1
SWEP.HoldtypeHolstered = "normal"
SWEP.HoldtypeActive = "pistol"
SWEP.HoldtypeSights = "revolver"
JMod.ApplyAmmoSpecs(SWEP, "Pistol Round")
SWEP.HipDispersion = 1100
SWEP.Primary.ClipSize = 25 -- DefaultClip is automatically set.
SWEP.ChamberSize = 0 -- open-bolt firearm lol
SWEP.Recoil = .6
SWEP.Delay = 60 / 1300 -- 60/RPM.

SWEP.Firemodes = {
	{
		Mode = 2,
		PrintName = "FULL-AUTO"
	},
	{
		Mode = 1,
		PrintName = "SEMI-AUTO"
	},
	{
		Mode = 0
	}
}

SWEP.AccuracyMOA = 12 -- accuracy in Minutes of Angle. There are 60 MOA in a degree.
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
SWEP.SightTime = .3

SWEP.IronSightStruct = {
	Pos = Vector(-3.52, 12, 1.05),
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
reload_tac
reload_empty
draw
fire
holster
sprint
bigammo_reload_tac
bigammo_reload_empty
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
		Time = .8,
		SoundTable = {
			{
				s = JMod.GunHandlingSounds.draw.handgun,
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
		Source = "fire",
		Time = 0.2,
		ShellEjectAt = 0,
		TPAnim = ACT_HL2MP_GESTURE_RANGE_ATTACK_PISTOL
	},
	["reload"] = {
		Source = "reload_tac",
		Time = 2.5,
		TPAnim = ACT_HL2MP_GESTURE_RELOAD_AR2,
		Checkpoints = {24, 42, 59, 71},
		FrameRate = 37,
		LHIK = true,
		LHIKIn = 0.5,
		LHIKOut = 0.5,
		SoundTable = {
			{
				s = "snds_jack_gmod/ez_weapons/mp/out.ogg",
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
				t = 1.65,
				v = 60,
				p = 120
			},
			{
				s = "snds_jack_gmod/ez_weapons/mp/in.ogg",
				t = 1.85,
				v = 60
			},
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
				s = "snds_jack_gmod/ez_weapons/mp/out.ogg",
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
				t = 1.7,
				v = 60,
				p = 120
			},
			{
				s = "snds_jack_gmod/ez_weapons/mp/in.ogg",
				t = 1.85,
				v = 60
			},
			{
				s = "snds_jack_gmod/ez_weapons/mp/pull.ogg",
				t = 2.45,
				v = 60
			},
			{
				s = "snds_jack_gmod/ez_weapons/mp/release.ogg",
				t = 2.7,
				v = 60
			},
		}
	}
}
