AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "EZ Fluid Bottler"
ENT.Author = "Jackarunda, AdventureBoots"
ENT.Category = "JMod - EZ Machines"
ENT.Information = ""
ENT.Spawnable = true
ENT.Base = "ent_jack_gmod_ezmachine_base"
---
ENT.Model = "models/compressor/compressorbake.mdl"
ENT.Mass = 500
ENT.EZcolorable = true
ENT.JModPreferredCarryAngles = Angle(0, 0, 0)
ENT.SpawnHeight = 10
---
ENT.StaticPerfSpecs = {
	MaxDurability = 100,
	MaxElectricity = 100
}
ENT.DynamicPerfSpecs = {
	Armor = 2,
	ChargeSpeed = 1
}

function ENT:CustomSetupDataTables()
	self:NetworkVar("Float", 1, "Progress")
	self:NetworkVar("Float", 2, "Chemicals")
	self:NetworkVar("Float", 3, "Fissile")
	self:NetworkVar("String", 0, "FluidType")
end

local STATE_BROKEN, STATE_OFF,  STATE_ON = -1, 0, 1

if SERVER then
	function ENT:CustomInit()
		self.EZupgradable = true
		self.Range = 1000
		self.NextUseTime = 0
		self:SetProgress(0)
		self.SoundLoop = CreateSound(self, "snds_jack_gmod/compressor_loop.wav")
		self.NextLogicThink = 0
	end

	function ENT:Use(activator)
		if self.NextUseTime > CurTime() then return end
		local State = self:GetState()
		local OldOwner = JMod.GetEZowner(self)
		local alt = activator:KeyDown(JMod.Config.General.AltFunctionKey)
		JMod.SetEZowner(self, activator, true)
		if State == STATE_BROKEN then
			JMod.Hint(activator, "destroyed", self)
		return
		elseif State == STATE_OFF then
			self:TurnOn(activator)
		elseif State == STATE_ON then
			if alt then
				self:ProduceResource()
				return
			end
			self:TurnOff(activator)
		end
	end

	function ENT:OnRemove()
		if self.SoundLoop then
			self.SoundLoop:Stop()
		end
	end

	function ENT:ProduceResource()
		local SelfPos, Up, Forward, Right = self:GetPos(), self:GetUp(), self:GetForward(), self:GetRight()
		local amt, chemAmt, fissileAmt = math.Clamp(math.floor(self:GetProgress()), 0, 100), math.min(math.floor(self:GetChemicals()), 100), math.min(math.floor(self:GetFissile()), 100)

		if amt <= 0 then return end

		local pos = self:WorldToLocal(SelfPos + Up * 30 + Right * 60)
		self:SetProgress(math.Clamp(self:GetProgress() - amt, 0, 100))
		JMod.MachineSpawnResource(self, self:GetFluidType(), amt, pos, Angle(0, 0, 0), -Forward, 300)
		self:EmitSound("snds_jack_gmod/ding.ogg", 80, 120)
		if chemAmt >= 1 then
			self:SetChemicals(math.Clamp(self:GetChemicals() - chemAmt, 0, 100))
			JMod.MachineSpawnResource(self, JMod.EZ_RESOURCE_TYPES.CHEMICALS, chemAmt, pos, Angle(0, 0, 0), -Forward, 300)
		end
		if fissileAmt >= 1 then
			self:SetFissile(math.Clamp(self:GetFissile() - fissileAmt, 0, 100))
			JMod.MachineSpawnResource(self, JMod.EZ_RESOURCE_TYPES.FISSILEMATERIAL, fissileAmt, pos, Angle(0, 0, 0), -Forward, 300)
		end
	end

	function ENT:TurnOn(activator)
		if self:GetState() > STATE_OFF then return end
		if self:GetElectricity() > 0 then
			if IsValid(activator) then self.EZstayOn = true end
			self:EmitSound("buttons/button1.wav", 60, 80)
			self:SetState(STATE_ON)
			self:CheckWaterLevel()
			self.NextUseTime = CurTime() + 1
			self.SoundLoop:Play()
		else
			self:EmitSound("buttons/button2.wav", 60, 100)
		end
	end

	function ENT:TurnOff(activator)
		if (self:GetState() <= STATE_OFF) then return end
		if IsValid(activator) then self.EZstayOn = nil end
		self:EmitSound("buttons/button18.wav", 60, 80)
		self:ProduceResource()
		self:SetState(STATE_OFF)
		self:SetProgress(0)
		self.NextUseTime = CurTime() + 1
		self.SoundLoop:Stop()
	end

	function ENT:CheckWaterLevel()
		if self:WaterLevel() >= 1 then
			if self.Submerged == false then
				self:ProduceResource()
			end
			self.Submerged = true
			self:SetFluidType(JMod.EZ_RESOURCE_TYPES.WATER)
		else
			if self.Submerged == true then
				self:ProduceResource()
			end
			self.Submerged = false 
			self:SetFluidType(JMod.EZ_RESOURCE_TYPES.GAS)
		end
	end

	function ENT:CleanseAir()
		local selfPos, Grade = self:LocalToWorld(self:OBBCenter()), self:GetGrade()
		local entites = ents.FindInSphere(selfPos, self.Range)

		for k, v in ipairs(entites) do

			local particleTable = JMod.EZ_HAZARD_PARTICLES[v:GetClass()]

			if istable(particleTable) and IsValid(v) and JMod.ClearLoS(self, v, false, 10, true) then 
				local LinCh = JMod.LinCh(Grade * 1.1, 1, 5)
				if LinCh then
					if particleTable[1] == JMod.EZ_RESOURCE_TYPES.CHEMICALS then
						self:SetChemicals(self:GetChemicals() + particleTable[2])
					elseif particleTable[1] == JMod.EZ_RESOURCE_TYPES.FISSILEMATERIAL then
						self:SetFissile(self:GetFissile() + particleTable[2])
					end

					SafeRemoveEntity(v)
					self:ConsumeElectricity(.2)
				end
			end
		end
	end

	function ENT:Think()
		local State = self:GetState()

		self:UpdateWireOutputs()

		if State == STATE_ON then
			local Time = CurTime()
			if (self.NextLogicThink < Time) then
				self:CheckWaterLevel()

				local grade = self:GetGrade()

				self:ConsumeElectricity(0.34)

				if self:GetProgress() < 100 then
					local rate = math.Round(1.36 * JMod.EZ_GRADE_BUFFS[grade] ^ 2, 2)
					if not(self.Submerged) then
						self:SetProgress(self:GetProgress() + (rate * 0.5))
						self:CleanseAir()
					else
						self:SetProgress(self:GetProgress() + rate)
					end
				else
					self:ProduceResource()
				end

				self.NextLogicThink = Time + 1
			end

			local Eff = EffectData()
			Eff:SetOrigin(self:GetPos() + self:GetRight() * -13 + self:GetUp() * 80)
			Eff:SetScale(0.1)
			util.Effect("eff_jack_gmod_airsuck", Eff, true, true)

			self:NextThink(CurTime() + .1)
			return true
		end
	end

	function ENT:OnPostEntityPaste(ply, ent, createdEntities)
		local Time = CurTime()
		ent.NextUseTime = Time + math.Rand(0, 3)
	end

