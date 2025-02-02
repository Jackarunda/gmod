-- Jackarunda 2021
AddCSLuaFile()
ENT.Type = "anim"
ENT.PrintName = "EZ Automated Field Hospital"
ENT.Author = "Jackarunda"
ENT.Category = "JMod - EZ Machines"
ENT.Information = "glhfggwpezpznore"
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.Base = "ent_jack_gmod_ezmachine_base"
---
ENT.Model = "models/mri-sjanner/mri-sjanner.mdl"
ENT.Mass = 750
ENT.EZconsumes = {
    JMod.EZ_RESOURCE_TYPES.POWER,
    JMod.EZ_RESOURCE_TYPES.BASICPARTS,
	JMod.EZ_RESOURCE_TYPES.MEDICALSUPPLIES
}
ENT.EZcolorable = true
ENT.EZbouyancy = .3
ENT.EZupgradable = true
-- Config --
ENT.StaticPerfSpecs={
	MaxDurability = 100
}
ENT.DynamicPerfSpecs={
	Armor = .7,
	MaxSupplies = 50,
	ElectricalEfficiency = 1,
	HealEfficiency = 1,
	HealSpeed = 1
}

----
local STATE_BROKEN,STATE_OFF,STATE_ON,STATE_OCCUPIED,STATE_WORKING=-1,0,1,2,3
function ENT:CustomSetupDataTables()
	self:NetworkVar("Int", 2, "Supplies")
