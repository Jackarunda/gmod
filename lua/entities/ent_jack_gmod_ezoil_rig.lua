-- Jackarunda 2023
AddCSLuaFile()
ENT.Type = "anim"
ENT.Author = "Jackarunda, AdventureBoots"
ENT.Information = "glhfggwpezpznore"
ENT.PrintName = "EZ Oil Rig"
ENT.Category = "JMod - EZ Machines"
ENT.Spawnable = true
ENT.AdminOnly = false
ENT.Base = "ent_jack_gmod_ezmachine_base"
---
ENT.Model = "models/jmod/machines/oil_rig.mdl"
ENT.Mass = 3000
ENT.SpawnHeight = 50
ENT.JModPreferredCarryAngles = Angle(0, 0, 0)
ENT.EZanchorage = 2000
ENT.EZpowerSocket = Vector(0, 0, 130)
ENT.EZbuoyancy = .8
---
ENT.WhitelistedResources = {JMod.EZ_RESOURCE_TYPES.OIL}
---
ENT.EZupgradable = true
ENT.StaticPerfSpecs = {
	MaxDurability = 400,
	MaxElectricity = 400,
}
ENT.DynamicPerfSpecs = {
	Armor = 2
}
---
local STATE_BROKEN, STATE_OFF, STATE_RUNNING = -1, 0, 1
---
function ENT:CustomSetupDataTables()
	self:NetworkVar("Float", 1, "Progress")
	self:NetworkVar("String", 0, "ResourceType")
	self:NetworkVar("Int", 2, "PipeLength")
end

