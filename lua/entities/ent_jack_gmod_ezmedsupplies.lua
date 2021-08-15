-- Jackarunda 2019
AddCSLuaFile()
ENT.Base="ent_jack_gmod_ezresource"
ENT.PrintName="EZ Medical Supplies Box"
ENT.Category="JMod - EZ Resources"
ENT.Spawnable=true
ENT.AdminSpawnable=true
---
ENT.EZsupplies=JMod.EZ_RESOURCE_TYPES.MEDICALSUPPLIES
ENT.JModPreferredCarryAngles=Angle(0,180,180)
ENT.Model="models/kali/props/cases/hard case b.mdl"
ENT.Material="models/kali/props/cases/hardcase/jardcase_b"
ENT.ModelScale=.5
ENT.Mass=30
ENT.ImpactNoise1="drywall.ImpactHard"
ENT.ImpactNoise2="Weapon.ImpactSoft"
ENT.DamageThreshold=120
ENT.BreakNoise="Metal_Box.Break"
ENT.PropModels={
	"models/items/healthkit.mdl",
	"models/healthvial.mdl",
	"models/items/medjit_medium.mdl",
	"models/items/medjit_small.mdl",
	"models/weapons/w_models/w_bonesaw.mdl", -- todo: missing texture
	"models/bandages.mdl"
}
---
if(SERVER)then
	function ENT:AltUse(ply)
		local Wep=ply:GetActiveWeapon()
		if((Wep)and(Wep.EZaccepts)and(Wep.EZaccepts==self.EZsupplies))then
			local ExistingAmt=Wep:GetSupplies()
			local Missing=Wep.EZmaxSupplies-ExistingAmt
			if(Missing>0)then
				local AmtToGive=math.min(Missing,self:GetResource())
				Wep:SetSupplies(ExistingAmt+AmtToGive)
				sound.Play("items/ammo_pickup.wav",self:GetPos(),65,math.random(90,110))
				self:SetResource(self:GetResource()-AmtToGive)
				if(self:GetResource()<=0)then self:Remove();return end
			end
		end
	end
	function ENT:UseEffect(pos,ent)
		for i=1,4*JMod.Config.SupplyEffectMult do self:FlingProp(table.Random(self.PropModels)) end
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
		JMod.HoloGraphicDisplay(self,Vector(0,3.4,9.5),Angle(-90,0,-90),.045,300,function()
			JMod.StandardResourceDisplay(JMod.EZ_RESOURCE_TYPES.MEDICALSUPPLIES,self:GetResource(),nil,0,0,200,true)
		end)
	end
	language.Add(ENT.ClassName,ENT.PrintName)
end