-- AdventureBoots Late 2021
AddCSLuaFile()
ENT.Type = "anim"
ENT.PrintName = "EZ Liquid Fuel Generator"
ENT.Author = "Jackarunda, AdventureBoots"
ENT.Category = "JMod - EZ Machines"
ENT.Information = ""
ENT.Spawnable = true
ENT.Base = "ent_jack_gmod_ezmachine_base"
ENT.Model = "models/jmod/machines/diesel_jenerator.mdl"
ENT.EZupgradable = true
--
ENT.JModPreferredCarryAngles = Angle(0, 0, 0)
ENT.Mass = 250
ENT.SpawnHeight = 1
--
ENT.StaticPerfSpecs = {
	MaxDurability = 200,
	MaxFuel = 200
}

ENT.DynamicPerfSpecs = {
	ChargeSpeed = 1,
	Armor = 2
}
ENT.EZconsumes = {
	JMod.EZ_RESOURCE_TYPES.BASICPARTS,
	JMod.EZ_RESOURCE_TYPES.FUEL
}
ENT.EZpowerProducer = true
ENT.EZpowerSocket = Vector(42, -1, 40)
ENT.MaxConnectionRange = 500

function ENT:CustomSetupDataTables()
	self:NetworkVar("Float", 1, "Progress")
	self:NetworkVar("Float", 2, "Fuel")
end

local STATE_BROKEN, STATE_OFF, STATE_ON = -1, 0, 1

if(SERVER)then
	function ENT:CustomInit()
		self:SetProgress(0)
		self.NextResourceThink = 0
		self.NextUseTime = 0
		self.NextEffThink = 0
		self.NextEnvThink = 0
		self.SoundLoop = CreateSound(self, "snds_jack_gmod/genny_start_loop.wav")
	end

	function ENT:Use(activator)
		if self.NextUseTime > CurTime() then return end
		local State = self:GetState()
		local Alt = activator:KeyDown(JMod.Config.General.AltFunctionKey)
		JMod.SetEZowner(self, activator)
		JMod.Colorify(self)

		if State == STATE_BROKEN then
			JMod.Hint(activator, "destroyed", self)
			return
		end
		if Alt then
			self:ModConnections(activator)
		else
			if(State == JMod.EZ_STATE_OFF)then
				self:TurnOn(activator)
			elseif(State == JMod.EZ_STATE_ON)then
				self:TurnOff(activator)
			end
		end
	end

	function ENT:TurnOn(activator, auto)
		if self:GetState() > STATE_OFF then return end
		if (self:WaterLevel() > 1) then return end
		if (self:GetFuel() > 0) then
			self.NextUseTime = CurTime() + 1
			self:SetState(STATE_ON)
			if not self.SoundLoop then self.SoundLoop = CreateSound(self, "snds_jack_gmod/genny_start_loop.wav") end
			self.SoundLoop:SetSoundLevel(70)
			self.SoundLoop:Play()
		elseif IsValid(activator) and not(auto) then
			self.EZstayOn = true
			self:EmitSound("snds_jack_gmod/genny_start_fail.ogg", 70, 100)
			self.NextUseTime = CurTime() + 1
			JMod.Hint(activator, "need fuel")
		end
	end

	function ENT:TurnOff(activator)
		if (self:GetState() <= 0) then return end
		self.NextUseTime = CurTime() + 1
		if IsValid(activator) then self.EZstayOn = nil end
		if self.SoundLoop then self.SoundLoop:Stop() end
		self:EmitSound("snds_jack_gmod/genny_stop.ogg", 70, 100)
		self:SetState(STATE_OFF)
		self:ProduceResource()
	end

	--[[function ENT:ResourceLoaded(typ, accepted)
		if typ == JMod.EZ_RESOURCE_TYPES.FUEL and accepted > 0 then
			timer.Simple(.1, function() 
				if IsValid(self) then self:TurnOn() end 
			end)
		end
	end--]]

	function ENT:OnRemove()
		if self.SoundLoop then self.SoundLoop:Stop() end
	end

	function ENT:SpawnEffect(pos)
		local effectdata = EffectData()
		effectdata:SetOrigin(pos)
		effectdata:SetNormal((VectorRand() + Vector(0, 0, 1)):GetNormalized())
		effectdata:SetMagnitude(math.Rand(5, 10))
		effectdata:SetScale(math.Rand(.5, 1.5))
		effectdata:SetRadius(math.Rand(2, 4))
		util.Effect("Sparks", effectdata)
		--self:EmitSound("items/suitchargeok1.wav", 75, 120)
	end

	function ENT:ProduceResource()
		local SelfPos, Up, Forward, Right = self:GetPos(), self:GetUp(), self:GetForward(), self:GetRight()
		local amt = math.Clamp(math.floor(self:GetProgress()), 0, 100)

		if amt <= 0 then return end
		local pos = self:WorldToLocal(SelfPos + Up * 30 + Forward * 60)
		self:SetProgress(math.Clamp(self:GetProgress() - amt, 0, 100))
		JMod.MachineSpawnResource(self, JMod.EZ_RESOURCE_TYPES.POWER, amt, pos, Angle(0, 0, 0), Forward * 60, 200)
		self:SpawnEffect(self:LocalToWorld(pos))
	end

	function ENT:ConsumeFuel(amt)
		if not(self.GetFuel)then return end
		amt = (amt or .2)/(self.FuelEffeciancy or 1)
		local NewAmt = math.Clamp(self:GetFuel() - amt, 0.0, self.MaxFuel)
		self:SetFuel(NewAmt)
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
				if self:WaterLevel() > 1 then self:TurnOff() return end
				local NRGperFuel = JMod.EnergyEconomyParameters.BasePowerConversions[JMod.EZ_RESOURCE_TYPES.FUEL] * JMod.EnergyEconomyParameters.FuelGennyEfficiencies[Grade]
				local FuelToConsume = JMod.EZ_GRADE_BUFFS[Grade]
				local PowerToProduce = FuelToConsume * NRGperFuel
				local SpeedModifier = .5

				self:ConsumeFuel(FuelToConsume * SpeedModifier)

				self:SetProgress(self:GetProgress() + PowerToProduce * SpeedModifier)

				if self:GetProgress() >= 100 then self:ProduceResource() end
			end
		end

		if (self.NextEffThink < Time) then
			self.NextEffThink = Time + .1
			if (State == STATE_ON) then
				local Eff = EffectData()
				Eff:SetOrigin(self:GetPos() + self:GetUp() * 65 + self:GetRight() * 11 + self:GetForward() * 35)
				Eff:SetNormal(self:GetUp())
				Eff:SetScale(1)
				util.Effect("eff_jack_gmod_ezexhaust", Eff, true)
			end
		end

		if (self.NextEnvThink < Time) then
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
		end

		self:NextThink(Time + .1)
		return true
	end

	function ENT:OnPostEntityPaste(ply, ent, createdEntities)
		local Time = CurTime()
		self.NextResourceThink = Time + math.Rand(0, 3)
		self.NextUseTime = Time + math.Rand(0, 3)
		self.NextEffThink = Time + math.Rand(0, 3)
		self.NextEnvThink = Time + math.Rand(0, 3)
	end

