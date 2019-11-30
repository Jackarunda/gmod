function EFFECT:Init(data)

	local dir=data:GetNormal()*math.Rand(2000,8000)
	
	if(self:WaterLevel()>0)then
	
		local NumParticles=10
		
		local emitter=ParticleEmitter(data:GetOrigin())
		
		for i=0, NumParticles do

			local Pos=(data:GetOrigin())
			if not(data.GetAngle)then return end
			local colorangle=data:GetAngle()
			local red=colorangle.p
			local green=colorangle.y
			local blue=colorangle.r
			local wind=data:GetStart()
				
			local rollparticle=emitter:Add("effects/bubble",Pos+VectorRand()*3)

			if(rollparticle)then
				rollparticle:SetVelocity(Vector(math.Rand(-100,100),math.Rand(-100,100),math.Rand(0,100))+dir)
					
				rollparticle:SetLifeTime(0)
				local life=math.Rand(3,6)
				local begin=CurTime()
				rollparticle:SetDieTime(life)
					
				local shadevariation=math.Rand(-10,10)
				rollparticle:SetColor(math.Clamp(255+shadevariation+math.Rand(-5,5),0,255),math.Clamp(255+shadevariation+math.Rand(-5,5),0,255),math.Clamp(255+shadevariation+math.Rand(-5,5),0,255))			

				rollparticle:SetStartAlpha(255)
				rollparticle:SetEndAlpha(0)
					
				rollparticle:SetStartSize(4)
				rollparticle:SetEndSize(15)
					
				rollparticle:SetRoll(math.Rand(-360, 360))
				rollparticle:SetRollDelta(math.Rand(-0.61, 0.61)*5)
					
				rollparticle:SetAirResistance(500)
					
				rollparticle:SetGravity(Vector(math.Rand(-2000, 2000), math.Rand(-2000, 2000),math.Rand(10000,15000))+wind)

				rollparticle:SetCollide(true)

				rollparticle:SetLighting(false)

			end
		end
		return
	end
	
	local NumParticles=1
	
	local emitter=ParticleEmitter(data:GetOrigin())
	if(emitter)then
		for i=0, NumParticles do

			local Pos=(data:GetOrigin())
			
			local colorangle=data:GetAngles()
			local red=colorangle.p
			local green=colorangle.y
			local blue=colorangle.r
			local wind=Vector(0,0,0)
			
			//these first two particles (rollparticles) are just so it looks like there's thick smoke rolling off of the grenade, instead of smoke particles appearing next to the grenade
			if(emitter)then
				local rollparticle=emitter:Add("sprites/mat_jack_smokeparticle",Pos+VectorRand())

				if(rollparticle)then
					rollparticle:SetVelocity(Vector(math.Rand(-100,100),math.Rand(-100,100),math.Rand(0,100))+dir*math.Rand(0.1,0.5))
					
					rollparticle:SetLifeTime(0)
					local life=math.Rand(0.02,0.07)
					local begin=CurTime()
					rollparticle:SetDieTime(life)
					
					rollparticle:SetColor(255,150,100)
					
					rollparticle:SetStartAlpha(255)
					rollparticle:SetEndAlpha(0)
					
					rollparticle:SetStartSize(5)
					rollparticle:SetEndSize(5)
					
					rollparticle:SetRoll(math.Rand(-360, 360))
					rollparticle:SetRollDelta(math.Rand(-0.61, 0.61)*5)
					
					rollparticle:SetAirResistance(500)
					
					rollparticle:SetGravity(Vector(math.Rand(-2000, 2000), math.Rand(-2000, 2000),math.Rand(3000,5000))+wind)

					rollparticle:SetCollide(false)

					rollparticle:SetLighting(false)
				end
			end
			
			if(emitter)then
				local rollparticle=emitter:Add("sprites/flamelet"..math.random(1,3),Pos+VectorRand()*2)

				if(rollparticle)then
					rollparticle:SetVelocity(Vector(math.Rand(-100,100),math.Rand(-100,100),math.Rand(0,100))+dir*math.Rand(0.1,0.5))
					
					rollparticle:SetLifeTime(0)
					local life=math.Rand(0.02,0.07)
					local begin=CurTime()
					rollparticle:SetDieTime(life)
					
					rollparticle:SetColor(255,255,255)
					
					rollparticle:SetStartAlpha(255)
					rollparticle:SetEndAlpha(0)
					
					rollparticle:SetStartSize(5)
					rollparticle:SetEndSize(5)
					
					rollparticle:SetRoll(math.Rand(-360, 360))
					rollparticle:SetRollDelta(math.Rand(-0.61, 0.61)*5)
					
					rollparticle:SetAirResistance(500)
					
					rollparticle:SetGravity(Vector(math.Rand(-1000, 1000), math.Rand(-1000, 1000),math.Rand(1500,2500))+wind)

					rollparticle:SetCollide(false)

					rollparticle:SetLighting(false)
				end
			end
		
			if(emitter)then
				local particle=emitter:Add("particle/smokestack", Pos) --particles/smokey is a nice volumetric smoke sprite

				if(particle)then
					particle:SetVelocity(Vector(math.Rand(-50,50),math.Rand(-50,50),math.Rand(-50,50))+dir)
					
					particle:SetLifeTime(0)
					local life=math.Rand(1,2.5)
					local begin=CurTime()
					particle:SetDieTime(life)
					
					local shadevariation=math.Rand(-20,20)
					particle:SetColor(math.Clamp(red+shadevariation+math.Rand(-5,5),0,255),math.Clamp(green+shadevariation+math.Rand(-5,5),0,255),math.Clamp(blue+shadevariation+math.Rand(-5,5),0,255))			

					particle:SetStartAlpha(255)
					particle:SetEndAlpha(0)
					
					particle:SetStartSize(5)
					particle:SetEndSize(100)
					
					particle:SetRoll(math.Rand(-360, 260)) --if using the nice particle, set this to something small and remove the RollDelta
					particle:SetRollDelta(math.Rand(-0.61, 0.61))
					
					particle:SetAirResistance(500)
					
					particle:SetGravity(Vector(math.Rand(-1000, 1000), math.Rand(-1000, 1000),math.Rand(1000,2000))+wind)

					particle:SetCollide(false)

					particle:SetLighting(true)
					
					particle:SetCollideCallback(function(pertical,hitpos,hitnorm)
						pertical:SetLifeTime(CurTime()+0.1)
						pertical:SetDieTime(CurTime()+0.1)
						if(emitter)then
							local porticel=emitter:Add("particle/smokestack",pertical:GetPos()) --particles/smokey is a nice volumetric smoke sprite

							if(porticel)then
								
								local newvector=hitnorm
								newvector:Rotate(Angle(90,math.Rand(0,360),90))
								newvector:Normalize()
								newvector=newvector*math.Rand(0.5,1.5)
								if(newvector.z<0)then newvector=Vector(newvector.x,newvector.y,math.abs(newvector.z)) end
								
								porticel:SetVelocity(newvector*300)
								
								porticel:SetLifeTime(0)
								local timelived=CurTime()-begin
								local lifeleft=life-timelived
								porticel:SetDieTime(lifeleft)
								local lifeleftfraction=lifeleft/life

								porticel:SetColor(pertical:GetColor())			

								porticel:SetStartAlpha(lifeleftfraction*255)
								if(lifeleftfraction>0.9)then  porticel:SetStartAlpha(175) end --the particle probably hit the ground instantly as a result of being emitted from the grenade downwards while the grenade was sitting on the ground
								porticel:SetEndAlpha(0)
								
								porticel:SetStartSize((1-lifeleftfraction)*60)
								if(lifeleftfraction>0.9)then porticel:SetStartSize(20) end
								porticel:SetEndSize(60)
								
								porticel:SetRoll(math.Rand(-360, 360))
								porticel:SetRollDelta(math.Rand(-0.61, 0.61))
								
								porticel:SetAirResistance(30)
								
								porticel:SetGravity(Vector(0,0,0))

								porticel:SetCollide(true)

								porticel:SetLighting(true)
								
								timer.Simple(0.01,function()
									if not(porticel)then return end
									local trase=util.QuickTrace(porticel:GetPos(),Vector(0,0,1),porticel)
									if not(trase.Hit)then
										porticel:SetGravity(Vector(math.Rand(-20, 20), math.Rand(-20, 20),math.Rand(70,90)))
									end
								end)
								
								timer.Simple(lifeleft/3.2,function()
									if not(porticel)then return end
									local trase=util.QuickTrace(porticel:GetPos(),Vector(0,0,1),porticel)
									if not(trase.Hit)then
										porticel:SetGravity(Vector(math.Rand(-20, 20), math.Rand(-20, 20),math.Rand(70,90)))
									end
								end)
							end
						end
					end)
				end
			end
		end
		
	emitter:Finish()
	end
end

function EFFECT:Think()

	return false
end

function EFFECT:Render()
end