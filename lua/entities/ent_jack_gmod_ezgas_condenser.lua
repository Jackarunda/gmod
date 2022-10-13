AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "EZ Gas Compressor"
ENT.Author = "Jackarunda, AdventureBoots"
ENT.Category = "JMod - EZ Misc."
ENT.Information = ""
ENT.Spawnable = true
ENT.Base = "ent_jack_gmod_ezmachine_base"
ENT.Model = "models/props_c17/furnitureboiler001a.mdl"
ENT.Mass = 200
--
ENT.MaxDurability = 50
ENT.JModPreferredCarryAngles = Angle(0, 0, 0)
ENT.MaxPower = 100
--
ENT.StaticPerfSpecs = {
	MaxDurability = 80,
	MaxElectricity = 100,
	MaxGas = 100
}

ENT.DynamicPerfSpecs = {
	ChargeSpeed = 1
}
function ENT:CustomSetupDataTables()
	self:NetworkVar("Float", 1, "Progress")
end

local STATE_BROKEN, STATE_OFF,  STATE_ON = -1, 0, 1

if(SERVER)then
	function ENT:SpawnFunction(ply,tr,ClassName)
		local ent=ents.Create(ClassName)
		ent:SetPos(tr.HitPos + tr.HitNormal*25)
		ent:SetAngles(Angle(0, 0, 0))
		JMod.Owner(ent,ply)
		ent:Spawn()
		ent:Activate()
		--local effectdata=EffectData()
		--effectdata:SetEntity(ent)
		--util.Effect("propspawn",effectdata)
		return ent
	end

	function ENT:CustomInit()
		self.EZupgradable = true
		self:SetState(STATE_ON)
		self:SetProgress(0)
		self.NextUse = 0
	end

	function ENT:Use(activator)
		local State=self:GetState()
		local OldOwner=self.Owner
		local alt = activator:KeyDown(JMod.Config.AltFunctionKey)
		JMod.Owner(self,activator)
		JMod.Colorify(self)
		if(IsValid(self.Owner) and (OldOwner ~= self.Owner))then
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

	function ENT:SpawnEffect(pos)
		--[[local effectdata=EffectData()
		effectdata:SetOrigin(pos)
		effectdata:SetNormal((VectorRand()+Vector(0,0,1)):GetNormalized())
		effectdata:SetMagnitude(math.Rand(5,10))
		effectdata:SetScale(math.Rand(.5,1.5))
		effectdata:SetRadius(math.Rand(2,4))
		util.Effect("Sparks", effectdata)]]--
		self:EmitSound("items/suitchargeok1.wav", 80, 120)
	end

	function ENT:ProduceResource()
		local SelfPos, Up, Forward, Right = self:GetPos(), self:GetUp(), self:GetForward(), self:GetRight()
		local amt = math.min(math.floor(self:GetProgress()), self.MaxPower)

		if amt <= 0 then return end

		local pos = SelfPos
		JMod.MachineSpawnResource(self, JMod.EZ_RESOURCE_TYPES.GAS, amt, self:WorldToLocal(pos), Angle(0, 0, 0), Forward * 100, true, 200)
		self:SetProgress(math.Clamp(self:GetProgress() - amt, 0, 100))
		self:SpawnEffect(pos)
	end

	function ENT:TurnOn()
		if (self:GetElectricity() > 0) then
			self:EmitSound("buttons/button1.wav", 60, 80)
			self:SetState(STATE_ON)
			self.NextUse = CurTime() + 1
		else
			self:EmitSound("buttons/button2.wav", 60, 100)
		end
	end

	function ENT:TurnOff()
		self:EmitSound("buttons/button18.wav", 60, 80)
		self:ProduceResource()
		self:SetState(STATE_OFF)
		self:SetProgress(0)
		self.NextUse = CurTime() + 1
	end

	function ENT:Think()
		local State = self:GetState()
		if(State == STATE_ON)then

			self:ConsumeElectricity(.5)

			local grade = self:GetGrade()

			if self:GetProgress() < self.MaxGas then
				local rate = math.Round(2 * JMod.EZ_GRADE_BUFFS[grade] ^ 2, 2)
				self:SetProgress(self:GetProgress() + rate)
			end

			if self:GetProgress() >= self.MaxGas then
				self:ProduceResource()
			end

			self:NextThink(CurTime() + 2)

			return true
		end
	end
elseif CLIENT then
	local GradeColors = JMod.EZ_GRADE_COLORS
	local GradeMats = JMod.EZ_GRADE_MATS
	function ENT:Draw()
		local SelfPos, SelfAng, State = self:GetPos(), self:GetAngles(), self:GetState()
		local Up, Right, Forward = SelfAng:Up(), SelfAng:Right(), SelfAng:Forward()
		local Grade = self:GetGrade()
		---
		local BasePos = SelfPos
		local Obscured = util.TraceLine({start=EyePos(),endpos=BasePos,filter={LocalPlayer(),self},mask=MASK_OPAQUE}).Hit
		local Closeness = LocalPlayer():GetFOV()*(EyePos():Distance(SelfPos))
		local DetailDraw = Closeness < 120000 -- cutoff point is 400 units when the fov is 90 degrees
		local PanelDraw = true
		---
		if((not(DetailDraw))and(Obscured))then return end -- if player is far and sentry is obscured, draw nothing
		if(Obscured)then DetailDraw=false end -- if obscured, at least disable details
		if(State==STATE_BROKEN)then DetailDraw=false PanelDraw=false end -- look incomplete to indicate damage, save on gpu comp too
		---
		self:DrawModel()
		---

		if DetailDraw then
			if Closeness < 20000 and State == STATE_ON then
				local DisplayAng = SelfAng:GetCopy()
				DisplayAng:RotateAroundAxis(DisplayAng:Right(), 0)
				DisplayAng:RotateAroundAxis(DisplayAng:Up(), -90)
				DisplayAng:RotateAroundAxis(DisplayAng:Forward(), 90)
				local Opacity = math.random(50, 150)
				local ProFrac = self:GetProgress() / self.MaxGas
				local R, G, B = JMod.GoodBadColor(ProFrac)
				local ElecFrac = self:GetElectricity() / self.MaxElectricity
				local ER, EG, EB = JMod.GoodBadColor(ElecFrac)
				cam.Start3D2D(SelfPos + Up * 5 - Forward * 20 - Right, DisplayAng, .1)
				surface.SetDrawColor(10, 10, 10, Opacity + 50)
				surface.DrawRect(90,  0, 128, 128)
				JMod.StandardRankDisplay(Grade, 152, 68, 118, Opacity + 50)
				draw.SimpleTextOutlined("PROGRESS", "JMod-Display", 0, 0, Color(255, 255, 255, Opacity), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, Opacity))
				draw.SimpleTextOutlined(tostring(math.Round(ProFrac * 100)) .. "%", "JMod-Display", 0, 30, Color(R, G, B, Opacity), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, Opacity))
				draw.SimpleTextOutlined("POWER", "JMod-Display", 0, 60, Color(255, 255, 255, Opacity), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, Opacity))
				draw.SimpleTextOutlined(tostring(math.Round(ElecFrac * 100)) .. "%", "JMod-Display", 0, 90, Color(ER, EG, EB, Opacity), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, Opacity))
				cam.End3D2D()
			end
		end
	end
	language.Add("ent_jack_gmod_ezgas_condenser", "EZ Gas Compressor")
end
