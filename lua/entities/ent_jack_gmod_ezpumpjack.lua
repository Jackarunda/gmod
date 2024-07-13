-- Jackarunda 2021
AddCSLuaFile()
ENT.Type = "anim"
ENT.Author = "Jackarunda"
ENT.Information = "glhfggwpezpznore"
ENT.PrintName = "EZ Pumpjack"
ENT.Category = "JMod - EZ Machines"
ENT.Spawnable = true
ENT.AdminOnly = false
ENT.Base = "ent_jack_gmod_ezmachine_base"
---
ENT.Model = "models/hunter/blocks/cube4x4x1.mdl"
ENT.Mass = 3000
ENT.SpawnHeight = 95
ENT.JModPreferredCarryAngles = Angle(0, 0, -90)
ENT.EZanchorage = 2000
---
ENT.WhitelistedResources = {JMod.EZ_RESOURCE_TYPES.WATER, JMod.EZ_RESOURCE_TYPES.OIL}
---
ENT.EZupgradable = true
ENT.StaticPerfSpecs = {
	MaxDurability = 400,
	MaxElectricity = 400,
}
ENT.DynamicPerfSpecs = {
	Armor = 2
}
ENT.EZpowerSocket = Vector(-90, 80, 0)
---
local STATE_BROKEN, STATE_OFF, STATE_RUNNING = -1, 0, 1
---
function ENT:CustomSetupDataTables()
	self:NetworkVar("Float", 1, "Progress")
	self:NetworkVar("String", 0, "ResourceType")
