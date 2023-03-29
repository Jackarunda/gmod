-- Jackarunda 2021
AddCSLuaFile()
ENT.Type = "anim"
ENT.Author = "Jackarunda"
ENT.Information = "glhfggwpezpznore"
ENT.PrintName = "EZ Auger Drill"
ENT.Category = "JMod - EZ Machines"
ENT.Spawnable = true
ENT.AdminOnly = false
ENT.Base = "ent_jack_gmod_ezmachine_base"
---
ENT.Model = "models/jmodels/props/machines/drill_support.mdl"
ENT.Mass = 2000
ENT.SpawnHeight = 115
ENT.JModPreferredCarryAngles = Angle(0, 0, 0)
ENT.EZupgradable = true
ENT.StaticPerfSpecs = {
	MaxDurability = 100,
	MaxElectricity = 400
}
ENT.DynamicPerfSpecs = {
	Armor = 2
}
--
--ENT.WhitelistedResources = {}
ENT.BlacklistedResources = {"water", "oil", "geothermal"}

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
		self.NextResourceThinkTime = 0
		self.NextEffectThinkTime = 0
		self.NextOSHAthinkTime = 0
		timer.Simple(0.1, function()
			self:TryPlace()
		end)
        timer.Simple(5, function()
            if IsValid(self) then
            JMod.Hint(self.EZowner, "ore scan")
            end
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
		local SelfAng = self:GetAngles()
		if (Tr.Hit) and (Tr.HitWorld) then
			local Roll = Tr.HitNormal:Angle().r
			local Yaw = Tr.HitNormal:Angle().y
			self:SetAngles(Angle(Tr.HitNormal:Angle().p + 90, (Yaw >= 20 and Yaw) or SelfAng.y, Roll))
			self:SetPos(Tr.HitPos + Tr.HitNormal * self.SpawnHeight - Tr.HitNormal * 5)
			--
			local GroundIsSolid = true
			for i = 1, 50 do
				local Contents = util.PointContents(Tr.HitPos - Vector(0, 0, 10 * i))
				if(bit.band(util.PointContents(self:GetPos()), CONTENTS_SOLID) == CONTENTS_SOLID)then GroundIsSolid=false break end
			end
			self:UpdateDepositKey()
			if not self.DepositKey then
				JMod.Hint(self.EZowner, "ground drill")
			elseif(GroundIsSolid)then
				if not(IsValid(self.Weld))then self.Weld = constraint.Weld(self, Tr.Entity, 0, 0, 50000, false, false) end
				if(IsValid(self.Weld) and self.DepositKey)then
					self:TurnOn(self.EZowner)
				else
					if self:GetState() > STATE_OFF then
						self:TurnOff()
					end
					JMod.Hint(self.EZowner, "machine mounting problem")
				end
			end
		end
	end

	function ENT:TurnOn(activator)
		if self:GetState() > STATE_OFF then return end
		if (self:GetElectricity() > 0) and (IsValid(self.Weld)) and (self.DepositKey) then
			self:SetState(STATE_RUNNING)
			self.SoundLoop = CreateSound(self, "snd_jack_betterdrill1.wav")
			self.SoundLoop:SetSoundLevel(60)
			self.SoundLoop:Play()
			self:SetProgress(0)
		else
			JMod.Hint(activator,"nopower")
		end
	end
	
	function ENT:TurnOff()
		self:SetState(STATE_OFF)
		self:ProduceResource(self:GetProgress())

		if self.SoundLoop then
			self.SoundLoop:Stop()
		end
	end

	function ENT:Use(activator)
		local State = self:GetState()
		local OldOwner = self.EZowner
		local alt = activator:KeyDown(JMod.Config.AltFunctionKey)
		JMod.SetEZowner(self,activator)
		if(IsValid(self.EZowner))then
			if(OldOwner ~= self.EZowner)then -- if owner changed then reset team color
				JMod.Colorify(self)
			end
		end

		if State == STATE_BROKEN then
			JMod.Hint(activator, "destroyed", self)

			return
		elseif State == STATE_OFF then
			if (self:GetElectricity() <= 0) then JMod.Hint(activator, "nopower") return end
			self:TryPlace()
		elseif State == STATE_RUNNING then
			if alt then
				self:ProduceResource(self:GetProgress())

				return
			end
			self:TurnOff()
		end
	end

	function ENT:ResourceLoaded(typ, accepted)
		if typ == JMod.EZ_RESOURCE_TYPES.POWER and accepted >= 1 then
			self:TurnOn(self.EZowner)
		end
	end
	
	function ENT:OnRemove()
		if(self.SoundLoop)then self.SoundLoop:Stop() end
	end
	
	function ENT:Think()
		local State, Time, Prog = self:GetState(), CurTime(), self:GetProgress()
		local SelfPos, Up, Right, Forward = self:GetPos(), self:GetUp(), self:GetRight(), self:GetForward()

		if (self.NextResourceThinkTime < Time) then
			self.NextResourceThinkTime = Time + 1
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

				-- This is just the rate at which we drill
				local drillRate = 0.8 * (JMod.EZ_GRADE_BUFFS[self:GetGrade()] ^ 2)

				self:ConsumeElectricity(JMod.EZ_GRADE_BUFFS[self:GetGrade()] ^ 1.5)
				
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
		end

		if (self.NextEffectThinkTime < Time) then
			self.NextEffectThinkTime = Time + .1
			if State == STATE_RUNNING then
				local Dert = EffectData()
				Dert:SetOrigin(SelfPos - Up * 100 - Right * 0 - Forward * 9)
				Dert:SetNormal(Up)
				util.Effect("eff_jack_gmod_augerdig", Dert, true, true)
			end
		end

		if (self.NextOSHAthinkTime < Time) and (State == STATE_RUNNING) then
			self.NextOSHAthinkTime = Time + .1
			local HitEnts = {self}
			local BasePos = SelfPos + Up * (-10 - Prog)
			local HullTr = util.TraceHull({
				start = SelfPos + Up * (-100 - Prog),
				endpos = BasePos,
				maxs = Vector(6, 6, 6),
				mins = Vector(-6, -6, -6),
				filter = self,
				mask = MASK_SOLID,
				ignoreworld = true
			})
			if HullTr.Hit then
				local pierce = 0
				while HullTr.Fraction < 1 and pierce < 100 do
					pierce = pierce + 1
					local ent = HullTr.Entity
					if IsValid(ent) and IsValid(ent:GetPhysicsObject()) then
						local Dmg = DamageInfo()
						Dmg:SetDamagePosition(BasePos)
						Dmg:SetDamageForce(Vector(0, 0, 10000))
						Dmg:SetDamage(10)
						Dmg:SetDamageType(DMG_CRUSH)
						Dmg:SetInflictor(ent)
						Dmg:SetAttacker(JMod.GetEZowner(self))
						ent:TakeDamageInfo(Dmg)
						--print(tostring(ent))
						table.insert(HitEnts, ent)
					end
					util.TraceHull({
						start = SelfPos + Up * (-100 - Prog) * HullTr.Fraction,
						endpos = BasePos,
						maxs = Vector(6, 6, 6),
						mins = Vector(-6, -6, -6),
						filter = HitEnts,
						mask = MASK_SOLID,
						ignoreworld = true,
						output = HullTr
					})
				end
				self:EmitSound("Boulder.ImpactHard")
			end
		end
	end
	
	function ENT:ProduceResource()
		local SelfPos, Forward, Up, Right, Typ = self:GetPos(), self:GetForward(), self:GetUp(), self:GetRight(), self:GetResourceType()
		local amt = math.Clamp(math.floor(self:GetProgress()), 0, 100)

		if amt <= 0 then return end

		local pos = SelfPos
		local spawnVec = self:WorldToLocal(SelfPos + Up * 50 - Right * 50)
		JMod.MachineSpawnResource(self, self:GetResourceType(), amt, spawnVec, Angle(0, 0, -90), Right * 100, true, 200)
		self:SetProgress(self:GetProgress() - amt)
	end

	function ENT:PostEntityPaste(ply, ent, createdEntities)
		local Time = CurTime()
		JMod.SetEZowner(self, ply)
		ent.NextRefillTime = Time + math.Rand(0, 3)
		ent.NextResourceThinkTime = 0
		ent.NextEffectThinkTime = 0
		ent.NextOSHAthinkTime = 0
	end

elseif(CLIENT)then

	function ENT:Initialize()
		self.Auger = JMod.MakeModel(self, "models/jmodels/props/machines/drill_auger.mdl")
		self.DrillPipe = JMod.MakeModel(self, "models/props_pipes/pipe03_straight01_long.mdl")
		self.DrillPipeEnd = JMod.MakeModel(self, "models/props_pipes/pipe03_connector01.mdl")
		self.DrillMotor = JMod.MakeModel(self, "models/props_wasteland/laundry_basket001.mdl")
		self.PowerBox = JMod.MakeModel(self, "models/props_lab/powerbox01a.mdl")
		self.DrillMat = Material("mechanics/metal2")
		self.DrillSpin = 0
		self.CurDepth = 0
	end

	function ENT:Draw()
		self:DrawModel()
		local Up, Right, Forward, Grade, Typ, State, FT = self:GetUp(), self:GetRight(), self:GetForward(), self:GetGrade(), self:GetResourceType(), self:GetState(), FrameTime()
		local SelfPos, SelfAng = self:GetPos(), self:GetAngles()
		local BoxPos = SelfPos + Up * 52 + Right * 3 + Forward * -8
		local MotorPos = BoxPos + Up * -45 + Right * -3
		local DrillPos = MotorPos + Up * -(120 + self.CurDepth)
		local PipePos = DrillPos + Up * 145 + Right * -8.5
		--
		if self.CurDepth - self:GetProgress() > 1 then
			self.CurDepth = Lerp(math.ease.InOutExpo(FT * 15), self.CurDepth, self:GetProgress())
		else
			self.CurDepth = Lerp(math.ease.InOutExpo(FT * 5), self.CurDepth, self:GetProgress())
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
			self.DrillSpin = self.DrillSpin - FT * 600
			if self.DrillSpin > 360 then
				self.DrillSpin = 0
			elseif self.DrillSpin < 0 then
				self.DrillSpin = 360
			end
		end
		--

		local Obscured = util.TraceLine({start = EyePos(), endpos = MotorPos, filter = {LocalPlayer(), self}, mask = MASK_OPAQUE}).Hit
		local Closeness = LocalPlayer():GetFOV() * (EyePos():Distance(SelfPos))
		local DetailDraw = Closeness < 36000 -- cutoff point is 400 units when the fov is 90 degrees
		local DrillDraw = true
		if State == STATE_BROKEN then 
			DetailDraw = false 
			DrillDraw = false 
		end -- look incomplete to indicate damage, save on gpu comp too

		if DrillDraw then
			MotorAng:RotateAroundAxis(Up, -90)
			MotorAng:RotateAroundAxis(Forward, 90)
			JMod.RenderModel(self.DrillPipe, PipePos, MotorAng, Vector(1, 0.9, 1), nil, JMod.EZ_GRADE_MATS[Grade])
			local DrillAng = SelfAng:GetCopy()
			DrillAng:RotateAroundAxis(Up, self.DrillSpin)
			JMod.RenderModel(self.Auger, DrillPos, DrillAng, Vector(3, 3, 3.2), nil, self.DrillMat)
			local PipeEndAng = SelfAng:GetCopy()
			PipeEndAng:RotateAroundAxis(Right, 90)
			PipeEndAng:RotateAroundAxis(Up, self.DrillSpin)
			JMod.RenderModel(self.DrillPipeEnd, DrillPos + Up * 101, PipeEndAng, Vector(1, 1, 1), nil, JMod.EZ_GRADE_MATS[Grade])
		end

		if (not(DetailDraw)) and (Obscured) then return end -- if player is far and sentry is obscured, draw nothing
		if Obscured then DetailDraw = false end -- if obscured, at least disable details
		
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
                    local ElecFrac=self:GetElectricity()/400
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
	language.Add("ent_jack_gmod_ezaugerdrill","EZ Auger Drill")
end