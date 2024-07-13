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
--
ENT.StaticPerfSpecs = {
	MaxElectricity = 100,
	MaxDurability = 50
}
ENT.DynamicPerfSpecs={
	MaxLiquid = 200,
	TurnSpeed = 5,
	SprayRadius = 400,
	Armor = 1
}
ENT.LiquidTypes = {
	[JMod.EZ_RESOURCE_TYPES.WATER] = {
		TankColor = Color(61, 194, 255),
		SoundRight = {"snds_jack_gmod/sprankler_slow_loop.wav"},
		SoundLeft = {"snds_jack_gmod/sprankler_fast_loop.wav"},
	},
	[JMod.EZ_RESOURCE_TYPES.FUEL] = {
		TankColor = Color(255, 61, 61),
		SoundRight = {"snds_jack_gmod/flamethrower_loop.wav"},
		SoundLeft = {"snds_jack_gmod/flamethrower_loop.wav", 120},
	},
	--[[[JMod.EZ_RESOURCE_TYPES.CHEMICALS] = {
		TankColor = Color(61, 255, 61),
		SoundRight = {"snds_jack_gmod/sprankler_slow_loop.wav"},
		SoundLeft = {"snds_jack_gmod/sprankler_fast_loop.wav"},
	}--]]
}

ENT.EZconsumes = nil

local STATE_BROKEN, STATE_OFF, STATE_ON = -1, 0, 1

function ENT:CustomSetupDataTables()
	self:NetworkVar("Float", 1, "Liquid")
	self:NetworkVar("Float", 2, "HeadRot")
	self:NetworkVar("String", 1, "LiquidType")
end

function ENT:SetMods(tbl, liquidType)
	local OldMaxLiquidSpec = (self.ModPerfSpecs and self.ModPerfSpecs.MaxLiquid) or 0
	self.ModPerfSpecs = tbl
	local OldLiquidType = self:GetLiquidType()
	self:SetLiquidType(liquidType)
	if (OldLiquidType ~= liquidType) or (self.ModPerfSpecs.MaxLiquid < OldMaxLiquidSpec) then
		JMod.MachineSpawnResource(self, OldLiquidType, self:GetLiquid(), Vector(0, -20, 50), Angle(0, 0, 0), self:GetRight(), 100)
	end
	self:InitPerfSpecs((OldLiquidType ~= liquidType) or ((self.ModPerfSpecs.MaxLiquid < OldMaxLiquidSpec)))
	self.EZconsumes = {JMod.EZ_RESOURCE_TYPES.POWER, JMod.EZ_RESOURCE_TYPES.BASICPARTS, liquidType}
	self:SetColor(self.LiquidTypes[liquidType].TankColor)
	self.SoundLeft = self.LiquidTypes[liquidType].SoundLeft
	self.SoundRight = self.LiquidTypes[liquidType].SoundRight
	if SERVER then
		self:SetupWire()
	end
end

function ENT:InitPerfSpecs(removeLiquid)
	if not self.ModPerfSpecs then return end
	if (self.StaticPerfSpecs) then
		for specName, value in pairs(self.StaticPerfSpecs)do 
			self[specName] = value 
		end
	end
	for specName, value in pairs(self.DynamicPerfSpecs)do 
		if(type(value)~="table")then
			self[specName] = value
		end
	end
	self.MaxLiquid = math.Round(self.MaxLiquid/100)*100 -- a sight for sore eyes, ey jack?-titanicjames
	--self.SprayRadius = self.SprayRadius*52.493 -- convert meters to source units
	
	local MaxValue=10
	for attrib, value in pairs(self.ModPerfSpecs) do
		local oldVal =  self[attrib]
		if istable(value) then
			self[attrib] = value
		else
			if value > 0 then
				local ratio = (math.abs(value / MaxValue) + 1) ^ 1.5
				self[attrib] = self[attrib] * ratio
				--print(attrib.." "..value.." ----- "..oldVal.." -> "..self[attrib])
			elseif value < 0 then
				local ratio = (math.abs(value / MaxValue) + 1) ^ 3
				self[attrib] = self[attrib] / ratio
			end
			--print(attrib.." "..value.." ----- "..oldVal.." -> "..self[attrib])
		end
	end

	-- Finally apply LiquidType attributes
	local LiquidType = self:GetLiquidType()
	if self.LiquidTypes[LiquidType] then
		--[[for attrib, mult in pairs(self.LiquidTypes[LiquidType]) do
			--print("applying LiquidType multiplier of "..mult .." to "..attrib..": "..self[attrib].." -> "..self[attrib]*mult)
			--self[attrib] = self[attrib] * mult
		end--]]
		self:SetColor(self.LiquidTypes[LiquidType].TankColor)
	end

	self:SetLiquid((removeLiquid and 0) or math.min(self:GetLiquid(), self.MaxLiquid))
	--[[if SERVER then
		net.Start("JMod_MachineSync")
		net.WriteEntity(self)
		net.WriteTable(NetworkTable)
		net.Broadcast()
	end--]]
