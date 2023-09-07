-- AdventureBoots Late 2023
AddCSLuaFile()
ENT.Type = "anim"
ENT.PrintName = "EZ Enrichment Centrifuge"
ENT.Author = "Jackarunda, AdventureBoots"
ENT.Category = "JMod - EZ Machines"
ENT.Information = ""
ENT.Spawnable = true -- Until we finsih the next phase of Econ 2
ENT.Base = "ent_jack_gmod_ezmachine_base"
ENT.Model = "models/jmod/machines/centrifuge.mdl"
---
ENT.EZupgradable = true
ENT.JModPreferredCarryAngles = Angle(0, 0, 0)
ENT.Mass = 600
ENT.SpawnHeight = 1
ENT.EZcolorable = true
--
ENT.StaticPerfSpecs = {
	MaxDurability = 100,
	MaxElectricity = 600,
	MaxUranium = 200,
	MaxGas = 300
}

ENT.DynamicPerfSpecs = {
	Armor = 1
}
ENT.EZconsumes = {
	JMod.EZ_RESOURCE_TYPES.BASICPARTS,
	JMod.EZ_RESOURCE_TYPES.POWER,
	JMod.EZ_RESOURCE_TYPES.GAS,
	JMod.EZ_RESOURCE_TYPES.URANIUM,
}

function ENT:CustomSetupDataTables()
	self:NetworkVar("Float", 1, "Progress")
	self:NetworkVar("Float", 2, "Gas")
	self:NetworkVar("Float", 3, "Uranium")
end

local STATE_BROKEN, STATE_OFF, STATE_ON = -1, 0, 1

