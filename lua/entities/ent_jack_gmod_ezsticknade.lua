-- Jackarunda 2021
AddCSLuaFile()
ENT.Base = "ent_jack_gmod_ezgrenade"
ENT.Author = "Jackarunda, TheOnly8Z"
ENT.Category = "JMod - EZ Explosives"
ENT.PrintName = "EZ Stick Grenade"
ENT.Spawnable = true
ENT.Model = "models/jmod/explosives/grenades/sticknade/stick_grenade.mdl" -- "models/mechanics/robotics/a2.mdl"
ENT.Material = "models/mats_jack_nades/stick_grenade"
--ENT.ModelScale=1.25
ENT.SpoonModel = "models/jmod/explosives/grenades/sticknade/stick_grenade_cap.mdl"
ENT.HardThrowStr = 800
ENT.SoftThrowStr = 400
ENT.JModPreferredCarryAngles = Angle(0, 0, 0)
ENT.EZspinThrow = true
ENT.PinBodygroup = nil
ENT.SpoonBodygroup = {4, 1}
ENT.DetDelay = 4

ENT.Hints = {"frag sleeve"}

ENT.JModEZstorableVolume = 2
ENT.Splitterring = false
local BaseClass = baseclass.Get(ENT.Base)

if SERVER then
	function ENT:ShiftAltUse(activator, onOff)
		if not onOff then return end
		self.Splitterring = not self.Splitterring

		if self.Splitterring then
			self:SetMaterial("models/mats_jack_nades/stick_grenade_frag")
			self:EmitSound("snds_jack_gmod/metal_shf.ogg", 60, 120)
		else
			self:SetMaterial("models/mats_jack_nades/stick_grenade")
			self:EmitSound("snds_jack_gmod/metal_shf.ogg", 60, 80)
		end
	end

	function ENT:Detonate()
		if self.Exploded then return end
		self.Exploded = true
		local SelfPos = self:GetPos()
		self:EmitSound("snd_jack_fragsplodeclose.ogg", 90, 100)

		if self.Splitterring then
			local plooie = EffectData()
			plooie:SetOrigin(SelfPos)
			plooie:SetScale(.5)
			plooie:SetRadius(1)
			plooie:SetNormal(vector_up)
			util.Effect("eff_jack_minesplode", plooie, true, true)
			util.ScreenShake(SelfPos, 20, 20, 1, 1000)
			JMod.FragSplosion(self, SelfPos + Vector(0, 0, 20), 1500, 70, 2500, JMod.GetEZowner(self), self:GetUp(), .75)
			self:Remove()
		else
			JMod.Sploom(JMod.GetEZowner(self), SelfPos, 150)
			local Blam = EffectData()
			Blam:SetOrigin(SelfPos)
			Blam:SetScale(.8)
			util.Effect("eff_jack_plastisplosion", Blam, true, true)
			util.ScreenShake(SelfPos, 20, 20, 1, 1000)
			self:Remove()
		end
	end
elseif CLIENT then
	language.Add("ent_jack_gmod_ezsticknade", "EZ Stick Grenade")
end
