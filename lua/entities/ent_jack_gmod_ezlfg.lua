-- AdventureBoots Late 2021
AddCSLuaFile()
ENT.Type = "anim"
ENT.PrintName = "EZ Liquid Fuel Generator"
ENT.Author = "Jackarunda, AdventureBoots"
ENT.Category = "JMod - EZ Misc."
ENT.Information = ""
ENT.Spawnable = true
ENT.Base = "ent_jack_gmod_ezmachine_base"
ENT.Model = "models/jmodels/props/machines/diesel_jenerator.mdl"
--ENT.Mat = "models/jmodels/props/machines/lfg"
--
ENT.JModPreferredCarryAngles = Angle(0, 0, 0)
ENT.Mass = 250
ENT.SpawnHeight = 10
--
ENT.StaticPerfSpecs = {
	MaxDurability = 100,
	MaxElectricity = 0,
	MaxFuel = 100
}

ENT.DynamicPerfSpecs = {
	ChargeSpeed = 1,
	Armor = 1
}
ENT.EZconsumes = {
	JMod.EZ_RESOURCE_TYPES.BASICPARTS,
	JMod.EZ_RESOURCE_TYPES.FUEL
}

function ENT:CustomSetupDataTables()
	self:NetworkVar("Float", 1, "Progress")
	self:NetworkVar("Float", 2, "Fuel")
end

local STATE_BROKEN, STATE_OFF, STATE_ON = -1, 0, 1

if(SERVER)then
	function ENT:CustomInit()
		self.EZupgradable = true
		self:SetProgress(0)
		self.NextResourceThink = 0
		self.NextUseTime = 0
		self.SoundLoop = CreateSound(self, "snd_jack_genrun_loop2.wav")
		--self.SoundLoop = CreateSound(self, "vehicles/v8/v8_firstgear_rev_loop1.wav")
	end

	function ENT:Use(activator)
		if self.NextUseTime > CurTime() then
			self:EmitSound("buttons/button2.wav", 60, 100)

			return
		end
		local State = self:GetState()
		local OldOwner = JMod.GetOwner(self)
		local alt = activator:KeyDown(JMod.Config.AltFunctionKey)
		JMod.SetOwner(self, activator)
		JMod.Colorify(self)

		if State == STATE_BROKEN then
			JMod.Hint(activator, "destroyed", self)
		return
		elseif State == STATE_OFF then
			self:TurnOn()
		elseif State == STATE_ON then
			if alt then
				self:ProduceResource()
				return
			end
			self:TurnOff()
		end
	end

	function ENT:TurnOn()
		if (self:GetState() == STATE_OFF) and (self:GetFuel() > 0) then
			self.NextUseTime = CurTime() + 8
			self:EmitSound("snd_jack_genstart.mp3")
			self:SetState(STATE_ON)
			timer.Simple(8, function()
				if IsValid(self) then
					self.SoundLoop:SetSoundLevel(70)
					self.SoundLoop:Play()
				end
			end)
		else
			self:EmitSound("buttons/button2.wav", 60, 100)
		end
	end

	function ENT:TurnOff()
		self.NextUseTime = CurTime() + 8
		if self.SoundLoop then
			self.SoundLoop:Stop()
		end
		self:EmitSound("snd_jack_genstop.mp3")
		self:ProduceResource()
		self:SetState(STATE_OFF)
	end

	function ENT:ResourceLoaded(typ, accepted)
		if typ == JMod.EZ_RESOURCE_TYPES.FUEL then
			timer.Simple(0.1, function() 
				if IsValid(self) then
					self:TurnOn() 
				end 
			end)
		end
	end

	function ENT:OnRemove()
		if self.SoundLoop then
			self.SoundLoop:Stop()
		end
	end

	function ENT:SpawnEffect(pos)
		local effectdata = EffectData()
		effectdata:SetOrigin(pos)
		effectdata:SetNormal((VectorRand() + Vector(0, 0, 1)):GetNormalized())
		effectdata:SetMagnitude(math.Rand(5, 10))
		effectdata:SetScale(math.Rand(.5, 1.5))
		effectdata:SetRadius(math.Rand(2, 4))
		util.Effect("Sparks", effectdata)
		self:EmitSound("items/suitchargeok1.wav", 75, 120)
	end

	function ENT:ProduceResource()
		local SelfPos, Up, Forward, Right = self:GetPos(), self:GetUp(), self:GetForward(), self:GetRight()
		local amt = math.min(math.floor(self:GetProgress()), 100)

		if amt <= 0 then return end

		local pos = self:WorldToLocal(SelfPos + Up * -5 + Forward * 60)
		JMod.MachineSpawnResource(self, JMod.EZ_RESOURCE_TYPES.POWER, amt, pos, Angle(0, 0, 0), Forward * 100, true, 200)
		self:SetProgress(math.Clamp(self:GetProgress() - amt, 0, 100))
		self:SpawnEffect(pos)
	end

	function ENT:ConsumeFuel(amt)
		if not(self.GetFuel)then return end
		amt = (amt or .2)/(self.FuelEffeciancy or 1)
		local NewAmt = math.Clamp(self:GetFuel() - amt, 0.0, self.MaxFuel)
		self:SetFuel(NewAmt)
		if(NewAmt <= 0) and (self:GetState() > 0)then self:TurnOff() end
	end

	function ENT:Think()
		local Time, State, Grade = CurTime(), self:GetState(), self:GetGrade()

		if State == STATE_ON then
			if self.NextResourceThink < Time then
				self.NextResourceThink = Time + 1

				self:ConsumeFuel(.2)

				local Rate = 1 * (JMod.EZ_GRADE_BUFFS[self:GetGrade()] ^ 2)

				self:SetProgress(self:GetProgress() + Rate)

				if self:GetProgress() >= 100 then
					self:ProduceResource()
				end
			end
		end
	end

elseif(CLIENT)then
	function ENT:CustomInit()
		self:DrawShadow(true)
	end

	local GradeColors = JMod.EZ_GRADE_COLORS
	local GradeMats = JMod.EZ_GRADE_MATS

	function ENT:Draw()
		local SelfPos, SelfAng, State = self:GetPos(), self:GetAngles(), self:GetState()
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

		if DetailDraw then
			if Closeness < 20000 and State == STATE_ON then
				local DisplayAng = SelfAng:GetCopy()
				DisplayAng:RotateAroundAxis(DisplayAng:Right(), 0)
				DisplayAng:RotateAroundAxis(DisplayAng:Up(), 0)
				DisplayAng:RotateAroundAxis(DisplayAng:Forward(), 90)
				local Opacity = math.random(50, 150)
				local ProgFrac = self:GetProgress() / 100
				local FuelFrac = self:GetFuel() / self.MaxFuel
				local R, G, B = JMod.GoodBadColor(ProgFrac)
				local FR, FG, FB = JMod.GoodBadColor(FuelFrac)

				cam.Start3D2D(SelfPos + Forward * 10 + Right * 25 + Up * 15, DisplayAng, .1)
				surface.SetDrawColor(10, 10, 10, Opacity + 50)
				local RankX, RankY = 60, 50
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
