AddCSLuaFile()
ENT.Type = "anim"
ENT.Author = "Jackarunda"
ENT.PrintName = "EZ Oil Refinery"
ENT.Category = "JMod - EZ Misc."
ENT.Spawnable = true -- Temporary, until the next phase of Econ2
ENT.AdminOnly = false
ENT.Base = "ent_jack_gmod_ezmachine_base"
---
ENT.Model = "models/jmod/machines/oil_refinery.mdl"
ENT.Mass = 2000
ENT.SpawnHeight = 10
ENT.JModPreferredCarryAngles = Angle(0, 0, 0)
---
ENT.EZconsumes = {
	JMod.EZ_RESOURCE_TYPES.OIL,
	JMod.EZ_RESOURCE_TYPES.BASICPARTS,
	JMod.EZ_RESOURCE_TYPES.POWER,
	JMod.EZ_RESOURCE_TYPES.FUEL,
	JMod.EZ_RESOURCE_TYPES.COAL
}
---
ENT.EZupgradable = true
ENT.StaticPerfSpecs = {
	MaxDurability = 100,
	MaxElectricity = 500,
	MaxOil = 500
}
ENT.DynamicPerfSpecs = {
	ProductionSpeed = 1,
	Armor = 1
}
ENT.FlexFuels = { JMod.EZ_RESOURCE_TYPES.COAL, JMod.EZ_RESOURCE_TYPES.FUEL }
---
local STATE_BROKEN, STATE_OFF, STATE_REFINING = -1, 0, 1
---
function ENT:CustomSetupDataTables()
	self:NetworkVar("Float", 1, "Progress")
	self:NetworkVar("Float", 2, "Oil")
end
if(SERVER)then
	function ENT:CustomInit()
		self:SetAngles(Angle(0, 0, 0))
		self:SetProgress(0)
		self:SetOil(0)
		self.LastOilTime = 0
		self.NextEffThink = 0
		self.NextRefineThink = 0
		self.NextEnvThink = 0
		--self:SetSubMaterial(2, "models/props_pipes/pipesystem01a_skin1") -- Pipe on top
		--self:SetSubMaterial(1, "models/props_wasteland/coolingtank02_skin3") -- Distillation tower
	end

	function ENT:TurnOn(activator)
		if ((self:GetElectricity() > 0) and (self:GetOil() > 0)) then
			self:SetState(STATE_REFINING)
			self:EmitSound("snd_jack_littleignite.wav")
			timer.Simple(0.1, function()
				if(self.SoundLoop)then self.SoundLoop:Stop() end
				self.SoundLoop = CreateSound(self, "snds_jack_gmod/intense_fire_loop.wav")
				self.SoundLoop:SetSoundLevel(50)
				self.SoundLoop:Play()
				self:SetProgress(0)
			end)
		else
			JMod.Hint(activator, "nopower_trifuel")
		end
	end

	function ENT:TurnOff()
		self:SetState(STATE_OFF)
		self:ProduceResource()
		if(self.SoundLoop)then self.SoundLoop:Stop() end

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
		elseif State == STATE_OFF then
			self:TurnOn()
		elseif State == STATE_REFINING then
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

	function ENT:ProduceResource()
		local amt = self:GetProgress()
		local SelfPos, Forward, Up, Right = self:GetPos(), self:GetForward(), self:GetUp(), self:GetRight()
		
		if amt <= 0 then return end

		local RefinedTable = JMod.RefiningTable[JMod.EZ_RESOURCE_TYPES.OIL]

		local i = 0
		for typ, modifier in pairs(RefinedTable) do
			local spawnVec = self:WorldToLocal(SelfPos + Forward * 65 + Right * 40 + Up * 30 * i)
			local spawnAng = Angle(0, 0, 0)
			local ejectVec = Forward
			timer.Simple(i / 2, function()
				if IsValid(self) then
					JMod.MachineSpawnResource(self, typ, amt*modifier, spawnVec, spawnAng, ejectVec, true, 200)
				end
			end)
			i = i + 1
		end
		self:SetProgress(0)
		self:EmitSound("snds_jack_gmod/ding.wav", 80, 120)
	end

	function ENT:ResourceLoaded(typ, accepted)
		if typ == JMod.EZ_RESOURCE_TYPES.OIL and accepted >= 1 then
			self:TurnOn(self.Owner)
		end
	end

	function ENT:Think()
		local State, Time = self:GetState(), CurTime()
		if (self.NextRefineThink < Time) then
			self.NextRefineThink = Time + 1
			if State == STATE_REFINING then

				local Grade = self:GetGrade()
				local GradeBuff = JMod.EZ_GRADE_BUFFS[Grade]

				self:ConsumeElectricity(1.5 * JMod.EZ_GRADE_BUFFS[Grade] ^ 1.5)

				if self:GetOil() <= 0 then
					if (Time - self.LastOilTime) >=5 then self:TurnOff() return end
				else
					self.LastOilTime = Time
					local OilConsumeAmt = GradeBuff ^ 1.75
					local ProductProduceAmt = GradeBuff ^ 2
					self:SetOil(self:GetOil() - OilConsumeAmt)
					self:SetProgress(self:GetProgress() + ProductProduceAmt)
					if self:GetProgress() >= 100 then
						self:ProduceResource()
					end
				end
			end
		end
		if (self.NextEffThink < Time) then
			self.NextEffThink = Time + .1
			if (State == STATE_REFINING) then
				local Eff = EffectData()
				Eff:SetOrigin(self:GetPos() + self:GetUp() * 270 + self:GetRight() * 40)
				Eff:SetNormal(self:GetUp())
				Eff:SetScale(.2)
				util.Effect("eff_jack_gmod_ezoilfiresmoke", Eff, true)
			end
		end
		if (self.NextEnvThink < Time) then
			self.NextEnvThink = Time + 5
			local Tr=util.QuickTrace(self:GetPos(), Vector(0, 0, 9e9), self)
			if not (Tr.HitSky) then
				for i = 1, 1 do
					local Gas = ents.Create("ent_jack_gmod_ezgasparticle")
					Gas:SetPos(self:GetPos() + Vector(0, 0, 100))
					JMod.SetOwner(Gas, self.Owner)
					Gas:SetDTBool(0, true)
					Gas:Spawn()
					Gas:Activate()
					Gas:GetPhysicsObject():SetVelocity(VectorRand() * math.random(1, 100))
				end
			end
		end

		self:NextThink(Time + .1)
		return true
	end

