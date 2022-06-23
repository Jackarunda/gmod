-- Jackarunda 2021
AddCSLuaFile()
ENT.Base="ent_jack_gmod_ezresource"
ENT.PrintName="EZ Coolant Bottle"
ENT.Category="JMod - EZ Resources"
ENT.IconOverride="materials/ez_resource_icons/coolant.png"
ENT.Spawnable=true
ENT.AdminSpawnable=true
---
ENT.EZsupplies=JMod.EZ_RESOURCE_TYPES.COOLANT
ENT.JModPreferredCarryAngles=Angle(0,0,0)
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
		self:DrawModel()
		JMod.HoloGraphicDisplay(self,Vector(0,-4.1,-7),Angle(90,0,90),.04,300,function()
			JMod.StandardResourceDisplay(JMod.EZ_RESOURCE_TYPES.COOLANT,self:GetResource(),nil,0,0,200,true)
		end)
	end
	language.Add(ENT.ClassName,ENT.PrintName)
end