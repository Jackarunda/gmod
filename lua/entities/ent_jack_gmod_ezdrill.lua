-- Jackarunda 2021
AddCSLuaFile()
ENT.Type = "anim"
ENT.Author = "Jackarunda"
ENT.Information = "glhfggwpezpznore"
ENT.PrintName = "EZ Drill"
ENT.Category = "JMod - EZ Misc."
ENT.Spawnable = true
ENT.AdminOnly = false
ENT.Base = "ent_jack_gmod_ezmachine_base"
---
ENT.Model = "models/jmodels/props/machines/drill_support.mdl"
ENT.Mass = 2000
ENT.SpawnHeight = 105
ENT.JModPreferredCarryAngles = Angle(0, 0, 0)
ENT.EZconsumes = {
	JMod.EZ_RESOURCE_TYPES.BASICPARTS,
	JMod.EZ_RESOURCE_TYPES.POWER
}
ENT.EZupgradable = true
ENT.StaticPerfSpecs = {
	MaxDurability = 100,
	MaxElectricity = 100
}
ENT.DynamicPerfSpecs = {
	Armor = 1.2
}
--
--ENT.WhitelistedResources = {}
ENT.BlacklistedResources = {"water", "oil", "geothermal", "geo"}

local STATE_BROKEN, STATE_OFF, STATE_RUNNING = -1, 0, 1
---
function ENT:CustomSetupDataTables()
	self:NetworkVar("Float", 1, "Progress")
	self:NetworkVar("String", 0, "ResourceType")
