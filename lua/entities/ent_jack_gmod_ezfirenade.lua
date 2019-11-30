-- Jackarunda 2019
AddCSLuaFile()
ENT.Base="ent_jack_gmod_ezgrenade"
ENT.Author="Jackarunda, TheOnly8Z"
ENT.Category="JMod - EZ Explosives"
ENT.PrintName="EZ Incendiary Grenade"
ENT.Spawnable=true

ENT.Model = "models/codww2/equipment/m14 incendiary grenade.mdl"
ENT.SpoonModel = "models/codww2/equipment/m14 incendiary grenade spoon.mdl"

if(SERVER)then

	function ENT:Prime()
		self:SetState(JMOD_EZ_STATE_PRIMED)
		self:EmitSound("weapons/pinpull.wav",60,100)
		self:SetBodygroup(3,1)
	end

	function ENT:Arm()
		self:SetBodygroup(2,1)
		self:SetState(JMOD_EZ_STATE_ARMED)
		timer.Simple(4,function()
			if(IsValid(self))then self:Detonate() end
		end)
	end

	function ENT:Detonate()
		if(self.Exploded)then return end
		self.Exploded=true
		local SelfPos,Owner,SelfVel=self:LocalToWorld(self:OBBCenter()),self.Owner or self,self:GetPhysicsObject():GetVelocity()
		local Boom=ents.Create("env_explosion")
		Boom:SetPos(SelfPos)
		Boom:SetKeyValue("imagnitude","50")
		Boom:SetOwner(Owner)
		Boom:Spawn()
		Boom:Fire("explode",0,"")
		for i=1,15 do
			local FireAng=(VectorRand()*Vector(0.5,0.5,0)+Vector(0,0,0.5)*(-math.random())):Angle()
			local Flame=ents.Create("ent_jack_gmod_eznapalm")
			Flame:SetPos(SelfPos+Vector(0,0,20))
			Flame:SetAngles(FireAng)
			Flame:SetOwner(self.Owner or game.GetWorld())
			Flame.Owner=self.Owner or self
			Flame:Spawn()
			Flame:Activate()
		end
		self:Remove()
	end
	
elseif(CLIENT)then
	language.Add("ent_jack_gmod_ezfirenade","EZ Incendiary Grenade")
end