elseif(CLIENT)then
	function ENT:CustomInit()
		self.Tank = JMod.MakeModel(self, "models/props_wasteland/horizontalcoolingtank04.mdl")
		self.Monitor = JMod.MakeModel(self, "models/props_lab/monitor01b.mdl")
		self.ControlPanel = JMod.MakeModel(self, "models/props_lab/reciever01a.mdl")
		self.LeverBase = JMod.MakeModel(self, "models/props_wasteland/panel_leverbase001a.mdl")
		self.Lever = JMod.MakeModel(self, "models/props_wasteland/panel_leverhandle001a.mdl")
		self.LeverRot = 0
	end

	function ENT:Draw()
		local SelfPos, SelfAng, State = self:GetPos(), self:GetAngles(), self:GetState()
		local Up, Right, Forward = SelfAng:Up(), SelfAng:Right(), SelfAng:Forward()
		local Grade = self:GetGrade()
		---
		local BasePos = SelfPos

		local Obscured = util.TraceLine({
			start = EyePos(), 
			endpos = BasePos, 
			filter = {LocalPlayer(), self}, 
			mask = MASK_OPAQUE
		}).Hit

		local Closeness = LocalPlayer():GetFOV()*(EyePos():Distance(SelfPos))
		local DetailDraw = Closeness < 400000 -- cutoff point is 4000 units when the fov is 90 degrees
		---
		if (not(DetailDraw))and(Obscured) then return end -- if player is far and sentry is obscured, draw nothing
		--if Obscured then DetailDraw = false end -- if obscured, at least disable details
		if State == STATE_BROKEN then DetailDraw = false end -- look incomplete to indicate damage, save on gpu comp too
		---
		self:DrawModel()
		---
		if DetailDraw then
			local BasePos = SelfPos + Up * 60 + Forward * 35 - Right * 35
			---
			local TankAng = SelfAng:GetCopy()
			TankAng:RotateAroundAxis(Up, -90)
			JMod.RenderModel(self.Tank, SelfPos + Up * 110 - Right * 60, TankAng, Vector(0.4, 0.4, 0.4), nil, JMod.EZ_GRADE_MATS[Grade])
			local ScreenAng = SelfAng:GetCopy()
			--ScreenAng:RotateAroundAxis(Up, 0)
			JMod.RenderModel(self.Monitor, BasePos - Forward * 2, ScreenAng, Vector(2, 2.5, 2.5))
			local KnobsAng = SelfAng:GetCopy()
			--KnobsAng:RotateAroundAxis(Up, 0)
			JMod.RenderModel(self.ControlPanel, BasePos + Forward * 5 - Up * 20, KnobsAng, Vector(1, 1.5, 1.5))
			local PanelAng = SelfAng:GetCopy()
			--PanelAng:RotateAroundAxis(Up, 0)
			JMod.RenderModel(self.LeverBase, BasePos + Forward * 10 - Up * 5 - Right * 50, PanelAng, Vector(1, 1, 1))
			---
			local LeverAng = SelfAng:GetCopy()
			if (State == STATE_REFINING) and (self.LeverRot > -180) then
				self.LeverRot = self.LeverRot - 300 * FrameTime()
			elseif (State ~= STATE_REFINING) and (self.LeverRot < 0) then
				self.LeverRot = self.LeverRot + 400 * FrameTime()
			end
			--self.LeverRot = math.Clamp(self.LeverRot, -181, 1)
			--print(self.LeverRot)
			LeverAng:RotateAroundAxis(Right, self.LeverRot)
			JMod.RenderModel(self.Lever, BasePos + Forward * 10 - Up * 5 - Right * 50, LeverAng, Vector(1, 1, 1))
			---
			
			if Closeness < 20000 and State == STATE_REFINING then
				local DisplayAng = SelfAng:GetCopy()
				DisplayAng:RotateAroundAxis(DisplayAng:Right(), -90)
				DisplayAng:RotateAroundAxis(DisplayAng:Up(), 90)
				DisplayAng:RotateAroundAxis(DisplayAng:Forward(), 0)
				local Opacity = math.random(50, 150)
				local ProFrac = self:GetProgress() / 100
				local ElecFrac = self:GetElectricity() / self.MaxElectricity
				local OilFrac = self:GetOil() / self.MaxOil
				local R, G, B = JMod.GoodBadColor(ProFrac)
				local ER, EG, EB = JMod.GoodBadColor(ElecFrac)
				local OR, OG, OB = JMod.GoodBadColor(OilFrac)
				cam.Start3D2D(SelfPos + Up * 70 + Forward * 46 - Right * 25, DisplayAng, .05)
					surface.SetDrawColor(10, 10, 10, Opacity + 50)
					surface.DrawRect(220, 0, 128, 128)
					JMod.StandardRankDisplay(Grade, 285, 65, 118, Opacity + 50)
					draw.SimpleTextOutlined("PROGRESS", "JMod-Display-L", 70, 0, Color(255, 255, 255, Opacity), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, Opacity))
					draw.SimpleTextOutlined(tostring(math.Round(ProFrac * 100)) .. "%", "JMod-Display-L", 70, 50, Color(R, G, B, Opacity), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, Opacity))
					draw.SimpleTextOutlined("POWER", "JMod-Display-L", 70, 130, Color(255, 255, 255, Opacity), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, Opacity))
					draw.SimpleTextOutlined(tostring(math.Round(ElecFrac * 100)) .. "%", "JMod-Display-L", 70, 180, Color(ER, EG, EB, Opacity), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, Opacity))
					draw.SimpleTextOutlined("OIL", "JMod-Display-L", 70, 260, Color(255, 255, 255, Opacity), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, Opacity))
					draw.SimpleTextOutlined(tostring(math.Round(OilFrac * 100)) .. "%", "JMod-Display-L", 70, 310, Color(OR, OG, OB, Opacity), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, Opacity))
				cam.End3D2D()
			end
		end
	end
	language.Add("ent_jack_gmod_ezrefinery", "EZ Refinery")
end
