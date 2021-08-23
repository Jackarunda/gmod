SWEP.Base = "wep_jack_gmod_gunbase"

SWEP.PrintName = "Flintlock Musket"

SWEP.Slot = 3

SWEP.ViewModel = "models/weapons/v_jmod_musket.mdl"
SWEP.WorldModel = "models/weapons/w_jmod_musket.mdl"
SWEP.ViewModelFOV = 75
SWEP.BodyHolsterSlot = "back"
SWEP.BodyHolsterAng = Angle(0,-15,0)
SWEP.BodyHolsterAngL = Angle(0,15,180)
SWEP.BodyHolsterPos = Vector(5.5,-3,-3)
SWEP.BodyHolsterPosL = Vector(1,-6,3)
SWEP.BodyHolsterScale = .9

JMod.ApplyAmmoSpecs(SWEP,"Black Powder Paper Cartridge")

SWEP.Primary.ClipSize = 1 -- DefaultClip is automatically set.

SWEP.Recoil = 2

SWEP.Delay = 60 / 100 -- 60 / RPM.
SWEP.Firemodes = {
	{
		Mode = 1,
		PrintName = "SINGLE"
	},
	{
		Mode = 0
	}
}

SWEP.AccuracyMOA = 12 -- accuracy in Minutes of Angle. There are 60 MOA in a degree.

SWEP.FirstShootSound = "snds_jack_gmod/ez_weapons/flintlock_longgun.wav"
SWEP.ShootSound = "snds_jack_gmod/ez_weapons/flintlock_longgun.wav"
SWEP.DistantShootSound = "snds_jack_gmod/ez_weapons/shotgun_far.wav"
SWEP.ShootSoundExtraMult=1

SWEP.MuzzleEffect = "muzzleflash_M3"
SWEP.ExtraMuzzleLua = "eff_jack_gmod_bpmuzzle"
SWEP.ExtraMuzzleLuaScale = 1

SWEP.SpeedMult = 1
SWEP.SightedSpeedMult = .7
SWEP.SightTime = .6

SWEP.IronSightStruct = {
	Pos = Vector(-6.2, -1, 3.75),
	Ang = Angle(-.2, 0, -5),
	Magnification = 1.1,
	SwitchToSound = JMod.GunHandlingSounds.aim.inn,
	SwitchFromSound = JMod.GunHandlingSounds.aim.out
}

SWEP.ActivePos = Vector(0, 0, 0)
SWEP.ActiveAng = Angle(0, 0, 0)

SWEP.HolsterPos = Vector(11, 1, -6)
SWEP.HolsterAng = Angle(0, 60, -15)

SWEP.ReloadPos = Vector(0,-2,-9)
SWEP.ReloadAng = Angle(20,0,0)

SWEP.BarrelLength = 50

SWEP.ProceduralViewBobIntensity = .3

-- ima just leave this here until arctic gets his shit together
SWEP.CanBash = true
SWEP.MeleeRange = 60
SWEP.MeleeDamageType = DMG_SLASH
SWEP.MeleeDamage = 20
SWEP.MeleeForceDir = Angle(0,0,0)
SWEP.MeleeAttackTime=.4
SWEP.MeleeTime = .5
SWEP.MeleeDelay = .4
SWEP.MeleeSwingSound = JMod.GunHandlingSounds.cloth.loud
SWEP.MeleeHitSound = {"snds_jack_gmod/ez_weapons/knives/hit1.wav","snds_jack_gmod/ez_weapons/knives/hit2.wav","snds_jack_gmod/ez_weapons/knives/hit3.wav"}
SWEP.MeleeHitNPCSound = {"snds_jack_gmod/knifestab.wav","snds_jack_gmod/knifestab.wav","snds_jack_gmod/knifestab.wav","snds_jack_gmod/knifestab.wav","snds_jack_gmod/knifestab.wav"}
SWEP.MeleeMissSound = "weapons/iceaxe/iceaxe_swing1.wav"
SWEP.MeleeVolume = 65
SWEP.MeleePitch = 1
SWEP.MeleeHitEffect = nil -- "BloodImpact"
SWEP.MeleeHitBullet = true
SWEP.MeleeDmgRand = .4
SWEP.MeleeViewMovements = {
	{t = 0, ang = Angle(0,-2,0)},
	{t = .3, ang = Angle(0,2,0)}
}
SWEP.BashPrepareAng = Angle(5,0,-20)
SWEP.BashPreparePos = Vector(0, -10, 0)
SWEP.BashPos = Vector(-10, 15, 5)
SWEP.BashAng = Angle(-5, 0, -30)

