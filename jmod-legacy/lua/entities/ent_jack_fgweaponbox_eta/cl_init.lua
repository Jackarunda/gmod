include('shared.lua')

language.Add("ent_jack_fgweaponbox_eta","Weapon Box")

local Letter=surface.GetTextureID("sprites/mat_jack_eta_lowercase")

function ENT:Initialize()
	util.PrecacheSound("snd_jack_boxopen.wav")
	
	util.PrecacheModel("models/weapons/v_halo_jeagle.mdl")
	util.PrecacheModel("models/weapons/w_pistol.mdl")
	util.PrecacheModel("models/mass_effect_3/weapons/pistols/n7 eajle.mdl")
	util.PrecacheModel("models/mass_effect_3/weapons/misc/jhermal clip.mdl")
	util.PrecacheModel("models/Items/combine_rifle_ammo01.mdl")
	util.PrecacheModel("models/Items/AR2_Grenade.mdl")

	util.PrecacheSound("snd_jack_fgpistoldraw.wav")
	util.PrecacheSound("snd_jack_smallcharge.wav")
	util.PrecacheSound("snd_jack_pilereload.wav")
	util.PrecacheSound("snd_jack_pilefire.wav")
	util.PrecacheSound("snd_jack_displaysoff.wav")
	util.PrecacheSound("snd_jack_displayson.wav")
	util.PrecacheSound("snd_jack_pileresonate_loud.wav")
	util.PrecacheSound("snd_jack_pileresonate_quiet.wav")
	util.PrecacheSound("snd_jack_laserreload.wav")
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