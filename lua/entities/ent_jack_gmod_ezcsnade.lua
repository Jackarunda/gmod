-- Based off of JMOD Smoke Grenade, created by Freaking Fission
AddCSLuaFile()
ENT.Base = "ent_jack_gmod_ezgrenade"
ENT.Author = "Jackarunda, TheOnly8Z, Freaking Fission"
ENT.PrintName = "EZ Tear Gas Grenade"
ENT.Category = "JMod - EZ Misc."
ENT.Spawnable = true
ENT.JModPreferredCarryAngles = Angle(0, 100, 0)
ENT.Model = "models/jmod/explosives/grenades/firenade/incendiary_grenade.mdl"
ENT.Material = "models/mats_jack_nades/tear_gas_grenade"
ENT.SpoonScale = 2
ENT.PinBodygroup = {3, 1}
ENT.SpoonBodygroup = {2, 1}
ENT.DetDelay = 2

if SERVER then
	function ENT:Detonate()
		if self.Exploded then return end
		self.Exploded = true
		self.FuelLeft = 30
		self:EmitSound("snd_jack_fragsplodeclose.ogg", 70, 150)
	end

	function ENT:CustomThink()
		if self.Exploded then
			if self.FuelLeft > 0 then
				local Gas = ents.Create("ent_jack_gmod_ezcsparticle")
				Gas:SetPos(self:LocalToWorld(self:OBBCenter()))
				JMod.SetEZowner(Gas, self.EZowner or self)
				Gas:Spawn()
				Gas:Activate()
				Gas.Canister = self
				Gas.CurVel = self:GetPhysicsObject():GetVelocity() + self:GetUp() * math.random(10, 200)
				self:EmitSound("snd_jack_sss.ogg", 55, 80)
				self.FuelLeft = self.FuelLeft - 1

				if self.FuelLeft <= 0 then
					SafeRemoveEntityDelayed(self, 1)
				end
			end
		end
	end
elseif CLIENT then
	function ENT:Draw()
		self:DrawModel()
	end

	language.Add("ent_jack_gmod_ezcssnade", "EZ Tear Gas Grenade")
end
