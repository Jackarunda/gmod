-- AdventureBoots 2023
AddCSLuaFile()
ENT.Type = "anim"
ENT.PrintName = "EZ Mini Radioisotope Thermoelectric Generator"
ENT.Author = "Jackarunda, AdventureBoots"
ENT.Category = "JMod - EZ Machines"
ENT.Information = "Probably came out of a soviet satillite"
ENT.Spawnable = false
ENT.AdminOnly = true
ENT.Base = "ent_jack_gmod_ezmachine_base"
ENT.Model = "models/jmod/machines/radioisotope-powergenerator-small.mdl"
ENT.Mat = "models/jmod/machines/rtg_assembly_soviet.vmt"
--
ENT.EZupgradable = false
ENT.EZcolorable = true
--
ENT.JModPreferredCarryAngles = Angle(0, -90, 0)
ENT.Mass = 30
ENT.SpawnHeight = 1
--
ENT.JModEZstorable = true
ENT.JModEZstorableVolume = 10
ENT.JModInvAllowedActive = true
--
ENT.StaticPerfSpecs = {
	MaxDurability = 100
}
ENT.DynamicPerfSpecs = {
	Armor = .8
}
ENT.EZconsumes = {
	JMod.EZ_RESOURCE_TYPES.BASICPARTS
}
ENT.EZpowerProducer = true
ENT.EZpowerSocket = Vector(0, 0, 0)
ENT.MaxConnectionRange = 100

function ENT:CustomSetupDataTables()
	self:NetworkVar("Float", 1, "Progress")
end

local STATE_BROKEN, STATE_OFF, STATE_ON = -1, 0, 1

if(SERVER)then
	function ENT:CustomInit()
		self:SetProgress(0)
		self.NextResourceThink = 0
		self.NextEnvThink = 0
		self.NextUseTime = 0
		self.PowerSLI = 0 -- Power Since Last Interaction
		self.MaxPowerSLI = 500
	end

	function ENT:Use(activator)
		if self.NextUseTime > CurTime() then return end
		local State = self:GetState()
		local Alt = JMod.IsAltUsing(activator)
		JMod.SetEZowner(self, activator)
		JMod.Colorify(self)

		if Alt then
			if State == STATE_BROKEN then
				JMod.Hint(activator, "destroyed", self)
				return
			elseif State == STATE_OFF then
				self:TurnOn(activator)
			elseif State == STATE_ON then
				self:TurnOff(activator)
			end
		else
			activator:PickupObject(self)
		end
	end

	function ENT:TurnOn(activator, auto)
		if (self:GetState() ~= STATE_OFF) then return end
		if IsValid(activator) and not(auto) then
			self.EZstayOn = true
			self:EmitSound("buttons/button1.wav", 60, 80)
		end
		self.NextUseTime = CurTime() + 1
		self:SetState(STATE_ON)
		self.PowerSLI = 0
	end

	function ENT:TurnOff(activator)
		if (self:GetState() <= 0) then return end
		self.NextUseTime = CurTime() + 1
		if IsValid(activator) then 
			self.EZstayOn = true 
			self:EmitSound("buttons/button18.wav", 60, 80)
		end
		self:SetState(STATE_OFF)
		self:ProduceResource()
		self.PowerSLI = 0
	end

	function ENT:ProduceResource(activator)
		local SelfPos, Up, Forward, Right = self:GetPos(), self:GetUp(), self:GetForward(), self:GetRight()
		local amt = math.Clamp(math.floor(self:GetProgress()), 0, 100)

		if amt <= 0 then return end
		local pos = self:WorldToLocal(SelfPos + Up * 10 + Right * 14)
		JMod.MachineSpawnResource(self, JMod.EZ_RESOURCE_TYPES.POWER, amt, pos, Angle(0, -90, 0), Forward * 60, 100)
		self:SetProgress(math.Clamp(self:GetProgress() - amt, 0, 100))
		--self:EmitSound("items/suitchargeok1.wav", 80, 120)

		self.PowerSLI = math.Clamp(self.PowerSLI + amt, 0, self.MaxPowerSLI)
		
		if self.PowerSLI >= self.MaxPowerSLI then
			self:TurnOff()
		end
	end

	function ENT:Think()
		local Time, State = CurTime(), self:GetState()

		self:UpdateWireOutputs()

		if self.NextResourceThink < Time then
			self.NextResourceThink = Time + 1
			if State == STATE_ON then
				local PowerPerMin = 5
				local PowerToProduce = (PowerPerMin/60)

				local InventoryOwner = self:GetNW2Entity("EZInvOwner", NULL)
				if IsValid(InventoryOwner) and InventoryOwner.EZarmor then
					for id, armorData in pairs(InventoryOwner.EZarmor.items) do
						local ArmodInfo = JMod.ArmorTable[armorData.name]
						if ArmodInfo and armorData.chrg then
							for k, v in pairs(armorData.chrg) do
								if k == "power" then
									local NeededPower = ArmodInfo.chrg.power - armorData.chrg.power
									local PowerToGive = math.min(NeededPower, PowerToProduce)
									armorData.chrg.power = armorData.chrg.power + PowerToGive
									PowerToProduce = PowerToProduce - PowerToGive
								end
							end
						end
					end
				end
				self:SetProgress(self:GetProgress() + PowerToProduce)

				if self:GetProgress() >= 100 then self:ProduceResource() end
			elseif State == STATE_BROKEN then
				JMod.DamageSpark(self)
			end
		end

		if self.NextEnvThink < Time then
			self.NextEnvThink = Time + math.random(15, 60)
			if JMod.LinCh(100 - self.Durability, 10, 100) then
				JMod.DamageSpark(self)
				for k, ent in pairs(ents.FindInSphere(self:GetPos(), 100)) do
					if JMod.ShouldDamageBiologically(ent) and JMod.VisCheck(self:GetPos(), ent, self) then
						JMod.FalloutIrradiate(self, ent)
					end
				end
			end
		end
	end

	function ENT:OnDestroy()
		for i = 1, JMod.Config.Particles.NuclearRadiationMult * 2 do
			local SelfPos, EZowner = self:GetPos(), JMod.GetEZowner(self)
			timer.Simple(i * .05, function()
				local Gas = ents.Create("ent_jack_gmod_ezfalloutparticle")
				Gas.Range = 500
				Gas:SetPos(SelfPos)
				JMod.SetEZowner(Gas, EZowner)
				Gas:Spawn()
				Gas:Activate()
				Gas.CurVel = (VectorRand() * math.random(1, 1000) + Vector(0, 0, 100 * JMod.Config.Particles.NuclearRadiationMult))
			end)
		end
	end

	function ENT:OnPostEntityPaste(ply, ent, createdEntities)
		local Time = CurTime()
		self.NextResourceThink = Time + math.Rand(0, 3)
		self.NextEnvThink = Time + math.Rand(1, 10)
		self.NextUseTime = Time + math.Rand(0, 3)
	end

