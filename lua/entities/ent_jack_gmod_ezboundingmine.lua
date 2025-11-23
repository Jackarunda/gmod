-- Jackarunda 2021
AddCSLuaFile()
ENT.Type = "anim"
ENT.Author = "Jackarunda, TheOnly8Z"
ENT.Category = "JMod - EZ Explosives"
ENT.PrintName = "EZ Mini Bounding Mine"
ENT.NoSitAllowed = true
ENT.Spawnable = true
ENT.AdminSpawnable = true
---
ENT.EZscannerDanger = true
ENT.JModEZstorable = true
ENT.JModPreferredCarryAngles = Angle(0, 0, 0)

ENT.UsableMats = {MAT_DIRT, MAT_FOLIAGE, MAT_SAND, MAT_SLOSH, MAT_GRASS, MAT_SNOW}

ENT.BlacklistedNPCs = {"bullseye_strider_focus", "npc_turret_floor", "npc_turret_ceiling", "npc_turret_ground"}

ENT.WhitelistedNPCs = {"npc_rollermine"}

---
function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "State")
end

---
if SERVER then
	function ENT:SpawnFunction(ply, tr)
		local SpawnPos = tr.HitPos + tr.HitNormal * 20
		local ent = ents.Create(self.ClassName)
		ent:SetAngles(Angle(0, 0, 0))
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
		self:SetModel("models/jmod/explosives/mines/boundingmine/bounding_mine.mdl")
		--self:SetModelScale(1.5)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:DrawShadow(true)
		self:SetUseType(SIMPLE_USE)
		self:GetPhysicsObject():SetMass(10)

		---
		timer.Simple(.01, function()
			self:GetPhysicsObject():SetMass(10)
			self:GetPhysicsObject():Wake()
		end)

		---
		self:SetState(JMod.EZ_STATE_OFF)

		if istable(WireLib) then
			self.Inputs = WireLib.CreateInputs(self, {"Detonate", "Arm"}, {"This will directly detonate the bomb", "Arms bomb when > 0"})

			self.Outputs = WireLib.CreateOutputs(self, {"State"}, {"1 is armed \n 0 is not \n -1 is broken \n 2 is arming"})
		end
	end

	if (iname == "Detonate") and (self:GetState() == STATE_ARMED) and (value > 0) then
		self:Detonate()
	elseif iname == "Arm" and value > 0 then
		self:SetState(STATE_ARMING)
	end

	function ENT:Bury(activator, pos, dir)
		local Tr = util.QuickTrace(pos or activator:GetShootPos(), dir or activator:GetAimVector() * 100, {activator, self})

		if Tr.Hit and table.HasValue(self.UsableMats, Tr.MatType) and IsValid(Tr.Entity:GetPhysicsObject()) then
			local Ang = Tr.HitNormal:Angle()
			Ang:RotateAroundAxis(Ang:Right(), -90)
			local Pos = Tr.HitPos - Tr.HitNormal * 10
			self:SetAngles(Ang)
			self:SetPos(Pos)
			--self:GetPhysicsObject():SetVelocity(Vector(0, 0, 0))
			constraint.Weld(self, Tr.Entity, 0, 0, 50000, true)
			local Fff = EffectData()
			Fff:SetOrigin(Tr.HitPos)
			Fff:SetNormal(Tr.HitNormal)
			Fff:SetScale(1)
			util.Effect("eff_jack_sminebury", Fff, true, true)
			self:EmitSound("snd_jack_pinpull.ogg")
			activator:EmitSound("Dirt.BulletImpact")
			self.ShootDir = Tr.HitNormal
			self:DrawShadow(false)
			self:Arm(activator)
			--JackaGenericUseEffect(activator)
		end
	end

	function ENT:PhysicsCollide(data, physobj)
		if data.DeltaTime > 0.2 then
			if data.Speed > 25 then
				print(physobj:HasGameFlag(FVPHYSICS_WAS_THROWN))
				if (physobj:HasGameFlag(FVPHYSICS_WAS_THROWN)) then
					timer.Simple(0.1, function()
						if IsValid(self) then
							self:Bury(nil, data.HitPos, data.HitNormal)
						end
					end)
				elseif (self:GetState() == JMod.EZ_STATE_ARMED) and (math.random(1, 5) == 3) then
					self:Detonate()
				else
					self:EmitSound("Weapon.ImpactHard")
				end
			end
		end
	end

	function ENT:OnTakeDamage(dmginfo)
		self:TakePhysicsDamage(dmginfo)
		local Pos, State = self:GetPos(), self:GetState()

		if JMod.LinCh(dmginfo:GetDamage(), 30, 100) then
			if State == JMod.EZ_STATE_ARMED then
				self:Detonate()
			elseif not (State == JMod.EZ_STATE_BROKEN) then
				sound.Play("Metal_Box.Break", Pos)
				self:SetState(JMod.EZ_STATE_BROKEN)
				SafeRemoveEntityDelayed(self, 10)
			end
		end
	end

	function ENT:Use(activator)
		local State = self:GetState()
		if State < 0 then return end
		local Alt = JMod.IsAltUsing(activator)

		if State == JMod.EZ_STATE_OFF then
			if Alt then
				JMod.SetEZowner(self, activator)
				self:Bury(activator)
				JMod.Hint(activator, "mine friends")
			else
				activator:PickupObject(self)
				JMod.Hint(activator, "arm boundingmine")
			end
		else
			self:EmitSound("snd_jack_minearm.ogg", 60, 70)
			self:SetState(JMod.EZ_STATE_OFF)
			JMod.SetEZowner(self, activator)
			self:DrawShadow(true)
			constraint.RemoveAll(self)
			self:SetPos(self:GetPos() + self:GetUp() * 40)
			activator:PickupObject(self)
		end
	end

	function ENT:Boom()
		local SelfPos = self:LocalToWorld(self:OBBCenter())
		local Up = Vector(0, 0, 1)
		local EffectType = 1
		local Traec = util.QuickTrace(self:GetPos(), Vector(0, 0, -5), self)

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

		for key, playa in pairs(ents.FindInSphere(SelfPos, 50)) do
			local Clayus = playa:GetClass()

			if playa:IsPlayer() or playa:IsNPC() or (Clayuss == "prop_vehicle_jeep") or (Clayuss == "prop_vehicle_jeep") or (Clayus == "prop_vehicle_airboat") then
				playa:SetVelocity(playa:GetVelocity() + Up * 200)
			end
		end

		util.BlastDamage(self, JMod.GetEZowner(self), SelfPos, 120 * JMod.Config.Explosives.Mine.Power, 30 * JMod.Config.Explosives.Mine.Power)
		util.ScreenShake(SelfPos, 99999, 99999, 1, 500)
		self:EmitSound("snd_jack_fragsplodeclose.ogg", 90, 100)
		JMod.Sploom(self.EZowner, SelfPos, math.random(10, 20))
		JMod.FragSplosion(self, SelfPos, 3000, 50 * JMod.Config.Explosives.Mine.Power, 3000, JMod.GetEZowner(self), nil, nil, 10)
		self:Remove()
	end

	function ENT:Detonate()
		if self.Exploded then return end
		self.Exploded = true

		local Tr = util.QuickTrace(self:LocalToWorld(self:OBBCenter()) + self:GetUp() * 20, -self:GetUp() * 40, {self, toucher})

		if Tr.Hit then
			timer.Simple(.1, function()
				util.Decal("Scorch", Tr.HitPos + Tr.HitNormal, Tr.HitPos - Tr.HitNormal)
			end)
		end

		constraint.RemoveAll(self)

		if Tr.Hit then
			self:SetPos(self:GetPos() + Tr.HitNormal * 11)
		end

		self:GetPhysicsObject():ApplyForceCenter(self:GetUp() * 3000)
		local Poof = EffectData()

		if Tr.Hit then
			Poof:SetOrigin(Tr.HitPos)
			Poof:SetNormal(Tr.HitNormal)
		else
			Poof:SetOrigin(self:GetPos())
			Poof:SetNormal(Vector(0, 0, 1))
		end

		Poof:SetScale(1)
		util.Effect("eff_jack_sminepop", Poof, true, true)
		--util.SpriteTrail(self,0,Color(50,50,50,255),false,8,20,.5,1/(15+1)*0.5,"trails/smoke.vmt")
		self:EmitSound("snd_jack_sminepop.ogg")
		sound.Play("snd_jack_sminepop.ogg", self:GetPos(), 120, 80)

		timer.Simple(math.Rand(.4, .5), function()
			if IsValid(self) then
				self:Boom()
			end
		end)

		Tr = util.QuickTrace(self:GetPos() + self:GetUp() * 20, self:GetUp() * 30, {self})

		if Tr.Hit then
			if Tr.Entity:IsPlayer() or Tr.Entity:IsNPC() then
				timer.Simple(.5, function()
					if IsValid(Tr.Entity) and IsValid(self) then
						local Bam = DamageInfo()
						Bam:SetDamage(100)
						Bam:SetDamageType(DMG_BLAST)
						Bam:SetDamageForce(self:GetUp() * 1000)
						Bam:SetDamagePosition(Tr.HitPos)
						Bam:SetAttacker(self)
						Bam:SetInflictor(self)
						Tr.Entity:TakeDamageInfo(Bam)
					end
				end)
			end
		end
	end

	function ENT:Arm(armer)
		local State = self:GetState()
		if State ~= JMod.EZ_STATE_OFF then return end
		JMod.SetEZowner(self, armer)
		self:SetState(JMod.EZ_STATE_ARMING)
		self:SetBodygroup(2, 1)
		self:EmitSound("snd_jack_minearm.ogg", 60, 110)

		timer.Simple(3, function()
			if IsValid(self) then
				if self:GetState() == JMod.EZ_STATE_ARMING then
					self:SetState(JMod.EZ_STATE_ARMED)
					self:DrawShadow(false)
				end
			end
		end)
	end

	function ENT:Think()
		local State, Time = self:GetState(), CurTime()

		if State == JMod.EZ_STATE_ARMED then
			for k, targ in pairs(ents.FindInSphere(self:GetPos(), 100)) do
				if not (targ == self) and (targ:IsPlayer() or targ:IsNPC() or targ:IsVehicle()) then
					if JMod.ShouldAttack(self, targ) and JMod.ClearLoS(self, targ, false, 5) then
						self:SetState(JMod.EZ_STATE_WARNING)
						sound.Play("snds_jack_gmod/mine_warn.ogg", self:GetPos() + Vector(0, 0, 30), 60, 100)

						timer.Simple(math.Rand(.15, .4) * JMod.Config.Explosives.Mine.Delay, function()
							if IsValid(self) then
								if self:GetState() == JMod.EZ_STATE_WARNING then
									self:Detonate()
								end
							end
						end)
					end
				end
			end

			self:NextThink(Time + .3)

			return true
		end
	end

	function ENT:OnRemove()
	end

elseif CLIENT then
	function ENT:Initialize()
	end

	--
	local GlowSprite = Material("sprites/mat_jack_basicglow")

	function ENT:Draw()
		self:DrawModel()
		local State, Vary = self:GetState(), math.sin(CurTime() * 50) / 2 + .5
		local pos = self:GetPos() + self:GetUp() * 11 + self:GetRight() * 1.5

		if State == JMod.EZ_STATE_ARMING then
			render.SetMaterial(GlowSprite)
			render.DrawSprite(pos, 20, 20, Color(255, 0, 0))
			render.DrawSprite(pos, 10, 10, Color(255, 255, 255))
		elseif State == JMod.EZ_STATE_WARNING then
			render.SetMaterial(GlowSprite)
			render.DrawSprite(pos, 30 * Vary, 30 * Vary, Color(255, 0, 0))
			render.DrawSprite(pos, 15 * Vary, 15 * Vary, Color(255, 255, 255))
		end
	end

	language.Add("ent_jack_gmod_ezboundingmine", "EZ Bounding Mine")
end
