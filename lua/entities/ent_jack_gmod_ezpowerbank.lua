-- AdventureBoots 2024
AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "ent_jack_gmod_ezmachine_base"
ENT.PrintName = "Power Bank"
ENT.Author = "Jackarunda"
ENT.Category = "JMod - Machines"
ENT.Information = ""
ENT.Spawnable = true
ENT.AdminSpawnable = true
--
ENT.JModPreferredCarryAngles = Angle(0, 0, 0)
ENT.JModPowerBank = true
ENT.Model = "models/props_lab/powerbox01a.mdl"
--
ENT.StaticPerfSpecs={ 
	MaxElectricity=1000,
	MaxDurability=100,
	Armor=1
}

if SERVER then
	function ENT:SpawnFunction(ply, tr)
		local SpawnPos = tr.HitPos + tr.HitNormal * 20
		local ent = ents.Create(self.ClassName)
		ent:SetPos(SpawnPos)
		JMod.SetEZowner(ent, ply)
		ent:Spawn()
		ent:Activate()
		return ent
	end

	function ENT:CustomInit()
		self.NextUseTime = 0
		self.Connections = {}
		self.EZupgradable = false
		self.EZcolorable = false
	end

	function ENT:Use(activator)
		if self.NextUseTime > CurTime() then return end
		local State = self:GetState()
		if State == JMod.EZ_STATE_OFF then
			self:TurnOn()
		elseif State == JMod.EZ_STATE_ON then
			self:TurnOff()
		end
	end

	function ENT:TurnOn()
		if self:GetState() ~= JMod.EZ_STATE_OFF then return end
		self:SetState(JMod.EZ_STATE_ON)
		for k, ent in ipairs(ents.FindInSphere(self:GetPos(), 400)) do
			if ent.EZpowerProducer or (ent.EZconsumes and table.HasValue(ent.EZconsumes, JMod.EZ_RESOURCE_TYPES.POWER) and ent.GetState and ent:GetState() ~= JMod.EZ_STATE_BROKEN) then
				self:ConnectEnt(ent)
			end
		end
	end

	function ENT:TurnOff()
		if self:GetState() ~= JMod.EZ_STATE_ON then return end
		self:SetState(JMod.EZ_STATE_OFF)
		for k, v in ipairs(self.Connections) do
			if IsValid(v.Cable) then
				v.Cable:Remove()
			end
			self.Connections[k] = nil
		end
	end

	function ENT:ConnectEnt(ent)
		if not IsValid(ent) or (ent == self) then return end
		local AlreadyConnected = false
		for k, v in ipairs(self.Connections) do
			if v.Ent == ent then
				AlreadyConnected = true

				break
			end
		end
		if AlreadyConnected then return end
		ent.Connections = ent.Connections or {}
		for k, v in pairs(ent.Connections) do
			if (v.Ent == self) then
				if IsValid(v.Cable) then
					v.Cable:Remove()
				end
				self.Connections[k] = nil

				break
			end
		end
		local Cable = constraint.Rope(self, ent, 0, 0, Vector(0, 0, 0), ent.EZpowerPlug or Vector(0, 0, 0), 450, 20, 100, 2, "cable/cable2")
		table.insert(ent.Connections, {Ent = self, Cable = Cable})
		table.insert(self.Connections, {Ent = ent, Cable = Cable})
	end

	function ENT:Think()
		local Time, State = CurTime(), self:GetState()
		self.Connections = self.Connections or {}
		local NumberOfConnected = #self.Connections

		if (State == JMod.EZ_STATE_ON) and (NumberOfConnected > 0) then
			local SelfPower = self:GetElectricity()

			for k, v in ipairs(self.Connections) do
				if SelfPower <= 0 then break end
				local Ent, Cable = v.Ent, v.Cable
				if not IsValid(Ent) or not IsValid(Cable) then
					table.remove(self.Connections, k)
				elseif Ent.JModPowerProducer then
					-- Do naught
				elseif Ent.JModPowerBank then
					local EntPower = Ent:GetElectricity()
					local ChargeDiff = SelfPower - EntPower
					if (ChargeDiff > 0) then
						local PowerTaken = Ent:TryLoadResource(JMod.EZ_RESOURCE_TYPES.POWER, ChargeDiff / 2)
						Ent.NextRefillTime = 0
						self:SetElectricity(SelfPower - PowerTaken)
					end
				elseif table.HasValue(Ent.EZconsumes, JMod.EZ_RESOURCE_TYPES.POWER) then
					local EntPower = Ent:GetElectricity()
					if (Ent.MaxElectricity - EntPower) > 1 then
						local PowerTaken = Ent:TryLoadResource(JMod.EZ_RESOURCE_TYPES.POWER, SelfPower)
						Ent.NextRefillTime = 0
						self:SetElectricity(SelfPower - PowerTaken)
						if (EntPower < 1) and Ent.TurnOn and Ent:GetState() == JMod.EZ_STATE_OFF then
							Ent:TurnOn()
						end
					end
				end
			end
		end

		if self:GetElectricity() > self.MaxElectricity then
			self:ProduceResource()
		end

		self:NextThink(Time + 1)
		return true
	end

	function ENT:ProduceResource()
		local SelfPos, Up, Forward, Right = self:GetPos(), self:GetUp(), self:GetForward(), self:GetRight()
		local amt = math.Clamp(math.floor(self:GetElectricity()), 0, self.MaxElectricity)

		if amt <= 0 then return end
		local pos = self:WorldToLocal(SelfPos + Up * 30 + Forward * 20)
		JMod.MachineSpawnResource(self, JMod.EZ_RESOURCE_TYPES.POWER, amt, pos, Angle(0, 0, 0), Forward * 60, true, 200)
		self:SetElectricity(math.Clamp(self:GetElectricity() - amt, 0, self.MaxElectricity))
	end

elseif CLIENT then
	function ENT:CustomInit()
		self:DrawShadow(true)
	end

	function ENT:Draw()
		local SelfPos, SelfAng, State, FT = self:GetPos(), self:GetAngles(), self:GetState(), FrameTime()
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
			if Closeness < 20000 and State == JMod.EZ_STATE_ON then
				local DisplayAng = SelfAng:GetCopy()
				DisplayAng:RotateAroundAxis(DisplayAng:Right(), -90)
				DisplayAng:RotateAroundAxis(DisplayAng:Up(), 90)
				local Opacity = math.random(50, 150)
				local ElecFrac = self:GetElectricity() / 1000
				local R, G, B = JMod.GoodBadColor(ElecFrac)

				cam.Start3D2D(SelfPos + Forward * 13 + Up * 13, DisplayAng, .08)
				draw.SimpleTextOutlined("POWER", "JMod-Display", 0, 0, Color(255, 255, 255, Opacity), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, Opacity))
				draw.SimpleTextOutlined(tostring(math.Round(ElecFrac * 100)) .. "%", "JMod-Display", 0, 30, Color(R, G, B, Opacity), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, Opacity))
				cam.End3D2D()
			end
		end
	end
end