SWEP.Base = "wep_jack_gmod_gunbase"
SWEP.PrintName = "Flintlock Pistol"
SWEP.Slot = 3
SWEP.ViewModel = "models/weapons/c_flintlock_handgun.mdl"
SWEP.WorldModel = "models/pistol/pistol.mdl"
SWEP.ViewModelFOV = 75
SWEP.BodyHolsterSlot = "back"
SWEP.BodyHolsterAng = Angle(0, -15, 0)
SWEP.BodyHolsterAngL = Angle(0, 15, 180)
SWEP.BodyHolsterPos = Vector(5.5, -3, -3)
SWEP.BodyHolsterPosL = Vector(1, -6, 3)
SWEP.BodyHolsterScale = .9
JMod.ApplyAmmoSpecs(SWEP, "Black Powder Paper Cartridge", .8)
SWEP.Primary.ClipSize = 1 -- DefaultClip is automatically set.
SWEP.Recoil = 2
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

SWEP.AccuracyMOA = 12 -- accuracy in Minutes of Angle. There are 60 MOA in a degree.
SWEP.FirstShootSound = "snds_jack_gmod/ez_weapons/flintlock_longgun.ogg"
SWEP.ShootSound = "snds_jack_gmod/ez_weapons/flintlock_longgun.ogg"
SWEP.DistantShootSound = "snds_jack_gmod/ez_weapons/shotgun_far.ogg"
SWEP.ShootSoundExtraMult = 1
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
SWEP.ReloadPos = Vector(0, -2, -9)
SWEP.ReloadAng = Angle(20, 0, 0)
SWEP.BarrelLength = 20
SWEP.ProceduralViewBobIntensity = .3

SWEP.VMBoneMods = {
	["Flintlock"] = Vector(10, 10, 10)
}

--[[
models/weapons/c_flintlock_handgun.mdl
models/pistol/pistol.mdl
anim	0	idle
anim	1	shoot
anim	2	reload
anim	3	draw
---------------------
bone	0	ValveBiped.Bip01_Spine4
bone	1	ValveBiped.Bip01_L_Clavicle
bone	2	ValveBiped.Bip01_L_UpperArm
bone	3	ValveBiped.Bip01_L_Forearm
bone	4	ValveBiped.Bip01_L_Hand
bone	5	ValveBiped.Bip01_L_Finger4
bone	6	ValveBiped.Bip01_L_Finger41
bone	7	ValveBiped.Bip01_L_Finger42
bone	8	ValveBiped.Bip01_L_Finger3
bone	9	ValveBiped.Bip01_L_Finger31
bone	10	ValveBiped.Bip01_L_Finger32
bone	11	ValveBiped.Bip01_L_Finger2
bone	12	ValveBiped.Bip01_L_Finger21
bone	13	ValveBiped.Bip01_L_Finger22
bone	14	ValveBiped.Bip01_L_Finger1
bone	15	ValveBiped.Bip01_L_Finger11
bone	16	ValveBiped.Bip01_L_Finger12
bone	17	ValveBiped.Bip01_L_Finger0
bone	18	ValveBiped.Bip01_L_Finger01
bone	19	ValveBiped.Bip01_L_Finger02
bone	20	ValveBiped.Bip01_L_Wrist
bone	21	ValveBiped.Bip01_R_Clavicle
bone	22	ValveBiped.Bip01_R_UpperArm
bone	23	ValveBiped.Bip01_R_Forearm
bone	24	ValveBiped.Bip01_R_Hand
bone	25	ValveBiped.Bip01_R_Finger4
bone	26	ValveBiped.Bip01_R_Finger41
bone	27	ValveBiped.Bip01_R_Finger42
bone	28	ValveBiped.Bip01_R_Finger3
bone	29	ValveBiped.Bip01_R_Finger31
bone	30	ValveBiped.Bip01_R_Finger32
bone	31	ValveBiped.Bip01_R_Finger2
bone	32	ValveBiped.Bip01_R_Finger21
bone	33	ValveBiped.Bip01_R_Finger22
bone	34	ValveBiped.Bip01_R_Finger1
bone	35	ValveBiped.Bip01_R_Finger11
bone	36	ValveBiped.Bip01_R_Finger12
bone	37	ValveBiped.Bip01_R_Finger0
bone	38	ValveBiped.Bip01_R_Finger01
bone	39	ValveBiped.Bip01_R_Finger02
bone	40	ValveBiped.Bip01_R_Wrist
bone	41	Flintlock
bone	42	Lock 1
bone	43	Lock 2
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
		LHIKOut = 0.35
	},
	["draw_empty"] = {
		Source = "draw_empty",
		Time = 1.2,
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
		LHIKOut = 0.35
	},
	["ready"] = {
		Source = "draw_empty",
		Time = 1.2,
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
		LHIKOut = 0.25
	},
	["fire"] = {
		Source = "fire_empty",
		Time = 0.5,
		TPAnim = ACT_HL2MP_GESTURE_RANGE_ATTACK_PISTOL
	},
	["reload_empty"] = {
		Source = "reload_empty",
		Time = 9,
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
				t = .2,
				v = 60,
				p = 100
			},
			{
				s = JMod.GunHandlingSounds.cloth.magpull,
				t = 1.1,
				v = 60,
				p = 100
			},
			{
				s = "snds_jack_gmod/ez_weapons/flm/rip.ogg",
				t = 2.1,
				v = 65
			},
			{
				s = "snds_jack_gmod/ez_weapons/flm/pour.ogg",
				t = 3.1,
				v = 65
			},
			{
				s = JMod.GunHandlingSounds.cloth.magpull,
				t = 4.8,
				v = 60,
				p = 130
			},
			{
				s = "snds_jack_gmod/ez_weapons/flm/drop.ogg",
				t = 6.1,
				v = 65,
				p = 100
			},
			{
				s = JMod.GunHandlingSounds.cloth.magpull,
				t = 7.4,
				v = 60,
				p = 120
			},
			{
				s = "snds_jack_gmod/ez_weapons/flm/halfcock.ogg",
				t = 7.6,
				v = 65,
				p = 100
			},
			{
				s = "snds_jack_gmod/ez_weapons/flm/openfrizzen.ogg",
				t = 7.9,
				v = 65,
				p = 100
			},
			{
				s = "snds_jack_gmod/ez_weapons/flm/primepan.ogg",
				t = 8.1,
				v = 65,
				p = 100
			},
			{
				s = "snds_jack_gmod/ez_weapons/flm/closefrizzen.ogg",
				t = 8.2,
				v = 65,
				p = 100
			},
			{
				s = "snds_jack_gmod/ez_weapons/flm/fullcock.ogg",
				t = 8.3,
				v = 65,
				p = 100
			},
			{
				s = JMod.GunHandlingSounds.cloth.loud,
				t = 9,
				v = 60,
				p = 100
			}
		},
		ViewPunchTable = {
			{
				t = 2,
				p = Angle(0, 5, 0)
			},
			{
				t = 7.2,
				p = Angle(1, 0, 0)
			},
			{
				t = 7.5,
				p = Angle(1, 0, 0)
			},
			{
				t = 7.8,
				p = Angle(1, 0, 0)
			},
			{
				t = 8.1,
				p = Angle(1, 0, 0)
			},
			{
				t = 8.4,
				p = Angle(2, 0, 0)
			}
		}
	},
}
