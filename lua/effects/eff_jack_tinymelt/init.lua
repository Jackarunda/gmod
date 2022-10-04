local Mat = Material("sprites/flamelet1")

function EFFECT:Init(data)
	local SelfPos = data:GetOrigin()
	local Follow = Vector(0, 0, 0)

	if data:GetStart() then
		Follow = data:GetStart()
	end

	local Scayul = data:GetScale()
	local SelfNorm = data:GetNormal()

	if self:WaterLevel() == 3 then
		local Splach = EffectData()
		Splach:SetOrigin(SelfPos)
		Splach:SetNormal(Vector(0, 0, 1))
		Splach:SetScale(5)
		util.Effect("WaterSplash", Splach)

		return
	end

	if math.random(1, 3) == 1 then
		local effectdata = EffectData()
		effectdata:SetOrigin(SelfPos)
		effectdata:SetNormal(SelfNorm)
		effectdata:SetMagnitude(.5 * Scayul) --amount and shoot hardness
		effectdata:SetScale(1 * Scayul) --length of strands
		effectdata:SetRadius(1 * Scayul) --thickness of strands
		util.Effect("Sparks", effectdata, true, true)
	end

	local Emitter = ParticleEmitter(SelfPos)
	Emitter:Finish()
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
