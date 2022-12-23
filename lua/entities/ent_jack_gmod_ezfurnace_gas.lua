AddCSLuaFile()
ENT.Type = "anim"
ENT.Author = "Jackarunda"
ENT.Information = "glhfggwpezpznore"
ENT.PrintName = "EZ Ore Smelter"
ENT.Category = "JMod - EZ Misc."
ENT.Spawnable = true -- Temporary, until the next phase of Econ2
ENT.AdminOnly = false
ENT.Base = "ent_jack_gmod_ezmachine_base"
---
ENT.Model = "models/jmodels/props/machines/gas_smelter.mdl"
ENT.Mass = 200
ENT.SpawnHeight = 10
---
ENT.EZconsumes = {
	JMod.EZ_RESOURCE_TYPES.BASICPARTS,
	JMod.EZ_RESOURCE_TYPES.POWER,
	JMod.EZ_RESOURCE_TYPES.FUEL,
	JMod.EZ_RESOURCE_TYPES.IRONORE,
	JMod.EZ_RESOURCE_TYPES.LEADORE,
	JMod.EZ_RESOURCE_TYPES.ALUMINUMORE,
	JMod.EZ_RESOURCE_TYPES.COPPERORE,
	JMod.EZ_RESOURCE_TYPES.TUNGSTENORE,
	JMod.EZ_RESOURCE_TYPES.TITANIUMORE,
	JMod.EZ_RESOURCE_TYPES.SILVERORE,
	JMod.EZ_RESOURCE_TYPES.GOLDORE,
	JMod.EZ_RESOURCE_TYPES.PLATINUMORE
}
---
ENT.EZupgradable = true
ENT.StaticPerfSpecs = {
	MaxDurability = 100,
	MaxElectricity = 200,
	MaxOre = 100,
	MaxFuel = 100
}
ENT.DynamicPerfSpecs = {
	FuelEffeciency = 1,
	Armor = 1
}
---
local STATE_BROKEN,STATE_OFF,STATE_SMELTING=-1,0,1
---
function ENT:CustomSetupDataTables()
	self:NetworkVar("Float", 1, "Fuel")
	self:NetworkVar("Float", 2, "Progress")
	self:NetworkVar("Float", 3, "Ore")
	self:NetworkVar("String", 0, "OreType")
