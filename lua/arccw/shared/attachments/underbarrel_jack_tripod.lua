att.PrintName = "EZ Tripod"
att.Icon = Material("entities/acwatt_bipod.png")
att.Description = "More stability for bigger guns"
att.SortOrder = 10

att.Desc_Pros = {"+ Tripod",}

att.Desc_Cons = {}
att.AutoStats = true
att.Slot = "ez_tripod"
att.LHIK = true
att.LHIK_Animation = true
att.MountPositionOverride = 1
att.Model = "models/weapons/arccw/atts/bipod.mdl"
att.Bipod = true
att.Mult_BipodRecoil = .5
att.Mult_BipodDispersion = .5
att.Mult_SightTime = 1.1
att.Mult_HipDispersion = 1
att.Mult_SpeedMult = 0.9

att.Hook_LHIK_TranslateAnimation = function(wep, anim)
	if anim == "idle" or anim == "in" or anim == "out" then
		if wep:InBipod() then
			return "idle_bipod"
		else
			return "idle"
		end
	end
end

att.Hook_Compatible = function(wep)
	if wep.Bipod_Integral then return false end
end
