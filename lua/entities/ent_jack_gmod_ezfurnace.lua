AddCSLuaFile()
ENT.Type = "anim"
ENT.Author = "Jackarunda"
ENT.Information = "glhfggwpezpznore"
ENT.PrintName = "EZ Smelting Furnace"
ENT.Category = "JMod - EZ Machines"
ENT.Spawnable = true
ENT.AdminOnly = false
ENT.Base = "ent_jack_gmod_ezmachine_base"
---
ENT.Model = "models/jmod/machines/gas_smelter.mdl"
ENT.Mass = 750
ENT.SpawnHeight = 10
---
ENT.EZconsumes = {
	JMod.EZ_RESOURCE_TYPES.BASICPARTS,
	JMod.EZ_RESOURCE_TYPES.POWER,
	JMod.EZ_RESOURCE_TYPES.FUEL,
	JMod.EZ_RESOURCE_TYPES.COAL,
	JMod.EZ_RESOURCE_TYPES.IRONORE,
	JMod.EZ_RESOURCE_TYPES.LEADORE,
	JMod.EZ_RESOURCE_TYPES.ALUMINUMORE,
	JMod.EZ_RESOURCE_TYPES.COPPERORE,
	JMod.EZ_RESOURCE_TYPES.TUNGSTENORE,
	JMod.EZ_RESOURCE_TYPES.TITANIUMORE,
	JMod.EZ_RESOURCE_TYPES.SILVERORE,
	JMod.EZ_RESOURCE_TYPES.GOLDORE,
	JMod.EZ_RESOURCE_TYPES.URANIUMORE,
	JMod.EZ_RESOURCE_TYPES.PLATINUMORE,
	JMod.EZ_RESOURCE_TYPES.SAND
}
---
ENT.EZupgradable = true
ENT.StaticPerfSpecs = {
	MaxDurability = 100,
	MaxElectricity = 500,
	MaxOre = 500
}
ENT.DynamicPerfSpecs = {
	Armor = 1
}
ENT.FlexFuels = { JMod.EZ_RESOURCE_TYPES.COAL, JMod.EZ_RESOURCE_TYPES.FUEL }
---
local STATE_BROKEN,STATE_OFF,STATE_SMELTING=-1,0,1
---
function ENT:CustomSetupDataTables()
	self:NetworkVar("Float", 2, "Progress")
	self:NetworkVar("Float", 3, "Ore")
	self:NetworkVar("String", 0, "OreType")
