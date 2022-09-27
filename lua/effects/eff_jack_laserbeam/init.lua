local Beamtwo = CreateMaterial("xeno/beamgauss", "UnlitGeneric", {
	["$basetexture"] = "sprites/spotlight",
	["$additive"] = "1",
	["$vertexcolor"] = "1",
	["$vertexalpha"] = "1",
})

local LaserBeam = Material("trails/laser")
local LaserHitPic = Material("sprites/mat_jack_glowything")

function EFFECT:Init(data)
	self.StartPos = data:GetStart()
	self.EndPos = data:GetOrigin()
	self.Scayul = data:GetScale() ^ 0.5
	self.Normal = data:GetNormal()
	self.Delay = math.Clamp(0.01 * data:GetScale(), 0.025, 0.06)
	self.EndTime = CurTime() + self.Delay
	self.Entity:SetRenderBoundsWS(self.StartPos, self.EndPos)
	local dlightend = DynamicLight(self:EntIndex())
	dlightend.Pos = self.EndPos
	dlightend.Size = 300 * self.Scayul
	dlightend.Decay = 2000
	dlightend.R = 175
	dlightend.G = 50
	dlightend.B = 40
	dlightend.Brightness = 1 * self.Scayul
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
	render.SetMaterial(Beamtwo)
	render.DrawBeam(self.StartPos, self.EndPos, Lerp((self.EndTime - CurTime()) / self.Delay, 0, 1 * self.Scayul), 0, 0, Color(255, 100, 80, 7))
	render.DrawBeam(self.StartPos, self.EndPos, Lerp((self.EndTime - CurTime()) / self.Delay, 0, .5 * self.Scayul), 0, 0, Color(255, 255, 255, 13))
end