end
if(SERVER)then
	function ENT:CustomInit()
		self:SetAngles(Angle(0, 0, 0))
		self:SetProgress(0)
		self:SetFuel(0)
		self:SetOre(0)
		self:SetOreType("generic")
		self.TimeSinceLastOre = 0
		self.NextEffThink = 0
		self.NextSmeltThink = 0
	end
	function ENT:TurnOn(activator)
		if self:GetFuel() > 0 and self:GetOre() > 0 then
			self:SetState(STATE_SMELTING)
			self:EmitSound("snd_jack_littleignite.wav")
			timer.Simple(0.1, function()
				self.SoundLoop = CreateSound(self, "snds_jack_gmod/intense_fire_loop.wav")
				self.SoundLoop:SetSoundLevel(50)
				self.SoundLoop:Play()
				self:SetProgress(0)
			end)
		else
			JMod.Hint(activator, "nopower")
		end
	end

	function ENT:TurnOff()
		self:SetState(STATE_OFF)
		self:ProduceResource()
		if self.SoundLoop then
			self.SoundLoop:Stop()
		end

		self:EmitSound("snd_jack_littleignite.wav")
	end

	function ENT:Use(activator)
		local State = self:GetState()
		local OldOwner = self.Owner
		local Alt = activator:KeyDown(JMod.Config.AltFunctionKey)
		JMod.SetOwner(self, activator)
		if(IsValid(self.Owner))then
			if(OldOwner ~= self.Owner)then -- if owner changed then reset team color
				JMod.Colorify(self)
			end
		end

		if State == STATE_BROKEN then
			JMod.Hint(activator, "destroyed", self)

			return
		elseif State==STATE_OFF then
			self:TurnOn()
		elseif State==STATE_SMELTING then
			if Alt then 
				self:ProduceResource()

				return
			end
			self:TurnOff()
		end
	end

	function ENT:OnRemove()
		if(self.SoundLoop)then self.SoundLoop:Stop() end
	end

	function ENT:ConsumeFuel(amt)
		local Elec = self:GetElectricity()
		amt = (amt or .5)/self.FuelEffeciency
		if Elec > 0 then
			local NewAmt = math.Clamp(Elec - amt, 0.0, self.MaxElectricity)
			self:SetElectricity(NewAmt)
		else
			local NewAmt = math.Clamp(self:GetFuel() - amt, 0.0, self.MaxFuel)
			self:SetFuel(NewAmt)
			if(NewAmt <= 0 and self:GetState() > 0)then self:TurnOff() end
		end
	end

	function ENT:SpawnEffect(pos)
		--[[local effectdata=EffectData()
		effectdata:SetOrigin(pos)
		effectdata:SetNormal((VectorRand()+Vector(0,0,1)):GetNormalized())
		effectdata:SetMagnitude(math.Rand(5,10))
		effectdata:SetScale(math.Rand(.5,1.5))
		effectdata:SetRadius(math.Rand(2,4))
		util.Effect("Sparks", effectdata)]]--
		self:EmitSound("snds_jack_gmod/ding.wav", 80, 120)
	end

	function ENT:ResourceLoaded(typ, accepted)
		if typ == self:GetOreType() and accepted >= 1 then
			self:TurnOn(self.Owner)
		end
	end

	function ENT:ProduceResource()
		local amt = self:GetProgress()
		local SelfPos, Forward, Up, Right, OreType = self:GetPos(), self:GetForward(), self:GetUp(), self:GetRight(), self:GetOreType()
		
		if amt <= 0 or OreType == "generic" then self:SetOre(0) return end

		local RefinedTable = JMod.RefiningTable[OreType]

		local pos = SelfPos
		for type, modifier in pairs(RefinedTable) do
			local i = 1
			local spawnVec = self:WorldToLocal(SelfPos + Right * 30 + Up * 20 * i)
			local spawnAng = Angle(0, 0, 0)
			local ejectVec = Forward * 100
			timer.Simple(0.2*i, function()
				if IsValid(self) then
					JMod.MachineSpawnResource(self, type, amt*modifier, spawnVec, spawnAng, ejectVec, true, 200)
				end
			end)
			i = i + 1
			self:SetProgress(math.Clamp(self:GetProgress() - amt, 0, 100))
			self:SetOre(math.Clamp(self:GetOre() - amt, 0, self.MaxOre))
			self:SpawnEffect(pos)
			if self:GetOre() <= 0 then
				self:SetOreType("generic")
			end
		end
	end

	function ENT:Think()
		local State, Time, OreTyp = self:GetState(), CurTime(), self:GetOreType()
		if (self.NextSmeltThink < Time) then
			self.NextSmeltThink = Time + 1
			if State == STATE_SMELTING then
				if not OreTyp then self:TurnOff() return end

				self:ConsumeFuel(.5)

				if self:GetOre() <= 0 then
					self.TimeSinceLastOre = self.TimeSinceLastOre + 1
				else
					self.TimeSinceLastOre = 0
					local Grade = self:GetGrade()
					local RefineAmt = math.min(Grade ^ 2, self:GetOre() - self:GetProgress())
					self:SetProgress(self:GetProgress() + RefineAmt)
				end
				if self.TimeSinceLastOre >= 5 then self:TurnOff() end

				if self:GetProgress() >= math.min(self:GetOre(), 100) then
					self:ProduceResource()
				end
			end
		end
		if (self.NextEffThink < Time) then
			self.NextEffThink = Time + .1
			if (State == STATE_SMELTING) then
				local Eff = EffectData()
				Eff:SetOrigin(self:GetPos() + self:GetUp() * 110 + self:GetRight() * -5 + self:GetForward() * 12)
				Eff:SetNormal(self:GetUp())
				Eff:SetScale(.1)
				util.Effect("eff_jack_gmod_ezoilfiresmoke", Eff, true)
			end
		end

		self:NextThink(Time + .1)
		return true
	end