end

if(SERVER)then
	function ENT:CustomInit()
		self.EZconsumes = {
			JMod.EZ_RESOURCE_TYPES.BASICPARTS,
			JMod.EZ_RESOURCE_TYPES.WATER,
			JMod.EZ_RESOURCE_TYPES.POWER,
		}
		self.Rotation = {Max = 360}
		self.SoundRight = {"snds_jack_gmod/sprankler_slow_loop.wav"}
		self.SoundLeft = {"snds_jack_gmod/sprankler_fast_loop.wav"}
		-- All moddable attributes
		-- Each mod selected for it is +1, against it is -1
		self.ModPerfSpecs = {
			MaxLiquid = 0,
			TurnSpeed = 0,
			SprayRadius = 0,
			Rotation = {Max = 360},
			Armor = 0
		}
		--
		self:SetLiquidType(JMod.EZ_RESOURCE_TYPES.WATER)
		self:SetMods(self.ModPerfSpecs, self:GetLiquidType())
		--
		self.PerferredDonor = nil
		if self.SpawnFull then
			self:SetLiquid(self.MaxLiquid)
		else
			self:SetLiquid(0)
		end
		--
		self.NextLiquidThink = 0
		self.NextUseTime = 0
		self.NextEffThink = 0
		self.Dir = "right"
	end

	function ENT:Use(activator)
		if self.NextUseTime > CurTime() then return end
		local State = self:GetState()
		local Alt = activator:KeyDown(JMod.Config.General.AltFunctionKey)
		JMod.SetEZowner(self, activator)
		JMod.Colorify(self)

		if Alt and self:GetPhysicsObject():IsMotionEnabled() then
			activator:PickupObject(self)
		else
			if State == STATE_BROKEN then
				JMod.Hint(activator, "destroyed", self)
				return
			elseif State == STATE_OFF then
				self:TurnOn(activator)
			elseif State == STATE_ON then
				self:TurnOff(activator)
			end
		end
	end

	function ENT:TurnOn(activator)
		if self:GetState() <= STATE_BROKEN then return end
		if ((self:GetLiquid() > 0) or (self:LoadLiquidFromDonor(self:GetLiquidType(), 100) > 0)) and self:GetElectricity() > 0 then
			self.NextUseTime = CurTime() + 1
			if IsValid(activator) then self.EZstayOn = true end
			self:SetState(STATE_ON)
			if not self.SoundLoop then
				self.SoundLoop = CreateSound(self, (self.Dir == "left" and self.SoundLeft[1]) or self.SoundRight[1])
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

	function ENT:TurnOff(activator)
		if (self:GetState() <= 0) then return end
		self.NextUseTime = CurTime() + 1
		if IsValid(activator) then self.EZstayOn = nil end
		self:SetState(STATE_OFF)
		if self.SoundLoop then
			self.SoundLoop:Stop()
		end
	end

	function ENT:LoadLiquidFromDonor(typ, amt)
		local SelfPos = self:GetPos()
		if IsValid(self.PerferredDonor) and (self.PerferredDonor:GetPos():Distance(SelfPos) <= 100) then
			local Supplies = self.PerferredDonor:GetEZsupplies(typ)
			if (Supplies) and (Supplies > 0) then
				local Required = math.min(Supplies, amt)
				local Accepted = self:TryLoadResource(typ, Required)
				self.PerferredDonor:SetEZsupplies(typ, Supplies - Required, self)
				JMod.ResourceEffect(typ, self.PerferredDonor:LocalToWorld(self.PerferredDonor:OBBCenter()), self:LocalToWorld(self:OBBCenter()), amt/200, 1, 1)

				return Accepted
			end
		end
		for _, v in ipairs(ents.FindInSphere(SelfPos, 100)) do
			if v.GetEZsupplies then
				local Supplies = v:GetEZsupplies(typ)
				if Supplies and Supplies > 0 then
					local Required = math.min(Supplies, amt)
					local Accepted = self:TryLoadResource(typ, Required)
					v:SetEZsupplies(typ, Supplies - Required, self)
					self.PerferredDonor = v

					return Accepted
				end
			end
		end

		return 0
	end

	function ENT:ConsumeLiquid(amt)
		local SelfType = self:GetLiquidType()

		local NewAmt = math.Clamp(self:GetLiquid() - amt, 0.0, self.MaxLiquid)
		self:SetLiquid(NewAmt)
		if(NewAmt <= 0) and (self:GetState() > 0) then
			local Loaded = self:LoadLiquidFromDonor(SelfType, amt * 5)
			if Loaded < amt then
				self:TurnOff()
			end
		end
	end

	function ENT:TryLoadResource(typ, amt)
		if(amt <= 0)then return 0 end
		local Time = CurTime()
		if (self.NextRefillTime > Time) or (typ == "generic") then return 0 end
		for _,v in pairs(self.EZconsumes)do
			if(typ == v)then
				local Accepted = 0
				if(typ == JMod.EZ_RESOURCE_TYPES.BASICPARTS)then
					local Missing = self.MaxDurability - self.Durability
					if(Missing <= 0)then return 0 end
					Accepted = math.min(Missing / 2, amt)
					self.Durability = math.min(self.Durability + (Accepted * 2), self.MaxDurability)
					if(self.Durability >= self.MaxDurability)then self:RemoveAllDecals() end
					self:EmitSound("snd_jack_turretrepair.ogg", 65, math.random(90, 110))
					if(self.Durability > 0)then
						if(self:GetState() == JMod.EZ_STATE_BROKEN)then self:SetState(JMod.EZ_STATE_OFF) end
					end
					self:SetNW2Float("EZdurability", self.Durability)
				elseif(typ == JMod.EZ_RESOURCE_TYPES.POWER)then
					local Powa = self:GetElectricity()
					local Missing = self.MaxElectricity - Powa
					if(Missing <= 0)then return 0 end
					Accepted = math.min(Missing, amt)
					self:SetElectricity(Powa + Accepted)
					self:EmitSound("snd_jack_turretbatteryload.ogg", 65, math.random(90, 110))
				elseif(typ == self:GetLiquidType())then
					local Liquid = self:GetLiquid()
					local Missing = self.MaxLiquid - Liquid
					if( Missing < 1 )then return 0 end
					Accepted = math.min(Missing, amt)
					self:SetLiquid(Liquid + Accepted)
					self:EmitSound("snds_jack_gmod/liquid_load.ogg", 65, math.random(90, 110))
				end
				if self.ResourceLoaded then self:ResourceLoaded(typ, Accepted) end
				self.NextRefillTime = Time + 1
				return math.ceil(Accepted)
			end
		end
		return 0
	end

	function ENT:IsEntInFieldOfView(ent)
		if not IsValid(ent) then return false end
		local SelfPos, EntPos = self:GetPos(), ent:GetPos()
		if not (ent:GetPos().z <= SelfPos.z + 64) then return false end
		local TargetAngle = self:WorldToLocal(EntPos):Angle().y
		if (TargetAngle > (360 - self.Rotation.Max)) then return false end
		if JMod.ClearLoS(self, v, false, 34) then return true end
	end

	local ThinkRate = 60/12 --Hz
	local EntsToRemove = {["ent_jack_gmod_eznapalm"] = true, ["ent_jack_gmod_ezfirehazard"] = true}

	function ENT:Think()
		local Time, State, SelfPos = CurTime(), self:GetState(), self:GetPos()
		local LiquidTyp = self:GetLiquidType()
		local LiquidConversionSpeed = 1.5

		self:UpdateWireOutputs()

		if self.NextLiquidThink < Time then
			self.NextLiquidThink = Time + ThinkRate
			if State == STATE_ON then
				if LiquidTyp == JMod.EZ_RESOURCE_TYPES.WATER then
					local WaterDeliveryAmt = 1 * LiquidConversionSpeed
					local WaterConsumptionAmt = 4 * LiquidConversionSpeed

					--debugoverlay.Sphere(SelfPos, self.SprayRadius, 1, Color(0, 255, 0), false)
					--print("Spray Radius: "..self.SprayRadius)
					for k, v in ipairs(ents.FindInSphere(self:GetPos(), self.SprayRadius)) do
						if self:IsEntInFieldOfView(v) then
							if v:IsOnFire() then v:Extinguish() end
							if EntsToRemove[v:GetClass()] and math.random(1, 3) >= 2 then
								SafeRemoveEntity(v)
							end
							if  v.Hydration and table.HasValue(v.EZconsumes, JMod.EZ_RESOURCE_TYPES.WATER) then
								v.Hydration = math.Clamp(v.Hydration + WaterDeliveryAmt, 0, 100)
							end
							v:RemoveAllDecals()
						end
					end--]]
					self:ConsumeElectricity(0.5 * LiquidConversionSpeed)
					self:ConsumeLiquid(WaterConsumptionAmt)
				elseif LiquidTyp == JMod.EZ_RESOURCE_TYPES.FUEL then
					local LiquidConsumptionAmt = 1 * LiquidConversionSpeed
					self:ConsumeElectricity(0.75 * LiquidConversionSpeed)
					self:ConsumeLiquid(LiquidConsumptionAmt)
				end
			end
		end

		if (self.NextEffThink < Time) then
			self.NextEffThink = Time + ((self.Dir == "left") and .075 or .15)
			if (State == STATE_ON) then
				local CurrentRot = self:GetHeadRot()
				local SelfAng = self:GetAngles()

				local SprayAngle = SelfAng:GetCopy()
				SprayAngle:RotateAroundAxis(SprayAngle:Up(), CurrentRot - 90)
				SprayAngle:RotateAroundAxis(SprayAngle:Right(), 35)
				
				if LiquidTyp == JMod.EZ_RESOURCE_TYPES.WATER then
					local Zoop = SprayAngle:Forward()
					if (self.Dir == "left") then
						Zoop = Zoop * .5
					end
					local SplachPos = SelfPos + self:GetUp() * 36 + SprayAngle:Forward() * 3
					--[[local Splach = EffectData()
					Splach:SetOrigin(SplachPos + SprayAngle:Forward() * 2)
					Splach:SetStart(Zoop)
					Splach:SetScale((self.Dir == "right") and 1 or .4)
					util.Effect("eff_jack_gmod_spranklerspray", Splach)--]]
					JMod.LiquidSpray(SplachPos, Zoop * 600, 1, self:EntIndex(), 3)

				elseif LiquidTyp == JMod.EZ_RESOURCE_TYPES.FUEL then
					local FirePos = util.QuickTrace(SelfPos + self:GetUp() * 35, SprayAngle:Forward() * 100, self).HitPos
					
					local RadiusMult = (self.SprayRadius / 400)
					if math.random(1, 2) == 1 then
						local Flame = ents.Create("ent_jack_gmod_eznapalm")
						Flame:SetPos(FirePos)
						local FlyAng = (SprayAngle:Forward() + VectorRand() * .1):Angle()
						Flame:SetAngles(FlyAng)
						Flame:SetOwner(JMod.GetEZowner(self))
						Flame.HighVisuals = (math.random(1, 2) == 1)
						Flame.SpeedMul = math.Rand(.25, .5) * RadiusMult
						Flame.LifeTime = math.random(2, 3)
						Flame.Creator = self
						Flame.Burnin = true
						JMod.SetEZowner(Flame, self.Owner)
						Flame:Spawn()
						Flame:Activate()
					end
					--
					local Foof = EffectData()
					Foof:SetNormal(SprayAngle:Forward())
					Foof:SetScale(1.5)
					Foof:SetStart(SprayAngle:Forward() * 300 * RadiusMult)
					Foof:SetOrigin(FirePos - SprayAngle:Forward() * 100)
					Foof:SetAttachment(0)
					util.Effect("eff_jack_gmod_ezflamethrowerfire", Foof, true, true)
					JMod.LiquidSpray(FirePos, SprayAngle:Forward() * 300 * RadiusMult, 1, self:EntIndex(), 2)
				end

				local TurnSpeed = self.TurnSpeed
				local HalfOfRot = (self.Rotation.Max or 360) / 2
				local RotMin, RotMax = -HalfOfRot, HalfOfRot
				if CurrentRot > RotMax then
					self.Dir = "right"
					if self.SoundLoop then
						self.SoundLoop:Stop()
					end
					self.SoundLoop = CreateSound(self, self.SoundRight[1])
					self.SoundLoop:Play()
					self.SoundLoop:SetSoundLevel(65)
					self.SoundLoop:ChangePitch(self.SoundRight[2] or 100)
				elseif CurrentRot < RotMin then
					self.Dir = "left"
					if self.SoundLoop then
						self.SoundLoop:Stop()
					end
					self.SoundLoop = CreateSound(self, self.SoundLeft[1])
					self.SoundLoop:Play()
					self.SoundLoop:SetSoundLevel(65)
					self.SoundLoop:ChangePitch(self.SoundLeft[2] or 100)
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

	function ENT:OnPostEntityPaste(ply, ent, createdEntities)
		local Time = CurTime()
		self.NextLiquidThink = Time + math.Rand(0, 3)
		self.NextUseTime = Time + math.Rand(0, 3)
		self.NextEffThink = Time + math.Rand(0, 3)
		self:SetMods(self.ModPerfSpecs, self:GetLiquidType())
	end

