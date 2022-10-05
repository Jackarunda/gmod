AddCSLuaFile()
ENT.Type="anim"
ENT.Author="Jackarunda"
ENT.Information="glhfggwpezpznore"
ENT.PrintName="EZ Pumpjack"
ENT.Category="JMod - EZ Misc."
ENT.Spawnable=true
ENT.AdminOnly=false
ENT.Base="ent_jack_gmod_ezmachine_base"
---
ENT.Model="models/hunter/blocks/cube4x4x1.mdl"
ENT.Mass=3000
ENT.SpawnHeight = 100
---
ENT.WhitelistedResources = {JMod.EZ_RESOURCE_TYPES.WATER, JMod.EZ_RESOURCE_TYPES.OIL}
---
ENT.EZupgradable=true
ENT.StaticPerfSpecs={
	MaxDurability=200,
	MaxElectricity=200,
}
ENT.DynamicPerfSpecs={
	Armor=5,
	PumpRate = 1
}
---
local STATE_BROKEN,STATE_OFF,STATE_RUNNING=-1,0,1
---
function ENT:CustomSetupDataTables()
	self:NetworkVar("Float", 1, "Fuel")
	self:NetworkVar("Float", 2, "Progress")
end
if(SERVER)then
	function ENT:CustomInit()
		self:SetAngles(Angle(0,0,-90))
		self:SetProgress(0)
		self:SetState(STATE_OFF)
		self.NextCalcThink=0
	end
	function ENT:TurnOn(activator)
		if self:GetElectricity() > 0 then
			self:SetState(STATE_RUNNING)
			self.SoundLoop = CreateSound(self, "snds_jack_gmod/pumpjack_start_loop.wav")
			self.SoundLoop:SetSoundLevel(65)
			self.SoundLoop:Play()
			self.SoundLoop:SetSoundLevel(65)
			self:SetProgress(0)
		else
			JMod.Hint(activator, "nopower")
		end
	end

	function ENT:TurnOff()
		self:SetState(STATE_OFF)

		if self.SoundLoop then
			self.SoundLoop:Stop()
		end

		self:EmitSound("snds_jack_gmod/pumpjack_stop.wav")
	end

	function ENT:Use(activator)
		local State=self:GetState()
		local OldOwner=self.Owner
		JMod.Owner(self,activator)
		if(IsValid(self.Owner))then
			if(OldOwner~=self.Owner)then -- if owner changed then reset team color
				JMod.Colorify(self)
			end
		end

		if State == STATE_BROKEN then
			JMod.Hint(activator, "destroyed", self)

			return
		elseif(State==STATE_OFF)then
			self:TryPlace()
		elseif(State==STATE_RUNNING)then

			self:TurnOff()
		end
	end
	function ENT:OnRemove()
		if(self.SoundLoop)then self.SoundLoop:Stop() end
	end
	function ENT:ConsumeFuel()
	end
	function ENT:Think()
		local State,Time=self:GetState(),CurTime()
		if(self.NextCalcThink<Time)then
			self.NextCalcThink=Time+1
			if(State==STATE_BROKEN)then
				if(self.SoundLoop)then self.SoundLoop:Stop() end
				if(self:GetElectricity()>0)then
					if(math.random(1,4)==2)then JMod.DamageSpark(self) end
				end

				if not IsValid(self.Weld) then
					self.Weld = nil
					self:TurnOff()

					return
				end

				self:ConsumeFuel(1)
				-- This is just the rate at which we pump
				local pumpRate = self.PumpRate^2
				-- Here's where we do the rescource deduction, and barrel production
				-- If it's a flow (i.e. water)
				if JMod.NaturalResourceTable[self.DepositKey].rate then
					-- We get the rate
					local flowRate = JMod.NaturalResourceTable[self.DepositKey].rate
					-- and set the progress to what it was last tick + our ability * the flowrate
					self:SetProgress(self:GetProgress() + pumpRate * flowRate)

					-- If the progress exceeds 100
					if self:GetProgress() >= 100 then
						-- Spawn barrel
						self:SpawnBarrel(100, self.DepositKey)
						self:SetProgress(0)
					end
				else
					self:SetProgress(self:GetProgress() + pumpRate)

					if self:GetProgress() >= 100 then
						local amtToPump = math.min(JMod.NaturalResourceTable[self.DepositKey].amt, 100)
						self:SpawnBarrel(amtToPump)
						self:SetProgress(0)
					end
				end

				JMod.EmitAIsound(self:GetPos(), 300, .5, 256)
			end
		end
		return true
	end

elseif(CLIENT)then
	language.Add("ent_jack_gmod_ezrefinery", "EZ Refinery")
end
