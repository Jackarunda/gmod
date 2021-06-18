-- Jackarunda 2019
AddCSLuaFile()
ENT.Base="ent_jack_gmod_ezresource"
ENT.PrintName="EZ Propellant Bottle"
ENT.Category="JMod - EZ Resources"
ENT.Spawnable=true
ENT.AdminSpawnable=true
---
ENT.EZsupplies="propellant"
ENT.JModPreferredCarryAngles=Angle(0,90,0)
ENT.MaxResource=JMod.EZbasicResourceBoxSize
ENT.Model="models/props_lab/jar01b.mdl"
ENT.Material="models/entities/mat_jack_powderbottle"
ENT.ModelScale=2
ENT.Mass=30
ENT.ImpactNoise1="Canister.ImpactHard"
ENT.DamageThreshold=80
ENT.BreakNoise="Metal_Box.Break"
ENT.Hint=nil
---
if(SERVER)then
	function ENT:UseEffect(pos,ent,destructive)
		if(destructive)then
			if(math.random(1,20)==2)then
				if(math.random(1,2)==1)then
					JMod.Sploom(self.Owner,self:GetPos(),math.random(50,130))
				end
				local Tr=util.QuickTrace(pos,Vector(math.random(-200,200),math.random(-200,200),math.random(0,-200)),{self})
				if(Tr.Hit)then
					local Fiah=ents.Create("env_fire")
					Fiah:SetPos(Tr.HitPos+Tr.HitNormal)
					Fiah:SetKeyValue("health",30)
					Fiah:SetKeyValue("fireattack",1)
					Fiah:SetKeyValue("firesize",math.random(20,200))
					Fiah:SetOwner(self.Owner or game.GetWorld())
					Fiah:Spawn()
					Fiah:Activate()
					Fiah:Fire("StartFire","",0)
					Fiah:Fire("kill","",math.random(3,10))
				end
				for k,ent in pairs(ents.FindInSphere(pos,600))do
					local Vec=(ent:GetPos()-pos):GetNormalized()
					if(self:Visible(ent))then
						if((ent:IsPlayer())or(ent:IsNPC()))then
							ent:SetVelocity(Vec*1000)
						elseif(IsValid(ent:GetPhysicsObject()))then
							ent:GetPhysicsObject():ApplyForceCenter(Vec*50000)
						end
					end
				end
			end
		end
	end
	function ENT:AltUse(ply)
		--
	end
elseif(CLIENT)then
	local TxtCol=Color(255,255,255,80)
	function ENT:Draw()
		local Ang,Pos=self:GetAngles(),self:GetPos()
		local Closeness=LocalPlayer():GetFOV()*(EyePos():Distance(Pos))
		local DetailDraw=Closeness<18000 -- cutoff point is 200 units when the fov is 90 degrees
		self:DrawModel()
		if(DetailDraw)then
			local Up,Right,Forward,Ammo=Ang:Up(),Ang:Right(),Ang:Forward(),tostring(self:GetResource())
			Ang:RotateAroundAxis(Ang:Right(),90)
			Ang:RotateAroundAxis(Ang:Up(),-180)
			Ang:RotateAroundAxis(Ang:Forward(),90)
			cam.Start3D2D(Pos-Right*6.7-Forward*1-Up,Ang,.02)
			draw.SimpleText("JACKARUNDA INDUSTRIES","JMod-Stencil",0,0,TxtCol,TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
			draw.SimpleText("EZ PROPELLANT","JMod-Stencil",0,50,TxtCol,TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
			draw.SimpleText(Ammo.." UNITS","JMod-Stencil",0,100,TxtCol,TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
			cam.End3D2D()
		end
	end
	language.Add(ENT.ClassName,ENT.PrintName)
end