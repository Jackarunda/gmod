-- Jackarunda 2019
AddCSLuaFile()
ENT.Base="ent_jack_gmod_ezresource"
ENT.PrintName="EZ Munition Box"
ENT.Category="JMod - EZ Resources"
ENT.Spawnable=true
ENT.AdminSpawnable=true
---
ENT.EZsupplies=JMod.EZ_RESOURCE_TYPES.MUNITIONS
ENT.JModPreferredCarryAngles=Angle(0,180,0)
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
	function ENT:Draw()
		self:DrawModel()
		JMod.HoloGraphicDisplay(self,Vector(-0.7,7.4,14),Angle(-90,0,90),.055,300,function()
			JMod.StandardResourceDisplay(JMod.EZ_RESOURCE_TYPES.MUNITIONS,self:GetResource(),nil,0,0,200,false)
		end)
	end
	language.Add(ENT.ClassName,ENT.PrintName)
end