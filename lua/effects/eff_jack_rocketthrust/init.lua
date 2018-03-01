function EFFECT:Init(data)
	local Scayul=1
	if(data:GetScale())then
		Scayul=data:GetScale()
	end
	local dirkshun=data:GetNormal()*1000*Scayul
	if(self:WaterLevel()>0)then
		local NumParticles=10
		local emitter=ParticleEmitter(data:GetOrigin())
		for i=0,NumParticles do
			local Pos = (data:GetOrigin())
			local colorangle=Angle(255,255,255)
			local red=colorangle.p
			local green=colorangle.y
			local blue=colorangle.r
			local wind=data:GetStart()
			local rollparticle = emitter:Add("effects/bubble",Pos+VectorRand()*3)
			if (rollparticle) then
				rollparticle:SetVelocity(Vector(math.Rand(-10,10),math.Rand(-10,10),math.Rand(-10,10))+dirkshun)
				rollparticle:SetLifeTime(0)
				local life=math.Rand(1,2)
				local begin=CurTime()
				rollparticle:SetDieTime(life)
				local shadevariation=math.Rand(-10,10)
				rollparticle:SetColor(math.Clamp(255+shadevariation+math.Rand(-5,5),0,255),math.Clamp(255+shadevariation+math.Rand(-5,5),0,255),math.Clamp(255+shadevariation+math.Rand(-5,5),0,255))
				rollparticle:SetStartAlpha(200)
				rollparticle:SetEndAlpha(0)
				rollparticle:SetStartSize(4)
				rollparticle:SetEndSize(15)
				rollparticle:SetRoll(math.Rand(-360,360))
				rollparticle:SetRollDelta(math.Rand(-0.61,0.61)*5)
				rollparticle:SetAirResistance(1000)
				rollparticle:SetGravity(Vector(math.Rand(-500,500), math.Rand(-500,500),math.Rand(2000,5000))+wind)
				rollparticle:SetCollide(true)
				rollparticle:SetLighting(false)
			end
		end
		return
	end
	local NumParticles = 1*Scayul
	local emitter = ParticleEmitter(data:GetOrigin())
	
		for i = 0, NumParticles do


			local Pos = (data:GetOrigin())
				
			local culur=math.random(175,255)
			local colorangle=Angle(culur,culur,culur)
			local red=colorangle.p
			local green=colorangle.y
			local blue=colorangle.r
			local wind=VectorRand()
				
			//these first two particles (rollparticles) are just so it looks like there's thick smoke rolling off of the grenade, instead of smoke particles appearing next to the grenade
				
			local rollparticle = emitter:Add("particles/flamelet"..math.random(1,5),Pos+VectorRand())

			if (rollparticle) then
				rollparticle:SetVelocity(VectorRand()*math.Rand(0,100)+dirkshun)
					
				rollparticle:SetLifeTime(0)
				local life=math.Rand(0.05,0.1)
				local begin=CurTime()
				rollparticle:SetDieTime(life)
					
				local shadevariation=math.Rand(-10,10)
				rollparticle:SetColor(255,255,255)			

				rollparticle:SetStartAlpha(255)
				rollparticle:SetEndAlpha(0)
					
				rollparticle:SetStartSize(2*Scayul)
				rollparticle:SetEndSize(10*Scayul)
					
				rollparticle:SetRoll(math.Rand(-360, 360))
				rollparticle:SetRollDelta(math.Rand(-0.61, 0.61)*5)
					
				rollparticle:SetAirResistance(600)
					
				rollparticle:SetGravity(Vector(math.Rand(-500, 500), math.Rand(-500, 500),math.Rand(2000,3000))+wind)

				rollparticle:SetCollide(false)

				rollparticle:SetLighting(false)
			end
			
			local sprite
			local chance=math.random(1,6)
			if(chance==1)then
				sprite="particle/smokestack"
			elseif(chance==2)then
				sprite="particles/smokey"
			elseif(chance==3)then
				sprite="particle/particle_smokegrenade"
			elseif(chance==4)then
				sprite="sprites/mat_jack_smoke1"
			elseif(chance==5)then
				sprite="sprites/mat_jack_smoke2"
			elseif(chance==6)then
				sprite="sprites/mat_jack_smoke3"
			end
		
			local particle = emitter:Add(sprite, Pos+data:GetNormal()*30) --particles/smokey is a nice volumetric smoke sprite

			if (particle) then
				particle:SetVelocity(VectorRand()*math.Rand(0,100)+dirkshun)
				
				particle:SetLifeTime(0)
				local life=math.Rand(0.5,1)*Scayul^0.5
				local begin=CurTime()
				particle:SetDieTime(life)
				
				local shadevariation=math.Rand(-20,20)
				particle:SetColor(math.Clamp(red+shadevariation+math.Rand(-5,5),0,255),math.Clamp(green+shadevariation+math.Rand(-5,5),0,255),math.Clamp(blue+shadevariation+math.Rand(-5,5),0,255))			

				particle:SetStartAlpha(150)
				particle:SetEndAlpha(0)
				
				particle:SetStartSize(2*Scayul)
				particle:SetEndSize(60*Scayul)
				
				particle:SetRoll(math.Rand(-360, 260)) --if using the nice particle, set this to something small and remove the RollDelta
				particle:SetRollDelta(math.Rand(-0.61, 0.61))
				
				particle:SetAirResistance(300)
				
				particle:SetGravity(Vector(math.Rand(-500, 500), math.Rand(-500, 500),math.Rand(1000,2000))+wind)

				particle:SetCollide(true)

				particle:SetLighting(true)
				
				particle:SetCollideCallback(function(pertical,hitpos,hitnorm)
					pertical:SetLifeTime(CurTime()+0.1)
					pertical:SetDieTime(CurTime()+0.1)
					if(IsValid(emitter))then
						local porticel = emitter:Add("particle/smokestack",pertical:GetPos()) --particles/smokey is a nice volumetric smoke sprite

						if (porticel) then
							
							local newvector=hitnorm
							newvector:Rotate(Angle(90,math.Rand(0,360),90))
							newvector:Normalize()
							newvector=newvector*math.Rand(0.5,1.5)
							if(newvector.z<0)then newvector=Vector(newvector.x,newvector.y,math.abs(newvector.z)) end
							
							porticel:SetVelocity(newvector*180)
							
							porticel:SetLifeTime(0)
							local timelived=CurTime()-begin
							local lifeleft=life-timelived
							porticel:SetDieTime(lifeleft)
							local lifeleftfraction=lifeleft/life

							porticel:SetColor(pertical:GetColor())			

							porticel:SetStartAlpha(lifeleftfraction*200)
							if(lifeleftfraction>0.9)then  porticel:SetStartAlpha(175) end --the particle probably hit the ground instantly as a result of being emitted from the grenade downwards while the grenade was sitting on the ground
							porticel:SetEndAlpha(0)
							
							porticel:SetStartSize((1-lifeleftfraction)*60)
							if(lifeleftfraction>0.9)then porticel:SetStartSize(20) end
							porticel:SetEndSize(60*Scayul)
							
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
		
	emitter:Finish()
	
	--[[
	timer.Simple(0.005,function()
		local NumParticles = 1
		
		local emitter = ParticleEmitter(data:GetOrigin())
		
			for i = 0, NumParticles*Scayul do


				local Pos = (data:GetOrigin())
					
				local culur=math.random(175,255)
				local colorangle=Angle(culur,culur,culur)
				local red=colorangle.p
				local green=colorangle.y
				local blue=colorangle.r
				local wind=VectorRand()
					
				//these first two particles (rollparticles) are just so it looks like there's thick smoke rolling off of the grenade, instead of smoke particles appearing next to the grenade
					
				local rollparticle = emitter:Add("particles/flamelet"..math.random(1,5),Pos+VectorRand())

				if (rollparticle) then
					rollparticle:SetVelocity(VectorRand()*math.Rand(0,100)+dirkshun)
						
					rollparticle:SetLifeTime(0)
					local life=math.Rand(0.05,0.1)
					local begin=CurTime()
					rollparticle:SetDieTime(life)
						
					local shadevariation=math.Rand(-10,10)
					rollparticle:SetColor(255,255,255)			

					rollparticle:SetStartAlpha(255)
					rollparticle:SetEndAlpha(0)
						
					rollparticle:SetStartSize(5*Scayul)
					rollparticle:SetEndSize(10*Scayul)
						
					rollparticle:SetRoll(math.Rand(-360, 360))
					rollparticle:SetRollDelta(math.Rand(-0.61, 0.61)*5)
						
					rollparticle:SetAirResistance(600)
						
					rollparticle:SetGravity(Vector(math.Rand(-500, 500), math.Rand(-500, 500),math.Rand(2000,3000))+wind)

					rollparticle:SetCollide(false)

					rollparticle:SetLighting(false)
				end
				
				local sprite
				local chance=math.random(1,6)
				if(chance==1)then
					sprite="particle/smokestack"
				elseif(chance==2)then
					sprite="particles/smokey"
				elseif(chance==3)then
					sprite="particle/particle_smokegrenade"
				elseif(chance==4)then
					sprite="sprites/mat_jack_smoke1"
				elseif(chance==5)then
					sprite="sprites/mat_jack_smoke2"
				elseif(chance==6)then
					sprite="sprites/mat_jack_smoke3"
				end
			
				local particle = emitter:Add(sprite, Pos+data:GetNormal()*30) --particles/smokey is a nice volumetric smoke sprite

				if (particle) then
					particle:SetVelocity(VectorRand()*math.Rand(0,100)+dirkshun)
					
					particle:SetLifeTime(0)
					local life=math.Rand(0.5,1)*Scayul^0.5
					local begin=CurTime()
					particle:SetDieTime(life)
					
					local shadevariation=math.Rand(-20,20)
					particle:SetColor(math.Clamp(red+shadevariation+math.Rand(-5,5),0,255),math.Clamp(green+shadevariation+math.Rand(-5,5),0,255),math.Clamp(blue+shadevariation+math.Rand(-5,5),0,255))			

					particle:SetStartAlpha(150)
					particle:SetEndAlpha(0)
					
					particle:SetStartSize(5*Scayul)
					particle:SetEndSize(60*Scayul)
					
					particle:SetRoll(math.Rand(-360, 260)) --if using the nice particle, set this to something small and remove the RollDelta
					particle:SetRollDelta(math.Rand(-0.61, 0.61))
					
					particle:SetAirResistance(300)
					
					particle:SetGravity(Vector(math.Rand(-500, 500), math.Rand(-500, 500),math.Rand(1000,2000))+wind)

					particle:SetCollide(true)

					particle:SetLighting(true)
					
					particle:SetCollideCallback(function(pertical,hitpos,hitnorm)
						pertical:SetLifeTime(CurTime()+0.1)
						pertical:SetDieTime(CurTime()+0.1)
						if(emitter)then
							local porticel = emitter:Add("particle/smokestack",pertical:GetPos()) --particles/smokey is a nice volumetric smoke sprite

							if (porticel) then
								
								local newvector=hitnorm
								newvector:Rotate(Angle(90,math.Rand(0,360),90))
								newvector:Normalize()
								newvector=newvector*math.Rand(0.5,1.5)
								if(newvector.z<0)then newvector=Vector(newvector.x,newvector.y,math.abs(newvector.z)) end
								
								porticel:SetVelocity(newvector*180)
								
								porticel:SetLifeTime(0)
								local timelived=CurTime()-begin
								local lifeleft=life-timelived
								porticel:SetDieTime(lifeleft)
								local lifeleftfraction=lifeleft/life

								porticel:SetColor(pertical:GetColor())			

								porticel:SetStartAlpha(lifeleftfraction*200)
								if(lifeleftfraction>0.9)then  porticel:SetStartAlpha(175) end --the particle probably hit the ground instantly as a result of being emitted from the grenade downwards while the grenade was sitting on the ground
								porticel:SetEndAlpha(0)
								
								porticel:SetStartSize((1-lifeleftfraction)*60)
								if(lifeleftfraction>0.9)then porticel:SetStartSize(20) end
								porticel:SetEndSize(60*Scayul)
								
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
			
		emitter:Finish()
	end)
	--]]
end
function EFFECT:Think()
	return false
end
function EFFECT:Render()
	-- lol
end