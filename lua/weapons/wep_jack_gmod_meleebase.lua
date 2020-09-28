SWEP.Base = "wep_jack_gmod_gunbase"
SWEP.Spawnable = true -- this obviously has to be set to true
SWEP.Category = "ArcCW - Other" -- edit this if you like
SWEP.AdminOnly = false

SWEP.PrintName = "Knife"
SWEP.Trivia_Class = "Melee Weapon"
SWEP.Trivia_Desc = "Sharp metal blade for stabbing and slashing."
SWEP.Trivia_Manufacturer = "Cold Steel"
SWEP.Trivia_Calibre = "N/A"
SWEP.Trivia_Mechanism = "Sharp Edge"
SWEP.Trivia_Country = "USA"
SWEP.Trivia_Year = 2006

SWEP.Slot = 0

SWEP.NotForNPCs = true

SWEP.UseHands = true

SWEP.ViewModel = "models/weapons/yurie_cod/iw7/tactical_knife_iw7_vm.mdl"
SWEP.WorldModel = "models/weapons/yurie_cod/iw7/tactical_knife_iw7_wm.mdl"
SWEP.ViewModelFOV = 60

SWEP.PrimaryBash = true
SWEP.CanBash = true
SWEP.MeleeDamage = 50
SWEP.MeleeRange = 32
SWEP.MeleeDamageType = DMG_SLASH

SWEP.MeleeDamage = 10
SWEP.MeleeDamageType = DMG_CLUB
SWEP.MeleeAttackTime=.3
SWEP.MeleeCooldown = .8
SWEP.MeleeSwingSound = JMod_GunHandlingSounds.cloth.loud
SWEP.MeleeHitSound = {"physics/metal/weapon_impact_hard1.wav","physics/metal/weapon_impact_hard2.wav","physics/metal/weapon_impact_hard3.wav"}
SWEP.MeleeHitNPCSound = {"physics/body/body_medium_impact_hard2.wav","physics/body/body_medium_impact_hard3.wav","physics/body/body_medium_impact_hard4.wav","physics/body/body_medium_impact_hard5.wav","physics/body/body_medium_impact_hard6.wav"}
SWEP.MeleeMissSound = "weapons/iceaxe/iceaxe_swing1.wav"
SWEP.MeleeVolume = 65
SWEP.MeleePitch = 1
SWEP.MeleeHitEffect = nil -- "BloodImpact"
SWEP.MeleeViewMovements = {
	{t = .05, ang = Angle(-2,-2,0)},
	{t = .35, ang = Angle(10,10,0)}
}

SWEP.MeleeGesture = ACT_HL2MP_GESTURE_RANGE_ATTACK_KNIFE

SWEP.NotForNPCs = true

SWEP.Firemodes = {
    {
        Mode = 1,
        PrintName = "MELEE"
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