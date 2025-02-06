-- Jackarunda early 2025
AddCSLuaFile()
ENT.Type = "anim"
ENT.PrintName = "EZ Bubble Shield Generator"
ENT.Author = "Jackarunda"
ENT.Category = "JMod - EZ Machines"
ENT.Information = ""
ENT.Spawnable = false
ENT.AdminOnly = false
ENT.Base = "ent_jack_gmod_ezmachine_base"
ENT.Model = "models/jmod/bubble_shield_generator.mdl"
---
ENT.EZupgradable = true
ENT.JModPreferredCarryAngles = Angle(0, 0, 0)
ENT.Mass = 200
ENT.SpawnHeight = 1
ENT.EZcolorable = true
--
ENT.StaticPerfSpecs = {
	--
}
ENT.DynamicPerfSpecs = {
	MaxElectricity = 100,
	MaxShieldStrength = 1,
	ChargeSpeed = 5
}
ENT.EZconsumes = {
	JMod.EZ_RESOURCE_TYPES.POWER
}

function ENT:CustomSetupDataTables()
	self:NetworkVar("Float", 1, "Electricity")
	self:NetworkVar("Float", 2, "ShieldStrength")
	self:NetworkVar("Float", 3, "ShieldProgress")
end

local STATE_BROKEN, STATE_OFF, STATE_CHARGING, STATE_ON = -1, 0, 1, 2

if(SERVER)then
	function ENT:CustomInit()
		self:SetElectricity(0)
		self:SetShieldStrength(0)
		self:SetShieldProgress(0)
		self.NextUseTime = 0
		self.NextEffThink = 0
		if self.SpawnFull then
			self:SetElectricity(self.MaxElectricity)
		end
		self.Established = {
			Pos = nil,
			Norm = nil,
			Anchor = nil, -- entity
			OnWorld = false
		}
	end

	function ENT:Use(activator)
		if self.NextUseTime > CurTime() then return end
		local State = self:GetState()
		local alt = JMod.IsAltUsing(activator)
		JMod.SetEZowner(self, activator)
		JMod.Colorify(self)

		if State == STATE_BROKEN then
			JMod.Hint(activator, "destroyed", self)
			return
		elseif State == STATE_OFF then
			self:TurnOn(activator)
		elseif State == STATE_ON then
			self:TurnOff()
		end
	end

	function ENT:EstablishSelf(activator)
		local SelfPos = self:GetPos()
		local Tr = util.QuickTrace(SelfPos + Vector(0, 0, 100), Vector(0, 0, -300), {self, activator})
		if (Tr.Hit) then
			if (Tr.HitWorld) then
				self.Established.Pos = Tr.HitPos
				self.Established.Norm = Tr.HitNormal
				self.Established.OnWorld = true
				self:GetPhysicsObject():SetVelocity(Vector(0, 0, 0))
				self:GetPhysicsObject():EnableMotion(false)
				return true
			end
			if (Tr.Entity and Tr.Entity.GetPhysicsObject) then
				local Phys = Tr.Entity:GetPhysicsObject()
				if (IsValid(Phys) and Phys.GetMass) then
					if (Phys:GetMass() >= 5000) and not(Phys:IsMotionEnabled()) then
						self.Established.Pos = Tr.HitPos
						self.Established.Norm = Tr.HitNormal
						self.Established.Anchor = Tr.Entity
						self.Established.OnWorld = false
						local Welded = constraint.Weld(self, Tr.Entity, 0, 0, 0, true)
						return true
					end
				end
			end
		end
		return false
	end

	function ENT:TurnOn(activator)
		if self:GetState() > STATE_OFF then return end
		if (self:GetElectricity() > 0) then
			self.NextUseTime = CurTime() + 1
			if (self:EstablishSelf(activator)) then
				self:EmitSound("snds_jack_gmod/electrical_start_charge.ogg", 60, 100 * self.ChargeSpeed)
				self:SetState(STATE_CHARGING)
				self.BaseSoundLoop = CreateSound(self, "snds_jack_gmod/electric_machine_low_hum_loop.wav")
				self.BaseSoundLoop:SetSoundLevel(65)
				self.BaseSoundLoop:PlayEx(.5, 100)
				self.BaseSoundLoop:SetSoundLevel(65)
			else
				self:EmitSound("buttons/button10.wav", 60, 100)
				-- todo: hint as to why we can't start
			end
		else
			self.NextUseTime = CurTime() + 1
			JMod.Hint(activator, "nopower")
		end
	end

	function ENT:TurnOff(activator)
		if (self:GetState() <= 0) then return end
		self.NextUseTime = CurTime() + 1
		self:ShieldBreak()
		if self.BaseSoundLoop then self.BaseSoundLoop:Stop() end
		self:EmitSound("snds_jack_gmod/electrical_forced_shut_off.ogg", 70, 100)
		self:SetState(STATE_OFF)
		self:SetShieldProgress(0)
		self:SetShieldStrength(0)
	end

	function ENT:OnRemove()
		if self.BaseSoundLoop then self.BaseSoundLoop:Stop() end
		if self.ShieldSoundLoop then self.ShieldSoundLoop:Stop() end
		if (IsValid(self.Shield)) then self.Shield:Remove() end
	end

	function ENT:EstablishShield()
		if (self:GetState() == STATE_ON) then return end
		self:SetState(STATE_ON)
		self:SetShieldStrength(self.MaxShieldStrength)
		self.ShieldSoundLoop = CreateSound(self, "snds_jack_gmod/bubble_shield_start_loop.wav")
		self.ShieldSoundLoop:SetSoundLevel(75)
		self.ShieldSoundLoop:Play()
		self.ShieldSoundLoop:SetSoundLevel(75)
		if (IsValid(self.Shield))then self.Shield:Remove() end
		local Pos = self:GetPos() - self:GetUp() * 120
		self.Shield = ents.Create("ent_jack_gmod_bubble_shield")
		self.Shield:SetPos(Pos)
		self.Shield.Projector = self
		self.Shield:SetSizeClass(self:GetGrade())

		local ShieldStrength = 1000 -- todo: based on grade
		self.Shield:SetMaxStrength(ShieldStrength)
		self.Shield:SetStrength(ShieldStrength)

		self.Shield:Spawn()
		self.Shield:Initialize()
	end

	function ENT:ShieldBreak()
		if (self:GetState() ~= STATE_ON) then return end
		if self.ShieldSoundLoop then self.ShieldSoundLoop:Stop() end
		self:EmitSound("snds_jack_gmod/bubble_shield_break.ogg", 80, 100)
		if (IsValid(self.Shield)) then self.Shield:Remove() end
		self:SetState(STATE_CHARGING)
		self:SetShieldProgress(0)
	end

	function ENT:OnBreak()
		self:ShieldBreak()
		if self.BaseSoundLoop then self.BaseSoundLoop:Stop() end
	end

	function ENT:Think()
		local Time, State, Grade = CurTime(), self:GetState(), self:GetGrade()

		--print(State, "elec", self:GetElectricity(), "prog", self:GetShieldProgress(), "streng", self:GetShieldStrength())

		self:UpdateWireOutputs()

		if (State == STATE_ON) then
			--self:ConsumeElectricity(.1)
			if not (IsValid(self.Shield)) then
				self:ShieldBreak()
			else
				-- slowly recharge the shield's strength for extra electricity consumption
			end
		elseif (State == STATE_CHARGING) then
			local Progress = self:GetShieldProgress()
			if (Progress >= 100) then
				self:EstablishShield()
			else
				self:SetShieldProgress(Progress + 5 * self.ChargeSpeed)
				self:ConsumeElectricity(1 * self.ChargeSpeed)
			end
		end

		self:NextThink(Time + .5)
		return true
	end

	function ENT:OnPostEntityPaste(ply, ent, createdEntities)
		local Time = CurTime()
		self.NextUseTime = Time + math.Rand(0, 3)
	end