if(SERVER)then
	function ENT:CustomInit()
		self:SetProgress(0)
		self.NextResourceThink = 0
		self.NextUseTime = 0
		self.NextEffThink = 0
		self.NextEnvThink = 0
		self.SoundLoop = CreateSound(self, "snds_jack_gmod/ezbhg_hum.wav")
		if self.SpawnFull then
			self:SetGas(self.MaxGas)
			self:SetUranium(self.MaxUranium)
		end
	end

	function ENT:Use(activator)
		if self.NextUseTime > CurTime() then return end
		local State = self:GetState()
		local alt = activator:KeyDown(JMod.Config.General.AltFunctionKey)
		JMod.SetEZowner(self, activator)
		JMod.Colorify(self)

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
			self:TurnOff()
		end
	end

	function ENT:TurnOn(activator)
		if self:GetState() > STATE_OFF then return end
		if (self:GetGas() > 0) and (self:GetUranium() > 0) and (self:GetElectricity() > 0) then
			self.NextUseTime = CurTime() + 1
			self:SetState(STATE_ON)
			self.SoundLoop:Play()
			self.SoundLoop:SetSoundLevel(70)
			self.SoundLoop:ChangeVolume(.9)
		else
			self:EmitSound("snds_jack_gmod/afh_unseal.wav", 70, 100)
			self.NextUseTime = CurTime() + 1
			JMod.Hint(activator, "need Gas")
		end
	end

	function ENT:TurnOff()
		if (self:GetState() <= 0) then return end
		self.NextUseTime = CurTime() + 1
		if self.SoundLoop then self.SoundLoop:Stop() end
		self:EmitSound("snds_jack_gmod/afh_shutdown.wav", 70, 100)
		self:ProduceResource()
		self:SetState(STATE_OFF)
	end

	function ENT:ResourceLoaded(typ, accepted)
		--[[if typ == JMod.EZ_RESOURCE_TYPES.POWER and accepted > 0 then
			timer.Simple(.1, function() 
				if IsValid(self) then self:TurnOn() end 
			end)
		end]]--
	end

	function ENT:OnRemove()
		if self.SoundLoop then self.SoundLoop:Stop() end
	end

	function ENT:ProduceResource()
		local SelfPos, Up, Forward, Right = self:GetPos(), self:GetUp(), self:GetForward(), self:GetRight()
		local amt = math.Clamp(math.floor(self:GetProgress()), 0, 100)

		if amt <= 0 then return end

		local pos = self:WorldToLocal(SelfPos + Up * 30 + Forward * 60 + Right * 10)
		JMod.MachineSpawnResource(self, JMod.EZ_RESOURCE_TYPES.FISSILEMATERIAL, amt, pos, Angle(0, 0, 0), Forward * 60, true, 200)
		self:SetProgress(math.Clamp(self:GetProgress() - amt, 0, 100))
	end

	function ENT:ConsumeGas(amt)
		if not(self.GetGas)then return end
		local NewAmt = math.Clamp(self:GetGas() - amt, 0.0, self.MaxGas)
		self:SetGas(NewAmt)
		if(NewAmt <= 0) and (self:GetState() > 0)then self:TurnOff() end
	end

	function ENT:ConsumeUranium(amt)
		if not(self.GetUranium)then return end
		local NewAmt = math.Clamp(self:GetUranium() - amt, 0.0, self.MaxUranium)
		self:SetUranium(NewAmt)
		if(NewAmt <= 0) and (self:GetState() > 0)then self:TurnOff() end
	end

	function ENT:OnBreak()
		if self.SoundLoop then
			self.SoundLoop:Stop()
		end
	end

	function ENT:Think()
		local Time, State, Grade = CurTime(), self:GetState(), self:GetGrade()

		self:UpdateWireOutputs()

		if self.NextResourceThink < Time then
			self.NextResourceThink = Time + 1
			if State == STATE_ON then
				local FissilePerU = JMod.RefiningTable[JMod.EZ_RESOURCE_TYPES.URANIUM][JMod.EZ_RESOURCE_TYPES.FISSILEMATERIAL]
				local UtoConsume = JMod.EZ_GRADE_BUFFS[Grade]
				local FissileToProduce = FissilePerU * UtoConsume
				local GasToConsume = UtoConsume * .5
				local SpeedModifier = 1

				self:ConsumeUranium(FissileToProduce * SpeedModifier)
				self:ConsumeGas(GasToConsume * SpeedModifier)
				self:ConsumeElectricity(2 * SpeedModifier)

				self:SetProgress(self:GetProgress() + FissileToProduce * SpeedModifier)

				if self:GetProgress() >= 100 then self:ProduceResource() end
			end
		end

		--[[if (self.NextEffThink < Time) then
			self.NextEffThink = Time + .1
			if (State == STATE_ON) then
				local Eff = EffectData()
				Eff:SetOrigin(self:GetPos() + self:GetUp() * 65 + self:GetRight() * 11 + self:GetForward() * 35)
				Eff:SetNormal(self:GetUp())
				Eff:SetScale(1)
				util.Effect("eff_jack_gmod_ezexhaust", Eff, true)
			end
		end]]--

		--[[if (self.NextEnvThink < Time) then
			self.NextEnvThink = Time + 5
			if (State == STATE_ON) then
				local Tr=util.QuickTrace(self:GetPos(), Vector(0, 0, 9e9), self)
				if not (Tr.HitSky) then
					if (math.random(1, 3) == 1) then
						local Gas = ents.Create("ent_jack_gmod_ezgasparticle")
						Gas:SetPos(self:GetPos() + Vector(0, 0, 100))
						JMod.SetEZowner(Gas, self.EZowner)
						Gas:SetDTBool(0, true)
						Gas:Spawn()
						Gas:Activate()
						Gas.CurVel = (VectorRand() * math.random(1, 100))
					end
				end
			end
		end]]--
	end

	function ENT:PostEntityPaste(ply, ent, createdEntities)
		local Time = CurTime()
		JMod.SetEZowner(self, ply, true)
		ent.NextRefillTime = Time + math.Rand(0, 3)
		self.NextResourceThink = Time + math.Rand(0, 3)
		self.NextUseTime = Time + math.Rand(0, 3)
		--self.NextEffThink = Time + math.Rand(0, 3)
		--self.NextEnvThink = Time + math.Rand(0, 3)
	end

