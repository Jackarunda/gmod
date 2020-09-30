SWEP.Base = "wep_jack_gmod_meleebase"
SWEP.Spawnable = false

SWEP.PrintName = "Pocket Knife"

SWEP.Slot = 0

SWEP.ViewModel = "models/weapons/yurie_cod/iw7/tactical_knife_iw7_vm.mdl"
SWEP.WorldModel = "models/weapons/yurie_cod/iw7/tactical_knife_iw7_wm.mdl"
SWEP.ViewModelFOV = 65
SWEP.MeleeRange = 1

SWEP.Firemodes = {
	{
		Mode = 1,
		PrintName = "MELEE"
	}
}

SWEP.MeleeTime = 0.5

SWEP.HoldtypeHolstered = "normal"
SWEP.HoldtypeActive = "knife"

--[[
vm_knifeonly_drop
vm_knifeonly_idle
vm_knifeonly_raise
vm_knifeonly_sprint_in
vm_knifeonly_sprint_loop
vm_knifeonly_sprint_out
vm_knifeonly_swipe
--]]
SWEP.Animations = {
	["draw"] = {
		Source = "vm_knifeonly_raise",
		Time = .8,
		SoundTable = {{s = "snds_jack_gmod/ez_weapons/knives/draw", t = 0}}
	},
	["ready"] = {
		Source = "vm_knifeonly_raise",
		Time = 1,
	},
	["idle"] = {
		Source = "vm_knifeonly_idle",
		Time = 10,
	},
	["bash"] = {
		Source = "vm_knifeonly_swipe",
		Time = 0.7,
	}
}

SWEP.IronSightStruct = false

SWEP.BashPreparePos = Vector(0, 0, 0)
SWEP.BashPrepareAng = Angle(0, 5, 0)

SWEP.BashPos = Vector(0, 0, 0)
SWEP.BashAng = Angle(10, -10, 0)

SWEP.HolsterPos = Vector(0, 0, 0)
SWEP.HolsterAng = Angle(-30, 0, 0)