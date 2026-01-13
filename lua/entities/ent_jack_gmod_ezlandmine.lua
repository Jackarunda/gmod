-- Jackarunda 2021
AddCSLuaFile()
ENT.Type = "anim"
ENT.Author = "Jackarunda"
ENT.Category = "JMod - EZ Explosives"
ENT.Information = "glhfggwpezpznore"
ENT.PrintName = "EZ Land Mine"
ENT.NoSitAllowed = true
ENT.Spawnable = true
ENT.AdminSpawnable = true
---
ENT.JModGUIcolorable = true
ENT.JModEZstorable = true
ENT.EZscannerDanger = true
ENT.JModPreferredCarryAngles = Angle(0, 0, 0)

ENT.BlacklistedNPCs = {"bullseye_strider_focus", "npc_turret_floor", "npc_turret_ceiling", "npc_turret_ground"}

ENT.WhitelistedNPCs = {"npc_rollermine"}

ENT.TriggerRadius = 100
ENT.TriggerRadiusSqr = ENT.TriggerRadius * ENT.TriggerRadius

---
local STATE_BROKEN, STATE_OFF, STATE_ARMING, STATE_ARMED, STATE_WARNING = -1, 0, 1, 2, 3

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "State")
end

-- Custom state setter that also updates WireLib
function ENT:UpdateState(state)
	self:SetState(state)
	if SERVER and istable(WireLib) then
		WireLib.TriggerOutput(self, "State", state)
	end
end

