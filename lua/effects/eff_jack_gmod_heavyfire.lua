function EFFECT:Init( data )
	local Pos=data:GetOrigin()
	self.Emitter=ParticleEmitter( Pos )
	local Scayul=1
	self.Scayul=Scayul
	local Vel=data:GetStart()
	local InitialVel=Vel+VectorRand()*math.Rand(0,300)
	if(true)then
		local particle=self.Emitter:Add("mats_jack_gmod_sprites/flamelet"..math.random(1,5),Pos)
		particle:SetVelocity(InitialVel)
		particle:SetAirResistance(100)
		particle:SetGravity(Vector(0,0,200))
		particle:SetDieTime(math.Rand(.6,1))
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(0)
		local Size=math.random(100,200)*Scayul
		particle:SetStartSize(Size/50)
		particle:SetEndSize(Size)
		particle:SetRoll(math.Rand(-2,2))
		particle:SetRollDelta(math.Rand(-2,2))
		particle:SetColor(255,255,255)
		particle:SetLighting(false)
		particle:SetCollide(false)
	end
	if((math.random(1,2)==2)and not(GAMEMODE.Lagging))then
		local particle=self.Emitter:Add(((math.random(1,2)==1) and "effects/thick_smoke")or "effects/thick_smoke2",Pos+Vector(0,0,5))
		particle:SetVelocity(InitialVel+Vector(0,0,150))
		particle:SetAirResistance(100)
		particle:SetGravity(Vector(0,0,300))
		particle:SetDieTime(math.Rand(.5,2))
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(0)
		local Size=math.random(100,200)*Scayul
		particle:SetStartSize(Size/100)
		particle:SetEndSize(Size)
		particle:SetRoll(math.Rand(-2,2))
		particle:SetRollDelta(math.Rand(-2,2))
		particle:SetColor(70,70,70)
		particle:SetLighting(false)
		particle:SetCollide(true)
	end
	if((math.random(1,2)==2)and not(GAMEMODE.Lagging))then
		local particle=self.Emitter:Add("sprites/heatwave",Pos)
		particle:SetVelocity(InitialVel)
		particle:SetAirResistance(200)
		particle:SetGravity(Vector(0,0,100))
		particle:SetDieTime(math.Rand(.5,1))
		particle:SetStartAlpha(40)
		particle:SetEndAlpha(0)
		local Size=math.random(70,140)*Scayul
		particle:SetStartSize(Size/100)
		particle:SetEndSize(Size)
		particle:SetRoll(math.Rand(-2,2))
		particle:SetRollDelta(math.Rand(-2,2))
	end
	self.Emitter:Finish()
end
function EFFECT:Think( )
	return false
end
function EFFECT:Render( )
	--
end