end
if(SERVER)then
	function ENT:CustomInit()
		if self.SpawnFull then
			self:SetSupplies(self.MaxSupplies)
		else
			self:SetSupplies(0)
		end

		---
		self.NextWhine=0
		self.NextRealThink=0
		self.NextUseTime=0
		self.IdleShutOffTime=0
		self.NextHumTime=0
		self.NextHeal = 0
		self.NextEnter = 0
		--
		self:CreatePod()
		self.NextOpStart = 0
	end

	function ENT:CreatePod()
		self.Pod = ents.Create("prop_vehicle_prisoner_pod")
		self.Pod:SetModel("models/vehicles/prisoner_pod_inner.mdl")
		local Ang, Up, Right, Forward = self:GetAngles(), self:GetUp(), self:GetRight(), self:GetForward()
		self.Pod:SetPos(self:GetPos() + Up * 52 + Right * 45)
		Ang:RotateAroundAxis(Up, -90)
		Ang:RotateAroundAxis(Forward, -85)
		self.Pod:SetAngles(Ang)
		self.Pod:Spawn()
		self.Pod:Activate()
		self.Pod:SetParent(self)
		self.Pod:SetNoDraw(true)
		self.Pod:SetThirdPersonMode(false)
		--self.Pod.IsJackyPod = true
	end

	function ENT:ReviveCorpses()
		for _, v in ipairs(ents.FindByClass("ent_jack_gmod_ezcorpse")) do
			--jprint(v, v.VeryDead)
			if (self:GetPos():Distance(v:GetPos()) < 512) and not(v.VeryDead) then
				if IsValid(v.DeadPlayer) and not(v.DeadPlayer:Alive()) then
					if IsValid(v.EZragdoll) then
						if istable(v.EZragdoll.EZarmorP) then
							constraint.RemoveAll(v.EZragdoll)
							v.EZragdoll.EZarmorP = nil
						end
					end
					v.DeadPlayer:Spawn()
					v.DeadPlayer:SetPos(v.EZragdoll:GetPos())
					v.DeadPlayer:EnterVehicle(self.Pod)
					v.DeadPlayer:SetHealth(1)
					v:Remove()
					break
				end
			end
		end
	end

	function ENT:Use(activator)
		local State = self:GetState()
		if State == STATE_BROKEN then return end

		if State == STATE_OFF then
			if self:GetElectricity() > 0 then
				self:TurnOn()
				JMod.Hint(activator, "afh enter")
			else
				JMod.Hint(activator, "nopower")
			end
		elseif State == STATE_ON then
			if not IsValid(self.Pod:GetDriver()) then
				if self.NextEnter < CurTime() then
					self.Pod.EZvehicleEjectPos = self.Pod:WorldToLocal(activator:GetPos())
					activator:EnterVehicle(self.Pod)
					JMod.Hint(activator, "afh upgrade")
				end
			end
		end
	end
	
	function ENT:TurnOn()
		if self:GetState() > STATE_OFF then return end

		if self:GetElectricity() <= 0 then
			JMod.Hint(activator, "nopower")

			return
		end

		local Time = CurTime()
		self:SetState(STATE_ON)
		self:SFX("afh_startup")
		self.IdleShutOffTime = Time + 5
		self.NextHumTime = Time + 4
		self.Pod:Fire("unlock", "", 1.4)
		self.NextEnter = Time + 1.6
		self:ConsumeElectricity()
		--self:ReviveCorpses()
	end

	function ENT:TurnOff()
		if (self:GetState() <= STATE_OFF) then return end
		self:SetState(STATE_OFF)
		self:SFX("afh_shutdown")
		self.Patient = nil

		if IsValid(self.Pod:GetDriver()) then
			self.Pod:GetDriver():ExitVehicle()
		end

		self.Pod:Fire("lock", "", 0)
	end

	function ENT:Seal()
		self:SetState(STATE_OCCUPIED)
		self:SFX("afh_seal")
		self.Patient = self.Pod:GetDriver()
		self.NextHeal = CurTime() + 3
		self:ConsumeElectricity()
	end

	function ENT:Unseal()
		self:SetState(STATE_ON)
		self:SFX("afh_unseal")
		self.Patient = nil
		self:ConsumeElectricity()
	end

	function ENT:TryStartOperation()
		if not IsValid(self.Patient) then return end
		---
		local override = hook.Run("JMod_CanFieldHospitalStart", self, self.Patient)
		if override == false then return end

		if override ~= true then
			local Helf, Max, Rads, Infection, Bleed, Gassed, Contaminated = self.Patient:Health(), self.Patient:GetMaxHealth(), self.Patient.EZirradiated or 0, (self.Patient.EZvirus and self.Patient.EZvirus.Severity) or 0, self.Patient.EZbleeding or 0, getMaxExposure and getMaxExposure(self.Patient) or false, getContamination and getContamination(self.Patient) or false
			if (Helf >= Max) and (Rads <= 0) and (Bleed <= 0) and (Infection <= 0) and not Gassed and not Contaminated then return end -- you're not hurt lol gtfo
			if self:GetSupplies() <= 0 then return end
		end

		if self.NextOpStart < CurTime() then
			self:SetState(STATE_WORKING)
			self:SFX("afh_spoolup")
			self:ConsumeElectricity()
			self.NextOpStart = CurTime() + 5
		end
	end

	function ENT:EndOperation(success)
		self:SetState(STATE_OCCUPIED)

		if success then
			self:SFX("ding")
		else
			self:Whine()
		end

		self:ConsumeElectricity()
	end

	function ENT:Think()
		local State, Time, Electricity = self:GetState(), CurTime(), self:GetElectricity()

		self:UpdateWireOutputs()

		if self.NextRealThink < Time then
			if not IsValid(self.Pod) then
				self:CreatePod()

				return
			end

			self.NextRealThink = Time + .15

			if State == STATE_ON then
				if IsValid(self.Pod:GetDriver()) then
					self:Seal()
				else
					if self.IdleShutOffTime < Time then
						self:TurnOff()

						return
					end
				end
			elseif State == STATE_OCCUPIED then
				if IsValid(self.Pod:GetDriver()) then
					self:TryStartOperation()
				else
					self:Unseal()
				end

				self.IdleShutOffTime = Time + 5
			elseif State == STATE_WORKING then
				if IsValid(self.Pod:GetDriver()) then
					self:TryHeal()
				else
					self:Unseal()
				end

				self.IdleShutOffTime = Time + 5
			end
		end

		if State > 0 then
			if self.NextHumTime < Time then
				self.NextHumTime = Time + 3
				self:SFX("afh_run")
				self:ConsumeElectricity()
			end

			if Electricity < self.MaxElectricity * .1 then
				self:Whine()
			end

			if self:GetSupplies() <= self.MaxSupplies * .1 then
				self:Whine()
			end

			if Electricity <= 0 then
				self:TurnOff()
			end
		end

		self:NextThink(Time + .1)

		return true
	end

	function ENT:TryHeal()
		local Time = CurTime()
		if self.NextHeal > Time then return end
		self.NextHeal = Time + 1 / self.HealSpeed ^ 2.75
		local Helf, Max, Supplies = self.Patient:Health(), self.Patient:GetMaxHealth(), self:GetSupplies()
		local Infection, Bleed = (self.Patient.EZvirus and self.Patient.EZvirus.Severity) or 0, self.Patient.EZbleeding or 0

		if Supplies <= 0 then
			if IsValid(self.Patient) then
				JMod.Hint(self.Patient, "afh supply")
			end

			self:EndOperation(false)

			return
		end

		---
		local override = hook.Run("JMod_FieldHospitalHeal", self, self.Patient)
		if override == false then return end
		---
		local Injury, Rads = Max - Helf, self.Patient.EZirradiated or 0
		local gassed, contaminated = getMaxExposure and getMaxExposure(self.Patient) or false, getContamination and getContamination(self.Patient) or false

		if (Injury > 0) or (Rads > 0) or gassed or contaminated then
			if Bleed > 0 then
				self.Patient.EZbleeding = math.Clamp(Bleed - self.HealEfficiency * JMod.Config.Machines.MedBay.HealMult * 5, 0, 9e9)
				self.Patient:PrintMessage(HUD_PRINTCENTER, "stopping bleeding")
				self:HealEffect()
			elseif Rads > 0 or contaminated then
				self.Patient.EZirradiated = math.Clamp(Rads - self.HealEfficiency * JMod.Config.Machines.MedBay.HealMult * 5, 0, 9e9)

				if RemoveContamination then
					RemoveContamination(self.Patient, 140 * self.HealEfficiency * JMod.Config.Machines.MedBay.HealMult)
				end

				self:HealEffect("hl1/ambience/steamburst1.ogg", true)
				self.Patient:PrintMessage(HUD_PRINTCENTER, "decontaminating")
			elseif gassed then
				removeDelayedExposure(self.Patient, 3 * self.HealEfficiency * JMod.Config.Machines.MedBay.HealMult, "Mustard")
				removeDelayedExposure(self.Patient, 140 * self.HealEfficiency * JMod.Config.Machines.MedBay.HealMult, "MustardSkin")
				removeDelayedExposure(self.Patient, 8.58 * self.HealEfficiency * JMod.Config.Machines.MedBay.HealMult, "Cyanide")
				removeDelayedExposure(self.Patient, 390 * self.HealEfficiency * JMod.Config.Machines.MedBay.HealMult, "TearGas")
				removeDelayedExposure(self.Patient, 57 * self.HealEfficiency * JMod.Config.Machines.MedBay.HealMult, "Chlorine")
				removeDelayedExposure(self.Patient, 57 * self.HealEfficiency * JMod.Config.Machines.MedBay.HealMult, "PhosgeneImmediate")
				removeDelayedExposure(self.Patient, 4.5 * self.HealEfficiency * JMod.Config.Machines.MedBay.HealMult, "Phosgene")
				removeDelayedExposure(self.Patient, .105 * self.HealEfficiency * JMod.Config.Machines.MedBay.HealMult, "Sarin")
				removeDelayedExposure(self.Patient, .045 * self.HealEfficiency * JMod.Config.Machines.MedBay.HealMult, "VX")
				self:HealEffect("hl1/ambience/steamburst1.ogg", true)
				self.Patient:PrintMessage(HUD_PRINTCENTER, "curing poisoning")
			else
				if Infection > 1 then
					self.Patient.EZvirus.Severity = math.Clamp(Infection - self.HealEfficiency * JMod.Config.Machines.MedBay.HealMult * 3, 1, 9e9)
					self.Patient:PrintMessage(HUD_PRINTCENTER, "boosting immune system")
				else
					self.Patient:PrintMessage(HUD_PRINTCENTER, "repairing damage")
				end

				local HealAmt = isnumber(override) and math.min(Injury, override) or math.min(Injury, math.ceil(3 * self.HealEfficiency * JMod.Config.Machines.MedBay.HealMult))
				self.Patient:SetHealth(Helf + HealAmt)
				self:HealEffect()
			end

			self:ConsumeElectricity(2)

			if math.random(1, 2) == 1 then
				self:SetSupplies(Supplies - 1)
			end
		else
			self:EndOperation(true)
		end
	end

	function ENT:HealEffect(snd, noBlood)
		if snd then
			self:SFX(snd, true)
		else
			for i = 1, math.random(1, 2) do
				timer.Simple(math.Rand(.01, .5), function()
					if IsValid(self) then
						self:SFX("ez_robotics/" .. math.random(1, 42))
					end
				end)

				timer.Simple(math.Rand(.01, .5), function()
					if IsValid(self) then
						self:SFX("ez_medical/" .. math.random(1, 27))
					end
				end)
			end
		end

		for i = 1, math.random(2, 4) do
			timer.Simple(math.Rand(.01, 1), function()
				if IsValid(self) then
					local Pos = self:GetPos() + self:GetRight() * math.random(-40, 50) + self:GetUp() * math.random(48, 52) + self:GetForward() * math.random(-5, 5)
					local Poof = EffectData()
					Poof:SetOrigin(Pos + VectorRand() * 5)
					util.Effect("eff_jack_Gmod_ezhealpoof", Poof, true, true)

					if (math.random(1, 2) == 1) and not noBlood then
						local Blud = EffectData()
						Blud:SetOrigin(Pos + VectorRand() * 5)
						util.Effect("BloodImpact", Blud, true, true)
					end
				end
			end)
		end
	end
	function ENT:OnPostEntityPaste(ply, ent, createdEntities)
		local Time = CurTime()
		self.NextWhine = Time + math.Rand(0, 3)
		self.NextRealThink = Time + math.Rand(0, 3)
		self.NextUseTime = Time + math.Rand(0, 3)
		self.IdleShutOffTime = Time + math.Rand(0, 3)
		self.NextHumTime = Time + math.Rand(0, 3)
		self.NextHeal = Time + math.Rand(0, 3)
		self.NextEnter = Time + math.Rand(0, 3)
		self.NextOpStart = Time + math.Rand(0, 3)
	end
