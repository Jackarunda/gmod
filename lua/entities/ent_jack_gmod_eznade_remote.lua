-- Jackarunda 2019
AddCSLuaFile()
ENT.Base = "ent_jack_gmod_ezmininade"
ENT.Author="Jackarunda, TheOnly8Z"
ENT.PrintName="EZminiNade-Remote"
ENT.Category="JMod - EZ Explosives"
ENT.Spawnable=true

ENT.Material = "models/mats_jack_nades/gnd_blu"
ENT.MiniNadeDamageMin = 70
ENT.MiniNadeDamageMax = 100
ENT.Hints = {"grenade", "mininade", "grenade remote", "binding"}
ENT.JModRemoteTrigger=true

local BaseClass = baseclass.Get(ENT.Base)

if(SERVER)then

	function ENT:JModEZremoteTriggerFunc(ply)
		if IsValid(ply) and ply:Alive() and ply == self.Owner and self:GetState()==JMOD_EZ_STATE_ARMED then 
			self:Detonate()
		end
	end
	
	function ENT:Arm()
		self:SetState(JMOD_EZ_STATE_ARMING)
		self:SetBodygroup(2,1)
		timer.Simple(.1, function()
			if IsValid(self) then
				self:EmitSound("snd_jack_minearm.wav",60,110)
				self:SetState(JMOD_EZ_STATE_ARMED)
			end
		end)
		self:SpoonEffect()
	end
	
elseif(CLIENT)then
	language.Add("ent_jack_gmod_eznade_remote","EZminiNade-Remote")
end