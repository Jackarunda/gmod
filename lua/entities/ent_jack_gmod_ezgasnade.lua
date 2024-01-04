-- Jackarunda 2021
AddCSLuaFile()
ENT.Base = "ent_jack_gmod_ezgrenade"
ENT.Author = "Jackarunda, TheOnly8Z"
ENT.Category = "JMod - EZ Misc."
ENT.PrintName = "EZ Gas Grenade"
ENT.Spawnable = true
ENT.Model = "models/jmod/explosives/grenades/gasnade/gas_grenade.mdl"
ENT.SpoonModel = "models/jmod/explosives/grenades/gasnade/gas_grenade_spoon.mdl"
ENT.PinBodygroup = {3, 1}
ENT.SpoonBodygroup = {2, 1}
ENT.DetDelay = 4

--ENT.ModelScale=1.5
if SERVER then
	function ENT:Detonate()
		if self.Exploded then return end
		self.Exploded = true
		local SelfPos, Owner, SelfVel = self:LocalToWorld(self:OBBCenter()), self.EZowner or self, self:GetPhysicsObject():GetVelocity()
		local Boom = ents.Create("env_explosion")
		Boom:SetPos(SelfPos)
		Boom:SetKeyValue("imagnitude", "50")
		Boom:SetOwner(Owner)
		Boom:Spawn()
		Boom:Fire("explode", 0)

		for i = 1, 30 do
			timer.Simple(i / 120, function()
				local Gas = ents.Create("ent_jack_gmod_ezgasparticle")
				Gas:SetPos(SelfPos)
				JMod.SetEZowner(Gas, Owner)
				Gas:Spawn()
				Gas:Activate()
				Gas.CurVel = (SelfVel + VectorRand() * math.random(1, 200))
			end)
		end

		if IsValid(self.EZowner) then
			JMod.Hint(JMod.GetEZowner(self), "gas spread", self:GetPos())
		end

		self:Remove()
	end
elseif CLIENT then
	language.Add("ent_jack_gmod_ezgasnade", "EZ Gas Grenade")
end
