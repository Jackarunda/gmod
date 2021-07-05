-- Jackarunda 2019
AddCSLuaFile()
ENT.Base="ent_jack_gmod_ezresource"
ENT.PrintName="EZ Munition Box"
ENT.Category="JMod - EZ Resources"
ENT.Spawnable=true
ENT.AdminSpawnable=true
---
ENT.EZsupplies=JMod.EZ_RESOURCE_TYPES.MUNITIONS
ENT.JModPreferredCarryAngles=Angle(0,0,0)
ENT.MaxResource=JMod.EZammoBoxSize
ENT.Model="models/Items/BoxJRounds.mdl"
ENT.Material="models/mat_jack_gmod_ezmunitionbox"
ENT.ModelScale=2.5
ENT.Mass=70
ENT.ImpactNoise1="Metal_Box.ImpactHard"
ENT.ImpactNoise2="Weapon.ImpactSoft"
ENT.DamageThreshold=120
ENT.BreakNoise="Metal_Box.Break"
---
if(SERVER)then
	function ENT:UseEffect(pos,ent,destroyed)
		local num=10
		if(destroyed)then num=1 end
		for i=1,num do
			timer.Simple(i/200,function()
				if not(IsValid(self))then return end
				local Eff=EffectData()
				Eff:SetOrigin(pos)
				Eff:SetAngles((VectorRand()+Vector(0,0,1)):GetNormalized():Angle())
				Eff:SetEntity(ent)
				util.Effect("eff_jack_gmod_40mmshell",Eff,true,true)
			end)
		end
	end
	function ENT:AltUse(ply)
		JMod.GiveAmmo(ply,self)
	end
elseif(CLIENT)then
	local TxtCol=Color(255,240,150,80)
	function ENT:Draw()
		local Ang,Pos=self:GetAngles(),self:GetPos()
		local Closeness=LocalPlayer():GetFOV()*(EyePos():Distance(Pos))
		local DetailDraw=Closeness<18000 -- cutoff point is 200 units when the fov is 90 degrees
		self:DrawModel()
		if(DetailDraw)then
			local Up,Right,Forward,Ammo=Ang:Up(),Ang:Right(),Ang:Forward(),tostring(self:GetResource())
			Ang:RotateAroundAxis(Ang:Right(),90)
			Ang:RotateAroundAxis(Ang:Up(),-90)
			cam.Start3D2D(Pos+Up*21-Right*.6-Forward*7.2,Ang,.05)
			draw.SimpleText("JACKARUNDA INDUSTRIES","JMod-Stencil",0,0,TxtCol,TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
			draw.SimpleText("EZ MUNITIONS","JMod-Stencil",0,50,TxtCol,TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
			draw.SimpleText(Ammo.." COUNT","JMod-Stencil",0,100,TxtCol,TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
			cam.End3D2D()
			---
			Ang:RotateAroundAxis(Ang:Right(),180)
			cam.Start3D2D(Pos+Up*21-Right*.6+Forward*7.2,Ang,.05)
			draw.SimpleText("JACKARUNDA INDUSTRIES","JMod-Stencil",0,0,TxtCol,TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
			draw.SimpleText("EZ MUNITIONS","JMod-Stencil",0,50,TxtCol,TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
			draw.SimpleText(Ammo.." COUNT","JMod-Stencil",0,100,TxtCol,TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
			cam.End3D2D()
		end
	end
	language.Add(ENT.ClassName,ENT.PrintName)
end