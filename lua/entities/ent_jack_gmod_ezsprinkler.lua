-- AdventureBoots Mid 2023
AddCSLuaFile()
ENT.Type = "anim"
ENT.PrintName = "EZ Sprinkler"
ENT.Author = "Jackarunda, AdventureBoots"
ENT.Category = "JMod - EZ Machines"
ENT.Information = ""
ENT.Spawnable = true
ENT.Base = "ent_jack_gmod_ezmachine_base"
ENT.Model = "models/jmod/machines/sprinkler_base.mdl"
ENT.EZupgradable = false
ENT.EZcolorable = false
--
ENT.JModPreferredCarryAngles = Angle(0, 90, 0)
ENT.Mass = 50
ENT.SpawnHeight = 1
ENT.SprayRange = 400
--
ENT.StaticPerfSpecs = {
	MaxElectricity = 100,
	MaxDurability = 50,
	MaxWater = 200,
	--MaxFuel = 200,
	Armor = 1
}

ENT.EZconsumes = {
	JMod.EZ_RESOURCE_TYPES.BASICPARTS,
	JMod.EZ_RESOURCE_TYPES.WATER,
	JMod.EZ_RESOURCE_TYPES.POWER,
	--JMod.EZ_RESOURCE_TYPES.FUEL --:troll:
}

function ENT:CustomSetupDataTables()
	self:NetworkVar("Float", 1, "Water")
	self:NetworkVar("Float", 3, "HeadRot")
	self:NetworkVar("String", 1, "LiquidType")
end

local STATE_BROKEN, STATE_OFF, STATE_ON = -1, 0, 1

