-- Jackarunda 2021
AddCSLuaFile()
ENT.Base="ent_jack_gmod_ezgrenade"
ENT.Author="Jackarunda, TheOnly8Z"
ENT.PrintName="EZ Smoke Grenade"
ENT.Category="JMod - EZ Misc."
ENT.Spawnable=true
ENT.JModPreferredCarryAngles=Angle(0, 140, 0)
ENT.Model="models/jmodels/explosives/grenades/firenade/incendiary_grenade.mdl"
ENT.Material="models/mats_jack_nades/smokescreen"
ENT.SpoonScale=2
if(SERVER)then
	function ENT:Prime()
		self:SetState(JMod.EZ_STATE_PRIMED)
		self:EmitSound("weapons/pinpull.wav", 60, 100)
		self:SetBodygroup(3, 1)
	end
	function ENT:Arm()
		self:SetBodygroup(2, 1)
		self:SetState(JMod.EZ_STATE_ARMED)
		self:SpoonEffect()
		timer.Simple(2, function()
			if(IsValid(self))then self:Detonate() end
		end)
	end
	function ENT:Detonate()
		if(self.Exploded)then return end
		self.Exploded=true
		self.FuelLeft=100
		self:EmitSound("snd_jack_fragsplodeclose.wav", 70, 150)
	end
	function ENT:CustomThink()
		if(self.Exploded)then
			local Foof=EffectData()
			Foof:SetOrigin(self:GetPos())
			Foof:SetNormal(self:GetUp())
			Foof:SetScale(self.FuelLeft/100)
			Foof:SetStart(self:GetPhysicsObject():GetVelocity())
			util.Effect("eff_jack_gmod_ezsmokescreen",Foof,true,true)
			self:EmitSound("snd_jack_sss.wav",55,80)
			self.FuelLeft=self.FuelLeft-.5
			if(self.FuelLeft<=0)then SafeRemoveEntityDelayed(self,1) end
		end
	end
elseif(CLIENT)then
	function ENT:Draw()
		self:DrawModel()
	end
	language.Add("ent_jack_gmod_ezsmokenade","EZ Smokescreen Grenade")
end