end
if(SERVER)then
	function ENT:CustomInit()
		self:SetAngles(Angle(0, 0, 0))
		self:SetProgress(0)
		self:SetOre(0)
		self:SetOreType("generic")
		self.LastOreTime = 0
		self.NextEffThink = 0
		self.NextSmeltThink = 0
		self.NextEnvThink = 0
	end

	function ENT:SetupWire()
		if not(istable(WireLib)) then return end
		self.Inputs = WireLib.CreateInputs(self, {"ToggleState [NORMAL]", "OnOff [NORMAL]"}, {"Toggles the machine on or off with an input > 0", "1 turns on, 0 turns off"})
		---
		local WireOutputs = {"State [NORMAL]", "Grade [NORMAL]", "Progress [NORMAL]", "FlexFuel [NORMAL]", "Ore [NORMAL]", "OreType [STRING]"}
		local WireOutputDesc = {"The state of the machine \n-1 is broken \n0 is off \n1 is on", "The machine grade", "Machine's progress", "Machine's flex fuel left", "Amount of ore left", "The type of ore it's processing"}
		for _, typ in ipairs(self.EZconsumes) do
			if typ == JMod.EZ_RESOURCE_TYPES.BASICPARTS then typ = "Durability" end
			local ResourceName = string.Replace(typ, " ", "")
			local ResourceDesc = "Amount of "..ResourceName.." left"
			--
			local OutResourceName = string.gsub(ResourceName, "^%l", string.upper).." [NORMAL]"
			if not(string.Right(ResourceName, 3) == "ore") and not(table.HasValue(self.FlexFuels, typ)) then
				table.insert(WireOutputs, OutResourceName)
				table.insert(WireOutputDesc, ResourceDesc)
			end
		end
		self.Outputs = WireLib.CreateOutputs(self, WireOutputs, WireOutputDesc)
	end

	function ENT:UpdateWireOutputs()
		if istable(WireLib) then
			WireLib.TriggerOutput(self, "State", self:GetState())
			WireLib.TriggerOutput(self, "Grade", self:GetGrade())
			WireLib.TriggerOutput(self, "Progress", self:GetProgress())
			WireLib.TriggerOutput(self, "Durability", self.Durability)
			WireLib.TriggerOutput(self, "FlexFuel", self:GetElectricity())
			WireLib.TriggerOutput(self, "Ore", self:GetOre())
			WireLib.TriggerOutput(self, "OreType", self:GetOreType())
		end
	end

	function ENT:TurnOn(activator)
		if self:GetState() > STATE_OFF then return end
		if (self:GetElectricity() <= 0) then
			JMod.Hint(activator, "nopower_trifuel")
			return
		end
		if (self:GetOre() <= 0) then
			JMod.Hint(activator, "need ore")
			return
		end
		self:SetState(STATE_SMELTING)
		self:EmitSound("snd_jack_littleignite.wav")
		timer.Simple(0.1, function()
			if(self.SoundLoop)then self.SoundLoop:Stop() end
			self.SoundLoop = CreateSound(self, "snds_jack_gmod/intense_fire_loop.wav")
			self.SoundLoop:SetSoundLevel(50)
			self.SoundLoop:Play()
		end)
	end

	function ENT:TurnOff()
		if (self:GetState() <= 0) then return end
		self:SetState(STATE_OFF)
		self:ProduceResource()
		if(self.SoundLoop)then self.SoundLoop:Stop() end

		self:EmitSound("snd_jack_littleignite.wav")
	end

	function ENT:Use(activator)
		local State = self:GetState()
		local OldOwner = self.EZowner
		local Alt = activator:KeyDown(JMod.Config.General.AltFunctionKey)
		JMod.SetEZowner(self, activator)
		if(IsValid(self.EZowner))then
			if(OldOwner ~= self.EZowner)then -- if owner changed then reset team color
				JMod.Colorify(self)
			end
		end

		if State == STATE_BROKEN then
			JMod.Hint(activator, "destroyed", self)

			return
		elseif State==STATE_OFF then
			self:TurnOn(activator)
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

	function ENT:SpawnEffect(pos)
		self:EmitSound("snds_jack_gmod/ding.wav", 80, 120)
	end

	function ENT:ResourceLoaded(typ, accepted)
		if typ == self:GetOreType() and accepted >= 1 then
			self:TurnOn(self.EZowner)
		end
	end

	function ENT:ProduceResource()
		local SelfPos, Forward, Up, Right, OreType = self:GetPos(), self:GetForward(), self:GetUp(), self:GetRight(), self:GetOreType()
		local amt = math.Clamp(math.floor(self:GetProgress()), 0, 100)
		
		if amt <= 0 or OreType == "generic" then return end

		local RefinedType = JMod.SmeltingTable[OreType][1]

		local spawnVec = self:WorldToLocal(SelfPos + Right * 30 + Up * 20)
		local spawnAng = Angle(0, 0, 0)
		local ejectVec = Forward * 100
		timer.Simple(0.3, function()
			if IsValid(self) then
				JMod.MachineSpawnResource(self, RefinedType, amt, spawnVec, spawnAng, ejectVec, true, 200)
				if (OreType == JMod.EZ_RESOURCE_TYPES.SAND) and (amt >= 75) and math.random(0, 100) then
					JMod.MachineSpawnResource(self, JMod.EZ_RESOURCE_TYPES.DIAMOND, 1, spawnVec + Up * 4, spawnAng, ejectVec, false)
				end
			end
		end)
		self:SetProgress(0)
		self:SpawnEffect(SelfPos)
		if self:GetOre() <= 0 then
			self:SetOreType("generic")
		end
	end

	function ENT:Think()
		local State, Time, OreTyp = self:GetState(), CurTime(), self:GetOreType()

		self:UpdateWireOutputs()

		if (self.NextSmeltThink < Time) then
			self.NextSmeltThink = Time + 1
			if (State == STATE_SMELTING) then
				if not OreTyp then self:TurnOff() return end

				local Grade = self:GetGrade()
				local GradeBuff = JMod.EZ_GRADE_BUFFS[Grade]

				self:ConsumeElectricity(1.5 * JMod.EZ_GRADE_BUFFS[Grade] ^ 1.5)

				if self:GetOre() <= 0 then
					if (Time - self.LastOreTime) >=5 then self:TurnOff() return end
				else
					self.LastOreTime = Time
					local OreConsumeAmt = GradeBuff ^ 2
					local MetalProduceAmt = GradeBuff ^ 2 * JMod.SmeltingTable[OreTyp][2]
					self:SetOre(self:GetOre() - OreConsumeAmt)
					self:SetProgress(self:GetProgress() + MetalProduceAmt)
					if self:GetProgress() >= 100 then
						self:ProduceResource()
					end
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
		if (self.NextEnvThink < Time) and (State == STATE_SMELTING) then
			self.NextEnvThink = Time + 5
			local Tr=util.QuickTrace(self:GetPos(), Vector(0, 0, 9e9), self)
			if not (Tr.HitSky) then
				for i = 1, 1 do
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

		self:NextThink(Time + .1)
		return true
	end

	function ENT:PostEntityPaste(ply, ent, createdEntities)
		local Time = CurTime()
		JMod.SetEZowner(self, ply, true)
		ent.NextRefillTime = Time + math.Rand(0, 3)
		self.LastOreTime = Time + math.Rand(0, 3)
		self.NextEffThink = Time + math.Rand(0, 3)
		self.NextSmeltThink = Time + math.Rand(0, 3)
		self.NextEnvThink = Time + math.Rand(0, 3)
	end

