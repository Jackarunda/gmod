-- AdventureBoots 2024
AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "ent_jack_gmod_ezmachine_base"
ENT.PrintName = "EZ Winch"
ENT.Author = "Jackarunda"
ENT.Category = "JMod - EZ Machines"
ENT.Information = ""
ENT.Spawnable = true -- For now...
ENT.AdminSpawnable = true
--
ENT.JModPreferredCarryAngles = Angle(0, 0, 0)
ENT.Model = "models/jmod/ezwinch01.mdl"
ENT.Mass = 50
ENT.MaxConnectionRange = 1000
--
ENT.StaticPerfSpecs={ 
	MaxElectricity = 100,
	MaxDurability = 100,
	Armor = 1.5
}

local STATE_BROKEN, STATE_OFF, STATE_WINDING, STATE_SPEELING = -1, 0, 1, 2
--
if SERVER then
	function ENT:SpawnFunction(ply, tr)
		local SpawnPos = tr.HitPos + tr.HitNormal * 20
		local ent = ents.Create(self.ClassName)
		ent:SetPos(SpawnPos)
		JMod.SetEZowner(ent, ply)
		ent:Spawn()
		ent:Activate()
		JMod.Hint(JMod.GetEZowner(ent), "ent_jack_gmod_ezwinch")
		return ent
	end

	function ENT:CustomInit()
		self.NextUseTime = 0
		self.EZconnections = {}
		self.EZupgradable = false
		self.EZcolorable = false
		self.CurrentCableLength = 0
	end

	function ENT:Use(activator)
		if self.NextUseTime > CurTime() then return end
		self.NextUseTime = CurTime() + .5
		local State = self:GetState()
		local IsPly = (IsValid(activator) and activator:IsPlayer())
		local Alt = IsPly and activator:KeyDown(JMod.Config.General.AltFunctionKey)
		JMod.SetEZowner(self, activator)

		if State == JMod.EZ_STATE_BROKEN then
			JMod.Hint(activator, "destroyed", self)

			return
		end
		
		if Alt then
			if IsValid(self.EZhooky) then 
				if self.EZhooky:IsPlayerHolding() then return end
				SafeRemoveEntity(self.EZhooky)
			else
				local Hooky = ents.Create("ent_jack_gmod_ezhook")
				if not IsValid(Hooky) then return end
				Hooky:SetPos(self:GetPos() + Vector(0, 0, 50)) -- Adjust the position as needed
				Hooky:SetAngles(self:GetAngles())
				Hooky.EZconnector = machine
				Hooky.NextStick = CurTime() + 1
				Hooky:Spawn()
				Hooky:Activate()
				self.EZhooky = Hooky

				self.CurrentCableLength = self.MaxConnectionRange
				self.EZrope = constraint.Elastic(self, Hooky, 0, 0, Vector(-7.5,10,3), Vector(0,0,9), 5000, 2, 10, "cable/cable2", 2, true)
				Hooky.EZrope = self.EZrope

				activator:DropObject()
				Hooky:Use(activator, activator, USE_TOGGLE, 1)
			end
		elseif IsValid(self.EZhooky) and not(self.EZhooky:IsPlayerHolding()) and IsValid(self.EZrope) then
			if State == STATE_OFF then
				self:SetState(STATE_WINDING)
			elseif State == STATE_WINDING then
				self:SetState(STATE_SPEELING)
			elseif State == STATE_SPEELING then
				self:SetState(STATE_OFF)
			end
		end
	end

	function ENT:Think()
		local Time, State = CurTime(), self:GetState()

		if not IsValid(self.EZhooky) or not IsValid(self.EZrope) then
			self:SetState(STATE_OFF)
		end

		if (State == STATE_WINDING) then
			self.CurrentCableLength = math.Clamp(self.CurrentCableLength + 25, 10, self.MaxConnectionRange)
			self.EZrope:Fire("SetSpringLength", tostring(self.CurrentCableLength), 0)
		elseif (State == STATE_SPEELING) then
			self.CurrentCableLength = math.Clamp(self.CurrentCableLength - 25, 10, self.MaxConnectionRange)
			self.EZrope:Fire("SetSpringLength", tostring(self.CurrentCableLength), 0)
		end

		self:NextThink(Time + .5)
		return true
	end

	function ENT:OnRemove()
		if IsValid(self.EZhooky) then
			SafeRemoveEntity(self.EZhooky)
		end
	end

elseif CLIENT then
	function ENT:CustomInit()
		self:DrawShadow(true)
		self.Wheel = JMod.MakeModel(self, "models/jmod/ezwinch01_wheel.mdl")
		self.WheelTurn = 0
	end

	function ENT:Think()
		local Time, State = CurTime(), self:GetState()
		local FT = FrameTime()
		if State == STATE_WINDING then
			self.WheelTurn = self.WheelTurn + 100 * FT
		elseif State == STATE_SPEELING then
			self.WheelTurn = self.WheelTurn - 100 * FT
		end
		if self.WheelTurn > 360 then
			self.WheelTurn = self.WheelTurn - 360
		end
	end

	function ENT:Draw()
		local SelfPos, SelfAng, State = self:GetPos(), self:GetAngles(), self:GetState()
		local Up, Right, Forward = SelfAng:Up(), SelfAng:Right(), SelfAng:Forward()
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
			local WheelAng = SelfAng:GetCopy()
			WheelAng:RotateAroundAxis(WheelAng:Forward(), self.WheelTurn)
			JMod.RenderModel(self.Wheel, BasePos - Right * 11.25 - Forward * 7.5 - Up * 2, WheelAng, Vector(1, 1, 1))
			if Closeness < 20000 and State > JMod.EZ_STATE_OFF then
				local DisplayAng = SelfAng:GetCopy()
				DisplayAng:RotateAroundAxis(DisplayAng:Right(), -90)
				DisplayAng:RotateAroundAxis(DisplayAng:Up(), 90)
				local Opacity = math.random(50, 150)
				local Elec = self:GetElectricity()
				local R, G, B = JMod.GoodBadColor(Elec / 1000)

				cam.Start3D2D(SelfPos + Forward * 10.5 + Up * 7, DisplayAng, .08)
				draw.SimpleTextOutlined("POWER", "JMod-Display", 0, 0, Color(200, 255, 255, Opacity), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, Opacity))
				draw.SimpleTextOutlined(tostring(math.Round(Elec)) .. "/" .. tostring(math.Round(self.MaxElectricity)), "JMod-Display", 0, 30, Color(R, G, B, Opacity), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, Opacity))
				cam.End3D2D()
			end
		end
		language.Add("ent_jack_gmod_ezwinch", "EZ Winch")
	end
end