end
if(SERVER)then
	function ENT:CustomInit()
		self:SetProgress(0)
		self.DepositKey = 0
		timer.Simple(0.1, function()
			self:TryPlace() 
		end)
	end

	function ENT:UpdateDepositKey()
		local SelfPos = self:GetPos() + Vector(0, 0, -100)
		-- first, figure out which deposits we are inside of, if any
		local DepositsInRange = {}

		for k, v in pairs(JMod.NaturalResourceTable)do
			-- Make sure the resource is on the whitelist
			local Dist = SelfPos:Distance(v.pos)

			-- store they desposit's key if we're inside of it
			if (Dist <= v.siz) and (not(table.HasValue(self.BlacklistedResources, v.typ))) then 
				if v.rate or (v.amt < 0) then break end
				table.insert(DepositsInRange, k)
			end
		end

		-- now, among all the deposits we are inside of, let's find the closest one
		local ClosestDeposit, ClosestRange = nil, 9e9

		if #DepositsInRange > 0 then
			for k, v in pairs(DepositsInRange)do
				local DepositInfo = JMod.NaturalResourceTable[v]
				local Dist = SelfPos:Distance(DepositInfo.pos)

				if(Dist < ClosestRange)then
					ClosestDeposit = v
					ClosestRange = Dist
				end
			end
		end
		if(ClosestDeposit)then 
			self.DepositKey = ClosestDeposit 
			self:SetResourceType(JMod.NaturalResourceTable[self.DepositKey].typ)
			--print("Our deposit is "..self.DepositKey) --DEBUG
		else 
			self.DepositKey = nil
			--print("No valid deposit") --DEBUG
		end
	end

	function ENT:TryPlace()
		local Tr = util.QuickTrace(self:GetPos() + Vector(0, 0, 10), Vector(0, 0, -500), self)
		if (Tr.Hit) and (Tr.HitWorld) then
			local Yaw = self:GetAngles().y
			self:SetAngles(Angle(Tr.HitNormal:Angle().x + 90, Yaw, 0))
			self:SetPos(Tr.HitPos + Tr.HitNormal * self.SpawnHeight)
			--
			local GroundIsSolid = true
			for i = 1, 50 do
				local Contents = util.PointContents(Tr.HitPos - Vector(0, 0, 10 * i))
				if(bit.band(util.PointContents(self:GetPos()), CONTENTS_SOLID) == CONTENTS_SOLID)then GroundIsSolid=false break end
			end
			self:UpdateDepositKey()
			if not self.DepositKey then
				--JMod.Hint(self.Owner, "oil derrick")
			elseif(GroundIsSolid)then
				if not(IsValid(self.Weld))then self.Weld = constraint.Weld(self, Tr.Entity, 0, 0, 50000, false, false) end
				if(IsValid(self.Weld) and self.DepositKey)then
					self:TurnOn(self.Owner)
				else
					if self:GetState() > 0 then
						self:TurnOff()
					end
					JMod.Hint(self.Owner, "machine mounting problem")
				end
			end
		end
	end

	function ENT:TurnOn(activator)
		if(self:GetElectricity() > 0)then
			self:SetState(STATE_RUNNING)
			self:SetSequence("active")
			self.SoundLoop = CreateSound(self, "snd_jack_betterdrill1.wav")
			self.SoundLoop:SetSoundLevel(60)
			self.SoundLoop:Play()
			self:SetProgress(0)
		else
			JMod.Hint(activator,"nopower")
		end
	end
	
	function ENT:TurnOff()
		self:SetSequence("idle")
		self:SetState(STATE_OFF)
		self:ProduceResource(self:GetProgress())

		if self.SoundLoop then
			self.SoundLoop:Stop()
		end
	end

	function ENT:Use(activator)
		local State = self:GetState()
		local OldOwner = self.Owner
		local alt = activator:KeyDown(JMod.Config.AltFunctionKey)
		JMod.SetOwner(self,activator)
		if(IsValid(self.Owner))then
			if(OldOwner ~= self.Owner)then -- if owner changed then reset team color
				JMod.Colorify(self)
			end
		end

		if State == STATE_BROKEN then
			JMod.Hint(activator, "destroyed", self)

			return
		elseif State == STATE_OFF then
			self:TryPlace()
		elseif State == STATE_RUNNING then
			if alt then
				self:ProduceResource(self:GetProgress())

				return
			end
			self:TurnOff()
		end
	end
	
	function ENT:OnRemove()
		if(self.SoundLoop)then self.SoundLoop:Stop() end
	end
	
	function ENT:Think()
		local State, Time = self:GetState(), CurTime()
		if State == STATE_BROKEN then
			if self.SoundLoop then self.SoundLoop:Stop() end

			if self:GetElectricity() > 0 then
				if math.random(1,4) == 2 then JMod.DamageSpark(self) end
			end

			return
		elseif State == STATE_RUNNING then
			if not IsValid(self.Weld) then
				self.DepositKey = nil
				--self.WellPos = nil
				--self.Weld = nil
				self:TurnOff()

				return
			end

			if not JMod.NaturalResourceTable[self.DepositKey] then 
				self:TurnOff()

				return
			end

			self:ConsumeElectricity(.2)
			-- This is just the rate at which we drill
			local drillRate = 0.8 * (JMod.EZ_GRADE_BUFFS[self:GetGrade()] ^ 2)
			
			-- Get the amount of resouces left in the ground
			local amtLeft = JMod.NaturalResourceTable[self.DepositKey].amt
			--print("Amount left: "..amtLeft) --DEBUG
			-- If there's nothing left, we shouldn't do anything
			if amtLeft <= 0 then self:TryPlace() return end
			-- While progress is less than 100
			self:SetProgress(self:GetProgress() + drillRate)

			if self:GetProgress() >= 100 then
				local amtToDrill = math.min(JMod.NaturalResourceTable[self.DepositKey].amt, 100)
				self:ProduceResource(amtToDrill)
				JMod.DepleteNaturalResource(self.DepositKey, amtToDrill)
			end

			JMod.EmitAIsound(self:GetPos(), 300, .5, 256)
		end

		self:NextThink(CurTime() + 1)

		return true 
	end
	
	function ENT:ProduceResource()
		local SelfPos, Forward, Up, Right, Typ = self:GetPos(), self:GetForward(), self:GetUp(), self:GetRight(), self:GetResourceType()
		local amt = math.min(self:GetProgress(), 100)

		if amt <= 0 then return end

		local pos = SelfPos
		local spawnVec = self:WorldToLocal(SelfPos - Up * 50 - Right * 50)
		JMod.MachineSpawnResource(self, self:GetResourceType(), amt, spawnVec, Angle(0, 0, -90), Right * 100, true, 200)
		self:SetProgress(self:GetProgress() - amt)
	end

