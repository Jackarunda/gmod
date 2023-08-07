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
ENT.Mass = 35
ENT.SpawnHeight = 1
--
ENT.StaticPerfSpecs = {
	MaxDurability = 100,
	MaxWater = 500,
	--MaxFuel = 500,
	Armor = 0.5
}

ENT.EZconsumes = {
	JMod.EZ_RESOURCE_TYPES.BASICPARTS,
	JMod.EZ_RESOURCE_TYPES.WATER,
	JMod.EZ_RESOURCE_TYPES.POWER,
	--JMod.EZ_RESOURCE_TYPES.FUEL --:troll:
}

function ENT:CustomSetupDataTables()
	self:NetworkVar("Float", 1, "Water")
	--self:NetworkVar("Float", 2, "Fuel")
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
		self:SetLiquidType("Water")
		if self.SpawnFull then
			self:SetWater(self.MaxWater)
		else
			self:SetWater(0)
		end
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
		if self:GetState() > STATE_OFF then return end
		if (self:GetWater() > 0) then
			self.NextUseTime = CurTime() + 1
			self:SetState(STATE_ON)
			if not self.SoundLoop then
				self.SoundLoop = CreateSound(self, "snds_jack_gmod/impact_sprinkler")
				self.SoundLoop:Play()
				self.SoundLoop:SetSoundLevel(70)
			end
		else
			self.NextUseTime = CurTime() + 1
			if self:GetLiquidType() == "Fuel" then
				JMod.Hint(activator, "need fuel")
			elseif self:GetLiquidType() == "Water" then
				JMod.Hint(activator, "need water")
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
		if typ == JMod.EZ_RESOURCE_TYPES.WATER and accepted > 0 then
			timer.Simple(.1, function() 
				if IsValid(self) then self:TurnOn() end 
			end)
		end
	end

	function ENT:ConsumeLiquid(amt)
		local SelfType = self:GetLiquidType()
		if SelfType == "Water" then
			local NewAmt = math.Clamp(self:GetWater() - amt, 0.0, self.MaxWater)
			self:SetWater(NewAmt)
			if(NewAmt <= 0) and (self:GetState() > 0)then self:TurnOff() end
		elseif SelfType == "Fuel" then
			local NewAmt = math.Clamp(self:GetFuel() - amt, 0.0, self.MaxFuel)
			self:SetFuel(NewAmt)
			if(NewAmt <= 0) and (self:GetState() > 0)then self:TurnOff() end
		end
	end

	function ENT:Think()
		local Time, State, Grade = CurTime(), self:GetState(), self:GetGrade()

		if self.NextLiquidThink < Time then
			self.NextLiquidThink = Time + 5
			if State == STATE_ON then
				local LiquidToSpray = 10

				--self:ConsumeLiquid(LiquidToSpray)
			end
		end

		if (self.NextEffThink < Time) then
			self.NextEffThink = Time + .1
			if (State == STATE_ON) then
				--self:EmitSound("snds_jack_gmod/hiss.wav", 60, 200)
				local CurrentRot = self:GetHeadRot()
				local SelfAng = self:GetAngles()
				local TurnSpeed = 5
				local RotMin, RotMax = 0, 360
				if CurrentRot > RotMax then
					self.Dir = "right"
				elseif CurrentRot < RotMin then
					self.Dir = "left"
				end
				if self.Dir == "right" then
					self:SetHeadRot(CurrentRot - TurnSpeed)
				elseif self.Dir == "left" then
					self:SetHeadRot(CurrentRot + TurnSpeed * 2)
				end
			end
		end
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
