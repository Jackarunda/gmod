-- Jackarunda 2020
AddCSLuaFile()
ENT.Base="ent_jack_gmod_ezresource"
ENT.PrintName="EZ Water Drum"
ENT.Category="JMod - EZ Resources"
ENT.IconOverride="materials/ez_resource_icons/water.png"
ENT.Spawnable=true
ENT.AdminSpawnable=true
---
ENT.EZsupplies=JMod.EZ_RESOURCE_TYPES.WATER
ENT.JModPreferredCarryAngles=Angle(0,0,0)
ENT.Model="models/props_borealis/bluebarrel001.mdl"
--ENT.Material="models/shiny"
--ENT.Color=Color(50,120,180)
ENT.SpawnHeight=30
ENT.ModelScale=.75
ENT.Mass=40
ENT.ImpactNoise1="Plastic_Barrel.ImpactHard"
ENT.ImpactNoise2="Weapon.ImpactSoft"
ENT.DamageThreshold=120
ENT.BreakNoise="Plastic_Barrel.Break"
--ENT.Hint="coolant"
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
		self:DrawModel()
		JMod.HoloGraphicDisplay(self,Vector(0,-10.8,0),Angle(90,0,90),.04,300,function()
			JMod.StandardResourceDisplay(JMod.EZ_RESOURCE_TYPES.WATER,self:GetResource(),nil,0,0,200,true)
		end)
	end
	language.Add(ENT.ClassName,ENT.PrintName)
end