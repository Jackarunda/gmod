-- Jackarunda 2021
AddCSLuaFile()
ENT.Base="ent_jack_gmod_ezresource"
ENT.PrintName="EZ Diamond"
ENT.Category="JMod - EZ Resources"
ENT.IconOverride="materials/ez_resource_icons/diamond.png"
ENT.Spawnable=true
ENT.AdminSpawnable=true
---
ENT.EZsupplies=JMod.EZ_RESOURCE_TYPES.DIAMOND
ENT.JModPreferredCarryAngles=Angle(0,0,0)
ENT.Model="models/props/CS_militia/footlocker01_open.mdl"
ENT.Material="phoenix_storms/grey_steel"
ENT.Color=Color(100,100,100)
ENT.ModelScale=.5
ENT.Mass=50
ENT.ImpactNoise1="Canister.ImpactHard"
ENT.DamageThreshold=120
ENT.BreakNoise="Metal_Box.Break"
ENT.JModPreferredCarryAngles=Angle(0,180,0)
---
if(SERVER)then
	function ENT:UseEffect(pos,ent)
		-- it's diamond yo
	end
elseif(CLIENT)then
	function ENT:Initialize()
		self.Diamond1=JMod.MakeModel(self,"models/props_debris/concrete_chunk05g.mdl","models/mat_jack_gmod_diamond")
		self.Diamond2=JMod.MakeModel(self,"models/props_debris/concrete_chunk04a.mdl","models/mat_jack_gmod_diamond")
		self.Diamond3=JMod.MakeModel(self,"models/props_debris/concrete_chunk05g.mdl","models/mat_jack_gmod_diamond")
	end
	function ENT:Draw()
		local Pos,Ang=self:GetPos(),self:GetAngles()
		local Right,Up,Forward=Ang:Right(),Ang:Up(),Ang:Forward()
		self:DrawModel()
		JMod.RenderModel(self.Diamond1,Pos-Right*5-Up*4,Ang,Vector(1,1,1),nil,"",true)
		JMod.RenderModel(self.Diamond2,Pos-Up*3,Ang,Vector(1,1,1),nil,"",true)
		JMod.RenderModel(self.Diamond3,Pos+Right*5-Up*4,Ang,Vector(1,1,1),nil,"",true)
		JMod.HoloGraphicDisplay(self,Vector(0,-9.7,9),Angle(-90,15,90),.032,300,function()
			JMod.StandardResourceDisplay(JMod.EZ_RESOURCE_TYPES.DIAMOND,self:GetResource(),nil,0,0,200,false)
		end)
	end
	language.Add(ENT.ClassName,ENT.PrintName)
end
