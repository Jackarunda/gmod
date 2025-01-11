SWEP.Base = "wep_jack_gmod_gunbase"
SWEP.PrintName = "Pocket Pistol"
JMod.SetWepSelectIcon(SWEP, "entities/ent_jack_gmod_ezweapon_pocketpistol", true)
SWEP.Slot = 1
SWEP.ViewModel = "models/weapons/v_jmod_usp.mdl"
SWEP.WorldModel = "models/weapons/w_jmod_usp.mdl"
SWEP.ViewModelFOV = 75
--[[ -- pocket pistol goes in pocket ^:)
SWEP.BodyHolsterSlot="thighs"
SWEP.BodyHolsterAng=Angle(90,90,-20)
SWEP.BodyHolsterAngL=Angle(90,90,-20)
SWEP.BodyHolsterPos=Vector(-5,17,-6)
SWEP.BodyHolsterPosL=Vector(-7,17,2.25)
SWEP.BodyHolsterScale=1.1
--]]
SWEP.HoldtypeHolstered = "normal"
SWEP.HoldtypeActive = "pistol"
SWEP.HoldtypeSights = "revolver"
JMod.ApplyAmmoSpecs(SWEP, "Pistol Round")
SWEP.HipDispersion = 1100
SWEP.Primary.ClipSize = 6 -- DefaultClip is automatically set.
SWEP.Recoil = 1.2
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
SWEP.SightTime = .25

SWEP.IronSightStruct = {
	Pos = Vector(-2.89, 10, 2.1),
	Ang = Angle(-1, 0, 0),
	Magnification = 1.1,
	SwitchToSound = JMod.GunHandlingSounds.aim.minor,
	SwitchFromSound = JMod.GunHandlingSounds.aim.minor
}

SWEP.ActivePos = Vector(-1, 0, 0)
SWEP.ActiveAng = Angle(0, 0, 0)
SWEP.MeleePitch = 1.1
SWEP.MeleeDamage = 7
SWEP.MeleeTime = .4
SWEP.HolsterPos = Vector(0, 0, 0)
SWEP.HolsterAng = Angle(-45, 0, 0)
SWEP.BarrelLength = 15

SWEP.Attachments = {
	{
		PrintName = "Tactical Rail",
		Slot = {"ez_tac_rail"},
		Bone = "tag_weapon",
		Offset = {
			vpos = Vector(2.5, 0, 0),
			vang = Angle(0, 0, 0),
			wpos = Vector(0, 0, 0),
			wang = Angle(0, 0, 0)
		},
		-- remove Slide because it ruins my life
		Installed = "tacrail_jack_laser"
	}
}

--[[
idle
reload_full
reload_empty
draw2
shoot1
dry
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
		Source = "draw2",
		Time = 0.3,
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
		Source = "shoot1",
		Time = .8,
		ShellEjectAt = 0,
		TPAnim = ACT_HL2MP_GESTURE_RANGE_ATTACK_PISTOL
	},
	["fire_empty"] = {
		Source = "dry",
		Time = 1,
		ShellEjectAt = 0,
		TPAnim = ACT_HL2MP_GESTURE_RANGE_ATTACK_PISTOL
	},
	["reload"] = {
		Source = "reload_full",
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
				v = 60,
				p = 120
			},
			{
				s = JMod.GunHandlingSounds.cloth.magpull,
				t = .4,
				v = 60,
				p = 110
			},
			{
				s = "snds_jack_gmod/ez_weapons/pistol/tap.ogg",
				t = .85,
				v = 60,
				p = 120
			},
			{
				s = "snds_jack_gmod/ez_weapons/pistol/in.ogg",
				t = .85,
				v = 60,
				p = 120
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
				v = 60,
				p = 120
			},
			{
				s = JMod.GunHandlingSounds.cloth.magpull,
				t = .4,
				v = 60,
				p = 110
			},
			{
				s = "snds_jack_gmod/ez_weapons/pistol/tap.ogg",
				t = .95,
				v = 60,
				p = 120
			},
			{
				s = "snds_jack_gmod/ez_weapons/pistol/in.ogg",
				t = 1,
				v = 60,
				p = 120
			},
			{
				s = "snds_jack_gmod/ez_weapons/pistol/release.ogg",
				t = 1.75,
				v = 60,
				p = 120
			}
		}
	}
}
