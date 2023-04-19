AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "EZ Geothermal Generator"
ENT.Author = "Jackarunda, AdventureBoots"
ENT.Category = "JMod - EZ Machines"
ENT.Information = ""
ENT.Spawnable = false --Until it's completed
ENT.Base = "ent_jack_gmod_ezmachine_base"
ENT.Model = "models/jmod/machines/geothermal.mdl"
--
ENT.JModPreferredCarryAngles = Angle(0, 0, 0)
ENT.SpawnHeight = 52
--
ENT.StaticPerfSpecs = {
	MaxDurability = 200,
	MaxElectricity = 0,
	MaxWater = 500
}
--
ENT.DynamicPerfSpecs = {
	Armor = 1,
	ChargeSpeed = 1
}
--
ENT.EZconsumes = {
	JMod.EZ_RESOURCE_TYPES.WATER
}

function ENT:CustomSetupDataTables()
	self:NetworkVar("Float", 1, "Progress")
	self:NetworkVar("Float", 2, "Pressure")
	self:NetworkVar("Int", 2,"Water")
end

local STATE_BROKEN, STATE_OFF,  STATE_ON = -1, 0, 1

if(SERVER)then
	function ENT:SpawnFunction(ply,tr,ClassName)
		local ent = ents.Create(ClassName)
		ent:SetPos(tr.HitPos + tr.HitNormal*ent.SpawnHeight)
		ent:SetAngles(Angle(0, 0, 0))
		JMod.SetEZowner(ent,ply)
		ent:Spawn()
		ent:Activate()
		JMod.Hint(ply, ClassName)
		return ent
	end

	function ENT:CustomInit()
		self.EZupgradable = true
		self:TurnOn()
		self:SetProgress(0)
		self.NextUse = 0
		self.NextResourceThinkTime = 0
	end

	function ENT:UpdateDepositKey()
		local SelfPos = self:GetPos()
		-- first, figure out which deposits we are inside of, if any
		local DepositsInRange = {}

		for k, v in pairs(JMod.NaturalResourceTable) do
			-- Make sure the resource is on the whitelist
			local Dist = SelfPos:Distance(v.pos)

			-- store they desposit's key if we're inside of it
			if (Dist <= v.siz) and v.typ == "geothermal" then
				if not v.rate and (v.amt < 0) then break end
				table.insert(DepositsInRange, k)
			end
		end

		-- now, among all the deposits we are inside of, let's find the closest one
		local ClosestDeposit, ClosestRange = nil, 9e9

		if #DepositsInRange > 0 then
			for k, v in pairs(DepositsInRange) do
				local DepositInfo = JMod.NaturalResourceTable[v]
				local Dist = SelfPos:Distance(DepositInfo.pos)

				if Dist < ClosestRange then
					ClosestDeposit = v
					ClosestRange = Dist
				end
			end
		end

		if ClosestDeposit then
			self.DepositKey = ClosestDeposit
		else
			self.DepositKey = nil
		end
	end

	function ENT:TryPlace()
		local Tr = util.QuickTrace(self:GetPos() + Vector(0, 0, 100), Vector(0, 0, -500), self)
		if (Tr.Hit) and (Tr.HitWorld) then
			local Pitch = Tr.HitNormal:Angle().x + 90
			local Yaw = self:GetAngles().y
			if Tr.HitNormal:Angle().y >= 20 then
				Yaw = Tr.HitNormal:Angle().y
			end
			local Roll = Tr.HitNormal:Angle().z - 90
			self:SetAngles(Angle(0, 0, 0))
			self:SetPos(Tr.HitPos + Tr.HitNormal * self.SpawnHeight)
			--
			local GroundIsSolid = true
			for i = 1, 50 do
				local Contents = util.PointContents(Tr.HitPos - Vector(0, 0, 10 * i))
				if(bit.band(util.PointContents(self:GetPos()), CONTENTS_SOLID) == CONTENTS_SOLID)then GroundIsSolid = false break end
			end
			self:UpdateDepositKey()
			if not(self.DepositKey)then
				--JMod.Hint(self.EZowner, "oil derrick")
			elseif(GroundIsSolid)then
				if not(IsValid(self.Weld))then self.Weld = constraint.Weld(self, Tr.Entity, 0, 0, 100000, false, false) end
				if(IsValid(self.Weld) and self.DepositKey)then
					self:TurnOn(self.EZowner)
				else
					if self:GetState() > 0 then
						self:TurnOff()
					end
					--JMod.Hint(self.EZowner, "machine mounting problem")
				end
			end
		end
	end

	function ENT:Use(activator)
		if self.NextUse > CurTime() then return end
		local State=self:GetState()
		local OldOwner=self.EZowner
		local alt = activator:KeyDown(JMod.Config.General.AltFunctionKey)
		JMod.SetEZowner(self,activator)
		JMod.Colorify(self)
		if(IsValid(self.EZowner) and (OldOwner ~= self.EZowner))then
			JMod.Colorify(self)
		end
		if(State==STATE_BROKEN)then
			JMod.Hint(activator,"destroyed",self)
		return
		elseif(State==STATE_OFF)then
			self:TurnOn()
		elseif(State==STATE_ON)then
			if(alt)then
				self:ProduceResource()
				return
			end
			self:TurnOff()
		end
	end

	function ENT:ProduceResource()
		local SelfPos, Up, Forward, Right = self:GetPos(), self:GetUp(), self:GetForward(), self:GetRight()
		local amt = math.Clamp(math.floor(self:GetProgress()), 0, 100)

		if amt <= 0 then return end

		local pos = SelfPos + Up*100
		JMod.MachineSpawnResource(self, JMod.EZ_RESOURCE_TYPES.POWER, amt, self:WorldToLocal(pos), Angle(-90, 0, 0), Up*-300, true, 200)
		self:SetProgress(math.Clamp(self:GetProgress() - amt, 0, 100))
		self:EmitSound("items/suitchargeok1.wav", 80, 120)
	end

	function ENT:TurnOn()
		if (self:GetState() ~= STATE_OFF) then return end
		self:SetState(STATE_ON)
		self:TryPlace()
	end

	function ENT:TurnOff()
		if (self:GetState() <= STATE_OFF) then return end
		self:ProduceResource()
		self:SetState(STATE_OFF)
	end

	function ENT:Think()
		local State, Time = self:GetState(), CurTime()
		
		if (self.NextResourceThinkTime < Time) then
			self.NextResourceThinkTime = Time + 1
			if State == STATE_BROKEN then
				if self.SoundLoop then self.SoundLoop:Stop() end

				return
			elseif State == STATE_RUNNING then
				if not IsValid(self.Weld) then
					self.DepositKey = nil
					self.WellPos = nil
					self:TurnOff()

					return
				end

				if not JMod.NaturalResourceTable[self.DepositKey] then 
					self:TurnOff()
					return
				end

				local Pressure = self:GetWater() / self.MaxWater
				local flowRate = JMod.NaturalResourceTable[self.DepositKey].rate
				self:SetProgress(self:GetProgress() + self.ChargeSpeed * flowRate * Pressure)

				-- If the progress exceeds 100
				if self:GetProgress() >= 100 then
					-- Spawn barrel
					local amtToPump = math.min(self:GetProgress(), 100)
					self:ProduceResource()
				end

				JMod.EmitAIsound(self:GetPos(), 300, .5, 256)
			end
		end
	end

	function ENT:PostEntityPaste(ply, ent, createdEntities)
		local Time = CurTime()
		JMod.SetEZowner(self, ply)
		ent.NextRefillTime = Time + math.Rand(0, 3)
		ent.NextUse = Time + math.Rand(0, 3)
		ent.NexResourceThinkTime = Time + math.Rand(0, 3)
	end

