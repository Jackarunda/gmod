att.PrintName = "EZ Low-Mag Scope"
att.Icon = Material("entities/acwatt_optic_magnus.png")
att.Description = "eat shit and die commie"

att.SortOrder = 4.5

att.Desc_Pros = {
    "+ Precision sight picture",
    "+ Zoom",
}
att.Desc_Cons = {
    "- Visible scope glint",
}
att.AutoStats = true
att.Slot = "optic_ez"

att.Model = "models/weapons/arccw/atts/magnus.mdl"

att.AdditionalSights = {
    {
        Pos = Vector(0, 15, -1.489),
        Ang = Angle(0, 0, -1),
        Magnification = 1.2, -- this is how much your eyes zoom into the scope, not scope magnification
        ScrollFunc = ArcCW.SCROLL_NONE,
        IgnoreExtra = true
    }
}

att.ScopeGlint = false -- lmao

att.Holosight = true
att.HolosightReticle = Material("hud/scopes/mildot.png")
att.HolosightNoFlare = true
att.HolosightSize = 17
att.HolosightBone = "holosight"
att.HolosightPiece = "models/weapons/arccw/atts/magnus_hsp.mdl"
att.Colorable = true

att.HolosightMagnification = 3 -- this is the scope magnification
att.HolosightBlackbox = true

att.Mult_SightTime = 1.7