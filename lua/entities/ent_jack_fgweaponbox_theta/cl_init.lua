include('shared.lua')

language.Add("ent_jack_fgweaponbox_theta","Weapon Box")

local Letter=surface.GetTextureID("sprites/mat_jack_theta_lowercase")

function ENT:Initialize()
	util.PrecacheSound("snd_jack_boxopen.wav")
	
	util.PrecacheModel("models/weapons/v_halo_jeagle.mdl")
	util.PrecacheModel("models/weapons/w_pistol.mdl")
	util.PrecacheModel("models/mass_effect_3/weapons/smgs/m-9 jempest.mdl")
	util.PrecacheModel("models/mass_effect_3/weapons/misc/jhermal clip.mdl")
	util.PrecacheModel("models/mass_effect_3/weapons/misc/jeatsink.mdl")
	util.PrecacheModel("models/hunter/blocks/cube025x125x025.mdl")
	util.PrecacheModel("models/Items/AR2_Grenade.mdl")
	
	util.PrecacheSound("snd_jack_highchargeloop.wav")
	util.PrecacheSound("snd_jack_arcgunwarn.wav")
	util.PrecacheSound("snd_jack_fgpistoldraw.wav")
	util.PrecacheSound("snd_jack_smallcharge.wav")
	util.PrecacheSound("snd_jack_railgunchargebegin.wav")
	util.PrecacheSound("snd_jack_railgunfire.wav")
	util.PrecacheSound("snd_jack_displaysoff.wav")
	util.PrecacheSound("snd_jack_displayson.wav")
	util.PrecacheSound("snd_jack_railgunchamber.wav")
	util.PrecacheSound("snd_jack_railgunvent.wav")
	util.PrecacheSound("snd_jack_massload.wav")
	util.PrecacheSound("snd_jack_load_iron.wav")
	util.PrecacheSound("snd_jack_raiilgunreload.wav")
	util.PrecacheSound("snd_jack_nuclearfgc_start.wav")
	util.PrecacheSound("snd_jack_nuclearfgc_end.wav")
end

function ENT:Draw()
	self.Entity:DrawModel()
	
	if not(self:GetDTBool(0))then return end
	
	local SelfPos=self:GetPos()
	local SelfAng=self:GetAngles()
	local Up=SelfAng:Up()
	
	local LightVec=render.GetLightColor(SelfPos)
	local LightCol=Color(LightVec.x*0,LightVec.y*20,LightVec.z*40,240)
	
	cam.Start3D2D(SelfPos+Up*12.1,SelfAng,1)
		draw.TexturedQuad({
			texture=Letter,
			color=LightCol,
			x=-2,
			y=5,
			w=4,
			h=4
		})
	cam.End3D2D()
	
	SelfAng:RotateAroundAxis(Up,180)
	
	cam.Start3D2D(SelfPos+Up*12.1,SelfAng,1)
		draw.TexturedQuad({
			texture=Letter,
			color=LightCol,
			x=-2,
			y=5,
			w=4,
			h=4
		})
	cam.End3D2D()
end