SWEP.Base = "wep_jack_gmod_gunbase"
SWEP.PrintName = "Cap and Ball Revolver"
JMod.SetWepSelectIcon(SWEP, "entities/ent_jack_gmod_ezweapon_cabr", true)
SWEP.Slot = 1
SWEP.ViewModel = "models/krazy/gtav/weapons/navyrevolver_v.mdl"
SWEP.WorldModel = "models/krazy/gtav/weapons/navyrevolver_w.mdl"
SWEP.ViewModelFOV = 80
SWEP.BodyHolsterSlot = "thighs"
SWEP.BodyHolsterAng = Angle(180, 0, -115)
SWEP.BodyHolsterAngL = Angle(180, 0, -90)
SWEP.BodyHolsterPos = Vector(.5, 5, -5)
SWEP.BodyHolsterPosL = Vector(-2, 5, 4)
SWEP.BodyHolsterScale = 1
SWEP.HoldtypeHolstered = "normal"
SWEP.HoldtypeActive = "pistol"
SWEP.HoldtypeSights = "revolver"
JMod.ApplyAmmoSpecs(SWEP, "Black Powder Paper Cartridge", .3)
SWEP.HipDispersion = 1100
SWEP.Primary.ClipSize = 6 -- DefaultClip is automatically set.
SWEP.ChamberSize = 0 -- revolver lol
SWEP.Recoil = 1.5
SWEP.VisualRecoilMult = 2
SWEP.Delay = 60 / 60 -- 60/RPM.

SWEP.Firemodes = {
	{
		Mode = 1,
		PrintName = "SINGLE-ACTION"
	},
	{
		Mode = 0
	}
}

SWEP.AccuracyMOA = 12 -- accuracy in Minutes of Angle. There are 60 MOA in a degree.
SWEP.FirstShootSound = "snds_jack_gmod/ez_weapons/caplock_handgun.ogg"
SWEP.ShootSound = "snds_jack_gmod/ez_weapons/caplock_handgun.ogg"
SWEP.DistantShootSound = "snds_jack_gmod/ez_weapons/pistol_far.ogg"
SWEP.ShootSoundExtraMult = 1
SWEP.MuzzleEffect = "muzzleflash_pistol"
SWEP.ExtraMuzzleLua = "eff_jack_gmod_bpmuzzle"
SWEP.ExtraMuzzleLuaScale = .5
SWEP.SpeedMult = 1
SWEP.SightedSpeedMult = .9
SWEP.SightTime = .25

SWEP.IronSightStruct = {
	Pos = Vector(-4.2, 10, 2),
	Ang = Angle(-.2, -.2, -2),
	Magnification = 1.1,
	SwitchToSound = JMod.GunHandlingSounds.aim.minor,
	SwitchFromSound = JMod.GunHandlingSounds.aim.minor
}

SWEP.ActivePos = Vector(0, 0, 0)
SWEP.ActiveAng = Angle(0, 0, 0)
SWEP.MeleePitch = 1.1
SWEP.MeleeDamage = 7
SWEP.MeleeTime = .4
SWEP.HolsterPos = Vector(0, 0, 0)
SWEP.HolsterAng = Angle(-45, 0, 0)
SWEP.ReloadPos = Vector(0, -4, 3)
SWEP.BarrelLength = 20

--[[
idle
idle_empty
draw
draw_empty
fire
iron_fire
fire_empty
dryfire
iron_fire_empty
iron_dryfire
reload
reload_empty
holster
holster_empty
sprint
sprint_empty
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
	["fire"] = {
		Source = "fire",
		Time = 1.4,
		Mult = 1,
		TPAnim = ACT_HL2MP_GESTURE_RANGE_ATTACK_PISTOL,
		SoundTable = {
			{
				s = "snds_jack_gmod/ez_weapons/cabr/cock.ogg",
				t = .7,
				v = 55
			},
		}
	},
	["reload"] = {
		Source = "reload",
		Time = 7,
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
				v = 55,
				p = 110
			},
			{
				s = "snds_jack_gmod/ez_weapons/cabr/pull.ogg",
				t = .6,
				v = 55
			},
			{
				s = "snds_jack_gmod/ez_weapons/flm/halfcock.ogg",
				t = 1.5,
				v = 55
			},
			{
				s = "snds_jack_gmod/ez_weapons/cabr/out.ogg",
				t = 2.8,
				v = 60
			},
			{
				s = JMod.GunHandlingSounds.cloth.magpull,
				t = 3.5,
				v = 55
			},
			{
				s = "snds_jack_gmod/ez_weapons/cabr/in.ogg",
				t = 4.15,
				v = 60
			},
			{
				s = "snds_jack_gmod/ez_weapons/flm/fullcock.ogg",
				t = 5.4,
				v = 55
			},
			{
				s = "snds_jack_gmod/ez_weapons/cabr/close.ogg",
				t = 5.75,
				v = 55
			},
			{
				s = JMod.GunHandlingSounds.grab,
				t = 6.55,
				v = 55
			}
		}
	}
}