elseif CLIENT then
	function ENT:CustomInit()
		local Grade = self:GetGrade()
		self.LastGrade = Grade
		self:SetSubMaterial(4, JMod.EZ_GRADE_MATS[Grade]:GetName())
	end

	function ENT:Draw()
		local SelfPos, SelfAng, State = self:GetPos(), self:GetAngles(), self:GetState()
		local Up, Right, Forward = SelfAng:Up(), SelfAng:Right(), SelfAng:Forward()
		local Grade = self:GetGrade()
		---
		local BasePos = SelfPos + Up*30
		local Obscured = false--util.TraceLine({start=EyePos(),endpos=BasePos,filter={LocalPlayer(),self},mask=MASK_OPAQUE}).Hit
		local Closeness = LocalPlayer():GetFOV()*(EyePos():Distance(SelfPos))
		local DetailDraw = Closeness < 120000 -- cutoff point is 400 units when the fov is 90 degrees
		local PanelDraw = true
		---
		self:DrawModel()
		---
		if((not(DetailDraw))and(Obscured))then return end -- if player is far and sentry is obscured, draw nothing
		if(Obscured)then DetailDraw=false end -- if obscured, at least disable details
		if(State==STATE_BROKEN)then DetailDraw=false PanelDraw=false end -- look incomplete to indicate damage, save on gpu comp too
		---
		if self.LastGrade ~= Grade then self:SetSubMaterial(4, JMod.EZ_GRADE_MATS[Grade]:GetName()) end

		if DetailDraw then
			if Closeness < 20000 and State == STATE_ON then
				local DisplayAng = SelfAng:GetCopy()
				DisplayAng:RotateAroundAxis(DisplayAng:Right(), 0)
				DisplayAng:RotateAroundAxis(DisplayAng:Up(), -135)
				DisplayAng:RotateAroundAxis(DisplayAng:Forward(), 90)
				local Opacity = math.random(50, 150)
				local ProFrac = self:GetProgress() / 100
				local R, G, B = JMod.GoodBadColor(ProFrac)
				local ElecFrac = self:GetElectricity() / self.MaxElectricity
				local ER, EG, EB = JMod.GoodBadColor(ElecFrac)
				cam.Start3D2D(SelfPos + Up * 45 - Forward * 12 - Right * 27, DisplayAng, .1)
					surface.SetDrawColor(10, 10, 10, Opacity + 50)
					surface.DrawRect(90,  0, 128, 128)
					JMod.StandardRankDisplay(Grade, 152, 68, 118, Opacity + 50)
					draw.SimpleTextOutlined("PROGRESS", "JMod-Display", 0, 0, Color(255, 255, 255, Opacity), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, Opacity))
					draw.SimpleTextOutlined(tostring(math.Round(ProFrac * 100)) .. "%", "JMod-Display", 0, 30, Color(R, G, B, Opacity), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, Opacity))
					draw.SimpleTextOutlined("POWER", "JMod-Display", 0, 60, Color(255, 255, 255, Opacity), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, Opacity))
					draw.SimpleTextOutlined(tostring(math.Round(ElecFrac * 100)) .. "%", "JMod-Display", 0, 90, Color(ER, EG, EB, Opacity), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, Opacity))
					draw.SimpleTextOutlined(string.upper(self:GetFluidType()), "JMod-Display", 0, 120, Color(255, 255, 255, Opacity), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, Opacity))
				cam.End3D2D()
			end
		end
		self.LastGrade = Grade
	end
	language.Add("ent_jack_gmod_ezgas_condenser", "EZ Fluid Bottler")
end
