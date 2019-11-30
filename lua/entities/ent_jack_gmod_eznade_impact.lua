-- Jackarunda 2019
AddCSLuaFile()
ENT.Base = "ent_jack_gmod_ezmininade"
ENT.Author="Jackarunda, TheOnly8Z"
ENT.Category="JMod - EZ"
ENT.PrintName="EZminiNade-Impact"
ENT.Spawnable=true

ENT.Material = "models/mats_jack_nades/gnd_blk"
ENT.MiniNadeDamageMin = 70
ENT.MiniNadeDamageMax = 100

local BaseClass = baseclass.Get(ENT.Base)

if(SERVER)then
	function ENT:PhysicsCollide(data,physobj)
		if data.DeltaTime>0.2 and data.Speed>200 and self:GetState() == JMOD_EZ_STATE_ARMED then
			self:Detonate()
		else
			BaseClass.PhysicsCollide(self, data, physobj)
		end
	end
elseif(CLIENT)then
	language.Add("ent_jack_gmod_eznade_impact","EZminiNade-Impact")
end