elseif(CLIENT)then
	function ENT:Initialize()
		self.StaticPerfSpecs.BaseClass = nil
		self.DynamicPerfSpecs.BaseClass = nil
		self:InitPerfSpecs()
		if(self.CustomInit)then self:CustomInit() end
		self.Piping = JMod.MakeModel(self, "models/props_c17/gasmeter002a.mdl")
	end
	local GradeColors = JMod.EZ_GRADE_COLORS
	local GradeMats = JMod.EZ_GRADE_MATS
	local WhiteSquare = Material("white_square")
	local HeatWaveMat = Material("sprites/heatwave")
	function ENT:Draw()
		local SelfPos, SelfAng, State = self:GetPos(), self:GetAngles(), self:GetState()
		local Up, Right, Forward = SelfAng:Up(), SelfAng:Right(), SelfAng:Forward()
		local Grade = self:GetGrade()
		---
		local BasePos = SelfPos

		local Obscured = util.TraceLine({
			start=EyePos(), 
			endpos=BasePos, 
			filter = {LocalPlayer(), self}, 
			mask = MASK_OPAQUE
		}).Hit

		local Closeness = LocalPlayer():GetFOV()*(EyePos():Distance(SelfPos))
		local DetailDraw = Closeness < 120000 -- cutoff point is 400 units when the fov is 90 degrees
		---
		if (not(DetailDraw))and(Obscured) then return end -- if player is far and sentry is obscured, draw nothing
		if Obscured then DetailDraw=false end -- if obscured, at least disable details
		if State == STATE_BROKEN then DetailDraw = false end -- look incomplete to indicate damage, save on gpu comp too
		---
		self:DrawModel()
		---
		if (State == STATE_SMELTING) then
			local GlowPos = BasePos + Up * 60 + Right * 7.5
			local GlowAng = SelfAng:GetCopy()
			GlowAng:RotateAroundAxis(GlowAng:Up(), -90)
			local GlowDir = GlowAng:Forward()
			render.SetMaterial(WhiteSquare)
			for i = 1, 5 do
				render.DrawQuadEasy(GlowPos + GlowDir * (1 + i / 5) * math.Rand(.9, 1), GlowDir, 40, 20, Color( 255, 255, 255, 200 ), GlowAng.r)
			end
			for i = 1, 20 do
				render.DrawQuadEasy(GlowPos + GlowDir * i / 2.5 * math.Rand(.9, 1), GlowDir, 40, 20, Color( 255 - i * 1, 255 - i * 9, 200 - i * 10, 55 - i * 2.5 ), GlowAng.r)
			end
			render.SetMaterial(HeatWaveMat)
			for i = 1, 2 do
				render.DrawSprite(BasePos + Up * (i * math.random(10, 30) + 120) - Right * 8 + Forward * 10, 60, 60, Color(255, 255 - i * 10, 255 - i * 20, 25))
			end
			local light = DynamicLight(self:EntIndex())
			if (light) then
				light.Pos = GlowPos + Right * 7 + Up * 1
				light.r = 255
				light.g = 200
				light.b = 100
				light.Brightness = 4
				light.Decay = 1000
				light.Size = 200 * math.Rand(.9, 1)
				light.DieTime = CurTime() + 0.1
			end
		end
		---
		if DetailDraw then
			local PipeAng = SelfAng:GetCopy()
			PipeAng:RotateAroundAxis(PipeAng:Right(), 0)
			PipeAng:RotateAroundAxis(PipeAng:Up(), 180)
			PipeAng:RotateAroundAxis(PipeAng:Forward(), 0)
			JMod.RenderModel(self.Piping, BasePos - Forward * 27 - Right * 30 + Up * 15, PipeAng, nil, GradeColors[Grade], GradeMats[Grade])

			if Closeness < 20000 and State == STATE_SMELTING then
				local DisplayAng = SelfAng:GetCopy()
				DisplayAng:RotateAroundAxis(DisplayAng:Right(), 0)
				DisplayAng:RotateAroundAxis(DisplayAng:Up(), 0)
				DisplayAng:RotateAroundAxis(DisplayAng:Forward(), 90)
				local Opacity = math.random(50, 150)
				local ProFrac = self:GetProgress() / 100
				local OreFrac = self:GetOre() / self.MaxOre
				local FuelFrac = self:GetFuel() / self.MaxFuel
				local ElecFrac = self:GetElectricity() / self.MaxElectricity
				local R, G, B = JMod.GoodBadColor(ProFrac)
				local OR, OG, OB = JMod.GoodBadColor(OreFrac)
				local FR, FG, FB = JMod.GoodBadColor(FuelFrac)
				local ER, EG, EB = JMod.GoodBadColor(ElecFrac)
				cam.Start3D2D(SelfPos - Forward * 10 + Right * 18 + Up * 56, DisplayAng, .05)
					surface.SetDrawColor(10, 10, 10, Opacity + 50)
					surface.DrawRect(420, 0, 128, 128)
					JMod.StandardRankDisplay(Grade, 485, 65, 118, Opacity + 50)
					draw.SimpleTextOutlined("PROGRESS", "JMod-Display", 0, 0, Color(255, 255, 255, Opacity), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, Opacity))
					draw.SimpleTextOutlined(tostring(math.Round(ProFrac * 100)) .. "%", "JMod-Display", 0, 30, Color(R, G, B, Opacity), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, Opacity))
					draw.SimpleTextOutlined("ORE REMAINING", "JMod-Display", 300, 60, Color(255, 255, 255, Opacity), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, Opacity))
					draw.SimpleTextOutlined(tostring(math.Round(OreFrac * self.MaxOre)), "JMod-Display", 300, 90, Color(OR, OG, OB, Opacity), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, Opacity))
					draw.SimpleTextOutlined("POWER REMAINING", "JMod-Display", 0, 120, Color(255, 255, 255, Opacity), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, Opacity))
					draw.SimpleTextOutlined(tostring(math.Round(ElecFrac * self.MaxElectricity * .5)) .. "%", "JMod-Display", 0, 150, Color(ER, EG, EB, Opacity), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, Opacity))
					draw.SimpleTextOutlined("FUEL REMAINING", "JMod-Display", 0, 60, Color(255, 255, 255, Opacity), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, Opacity))
					draw.SimpleTextOutlined(tostring(math.Round(FuelFrac * self.MaxFuel)) .. "%", "JMod-Display", 0, 90, Color(FR, FG, FB, Opacity), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, Opacity))
					draw.SimpleTextOutlined("ORE TYPE", "JMod-Display", 300, 0, Color(255, 255, 255, Opacity), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, Opacity))
					draw.SimpleTextOutlined(string.upper(self:GetOreType()), "JMod-Display", 300, 30, Color(255, 255, 255, Opacity), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, Opacity))
				cam.End3D2D()
			end
		end
	end
	language.Add("ent_jack_gmod_ezfurnace_gas", "EZ Ore Smelter")
end
