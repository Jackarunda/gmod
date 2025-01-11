SWEP.Base = "wep_jack_gmod_gunbase"
SWEP.PrintName = "Magnum Revolver"
JMod.SetWepSelectIcon(SWEP, "entities/ent_jack_gmod_ezweapon_magrevolver", true)
SWEP.Slot = 1
SWEP.ViewModel = "models/weapons/c_mw2_44magnum.mdl"
SWEP.WorldModel = "models/weapons/w_jmod_44mag.mdl"
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
JMod.ApplyAmmoSpecs(SWEP, "Magnum Pistol Round", 1.3)
SWEP.HipDispersion = 1100
SWEP.Primary.ClipSize = 6 -- DefaultClip is automatically set.
SWEP.ChamberSize = 0 -- revolver lol
SWEP.Recoil = 2
SWEP.VisualRecoilMult = 2
SWEP.Delay = 60 / 150 -- 60/RPM.

SWEP.Firemodes = {
	{
		Mode = 1,
		PrintName = "DOUBLE-ACTION"
	},
	{
		Mode = 0
	}
}

SWEP.AccuracyMOA = 6 -- accuracy in Minutes of Angle. There are 60 MOA in a degree.
SWEP.FirstShootSound = "snds_jack_gmod/ez_weapons/magnum_revolver.ogg"
SWEP.ShootSound = "snds_jack_gmod/ez_weapons/magnum_revolver.ogg"
SWEP.DistantShootSound = "snds_jack_gmod/ez_weapons/pistol_far.ogg"
SWEP.ShootSoundExtraMult = 1
SWEP.MuzzleEffect = "muzzleflash_pistol_deagle"
SWEP.ShellModel = "models/jhells/shell_9mm.mdl"
SWEP.ShellPitch = 80
SWEP.ShellScale = 3.5
SWEP.ShellSounds = JMod.ShellSounds.metal
SWEP.SpeedMult = 1
SWEP.SightedSpeedMult = .9
SWEP.SightTime = .35

SWEP.IronSightStruct = {
	Pos = Vector(-1.78, 12, .43),
	Ang = Angle(-.25, 0, -2),
	Magnification = 1.1,
	SwitchToSound = JMod.GunHandlingSounds.aim.minor,
	SwitchFromSound = JMod.GunHandlingSounds.aim.minor
}

SWEP.ActivePos = Vector(0, 0, .5)
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
reload_empty
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
		Time = 0.7,
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
	["fire"] = {
		Source = "fire",
		Time = 0.4,
		TPAnim = ACT_HL2MP_GESTURE_RANGE_ATTACK_PISTOL
	},
	["reload"] = {
		Source = "reload_empty",
		Time = 4,
		TPAnim = ACT_HL2MP_GESTURE_RELOAD_AR2,
		Checkpoints = {24, 42, 59, 71, 89},
		FrameRate = 37,
		LHIK = true,
		LHIKIn = 0.5,
		LHIKOut = 0.5,
		ShellEjectAt = 1.1,
		SoundTable = {
			{
				s = JMod.GunHandlingSounds.cloth.move,
				t = 0,
				v = 60,
				p = 110
			},
			{
				s = "snds_jack_gmod/ez_weapons/magnumrevolver/open.ogg",
				t = .65,
				v = 60
			},
			{
				s = "snds_jack_gmod/ez_weapons/magnumrevolver/out.ogg",
				t = .75,
				v = 55
			},
			{
				s = JMod.GunHandlingSounds.cloth.magpull,
				t = .8,
				v = 60,
				p = 110
			},
			{
				s = "snds_jack_gmod/ez_weapons/magnumrevolver/in.ogg",
				t = 1.9,
				v = 60
			},
			{
				s = "snds_jack_gmod/ez_weapons/magnumrevolver/close.ogg",
				t = 2.8,
				v = 60
			},
			{
				s = JMod.GunHandlingSounds.grab,
				t = 3.7,
				v = 55,
				p = 110
			}
		}
	}
}