if(SERVER)then
	function ENT:CustomInit()
		self.NextLiquidThink = 0
		self.NextUseTime = 0
		self.NextEffThink = 0
		self.Dir = "right"
		self.SoundRight = "snds_jack_gmod/sprankler_slow_loop.wav"
		self.SoundLeft = "snds_jack_gmod/sprankler_fast_loop.wav"
		self:SetLiquidType(JMod.EZ_RESOURCE_TYPES.WATER)
		self.PerferredDonor = nil
		if self.SpawnFull then
			self:SetWater(self.MaxWater)
		else
			self:SetWater(0)
		end
		self:SetColor(Color(61, 194, 255))
	end

	function ENT:Use(activator)
		if self.NextUseTime > CurTime() then return end
		local State = self:GetState()
		local Alt = activator:KeyDown(JMod.Config.General.AltFunctionKey)
		JMod.SetEZowner(self, activator)
		JMod.Colorify(self)

		if Alt then
			if State == STATE_BROKEN then
				JMod.Hint(activator, "destroyed", self)
				return
			elseif State == STATE_OFF then
				self:TurnOn(activator)
			elseif State == STATE_ON then
				self:TurnOff()
			end
		else
			activator:PickupObject(self)
		end
	end

	function ENT:TurnOn(activator)
		if self:GetState() <= STATE_BROKEN then return end
		if ((self:GetWater() > 0) or (self:LoadLiquidFromDonor(self:GetLiquidType(), 100) > 0)) and self:GetElectricity() > 0 then
			self.NextUseTime = CurTime() + 1
			self:SetState(STATE_ON)
			if not self.SoundLoop then
				self.SoundLoop = CreateSound(self, (self.Dir == "left" and self.SoundLeft) or self.SoundRight)
			end
			self.SoundLoop:Play()
			self.SoundLoop:SetSoundLevel(60)
		else
			self.NextUseTime = CurTime() + 1
			if self:GetElectricity() <= 0 then 
				JMod.Hint(activator, "nopower")
			elseif self:GetLiquidType() == JMod.EZ_RESOURCE_TYPES.WATER then
				JMod.Hint(activator, "sprinkler water")
			end
		end
	end

	function ENT:TurnOff()
		if (self:GetState() <= 0) then return end
		self.NextUseTime = CurTime() + 1
		self:SetState(STATE_OFF)
		if self.SoundLoop then
			self.SoundLoop:Stop()
		end
	end

	function ENT:ResourceLoaded(typ, accepted)
		if (typ == JMod.EZ_RESOURCE_TYPES.WATER) or (typ == JMod.EZ_RESOURCE_TYPES.POWER) and accepted > 0 then
			timer.Simple(.1, function() 
				if IsValid(self) then self:TurnOn() end 
			end)
		end
	end

	function ENT:LoadLiquidFromDonor(typ, amt)
		local SelfPos = self:GetPos()
		if IsValid(self.PerferredDonor) and (self.PerferredDonor:GetPos():Distance(SelfPos) <= 100) and self.PerferredDonor:GetEZsupplies(typ) > 0 then
			local Supplies = self.PerferredDonor:GetEZsupplies(typ)
			local Required = math.min(Supplies, amt)
			local Accepted = self:TryLoadResource(typ, Required)
			self.PerferredDonor:SetEZsupplies(typ, Supplies - Required, self)
			--typ, fromPoint, toPoint, amt, spread, scale, upSpeed
			JMod.ResourceEffect(typ, self.PerferredDonor:LocalToWorld(self.PerferredDonor:OBBCenter()), self:LocalToWorld(self:OBBCenter()), amt/200, 1, 1)

			return Accepted
		end
		for _, v in ipairs(ents.FindInSphere(SelfPos, 100)) do
			if v.GetEZsupplies and (v:GetEZsupplies(typ) and v:GetEZsupplies(typ) > 0) then
				local Supplies = v:GetEZsupplies(typ)
				local Required = math.min(Supplies, amt)
				local Accepted = self:TryLoadResource(typ, Required)
				v:SetEZsupplies(typ, Supplies - Required, self)
				self.PerferredDonor = v

				return Accepted
			end
		end

		return 0
	end

	function ENT:ConsumeLiquid(amt)
		local SelfType = self:GetLiquidType()
		if SelfType == JMod.EZ_RESOURCE_TYPES.WATER then
			local NewAmt = math.Clamp(self:GetWater() - amt, 0.0, self.MaxWater)
			self:SetWater(NewAmt)
			if(NewAmt <= 0) and (self:GetState() > 0) then
				local Loaded = self:LoadLiquidFromDonor(SelfType, amt * 5)
				if Loaded < amt then
					self:TurnOff()
				end
			end
		elseif SelfType == JMod.EZ_RESOURCE_TYPES.FUEL then
			local NewAmt = math.Clamp(self:GetFuel() - amt, 0.0, self.MaxFuel)
			self:SetFuel(NewAmt)
			if(NewAmt <= 0) and (self:GetState() > 0) then 
				local Loaded = self:LoadLiquidFromDonor(SelfType, amt * 5)
				if Loaded < amt then
					self:TurnOff()
				end
			end
		end
	end

	local ThinkRate = 60/12 --Hz
	local EntsToRemove = {["ent_jack_gmod_eznapalm"] = true, ["ent_jack_gmod_ezfirehazard"] = true}

	function ENT:Think()
		local Time, State, SelfPos = CurTime(), self:GetState(), self:GetPos()
		local WaterConversionSpeed = 1.5

		self:UpdateWireOutputs()

		if self.NextLiquidThink < Time then
			self.NextLiquidThink = Time + ThinkRate
			if State == STATE_ON then
				local WaterDeliveryAmt = 1 * WaterConversionSpeed
				local WaterConsumptionAmt = 4 * WaterConversionSpeed

				for k, v in ipairs(ents.FindInSphere(self:GetPos(), self.SprayRange)) do
					if IsValid(v) and (v:GetPos().z <= SelfPos.z + 64) and JMod.ClearLoS(self, v, false, 34) then
						if v:IsOnFire() then v:Extinguish() end
						if EntsToRemove[v:GetClass()] and math.random(1, 3) >= 2 then
							SafeRemoveEntity(v)
						end
						if  v.Hydration and table.HasValue(v.EZconsumes, JMod.EZ_RESOURCE_TYPES.WATER) then
							v.Hydration = math.Clamp(v.Hydration + WaterDeliveryAmt, 0, 100)
						end
						v:RemoveAllDecals()
					end
				end
				self:ConsumeElectricity(0.5 * WaterConversionSpeed)
				self:ConsumeLiquid(WaterConsumptionAmt)
			end
		end

		if (self.NextEffThink < Time) then
			self.NextEffThink = Time + ((self.Dir == "left") and .075 or .15)
			if (State == STATE_ON) then
				local CurrentRot = self:GetHeadRot()
				local SelfAng = self:GetAngles()

				local SplachAngle = SelfAng:GetCopy()
				SplachAngle:RotateAroundAxis(SplachAngle:Up(), CurrentRot)
				SplachAngle:RotateAroundAxis(SplachAngle:Right(), 35)
				local Splach = EffectData()
				Splach:SetOrigin(SelfPos + self:GetUp() * 35 + SplachAngle:Forward() * 2)
				local Zoop = SplachAngle:Forward()
				if (self.Dir == "left") then
					Zoop = Zoop / 1
				end
				Splach:SetStart(Zoop)
				Splach:SetScale((self.Dir == "right") and 1 or .4)
				util.Effect("eff_jack_gmod_spranklerspray", Splach)

				local TurnSpeed = 5
				local RotMin, RotMax = 0, 360
				if CurrentRot > RotMax then
					self.Dir = "right"
					if self.SoundLoop then
						self.SoundLoop:Stop()
					end
					self.SoundLoop = CreateSound(self, self.SoundRight)
					self.SoundLoop:Play()
					self.SoundLoop:SetSoundLevel(60)
				elseif CurrentRot < RotMin then
					self.Dir = "left"
					if self.SoundLoop then
						self.SoundLoop:Stop()
					end
					self.SoundLoop = CreateSound(self, self.SoundLeft)
					self.SoundLoop:Play()
					self.SoundLoop:SetSoundLevel(60)
				end
				if self.Dir == "right" then
					self:SetHeadRot(CurrentRot - TurnSpeed)
				elseif self.Dir == "left" then
					self:SetHeadRot(CurrentRot + TurnSpeed * 2)
				end
			elseif self.SoundLoop then
				self.SoundLoop:Stop()
			end
		end

		self:NextThink(Time + .05)
		return true
	end

	function ENT:OnBreak()
		if self.SoundLoop then
			self.SoundLoop:Stop()
		end
	end
	function ENT:OnRemove()
		if self.SoundLoop then
			self.SoundLoop:Stop()
		end
	end

	function ENT:PostEntityPaste(ply, ent, createdEntities)
		local Time = CurTime()
		JMod.SetEZowner(self, ply, true)
		ent.NextRefillTime = Time + math.Rand(0, 3)
		self.NextLiquidThink = Time + math.Rand(0, 3)
		self.NextUseTime = Time + math.Rand(0, 3)
		self.NextEffThink = Time + math.Rand(0, 3)
	end

