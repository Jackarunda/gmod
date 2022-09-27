local Beamtwo = CreateMaterial("xeno/beamgauss", "UnlitGeneric", {
	["$basetexture"] = "sprites/spotlight",
	["$additive"] = "1",
	["$vertexcolor"] = "1",
	["$vertexalpha"] = "1",
})

local LaserBeam = Material("trails/laser")
local LaserHitPic = Material("sprites/mat_jack_glowything")

function EFFECT:Init(data)
	self.StartPos = data:GetOrigin()
	self.EndPos = data:GetOrigin()
	self.Scayul = data:GetScale() ^ 0.5
	self.Normal = data:GetNormal()
	self.Delay = math.Clamp(0.01 * data:GetScale(), 0.025, 0.06)
	self.EndTime = CurTime() + self.Delay
	self.Entity:SetRenderBoundsWS(self.StartPos, self.EndPos)
	local dlightend = DynamicLight(0)
	dlightend.Pos = self.EndPos
	dlightend.Size = 200 * self.Scayul
	dlightend.Decay = 2000
	dlightend.R = 175
	dlightend.G = 50
	dlightend.B = 40
	dlightend.Brightness = .75 * self.Scayul
	dlightend.DieTime = CurTime() + self.Delay
end

function EFFECT:Think()
	if self.EndTime < CurTime() then
		return false
	else
		return true
	end
end

function EFFECT:Render()
	local Flicker = math.Rand(.9, 1.1)
	self.Entity:SetRenderBoundsWS(self.StartPos, self.EndPos)
	render.SetMaterial(LaserHitPic)
	render.DrawSprite(self.EndPos + self.Normal, 10 * Flicker, 10 * Flicker, Color(255, 255, 255, 175))
	render.DrawSprite(self.EndPos + self.Normal, 30 * Flicker, 30 * Flicker, Color(255, 100, 100, 100))
	render.DrawQuadEasy(self.EndPos + self.Normal * 0.5, self.Normal, 8 * Flicker, 8 * Flicker, Color(255, 255, 255, 200))
	render.DrawQuadEasy(self.EndPos + self.Normal * 0.5, self.Normal, 25 * Flicker, 25 * Flicker, Color(255, 100, 100, 160))
end