if SERVER then
	function ENT:CustomInit()
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
		self:GetPhysicsObject():SetBuoyancyRatio(self.EZbuoyancy)
		self:GetPhysicsObject():Wake()
	end

	function ENT:TryPlace()
		local TowerPos = self:GetPos() + Vector(0, 0, 130)
		local SeaBedTr = util.QuickTrace(TowerPos, Vector(0, 0, -50000), self)
		if (SeaBedTr.Hit) and (SeaBedTr.HitWorld) then
			local DeepWater = true
			--[[for i = 1, 10 do
				local Contents = util.PointContents(SeaBedTr.HitPos + Vector(0, 0, 10 * i))
				if(bit.band(Contents, CONTENTS_WATER) == CONTENTS_WATER)then DeepWater = false break end
			end--]]

			self:UpdateDepositKey(SeaBedTr.HitPos)

			if not(self.DepositKey) then
				JMod.Hint(JMod.GetEZowner(self), "oil rig")
			elseif (DeepWater) then
				local WaterTraceStart = util.QuickTrace(TowerPos, Vector(0, 0, 9e9), self).HitPos
				local WaterSurfaceTr = util.TraceLine({
					start = WaterTraceStart,
					endpos = self:GetPos() - Vector(0, 0, self.SpawnHeight + 5),
					filter = self,
					mask = MASK_WATER
				})
				if not(WaterSurfaceTr.Hit) then return end
				SelfAng = self:GetAngles()
				self:SetAngles(Angle(0, SelfAng.y, 0))
				self:SetPos(WaterSurfaceTr.HitPos + WaterSurfaceTr.HitNormal * self.SpawnHeight)
				---
				JMod.EZinstallMachine(self)
				--self:SetPipeLength(self:GetPos():Distance(SeaBedTr.HitPos))
				local Cable = constraint.Rope(self, game.GetWorld(), 0, 0, Vector(0, 0, 130), SeaBedTr.HitPos, self:GetPos():Distance(SeaBedTr.HitPos), 100, self.EZanchorage, 10, "cable/cable2", true, Color(0, 0, 0))
				self.WellPos = SeaBedTr.HitPos
				---
				if self.DepositKey then
					self:TurnOn(self.EZowner)
				else
					if self:GetState() > STATE_OFF then
						self:TurnOff(self.EZowner)
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

		if self.EZinstalled then
			if (self:GetElectricity() > 0) and JMod.NaturalResourceTable[self.DepositKey] then
				if IsValid(activator) then self.EZstayOn = true end
				self:SetState(STATE_RUNNING)
				self.SoundLoop = CreateSound(self, "snds_jack_gmod/pumpjack_start_loop.wav")
				self.SoundLoop:SetSoundLevel(65)
				self.SoundLoop:Play()
				self:SetProgress(0)
			else
				JMod.Hint(activator, "nopower")
			end
		else
			self:TryPlace()
		end
	end

	function ENT:TurnOff(activator)
		if (self:GetState() <= 0) then return end
		if IsValid(activator) then self.EZstayOn = nil end
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

			else
				self:TurnOn(activator)
			end
		elseif State == STATE_RUNNING then
			if alt then
				self:ProduceResource()

			else
				self:TurnOff(activator)
			end
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

				local DepositInfo = JMod.NaturalResourceTable[self.DepositKey]
				if not DepositInfo then 
					self:TurnOff()

					return
				end

				self:ConsumeElectricity(.5 * (JMod.EZ_GRADE_BUFFS[self:GetGrade()] ^ 2) * JMod.Config.ResourceEconomy.ExtractionSpeed)
				-- This is just the rate at which we pump
				local pumpRate = 1 * (JMod.EZ_GRADE_BUFFS[self:GetGrade()] ^ 2) * JMod.Config.ResourceEconomy.ExtractionSpeed
				-- Here's where we do the rescource deduction, and barrel production
				-- If it's a flow (i.e. water)
				if DepositInfo.rate then
					-- We get the rate
					local flowRate = DepositInfo.rate
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
						local amtToPump = math.min(DepositInfo.amt, 100)
						self:ProduceResource()
					end
				end

				JMod.EmitAIsound(self:GetPos(), 300, .5, 256)
			end
		end
		if ((self.NextEffThink or 0) < Time) then
			self.NextEffThink = Time + .1
			if (State == STATE_RUNNING) then
				local Eff = EffectData()
				Eff:SetOrigin(self:GetPos() + self:GetUp() * 150)
				Eff:SetNormal(self:GetUp())
				Eff:SetScale(.1)
				util.Effect("eff_jack_gmod_ezoilfiresmoke", Eff, true)
			end
		end
	end

	function ENT:ProduceResource()
		local SelfPos, Forward, Up, Right, Typ = self:GetPos(), self:GetForward(), self:GetUp(), self:GetRight(), self:GetResourceType()
		local amt = math.min(self:GetProgress(), 100)

		if amt <= 0 then return end

		local pos = SelfPos + Forward * 15 - Up * 25 - Right * 2
		local spawnVec = self:WorldToLocal(Vector(SelfPos+Up*20+Forward*60-Right*50))
		self:SetProgress(self:GetProgress() - amt)
		JMod.MachineSpawnResource(self, self:GetResourceType(), amt, spawnVec, nil, Forward*500, 300)
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
			if(dmginfo:IsDamageType(DMG_BURN+DMG_SLOWBURN))then 
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
		local Grade = self:GetGrade()
		self.LastGrade = Grade
		self:SetSubMaterial(0, JMod.EZ_GRADE_MATS[Grade]:GetName())
		self.Ladder = JMod.MakeModel(self, "models/props_c17/metalladder001.mdl")
		--self.Pipe = JMod.MakeModel(self, "models/jmod/machines/oil_rig_pipe.mdl")
	end

	function ENT:Draw()
		local Time, SelfPos, SelfAng, State, Grade, Typ = CurTime(), self:GetPos(), self:GetAngles(), self:GetState(), self:GetGrade(), self:GetResourceType()
		local Up, Right, Forward = SelfAng:Up(), SelfAng:Right(), SelfAng:Forward()
		--local PipeLength = self:GetPipeLength()

		self:DrawModel()
		--
		local BasePos = SelfPos + Up * 30
		local Obscured=false--util.TraceLine({start=EyePos(),endpos=BasePos,filter={LocalPlayer(),self},mask=MASK_OPAQUE}).Hit
		local Closeness=LocalPlayer():GetFOV()*(EyePos():Distance(SelfPos))
		local DetailDraw=Closeness<300000 -- cutoff point is ---- units when the fov is 90 degrees
		if((not(DetailDraw))and(Obscured))then return end -- if player is far and sentry is obscured, draw nothing
		if(Obscured)then DetailDraw=false end -- if obscured, at least disable details
		if(State==STATE_BROKEN)then DetailDraw=false end -- look incomplete to indicate damage, save on gpu comp too

		--if self.LastGrade ~= Grade then self:SetSubMaterial(0, JMod.EZ_GRADE_MATS[Grade]:GetName()) end
		self:SetSubMaterial(0, JMod.EZ_GRADE_MATS[Grade]:GetName())

		if(DetailDraw)then
			local LadderAng=SelfAng:GetCopy()
			LadderAng:RotateAroundAxis(Up,0)
			LadderAng:RotateAroundAxis(Right,-7)
			JMod.RenderModel(self.Ladder,BasePos-Forward*44-Up*34,LadderAng,nil,Vector(1,1,1),JMod.EZ_GRADE_MATS[Grade])
			--self.Pipe:ManipulateBonePosition(2, Up * -PipeLength)
			--JMod.RenderModel(self.Pipe,BasePos-Up*20,SelfAng,nil,Vector(1,1,PipeLength/64))

			if((Closeness<20000)and(State==STATE_RUNNING))then
				local DisplayAng=SelfAng:GetCopy()
				DisplayAng:RotateAroundAxis(DisplayAng:Up(),90)
				DisplayAng:RotateAroundAxis(DisplayAng:Forward(),90)
				local Opacity=math.random(50,150)
				cam.Start3D2D(SelfPos+Up*52+Forward*52+Right*18,DisplayAng,.1)
					surface.SetDrawColor(10, 10, 10, Opacity + 50)
					surface.DrawRect(0, 0, 128, 128)
					JMod.StandardRankDisplay(Grade, 64, 64, 118, Opacity + 50)
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
				cam.End3D2D()
			end
		end
		self.LastGrade = Grade
	end

	language.Add("ent_jack_gmod_ezpump_rig", "EZ Oil Rig")
end