elseif(CLIENT)then
	function ENT:CustomInit()
		self:DrawShadow(true)
		self.Sprinkleer = JMod.MakeModel(self, "models/jmod/machines/sprinkler_head.mdl")
		self.Debug = false
	end

	local DebugCooler = Color(61, 200, 255)
	function ENT:Draw()
		local SelfPos, SelfAng, State, FT = self:GetPos(), self:GetAngles(), self:GetState(), FrameTime()
		local Up, Right, Forward = SelfAng:Up(), SelfAng:Right(), SelfAng:Forward()
		local Grade = self:GetGrade()
		---
		local BasePos = SelfPos
		local Obscured = util.TraceLine({start = EyePos(), endpos = BasePos, filter = {LocalPlayer(), self}, mask = MASK_OPAQUE}).Hit
		local Closeness = LocalPlayer():GetFOV() * (EyePos():Distance(SelfPos))
		local DetailDraw = Closeness < 120000 -- cutoff point is 400 units when the fov is 90 degrees
		---
		if((not(DetailDraw)) and (Obscured))then return end -- if player is far and sentry is obscured, draw nothing
		if(Obscured)then DetailDraw = false end -- if obscured, at least disable details
		if(State == STATE_BROKEN)then DetailDraw = false end -- look incomplete to indicate damage, save on gpu comp too
		---
		self:DrawModel()
		---
		local SprinkleerAng = SelfAng:GetCopy()
		SprinkleerAng:RotateAroundAxis(Up, self:GetHeadRot())
		JMod.RenderModel(self.Sprinkleer, BasePos, SprinkleerAng)
		---
		if self.Debug then
			render.DrawWireframeSphere(SelfPos, 400, 12, 12, DebugCooler, true)
		end

		if DetailDraw then
			if Closeness < 20000 and State == STATE_ON then
				local DisplayAng = SelfAng:GetCopy()
				DisplayAng:RotateAroundAxis(DisplayAng:Right(), 0)
				DisplayAng:RotateAroundAxis(DisplayAng:Up(), 180)
				DisplayAng:RotateAroundAxis(DisplayAng:Forward(), 90)
				local Opacity = math.random(50, 150)
				local PowFrac = self:GetElectricity() / self.MaxElectricity
				local WaterFrac = self:GetWater() / self.MaxWater
				--local FuelFrac = self:GetFuel() / self.MaxFuel
				local R, G, B = JMod.GoodBadColor(PowFrac)
				local WR, WG, WB = JMod.GoodBadColor(WaterFrac)
				--local FR, FG, FB = JMod.GoodBadColor(FuelFrac)

				cam.Start3D2D(SelfPos - Forward * 1 - Up * 8 - Right * 12, DisplayAng, .06)
				draw.SimpleTextOutlined("POWER", "JMod-Display", 0, 0, Color(255, 255, 255, Opacity), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, Opacity))
				draw.SimpleTextOutlined(tostring(math.Round(PowFrac * 100)) .. "%", "JMod-Display", 0, 30, Color(R, G, B, Opacity), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, Opacity))
				draw.SimpleTextOutlined("WATER", "JMod-Display", 0, 90, Color(255, 255, 255, Opacity), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, Opacity))
				draw.SimpleTextOutlined(tostring(math.Round(WaterFrac * 100)) .. "%", "JMod-Display", 0, 120, Color(WR, WG, WB, Opacity), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, Opacity))
				--draw.SimpleTextOutlined("FUEL", "JMod-Display", 0, 90, Color(255, 255, 255, Opacity), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, Opacity))
				--draw.SimpleTextOutlined(tostring(math.Round(FuelFrac * 100)) .. "%", "JMod-Display", 0, 120, Color(FR, FG, FB, Opacity), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, Opacity))
				cam.End3D2D()

			end
		end
	end
	language.Add("ent_jack_gmod_ezlfg", "EZ Liquid Fuel Generator")
end
