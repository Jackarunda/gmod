-- AdventureBoots 2024
AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "ent_jack_gmod_ezmachine_base"
ENT.PrintName = "EZ Winch"
ENT.Author = "Jackarunda"
ENT.Category = "JMod - EZ Machines"
ENT.Information = ""
ENT.Spawnable = true
ENT.AdminSpawnable = true
--
ENT.JModPreferredCarryAngles = Angle(0, 0, 0)
ENT.Model = "models/jmod/ezwinch01.mdl"
ENT.Mass = 25
--
ENT.StaticPerfSpecs={ 
	MaxElectricity = 100,
	MaxDurability = 100,
	Armor = 1.5
}

local STATE_BROKEN, STATE_OFF, STATE_WINDING, STATE_SPEELING = -1, 0, 1, 2
--
if SERVER then
	function ENT:SetupWire()
		if not(istable(WireLib)) then return end
		local WireInputs = {"Speel [NORMAL]", "Ratchet [NORMAL]", "TurnOff [NORMAL]", "Disconnect [NORMAL]"}
		local WireInputDesc = {"Starts letting out chain", "Starts winding the chain", "Turns off", "Disconnects the winch from the machine"}
		self.Inputs = WireLib.CreateInputs(self, WireInputs, WireInputDesc)
		--
		local WireOutputs = {"State [NORMAL]", "Length [NORMAL]"}
		local WireOutputDesc = {"The state of the machine \n-1 is broken \n0 is off \n1 is on \n2 is speeling", "The current cable length"}
		for _, typ in ipairs(self.EZconsumes) do
			if typ == JMod.EZ_RESOURCE_TYPES.BASICPARTS then typ = "Durability" end
			local ResourceName = string.Replace(typ, " ", "")
			local ResourceDesc = "Amount of "..ResourceName.." left"
			--
			local OutResourceName = string.gsub(ResourceName, "^%l", string.upper).." [NORMAL]"
			if not(istable(self.FlexFuels) and table.HasValue(self.FlexFuels, typ)) then
				table.insert(WireOutputs, OutResourceName)
				table.insert(WireOutputDesc, ResourceDesc)
			end
		end
		self.Outputs = WireLib.CreateOutputs(self, WireOutputs, WireOutputDesc)
	end

	function ENT:UpdateWireOutputs()
		if not istable(WireLib) then return end
		WireLib.TriggerOutput(self, "State", self:GetState())
		--WireLib.TriggerOutput(self, "Length", self.CurrentCableLength)
		for _, typ in ipairs(self.EZconsumes) do
			if typ == JMod.EZ_RESOURCE_TYPES.BASICPARTS then
				WireLib.TriggerOutput(self, "Durability", self.Durability)
			else
				local MethodName = JMod.EZ_RESOURCE_TYPE_METHODS[typ]
				if MethodName then
					local ResourceGetMethod = self["Get"..MethodName]
					if ResourceGetMethod then
						local ResourceName = string.Replace(typ, " ", "")
						WireLib.TriggerOutput(self, string.gsub(ResourceName, "^%l", string.upper), ResourceGetMethod(self))
					end
				end
			end
		end
	end

	function ENT:TriggerInput(iname, value)
		local State, Owner = self:GetState(), JMod.GetEZowner(self)
		if State < STATE_OFF then return end
		if iname == "Speel" then
			self:Speel()
		elseif iname == "Ratchet" then
			self:TurnOn()
		elseif iname == "TurnOff" then
			self:TurnOff()
		elseif iname == "Disconnect" then
			if value > 0 then
				if IsValid(self.Hooker) and not(self.Hooker:IsPlayerHolding()) and IsValid(self.Chain) then
					SafeRemoveEntity(self.Hooker)
				end
			end
		end
	end

	function ENT:CustomInit()
		self.NextUseTime = 0
		self.EZconnections = {}
		self.EZupgradable = false
		self.EZcolorable = false
		self.MaxConnectionRange = 1000
		self.CurrentCableLength = 0
		self.SoundLoop = CreateSound(self, "snds_jack_gmod/slow_ratchet.wav")
	end

	function ENT:Ratchet(amt)
		if not(IsValid(self.Chain)) or (self:GetState() < STATE_OFF) then return end
		amt = amt or 5
		if amt < 0 then
			if (self:GetElectricity() <= 0) then self:TurnOff() end
			self:ConsumeElectricity(-amt * 0.05)
		end
		self.CurrentCableLength = math.Clamp(self.CurrentCableLength + amt, 10, self.MaxConnectionRange)
		self.Chain:Fire("SetSpringLength", tostring(self.CurrentCableLength), 0)
		self.VisualRope:Fire("SetLength", self.CurrentCableLength, 0)
		if istable(WireLib) then
			WireLib.TriggerOutput(self, "Length", self.CurrentCableLength)
		end
	end

	function ENT:TurnOn()
		if self:GetState() < STATE_OFF then return end
		self:SetState(STATE_WINDING)
		self:StartSound()
	end

	function ENT:Speel()
		if self:GetState() < STATE_OFF then return end
		if not(IsValid(self.Hooker)) then
			self:CreateHook()
		end
		self:SetState(STATE_SPEELING)
		self:StartSound()
	end

	function ENT:TurnOff()
		if self:GetState() < STATE_WINDING then return end
		self:SetState(STATE_OFF)
		self:EndSound()
	end

	function ENT:StartSound()
		if not self.SoundLoop then
			self.SoundLoop = CreateSound(self, "snds_jack_gmod/slow_ratchet.wav")
		end
		self.SoundLoop:Play()
	end

	function ENT:EndSound()
		if self.SoundLoop then
			self.SoundLoop:Stop()
		end
	end

	function ENT:CreateHook(dude)
		local Hooky = ents.Create("ent_jack_gmod_ezhook")
		Hooky:SetPos(self:GetPos() + Vector(0, 0, 50)) -- Adjust the position as needed
		Hooky:SetAngles(self:GetAngles())
		Hooky.EZconnector = machine
		Hooky.NextStick = CurTime() + 1
		Hooky:Spawn()
		Hooky:Activate()
		self.Hooker = Hooky

		self.CurrentCableLength = 20
		self.Chain, self.VisualRope = constraint.Elastic(self, Hooky, 0, 0, Vector(-7.5,10,3), Vector(0,0,9), 5000, 2, 10, "cable/mat_jack_gmod_chain", 2, true)
		self.VisualRope:SetKeyValue( "Collide", "false")
		Hooky.Chain = self.Chain

		if IsValid(dude) then
			dude:DropObject()
			Hooky:Use(dude, dude, USE_ON, 1)
		end
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

		if State == STATE_OFF then
			if not(IsValid(self.Hooker)) then
				self:CreateHook(activator)
			end

			self:Speel()
			return
		else
			if Alt then
				if IsValid(self.Hooker) and not(self.Hooker:IsPlayerHolding()) and IsValid(self.Chain) then
					SafeRemoveEntity(self.Hooker)
				end
				self:Speel()

				return
			end
			if State == STATE_SPEELING then
				self:TurnOn()
			elseif State == STATE_WINDING then
				self:TurnOff()
			end
		end
	end

	function ENT:Think()
		local Time, State = CurTime(), self:GetState()

		if not IsValid(self.Hooker) or not IsValid(self.Chain) then
			self:TurnOff()
		end

		if (State == STATE_SPEELING) then
			self:Ratchet(5)
		elseif (State == STATE_WINDING) then
			self:Ratchet(-5)
		end

		-- If the current length is less than 10 or greater than the max, turn off the machine
		if (self.CurrentCableLength <= 10) then
			self:TurnOff()
		end

		self:UpdateWireOutputs()

		self:NextThink(Time + .2)
		return true
	end

	function ENT:OnPostEntityPaste(ply, Ent, CreatedEntities)
		self.Hooker = CreatedEntities[self.Hooker:EntIndex()]
		self.SoundLoop = CreateSound(self, "snds_jack_gmod/slow_ratchet.wav")
		timer.Simple(1, function()
			if IsValid(self) and IsValid(self.Hooker) then
				self.Chain = constraint.Find(self, self.Hooker, "Elastic", 0, 0)
				self.Hooker.Chain = self.Chain
			end
		end)
	end

	function ENT:OnRemove()
		if IsValid(self.Hooker) then
			SafeRemoveEntity(self.Hooker)
		end
	end

elseif CLIENT then
	function ENT:CustomInit()
		self:DrawShadow(true)
		self.Wheel = JMod.MakeModel(self, "models/jmod/ezwinch01_wheel.mdl")
		self.WheelTurn = 0
	end

	function ENT:Think()
		if self.ClientOnly then return end
		local Time, State = CurTime(), self:GetState()
		local FT = FrameTime()
		if State == STATE_SPEELING then
			self.WheelTurn = self.WheelTurn + 100 * FT
		elseif State == STATE_WINDING then
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
				local R, G, B = JMod.GoodBadColor(Elec / self.MaxElectricity)

				cam.Start3D2D(SelfPos + Forward * 10.5 + Up * 7, DisplayAng, .08)
				draw.SimpleTextOutlined("POWER", "JMod-Display", 0, 0, Color(200, 255, 255, Opacity), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, Opacity))
				draw.SimpleTextOutlined(tostring(math.Round(Elec)) .. "/" .. tostring(math.Round(self.MaxElectricity)), "JMod-Display", 0, 30, Color(R, G, B, Opacity), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, Opacity))
				cam.End3D2D()
			end
		end
		language.Add("ent_jack_gmod_ezwinch", "EZ Winch")
	end
end