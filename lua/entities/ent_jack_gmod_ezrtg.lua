-- AdventureBoots Late 2021
AddCSLuaFile()
ENT.Type = "anim"
ENT.PrintName = "EZ Radioisotope Thermoelectric Generator"
ENT.Author = "Jackarunda, AdventureBoots"
ENT.Category = "JMod - EZ Machines"
ENT.Information = ""
ENT.Spawnable = true
ENT.Base = "ent_jack_gmod_ezmachine_base"
ENT.Model = "models/radioisotope-powergenerator/radioisotope-powergenerator.mdl"
--
ENT.EZupgradable = true
ENT.EZcolorable = false
--
ENT.JModPreferredCarryAngles = Angle(0, -90, 0)
ENT.Mass = 250
ENT.SpawnHeight = 1
--
ENT.StaticPerfSpecs = {
	MaxDurability = 100
}

ENT.DynamicPerfSpecs = {
	Armor = 1
}
ENT.EZconsumes = {
	JMod.EZ_RESOURCE_TYPES.BASICPARTS
}

function ENT:CustomSetupDataTables()
	self:NetworkVar("Float", 1, "Progress")
end

local STATE_BROKEN, STATE_OFF, STATE_ON = -1, 0, 1

if(SERVER)then
	function ENT:CustomInit()
		self:SetProgress(0)
		self.NextResourceThink = 0
		self.NextUseTime = 0
		self.TimerName = ""
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
				timer.Start(self.TimerName)
				return
			end
			self:TurnOff()
		end
	end

	function ENT:TurnOn(activator)
		if (self:GetState() ~= STATE_OFF) then JMod.Hint(activator, "destroyed", self) return end
		self:EmitSound("buttons/button1.wav", 60, 80)
		self.NextUseTime = CurTime() + 1
		self:SetState(STATE_ON)
		self.TimerName = ("RTGautoShutOff" .. tostring(self:EntIndex()))
		timer.Create(self.TimerName, 1200, 1, function() 
			if IsValid(self) then self:TurnOff() end 
		end)
		timer.Start(self.TimerName)
	end

	function ENT:TurnOff()
		if (self:GetState() <= 0) then return end
		self.NextUseTime = CurTime() + 1
		self:EmitSound("buttons/button18.wav", 60, 80)
		self:ProduceResource()
		self:SetState(STATE_OFF)
		timer.Remove("RTGautoShutOff" .. self.TimerName)
	end

	function ENT:ProduceResource()
		local SelfPos, Up, Forward, Right = self:GetPos(), self:GetUp(), self:GetForward(), self:GetRight()
		local amt = math.Clamp(math.floor(self:GetProgress()), 0, 100)

		if amt <= 0 then return end

		local pos = self:WorldToLocal(SelfPos + Up * 30 + Right * 60)
		JMod.MachineSpawnResource(self, JMod.EZ_RESOURCE_TYPES.POWER, amt, pos, Angle(0, -90, 0), Forward * 60, true, 200)
		self:SetProgress(math.Clamp(self:GetProgress() - amt, 0, 100))
		self:EmitSound("items/suitchargeok1.wav", 80, 120)
	end

	function ENT:Think()
		local Time, State, Grade = CurTime(), self:GetState(), self:GetGrade()

		self:UpdateWireOutputs()

		if self.NextResourceThink < Time then
			self.NextResourceThink = Time + 1
			if State == STATE_ON then
				local PowerPerMin = 10
				local PowerToProduce = (PowerPerMin/60) * JMod.EZ_GRADE_BUFFS[Grade]

				self:SetProgress(self:GetProgress() + PowerToProduce)

				if self:GetProgress() >= 100 then self:ProduceResource() end
			end
		end
	end

	function ENT:PostEntityPaste(ply, ent, createdEntities)
		local Time = CurTime()
		JMod.SetEZowner(self, ply, true)
		ent.NextRefillTime = Time + math.Rand(0, 1)
		self.NextResourceThink = Time + math.Rand(0, 3)
		self.NextUseTime = Time + math.Rand(0, 3)
	end

elseif(CLIENT)then
	function ENT:CustomInit()
		self:DrawShadow(true)
		self.Cylinder = JMod.MakeModel(self, "models/hunter/tubes/tube2x2x05.mdl")
	end

	local GlowSprite = Material("sprites/mat_jack_basicglow")

	function ENT:Draw()
		local SelfPos, SelfAng, State, FT = self:GetPos(), self:GetAngles(), self:GetState(), FrameTime()
		local Up, Right, Forward = SelfAng:Up(), SelfAng:Right(), SelfAng:Forward()
		local Grade = self:GetGrade()
		---
		local BasePos = SelfPos + Up * 30
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
		local CylinderAng = SelfAng:GetCopy()
		CylinderAng:RotateAroundAxis(Right, 0)
		JMod.RenderModel(self.Cylinder, BasePos + Up * 18.5, CylinderAng, Vector(0.25, 0.25, 1), nil, JMod.EZ_GRADE_MATS[Grade])
		
		if DetailDraw then
			if (Closeness < 20000) and (State == STATE_ON) then
				local DisplayAng = SelfAng:GetCopy()
				DisplayAng:RotateAroundAxis(DisplayAng:Right(), 0)
				DisplayAng:RotateAroundAxis(DisplayAng:Up(), 0)
				DisplayAng:RotateAroundAxis(DisplayAng:Forward(), 90)
				local Opacity = math.random(50, 150)
				local ProgFrac = self:GetProgress() / 100
				local R, G, B = JMod.GoodBadColor(ProgFrac)

				cam.Start3D2D(SelfPos + Forward * 5 + Right * 35 + Up * 20, DisplayAng, .06)
				surface.SetDrawColor(10, 10, 10, Opacity + 50)
				local RankX, RankY = -65, 70
				surface.DrawRect(RankX, RankY, 128, 128)
				JMod.StandardRankDisplay(Grade, RankX + 62, RankY + 68, 118, Opacity + 50)
				draw.SimpleTextOutlined("PROGRESS", "JMod-Display", 0, 0, Color(255, 255, 255, Opacity), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, Opacity))
				draw.SimpleTextOutlined(tostring(math.Round(ProgFrac * 100)) .. "%", "JMod-Display", 0, 30, Color(R, G, B, Opacity), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, Opacity))
				cam.End3D2D()
			end
			if State == STATE_ON then
				render.SetMaterial(GlowSprite)
				render.DrawSprite(SelfPos + Forward * -8.5 + Right * 33 + Up * 24, 20, 20, Color(255, 0, 0))
				render.DrawSprite(SelfPos + Forward * -8.5 + Right * 33 + Up * 24, 15, 15, Color(255, 0, 0))
			end
		end
	end
	language.Add("ent_jack_gmod_ezrps", "EZ Radioisotope Thermoelectric Generator")
end
