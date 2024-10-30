-- Jackarunda 2021
AddCSLuaFile()
ENT.Base = "ent_jack_gmod_ezgrenade"
ENT.Author = "Jackarunda, TheOnly8Z"
ENT.Category = "JMod - EZ Explosives"
ENT.PrintName = "EZ Gebalte Ladung"
ENT.Spawnable = true
ENT.Model = "models/jmod/explosives/grenades/bundlenade/bundle_grenade.mdl"
ENT.Material = "models/mats_jack_nades/stick_grenade"
--ENT.ModelScale=1.25
ENT.SpoonModel = "models/jmod/explosives/grenades/sticknade/stick_grenade_cap.mdl"
ENT.HardThrowStr = 200
ENT.SoftThrowStr = 100
ENT.JModPreferredCarryAngles = Angle(0, 0, 0)
ENT.EZspinThrow = true
ENT.PinBodygroup = nil -- No pin
ENT.SpoonBodygroup = {4, 1}
ENT.DetDelay = 4
--ENT.EZstorageVolumeOverride=4
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

		timer.Simple(0, function()
			if IsValid(self) then
				local SelfPos, PowerMult = self:GetPos(), 3

				if self.Splitterring then
					local plooie = EffectData()
					plooie:SetOrigin(SelfPos)
					plooie:SetScale(1)
					plooie:SetRadius(2)
					plooie:SetNormal(vector_up)
					util.Effect("eff_jack_minesplode", plooie, true, true)
					util.ScreenShake(SelfPos, 99999, 99999, 1, 750 * PowerMult)
					JMod.FragSplosion(self, SelfPos + Vector(0, 0, 20), 5000, 70, 5000, JMod.GetEZowner(self))

					timer.Simple(.1, function()
						for i = 1, 5 do
							local Tr = util.QuickTrace(SelfPos, VectorRand() * 20)

							if Tr.Hit then
								util.Decal("Scorch", Tr.HitPos + Tr.HitNormal, Tr.HitPos - Tr.HitNormal)
							end
						end
					end)

					self:Remove()
				else
					--
					local Blam = EffectData()
					Blam:SetOrigin(SelfPos)
					Blam:SetScale(PowerMult / 1.5)
					util.Effect("eff_jack_plastisplosion", Blam, true, true)
					util.ScreenShake(SelfPos, 99999, 99999, 1, 750 * PowerMult)

					for i = 1, 2 do
						sound.Play("ambient/explosions/explode_" .. math.random(1, 9) .. ".wav", SelfPos + VectorRand() * 1000, 140, math.random(80, 110))
					end

					for i = 1, PowerMult do
						sound.Play("BaseExplosionEffect.Sound", SelfPos, 120, math.random(90, 110))
					end

					self:EmitSound("snd_jack_fragsplodeclose.ogg", 90, 100)

					timer.Simple(.1, function()
						for i = 1, 5 do
							local Tr = util.QuickTrace(SelfPos, VectorRand() * 20)

							if Tr.Hit then
								util.Decal("Scorch", Tr.HitPos + Tr.HitNormal, Tr.HitPos - Tr.HitNormal)
							end
						end
					end)

					JMod.WreckBuildings(self, SelfPos, PowerMult)
					JMod.BlastDoors(self, SelfPos, PowerMult)

					timer.Simple(0, function()
						local ZaWarudo = game.GetWorld()
						local Infl, Att = (IsValid(self) and self) or ZaWarudo, (IsValid(self) and IsValid(self.EZowner) and self.EZowner) or (IsValid(self) and self) or ZaWarudo
						util.BlastDamage(Infl, Att, SelfPos, 125 * PowerMult, 180 * PowerMult)
						self:Remove()
					end)
				end
			end
		end)
	end
elseif CLIENT then
	language.Add("ent_jack_gmod_ezsticknadebundle", "EZ Gebalte Ladung")
end