elseif(CLIENT)then
	function ENT:CustomInit()
		self:DrawShadow(true)
		self.BasalPlat = JMod.MakeModel(self, "models/hunter/blocks/cube1x1x025.mdl")
		self.Pistoney = JMod.MakeModel(self, "models/mechanics/robotics/a1.mdl")
	end

	function ENT:Draw()
		local SelfPos, SelfAng, State = self:GetPos(), self:GetAngles(), self:GetState()
		local Up, Right, Forward = SelfAng:Up(), SelfAng:Right(), SelfAng:Forward()
		local Grade = self:GetGrade()
		---
		local BasePos = SelfPos
		local Obscured = util.TraceLine({start = EyePos(), endpos = BasePos + Up * 30, filter = {LocalPlayer(), self}, mask = MASK_OPAQUE}).Hit
		local Closeness = LocalPlayer():GetFOV() * (EyePos():Distance(SelfPos))
		local DetailDraw = Closeness < 120000 -- cutoff point is 400 units when the fov is 90 degrees
		---
		--if((not(DetailDraw)) and (Obscured))then return end -- if player is far and sentry is obscured, draw nothing
		if(Obscured)then DetailDraw = false end -- if obscured, at least disable details
		if(State == STATE_BROKEN)then DetailDraw = false end -- look incomplete to indicate damage, save on gpu comp too
		---
		self:DrawModel()
		---
		local BasalPlatAng = SelfAng:GetCopy()
		JMod.RenderModel(self.BasalPlat, BasePos + Up * 12 + Forward * 8 - Right * 0, BasalPlatAng, nil, Vector(1,1,1), JMod.EZ_GRADE_MATS[Grade])
		---
		local WeDoBeBobbin = (State == STATE_ON and math.sin(CurTime() * 100) / 2 + .5) or 0
		local PistoneyAng = SelfAng:GetCopy()
		PistoneyAng:RotateAroundAxis(Right, 90)
		JMod.RenderModel(self.Pistoney, BasePos + Up * (44.5 + 5 * WeDoBeBobbin) - Forward * 19, PistoneyAng, nil, Vector(1, 1, 1), JMod.EZ_GRADE_MATS[Grade])

		if DetailDraw then
			if Closeness < 20000 and State == STATE_ON then
				local DisplayAng = SelfAng:GetCopy()
				DisplayAng:RotateAroundAxis(DisplayAng:Right(), 0)
				DisplayAng:RotateAroundAxis(DisplayAng:Up(), -90)
				DisplayAng:RotateAroundAxis(DisplayAng:Forward(), 90)
				local Opacity = math.random(50, 150)
				local ProgFrac = self:GetProgress() / 100
				local FuelFrac = self:GetFuel() / self.MaxFuel
				local R, G, B = JMod.GoodBadColor(ProgFrac)
				local FR, FG, FB = JMod.GoodBadColor(FuelFrac)

				cam.Start3D2D(SelfPos + Forward * -36 + Right * -12 + Up * 53, DisplayAng, .06)
				surface.SetDrawColor(10, 10, 10, Opacity + 50)
				local RankX, RankY = -70, 190
				surface.DrawRect(RankX, RankY, 128, 128)
				JMod.StandardRankDisplay(Grade, RankX + 62, RankY + 68, 118, Opacity + 50)
				draw.SimpleTextOutlined("PROGRESS", "JMod-Display", 0, 0, Color(255, 255, 255, Opacity), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, Opacity))
				draw.SimpleTextOutlined(tostring(math.Round(ProgFrac * 100)) .. "%", "JMod-Display", 0, 30, Color(R, G, B, Opacity), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, Opacity))
				draw.SimpleTextOutlined("FUEL", "JMod-Display", 0, 90, Color(255, 255, 255, Opacity), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, Opacity))
				draw.SimpleTextOutlined(tostring(math.Round(FuelFrac * 100)) .. "%", "JMod-Display", 0, 120, Color(FR, FG, FB, Opacity), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, Opacity))
				cam.End3D2D()

			end
		end
	end
	language.Add("ent_jack_gmod_ezlfg", "EZ Liquid Fuel Generator")
end
