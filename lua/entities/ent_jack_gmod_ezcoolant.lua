-- Jackarunda 2020
AddCSLuaFile()
ENT.Base="ent_jack_gmod_ezresource"
ENT.PrintName="EZ Coolant Drum"
ENT.Category="JMod - EZ Resources"
ENT.Spawnable=true
ENT.AdminSpawnable=true
---
ENT.EZsupplies="coolant"
ENT.JModPreferredCarryAngles=Angle(0,0,0)
ENT.MaxResource=JMod.EZbasicResourceBoxSize
ENT.Model="models/props_junk/garbage_plasticbottle002a.mdl"
ENT.Material="models/shiny"
ENT.Color=Color(50,120,180)
ENT.ModelScale=2
ENT.Mass=40
ENT.ImpactNoise1="Plastic_Barrel.ImpactHard"
ENT.ImpactNoise2="Weapon.ImpactSoft"
ENT.DamageThreshold=120
ENT.BreakNoise="Plastic_Barrel.Break"
ENT.Hint="coolant"
---
if(SERVER)then
	function ENT:UseEffect(pos,ent)
		local FX=EffectData()
		FX:SetOrigin(pos)
		FX:SetScale(1)
		util.Effect("WaterSplash",FX,true,true)
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
			cam.Start3D2D(Pos-Up*1-Right*0-Forward*4.1,Ang,.03)
			draw.SimpleText("JACKARUNDA INDUSTRIES","JMod-Stencil",0,0,TxtCol,TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
			draw.SimpleText("EZ COOLANT","JMod-Stencil",0,50,TxtCol,TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
			draw.SimpleText(Ammo.." UNITS","JMod-Stencil",0,100,TxtCol,TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
			cam.End3D2D()
			---
			Ang:RotateAroundAxis(Ang:Right(),180)
			cam.Start3D2D(Pos-Up*2+Right*1+Forward*4.1,Ang,.03)
			draw.SimpleText("JACKARUNDA INDUSTRIES","JMod-Stencil",0,0,TxtCol,TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
			draw.SimpleText("EZ COOLANT","JMod-Stencil",0,50,TxtCol,TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
			draw.SimpleText(Ammo.." UNITS","JMod-Stencil",0,100,TxtCol,TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
			cam.End3D2D()
		end
	end
	language.Add(ENT.ClassName,ENT.PrintName)
end