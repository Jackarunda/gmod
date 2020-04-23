include('shared.lua')

language.Add("ent_jack_fgcartridgebox_energy","Energy Cartridge Box")

local Pic=surface.GetTextureID("sprites/mat_jack_radsign")

function ENT:Draw()
	self.Entity:DrawModel()
	
	if not(self:GetDTBool(0))then return end
	
	local SelfPos=self:GetPos()
	local SelfAng=self:GetAngles()
	local Up=SelfAng:Up()
	local Forward=SelfAng:Forward()
	
	local LightVec=render.GetLightColor(SelfPos)
	local LightCol=Color(LightVec.x*0,LightVec.y*20,LightVec.z*40,240)
	
	cam.Start3D2D(SelfPos+Up*8.03-Forward*.5,SelfAng,1)
		draw.TexturedQuad({
			texture=Pic,
			color=LightCol,
			x=-1,
			y=3,
			w=3,
			h=3
		})
	cam.End3D2D()
	
	SelfAng:RotateAroundAxis(Up,180)
	
	cam.Start3D2D(SelfPos+Up*8.03+Forward*.5,SelfAng,1)
		draw.TexturedQuad({
			texture=Pic,
			color=LightCol,
			x=-1,
			y=3,
			w=3,
			h=3
		})
	cam.End3D2D()
end