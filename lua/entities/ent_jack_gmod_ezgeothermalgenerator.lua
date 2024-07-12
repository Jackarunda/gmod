AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "EZ Geothermal Generator"
ENT.Author = "Jackarunda, AdventureBoots"
ENT.Category = "JMod - EZ Machines"
ENT.Information = ""
ENT.Spawnable = true
ENT.Base = "ent_jack_gmod_ezmachine_base"
ENT.Model = "models/jmod/machines/geothermal.mdl"
--
ENT.JModPreferredCarryAngles = Angle(0, 0, 0)
ENT.SpawnHeight = 52
ENT.Mass = 8000
ENT.EZanchorage = 2000
--
ENT.StaticPerfSpecs = {
	MaxDurability = 400,
	MaxElectricity = 0,
	MaxWater = 200
}
--
ENT.DynamicPerfSpecs = {
	Armor = 2,
	ChargeRate = 1
}
--
ENT.EZconsumes = {
	JMod.EZ_RESOURCE_TYPES.BASICPARTS,
	JMod.EZ_RESOURCE_TYPES.WATER
}
ENT.WhitelistedResources = {
	"geothermal"
}
ENT.EZpowerProducer = true
ENT.EZpowerSocket = Vector(10, 30, 48)

function ENT:CustomSetupDataTables()
	self:NetworkVar("Float", 1, "Progress")
	self:NetworkVar("Int", 2, "Water")
end

local STATE_BROKEN, STATE_OFF, STATE_RUNNING = -1, 0, 1

