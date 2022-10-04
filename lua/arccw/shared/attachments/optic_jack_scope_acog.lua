att.PrintName="EZ Advanced Combat Optical Gunsight"
att.Icon=Material("entities/acwatt_optic_magnus.png")
att.Description="eat shit and die commie"

att.SortOrder=4.5

att.Desc_Pros={
    "aaa"
}
att.Desc_Cons={
}
att.AutoStats=true
att.Slot="ez_optic"

att.Model="models/weapons/arccw/atts/aimpoint.mdl"

att.AdditionalSights={
    {
        Pos=Vector(0, 7, -1.43107*0.75),
        Ang=Angle(0, 0, 0),
        Magnification=1.3,
        ScrollFunc=ArcCW.SCROLL_NONE,
		SwitchToSound="snds_jack_gmod/ez_weapons/handling/aim1.wav",
		SwitchFromSound="snds_jack_gmod/ez_weapons/handling/aim_out.wav"
    }
}

att.ScopeGlint=false -- lmao

att.Holosight=true
att.HolosightReticle=Material("holosights/dot.png")
att.HolosightSize=0.4
att.HolosightBone="holosight"

--[[
att.HolosightMagnification=1.5 -- this is the scope magnification
att.HolosightBlackbox=true

att.Mult_SightTime=1
--]]
att.Mult_SightTime=.6
att.Mult_SightedSpeedMult=1.1

att.Colorable=true