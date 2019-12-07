-- Jackarunda 2019
AddCSLuaFile()
ENT.Base = "ent_jack_gmod_ezmininade"
ENT.Author="Jackarunda, TheOnly8Z"
ENT.Category="JMod - EZ"
ENT.PrintName="EZminiNade-Impact"
ENT.Spawnable=true

ENT.Material = "models/mats_jack_nades/gnd_blk"
ENT.MiniNadeDamageMin = 70
ENT.MiniNadeDamageMax = 110

local BaseClass = baseclass.Get(ENT.Base)

if(SERVER)then
	function ENT:PhysicsCollide(data,physobj)
		if data.DeltaTime>0.2 and data.Speed>200 and self:GetState() == JMOD_EZ_STATE_ARMED then
			self:Detonate()
		else
			BaseClass.PhysicsCollide(self, data, physobj)
		end
	end
	
	function ENT:Arm()
		self:SetState(JMOD_EZ_STATE_ARMING)
		timer.Simple(.3, function()
			if IsValid(self) then
				self:SetState(JMOD_EZ_STATE_ARMED)
			end
		end)
		self:PinEffect()
	end
	
	function ENT:CustomThink(state,tim)
		if(state==JMOD_EZ_STATE_ARMED)then
			if(IsValid(self.AttachedBomb))then
				if(self.AttachedBomb:IsPlayerHolding())then self.NextDet=tim+.5 end
				local CurVel=self.AttachedBomb:GetPhysicsObject():GetVelocity()
				local Change=CurVel:Distance(self.LastVel)
				self.LastVel=CurVel
				if(Change>300)then
					if(self.NextDet<tim)then self:Detonate() end
					return
				end
				self:NextThink(tim+.1)
				return true
			end
		end
	end
	
elseif(CLIENT)then
	language.Add("ent_jack_gmod_eznade_impact","EZminiNade-Impact")
end