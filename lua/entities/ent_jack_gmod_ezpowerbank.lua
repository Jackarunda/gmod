-- AdventureBoots 2024
AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "ent_jack_gmod_ezmachine_base"
ENT.PrintName = "EZ Power Bank"
ENT.Author = "Jackarunda"
ENT.Category = "JMod - EZ Machines"
ENT.Information = ""
ENT.Spawnable = true
ENT.AdminSpawnable = true
--
ENT.JModPreferredCarryAngles = Angle(0, 180, 0)
ENT.EZpowerBank = true
ENT.Model = "models/jmod/machines/ez_powerbank.mdl"
ENT.Mass = 150
ENT.MaxConnectionRange = 1000
ENT.EZupgradable = false
--
ENT.StaticPerfSpecs={ 
	MaxElectricity = 1000,
	MaxDurability = 100,
	Armor = 2.5
}

if SERVER then
	function ENT:SpawnFunction(ply, tr)
		local SpawnPos = tr.HitPos + tr.HitNormal * 20
		local ent = ents.Create(self.ClassName)
		ent:SetPos(SpawnPos)
		JMod.SetEZowner(ent, ply)
		ent:Spawn()
		ent:Activate()
		JMod.Hint(JMod.GetEZowner(ent), "ent_jack_gmod_ezpowerbank")
		return ent
	end

	function ENT:CustomInit()
		self.NextUseTime = 0
		--self.EZconnections = {}
		self.EZcolorable = false
		self.PowerFlow = 0
	end

	function ENT:Use(activator)
		if self.NextUseTime > CurTime() then return end
		local State = self:GetState()
		local IsPly = (IsValid(activator) and activator:IsPlayer())
		local Alt = IsPly and JMod.IsAltUsing(activator)
		JMod.SetEZowner(self, activator)

		if State == JMod.EZ_STATE_BROKEN then
			JMod.Hint(activator, "destroyed", self)
		end
		
		if Alt then
			self:ModConnections(activator)
		else
			if State == JMod.EZ_STATE_OFF then
				self:TurnOn(activator)
			elseif State == JMod.EZ_STATE_ON then
				self:TurnOff(activator)
			end
		end
	end

	function ENT:TurnOn(dude)
		if self:GetState() ~= JMod.EZ_STATE_OFF then return end
		self:SetState(JMod.EZ_STATE_ON)
		if IsValid(dude) then
			self.EZstayOn = true
		end
	end

	function ENT:TurnOff(dude)
		if self:GetState() ~= JMod.EZ_STATE_ON then return end
		self:SetState(JMod.EZ_STATE_OFF)
		if IsValid(dude) then
			self.EZstayOn = nil
		end
	end

	function ENT:DisconnectAll()
		JMod.RemoveResourceConnection(self)
	end

	function ENT:Think()
		local Time, State = CurTime(), self:GetState()
		self.EZconnections = self.EZconnections or {}

		if (State == JMod.EZ_STATE_ON) then
			JMod.DistributePower(self)
		end

		self:NextThink(Time + 1)
		return true
	end

	function ENT:ProduceResource(activator)
		local SelfPos, Up, Forward, Right = self:GetPos(), self:GetUp(), self:GetForward(), self:GetRight()
		local PowerLeft = self:GetElectricity()
		local Amt = math.Clamp(math.floor(PowerLeft), 0, 100)

		if Amt <= 0 then return end
		local SpawnPos = self:WorldToLocal(SelfPos + Up * 16 + Forward * 32)
		self:SetElectricity(PowerLeft - Amt)
		local OldState = self:GetState()
		self:SetState(JMod.EZ_STATE_OFF) -- Hacky
		JMod.MachineSpawnResource(self, JMod.EZ_RESOURCE_TYPES.POWER, Amt, SpawnPos, Angle(0, 0, 0), Forward * 10, false)
		self:SetState(OldState)
	end

	function ENT:OnRemove()
		if IsValid(self.EZconnectorPlug) then SafeRemoveEntity(self.EZconnectorPlug) end
	end
elseif CLIENT then
	function ENT:CustomInit()
		self:DrawShadow(true)
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
		--if((not(DetailDraw)) and (Obscured))then return end -- if player is far and sentry is obscured, draw nothing
		if(Obscured)then DetailDraw = false end -- if obscured, at least disable details
		if(State == STATE_BROKEN)then DetailDraw = false end -- look incomplete to indicate damage, save on gpu comp too
		---
		self:DrawModel()
		---
		if DetailDraw then
			if Closeness < 20000 and State == JMod.EZ_STATE_ON then
				local DisplayAng = SelfAng:GetCopy()
				DisplayAng:RotateAroundAxis(DisplayAng:Right(), -90)
				DisplayAng:RotateAroundAxis(DisplayAng:Up(), 90)
				local Opacity = math.random(50, 150)
				local Elec = self:GetElectricity()
				local R, G, B = JMod.GoodBadColor(Elec / 1000)

				cam.Start3D2D(SelfPos + Forward * 10.5 + Up * 23, DisplayAng, .08)
				draw.SimpleTextOutlined("POWER", "JMod-Display", 0, 0, Color(200, 255, 255, Opacity), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, Opacity))
				draw.SimpleTextOutlined(tostring(math.Round(Elec)) .. "/" .. tostring(math.Round(self.MaxElectricity)), "JMod-Display", 0, 30, Color(R, G, B, Opacity), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, Opacity))
				cam.End3D2D()
			end
		end
		language.Add("ent_jack_gmod_ezpowerbank", "EZ Power Bank")
	end
end