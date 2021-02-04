-- Jackarunda 2019
AddCSLuaFile()
ENT.Base="ent_jack_gmod_ezresource"
ENT.PrintName="EZ Antimatter"
ENT.Category="JMod - EZ Resources"
ENT.Spawnable=true
ENT.AdminOnly=true
---
ENT.EZsupplies="antimatter"
ENT.JModPreferredCarryAngles=Angle(0,0,0)
ENT.MaxResource=JMod_EZsuperRareResourceSize
ENT.Model="models/thedoctor/darkmatter.mdl"
ENT.ModelScale=1
-- 10 micrograms
ENT.Mass=100
ENT.ImpactNoise1="Canister.ImpactHard"
ENT.ImpactNoise2="Weapon.ImpactSoft"
ENT.ImpactSensitivity=800
ENT.DamageThreshold=50
ENT.BreakNoise="Metal_Box.Break"
ENT.Hint="antimatter"
---
if(SERVER)then
	function ENT:UseEffect(pos,ent,destructive)
		if((destructive)and not(self.Sploomd))then
			self.Sploomd=true
			local Blam=EffectData()
			Blam:SetOrigin(pos)
			Blam:SetScale(5)
			util.Effect("eff_jack_plastisplosion",Blam,true,true)
			util.ScreenShake(pos,99999,99999,1,750*5)
			for i=1,2 do sound.Play("BaseExplosionEffect.Sound",pos,120,math.random(90,110)) end
			for i=1,2 do sound.Play("ambient/explosions/explode_"..math.random(1,9)..".wav",pos+VectorRand()*1000,140,math.random(90,110)) end
			timer.Simple(.1,function() util.BlastDamage(game.GetWorld(),game.GetWorld(),pos,1000,500) end)
		end
	end
	function ENT:AltUse(ply)
		--
	end
elseif(CLIENT)then
	local TxtCol=Color(50,50,50,220)
	function ENT:Draw()
		local Ang,Pos=self:GetAngles(),self:GetPos()
		local Closeness=LocalPlayer():GetFOV()*(EyePos():Distance(Pos))
		local DetailDraw=Closeness<18000 -- cutoff point is 200 units when the fov is 90 degrees
		self:DrawModel()
		if(DetailDraw)then
			local Up,Right,Forward,Count=Ang:Up(),Ang:Right(),Ang:Forward(),tostring(self:GetResource())
			Ang:RotateAroundAxis(Ang:Right(),90)
			cam.Start3D2D(Pos+Up*8.5-Right*.5-Forward*6.2,Ang,.012)
			draw.SimpleText("JACKARUNDA INDUSTRIES","JMod-Stencil",0,0,TxtCol,TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
			draw.SimpleText("EZ ANTIMATTER","JMod-Stencil",0,50,TxtCol,TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
			draw.SimpleText(Count.." UNITS","JMod-Stencil",0,100,TxtCol,TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
			cam.End3D2D()
		end
	end
	language.Add(ENT.ClassName,ENT.PrintName)
end