elseif(CLIENT)then

	function ENT:Initialize()
		self.Auger = JMod.MakeModel(self, "models/jmod/jmodels/drill_auger.mdl")
		self.DrillPipe = JMod.MakeModel(self, "models/props_pipes/pipe03_straight01_long.mdl")
		self.DrillPipeEnd = JMod.MakeModel(self, "models/props_pipes/pipe03_connector01.mdl")
		self.DrillMotor = JMod.MakeModel(self, "models/props_wasteland/laundry_basket001.mdl")
		self.PowerBox = JMod.MakeModel(self, "models/props_lab/powerbox01a.mdl")
		self.DrillMat = Material("phoenix_storms/grey_steel")
		self.DrillSpin = 0
		self.CurDepth = 0
	end

	function ENT:Draw()
		self:DrawModel()
		local Up, Right, Forward, Grade, Typ, State = self:GetUp(), self:GetRight(), self:GetForward(), self:GetGrade(), self:GetResourceType(), self:GetState()
		local SelfPos, SelfAng = self:GetPos(), self:GetAngles()
		local BoxPos = SelfPos + Up * 52 + Right * 3 + Forward * -8
		local MotorPos = BoxPos + Up * -45 + Right * -3
		local DrillPos = MotorPos + Up * -(120 + self.CurDepth)
		local PipePos = DrillPos + Up * 150.5 + Right * -8.5
		--
		if self.CurDepth - self:GetProgress() > 1 then
			self.CurDepth = Lerp(math.ease.InOutCubic(FrameTime() * 10), self.CurDepth, self:GetProgress())
		else
			self.CurDepth = Lerp(math.ease.InOutExpo(FrameTime() * 5), self.CurDepth, self:GetProgress())
		end
		--
		local PowerBoxAng = SelfAng:GetCopy()
		PowerBoxAng:RotateAroundAxis(Up, -90)
		JMod.RenderModel(self.PowerBox, BoxPos, PowerBoxAng, Vector(2, 1.8, 1.2), nil, JMod.EZ_GRADE_MATS[Grade])
		local MotorAng = SelfAng:GetCopy()
		MotorAng:RotateAroundAxis(Up, 90)
		JMod.RenderModel(self.DrillMotor, MotorPos, MotorAng, Vector(0.8, 0.8, 0.8), nil, JMod.EZ_GRADE_MATS[Grade])
		--
		if State == STATE_RUNNING then
			self.DrillSpin = self.DrillSpin - FrameTime() * 300
			if self.DrillSpin > 360 then
				self.DrillSpin = 0
			elseif self.DrillSpin < 0 then
				self.DrillSpin = 360
			end
		end
		--

		local Obscured = util.TraceLine({start = EyePos(), endpos = BasePos, filter = {LocalPlayer(), self}, mask = MASK_OPAQUE}).Hit
		local Closeness = LocalPlayer():GetFOV() * (EyePos():Distance(SelfPos))
		local DetailDraw = Closeness < 36000 -- cutoff point is 400 units when the fov is 90 degrees
		local DrillDraw = true
		if ((not(DetailDraw)) and (Obscured)) then return end -- if player is far and sentry is obscured, draw nothing
		if Obscured then DetailDraw = false end -- if obscured, at least disable details
		if State == STATE_BROKEN then DetailDraw = false DrillDraw = false end -- look incomplete to indicate damage, save on gpu comp too

		if DrillDraw then
			MotorAng:RotateAroundAxis(Up, -90)
			MotorAng:RotateAroundAxis(Forward, 90)
			JMod.RenderModel(self.DrillPipe, PipePos, MotorAng, Vector(1, 1, 1), nil, JMod.EZ_GRADE_MATS[Grade])
			local DrillAng = SelfAng:GetCopy()
			DrillAng:RotateAroundAxis(Up, self.DrillSpin)
			JMod.RenderModel(self.Auger, DrillPos, DrillAng, Vector(3, 3, 3.2), nil, self.DrillMat)
			local PipeEndAng = SelfAng:GetCopy()
			PipeEndAng:RotateAroundAxis(Right, 90)
			PipeEndAng:RotateAroundAxis(Up, self.DrillSpin)
			JMod.RenderModel(self.DrillPipeEnd, DrillPos + Up * 101, PipeEndAng, Vector(1, 1, 1), nil, JMod.EZ_GRADE_MATS[Grade])
		end
		
		if DetailDraw then
			if (Closeness < 40000) and (State == STATE_RUNNING) then
				local DisplayAng = SelfAng:GetCopy()
				DisplayAng:RotateAroundAxis(DisplayAng:Right(), 0)
				DisplayAng:RotateAroundAxis(DisplayAng:Up(), 180)
				DisplayAng:RotateAroundAxis(DisplayAng:Forward(), 90)
				local Opacity = math.random(50, 150)
				cam.Start3D2D(SelfPos + Up * 44 - Right * 22 + Forward * 28, DisplayAng, .15)
                    surface.SetDrawColor(10, 10, 10, Opacity + 50)
                    surface.DrawRect(184, -200, 128, 128)
                    JMod.StandardRankDisplay(Grade, 248, -140, 118, Opacity + 50)
                    draw.SimpleTextOutlined("EXTRACTING","JMod-Display",250,-60,Color(255,255,255,Opacity),TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP,3,Color(0,0,0,Opacity))
                    local ExtractCol=Color(100,255,100,Opacity)
                    draw.SimpleTextOutlined(string.upper(Typ) or "N/A","JMod-Display",250,-30,ExtractCol,TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP,3,Color(0,0,0,Opacity))
                    draw.SimpleTextOutlined("POWER","JMod-Display",250,0,Color(255,255,255,Opacity),TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP,3,Color(0,0,0,Opacity))
                    local ElecFrac=self:GetElectricity()/100
                    local R,G,B=JMod.GoodBadColor(ElecFrac)
                    draw.SimpleTextOutlined(tostring(math.Round(ElecFrac*100)).."%","JMod-Display",250,30,Color(R,G,B,Opacity),TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP,3,Color(0,0,0,Opacity))
                    draw.SimpleTextOutlined("PROGRESS","JMod-Display",250,60,Color(255,255,255,Opacity),TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP,3,Color(0,0,0,Opacity))
                    local ProgressFrac = self:GetProgress() / 100
					local PR, PG, PB = JMod.GoodBadColor(ElecFrac)
                    draw.SimpleTextOutlined(tostring(math.Round(ProgressFrac * 100)).."%", "JMod-Display", 250, 90, Color(PR, PG, PB, Opacity), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, Opacity))
                    --local CoolFrac=self:GetCoolant()/100
                    --draw.SimpleTextOutlined("COOLANT","JMod-Display",90,0,Color(255,255,255,Opacity),TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP,3,Color(0,0,0,Opacity))
                    --local R,G,B=JMod.GoodBadColor(CoolFrac)
                    --draw.SimpleTextOutlined(tostring(math.Round(CoolFrac*100)).."%","JMod-Display",90,30,Color(R,G,B,Opacity),TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP,3,Color(0,0,0,Opacity))
				cam.End3D2D()
			end
		end
	end
	language.Add("ent_jack_gmod_ezdrill","EZ Dill")
end