---
if SERVER then
	function ENT:SpawnFunction(ply, tr)
		local SpawnPos = tr.HitPos + tr.HitNormal * 40
		local ent = ents.Create(self.ClassName)
		ent:SetAngles(Angle(0, 0, 0))
		ent:SetPos(SpawnPos)
		JMod.SetEZowner(ent, ply)
		ent:Spawn()
		ent:Activate()

		return ent
	end

	function ENT:Initialize()
		self:SetModel("models/props_pipes/pipe02_connector01.mdl")
		self:SetMaterial("models/jacky_camouflage/digi2")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:DrawShadow(true)
		self:SetUseType(SIMPLE_USE)
		self:GetPhysicsObject():SetMass(20)

		---
		timer.Simple(.01, function()
			if not IsValid(self) then return end
			self:GetPhysicsObject():SetMass(20)
			self:GetPhysicsObject():Wake()
		end)

		---
		self:UpdateState(STATE_OFF)

		if istable(WireLib) then
			self.Inputs = WireLib.CreateInputs(self, {"Detonate", "Arm"}, {"This will directly detonate the bomb", "Arms bomb when > 0"})

			self.Outputs = WireLib.CreateOutputs(self, {"State"}, {"-1 is broken \n 0 is unarmed \n 1 is arming \n 2 is armed \n 3 is warning"})
		end

		---
		self.StillTicks = 0
		
		-- Set up trigger bounds with bloat to extend detection radius
		self:UseTriggerBounds(true, self.TriggerRadius)

		if self.AutoArm then
			self:NextThink(CurTime() + math.Rand(.1, 1))
		end
	end

	function ENT:EnableTargetDetection()
		self:SetTrigger(true)
	end

	function ENT:DisableTargetDetection()
		self:SetTrigger(false)
	end

	function ENT:Touch(ent)
		-- Use continuous Touch instead of StartTouch so entities entering
		-- from corners (outside spherical radius) still trigger when they move closer
		if self:GetState() ~= STATE_ARMED then return end
		if ent == self then return end
		-- Only react to players, NPCs, and vehicles
		if not (ent:IsPlayer() or ent:IsNPC() or ent:IsVehicle()) then return end
		
		-- Check distance is within trigger radius and target is valid
		local SelfPos = self:GetPos()
		local dist = ent:GetPos():DistToSqr(SelfPos)
		if dist <= self.TriggerRadiusSqr and JMod.ShouldAttack(self, ent) and JMod.ClearLoS(self, ent) then
			self:TriggerWarning()
		end
	end

	function ENT:TriggerWarning()
		if self:GetState() ~= STATE_ARMED then return end
		
		local SelfPos = self:GetPos()
		self:UpdateState(STATE_WARNING)
		sound.Play("snds_jack_gmod/mine_warn.ogg", SelfPos + Vector(0, 0, 30), 60, 100)

		timer.Simple(math.Rand(.05, .3) * JMod.Config.Explosives.Mine.Delay, function()
			if IsValid(self) then
				if self:GetState() == STATE_WARNING then
					self:Detonate()
				end
			end
		end)
	end

	function ENT:TriggerInput(iname, value)
		if iname == "Detonate" and value > 0 then
			self:Detonate()
		elseif iname == "Arm" and value > 0 then
			self:UpdateState(STATE_ARMED)
			self:EnableTargetDetection()
		end
	end

	function ENT:PhysicsCollide(data, physobj)
		if data.DeltaTime > 0.2 then
			if data.Speed > 25 then
				if (self:GetState() == STATE_ARMED) and (IsValid(data.HitEntity) and JMod.ShouldAttack(self, data.HitEntity)) then
					self:Detonate()
				else
					self:EmitSound("Weapon.ImpactHard")
				end
			end
		end
	end

	function ENT:OnTakeDamage(dmginfo)
		self:TakePhysicsDamage(dmginfo)

		if JMod.LinCh(dmginfo:GetDamage(), 10, 50) then
			local Pos, State = self:GetPos(), self:GetState()

			if State == STATE_ARMED then
				self:Detonate()
			elseif not (State == STATE_BROKEN) then
				sound.Play("Metal_Box.Break", Pos)
				self:UpdateState(STATE_BROKEN)
				SafeRemoveEntityDelayed(self, 10)
			end
		end
	end

	function ENT:Use(activator)
		local State = self:GetState()
		if State < 0 then return end
		self.AutoArm = false
		local Alt = JMod.IsAltUsing(activator)

		if State == STATE_OFF then
			if Alt then
				JMod.SetEZowner(self, activator)
				net.Start("JMod_ColorAndArm")
				net.WriteEntity(self)
				net.Send(activator)
			else
				activator:PickupObject(self)
				JMod.Hint(activator, "arm")
			end
		elseif not (activator.KeyDown and activator:KeyDown(IN_SPEED)) then
			self:EmitSound("snd_jack_minearm.ogg", 60, 70)
			self:UpdateState(STATE_OFF)
			JMod.SetEZowner(self, activator)
			self:DrawShadow(true)
			-- Disable trigger detection when disarmed
			self:DisableTargetDetection()
		end
	end

	function ENT:Detonate()
		if self.Exploded then return end
		self.Exploded = true
		local SelfPos = self:LocalToWorld(self:OBBCenter())
		local Up = Vector(0, 0, 1)
		local EffectType = 1
		local Traec = util.QuickTrace(self:GetPos(), Vector(0, 0, -5), self.Entity)
		local Owner = JMod.GetEZowner(self)

		if Traec.Hit then
			if (Traec.MatType == MAT_DIRT) or (Traec.MatType == MAT_SAND) then
				EffectType = 1
			elseif (Traec.MatType == MAT_CONCRETE) or (Traec.MatType == MAT_TILE) then
				EffectType = 2
			elseif (Traec.MatType == MAT_METAL) or (Traec.MatType == MAT_GRATE) then
				EffectType = 3
			elseif Traec.MatType == MAT_WOOD then
				EffectType = 4
			end
		else
			EffectType = 5
		end

		local plooie = EffectData()
		plooie:SetOrigin(SelfPos)
		plooie:SetScale(1)
		plooie:SetRadius(EffectType)
		plooie:SetNormal(Up)
		util.Effect("eff_jack_minesplode", plooie, true, true)
		util.ScreenShake(SelfPos, 99999, 99999, 1, 500)
		self:EmitSound("snd_jack_fragsplodeclose.ogg", 90, 100)
		JMod.Sploom(Owner, SelfPos, math.random(15, 20) * JMod.Config.Explosives.Mine.Power)
		JMod.FragSplosion(self, SelfPos + Up * 5, 1200, 30 * JMod.Config.Explosives.Mine.Power, 2000, Owner, Up, .75, 10)
		self:Remove()
	end

	function ENT:Arm(armer, autoColor)
		local State = self:GetState()
		if State ~= STATE_OFF then return end
		JMod.Hint(armer, "mine friends")
		JMod.SetEZowner(self, armer)
		self:UpdateState(STATE_ARMING)
		self:EmitSound("snd_jack_minearm.ogg", 60, 110)

		if autoColor then
			local Tr = util.QuickTrace(self:GetPos() + Vector(0, 0, 10), Vector(0, 0, -50), self)

			if Tr.Hit then
				local Info = JMod.HitMatColors[Tr.MatType]

				if Info then
					self:SetColor(Info[1])

					if Info[2] then
						self:SetMaterial(Info[2])
					end
				end
			end
		end

		timer.Simple(3, function()
			if IsValid(self) then
				if self:GetState() == STATE_ARMING then
					self:UpdateState(STATE_ARMED)
					self:DrawShadow(false)
					-- Enable trigger-based target detection
					self:EnableTargetDetection()
					local Tr = util.QuickTrace(self:GetPos() + Vector(0, 0, 20), Vector(0, 0, -40), self)

					if Tr.Hit then
						constraint.Weld(Tr.Entity, self, 0, 0, 5000, false, false)
					end
				end
			end
		end)
	end

	function ENT:Think()
		-- Only needed for AutoArm functionality
		if not self.AutoArm then return end
		
		local Time = CurTime()
		local Phys = self:GetPhysicsObject()
		if not IsValid(Phys) then return end
		
		local Vel = Phys:GetVelocity()

		if Vel:Length() < 1 then
			self.StillTicks = self.StillTicks + 1
		else
			self.StillTicks = 0
		end

		if self.StillTicks > 4 then
			self:Arm(JMod.GetEZowner(self), true)
			self.AutoArm = false -- Stop thinking after armed
			return
		end

		self:NextThink(Time + .5)
		return true
	end

	function ENT:OnRemove()
	end
	--aw fuck you
elseif CLIENT then
	function ENT:Initialize()
	end

	--
	local GlowSprite = Material("sprites/mat_jack_basicglow")

	function ENT:Draw()
		self:DrawModel()
		local State, Vary = self:GetState(), math.sin(CurTime() * 50) / 2 + .5

		if State == STATE_ARMING then
			render.SetMaterial(GlowSprite)
			render.DrawSprite(self:GetPos() + Vector(0, 0, 4), 20, 20, Color(255, 0, 0))
			render.DrawSprite(self:GetPos() + Vector(0, 0, 4), 10, 10, Color(255, 255, 255))
		elseif State == STATE_WARNING then
			render.SetMaterial(GlowSprite)
			render.DrawSprite(self:GetPos() + Vector(0, 0, 4), 30 * Vary, 30 * Vary, Color(255, 0, 0))
			render.DrawSprite(self:GetPos() + Vector(0, 0, 4), 15 * Vary, 15 * Vary, Color(255, 255, 255))
		end
	end

	language.Add("ent_jack_gmod_ezlandmine", "EZ Landmine")
end
