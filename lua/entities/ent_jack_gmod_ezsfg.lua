-- AdventureBoots Mid 2023
-- Zackarunda, shortly thereafter
AddCSLuaFile()
ENT.Type = "anim"
ENT.PrintName = "EZ Solid Fuel Generator"
ENT.Author = "Jackarunda, AdventureBoots"
ENT.Category = "JMod - EZ Machines"
ENT.Information = ""
ENT.Spawnable = true
ENT.Base = "ent_jack_gmod_ezmachine_base"
ENT.Model = "models/jmod/machines/biofuel_jenerator.mdl"
ENT.EZupgradable = true
--
ENT.JModPreferredCarryAngles = Angle(0, 0, 0)
ENT.Mass = 400
ENT.SpawnHeight = 5
ENT.EZcolorable = true
--
ENT.StaticPerfSpecs = {
	MaxDurability = 200,
	MaxElectricity = 1000,
	MaxWater = 300
}

ENT.DynamicPerfSpecs = {
	ChargeSpeed = 1,
	Armor = 2
}
ENT.EZconsumes = {
	JMod.EZ_RESOURCE_TYPES.BASICPARTS,
	JMod.EZ_RESOURCE_TYPES.COAL,
	JMod.EZ_RESOURCE_TYPES.WOOD,
	JMod.EZ_RESOURCE_TYPES.WATER
}
ENT.FlexFuels = { JMod.EZ_RESOURCE_TYPES.COAL, JMod.EZ_RESOURCE_TYPES.WOOD }
ENT.EZpowerProducer = true
ENT.EZpowerSocket = Vector(65, 18, 18)
ENT.MaxConnectionRange = 500

function ENT:CustomSetupDataTables()
	self:NetworkVar("Float", 2, "Progress")
	self:NetworkVar("Float", 3, "Water")
end

local STATE_BROKEN, STATE_OFF, STATE_ON = -1, 0, 1