elseif(CLIENT)then
	function ENT:CustomInit()
		self.Camera = JMod.MakeModel(self,"models/props_combine/combinecamera001.mdl")
		self.TopCanopy = JMod.MakeModel(self,"models/props_phx/construct/windows/window_dome360.mdl")
		self.BottomCanopy = JMod.MakeModel(self,"models/props_phx/construct/windows/window_dome360.mdl")
		self.TopCanopy:SetSubMaterial(0,"mri-sjanner/mri-dome_side")
		self.BottomCanopy:SetSubMaterial(0,"mri-sjanner/mri-dome_side")
		self.TopCanopy:SetSubMaterial(1,"mri-sjanner/mri-dome")
		self.BottomCanopy:SetSubMaterial(1,"mri-sjanner/mri-dome")
		self.Rotator = JMod.MakeModel(self,"models/hunter/tubes/tube4x4x1.mdl")
		-- models/props_phx/construct/glass/glass_dome360.mdl
		self.OpenAmt = 1
		self.DriveCycle = 0
	end

	function ENT:PostEntityPaste(ply, ent, createdEntities)
		self.OpenAmt = 1
		self.DriveCycle = 0
	end

	function ENT:Think()
		local State, Grade, Time = self:GetState(), self:GetGrade(), CurTime()
		local FT = FrameTime()
		if State > 1 then
			self.OpenAmt = math.Clamp((self.OpenAmt or 0) - FT * 1.3, 0, 1) --Lerp(FT*2,self.OpenAmt,0)
		else
			self.OpenAmt = math.Clamp((self.OpenAmt or 0) + FT * 1.3, 0, 1) --Lerp(FT*2,self.OpenAmt,1)
		end

		if (State == STATE_WORKING) then
			self.DriveCycle=self.DriveCycle+FT*100
			if(self.DriveCycle>360)then self.DriveCycle=0 end
		end
	end

	local function ColorToVector(col)
		return Vector(col.r / 255, col.g / 255, col.b / 255)
	end
	local GlowSprite=Material("sprites/mat_jack_basicglow")
	function ENT:Draw()
		local SelfPos, SelfAng, State, FT, Grade = self:GetPos(), self:GetAngles(), self:GetState(), FrameTime(), self:GetGrade()
		local Up, Right, Forward, FT = SelfAng:Up(), SelfAng:Right(), SelfAng:Forward(), FrameTime()
		---
		local BasePos = SelfPos + Up * 60

		local Obscured = util.TraceLine({
			start = EyePos(),
			endpos = BasePos,
			filter = {LocalPlayer(), self},
			mask = MASK_OPAQUE
		}).Hit

		local Closeness = LocalPlayer():GetFOV() * EyePos():Distance(SelfPos)
		local DetailDraw = Closeness < 60000
		if (not DetailDraw) and Obscured then return end -- if player is far and sentry is obscured, draw nothing

		-- if obscured, at least disable details
		if Obscured then
			DetailDraw = false
		end

		-- look incomplete to indicate damage, save on gpu comp too
		if State == STATE_BROKEN then
			DetailDraw = false
		end

		---
		self:DrawModel()
		---
		local DisplayAng=SelfAng:GetCopy()
		DisplayAng:RotateAroundAxis(Forward,90)
		if(DetailDraw)then
			local CamAng=SelfAng:GetCopy()
			CamAng:RotateAroundAxis(Up,-90)
			CamAng:RotateAroundAxis(Right,180)
			JMod.RenderModel(self.Camera,BasePos+Up*10+Forward*25,CamAng,nil,Vector(1,1,1),JMod.EZ_GRADE_MATS[Grade])
			---
			local TopCanopyAng = SelfAng:GetCopy()
			TopCanopyAng:RotateAroundAxis(Forward, -10 * self.OpenAmt)
			JMod.RenderModel(self.TopCanopy, BasePos - Up * (17 - 10 * self.OpenAmt) + Right * 2, TopCanopyAng, Vector(.4, 1.45, .5))
			---
			local BottomCanopyAng = SelfAng:GetCopy()
			BottomCanopyAng:RotateAroundAxis(Right, 180)
			JMod.RenderModel(self.BottomCanopy, BasePos - Up * 17 + Right * 2, BottomCanopyAng, Vector(.4, 1.45, .5))
			---
			local RotatorAng = SelfAng:GetCopy()
			RotatorAng:RotateAroundAxis(Forward,90)
			RotatorAng:RotateAroundAxis(Right,self.DriveCycle)
			JMod.RenderModel(self.Rotator, BasePos - Up*10 - Right*22, RotatorAng,Vector(.58, .58, .3),Vector(1,1,1),JMod.EZ_GRADE_MATS[Grade])
			---
			if State > 0 then
				local Opacity = math.random(50, 200)
				local ElecFrac = self:GetElectricity() / self.MaxElectricity
				local R, G, B = JMod.GoodBadColor(ElecFrac)
				cam.Start3D2D(BasePos + Up * 22 + Right * 22 + Forward * 21, DisplayAng, .08)
				draw.SimpleTextOutlined("Jackarunda Industries", "JMod-Display", 0, 0, Color(255, 255, 255, Opacity), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, Opacity))
				draw.SimpleTextOutlined("POWER " .. math.Round(ElecFrac * 100) .. "%", "JMod-Display", 0, 40, Color(R, G, B, Opacity), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, Opacity))
				draw.SimpleTextOutlined("SUPPLIES " .. self:GetSupplies() .. "/" .. self.MaxSupplies * JMod.EZ_GRADE_BUFFS[Grade], "JMod-Display", 0, 80, Color(255, 255, 255, Opacity), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, Opacity))
				cam.End3D2D()
			end
		end

		if State <= 0 then
			cam.Start3D2D(BasePos + Up * 40 + Right * 7.8 - Forward * 50, DisplayAng, 1)
			surface.SetDrawColor(0, 0, 0, 255)
			--surface.DrawRect(39, 9, 22, 12)
			cam.End3D2D()
			---
			cam.Start3D2D(BasePos + Up * 11 + Right * 3.8 - Forward * 50, DisplayAng, 1)
			surface.SetDrawColor(0, 0, 0, 255)
			--surface.DrawRect(8, 9, 15, 10)
			--surface.DrawRect(77, 9, 15, 10)
			cam.End3D2D()
		end
	end

	language.Add("ent_jack_gmod_ezfieldhospital", "EZ Automated Field Hospital")
end
