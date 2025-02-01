-- Jackarunda 2021
AddCSLuaFile()
ENT.Type = "anim"
ENT.Author = "Jackarunda"
ENT.Category = "JMod - EZ Explosives"
ENT.Information = "glhfggwpezpznore"
ENT.PrintName = "EZ Torpedo"
ENT.Spawnable = true
ENT.AdminSpawnable = true
---
ENT.JModPreferredCarryAngles = Angle(0, 0, 0)
ENT.EZbombBaySize = 50
ENT.EZrackOffset = Vector(0, 0, 8)
ENT.EZrackAngles = Angle(0, 0, 0)
---
local STATE_BROKEN, STATE_OFF, STATE_ARMED, STATE_LAUNCHED = -1, 0, 1, 2

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "State")
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
		self:SetModel("models/props_phx/torpedo.mdl")
		self:SetSubMaterial(0, "jhoenix_storms/mat_jack_eztorpedo")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:DrawShadow(true)
		self:SetUseType(SIMPLE_USE)

		---
		timer.Simple(.01, function()
			self:GetPhysicsObject():SetMass(400)
			self:GetPhysicsObject():Wake()
			self:GetPhysicsObject():EnableDrag(false)
		end)

		---
		self:SetState(STATE_OFF)
		self.NextDet = 0
		self.FuelLeft = 100

		if istable(WireLib) then
			self.Inputs = WireLib.CreateInputs(self, {"Detonate", "Arm", "Launch"}, {"Directly detonates rocket", "Arms rocket", "Launches rocket"})

			self.Outputs = WireLib.CreateOutputs(self, {"State", "Fuel"}, {"-1 broken \n 0 off \n 1 armed \n 2 launched", "Fuel left in the tank"})
		end
	end

	function ENT:TriggerInput(iname, value)
		if iname == "Detonate" and value > 0 then
			self:Detonate()
		elseif iname == "Arm" and value > 0 then
			self:SetState(STATE_ARMED)
		elseif iname == "Arm" and value == 0 then
			self:SetState(STATE_OFF)
		elseif iname == "Launch" and value > 0 then
			self:SetState(STATE_ARMED)
			self:Launch()
		end
	end

	function ENT:Use(activator)
		local State = self:GetState()
		if State < 0 then return end
		local Alt = JMod.IsAltUsing(activator)

		if State == STATE_OFF then
			if Alt then
				JMod.SetEZowner(self, activator)
				self:EmitSound("snds_jack_gmod/bomb_arm.ogg", 60, 120)
				self:SetState(STATE_ARMED)
				self.EZlaunchableWeaponArmedTime = CurTime()
				JMod.Hint(activator, "launch")
			end
		elseif State == STATE_ARMED then
			self:EmitSound("snds_jack_gmod/bomb_disarm.ogg", 60, 120)
			self:SetState(STATE_OFF)
			JMod.SetEZowner(self, activator)
			self.EZlaunchableWeaponArmedTime = nil
		end
	end

	function ENT:PhysicsCollide(data, physobj)
		if not IsValid(self) then return end
		--local RealSpeed = math.abs(data.OurOldVelocity:Length() - data.TheirOldVelocity:Length())

		if data.DeltaTime > 0.2 then
			--jprint(RealSpeed)
			if data.Speed > 50 then
				self:EmitSound("Canister.ImpactHard")
			end

			local DetSpd = 400

			if (data.Speed > DetSpd) and (self:GetState() >= STATE_ARMED) then
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
		self:EmitSound("snd_jack_turretbreak.ogg", 70, math.random(80, 120))

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

		if JMod.LinCh(dmginfo:GetDamage(), 60, 120) then
			if math.random(1, 3) == 1 then
				self:Break()
			else
				JMod.SetEZowner(self, dmginfo:GetAttacker())
				self:Detonate()
			end
		end
	end

	function ENT:InWater()
		return bit.band(util.PointContents(self:LocalToWorld(self:OBBCenter()) - Vector(0, 0, 5)), CONTENTS_WATER) == CONTENTS_WATER
	end

	function ENT:Detonate()
		if self.NextDet > CurTime() then return end
		if self.Exploded then return end
		self.Exploded = true
		sound.Play("snds_jack_gmod/mine_warn.ogg", self:GetPos() + Vector(0, 0, 30), 60, 100)

		local SelfPos, Att = self:GetPos() + Vector(0, 0, 50), JMod.GetEZowner(self)
		---
		if not self:InWater() then
			local Eff = "500lb_ground"
			if not util.QuickTrace(SelfPos, Vector(0, 0, -300), {self}).HitWorld then
				Eff = "500lb_air"
			end
			for k, ply in player.Iterator() do
				local Dist = ply:GetPos():Distance(SelfPos)
	
				if (Dist > 250) and (Dist < 5000) then
					timer.Simple(Dist / 6000, function()
						ply:EmitSound("snds_jack_gmod/big_bomb_far.ogg", 55, 110)
						sound.Play("ambient/explosions/explode_" .. math.random(1, 9) .. ".wav", ply:GetPos(), 60, 70)
						util.ScreenShake(ply:GetPos(), 1000, 3, 1, 100)
					end)
				end
			end
			ParticleEffect(Eff, SelfPos, Angle(0, 0, 0))
			sound.Play("ambient/explosions/explode_" .. math.random(1, 9) .. ".wav", SelfPos, 80, 100)
		else
			local splad = EffectData()
			splad:SetOrigin(SelfPos)
			splad:SetScale(3)
			splad:SetEntity(self)
			util.Effect("eff_jack_gmod_watersplode", splad, true, true)
			
			for i = 1, 3 do
				sound.Play("ambient/water/water_splash" .. math.random(1, 3) .. ".wav", SelfPos, 80, 100)
				sound.Play("ambient/water/water_splash" .. math.random(1, 3) .. ".wav", SelfPos, 160, 50)
				sound.Play("ambient/explosions/explode_" .. math.random(1, 9) .. ".wav", SelfPos, 80, math.random(80, 110))
			end
		end
		---
		util.ScreenShake(SelfPos, 1000, 3, 3, 2000)

		---
		timer.Simple(.1, function()
			util.BlastDamage(game.GetWorld(), Att, SelfPos, 800, 200)
			util.BlastDamage(game.GetWorld(), Att, SelfPos - Vector(0, 0, 120), 800, 200)
		end)

		---
		JMod.WreckBuildings(self, SelfPos, 8)
		---
		self:Remove()
	end

	function ENT:OnRemove()
	end

	--
	function ENT:Launch()
		if self:GetState() ~= STATE_ARMED then return end
		self:SetState(STATE_LAUNCHED)
		local Phys = self:GetPhysicsObject()
		constraint.RemoveAll(self)
		Phys:EnableMotion(true)
		Phys:Wake()
		self.NextDet = CurTime() + 1
	end

	function ENT:EZdetonateOverride(detonator)
		self:Detonate()
	end

	function ENT:Think()
		if istable(WireLib) then
			WireLib.TriggerOutput(self, "State", self:GetState())
			WireLib.TriggerOutput(self, "Fuel", self.FuelLeft)
		end
		local SelfPos = self:LocalToWorld(self:OBBCenter())
		local Forward = self:GetForward()

		local Phys = self:GetPhysicsObject()
		JMod.AeroDrag(self, Forward, .75)

		local InWater = self:InWater()
		if self:GetState() == STATE_LAUNCHED then
			if (self.FuelLeft > 0) then
				if (InWater) then
					local OurVel = Phys:GetVelocity()
					local CounterPush = 0
					if OurVel.z > 0 then
						CounterPush = -OurVel.z * .8
					end
					Phys:ApplyForceCenter(Forward * 40000 + Vector(0, 0, CounterPush))
					---
					local StartPos = SelfPos - Forward * 80 + Vector(0, 0, 100)
					local WakeTr = util.TraceLine({
						start = StartPos, 
						endpos = StartPos + Vector(0, 0, -120), 
						filter = self,
						mask = MASK_WATER
					})

					if WakeTr.Hit and (WakeTr.Fraction > 0) then
						local Eff = EffectData()
						Eff:SetOrigin(WakeTr.HitPos)
						Eff:SetNormal(self:GetUp())
						Eff:SetScale(6)
						util.Effect("WaterSplash", Eff, true, true)
					end
				end
				self.FuelLeft = self.FuelLeft - .2
			else
				self:Detonate()
			end
		end

		JMod.AeroDrag(self, Forward, 4)

		self:NextThink(CurTime() + .05)

		return true
	end
elseif CLIENT then
	function ENT:Initialize()
		self.Mdl = JMod.MakeModel(self, "models/xqm/propeller1.mdl", nil, 1)
		self.Spin = 0
	end

	function ENT:Think()
		self.Spin = self.Spin - 5000 * FrameTime()
	end

	--
	--local WakeSprite = Material("cable/smoke")

	function ENT:Draw()
		local Pos, Ang, Dir = self:LocalToWorld(self:OBBCenter()), self:GetAngles(), self:GetForward()
		Ang:RotateAroundAxis(Ang:Up(), 180)
		self:DrawModel()

		if self:GetState() == STATE_LAUNCHED then
			Ang:RotateAroundAxis(Ang:Forward(), self.Spin)
		end
		JMod.RenderModel(self.Mdl, Pos - Dir * 85, Ang, Vector(.7, .7, .7), Vector(.5, .5, .5))
	end

	language.Add("ent_jack_gmod_eztorpedo", "EZ Torpedo")
end
