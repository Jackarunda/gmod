function EFFECT:Init(data)
	local NumParticles=3000
	local emitter=ParticleEmitter(data:GetOrigin())
		
	emitter:Finish()
end
function EFFECT:Think()
	return false
end
function EFFECT:Render()
end