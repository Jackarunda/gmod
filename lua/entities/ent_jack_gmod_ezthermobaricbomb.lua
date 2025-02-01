-- Jackarunda 2021
AddCSLuaFile()
ENT.Base = "ent_jack_gmod_ezbomb"
ENT.Author = "Jackarunda"
ENT.Category = "JMod - EZ Explosives"
ENT.Information = "glhfggwpezpznore"
ENT.PrintName = "EZ Thermobaric Bomb"
ENT.Spawnable = true
ENT.AdminSpawnable = true
---
ENT.JModPreferredCarryAngles = Angle(0, 0, 0)
ENT.EZrackOffset = Vector(0, 0, 10)
ENT.EZrackAngles = Angle(0, 0, 90)
ENT.EZbombBaySize = 5
---
ENT.EZguidable = false
ENT.Model = "models/props_phx/ww2bomb.mdl"
ENT.Material = "models/entities/mat_jack_faebomb"
ENT.Mass = 100
ENT.DetSpeed = 1000
ENT.DetType = "impactdet"

local STATE_BROKEN, STATE_OFF, STATE_ARMED = -1, 0, 1

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "State")
end

---
if SERVER then
	function ENT:Detonate()
		if self.Exploded then return end
		self.Exploded = true
		local SelfPos, Att = self:GetPos() + Vector(0, 0, 60), JMod.GetEZowner(self)
		JMod.Sploom(Att, SelfPos, 100)

		---
		if self:WaterLevel() >= 3 then
			self:Remove()

			return
		end

		---
		local Sploom = EffectData()
		Sploom:SetOrigin(SelfPos)
		util.Effect("eff_jack_gmod_faebomb_predet", Sploom, true, true)
		---
		local Oof = .25

		for i = 1, 500 do
			local Tr = util.QuickTrace(SelfPos, VectorRand() * 1000, self)

			if Tr.Hit then
				Oof = Oof * 1.005
			end
		end

		---
		timer.Simple(.3, function()
			util.ScreenShake(SelfPos, 1000, 3, 2, 2000 * Oof)
			---
			util.BlastDamage(game.GetWorld(), IsValid(Att) and Att or game.GetWorld(), SelfPos, 2000 * Oof, 200 * Oof)
			---
			for k, v in ipairs(ents.FindInSphere(SelfPos, 2000 * Oof)) do
				if v:GetClass() == "ent_jack_gmod_ezoilfire" then
					v:Diffuse()
				end
			end
			---
			for i = 1, 2 * Oof do
				sound.Play("ambient/explosions/explode_" .. math.random(1, 9) .. ".wav", SelfPos + VectorRand() * 1000, 160, math.random(80, 110))
			end

			---
			JMod.WreckBuildings(self, SelfPos, 10 * Oof)
			JMod.BlastDoors(self, SelfPos, 10 * Oof)

			---
			timer.Simple(.2, function()
				JMod.WreckBuildings(self, SelfPos, 10 * Oof)
				JMod.BlastDoors(self, SelfPos, 10 * Oof)
			end)

			timer.Simple(.4, function()
				JMod.WreckBuildings(self, SelfPos, 10 * Oof)
				JMod.BlastDoors(self, SelfPos, 10 * Oof)
			end)

			---
			timer.Simple(.1, function()
				local Tr = util.QuickTrace(SelfPos + Vector(0, 0, 100), Vector(0, 0, -400))

				if Tr.Hit then
					util.Decal("BigScorch", Tr.HitPos + Tr.HitNormal, Tr.HitPos - Tr.HitNormal)
				end
			end)

			---
			local Sploom = EffectData()
			Sploom:SetOrigin(SelfPos)
			Sploom:SetScale(Oof)
			util.Effect("eff_jack_gmod_faebomb_main", Sploom, true, true)
		end)

		self:Remove()
	end

	function ENT:AeroDragThink()
		JMod.AeroDrag(self, self:GetForward())
	end
elseif CLIENT then
	function ENT:Initialize()
	end

	--
	function ENT:Think()
	end

	--
	function ENT:Draw()
		self:DrawModel()
	end

	language.Add("ent_jack_gmod_ezthermobaric", "EZ Thermobaric Bomb")
end
