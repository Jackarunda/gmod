-- Jackarunda 2021
AddCSLuaFile()
ENT.Base = "ent_jack_gmod_ezgrenade"
ENT.Author = "Jackarunda, TheOnly8Z"
ENT.Information = "glhfggwpezpznore"
ENT.PrintName = "EZ Mininade Base"
ENT.Spawnable = false
ENT.JModPreferredCarryAngles = Angle(0, -140, 0)
ENT.Model = "models/jmod/explosives/grenades/minifragnade/w_minifragjade.mdl"
ENT.Material = "models/mats_jack_nades/gnd"
ENT.MiniNadeDamage = 100
ENT.Mass = 7
local BaseClass = baseclass.Get(ENT.Base)

if SERVER then
	function ENT:Initialize()
		BaseClass.Initialize(self)
		self.LastVel = Vector(0, 0, 0)
		self.NextDet = 0
	end

	function ENT:OnTakeDamage(dmginfo)
		self:TakePhysicsDamage(dmginfo)

		if dmginfo:GetInflictor() ~= self and dmginfo:GetDamage() >= 5 and not self.Exploded and self:GetState() ~= JMod.EZ_STATE_BROKEN then
			self:EmitSound("physics/metal/metal_box_impact_bullet2.wav", 75, 200)
			self:SetState(JMod.EZ_STATE_BROKEN)
			local eff = EffectData()
			eff:SetOrigin(self:GetPos())
			eff:SetScale(1) -- how far
			eff:SetRadius(8) -- how thick
			eff:SetMagnitude(4) -- how much
			util.Effect("Sparks", eff)
			SafeRemoveEntity(self)
		end
	end

	function ENT:Use(activator, activatorAgain, onOff)
		if self.Exploded then return end
		local Dude = activator or activatorAgain
		JMod.SetEZowner(self, Dude)
		JMod.Hint(Dude, self.ClassName)
		local Time = CurTime()
		if self.ShiftAltUse and JMod.IsAltUsing(Dude) and Dude:KeyDown(IN_SPEED) then return self:ShiftAltUse(Dude, tobool(onOff)) end

		if tobool(onOff) then
			local State = self:GetState()
			if State < 0 then return end
			local Alt = JMod.IsAltUsing(Dude)

			if State == JMod.EZ_STATE_OFF and Alt then
				self:Prime()
				JMod.Hint(Dude, "grenade")
			else
				JMod.Hint(Dude, "prime")
			end

			if self.Hints then
				for k, v in pairs(self.Hints) do
					timer.Simple(k, function()
						if IsValid(Dude) then
							JMod.Hint(Dude, v)
						end
					end)
				end
			end

			JMod.ThrowablePickup(Dude, self, self.HardThrowStr, self.SoftThrowStr)
		end
	end

	function ENT:PhysicsCollide(data, physobj)
		if (not IsValid(self.AttachedBomb)) and self:IsPlayerHolding() and data.HitEntity.EZdetonateOverride then
			self:EmitSound("Grenade.ImpactHard")
			self:SetPos(data.HitPos - data.HitNormal)
			self.AttachedBomb = data.HitEntity
			self.LastVel = data.HitEntity:GetVelocity()

			timer.Simple(0, function()
				self:SetParent(data.HitEntity)
			end)
		else
			BaseClass.PhysicsCollide(self, data, physobj)
		end
	end

	function ENT:Detonate()
		if self.Exploded then return end
		self.Exploded = true
		local SelfPos = self:GetPos()

		if IsValid(self.AttachedBomb) then
			JMod.SetEZowner(self.AttachedBomb, self.EZowner or self.AttachedBomb.EZowner or game.GetWorld())
			self.AttachedBomb:EZdetonateOverride(self)
			JMod.Sploom(self.EZowner, SelfPos, 3)
			self:Remove()

			return
		end

		JMod.Sploom(self.EZowner, SelfPos, self.MiniNadeDamage, self.MiniNadeDamageMax)
		util.ScreenShake(SelfPos, 20, 20, 1, 500)
		self:Remove()
	end
elseif CLIENT then
end