if(SERVER)then
	function ENT:CustomInit()
		self.EZupgradable = true
		self:SetProgress(0)
		if self.SpawnFull then
			self:SetWater(self.MaxWater)
		else
			self:SetWater(0)
		end
		self:TryPlace()
		self.NextUse = 0
		self.NextResourceThinkTime = 0
		self.NextWaterLoseTime = 0
		self.SoundLoop = CreateSound(self, "snd_jack_waterturbine.wav")
	end

	function ENT:TryPlace()
		local Tr = util.QuickTrace(self:GetPos() + Vector(0, 0, 100), Vector(0, 0, -500), self)
		if (Tr.Hit) and (Tr.HitWorld) then
			local GroundIsSolid = true
			for i = 1, 50 do
				local Contents = util.PointContents(Tr.HitPos - Vector(0, 0, 10 * i))
				if(bit.band(util.PointContents(self:GetPos()), CONTENTS_SOLID) == CONTENTS_SOLID)then GroundIsSolid = false break end
			end

			self:UpdateDepositKey()

			if not(self.DepositKey)then
				JMod.Hint(JMod.GetEZowner(self), "geothermal gen")
			elseif(GroundIsSolid)then
				local HitAng = Tr.HitNormal:Angle()
				local Pitch = HitAng.p
				local Yaw = self:GetAngles().y
				local Roll = HitAng.r
				self:SetAngles(Angle(0, Yaw, Roll))
				self:SetPos(Tr.HitPos + Tr.HitNormal * (self.SpawnHeight - 15))
				---
				JMod.EZinstallMachine(self)
				---
				if self.DepositKey then
					self:TurnOn(JMod.GetEZowner(self))
				else
					if self:GetState() > STATE_OFF then
						self:TurnOff()
					end
					self.EZstayOn = nil
					JMod.Hint(JMod.GetEZowner(self), "machine mounting problem")
				end
			end
		end
	end

	function ENT:Use(activator)
		if self.NextUse > CurTime() then return end
		local State = self:GetState()
		local OldOwner = JMod.GetEZowner(self)
		local Alt = activator:KeyDown(JMod.Config.General.AltFunctionKey)
		JMod.SetEZowner(self, activator, true)
		if(State == STATE_BROKEN)then
			JMod.Hint(activator, "destroyed", self)

			return
		end
		if Alt then
			self:ModConnections(activator)
		else
			if(State == STATE_OFF)then
				self:TurnOn(activator)
			elseif(State == STATE_RUNNING)then
				self:TurnOff(activator)
			end
		end
	end

	function ENT:ProduceResource()
		local SelfPos, Up, Forward, Right = self:GetPos(), self:GetUp(), self:GetForward(), self:GetRight()
		local amt = math.Clamp(math.floor(self:GetProgress()), 0, 100)

		if amt < 1 then return end

		local pos = SelfPos + Up*20 - Right*50 + Forward*25
		self:SetProgress(math.Clamp(self:GetProgress() - amt, 0, 100))
		JMod.MachineSpawnResource(self, JMod.EZ_RESOURCE_TYPES.POWER, amt, self:WorldToLocal(pos), Angle(0, 0, 0), Up, 300)
		self:EmitSound("items/suitchargeok1.wav", 80, 120)
	end

	function ENT:TurnOn(Dude, auto)
		if self:GetState() > 0 then return end

		if self.EZinstalled then
			if IsValid(Dude) and not(auto) then
				self.EZstayOn = true
				self:EmitSound("snd_jack_rustywatervalve.ogg", 100, 120)
				self.NextUse = CurTime() + 1
				timer.Simple(0.6, function()
					if not IsValid(self) then return end
					self:EmitSound("snds_jack_gmod/hiss.ogg", 100, 80)
				end)
			end
			if (self:GetWater() > 0) and JMod.NaturalResourceTable[self.DepositKey] then
				self:SetState(STATE_RUNNING)
				timer.Simple(1, function()
					if not IsValid(self) then return end
					if self.SoundLoop then 
						self.SoundLoop:Play() 
						self.SoundLoop:SetSoundLevel(75)
						self.SoundLoop:ChangePitch(100)
					end
				end)
			elseif self:GetWater() <= 0 then
				JMod.Hint(JMod.GetEZowner(self), "refill geo")
			end
		else
			self:TryPlace()
		end
	end

	function ENT:TurnOff(activator)
		if (self:GetState() <= 0) then return end
		if IsValid(activator) then self.EZstayOn = nil end
		self:ProduceResource()
		self:SetState(STATE_OFF)
		self:EmitSound("snd_jack_rustywatervalve.ogg", 100, 120)
		timer.Simple(1, function()
			if not IsValid(self) then return end
			if self.SoundLoop then 
				self.SoundLoop:Stop()
			end
		end)
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

				return
			elseif State == STATE_RUNNING then

				if not self.EZinstalled then self:TurnOff() return end

				if self:GetWater() <= 0 then
					self:TurnOff()

					return 
				end

				local DepositInfo = JMod.NaturalResourceTable[self.DepositKey]
				if not(DepositInfo and DepositInfo.rate and (DepositInfo.rate > 0)) then 
					self:TurnOff()

					return
				end

				local FlowRate = DepositInfo.rate --* JMod.Config.ResourceEconomy.ExtractionSpeed
				self:SetProgress(self:GetProgress() + FlowRate / (self.ChargeRate))

				if self.NextWaterLoseTime < Time then
					self.NextWaterLoseTime = Time + FlowRate * self.ChargeRate * 20

					self:SetWater(self:GetWater() - 1 * FlowRate)
				end
				

				if self:GetProgress() >= 100 then
					self:ProduceResource()
				end

				self.LastWater = math.floor(self:GetWater())
			end
		end

		if State == STATE_RUNNING then
			self:EmitSound("snds_jack_gmod/hiss.ogg", 60, math.random(75, 80) * self.ChargeRate)
			local Foof = EffectData()
			Foof:SetOrigin(self:GetPos() + self:GetUp() * 120 + self:GetForward() * 10)
			Foof:SetNormal(self:GetUp())
			Foof:SetScale(1)
			Foof:SetStart(self:GetPhysicsObject():GetVelocity())
			util.Effect("eff_jack_gmod_ezsteam", Foof, true, true)
		end

		self:NextThink(Time + .2)
		return true
	end

	--[[function ENT:ResourceLoaded(typ, accepted)
		if typ == JMod.EZ_RESOURCE_TYPES.WATER and accepted >= 1 then
			self:TurnOn(JMod.GetEZowner(self), true)
		end
	end--]]

	function ENT:OnDestroy(dmginfo)
		local Pos = self:GetPos()
		local Foof = EffectData()
		Foof:SetOrigin(Pos + self:GetUp() * 10)
		Foof:SetNormal(self:GetUp())
		Foof:SetScale(50)
		Foof:SetStart(self:GetPhysicsObject():GetVelocity())
		util.Effect("eff_jack_gmod_ezsteam", Foof, true, true)
		self:EmitSound("snds_jack_gmod/hiss.ogg", 100, 100)

		local Range = 400
		for _, ent in pairs(ents.FindInSphere(Pos, Range)) do
			if ent ~= self then
				local DDistance = Pos:Distance(ent:GetPos())
				local DistanceFactor = (1 - DDistance / Range) ^ 2

				if JMod.ClearLoS(self, ent) then
					local Dmg = DamageInfo()
					Dmg:SetDamage(100 * DistanceFactor) -- wanna scale this with distance
					Dmg:SetDamageType(DMG_BURN)
					Dmg:SetDamageForce(Vector(0, 0, 5000) * DistanceFactor) -- some random upward force
					Dmg:SetAttacker((IsValid(dmginfo:GetAttacker()) and dmginfo:GetAttacker()) or game.GetWorld()) -- the earth is mad at you
					Dmg:SetInflictor(self or game.GetWorld())
					Dmg:SetDamagePosition(ent:GetPos())

					if ent.TakeDamageInfo then
						ent:TakeDamageInfo(Dmg)
					end
				end
			end
		end
	end

	function ENT:OnRemove()
		if self.SoundLoop then 
			self.SoundLoop:Stop()
		end
	end

	function ENT:OnPostEntityPaste(ply, ent, createdEntities)
		local Time = CurTime()
		ent.NextUse = Time + math.Rand(0, 3)
		ent.NextResourceThinkTime = Time + math.Rand(0, 3)
		self.NextWaterLoseTime = Time
	end

