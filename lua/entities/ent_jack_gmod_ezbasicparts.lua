-- Jackarunda 2021
AddCSLuaFile()
ENT.Base="ent_jack_gmod_ezresource"
ENT.PrintName="EZ Basic Parts Box"
ENT.Category="JMod-EZ Resources"
ENT.IconOverride="materials/ez_resource_icons/basic parts.png"
ENT.Spawnable=true
ENT.AdminSpawnable=true
---
ENT.EZsupplies=JMod.EZ_RESOURCE_TYPES.BASICPARTS
ENT.JModPreferredCarryAngles=Angle(0,180,0)
ENT.Model="models/Items/item_item_crate.mdl"
ENT.Material="models/mat_jack_gmod_ezparts"
ENT.ModelScale=.8
ENT.Mass=50
ENT.ImpactNoise1="Wood_Box.ImpactHard"
ENT.ImpactNoise2="Weapon.ImpactSoft"
ENT.DamageThreshold=120
ENT.BreakNoise="Wood_Box.Break"
---
if(SERVER)then
	function ENT:UseEffect(pos,ent)
		for i=1,2*JMod.Config.SupplyEffectMult do self:FlingProp("models/mechanics/gears/gear12x6_small.mdl") end
		local effectdata=EffectData()
		effectdata:SetOrigin(pos+VectorRand())
		effectdata:SetNormal((VectorRand()+Vector(0,0,1)):GetNormalized())
		effectdata:SetMagnitude(math.Rand(2,4)) --amount and shoot hardness
		effectdata:SetScale(math.Rand(1,2)) --length of strands
		effectdata:SetRadius(math.Rand(2,4)) --thickness of strands
		util.Effect("Sparks",effectdata,true,true)
	end
elseif(CLIENT)then
	function ENT:Draw()
		self:DrawModel()
		JMod.HoloGraphicDisplay(self,Vector(0.5,13,10),Angle(-90,0,90),.043,300,function()
			JMod.StandardResourceDisplay(JMod.EZ_RESOURCE_TYPES.BASICPARTS,self:GetResource(),nil,0,0,200,true)
		end)
	end
	language.Add(ENT.ClassName,ENT.PrintName)
end