if(SERVER)then
	function ENT:CustomInit()
		self:SetProgress(0)
		if self.SpawnFull then
			self:SetWater(self.MaxWater)
		else
			self:SetWater(0)
		end
		self.NextResourceThink = 0
		self.NextWaterLoseTime = 0
		self.NextUseTime = 0
		self.NextEffThink = 0
		self.NextFoofThink = 0
		self.NextEnvThink = 0
		self.Suffocated = 0
	end

	function ENT:Use(activator)
		if self.NextUseTime > CurTime() then return end
		local State = self:GetState()
		local Alt = JMod.IsAltUsing(activator)
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
				self:TurnOff()
			end
		end
	end

	function ENT:TurnOn(activator, auto)
		if self:GetState() > STATE_OFF then return end
		if (self:WaterLevel() > 1) then return end
		if (self:GetElectricity() > 0) and (self:GetWater() > 0) then
			self.NextUseTime = CurTime() + 1
			self:SetState(STATE_ON)
			timer.Simple(0.1, function()
				if(self.SoundLoop)then self.SoundLoop:Stop() end
				self.SoundLoop = CreateSound(self, "snds_jack_gmod/intense_fire_loop.wav")
				self.SoundLoop:SetSoundLevel(60)
				self.SoundLoop:Play()
			end)
		elseif self:GetElectricity() <= 0 then 
			JMod.Hint(activator, "need combustibles")

			return
		elseif self:GetWater() <= 0 then
			JMod.Hint(activator, "refill sfg water")

			return
		end
		if IsValid(activator) and not(auto) then
			self.EZstayOn = true
			self:EmitSound("snd_jack_littleignite.ogg")
		end
		self:UpdateWireOutputs()
	end

	function ENT:TurnOff(activator)
		if (self:GetState() <= 0) then return end
		self.NextUseTime = CurTime() + 1
		if IsValid(activator) then self.EZstayOn = true end
		if self.SoundLoop then self.SoundLoop:Stop() end
		--self:EmitSound("snds_jack_gmod/genny_stop.ogg", 70, 100)
		self:EmitSound("snd_jack_littleignite.ogg")
		self:SetState(STATE_OFF)
		self:ProduceResource()
		self:UpdateWireOutputs()
	end

	--[[function ENT:ResourceLoaded(typ, accepted)
		if (typ == JMod.EZ_RESOURCE_TYPES.COAL) or (typ == JMod.EZ_RESOURCE_TYPES.WOOD) and accepted > 0 then
			timer.Simple(.1, function() 
				if IsValid(self) then self:TurnOn() end 
			end)
		end
	end--]]

	function ENT:OnRemove()
		if self.SoundLoop then self.SoundLoop:Stop() end
	end

	function ENT:ProduceResource()
		local SelfPos, Up, Forward, Right = self:GetPos(), self:GetUp(), self:GetForward(), self:GetRight()
		local amt = math.Clamp(math.floor(self:GetProgress()), 0, 100)

		if amt <= 0 then return end
		local pos = self:WorldToLocal(SelfPos + Up * 30 + Right * -40 + Forward * 60)
		self:SetProgress(math.Clamp(self:GetProgress() - amt, 0, 100))
		JMod.MachineSpawnResource(self, JMod.EZ_RESOURCE_TYPES.POWER, amt, pos, Angle(0, 90, 0), Right * -60, 200)
		self:EmitSound("snds_jack_gmod/steam_whistle_start.ogg", 150, 100)
		self.SteamLoop = CreateSound(self, "snds_jack_gmod/steam_whistle_loop.wav", nil)
		timer.Simple(0.16, function()
			if not(IsValid(self)) then return end
			self.SteamLoop:Play()
			for i = 0, 10 do
				timer.Simple(i * 0.1, function()
					if not(IsValid(self)) then return end
					local Foof = EffectData()
					Foof:SetOrigin(SelfPos + Up * 74 + Right * 0 + Forward * 34)
					Foof:SetNormal(Up)
					Foof:SetScale(0.5)
					Foof:SetStart(self:GetPhysicsObject():GetVelocity())
					util.Effect("eff_jack_gmod_ezsteam", Foof, true, true)
					if i == 10 then
						self.SteamLoop:Stop()
						timer.Simple(0, function()
							if IsValid(self) then self:EmitSound("snds_jack_gmod/steam_whistle_end.ogg", 150, 100) end
						end)
					end
				end)
			end
		end)
	end

	function ENT:OnBreak()
		if self.SoundLoop then
			self.SoundLoop:Stop()
		end
		if self.SteamLoop then
			self.SteamLoop:Stop()
		end
	end

	function ENT:ConsumeWater(amt)
		amt = (amt or .2)
		local NewAmt = math.Clamp(self:GetWater() - amt, 0.0, self.MaxWater)
		self:SetWater(NewAmt)
	end

	function ENT:Think()
		local Time, State, Grade = CurTime(), self:GetState(), self:GetGrade()
		local Up, Forward, Right = self:GetUp(), self:GetForward(), self:GetRight()

		self:UpdateWireOutputs()

		if self.NextResourceThink < Time then
			self.NextResourceThink = Time + 1
			if State == STATE_ON then
				if (self:WaterLevel() > 0) then 
					self:TurnOff() 
					local Foof = EffectData()
					Foof:SetOrigin(self:GetPos())
					Foof:SetNormal(-Right)
					Foof:SetScale(10)
					Foof:SetStart(self:GetPhysicsObject():GetVelocity())
					util.Effect("eff_jack_gmod_ezsteam", Foof, true, true)
					self:EmitSound("snds_jack_gmod/hiss.ogg", 100, 100)
					return 
				end
				local NRGperFuel = 1 * JMod.EnergyEconomyParameters.SteamGennyEfficiencies[Grade]
				local FuelToConsume = JMod.EZ_GRADE_BUFFS[Grade]
				local PowerToProduce = FuelToConsume * NRGperFuel
				local SpeedModifier = 4

				if self:GetWater() <= 0 or self:GetElectricity() <= 0 then
					self:TurnOff()
				end

				self:ConsumeElectricity(FuelToConsume * SpeedModifier)

				self:ConsumeWater(FuelToConsume * 0.4 * JMod.EnergyEconomyParameters.SteamGennyEfficiencies[Grade] * SpeedModifier)

				self:SetProgress(self:GetProgress() + PowerToProduce * SpeedModifier)

				if self:GetProgress() >= 100 then self:ProduceResource() end
			end
		end

		if (self.NextEffThink < Time) then
			self.NextEffThink = Time + .4 * Grade
			if (State == STATE_ON) then
				local Eff = EffectData()
				Eff:SetOrigin(self:GetPos() + Up * 90 + Forward * 70)
				Eff:SetNormal(Up)
				Eff:SetScale(1)
				util.Effect("eff_jack_gmod_ezexhaust", Eff, true)
				--
			end
		end
		if (self.NextFoofThink < Time) then
			self.NextFoofThink = Time + .4/Grade
			if (State == STATE_ON) then
				self:EmitSound("snds_jack_gmod/hiss.wav", 75, math.random(75, 80) * Grade / 2)
				local Foof = EffectData()
				Foof:SetOrigin(self:GetPos() + Up * 30 + Right * -25 + Forward * 35)
				Foof:SetNormal(-Right)
				Foof:SetScale(0.5)
				Foof:SetStart(self:GetPhysicsObject():GetVelocity())
				util.Effect("eff_jack_gmod_ezsteam", Foof, true, true)
			end
		end

		if (self.NextEnvThink < Time) then
			self.NextEnvThink = Time + 3
			if (State == STATE_ON) then
				local Tr = util.QuickTrace(self:GetPos() + Forward * 70, Vector(0, 0, 9e9), self)
				if not (Tr.HitSky) and (math.random(1, Grade) == 1) then
					local Gas = ents.Create("ent_jack_gmod_ezcoparticle")
					Gas:SetPos(self:GetPos() + Forward * 120 + Vector(0, 0, 100))
					JMod.SetEZowner(Gas, self.EZowner)
					Gas:SetDTBool(0, true)
					Gas:Spawn()
					Gas:Activate()
					Gas.CurVel = (VectorRand() * math.random(1, 100))
				end
				if (Up.z < .70) then -- we are too tilted
					self.Suffocated = self.Suffocated + 1
					if (self.Suffocated >= 2) then
						self:TurnOff()
						return
					end
				else
					self.Suffocated = 0
				end
			end
		end
	end

	function ENT:OnPostEntityPaste(ply, ent, createdEntities)
		local Time = CurTime()
		self.NextResourceThink = Time + math.Rand(0, 3)
		self.NextUseTime = Time + math.Rand(0, 3)
		self.NextEffThink = Time + math.Rand(0, 3)
		self.NextEnvThink = Time + math.Rand(0, 3)
		self.NextWaterLoseTime = Time
	end

	function ENT:OnDestroy(dmginfo)
		local Pos = self:GetPos()
		local Foof = EffectData()
		Foof:SetOrigin(Pos + self:GetUp() * 10)
		--Foof:SetNormal(self:GetUp())
		Foof:SetScale(50)
		Foof:SetStart(self:GetPhysicsObject():GetVelocity() + VectorRand() * math.random(10, 100))
		util.Effect("eff_jack_gmod_ezsteam", Foof, true, true)
		self:EmitSound("snds_jack_gmod/hiss.ogg", 100, 100)

		local Steeam = (self:GetWater() / self.MaxWater) / (self:GetElectricity() / self.MaxElectricity)

		local Range = 250 * Steeam
		for _, ent in pairs(ents.FindInSphere(Pos, Range)) do
			if ent ~= self then
				local DDistance = Pos:Distance(ent:GetPos())
				local DistanceFactor = (1 - DDistance / Range) ^ 2

				if JMod.ClearLoS(self, ent) then
					local Dmg = DamageInfo()
					Dmg:SetDamage(100 * DistanceFactor * Steeam) -- wanna scale this with distance
					Dmg:SetDamageType(DMG_BURN)
					Dmg:SetDamageForce(Vector(0, 0, 5000) * DistanceFactor) -- some random upward force
					Dmg:SetAttacker((IsValid(dmginfo:GetAttacker()) and dmginfo:GetAttacker()) or game.GetWorld()) -- the earth is mad at you
					Dmg:SetInflictor(self or game.GetWorld())
					Dmg:SetDamagePosition(ent:GetPos())

					if ent.TakeDamageInfo then
						ent:TakeDamageInfo(Dmg)
					end
				end
			end
		end
	end

