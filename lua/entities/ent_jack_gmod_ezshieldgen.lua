-- Jackarunda early 2025
AddCSLuaFile()
ENT.Type = "anim"
ENT.PrintName = "EZ Bubble Shield Generator"
ENT.Author = "Jackarunda"
ENT.Category = "JMod - EZ Machines"
ENT.Information = ""
ENT.Spawnable = true
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
	ElectricityToShieldStrengthConversion = .045
}
ENT.DynamicPerfSpecs = {
	MaxElectricity = 200,
	MaxCoolant = 100,
	MaxShieldStrengthMult = 1,
	ChargeMult = 1
}
ENT.EZconsumes = {
	JMod.EZ_RESOURCE_TYPES.POWER,
	JMod.EZ_RESOURCE_TYPES.BASICPARTS,
	JMod.EZ_RESOURCE_TYPES.COOLANT
}

function ENT:CustomSetupDataTables()
	self:NetworkVar("Float", 1, "ShieldChargeProgress")
	self:NetworkVar("Float", 2, "Coolant")
end

local STATE_BROKEN, STATE_OFF, STATE_CHARGING, STATE_ON = -1, 0, 1, 2

if(SERVER)then
	function ENT:CustomInit()
		self:SetShieldChargeProgress(0)
		self.NextUseTime = 0
		self.NextEffThink = 0
		self.Established = {
			Pos = nil,
			Norm = nil,
			Anchor = nil, -- entity
			OnWorld = false
		}
		self.NextAlarm = 0
		self.Temperature = 0
		if self.SpawnFull then
			self:SetElectricity(self.MaxElectricity)
			self:SetCoolant(self.MaxCoolant)
		end
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
		elseif (State == STATE_ON or State == STATE_CHARGING) and alt then
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
						self:GetPhysicsObject():SetVelocity(Vector(0, 0, 0))
						self:GetPhysicsObject():EnableMotion(false)
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
				self:EmitSound("snds_jack_gmod/electrical_start_charge.ogg", 60, 100)
				self:SetState(STATE_CHARGING)
				self.BaseSoundLoop = CreateSound(self, "snds_jack_gmod/electric_machine_low_hum_loop.wav")
				self.BaseSoundLoop:SetSoundLevel(65)
				self.BaseSoundLoop:PlayEx(.5, 100)
				self.BaseSoundLoop:SetSoundLevel(65)
			else
				self:EmitSound("buttons/button10.wav", 60, 100)
				JMod.Hint(activator, "shield genny base")
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
		self:SetShieldChargeProgress(0)
	end

	function ENT:OnRemove()
		if self.BaseSoundLoop then self.BaseSoundLoop:Stop() end
		if self.ShieldSoundLoop then self.ShieldSoundLoop:Stop() end
		local Shield = self.Shield
		timer.Simple(0, function()
			if (IsValid(Shield)) then Shield:Break() end
		end)
	end

	function ENT:EstablishShield()
		if (self:GetState() == STATE_ON) then return end
		self:SetState(STATE_ON)
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

		local ShieldStrength = 1000 * self.MaxShieldStrengthMult ^ 2
		self.Shield:SetMaxStrength(ShieldStrength)
		self.Shield:SetStrength(ShieldStrength)

		self.Shield:Spawn()
		self.Shield:Activate()
	end

	function ENT:ShieldBreak()
		if self.ShieldSoundLoop then self.ShieldSoundLoop:Stop() end
		if (IsValid(self.Shield)) then self.Shield:Break() end
		self:SetState(STATE_CHARGING)
		self:SetShieldChargeProgress(0)
	end

	function ENT:OnBreak()
		self:ShieldBreak()
		if self.BaseSoundLoop then self.BaseSoundLoop:Stop() end
	end

	function ENT:Alarm()
		self:EmitSound("snds_jack_gmod/klaxon_alarm_short.ogg", 80, 100)
		local Eff = EffectData()
		Eff:SetOrigin(self:GetPos() - Vector(0, 0, 40))
		util.Effect("eff_jack_gmod_redflash", Eff, true, true)
	end

	function ENT:Think()
		local Time, State, Grade, CurCoolant = CurTime(), self:GetState(), self:GetGrade(), self:GetCoolant()
		self:UpdateWireOutputs()
		if (self.Temperature > 25) then
			local Cool = (CurCoolant > 1 and 1) or 2
			local Eff = EffectData()
			Eff:SetOrigin(self:GetPos() - Vector(0, 0, 60))
			Eff:SetScale(self.Temperature / 100)
			Eff:SetColor(Cool)
			util.Effect("eff_jack_gmod_shieldgenoverheat", Eff, true, true)
		end
		if (CurCoolant > 0) then
			self.Temperature = math.Clamp(self.Temperature ^ .99 - .2, 0, 100)
		else
			self.Temperature = math.Clamp(self.Temperature ^ .995 - .1, 0, 100)
		end
		if (State == STATE_ON) then
			if (self:WaterLevel() > 0) then self:TurnOff() return end
			if (self:GetPhysicsObject():IsMotionEnabled()) then self:TurnOff() return end
			if not (IsValid(self.Shield)) then
				self:ShieldBreak()
			else
				local MaxChargingCapability = 2.5 * self.ChargeMult
				if (CurCoolant > 0) then MaxChargingCapability = MaxChargingCapability * 2 end
				local Accepted = self.Shield:AcceptRecharge(MaxChargingCapability)
				-- jprint("added", Accepted, "coolnt", CurCoolant, "elec", self:GetElectricity(), "str", self.Shield:GetStrength())
				if (Accepted > 0) then
					self:ConsumeElectricity(Accepted * self.ElectricityToShieldStrengthConversion)
					if (Accepted > 3) then self.Temperature = self.Temperature + 1.5 end
					if (Accepted > 6) then -- high-power mode, push it to the limit
						self:SetCoolant(math.Clamp(CurCoolant - math.Rand(.4, .6), 0, self.MaxCoolant))
					end
				end
				if (((self:GetElectricity() / self.MaxElectricity) < .15) or (self.Shield:GetStrength() < 100)) then
					if (self.NextAlarm < Time) then
						self.NextAlarm = Time + .25
						self:Alarm()
					end
				end
			end
		elseif (State == STATE_CHARGING) then
			local Progress = self:GetShieldChargeProgress()
			if (Progress >= 1000 * self.MaxShieldStrengthMult ^ 2) then
				self:EstablishShield()
			else
				local ChargeAmt, CurCoolant = 10, self:GetCoolant()
				if (CurCoolant > 0) then
					self:SetCoolant(math.Clamp(CurCoolant - math.Rand(.4, .8), 0, self.MaxCoolant))
					ChargeAmt = 20
				end
				self.Temperature = self.Temperature + 1
				self:SetShieldChargeProgress(Progress + ChargeAmt)
				self:ConsumeElectricity(ChargeAmt * self.ElectricityToShieldStrengthConversion)
			end
		end

		self:NextThink(Time + .25)
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
		self.Plate = JMod.MakeModel(self, "models/hunter/plates/plate1x2.mdl")
	end

	function ENT:Draw()
		local SelfPos, SelfAng, State = self:GetPos(), self:GetAngles(), self:GetState()
		local Up, Right, Forward = SelfAng:Up(), SelfAng:Right(), SelfAng:Forward()
		local Grade = self:GetGrade()
		---
		local BasePos = SelfPos
		local Obscured = false -- util.TraceLine({start = EyePos(), endpos = BasePos, filter = {LocalPlayer(), self}, mask = MASK_OPAQUE}).Hit
		local Closeness = LocalPlayer():GetFOV() * (EyePos():Distance(SelfPos))
		local DetailDraw = Closeness < 1200000 -- cutoff point is 400 units when the fov is 90 degrees
		---
		if((not(DetailDraw)) and (Obscured))then return end -- if player is far and sentry is obscured, draw nothing
		if(Obscured)then DetailDraw = false end -- if obscured, at least disable details
		if(State == STATE_BROKEN)then DetailDraw = false end -- look incomplete to indicate damage, save on gpu comp too
		---
		self:DrawModel()
		---
		if IsValid(self.BaseGear) then
			self.BaseGear:SetMaterial(JMod.EZ_GRADE_MATS[Grade]:GetName())
			JMod.RenderModel(self.BaseGear, BasePos - Up * 100, SelfAng)
		end
		if (self.Plate) then
			self.Plate:SetMaterial(JMod.EZ_GRADE_MATS[Grade]:GetName())
			local PlateAng = SelfAng:GetCopy()
			PlateAng:RotateAroundAxis(Up, 90)
			PlateAng:RotateAroundAxis(Forward, 45)
			JMod.RenderModel(self.Plate, BasePos - Up * 46 + Right * 10, PlateAng, Vector(.3, .25, .5))
		end

		if DetailDraw then
			if Closeness < 20000 and State > 0 then
				local DisplayAng = SelfAng:GetCopy()
				--DisplayAng:RotateAroundAxis(DisplayAng:Right(), 0)
				--DisplayAng:RotateAroundAxis(DisplayAng:Up(), 0)
				DisplayAng:RotateAroundAxis(DisplayAng:Forward(), 45)
				local Opacity = math.random(50, 150)
				local ElecAmt = self:GetElectricity()
				local CoolAmt = self:GetCoolant()
				local ChargeAmt = self:GetShieldChargeProgress()

				cam.Start3D2D(SelfPos - Forward * 15 + Right * 8 - Up * 42, DisplayAng, .06)
				surface.SetDrawColor(10, 10, 10, Opacity + 50)
				local RankX, RankY = 300, 30
				surface.DrawRect(RankX, RankY, 128, 128)
				JMod.StandardRankDisplay(Grade, RankX + 62, RankY + 68, 118, Opacity + 50)
				draw.SimpleTextOutlined("ELECTRICITY", "JMod-Display", 190, -10, Color(255, 255, 255, Opacity), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, Opacity))
				draw.SimpleTextOutlined(tostring(math.Round(ElecAmt)), "JMod-Display", 190, 20, Color(255, 255, 255, Opacity), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, Opacity))
				draw.SimpleTextOutlined("COOLANT", "JMod-Display", 190, 60, Color(255, 255, 255, Opacity), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, Opacity))
				draw.SimpleTextOutlined(tostring(math.Round(CoolAmt)), "JMod-Display", 190, 90, Color(255, 255, 255, Opacity), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, Opacity))
				if (State == STATE_CHARGING) then draw.SimpleTextOutlined("Charging... "..tostring(math.Round(ChargeAmt)), "JMod-Display", 190, 150, Color(255, 255, 255, Opacity), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, Opacity)) end
				cam.End3D2D()
			end
		end
	end
	language.Add("ent_jack_gmod_ezshieldgen", "EZ Bubble Shield Generator")
end