elseif(CLIENT)then
	local GlowyColor = Vector(.3, 2, .2)
	local GlowyScale = Vector(.2, 1, 2)
	function ENT:CustomInit()
		self:DrawShadow(true)
		self.Cylinder = JMod.MakeModel(self, "models/hunter/tubes/tube2x2x05.mdl", "models/debug/debugwhite")
	end

	function ENT:Think()
		local SelfPos, SelfAng, State = self:GetPos(), self:GetAngles(), self:GetState()
		if State ~= STATE_ON then return end
		local Up, Right, Forward = SelfAng:Up(), SelfAng:Right(), SelfAng:Forward()
		local GlowCol = GlowyColor:ToColor()
		local DLight = DynamicLight(self:EntIndex())

		if DLight then
			DLight.Pos = SelfPos + Up * 20
			DLight.r = GlowCol.r
			DLight.g = GlowCol.g
			DLight.b = GlowCol.b
			DLight.Brightness = .7
			DLight.Size = 100
			DLight.Decay = 15000
			DLight.DieTime = CurTime() + .1
			DLight.Style = 0
		end
	end

	function ENT:Draw()
		local SelfPos, SelfAng, State = self:GetPos(), self:GetAngles(), self:GetState()
		local Up, Right, Forward = SelfAng:Up(), SelfAng:Right(), SelfAng:Forward()
		local Grade = self:GetGrade()
		---
		local BasePos = SelfPos + Up * 30
		local Obscured = util.TraceLine({start = EyePos(), endpos = BasePos, filter = {LocalPlayer(), self}, mask = MASK_OPAQUE}).Hit
		local Closeness = LocalPlayer():GetFOV() * (EyePos():Distance(SelfPos))
		local DetailDraw = Closeness < 120000 -- cutoff point is 400 units when the fov is 90 degrees
		---
		if((not(DetailDraw)) and (Obscured))then return end -- if player is far and sentry is obscured, draw nothing
		if(Obscured)then DetailDraw = false end -- if obscured, at least disable details
		if(State == STATE_BROKEN)then DetailDraw = false end -- look incomplete to indicate damage, save on gpu comp too
		---
		self:DrawModel()
		local GlowyBasePos = SelfPos + Up * 20
		JMod.RenderModel(self.Cylinder, GlowyBasePos, SelfAng, Vector(0.13, 0.13, .5), GlowyColor, nil, State == STATE_ON)
		---
		
		if DetailDraw then
			if (Closeness < 20000) and (State == STATE_ON) then
				local DisplayAng = SelfAng:GetCopy()
				DisplayAng:RotateAroundAxis(DisplayAng:Right(), 0)
				DisplayAng:RotateAroundAxis(DisplayAng:Up(), 0)
				DisplayAng:RotateAroundAxis(DisplayAng:Forward(), 90)
				local Opacity = math.random(50, 150)
				local ProgFrac = self:GetProgress() / 100
				local R, G, B = JMod.GoodBadColor(ProgFrac)

				cam.Start3D2D(SelfPos + Right * 7.8 + Up * 5, DisplayAng, .06)
				draw.SimpleTextOutlined("PROGRESS", "JMod-Display", 0, 0, Color(255, 255, 255, Opacity), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, Opacity))
				draw.SimpleTextOutlined(tostring(math.Round(ProgFrac * 100)) .. "%", "JMod-Display", 0, 30, Color(R, G, B, Opacity), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, Opacity))
				cam.End3D2D()
			end
		end
	end
	language.Add("ent_jack_gmod_ezrps", "EZ Radioisotope Thermoelectric Generator")
end