end
if(SERVER)then
	function ENT:CustomInit()
		self:SetAngles(Angle(0, 0, -90))
		self:SetProgress(0)
		self.DepositKey = 0
		self.NextResourceThinkTime = 0
		timer.Simple(0.1, function()
			self:TryPlace() 
		end)
        timer.Simple(5, function()
            if IsValid(self) then
            	JMod.Hint(JMod.GetEZowner(self), "liquid scan")
            end
        end)
	end

	function ENT:TryPlace()
		local Tr = util.QuickTrace(self:GetPos() + Vector(0, 0, 100), Vector(0, 0, -500), self)
		SelfAng = self:GetAngles()
		if (Tr.Hit) and (Tr.HitWorld) then
			local GroundIsSolid = true
			for i = 1, 50 do
				local Contents = util.PointContents(Tr.HitPos - Vector(0, 0, 10 * i))
				if(bit.band(util.PointContents(self:GetPos()), CONTENTS_SOLID) == CONTENTS_SOLID)then GroundIsSolid = false break end
			end

			self:UpdateDepositKey()

			if not(self.DepositKey)then
				JMod.Hint(JMod.GetEZowner(self), "oil derrick")
			elseif(GroundIsSolid)then
				local HitAngle = Tr.HitNormal:Angle()
				--jprint("Before", HitAngle)
				HitAngle:RotateAroundAxis(HitAngle:Up(), 90)
				--jprint("After", HitAngle)
				--self:SetAngles(HitAngle)
				self:SetAngles(Angle(0, SelfAng.y, -90))
				self:SetPos(Tr.HitPos + Tr.HitNormal * self.SpawnHeight)
				---
				self:GetPhysicsObject():EnableMotion(false)
				self.EZinstalled = true
				---
				if self.DepositKey then
					self:TurnOn(self.EZowner)
				else
					if self:GetState() > STATE_OFF then
						self:TurnOff(JMod.GetEZowner(self))
					end
					self.EZstayOn = nil
					JMod.Hint(JMod.GetEZowner(self), "machine mounting problem")
				end
			end
		end
	end

	function ENT:TurnOn(activator)
		if self:GetState() ~= STATE_OFF then return end
		local SelfPos, Forward, Right = self:GetPos(), self:GetForward(), self:GetRight()

		if self.EZinstalled and JMod.NaturalResourceTable[self.DepositKey] then
			if (self:GetElectricity() > 0) then
				if IsValid(activator) then self.EZstayOn = true end
				self:SetState(STATE_RUNNING)
				self.SoundLoop = CreateSound(self, "snds_jack_gmod/pumpjack_start_loop.wav")
				self.SoundLoop:SetSoundLevel(65)
				self.SoundLoop:Play()
				self.WellPos = SelfPos + Forward * 120 - Right * 95
				self:SetProgress(0)
			else
				JMod.Hint(activator, "nopower")
			end
		else
			self:TryPlace()
		end
	end

	function ENT:TurnOff(stayOff)
		if (self:GetState() <= STATE_OFF) then return end
		if stayOff then self.EZstayOn = nil end
		self:SetState(STATE_OFF)
		self:ProduceResource()

		if self.SoundLoop then
			self.SoundLoop:Stop()
		end

		self:EmitSound("snds_jack_gmod/pumpjack_stop.ogg")
	end

	function ENT:Use(activator)
		local State = self:GetState()
		local OldOwner = JMod.GetEZowner(self)
		local alt = activator:KeyDown(JMod.Config.General.AltFunctionKey)
		JMod.SetEZowner(self, activator, true)

		if State == STATE_BROKEN then
			JMod.Hint(activator, "destroyed", self)

			return
		elseif State == STATE_OFF then
			if alt and self.EZinstalled then
				JMod.EZinstallMachine(self, false)

				return
			end
			self:TurnOn(activator)
		elseif State == STATE_RUNNING then
			if alt then
				self:ProduceResource()

				return
			end
			self:TurnOff()
		end
	end

	--[[function ENT:ResourceLoaded(typ, accepted)
		if typ == JMod.EZ_RESOURCE_TYPES.POWER and accepted >= 1 then
			self:TurnOn(self.EZowner)
		end
	end--]]

	function ENT:OnRemove()
		if(self.SoundLoop)then self.SoundLoop:Stop() end
	end

	function ENT:Think()
		local State, Time = self:GetState(), CurTime()
		local Phys = self:GetPhysicsObject()

		self:UpdateWireOutputs()

		if self.EZinstalled then
			if Phys:IsMotionEnabled() or self:IsPlayerHolding() then
				self.EZinstalled = false
				self:TurnOff()

				return
			end
		end

		if (self.NextResourceThinkTime < Time) then
			self.NextResourceThinkTime = Time + 1
			
			if State == STATE_BROKEN then
				if self.SoundLoop then self.SoundLoop:Stop() end

				if self:GetElectricity() > 0 then
					if math.random(1, 4) == 2 then JMod.DamageSpark(self) end
				end

				return
			elseif State == STATE_RUNNING then
				
				if not self.EZinstalled then self:TurnOff() return end

				local Deposit = JMod.NaturalResourceTable[self.DepositKey]
				if not Deposit then 
					self:TurnOff()

					return
				end

				self:ConsumeElectricity(.5 * (JMod.EZ_GRADE_BUFFS[self:GetGrade()] ^ 2) * JMod.Config.ResourceEconomy.ExtractionSpeed)
				-- This is just the rate at which we pump
				local pumpRate = 1 * (JMod.EZ_GRADE_BUFFS[self:GetGrade()] ^ 2) * JMod.Config.ResourceEconomy.ExtractionSpeed
				-- Here's where we do the rescource deduction, and barrel production
				-- If it's a flow (i.e. water)
				if Deposit.rate then
					-- We get the rate
					local flowRate = Deposit.rate
					-- and set the progress to what it was last tick + our ability * the flowrate
					self:SetProgress(self:GetProgress() + pumpRate * flowRate)

					-- If the progress exceeds 100
					if self:GetProgress() >= 100 then
						-- Spawn barrel
						local amtToPump = math.min(self:GetProgress(), 100)
						self:ProduceResource()
					end
				else
					self:SetProgress(self:GetProgress() + pumpRate)

					if self:GetProgress() >= 100 then
						local amtToPump = math.min(Deposit.amt, 100)
						self:ProduceResource()
					end
				end

				JMod.EmitAIsound(self:GetPos(), 300, .5, 256)
			end
		end
	end

	function ENT:ProduceResource()
		local SelfPos, Forward, Up, Right, Typ = self:GetPos(), self:GetForward(), self:GetUp(), self:GetRight(), self:GetResourceType()
		local amt = math.min(self:GetProgress(), 100)

		if amt <= 0 then return end

		local pos = SelfPos + Forward * 15 - Up * 25 - Right * 2
		local spawnVec = self:WorldToLocal(Vector(SelfPos+Forward*120-Right*50))
		self:SetProgress(self:GetProgress() - amt)
		JMod.MachineSpawnResource(self, self:GetResourceType(), amt, spawnVec, Angle(0, 0, 90), Forward*500, 200)
		JMod.DepleteNaturalResource(self.DepositKey, amt)
	end

	function ENT:OnDestroy(dmginfo)
		local SelfPos, Up, Forward, Right = self:GetPos(), self:GetUp(), self:GetForward(), self:GetRight()
		if not self.WellPos then return end
		local createOilFire = function()
			timer.Simple(0.1, function()
				local oilFire = ents.Create("ent_jack_gmod_ezoilfire")
				oilFire:SetPos(self.WellPos)
				oilFire:SetAngles(Angle(180, 0, 90))
				oilFire.DepositKey = self.DepositKey
				oilFire:Spawn()
				JMod.SetEZowner(oilFire, self.EZowner)
				oilFire:Activate()
			end)
		end
		if not(self.DepositKey)then return end
		if(self:GetResourceType() == "oil")then
			if(dmginfo:IsDamageType(DMG_BURN+DMG_SLOWBURN) or self:IsOnFire())then 
				createOilFire()
			elseif dmginfo:IsDamageType(DMG_BLAST + DMG_BLAST_SURFACE + DMG_PLASMA + DMG_ENERGYBEAM) and (math.random(0, 100) > 50) then
				createOilFire()
			elseif dmginfo:IsDamageType(DMG_DIRECT + DMG_BUCKSHOT) and (math.random(0, 100) > 75) then
				createOilFire()
			end
		end
	end

	function ENT:OnPostEntityPaste(ply, ent, createdEntities)
		local Time = CurTime()
		self.DepositKey = 0
		self.NextResourceThinkTime = 0
		if self:GetState(STATE_RUNNING) then
			timer.Simple(0.1, function()
				if IsValid(self) then self:TryPlace() end
			end)
		end
	end