elseif CLIENT then
	function ENT:CustomInit()
		self.Piping = JMod.MakeModel(self, "models/props_c17/gasmeter002a.mdl")
	end
	
	local Black = Material("black_square_model")--"models/debug/debugwhite")
	function ENT:Draw()
		local SelfPos,SelfAng,State=self:GetPos(),self:GetAngles(),self:GetState()
		local Up,Right,Forward=SelfAng:Up(),SelfAng:Right(),SelfAng:Forward()
		local Grade = self:GetGrade()
		---
		local BasePos = SelfPos + Up * 36 + Forward * -40 + Right * 15
		local Obscured = false--util.TraceLine({start=EyePos(),endpos=BasePos,filter={LocalPlayer(),self},mask=MASK_OPAQUE}).Hit
		local Closeness = LocalPlayer():GetFOV()*(EyePos():Distance(SelfPos))
		local DetailDraw = Closeness<120000 -- cutoff point is 400 units when the fov is 90 degrees
		---
		if((not(DetailDraw))and(Obscured))then return end -- if player is far and machine is obscured, draw nothing
		if(Obscured)then DetailDraw=false end -- if obscured, at least disable details
		if(State==STATE_BROKEN)then DetailDraw=false end -- look incomplete to indicate damage, save on gpu comp too
		---
		self:DrawModel()
		---
		if DetailDraw then
			local PipeAng = SelfAng:GetCopy()
			PipeAng:RotateAroundAxis(Up, 90)
			--PipeAng:RotateAroundAxis(Right, 0)
			JMod.RenderModel(self.Piping, BasePos + Up * -14 + Forward * 80 + Right * -46, PipeAng, Vector(1.5, 1.5, 1.5), nil, JMod.EZ_GRADE_MATS[Grade])
		end
		if Closeness < 20000 and State == STATE_RUNNING then
			local DisplayAng = SelfAng:GetCopy()
			DisplayAng:RotateAroundAxis(DisplayAng:Right(), 90)
			DisplayAng:RotateAroundAxis(DisplayAng:Up(), -90)
			DisplayAng:RotateAroundAxis(DisplayAng:Forward(), 0)
			local Opacity = math.random(50, 150)
			local ElecFrac = self:GetProgress() / 100
			local PresFrac = self:GetWater() / 200
			local R, G, B = JMod.GoodBadColor(ElecFrac)
			local PR, PG, PB = JMod.GoodBadColor(PresFrac)
			cam.Start3D2D(BasePos, DisplayAng, .1)
			surface.SetDrawColor(10,10,10,Opacity+50)
			surface.DrawRect(380, 100, 128, 128)
			JMod.StandardRankDisplay(Grade, 446, 160, 118, Opacity + 50)
			draw.SimpleTextOutlined("PROGRESS", "JMod-Display", 150, 30, Color(255, 255, 255, Opacity), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, Opacity))
			draw.SimpleTextOutlined(tostring(math.Round(ElecFrac * 100)) .. "%", "JMod-Display", 150, 60, Color(R, G, B, Opacity), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, Opacity))
			draw.SimpleTextOutlined("WATER", "JMod-Display", 350, 30, Color(255, 255, 255, Opacity), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, Opacity))
			draw.SimpleTextOutlined(tostring(math.Round(PresFrac * 100)) .. "%", "JMod-Display", 350, 60, Color(PR, PG, PB, Opacity), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, Opacity))
			cam.End3D2D()
		elseif State ~= STATE_RUNNING then
			DisplayAng=SelfAng:GetCopy()
			DisplayAng:RotateAroundAxis(DisplayAng:Up(), 180)
			DisplayAng:RotateAroundAxis(DisplayAng:Right(), 0)
			DisplayAng:RotateAroundAxis(DisplayAng:Forward(), 0)
			render.SetMaterial(Black)
			render.DrawQuadEasy(SelfPos + Up * 31 + Forward * -40 + Right * 43, DisplayAng:Forward(), 50, 50, Color(0, 0, 0, 255), DisplayAng.r)
		end
	end
	language.Add("ent_jack_gmod_ezsolargenerator", "EZ Solar Panel")
end