elseif(CLIENT)then
	function ENT:CustomInit()
		self:DrawShadow(true)
		self.BaseGear = JMod.MakeModel(self, "models/Mechanics/gears/gear24x6.mdl")
	end

	function ENT:Draw()
		local SelfPos, SelfAng, State = self:GetPos(), self:GetAngles(), self:GetState()
		local Up, Right, Forward = SelfAng:Up(), SelfAng:Right(), SelfAng:Forward()
		local Grade = self:GetGrade()
		---
		local BasePos = SelfPos
		local Obscured = false--util.TraceLine({start = EyePos(), endpos = BasePos, filter = {LocalPlayer(), self}, mask = MASK_OPAQUE}).Hit
		local Closeness = LocalPlayer():GetFOV() * (EyePos():Distance(SelfPos))
		local DetailDraw = Closeness < 1200000 -- cutoff point is 400 units when the fov is 90 degrees
		---
		if((not(DetailDraw)) and (Obscured))then return end -- if player is far and sentry is obscured, draw nothing
		if(Obscured)then DetailDraw = false end -- if obscured, at least disable details
		if(State == STATE_BROKEN)then DetailDraw = false end -- look incomplete to indicate damage, save on gpu comp too
		---
		self:DrawModel()
		---
		if (self.BaseGear) then
			self.BaseGear:SetMaterial(JMod.EZ_GRADE_MATS[Grade]:GetName())
			JMod.RenderModel(self.BaseGear, BasePos - Up * 100, SelfAng)
		end

		if DetailDraw then
			if Closeness < 20000 and State == STATE_ON then
				local DisplayAng = SelfAng:GetCopy()
				DisplayAng:RotateAroundAxis(DisplayAng:Right(), 0)
				DisplayAng:RotateAroundAxis(DisplayAng:Up(), 0)
				DisplayAng:RotateAroundAxis(DisplayAng:Forward(), 45)
				local Opacity = math.random(50, 150)
				local ShieldAmt = self:GetShieldStrength()
				local ElecAmt = self:GetElectricity()

				cam.Start3D2D(SelfPos - Forward * 15 + Right * 8 - Up * 40, DisplayAng, .06)
				surface.SetDrawColor(10, 10, 10, Opacity + 50)
				local RankX, RankY = 300, 30
				surface.DrawRect(RankX, RankY, 128, 128)
				JMod.StandardRankDisplay(Grade, RankX + 62, RankY + 68, 118, Opacity + 50)
				draw.SimpleTextOutlined("SHIELD STRENGTH", "JMod-Display", 200, 0, Color(255, 255, 255, Opacity), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, Opacity))
				draw.SimpleTextOutlined(tostring(math.Round(ShieldAmt)), "JMod-Display", 200, 30, Color(255, 255, 255, Opacity), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, Opacity))
				draw.SimpleTextOutlined("ELECTRICITY", "JMod-Display", 200, 90, Color(255, 255, 255, Opacity), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, Opacity))
				draw.SimpleTextOutlined(tostring(math.Round(ElecAmt)), "JMod-Display", 200, 120, Color(255, 255, 255, Opacity), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, Opacity))
				cam.End3D2D()
			end
		end
	end
	language.Add("ent_jack_gmod_ezshieldgen", "EZ Bubble Shield Generator")
end