elseif(CLIENT)then
	function ENT:CustomInit()
		self:DrawShadow(true)
		self.Sprinkleer = JMod.MakeModel(self, "models/jmod/machines/sprinkler_head.mdl")
		self.Debug = false
		self.ModPerfSpecs = {}
	end

	local DebugCooler = Color(61, 200, 255)
	function ENT:Draw()
		local SelfPos, SelfAng, State = self:GetPos(), self:GetAngles(), self:GetState()
		local Up, Right, Forward = SelfAng:Up(), SelfAng:Right(), SelfAng:Forward()
		local Grade = self:GetGrade()
		---
		local BasePos = SelfPos
		local Obscured = false--util.TraceLine({start = EyePos(), endpos = BasePos, filter = {LocalPlayer(), self}, mask = MASK_OPAQUE}).Hit
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
		SprinkleerAng:RotateAroundAxis(Up, self:GetHeadRot() - 90)
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
				local WaterFrac = self:GetLiquid() / self.MaxLiquid
				--local FuelFrac = self:GetFuel() / self.MaxFuel
				local R, G, B = JMod.GoodBadColor(PowFrac)
				local WR, WG, WB = JMod.GoodBadColor(WaterFrac)
				--local FR, FG, FB = JMod.GoodBadColor(FuelFrac)

				cam.Start3D2D(SelfPos - Forward * 1 - Up * 8 - Right * 12, DisplayAng, .06)
				draw.SimpleTextOutlined("POWER", "JMod-Display", 0, 0, Color(255, 255, 255, Opacity), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, Opacity))
				draw.SimpleTextOutlined(tostring(math.Round(PowFrac * self.MaxElectricity)) .. "%", "JMod-Display", 0, 30, Color(R, G, B, Opacity), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, Opacity))
				draw.SimpleTextOutlined(string.upper(self:GetLiquidType()), "JMod-Display", 0, 90, Color(255, 255, 255, Opacity), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, Opacity))
				draw.SimpleTextOutlined(tostring(math.Round(WaterFrac * self.MaxLiquid)) .. "%", "JMod-Display", 0, 120, Color(WR, WG, WB, Opacity), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, Opacity))
				--draw.SimpleTextOutlined("FUEL", "JMod-Display", 0, 90, Color(255, 255, 255, Opacity), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, Opacity))
				--draw.SimpleTextOutlined(tostring(math.Round(FuelFrac * 100)) .. "%", "JMod-Display", 0, 120, Color(FR, FG, FB, Opacity), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, Opacity))
				cam.End3D2D()

			end
		end
	end
	language.Add("ent_jack_gmod_ezlfg", "EZ Liquid Fuel Generator")
end
