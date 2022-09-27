-- Jackarunda 2021
AddCSLuaFile()
ENT.Base = "ent_jack_gmod_ezmininade"
ENT.Author = "Jackarunda, TheOnly8Z"
ENT.PrintName = "EZminiNade-Timed"
ENT.Category = "JMod - EZ Explosives"
ENT.Spawnable = true
ENT.Material = "models/mats_jack_nades/gnd_ylw"

ENT.Hints = {"mininade"}

local BaseClass = baseclass.Get(ENT.Base)

if SERVER then
	function ENT:Arm()
		self:SetBodygroup(2, 1)
		self:SetState(JMod.EZ_STATE_ARMED)

		timer.Simple(IsValid(self.AttachedBomb) and 10 or 3, function()
			if IsValid(self) then
				self:Detonate()
			end
		end)

		self:SpoonEffect()
	end
elseif CLIENT then
	language.Add("ent_jack_gmod_eznade_timed", "EZminiNade-Timed")
end
