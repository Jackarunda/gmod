-- Jackarunda 2021
AddCSLuaFile()
ENT.Type = "anim"
ENT.Author = "TheOnly8Z"
ENT.PrintName = "EZ Satchel Charge Plunger"
ENT.Spawnable = false
ENT.NoSitAllowed = true
ENT.JModPreferredCarryAngles = Angle(0, 0, 0)

function ENT:SetupDataTables()
	self:NetworkVar("Bool", 0, "Fired")
end

if SERVER then
	function ENT:Initialize()
		--self:SetModel("models/grenades/satchel_charge_plunger.mdl")
		self:SetModel("models/hunter/blocks/cube025x025x025.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:DrawShadow(true)
		self:SetUseType(SIMPLE_USE)
		self.DieTime = nil
		self:SetFired(false)

		if self:GetPhysicsObject():IsValid() then
			self:GetPhysicsObject():SetMass(10)
			self:GetPhysicsObject():Wake()
		end

		if istable(WireLib) then
			--self.Inputs=WireLib.CreateInputs(self, {"Fire"}, {"Plunges the plunger"})
			self.Outputs = WireLib.CreateOutputs(self, {"State"}, {"Fired or not"})
		end
	end

	function ENT:TriggerInput(iname, value)
	end

	--if(iname == "Fire" and value > 0) then
	--	self:SetFired(true)
	--end
	function ENT:Use(activator, caller, typ, val)
		if not IsValid(activator) then return end

		if IsValid(self:GetParent()) then
			self:GetParent():Use(activator, caller, typ, val)

			return
		end

		self.EZowner = activator

		if JMod.IsAltUsing(activator) then
			if not IsValid(self.DetCable) then self:EmitSound("buttons/button4.wav") return end
			self:EmitSound("snds_jack_gmod/plunger.ogg")
			self:SetFired(true)

			timer.Simple(.5, function()
				if IsValid(self.Satchel) then
					self.Satchel:Detonate()
				end
			end)

			self.DieTime = CurTime() + 10
		else
			activator:PickupObject(self)
		end
	end

	function ENT:PhysicsCollide(data, physobj)
		if data.DeltaTime > 0.5 and data.Speed > 100 then
			--[[if data.Speed > 200 then
				self:EmitSound("Metal_Box.Break")
				self.DieTime = CurTime() + 2
			end--]]
			if data.HitEntity == self.Satchel then
				timer.Simple(0, function()
					if not (IsValid(self) and IsValid(self.Satchel)) then return end
					self:ForcePlayerDrop()
					self:SetPos(self.Satchel:GetPos() + self.Satchel:GetForward() * 5)
					self:SetAngles(self.Satchel:GetAngles())
					self:SetParent(data.HitEntity)
					if IsValid(self.DetCable) then
						self.DetCable:Remove()
					end
					data.HitEntity:SetState(JMod.EZ_STATE_OFF)
				end)
			end
		end
	end

	function ENT:Think()
		if istable(WireLib) then
			WireLib.TriggerOutput(self, "State", self:GetFired())
		end

		if not IsValid(self.Satchel) and self.DieTime == nil then
			self:Remove()
		elseif self.DieTime ~= nil and self.DieTime < CurTime() then
			self:Remove()
		end
	end

	function ENT:OnRemove()
		if IsValid(self.Satchel) then
			SafeRemoveEntity(self.Satchel)
		end
	end
elseif CLIENT then
	function ENT:Initialize()
		--self:SetBodygroup(2,1)
		self.Mdl = ClientsideModel("models/jmod/explosives/grenades/satchelcharge/satchel_charge_plunger.mdl")
		self.Mdl:SetModelScale(3, 0)
		self.Mdl:SetPos(self:GetPos())
		self.Mdl:SetParent(self)
		self.Mdl:SetNoDraw(true)
	end

	function ENT:Draw()
		--self:DrawModel()
		self.Mdl:SetRenderOrigin(self:GetPos() + self:GetForward() * 30 + self:GetUp() * 1.5)
		self.Mdl:SetRenderAngles(self:GetAngles())

		if self:GetFired() then
			self.Mdl:SetBodygroup(2, 1)
		end

		self.Mdl:DrawModel()
	end

	language.Add("ent_jack_gmod_ezsatchelcharge_plunger", "EZ Satchel Charge Plunger")
end
