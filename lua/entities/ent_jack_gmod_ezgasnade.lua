-- Jackarunda 2019
AddCSLuaFile()
ENT.Base="ent_jack_gmod_ezgrenade"
ENT.Author="Jackarunda, TheOnly8Z"
ENT.Category="JMod - EZ Explosives"
ENT.PrintName="EZ Gas Grenade"
ENT.Spawnable=true

ENT.Model = "models/grenades/gas_grenade.mdl"
ENT.SpoonModel = "models/grenades/gas_grenade_spoon.mdl"
ENT.ModelScale = 1.5

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
		self:SpoonEffect()
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
		for i=1,30 do
			timer.Simple(i/120,function()
				local Gas=ents.Create("ent_jack_gmod_ezgasparticle")
				Gas:SetPos(SelfPos)
				JMod_Owner(Gas,Owner)
				Gas:Spawn()
				Gas:Activate()
				Gas:GetPhysicsObject():SetVelocity(SelfVel+VectorRand()*math.random(1,200))
			end)
		end
        if IsValid(self.Owner) then JMod_Hint(self.Owner, "gas spread", self:GetPos()) end
		self:Remove()
	end
	
elseif(CLIENT)then
	language.Add("ent_jack_gmod_ezgasnade","EZ Gas Grenade")
end