elseif(CLIENT)then
	function ENT:CustomInit()
		self.MachineryBox = JMod.MakeModel(self, "models/hunter/blocks/cube05x105x05.mdl")
		self.Ladder=JMod.MakeModel(self,"models/props_c17/metalladder001.mdl")
		self.Mdl=ClientsideModel("models/tsbb/pump_jack.mdl")
		self.Mdl:SetPos(self:GetPos()-self:GetRight()*100)
		local Ang=self:GetAngles()
		Ang:RotateAroundAxis(self:GetForward(),90)
		self.Mdl:SetAngles(Ang)
		self.Mdl:SetParent(self)
		self.Mdl:SetNoDraw(true)
		self.DriveCycle = 0
		self.DriveMomentum = 0
	end

	--[[
	0	Base
	1	WalkingBeam
	2	CounterWeight
	--]]
	function ENT:Think()
		local State, Grade, Time = self:GetState(), self:GetGrade(), CurTime()
		local FT = FrameTime()

		if State == STATE_RUNNING then
			self.DriveMomentum = math.Clamp(self.DriveMomentum + FT / 3, 0, 0.4)
		else
			self.DriveMomentum = math.Clamp(self.DriveMomentum - FT / 3, 0, 0.4)
		end
		self.DriveCycle=self.DriveCycle+self.DriveMomentum*Grade*FT*100
		if(self.DriveCycle>360)then self.DriveCycle=0 end
	end

	
	function ENT:Draw()
		local Time, SelfPos, SelfAng, State, Grade, Typ = CurTime(), self:GetPos(), self:GetAngles(), self:GetState(), self:GetGrade(), self:GetResourceType()
		local Up, Right, Forward = SelfAng:Up(), SelfAng:Right(), SelfAng:Forward()

		local WalkingBeamDrive=math.sin((self.DriveCycle/360)*math.pi*2-math.pi)*20
		self.Mdl:ManipulateBoneAngles(1,Angle(0,0,WalkingBeamDrive))
		self.Mdl:ManipulateBoneAngles(2,Angle(0,0,self.DriveCycle))
		--render.SetBlend(.5)
		--self:DrawModel()
		--render.SetBlend(1)
		self.Mdl:SetRenderOrigin(SelfPos - Right * 100)
		local MdlAng = SelfAng:GetCopy()
		MdlAng:RotateAroundAxis(Forward, 90)
		self.Mdl:SetRenderAngles(MdlAng)
		self.Mdl:DrawModel()
		local BasePos=SelfPos+Up*32
		local BoxAng=SelfAng:GetCopy()
		BoxAng:RotateAroundAxis(Up,90)
		BoxAng:RotateAroundAxis(Forward,90)
		JMod.RenderModel(self.MachineryBox,BasePos-Up*32-Right*74+Forward*20,BoxAng,nil,Vector(1,1,1),JMod.EZ_GRADE_MATS[Grade])
		--
		local Obscured=false--util.TraceLine({start=EyePos(),endpos=BasePos,filter={LocalPlayer(),self},mask=MASK_OPAQUE}).Hit
		local Closeness=LocalPlayer():GetFOV()*(EyePos():Distance(SelfPos))
		local DetailDraw=Closeness<36000 -- cutoff point is 400 units when the fov is 90 degrees
		if((not(DetailDraw))and(Obscured))then return end -- if player is far and sentry is obscured, draw nothing
		if(Obscured)then DetailDraw=false end -- if obscured, at least disable details
		if(State==STATE_BROKEN)then DetailDraw=false end -- look incomplete to indicate damage, save on gpu comp too
		if(DetailDraw)then
			local LadderAng=SelfAng:GetCopy()
			LadderAng:RotateAroundAxis(Up,90)
			LadderAng:RotateAroundAxis(Forward,80)
			JMod.RenderModel(self.Ladder,BasePos-Right*80+Forward*30-Up*60,LadderAng,nil,Vector(1,1,1),JMod.EZ_GRADE_MATS[Grade])
			
			if((Closeness<20000)and(State==STATE_RUNNING))then
				local DisplayAng=SelfAng:GetCopy()
				DisplayAng:RotateAroundAxis(DisplayAng:Right(),90)
				DisplayAng:RotateAroundAxis(DisplayAng:Up(),180)
				DisplayAng:RotateAroundAxis(DisplayAng:Forward(),-50)
				local Opacity=math.random(50,150)
				cam.Start3D2D(SelfPos+Up*25-Right*50-Forward*80,DisplayAng,.1)
					surface.SetDrawColor(10, 10, 10, Opacity + 50)
					surface.DrawRect(184, -200, 128, 128)
					JMod.StandardRankDisplay(Grade, 248, -140, 118, Opacity + 50)
					draw.SimpleTextOutlined("EXTRACTING","JMod-Display",250,-60,Color(255,255,255,Opacity),TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP,3,Color(0,0,0,Opacity))
					local ExtractCol=Color(100,255,100,Opacity)
					if(Typ=="water")then ExtractCol=Color(0,200,200,Opacity)
					elseif(Typ=="oil")then ExtractCol=Color(120,80,0,Opacity) end
					draw.SimpleTextOutlined(string.upper(Typ) or "N/A","JMod-Display",250,-30,ExtractCol,TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP,3,Color(0,0,0,Opacity))
					draw.SimpleTextOutlined("POWER","JMod-Display",250,0,Color(255,255,255,Opacity),TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP,3,Color(0,0,0,Opacity))
					local ElecFrac=self:GetElectricity()/400
					local R,G,B=JMod.GoodBadColor(ElecFrac)
					draw.SimpleTextOutlined(tostring(math.Round(ElecFrac*100)).."%","JMod-Display",250,30,Color(R,G,B,Opacity),TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP,3,Color(0,0,0,Opacity))
					draw.SimpleTextOutlined("PROGRESS","JMod-Display",250,60,Color(255,255,255,Opacity),TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP,3,Color(0,0,0,Opacity))
					local ProgressFrac=self:GetProgress()/100
					draw.SimpleTextOutlined(tostring(math.Round(ProgressFrac*100)).."%","JMod-Display",250,90,Color(R,G,B,Opacity),TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP,3,Color(0,0,0,Opacity))
					--local CoolFrac=self:GetCoolant()/100
					--draw.SimpleTextOutlined("COOLANT","JMod-Display",90,0,Color(255,255,255,Opacity),TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP,3,Color(0,0,0,Opacity))
					--local R,G,B=JMod.GoodBadColor(CoolFrac)
					--draw.SimpleTextOutlined(tostring(math.Round(CoolFrac*100)).."%","JMod-Display",90,30,Color(R,G,B,Opacity),TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP,3,Color(0,0,0,Opacity))
				cam.End3D2D()
			end
		end
	end

	language.Add("ent_jack_gmod_ezoilpump", "EZ Pumpjack")
end
