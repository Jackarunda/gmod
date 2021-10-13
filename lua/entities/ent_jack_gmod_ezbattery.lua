-- Jackarunda 2021
AddCSLuaFile()
ENT.Base="ent_jack_gmod_ezresource"
ENT.PrintName="EZ Battery"
ENT.Category="JMod - EZ Resources"
ENT.IconOverride="materials/ez_resource_icons/power.png"
ENT.Spawnable=true
ENT.AdminSpawnable=true
---
ENT.EZsupplies=JMod.EZ_RESOURCE_TYPES.POWER
ENT.JModPreferredCarryAngles=Angle(0,0,0)
ENT.Model="models/props_phx/facepunch_barrel.mdl"
ENT.Material="models/mat_jack_gmod_ezbattery"
ENT.ModelScale=.6
ENT.Mass=50
ENT.ImpactNoise1="Canister.ImpactHard"
ENT.DamageThreshold=120
ENT.BreakNoise="Metal_Box.Break"
ENT.JModPreferredCarryAngles=Angle(0,180,0)
---
if(SERVER)then
	function ENT:UseEffect(pos,ent)
		local effectdata=EffectData()
		effectdata:SetOrigin(pos+VectorRand())
		effectdata:SetNormal((VectorRand()+Vector(0,0,1)):GetNormalized())
		effectdata:SetMagnitude(math.Rand(5,10)) --amount and shoot hardness
		effectdata:SetScale(math.Rand(.5,1.5)) --length of strands
		effectdata:SetRadius(math.Rand(2,4)) --thickness of strands
		util.Effect("Sparks",effectdata,true,true)
	end
elseif(CLIENT)then
	function ENT:Draw()
		self:DrawModel()
		JMod.HoloGraphicDisplay(self,Vector(0,8.31,12),Angle(-90,0,90),.03,300,function()
			JMod.StandardResourceDisplay(JMod.EZ_RESOURCE_TYPES.POWER,self:GetResource(),nil,0,0,200,true)
		end)
	end
	language.Add(ENT.ClassName,ENT.PrintName)
end