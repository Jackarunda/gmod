-- Jackarunda 2019
AddCSLuaFile()
ENT.Base="ent_jack_gmod_ezresource"
ENT.PrintName="EZ Gas Tank"
ENT.Category="JMod - EZ"
ENT.Spawnable=true
ENT.AdminSpawnable=true
---
ENT.EZsupplies="gas"
ENT.JModPreferredCarryAngles=Angle(0,0,0)
ENT.MaxResource=JMod_EZfuelCanSize
ENT.Model="models/props_junk/propane_tank001a.mdl"
ENT.Material=nil
ENT.ModelScale=1.5
ENT.Mass=40
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
					JMod_Sploom(self.Owner,self:GetPos(),math.random(50,130))
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
			cam.Start3D2D(Pos+Up*2+Right*1.5-Forward*6.5,Ang,.03)
			draw.SimpleText("JACKARUNDA INDUSTRIES","JMod-Stencil",0,0,TxtCol,TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
			draw.SimpleText("EZ GAS","JMod-Stencil",0,50,TxtCol,TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
			draw.SimpleText(Ammo.." UNITS","JMod-Stencil",0,100,TxtCol,TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
			cam.End3D2D()
		end
	end
	language.Add(ENT.ClassName,ENT.PrintName)
end