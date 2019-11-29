//i know this effect is very poorly organized and disjointed looking. This is because the original person who wrote it did it like shit, and i was too lazy to blank and rewrite everything

local matRefraction	= Material( "refract_ring" )

local tMats={}

tMats.Glow1=Material("sprites/light_glow02")
--tMats.Glow1=Material("models/roller/rollermine_glow")
tMats.Glow2=Material("sprites/yellowflare")
tMats.Glow3=Material("sprites/redglow2")

for _,mat in pairs(tMats) do

	mat:SetInt("$spriterendermode",9)
	mat:SetInt("$ignorez",1)
	mat:SetInt("$illumfactor",8)

end

/*---------------------------------------------------------
   Init( data table )
---------------------------------------------------------*/
function EFFECT:Init( data )

	self.Position=data:GetOrigin()
	self.Position.z=self.Position.z+4
	self.TimeLeft=CurTime()+1
	self.GAlpha=254
	self.DerpAlpha=254
	self.GSize=200
	self.CloudHeight =1*2.5
	
	self.Refract=0
	self.Size=48
	if render.GetDXLevel()<=81 then
		matRefraction=Material( "effects/strider_pinch_dudv" )
	end
	
	self.SplodeDist=2000
	self.BlastSpeed=6000
	self.lastThink=0
	self.MinSplodeTime=CurTime()+self.CloudHeight/self.BlastSpeed
	self.MaxSplodeTime=CurTime()+6
	self.GroundPos=self.Position - Vector(0,0,self.CloudHeight)
	
	local Pos=self.Position

	self.smokeparticles={}
	self.Emitter=ParticleEmitter( Pos )

	local spawnpos=Pos
	
	local Scayul=data:GetScale()
	self.Scayul=Scayul
	
	local AddVel=data:GetStart()

	for k=0,20*Scayul do
		
		for i=0,15 do
			local sprite
			local chance=math.random(1,6)
			if(chance==1)then
				sprite="particle/smokestack"
			elseif(chance==2)then
				sprite="particles/smokey"
			elseif(chance==3)then
				sprite="particle/particle_smokegrenade"
			elseif(chance==4)then
				sprite="sprites/Smoke1"
			elseif(chance==5)then
				sprite="sprites/Smoke2"
			elseif(chance==6)then
				sprite="sprites/Smoke3"
			end
			local particle=self.Emitter:Add(sprite,Pos+Vector(0,0,math.Rand(0,60)))
			particle:SetVelocity(VectorRand()*math.Rand(20,1500)*Scayul)
			particle:SetAirResistance(200)
			particle:SetGravity(VectorRand()*math.Rand(0,200))
			particle:SetDieTime(math.Rand(1,5)*0.4)
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(0)
			particle:SetStartSize(5)
			particle:SetEndSize(math.Rand(200,400)*Scayul)
			particle:SetRoll(0)
			particle:SetRollDelta(math.Rand(-3,3))
			particle:SetLighting(true)
			particle:SetCollide(true)
			particle:SetColor(0,0,0)
		end
	end
	
	for i=0,50 do
		local particle=self.Emitter:Add("sprites/heatwave", Pos)
		particle:SetVelocity(VectorRand()*math.Rand(100,1000)*Scayul)
		particle:SetAirResistance(100)
		particle:SetGravity(VectorRand()*math.Rand(-200,200))
		particle:SetDieTime(math.Rand(0.5,3)*0.4)
		particle:SetStartAlpha(40)
		particle:SetEndAlpha(0)
		particle:SetStartSize(200*Scayul)
		particle:SetEndSize(300*Scayul)
		particle:SetRoll(math.Rand(0,10))
		particle:SetRollDelta(6000)
	end
	
	for k=0,300 do
		local particle=self.Emitter:Add("sprites/jackconfetti", Pos)
		if(particle)then
			particle:SetVelocity(VectorRand()*math.Rand(500, 2000)+Vector(0,0,math.Rand(300,500))*Scayul)
			particle:SetLifeTime(0)
			particle:SetDieTime(math.Rand(4,8))
			particle:SetColor(math.Rand(0,255),math.Rand(0,255),math.Rand(0,255))
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(255)
			particle:SetStartSize(1)
			particle:SetEndSize(1)
			particle:SetRoll(math.Rand(-360, 360))
			particle:SetRollDelta(math.Rand(-0.21, 0.21))
			particle:SetAirResistance(200)
			particle:SetGravity(Vector(math.Rand(-1000, 1000), math.Rand(-1000, 1000), math.Rand(0, -1500)))
			particle:SetCollide(true)
			particle:SetBounce(0.1)
			//particle:SetLighting(1)					  --i want them to be pretty, even though i know that no lighting is unrealistic. With lightin, theyre just so dim -_-
		end
	end
end

/*---------------------------------------------------------
   THINK
---------------------------------------------------------*/
function EFFECT:Think( )

end

/*---------------------------------------------------------
   Draw the effect
---------------------------------------------------------*/
function EFFECT:Render( )


end
