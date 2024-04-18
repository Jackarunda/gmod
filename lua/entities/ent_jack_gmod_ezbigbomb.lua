-- Jackarunda 2021
AddCSLuaFile()
ENT.Type = "anim"
ENT.Author = "Jackarunda"
ENT.Category = "JMod - EZ Explosives"
ENT.Information = "glhfggwpezpznore"
ENT.PrintName = "EZ Big Bomb"
ENT.Spawnable = true
ENT.AdminSpawnable = true
---
ENT.JModPreferredCarryAngles = Angle(90, 0, 0)
ENT.EZRackOffset = Vector(0, 0, 30)
ENT.EZRackAngles = Angle(0, 0, 90)
ENT.EZbombBaySize = 33
ENT.EZguidable = true
---
local STATE_BROKEN, STATE_OFF, STATE_ARMED = -1, 0, 1

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "State")
	self:NetworkVar("Bool", 0, "Guided")
end

---
if SERVER then
	function ENT:SpawnFunction(ply, tr)
		local SpawnPos = tr.HitPos + tr.HitNormal * 40
		local ent = ents.Create(self.ClassName)
		ent:SetAngles(Angle(180, 0, 0))
		ent:SetPos(SpawnPos)
		JMod.SetEZowner(ent, ply)
		ent:Spawn()
		ent:Activate()
		--local effectdata=EffectData()
		--effectdata:SetEntity(ent)
		--util.Effect("propspawn",effectdata)

		return ent
	end

	function ENT:Initialize()
		self:SetModel("models/hunter/blocks/cube05x4x05.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:DrawShadow(true)
		self:SetUseType(SIMPLE_USE)

		---
		timer.Simple(.01, function()
			self:GetPhysicsObject():SetMass(300)
			self:GetPhysicsObject():Wake()
			self:GetPhysicsObject():EnableDrag(false)
		end)

		---
		self:SetState(STATE_OFF)
		self.LastUse = 0
		self.DetTime = 0

		if istable(WireLib) then
			self.Inputs = WireLib.CreateInputs(self, {"Detonate", "Arm"}, {"Directly detonates the bomb", "Arms bomb when > 0"})

			self.Outputs = WireLib.CreateOutputs(self, {"State", "Guided"}, {"-1 broken \n 0 off \n 1 armed", "True when guided"})
		end
	end

	function ENT:TriggerInput(iname, value)
		if (iname == "Detonate") and (value > 0) then
			self:Detonate()
		elseif iname == "Arm" and value > 0 then
			self:SetState(STATE_ARMED)
		end
	end

	function ENT:PhysicsCollide(data, physobj)
		if not IsValid(self) then return end

		if data.DeltaTime > 0.2 then
			if data.Speed > 50 then
				self:EmitSound("Canister.ImpactHard")
			end

			if (data.Speed > 1000) and (self:GetState() == STATE_ARMED) then
				self:Detonate()

				return
			end

			if data.Speed > 2000 then
				self:Break()
			end
		end
	end

	function ENT:Break()
		if self:GetState() == STATE_BROKEN then return end
		self:SetState(STATE_BROKEN)
		self:EmitSound("snd_jack_turretbreak.wav", 70, math.random(80, 120))

		for i = 1, 20 do
			JMod.DamageSpark(self)
		end

		SafeRemoveEntityDelayed(self, 10)
	end

	function ENT:OnTakeDamage(dmginfo)
		if IsValid(self.DropOwner) then
			local Att = dmginfo:GetAttacker()
			if IsValid(Att) and (self.DropOwner == Att) then return end
		end

		self:TakePhysicsDamage(dmginfo)

		if JMod.LinCh(dmginfo:GetDamage(), 80, 200) then
			JMod.SetEZowner(self, dmginfo:GetAttacker())
			self:Detonate()
		end
	end

	function ENT:Use(activator)
		local State, Time = self:GetState(), CurTime()
		if State < 0 then return end

		if State == STATE_OFF then
			JMod.SetEZowner(self, activator)

			if Time - self.LastUse < .2 then
				self:SetState(STATE_ARMED)
				self:EmitSound("snds_jack_gmod/bomb_arm.wav", 70, 100)
				self.EZdroppableBombArmedTime = CurTime()
				JMod.Hint(activator, "impactdet")
			else
				JMod.Hint(activator, "double tap to arm")
			end

			self.LastUse = Time
		elseif State == STATE_ARMED then
			JMod.SetEZowner(self, activator)

			if Time - self.LastUse < .2 then
				self:SetState(STATE_OFF)
				self:EmitSound("snds_jack_gmod/bomb_disarm.wav", 70, 100)
				self.EZdroppableBombArmedTime = nil
			else
				JMod.Hint(activator, "double tap to disarm")
			end

			self.LastUse = Time
		end
	end

	function ENT:Detonate()
		if self.Exploded then return end
		self.Exploded = true
		local SelfPos, Att = self:GetPos() + Vector(0, 0, 100), JMod.GetEZowner(self)
		---
		util.ScreenShake(SelfPos, 1000, 3, 2, 8000)
		local Eff = "cloudmaker_ground"

		if not util.QuickTrace(SelfPos, Vector(0, 0, -300), {self}).HitWorld then
			Eff = "cloudmaker_air"
		end

		for i = 1, 10 do
			sound.Play("ambient/explosions/explode_" .. math.random(1, 9) .. ".wav", SelfPos + VectorRand() * 1000, 160, math.random(80, 110))
		end

		---
		for k, ply in player.Iterator() do
			local Dist = ply:GetPos():Distance(SelfPos)

			if (Dist > 500) and (Dist < 8000) then
				timer.Simple(Dist / 6000, function()
					ply:EmitSound("snds_jack_gmod/big_bomb_far.wav", 55, 110)
					sound.Play("ambient/explosions/explode_" .. math.random(1, 9) .. ".wav", ply:GetPos(), 60, 70)
					util.ScreenShake(ply:GetPos(), 1000, 3, 2, 100)
				end)
			end
		end

		---
		util.BlastDamage(game.GetWorld(), Att, SelfPos + Vector(0, 0, 300), 1600, 150)

		timer.Simple(.25, function()
			util.BlastDamage(game.GetWorld(), Att, SelfPos, 3200, 150)
		end)

		for k, ent in pairs(ents.FindInSphere(SelfPos, 1000)) do
			if ent:GetClass() == "npc_helicopter" then
				ent:Fire("selfdestruct", "", math.Rand(0, 2))
			end
		end

		---
		JMod.WreckBuildings(self, SelfPos, 10)
		JMod.BlastDoors(self, SelfPos, 10)

		---
		timer.Simple(.2, function()
			local Tr = util.QuickTrace(SelfPos + Vector(0, 0, 100), Vector(0, 0, -400))

			if Tr.Hit then
				util.Decal("GiantScorch", Tr.HitPos + Tr.HitNormal, Tr.HitPos - Tr.HitNormal)
			end
		end)

		---
		JMod.FragSplosion(self, SelfPos, 20000, 400, 8000, JMod.GetEZowner(self))
		---
		self:Remove()

		timer.Simple(.1, function()
			ParticleEffect(Eff, SelfPos, Angle(0, 0, 0))
		end)
	end

	function ENT:OnRemove()
	end

	--
	function ENT:EZdetonateOverride(detonator)
		self:Detonate()
	end

	function ENT:Think()
		local Phys, UseAeroDrag = self:GetPhysicsObject(), true

		if istable(WireLib) then
			WireLib.TriggerOutput(self, "State", self:GetState())
			WireLib.TriggerOutput(self, "Guided", self:GetGuided())
		end

		--if((self:GetState()==STATE_ARMED)and(self:GetGuided())and not(constraint.HasConstraints(self)))then
		--for k,designator in pairs(ents.FindByClass("wep_jack_gmod_ezdesignator"))do
		--if((designator:GetLasing())and(designator.EZowner)and(JMod.ShouldAllowControl(self,designator.EZowner)))then
		--[[
					local TargPos,SelfPos=ents.FindByClass("npc_*")[1]:GetPos(),self:GetPos()--designator.EZowner:GetEyeTrace().HitPos
					local TargVec=TargPos-SelfPos
					local Dist,Dir,Vel=TargVec:Length(),TargVec:GetNormalized(),Phys:GetVelocity()
					local Speed=Vel:Length()
					if(Speed<=0)then return end
					local ETA=Dist/Speed
					jprint(ETA)
					TargPos=TargPos--Vel*ETA/2
					JMod.Sploom(self,TargPos,1)
					JMod.AeroGuide(self,-self:GetRight(),TargPos,1,1,.2,10)
					--]]
		--end
		--end
		--end
		JMod.AeroDrag(self, -self:GetRight(), 4)
		self:NextThink(CurTime() + .1)

		return true
	end
elseif CLIENT then
	function ENT:Initialize()
		--[[self.Mdl = ClientsideModel("models/jmod/mk82_gbu.mdl")
		self.Mdl:SetModelScale(1.5, 0)
		self.Mdl:SetPos(self:GetPos())
		self.Mdl:SetParent(self)
		self.Mdl:SetNoDraw(true)--]]
		self.Mdl = JMod.MakeModel(self, "models/jmod/mk82_gbu.mdl", nil, 1.5)
		self.Guided = false
	end

	function ENT:Think()
		if (not self.Guided) and self:GetGuided() then
			self.Guided = true
			self.Mdl:SetBodygroup(0, 1)
		end
	end

	function ENT:Draw()
		local Pos, Ang = self:GetPos(), self:GetAngles()
		Ang:RotateAroundAxis(Ang:Up(), 90)
		--self:DrawModel()
		JMod.RenderModel(self.Mdl, Pos + Ang:Up() * -15, Ang)
	end

	function ENT:OnRemove()
		if self.Mdl then
			self.Mdl:Remove()
		end
	end

	language.Add("ent_jack_gmod_ezbigbomb", "EZ Big Bomb")
end
