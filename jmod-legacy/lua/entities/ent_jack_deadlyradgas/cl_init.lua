include('shared.lua')

local Glow=Material("sprites/mat_jack_glowything")

//language.Add("ent_jack_deadlyradgas", "Radioactive Poisonous Gas")

//killicon.Add("ent_jack_deadlyradgas","vgui/mat_jack_deadlyradgas_ki",Color(255,255,255,255))

function ENT:Initialize()
	self.Age=1
end

function ENT:Draw()
	local SelfPos=self:GetPos()

	local Size=100

	render.SetMaterial(Glow)
	render.DrawSprite(SelfPos,Size,Size,Color(150,190,255,255))
	
	//self.Entity:DrawModel()
end

function ENT:Think()
	//do nothing
end