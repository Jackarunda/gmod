-- Jackarunda 2021
AddCSLuaFile()
ENT.Base="ent_jack_gmod_ezgrenade"
ENT.Author="Jackarunda, TheOnly8Z"
ENT.Category="JMod - EZ Explosives"
ENT.PrintName="EZ Incendiary Grenade"
ENT.Spawnable=true

ENT.Model="models/jmodels/explosives/grenades/firenade/incendiary_grenade.mdl"
--ENT.ModelScale=1.5
ENT.SpoonModel="models/jmodels/explosives/grenades/firenade/incendiary_grenade_spoon.mdl"

if(SERVER)then

	function ENT:Prime()
		self:SetState(JMod.EZ_STATE_PRIMED)
		self:EmitSound("weapons/pinpull.wav", 60, 100)
		self:SetBodygroup(3, 1)
	end

	function ENT:Arm()
		self:SetBodygroup(2, 1)
		self:SetState(JMod.EZ_STATE_ARMED)
		timer.Simple(4,function()
			if(IsValid(self))then self:Detonate() end
		end)
		self:SpoonEffect()
	end

	function ENT:Detonate()
		if(self.Exploded)then return end
		self.Exploded=true
		local SelfPos, Owner, SelfVel=self:LocalToWorld(self:OBBCenter()), self.Owner or self,self:GetPhysicsObject():GetVelocity()
		local Boom=ents.Create("env_explosion")
		Boom:SetPos(SelfPos)
		Boom:SetKeyValue("imagnitude", "50")
		Boom:SetOwner(Owner)
		Boom:Spawn()
		Boom:Fire("explode", 0)
		for i=1, 25 do
			local FireVec=(self:GetVelocity()/500+VectorRand()*.3+Vector(0,0,.3)):GetNormalized()
			FireVec.z=FireVec.z/2
			local Flame=ents.Create("ent_jack_gmod_eznapalm")
			Flame:SetPos(SelfPos+Vector(0, 0, 10))
			Flame:SetAngles(FireVec:Angle())
			Flame:SetOwner(self.Owner or game.GetWorld())
			JMod.Owner(Flame, self.Owner or self)
			Flame.SpeedMul=self:GetVelocity():Length()/1000+.5
			Flame.Creator=self
			Flame.HighVisuals=true
			Flame:Spawn()
			Flame:Activate()
		end
		self:Remove()
	end
	
elseif(CLIENT)then
	language.Add("ent_jack_gmod_ezfirenade", "EZ Incendiary Grenade")
end