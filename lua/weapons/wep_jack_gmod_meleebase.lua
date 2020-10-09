SWEP.Base = "wep_jack_gmod_gunbase"

SWEP.PrintName = "Melee"

SWEP.NoInfoDisplay = true

SWEP.Slot = 0

SWEP.NotForNPCs = true

SWEP.UseHands = true

SWEP.ViewModel = "models/weapons/yurie_cod/iw7/tactical_knife_iw7_vm.mdl"
SWEP.WorldModel = "models/weapons/yurie_cod/iw7/tactical_knife_iw7_wm.mdl"
SWEP.ViewModelFOV = 60

SWEP.PrimaryBash = true
SWEP.CanBash = true
SWEP.MeleeRange = 1
SWEP.MeleeDamageType = DMG_SLASH
SWEP.MeleeDamage = 15
SWEP.MeleeForceDir = Angle(0,60,0)
SWEP.MeleeAttackTime=.1
SWEP.MeleeTime = .5
SWEP.MeleeDelay = .3
SWEP.MeleeSwingSound = JMod_GunHandlingSounds.cloth.loud
SWEP.MeleeHitSound = {"physics/metal/weapon_impact_hard1.wav","physics/metal/weapon_impact_hard2.wav","physics/metal/weapon_impact_hard3.wav"}
SWEP.MeleeHitNPCSound = {"physics/body/body_medium_impact_hard2.wav","physics/body/body_medium_impact_hard3.wav","physics/body/body_medium_impact_hard4.wav","physics/body/body_medium_impact_hard5.wav","physics/body/body_medium_impact_hard6.wav"}
SWEP.MeleeMissSound = "weapons/iceaxe/iceaxe_swing1.wav"
SWEP.MeleeVolume = 65
SWEP.MeleePitch = 1
SWEP.MeleeHitEffect = nil -- "BloodImpact"
SWEP.MeleeHitBullet = true
SWEP.BackHitDmgMult = 1.5
SWEP.MeleeDmgRand = .4
SWEP.MeleeViewMovements = {
	{t = 0, ang = Angle(0,-5,0)},
	{t = .02, ang = Angle(0,30,0)}
}

SWEP.MeleeGesture = ACT_HL2MP_GESTURE_RANGE_ATTACK_KNIFE

SWEP.NotForNPCs = true

SWEP.Firemodes = {
    {
        Mode = 1,
        PrintName = "MELEE"
    },
	{
		Mode = 0,
		PrintName = "SAFE"
	}
}

SWEP.MeleeTime = 0.5

SWEP.HoldtypeHolstered = "normal"
SWEP.HoldtypeActive = "knife"

SWEP.Primary.ClipSize = -1

SWEP.Animations = {
    ["draw"] = {
        Source = "draw",
        Time = 0.5,
        SoundTable = {{s = "weapons/arccw/knife/knife_deploy.wav", t = 0}}
    },
    ["ready"] = {
        Source = "draw",
        Time = 0.5,
    },
    ["bash"] = {
        Source = {"stab", "midslash1", "midslash2", "stab_miss"},
        Time = 0.75,
    },
}

SWEP.IronSightStruct = false

SWEP.BashPreparePos = Vector(0, 0, 0)
SWEP.BashPrepareAng = Angle(0, 5, 0)

SWEP.BashPos = Vector(0, 0, 0)
SWEP.BashAng = Angle(10, -10, 0)

SWEP.HolsterPos = Vector(0, -1, 2)
SWEP.HolsterAng = Angle(-15, 0, 0)

-- overrides cause arctic isn't all he's cracked up to be
-- fuck