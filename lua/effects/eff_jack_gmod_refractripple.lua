﻿local Spark = Material("sprites/mat_jack_nicespark")

function EFFECT:Init(data)
	self.Scale = data:GetScale()
	self.Pos = data:GetOrigin()
	self.LifeTime = .5
	self.DieTime = CurTime() + self.LifeTime
	self.Size = .1
	self.Normal = data:GetNormal()
	self.Mat = Material("sprites/mat_jack_refractripple")
	self.RefractAmt = 2
	self.Mat:SetFloat("$refractamount", self.RefractAmt)
	---
	--[[
	local emitter = ParticleEmitter(self.Pos)

	for i = 1, 2 do
		local Sprite = table.Random({"effects/splash1", "effects/splash2", "effects/splash4"})
		local particle = emitter:Add(Sprite, self.Pos)
		particle:SetVelocity(VectorRand() * math.Rand(0, 30) * self.Scale + Vector(0, 0, math.Rand(20, 40) * self.Scale))
		particle:SetCollide(false)
		particle:SetLighting(false)
		particle:SetBounce(.01)
		particle:SetGravity(Vector(0, 0, -600))
		particle:SetAirResistance(10)
		particle:SetDieTime(math.Rand(.2, .4) * self.Scale)
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(0)
		particle:SetStartSize(10)
		particle:SetEndSize(10)
		particle:SetRoll(math.Rand(180, 480))
		particle:SetRollDelta(math.Rand(-1, 1) * 6)
		particle:SetColor(255, 255, 255)
	end

	emitter:Finish()
	--]]
end

function EFFECT:Think()
	if self.DieTime > CurTime() then
		local FT = FrameTime()
		self.Size = self.Size + 200 * FT
		self.RefractAmt = math.Clamp(self.RefractAmt - FT * 8, .01, 2)
		self.Mat:SetFloat("$refractamount", self.RefractAmt)
		self:NextThink(CurTime() + .05)
		return true
	else
		return false
	end
end

function EFFECT:Render()
	local Time = CurTime()
	local Frac = ((self.DieTime - Time) / self.LifeTime) ^ 3
	render.SetMaterial(Spark)
	render.DrawSprite(self.Pos + self.Normal, 10 * Frac, 10 * Frac, color_white)
	render.SetMaterial(self.Mat)
	render.DrawQuadEasy(self.Pos + self.Normal, self.Normal, self.Size * self.Scale, self.Size * self.Scale, color_white)
	return
end
