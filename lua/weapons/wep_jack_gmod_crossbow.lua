SWEP.Base = "wep_jack_gmod_gunbase"
SWEP.PrintName = "Crossbow"
JMod.SetWepSelectIcon(SWEP, "entities/ent_jack_gmod_ezweapon_crossbow", true)
SWEP.Slot = 3
SWEP.ViewModel = "models/weapons/c_jmod_crossbow.mdl"
SWEP.WorldModel = "models/weapons/w_jmod_crossbow.mdl"
SWEP.ViewModelFOV = 75
SWEP.BodyHolsterSlot = "back"
SWEP.BodyHolsterAng = Angle(90, -103, 10)
SWEP.BodyHolsterAngL = Angle(90, -103, -10)
SWEP.BodyHolsterPos = Vector(11.5, -10, -6)
SWEP.BodyHolsterPosL = Vector(10.5, -11, 6)
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
JMod.ApplyAmmoSpecs(SWEP, "Arrow")
SWEP.ShootEntity = "ent_jack_gmod_ezarrow"
SWEP.MuzzleVelocity = 7000
SWEP.ShootEntityOffset = Vector(-1, 0, -2)
SWEP.ShootEntityAngle = Angle(0, 0, 0)
SWEP.ShootEntityAngleCorrection = Angle(0, 0, 0)
SWEP.MuzzleEffect = nil
SWEP.NoFlash = true
SWEP.Primary.ClipSize = 1 -- DefaultClip is automatically set.
SWEP.ChamberSize = 0
SWEP.Recoil = .6
SWEP.Delay = 60 / 100 -- 60/RPM.

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

SWEP.FirstShootSound = {"snds_jack_gmod/ez_weapons/crossbow/fire1.ogg", "snds_jack_gmod/ez_weapons/crossbow/fire2.ogg", "snds_jack_gmod/ez_weapons/crossbow/fire3.ogg"}

SWEP.ShootSound = {"snds_jack_gmod/ez_weapons/crossbow/fire1.ogg", "snds_jack_gmod/ez_weapons/crossbow/fire2.ogg", "snds_jack_gmod/ez_weapons/crossbow/fire3.ogg"}

SWEP.DistantShootSound = ""
SWEP.ShootSoundExtraMult = 0
SWEP.ShootVol = 55
--[[
SWEP.MuzzleEffect="muzzleflash_m14"
SWEP.ShellModel="models/jhells/shell_762nato.mdl"
SWEP.ShellPitch=80
SWEP.ShellScale=2
--]]
SWEP.SpeedMult = 1
SWEP.SightedSpeedMult = .7
SWEP.SightTime = .5

-- arctic, don't ever write descriptions again
SWEP.BulletBones = {
	[1] = "tag_clip"
}

SWEP.IronSightStruct = {
	Pos = Vector(-2.22, 4, .6),
	Ang = Angle(-.15, 0, -2),
	Magnification = 1.2,
	SwitchToSound = JMod.GunHandlingSounds.aim.inn,
	SwitchFromSound = JMod.GunHandlingSounds.aim.out
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
		SoundTable = {
			{
				s = JMod.GunHandlingSounds.draw.longgun,
				t = 0,
				v = 50
			}
		},
		Mult = 1,
		LHIK = true,
		LHIKIn = 0,
		LHIKOut = 0.35,
	},
	["fire"] = {
		Source = "shoot",
		Time = .5,
		TPAnim = ACT_HL2MP_GESTURE_RANGE_ATTACK_AR2
	},
	["reload_empty"] = {
		Source = "reload",
		Time = 4,
		TPAnim = ACT_HL2MP_GESTURE_RELOAD_AR2,
		Checkpoints = {24, 42, 59, 71, 89},
		FrameRate = 37,
		Mult = 1,
		LHIK = true,
		LHIKIn = 0.5,
		LHIKOut = 0.5,
		SoundTable = {
			{
				s = JMod.GunHandlingSounds.cloth.loud,
				t = 0,
				v = 60
			},
			{
				s = JMod.GunHandlingSounds.cloth.quiet,
				t = .5,
				v = 60
			},
			{
				s = "snds_jack_gmod/ez_weapons/crossbow/pull.ogg",
				t = 0.9,
				v = 55
			},
			{
				s = JMod.GunHandlingSounds.cloth.magpull,
				t = 1.4,
				v = 60,
				p = 110
			},
			{
				s = "snds_jack_gmod/ez_weapons/crossbow/in.ogg",
				t = 2.4,
				v = 55,
				p = 120
			},
			{
				s = "snds_jack_gmod/ez_weapons/crossbow/clack.ogg",
				t = 3.3,
				v = 55
			},
			{
				s = JMod.GunHandlingSounds.grab,
				t = 3.7,
				v = 55
			}
		}
	},
}
