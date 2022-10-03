﻿-- Jackarunda 2021
AddCSLuaFile()
ENT.Base = "ent_jack_gmod_ezgrenade"
ENT.Author = "Jackarunda, TheOnly8Z"
ENT.PrintName = "EZ Signal Grenade"
ENT.Category = "JMod - EZ Misc."
ENT.Spawnable = true
ENT.JModPreferredCarryAngles = Angle(0, 140, 0)
ENT.Model = "models/jmodels/explosives/grenades/firenade/incendiary_grenade.mdl"
ENT.Material = "models/mats_jack_nades/smokesignal"
ENT.Color = Color(128, 128, 128)
ENT.SpoonScale = 2
ENT.JModGUIcolorable = true

if SERVER then
	function ENT:Use(activator, activatorAgain, onOff)
		if self.Exploded then return end
		local Dude = activator or activatorAgain
		JMod.Owner(self, Dude)
		local Time = CurTime()

		if tobool(onOff) then
			local State = self:GetState()
			if State < 0 then return end
			local Alt = Dude:KeyDown(JMod.Config.AltFunctionKey)

			if State == JMod.EZ_STATE_OFF and Alt then
				JMod.Owner(self, activator)
				net.Start("JMod_ColorAndArm")
				net.WriteEntity(self)
				net.Send(activator)
			end

			JMod.ThrowablePickup(Dude, self, self.HardThrowStr, self.SoftThrowStr)
		end
	end

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
			if IsValid(self) then
				self:Detonate()
			end
		end)
	end

	function ENT:Detonate()
		if self.Exploded then return end
		self.Exploded = true
		self.FuelLeft = 100
		self:EmitSound("snd_jack_fragsplodeclose.wav", 70, 150)
	end

	function ENT:CustomThink()
		if self.Exploded then
			local Foof = EffectData()
			Foof:SetOrigin(self:GetPos())
			Foof:SetNormal(self:GetUp())
			Foof:SetScale(self.FuelLeft / 100)
			Foof:SetStart(self:GetPhysicsObject():GetVelocity())
			local Col = self:GetColor()
			Foof:SetAngles(Angle(Col.r, Col.g, Col.b))
			util.Effect("eff_jack_gmod_ezsmokesignal", Foof, true, true)
			self:EmitSound("snd_jack_sss.wav", 55, 80)
			self.FuelLeft = self.FuelLeft - .5

			if self.FuelLeft <= 0 then
				SafeRemoveEntityDelayed(self, 1)
			end
		end
	end
elseif CLIENT then
	function ENT:Draw()
		self:DrawModel()
	end

	language.Add("ent_jack_gmod_ezsignalnade", "EZ Smoke Signal Grenade")
end
