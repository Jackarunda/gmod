att.PrintName = "EZ Red Dot Sight"
att.Icon = Material("entities/acwatt_optic_aimpoint.png")
att.Description = "wew lad"

att.SortOrder = 0

att.ModelOffset = Vector(0, 0, -0.2)

att.Desc_Pros = {
    "+ Precision sight picture",
}
att.Desc_Cons = {
}
att.AutoStats = true
att.Slot = "optic_ez"

att.Model = "models/weapons/arccw/atts/mrs.mdl"

att.AdditionalSights = {
    {
        Pos = Vector(0, 6, -1.278),
        Ang = Angle(0, 0, 0),
        Magnification = 1.25,
        ScrollFunc = ArcCW.SCROLL_NONE,
		SwitchToSound = "snds_jack_gmod/ez_weapons/handling/aim1.wav",
		SwitchFromSound = "snds_jack_gmod/ez_weapons/handling/aim_out.wav"
    }
}

att.Holosight = true
att.HolosightReticle = Material("holosights/dot.png")
att.HolosightSize = 0.4
att.HolosightBone = "holosight"

att.Mult_SightTime = .95
att.Mult_SightedSpeedMult = 1.2

att.Colorable = true