elseif(CLIENT)then
	function ENT:CustomInit()
		self:DrawShadow(true)
		self.Piston = JMod.MakeModel(self, "models/jmod/machines/biofuel_piston.mdl")
		self.Pusher = JMod.MakeModel(self, "models/jmod/machines/biofuel_pusher.mdl")
		self.Flywheel = JMod.MakeModel(self, "models/jmod/machines/biofuel_flywheel.mdl")
		self.WheelTurn = 0
		self.WheelMomentum = 0
	end

	function ENT:Think()
		local State, Grade = self:GetState(), self:GetGrade()
		local FT = FrameTime()
		if State == STATE_ON then
			self.WheelMomentum = math.Clamp(self.WheelMomentum or 0 + FT / 8, 0, 1)
		else
			self.WheelMomentum = math.Clamp(self.WheelMomentum or 0 - FT / 2, 0, 1)
		end
		self.WheelTurn = self.WheelTurn or 0 - self.WheelMomentum*Grade*FT*300

		if self.WheelTurn > 360 then
			self.WheelTurn = 1
		elseif self.WheelTurn < 0 then
			self.WheelTurn = 360
		end
	end

	local WhiteSquare = Material("white_square")
	local HeatWaveMat = Material("sprites/heatwave")

	function ENT:Draw()
		local SelfPos, SelfAng, State = self:GetPos(), self:GetAngles(), self:GetState()
		local Up, Right, Forward = SelfAng:Up(), SelfAng:Right(), SelfAng:Forward()
		local Grade = self:GetGrade()
		---
		local BasePos = SelfPos
		local Obscured = util.TraceLine({start = EyePos(), endpos = BasePos + Up * 60, filter = {LocalPlayer(), self}, mask = MASK_OPAQUE}).Hit
		local Closeness = LocalPlayer():GetFOV() * (EyePos():Distance(SelfPos))
		local DetailDraw = Closeness < 120000 -- cutoff point is 400 units when the fov is 90 degrees
		---
		if((not(DetailDraw)) and (Obscured))then return end -- if player is far and sentry is obscured, draw nothing
		if(Obscured)then DetailDraw = false end -- if obscured, at least disable details
		if(State == STATE_BROKEN)then DetailDraw = false end -- look incomplete to indicate damage, save on gpu comp too
		---
		self:DrawModel()
		---
		if (State == STATE_ON) then
				local GlowPos = BasePos + Up * 60 + Forward * -13
				local GlowAng = SelfAng:GetCopy()
				local Roll = GlowAng.r
				GlowAng:RotateAroundAxis(GlowAng:Up(), 180)
				local GlowDir = GlowAng:Forward()
				render.SetMaterial(WhiteSquare)
			if Closeness > 40000 then
				render.DrawQuadEasy(GlowPos + GlowDir * math.Rand(.9, 1), GlowDir, 24, 12, Color( 255, 167, 116, 225), Roll)
			else
				for i = 1, 5 do
					render.DrawQuadEasy(GlowPos + GlowDir * (1 + i / 5) * math.Rand(.9, 1), GlowDir, 24, 12, Color( 255, 255, 255, 200 ), Roll)
				end
				for i = 1, 20 do
					render.DrawQuadEasy(GlowPos + GlowDir * i / 2.5 * math.Rand(.9, 1), GlowDir, 24, 12, Color( 255 - i * 1, 255 - i * 9, 200 - i * 10, 55 - i * 2.5 ), Roll)
				end
				if JMod.Config.QoL.NiceFire then
					render.SetMaterial(HeatWaveMat)
					for i = 1, 2 do
						--render.DrawSprite(BasePos + Up * (i * math.random(10, 30) + 80) + Forward * 70, 30, 30, Color(255, 255 - i * 10, 255 - i * 20, 25))
						--render.DrawSprite(BasePos + Up * 60 + Right * (i * math.random(5, -5)) - Forward * 24, 30, 30, Color(255, 255 - i * 10, 255 - i * 20, 25))
					end
				end
			end
		end
		if DetailDraw then
			--- render wheel
			local FlywheelPos = BasePos + Up * 18 + Forward * 64.5 - Right * 21.5
			local FlywheelAng = SelfAng:GetCopy()
			FlywheelAng:RotateAroundAxis(Right, self.WheelTurn)
			JMod.RenderModel(self.Flywheel, FlywheelPos, FlywheelAng, nil, Vector(1, 1, 1), JMod.EZ_GRADE_MATS[Grade])
			--- calculate and render piston based on orientation of wheel (the piston is slaved to the wheel, in terms of render math)
			local PistonPivotPos = FlywheelPos + Up * 16 - Forward * 29 - Right * 1.2
			local WheelTurnRadians = math.rad(self.WheelTurn)
			local PistonEndX = -math.sin(WheelTurnRadians)
			local PistonEndY = -math.cos(WheelTurnRadians)
			local PistonEndPos = FlywheelPos - PistonEndX * Forward * 9.3 + PistonEndY * Up * 9.3 - Right * 1.2
			-- now that we know the desired tip positions, we can calc the angle for the piston housing
			local PistonVec = PistonEndPos - PistonPivotPos
			local PistonDir = PistonVec:GetNormalized()
			local PistonAng = PistonDir:Angle()
			JMod.RenderModel(self.Piston, PistonPivotPos, PistonAng, nil, Vector(1, 1, 1), JMod.EZ_GRADE_MATS[Grade])
			-- now render the piston shaft at the same angle, but slide it along the vector by some amount
			local PusherPos = PistonEndPos
			JMod.RenderModel(self.Pusher, PusherPos, PistonAng, nil, Vector(1, 1, 1), JMod.EZ_GRADE_MATS[Grade])
			---
			if Closeness < 20000 and (State == STATE_ON) then
				local DisplayAng = SelfAng:GetCopy()
				DisplayAng:RotateAroundAxis(DisplayAng:Right(), 0)
				DisplayAng:RotateAroundAxis(DisplayAng:Up(), -90)
				DisplayAng:RotateAroundAxis(DisplayAng:Forward(), 90)
				local Opacity = math.random(50, 150)
				local ProgFrac = self:GetProgress() / 100
				local FuelFrac = self:GetElectricity() / self.MaxElectricity
				local PresFrac = self:GetWater() / self.MaxWater
				local R, G, B = JMod.GoodBadColor(ProgFrac)
				local PR, PG, PB = JMod.GoodBadColor(PresFrac)
				local FR, FG, FB = JMod.GoodBadColor(FuelFrac)

				cam.Start3D2D(SelfPos + Forward * -23 + Right * -16 + Up * 53, DisplayAng, .06)
				surface.SetDrawColor(10, 10, 10, Opacity + 50)
				local RankX, RankY = -70, 240
				surface.DrawRect(RankX, RankY, 128, 128)
				JMod.StandardRankDisplay(Grade, RankX + 62, RankY + 68, 118, Opacity + 50)
				draw.SimpleTextOutlined("PROGRESS", "JMod-Display", 0, 10, Color(255, 255, 255, Opacity), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, Opacity))
				draw.SimpleTextOutlined(tostring(math.Round(ProgFrac * 100)) .. "%", "JMod-Display", 0, 40, Color(R, G, B, Opacity), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, Opacity))
				draw.SimpleTextOutlined("WATER", "JMod-Display", 0, 80, Color(255, 255, 255, Opacity), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, Opacity))
				draw.SimpleTextOutlined(tostring(math.Round(PresFrac * 100)) .. "%", "JMod-Display", 0, 110, Color(PR, PG, PB, Opacity), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, Opacity))
				draw.SimpleTextOutlined("FUEL", "JMod-Display", 0, 150, Color(255, 255, 255, Opacity), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, Opacity))
				draw.SimpleTextOutlined(tostring(math.Round(FuelFrac * 100)) .. "%", "JMod-Display", 0, 180, Color(FR, FG, FB, Opacity), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, Opacity))
				cam.End3D2D()
			end
		end
	end
	language.Add("ent_jack_gmod_ezsfg", "EZ Solid Fuel Generator")
end
