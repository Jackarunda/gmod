AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "EZ Geothermal Generator"
ENT.Author = "Jackarunda, AdventureBoots"
ENT.Category = "JMod - EZ Machines"
ENT.Information = ""
ENT.Spawnable = true --Until it's completed
ENT.Base = "ent_jack_gmod_ezmachine_base"
ENT.Model = "models/jmod/machines/geothermal.mdl"
--
ENT.JModPreferredCarryAngles = Angle(0, 0, 0)
ENT.SpawnHeight = 52
ENT.Mass = 8000
--
ENT.StaticPerfSpecs = {
	MaxDurability = 300,
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
		self:TurnOn()
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
				--JMod.Hint(self.EZowner, "oil derrick")
			elseif(GroundIsSolid)then
				local HitAng = Tr.HitNormal:Angle()
				local Pitch = HitAng.p
				local Yaw = self:GetAngles().y
				local Roll = HitAng.r
				self:SetAngles(Angle(0, Yaw, Roll))
				self:SetPos(Tr.HitPos + Tr.HitNormal * (self.SpawnHeight - 15))
				---
				self:GetPhysicsObject():EnableMotion(false)
				self.EZinstalled = true
				---
				if self.DepositKey then
					self:TurnOn(JMod.GetEZowner(self))
				else
					if self:GetState() > STATE_OFF then
						self:TurnOff()
					end
					JMod.Hint(self.EZowner, "machine mounting problem")
				end
			end
		end
	end

	function ENT:Use(activator)
		if self.NextUse > CurTime() then return end
		local State = self:GetState()
		local OldOwner = JMod.GetEZowner(self)
		local alt = activator:KeyDown(JMod.Config.General.AltFunctionKey)
		JMod.SetEZowner(self, activator)
		JMod.Colorify(self)
		if(IsValid(JMod.GetEZowner(self)) and (OldOwner ~= JMod.GetEZowner(self)))then
			JMod.Colorify(self)
		end
		if(State == STATE_BROKEN)then
			JMod.Hint(activator, "destroyed", self)

			return
		elseif(State == STATE_OFF)then
			self:TurnOn()
		elseif(State == STATE_RUNNING)then
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

		if amt < 1 then return end

		local pos = SelfPos + Up*20 - Right*50 + Forward*25
		JMod.MachineSpawnResource(self, JMod.EZ_RESOURCE_TYPES.POWER, amt, self:WorldToLocal(pos), Angle(0, 0, 0), Up, true, 200)
		self:SetProgress(math.Clamp(self:GetProgress() - amt, 0, 100))
		self:EmitSound("items/suitchargeok1.wav", 80, 120)
	end

	function ENT:TurnOn()
		if self:GetState() ~= STATE_OFF then return end

		if self.EZinstalled then
			self:EmitSound("snd_jack_rustywatervalve.wav", 100, 120)
			timer.Simple(0.6, function()
				if not IsValid(self) then return end
				self:EmitSound("snds_jack_gmod/hiss.wav", 100, 80)
			end)
			if (self:GetWater() > 0) and (self.DepositKey) then
				self:SetState(STATE_RUNNING)
				timer.Simple(1, function()
					if not IsValid(self) then return end
					if self.SoundLoop then 
						self.SoundLoop:Play() 
						self.SoundLoop:SetSoundLevel(100)
						self.SoundLoop:ChangePitch(100)
					end
				end)
			end
		else
			self:TryPlace()
		end
	end

	function ENT:TurnOff()
		if self:GetState() <= STATE_OFF then return end
		self:ProduceResource()
		self:SetState(STATE_OFF)
		self:EmitSound("snd_jack_rustywatervalve.wav", 100, 120)
		timer.Simple(1, function()
			if not IsValid(self) then return end
			if self.SoundLoop then 
				self.SoundLoop:Stop()
			end
		end)
	end

	function ENT:Think()
		local State, Time = self:GetState(), CurTime()
		
		if (self.NextResourceThinkTime < Time) then
			self.NextResourceThinkTime = Time + 1

			local Phys = self:GetPhysicsObject()
			if State == STATE_BROKEN then
				if self.SoundLoop then self.SoundLoop:Stop() end

				return
			elseif State == STATE_RUNNING then

				if self.EZinstalled then
					if Phys:IsMotionEnabled() or self:IsPlayerHolding() then
						self.EZinstalled = false
						self:TurnOff()

						return
					end
				else
					self:TurnOff()

					return
				end

				if self:GetWater() <= 0 then
					self:TurnOff()

					return 
				end

				if not JMod.NaturalResourceTable[self.DepositKey] then 
					self:TurnOff()

					return
				end

				local FlowRate = JMod.NaturalResourceTable[self.DepositKey].rate
				self:SetProgress(self:GetProgress() + FlowRate / (5 / self.ChargeRate))
				if self.NextWaterLoseTime < Time then
					self.NextWaterLoseTime = Time + FlowRate / (1/(self.ChargeRate*10))

					self:SetWater(self:GetWater() - 1 * FlowRate)
					self:EmitSound("snds_jack_gmod/hiss.wav", 100, math.random(75, 80) * self.ChargeRate)
					local Foof = EffectData()
					Foof:SetOrigin(self:GetPos() + self:GetUp() * 120 + self:GetForward() * 10)
					Foof:SetNormal(self:GetUp())
					Foof:SetScale(1)
					Foof:SetStart(self:GetPhysicsObject():GetVelocity())
					util.Effect("eff_jack_gmod_ezsteam", Foof, true, true)
				end
				

				if self:GetProgress() >= 100 then
					self:ProduceResource()
				end

				self.LastWater = math.floor(self:GetWater())
			end
		end
	end

	function ENT:ResourceLoaded(typ, accepted)
		if typ == JMod.EZ_RESOURCE_TYPES.WATER and accepted >= 1 then
			self:TurnOn(JMod.GetEZowner(self))
		end
	end

	function ENT:OnRemove()
		if self.SoundLoop then 
			self.SoundLoop:Stop()
		end
	end

	function ENT:PostEntityPaste(ply, ent, createdEntities)
		local Time = CurTime()
		JMod.SetEZowner(self, ply)
		ent.NextRefillTime = Time + math.Rand(0, 3)
		ent.NextUse = Time + math.Rand(0, 3)
		ent.NexResourceThinkTime = Time + math.Rand(0, 3)
		self.NextWaterLoseTime = Time
	end

elseif CLIENT then
	function ENT:CustomInit()
		self:DrawShadow(true)
	end
	
	local Black = Material("black_square_model")--"models/debug/debugwhite")
	function ENT:Draw()
		local SelfPos,SelfAng,State=self:GetPos(),self:GetAngles(),self:GetState()
		local Up,Right,Forward=SelfAng:Up(),SelfAng:Right(),SelfAng:Forward()
		local Grade = self:GetGrade()
		---
		local BasePos = SelfPos + Up * 36 + Forward * -40 + Right * 15
		local Obscured = util.TraceLine({start=EyePos(),endpos=BasePos,filter={LocalPlayer(),self},mask=MASK_OPAQUE}).Hit
		local Closeness = LocalPlayer():GetFOV()*(EyePos():Distance(SelfPos))
		local DetailDraw = Closeness<120000 -- cutoff point is 400 units when the fov is 90 degrees
		---
		if((not(DetailDraw))and(Obscured))then return end -- if player is far and sentry is obscured, draw nothing
		if(Obscured)then DetailDraw=false end -- if obscured, at least disable details
		--if(State==STATE_BROKEN)then DetailDraw=false end -- look incomplete to indicate damage, save on gpu comp too
		---
		self:DrawModel()
		---

		if DetailDraw then
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
	end
	language.Add("ent_jack_gmod_ezsolargenerator", "EZ Solar Panel")
end
