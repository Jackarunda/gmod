-- Jackarunda 2019
AddCSLuaFile()
ENT.Base="ent_jack_gmod_ezresource"
ENT.PrintName="EZ Advanced Textiles Box"
ENT.Category="JMod - EZ Resources"
ENT.IconOverride="materials/ez_resource_icons/advanced textiles.png"
ENT.Spawnable=true
ENT.AdminSpawnable=true
---
ENT.EZsupplies=JMod.EZ_RESOURCE_TYPES.ADVANCEDTEXTILES
ENT.JModPreferredCarryAngles=Angle(0,180,180)
ENT.Model="models/kali/props/cases/hard case b.mdl"
ENT.Material="models/kali/props/cases/hardcase/jardjase_b"
ENT.ModelScale=.5
ENT.Mass=30
ENT.ImpactNoise1="drywall.ImpactHard"
ENT.ImpactNoise2="Weapon.ImpactSoft"
ENT.DamageThreshold=120
ENT.BreakNoise="Metal_Box.Break"
ENT.PropModels={"models/props_junk/garbage_carboard002a.mdl"}
---
if(SERVER)then
	function ENT:UseEffect(pos,ent)
		for i=1,1*JMod.Config.SupplyEffectMult do self:FlingProp(table.Random(self.PropModels)) end
	end
elseif(CLIENT)then
	function ENT:Draw()
		self:DrawModel()
		JMod.HoloGraphicDisplay(self,Vector(0,3.5,10),Angle(-90,0,-90),.035,300,function()
			JMod.StandardResourceDisplay(JMod.EZ_RESOURCE_TYPES.ADVANCEDTEXTILES,self:GetResource(),nil,0,0,200,true)
		end)
	end
	language.Add(ENT.ClassName,ENT.PrintName)
end