elseif(CLIENT)then
	function ENT:CustomInit()
		self.Piping = JMod.MakeModel(self, "models/props_c17/gasmeter002a.mdl")
		self.Panel = JMod.MakeModel(self, "models/hunter/blocks/cube05x1x025.mdl")
	end
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
			PipeAng:RotateAroundAxis(Forward, 180)
			PipeAng:RotateAroundAxis(Right, 180)
			JMod.RenderModel(self.Piping, BasePos - Forward * 27 - Right * 30 + Up * 15, PipeAng, nil, Vector(1,1,1), JMod.EZ_GRADE_MATS[Grade])

			local PanelAng = SelfAng:GetCopy()
			PanelAng:RotateAroundAxis(Right, 90)
			PanelAng:RotateAroundAxis(Forward, 90)
			JMod.RenderModel(self.Panel, BasePos + Up * 54 + Forward * 22.5 - Right * 2, PanelAng, nil, Vector(1,1,1), JMod.EZ_GRADE_MATS[Grade])

			if Closeness < 20000 and State == STATE_SMELTING then
				local DisplayAng = SelfAng:GetCopy()
				DisplayAng:RotateAroundAxis(DisplayAng:Right(), 0)
				DisplayAng:RotateAroundAxis(DisplayAng:Up(), 0)
				DisplayAng:RotateAroundAxis(DisplayAng:Forward(), 90)
				local Opacity = math.random(50, 150)
				local ProFrac = self:GetProgress() / 100
				local OreFrac = self:GetOre() / self.MaxOre
				local ElecFrac = self:GetElectricity() / self.MaxElectricity
				local R, G, B = JMod.GoodBadColor(ProFrac)
				local OR, OG, OB = JMod.GoodBadColor(OreFrac)
				local ER, EG, EB = JMod.GoodBadColor(ElecFrac)
				cam.Start3D2D(SelfPos - Forward * 10 + Right * 18 + Up * 56, DisplayAng, .05)
					surface.SetDrawColor(10, 10, 10, Opacity + 50)
					surface.DrawRect(420, 0, 128, 128)
					JMod.StandardRankDisplay(Grade, 485, 65, 118, Opacity + 50)
					draw.SimpleTextOutlined("PROGRESS", "JMod-Display", 0, 0, Color(255, 255, 255, Opacity), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, Opacity))
					draw.SimpleTextOutlined(tostring(math.Round(ProFrac * 100)) .. "%", "JMod-Display", 0, 30, Color(R, G, B, Opacity), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, Opacity))
					draw.SimpleTextOutlined("AMT REMAINING", "JMod-Display", 290, 60, Color(255, 255, 255, Opacity), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, Opacity))
					draw.SimpleTextOutlined(tostring(math.Round(OreFrac * self.MaxOre)), "JMod-Display", 290, 90, Color(OR, OG, OB, Opacity), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, Opacity))
					draw.SimpleTextOutlined("POWER", "JMod-Display", 0, 60, Color(255, 255, 255, Opacity), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, Opacity))
					draw.SimpleTextOutlined(tostring(math.Round(ElecFrac * 100)) .. "%", "JMod-Display", 0, 90, Color(ER, EG, EB, Opacity), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, Opacity))
					draw.SimpleTextOutlined("TYPE", "JMod-Display", 290, 0, Color(255, 255, 255, Opacity), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, Opacity))
					draw.SimpleTextOutlined(string.upper(self:GetOreType()), "JMod-Display", 290, 30, Color(228, 215, 101, Opacity), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, Opacity))
				cam.End3D2D()
			end
		end
	end
	language.Add("ent_jack_gmod_ezfurnace_gas", "EZ Smelting Furnace")
end