elseif(CLIENT)then
	function ENT:CustomInit()
		self:DrawShadow(true)
	end

	function ENT:Draw()
		local SelfPos, SelfAng, State, FT = self:GetPos(), self:GetAngles(), self:GetState(), FrameTime()
		local Up, Right, Forward = SelfAng:Up(), SelfAng:Right(), SelfAng:Forward()
		local Grade = self:GetGrade()
		---
		local BasePos = SelfPos
		local Obscured = util.TraceLine({start = EyePos(), endpos = BasePos, filter = {LocalPlayer(), self}, mask = MASK_OPAQUE}).Hit
		local Closeness = LocalPlayer():GetFOV() * (EyePos():Distance(SelfPos))
		local DetailDraw = Closeness < 1200000 -- cutoff point is 400 units when the fov is 90 degrees
		---
		if((not(DetailDraw)) and (Obscured))then return end -- if player is far and sentry is obscured, draw nothing
		if(Obscured)then DetailDraw = false end -- if obscured, at least disable details
		if(State == STATE_BROKEN)then DetailDraw = false end -- look incomplete to indicate damage, save on gpu comp too
		---
		self:DrawModel()
		---

		if DetailDraw then
			if Closeness < 20000 and State == STATE_ON then
				local DisplayAng = SelfAng:GetCopy()
				DisplayAng:RotateAroundAxis(DisplayAng:Right(), 0)
				DisplayAng:RotateAroundAxis(DisplayAng:Up(), 0)
				DisplayAng:RotateAroundAxis(DisplayAng:Forward(), 90)
				local Opacity = math.random(50, 150)
				local ProgFrac = self:GetProgress() / 100
				local ElecFrac = self:GetElectricity() / self.MaxElectricity
				local GasFrac = self:GetGas() / self.MaxGas
				local UraniumFrac = self:GetUranium() / self.MaxUranium
				local R, G, B = JMod.GoodBadColor(ProgFrac)
				local ER, EG, EB = JMod.GoodBadColor(ElecFrac)
				local FR, FG, FB = JMod.GoodBadColor(GasFrac)
				local UR, UG, UB = JMod.GoodBadColor(UraniumFrac)

				cam.Start3D2D(SelfPos - Forward * 10 - Right * 5 + Up * 50, DisplayAng, .06)
				surface.SetDrawColor(10, 10, 10, Opacity + 50)
				local RankX, RankY = 300, 30
				surface.DrawRect(RankX, RankY, 128, 128)
				JMod.StandardRankDisplay(Grade, RankX + 62, RankY + 68, 118, Opacity + 50)
				draw.SimpleTextOutlined("PROGRESS", "JMod-Display", 200, 0, Color(255, 255, 255, Opacity), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, Opacity))
				draw.SimpleTextOutlined(tostring(math.Round(ProgFrac * 100)) .. "%", "JMod-Display", 200, 30, Color(R, G, B, Opacity), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, Opacity))
				draw.SimpleTextOutlined("POWER", "JMod-Display", 200, 90, Color(255, 255, 255, Opacity), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, Opacity))
				draw.SimpleTextOutlined(tostring(math.Round(ElecFrac * 100)) .. "%", "JMod-Display", 200, 120, Color(ER, EG, EB, Opacity), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, Opacity))
				draw.SimpleTextOutlined("GAS", "JMod-Display", 0, 0, Color(255, 255, 255, Opacity), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, Opacity))
				draw.SimpleTextOutlined(tostring(math.Round(GasFrac * 100)) .. "%", "JMod-Display", 0, 30, Color(FR, FG, FB, Opacity), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, Opacity))
				draw.SimpleTextOutlined("URANIUM", "JMod-Display", 0, 90, Color(255, 255, 255, Opacity), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, Opacity))
				draw.SimpleTextOutlined(tostring(math.Round(UraniumFrac * 100)) .. "%", "JMod-Display", 0, 120, Color(UR, UG, UB, Opacity), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, Opacity))
				cam.End3D2D()

			end
		end
	end
	language.Add("ent_jack_gmod_ezlfg", "EZ Enrichment Centrifuge")
end