elseif CLIENT then
	function ENT:CustomInit()
		self:DrawShadow(true)
	end
	
	function ENT:Draw()
		local SelfPos,SelfAng,State=self:GetPos(),self:GetAngles(),self:GetState()
		local Up,Right,Forward=SelfAng:Up(),SelfAng:Right(),SelfAng:Forward()
		local Grade = self:GetGrade()
		---
		local BasePos=SelfPos
		local Obscured=util.TraceLine({start=EyePos(),endpos=BasePos,filter={LocalPlayer(),self},mask=MASK_OPAQUE}).Hit
		local Closeness=LocalPlayer():GetFOV()*(EyePos():Distance(SelfPos))
		local DetailDraw=Closeness<120000 -- cutoff point is 400 units when the fov is 90 degrees
		local PanelDraw = true
		---
		if((not(DetailDraw))and(Obscured))then return end -- if player is far and sentry is obscured, draw nothing
		if(Obscured)then DetailDraw=false end -- if obscured, at least disable details
		if(State==STATE_BROKEN)then DetailDraw=false PanelDraw=false end -- look incomplete to indicate damage, save on gpu comp too
		---
		self:DrawModel()
		---

		if DetailDraw then
			JMod.RenderModel(self.PanelBackModel, BasePos - Forward * 0.6 + Right * .5, PanelAng, Vector(1.01, 1.01, 1))

			if Closeness < 20000 and State == STATE_ON then
				local DisplayAng = SelfAng:GetCopy()
				DisplayAng:RotateAroundAxis(DisplayAng:Right(), 90)
				DisplayAng:RotateAroundAxis(DisplayAng:Up(), -90)
				DisplayAng:RotateAroundAxis(DisplayAng:Forward(), 0)
				local Opacity = math.random(50, 150)
				local ElecFrac = self:GetProgress() / 100
				local PresFrac = self:GetWater() / 500
				local R, G, B = JMod.GoodBadColor(ElecFrac)
				local PR, PG, PB = JMod.GoodBadColor(PresFrac)
				cam.Start3D2D(SelfPos + Up * 36 + Forward * -40 + Right * 15, DisplayAng, .1)
				surface.SetDrawColor(10,10,10,Opacity+50)
				surface.DrawRect(380, 100, 128, 128)
				JMod.StandardRankDisplay(Grade, 446, 160, 118, Opacity + 50)
				draw.SimpleTextOutlined("PROGRESS", "JMod-Display", 150, 30, Color(255, 255, 255, Opacity), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, Opacity))
				draw.SimpleTextOutlined(tostring(math.Round(ElecFrac * 100)) .. "%", "JMod-Display", 150, 60, Color(R, G, B, Opacity), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, Opacity))
				draw.SimpleTextOutlined("PRESSURE", "JMod-Display", 350, 30, Color(255, 255, 255, Opacity), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, Opacity))
				draw.SimpleTextOutlined(tostring(math.Round(PresFrac * 100)) .. "%", "JMod-Display", 350, 60, Color(PR, PG, PB, Opacity), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, Opacity))
				cam.End3D2D()
			end
		end
	end
	language.Add("ent_jack_gmod_ezsolargenerator", "EZ Solar Panel")
end