SWEP.Attachments = {
	{
        PrintName = "Muzzle",
        Slot = {"ez_muzzle"},
        Bone = "Musket",
        Offset = {
			vpos = Vector(-3.5, 21, 1.5),
            vang = Angle(0, 80, 180),
			wpos = Vector(-8, 1.5, 1),
            wang = Angle(-14, -2, -90)
        },
        -- remove Slide because it ruins my life
		Installed = "muzzle_jack_bayonet"
    }
}

--[[
idle
idle_empty
draw
draw_empty
fire
fire_empty
dryfire
iron_fire
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
	["idle_empty"] = {
		Source = "idle_empty",
		Time = 1
	},
	["draw"] = {
		Source = "draw",
		Time = 1.2,
		SoundTable = {{s = JMod.GunHandlingSounds.draw.longgun, t = 0, v=60}},
		Mult=1,
		LHIK = true,
		LHIKIn = 0,
		LHIKOut = 0.35
	},
	["draw_empty"] = {
		Source = "draw_empty",
		Time = 1.2,
		SoundTable = {{s = JMod.GunHandlingSounds.draw.longgun, t = 0, v=60}},
		Mult=1,
		LHIK = true,
		LHIKIn = 0,
		LHIKOut = 0.35
	},
	["ready"] = {
		Source = "draw_empty",
		Time = 1.2,
		SoundTable = {
			{s = JMod.GunHandlingSounds.draw.longgun, t = 0, v=60}
		},
		Mult=1,
		LHIK = true,
		LHIKIn = 0,
		LHIKOut = 0.25
	},
	["fire"] = {
		Source = "fire_empty",
		Time = 0.5
	},
	["reload_empty"] = {
		Source = "reload_empty",
		Time = 9,
		TPAnim = ACT_HL2MP_GESTURE_RELOAD_AR2,
		Checkpoints = {24, 42, 59, 71, 89},
		FrameRate = 37,
		Mult=1,
		LHIK = true,
		LHIKIn = 0.5,
		LHIKOut = 0.5,
		SoundTable = {
			{s = JMod.GunHandlingSounds.cloth.loud, t = .2, v=60, p=100},
			{s = JMod.GunHandlingSounds.cloth.magpull, t = 1.1, v=60, p=100},
			{s = "snds_jack_gmod/ez_weapons/flm/rip.wav", t = 2.1, v=65},
			{s = "snds_jack_gmod/ez_weapons/flm/pour.wav", t = 3.1, v=65},
			{s = JMod.GunHandlingSounds.cloth.magpull, t = 4.8, v=60, p=130},
			{s = "snds_jack_gmod/ez_weapons/flm/drop.wav", t = 6.1, v=65, p=100},
			{s = JMod.GunHandlingSounds.cloth.magpull, t = 7.4, v=60, p=120},
			{s = "snds_jack_gmod/ez_weapons/flm/halfcock.wav", t = 7.6, v=65, p=100},
			{s = "snds_jack_gmod/ez_weapons/flm/openfrizzen.wav", t = 7.9, v=65, p=100},
			{s = "snds_jack_gmod/ez_weapons/flm/primepan.wav", t = 8.1, v=65, p=100},
			{s = "snds_jack_gmod/ez_weapons/flm/closefrizzen.wav", t = 8.2, v=65, p=100},
			{s = "snds_jack_gmod/ez_weapons/flm/fullcock.wav", t = 8.3, v=65, p=100},
			{s = JMod.GunHandlingSounds.cloth.loud, t = 9, v=60, p=100}
		},
		ViewPunchTable = {
			{t = 2, p = Angle(0,5,0)},
			{t = 7.2, p = Angle(1,0,0)},
			{t = 7.5, p = Angle(1,0,0)},
			{t = 7.8, p = Angle(1,0,0)},
			{t = 8.1, p = Angle(1,0,0)},
			{t = 8.4, p = Angle(2,0,0)}
		}
	},
}