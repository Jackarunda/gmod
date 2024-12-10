-- Jackarunda 2021
AddCSLuaFile()
ENT.Type = "anim"
ENT.Author = "Jackarunda"
ENT.Category = "JMod - EZ Misc."
ENT.Information = "glhfggwpezpznore"
ENT.PrintName = "EZ Road Flare"
ENT.NoSitAllowed = true
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.JModGUIcolorable = true
---
ENT.JModEZstorable = true
ENT.JModPreferredCarryAngles = Angle(0, 0, 0)
---
local STATE_OFF, STATE_BURNIN, STATE_BURNT = 0, 1, 2

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "State")
	self:NetworkVar("Int", 1, "Fuel")
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
		self:SetModel("models/props_junk/flare.mdl")
		self:SetMaterial("models/jflare")
		self:SetModelScale(1.5, 0)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:DrawShadow(true)
		self:SetUseType(SIMPLE_USE)
		self:SetColor(Color(150, 40, 40))
		self:GetPhysicsObject():SetMass(8)

		---
		timer.Simple(.01, function()
			self:GetPhysicsObject():SetMass(8)
			self:GetPhysicsObject():Wake()
		end)

		---
		self.BurnMatApplied = false
		---
		self:SetState(STATE_OFF)
		self:SetFuel(math.random(1500, 2000))

		if istable(WireLib) then
			self.Inputs = WireLib.CreateInputs(self, {"Ignite"}, {"Ignites flare"})
		end
	end

	function ENT:TriggerInput(iname, value)
		if iname == "Ignite" and value > 0 then
			self:Light()
		end
	end

	function ENT:PhysicsCollide(data, physobj)
		if data.DeltaTime > 0.2 then
			if data.Speed > 25 then
				self:EmitSound("Drywall.ImpactHard")

				if self:GetState() == STATE_BURNIN then
					local Dmg = DamageInfo()
					Dmg:SetDamageType(DMG_BURN)
					Dmg:SetAttacker(JMod.GetEZowner(self))
					Dmg:SetInflictor(self)
					Dmg:SetDamage(5)
					Dmg:SetDamagePosition(self:GetPos())
					Dmg:SetDamageForce(Vector(0, 0, 100))

					if data.HitEntity.TakeDamageInfo then
						data.HitEntity:TakeDamageInfo(Dmg)
					end
				end
			end
		end
	end

	function ENT:OnTakeDamage(dmginfo)
		self:TakePhysicsDamage(dmginfo)

		if JMod.LinCh(dmginfo:GetDamage(), 1, 50) then
			local Pos, State = self:GetPos(), self:GetState()

			if dmginfo:IsDamageType(DMG_BURN) then
				self:Light()
			else
				sound.Play("Metal_Box.Break", Pos)
				self:Remove()
			end
		end
	end

	function ENT:Use(activator)
		local State = self:GetState()
		if State == STATE_BURNT then return end
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
		elseif State == STATE_BURNIN then
			activator:PickupObject(self)
		end
	end

	function ENT:Light()
		if self:GetState() == STATE_BURNT then return end
		self:SetState(STATE_BURNIN)
		self.BurnSound = CreateSound(self, "snds_jack_gmod/flareburn.wav")
		self.BurnSound:Play()
		---
		local Spewn = ents.Create("ent_jack_spoon")
		Spewn.Model = "models/jmod/explosives/grenades/sticknade/stick_grenade_cap.mdl"
		Spewn:SetPos(self:GetPos())
		Spewn:Spawn()
		Spewn:GetPhysicsObject():SetVelocity(self:GetPhysicsObject():GetVelocity() + VectorRand() * 250)
	end

	ENT.Arm = ENT.Light -- for compatibility with the ColorAndArm feature

	function ENT:Burnout()
		if self:GetState() == STATE_BURNT then return end
		self:SetState(STATE_BURNT)
		self.BurnSound:Stop()
		self:SetMaterial("models/jflare_burnt")
		SafeRemoveEntityDelayed(self, 20)
	end

	function ENT:Think()
		if self:GetState() == STATE_BURNT then return end
		local State, Fuel, Time, Pos = self:GetState(), self:GetFuel(), CurTime(), self:GetPos()
		local Up, Right, Forward = self:GetUp(), self:GetRight(), self:GetForward()

		if State == STATE_BURNIN then
			if not self.BurnMatApplied and (Fuel < 1000) then
				self.BurnMatApplied = true
				self:SetMaterial("models/jflare_burnt")
			end

			local Num = (Fuel > 150 and 3) or 1

			for i = 1, Num do
				local Fsh = EffectData()
				Fsh:SetOrigin(Pos + Up * 10)
				Fsh:SetScale((Fuel > 150 and .75) or .25)
				Fsh:SetNormal(Up)
				Fsh:SetStart(self:GetVelocity())
				Fsh:SetEntity(self)
				util.Effect("eff_jack_gmod_flareburn", Fsh, true, true)
				-- this requires an attachment to be spec'd on the entity, and i can't be assed
				--ParticleEffect("gf2_fountain_02_regulus_b_main",Pos,self:GetAngles(),self)
			end

			for k, v in pairs(ents.FindInSphere(Pos, 30)) do
				if v.JModHighlyFlammableFunc then
					JMod.SetEZowner(v, self.EZowner)
					local Func = v[v.JModHighlyFlammableFunc]
					Func(v)
				end
			end

			if Fuel <= 0 then
				self:Burnout()

				return
			end

			self:SetFuel(Fuel - 1)
			self:NextThink(Time + .1)

			return true
		end
	end

	function ENT:OnRemove()
		if self.BurnSound then
			self.BurnSound:Stop()
		end
	end
elseif CLIENT then
	function ENT:Initialize()
		self.Cap = JMod.MakeModel(self, "models/jmod/explosives/grenades/sticknade/stick_grenade_cap.mdl", nil, 2)
	end

	function ENT:Think()
		local State, Fuel, Pos, Ang = self:GetState(), self:GetFuel(), self:GetPos(), self:GetAngles()

		if State == STATE_BURNIN then
			local Up, Right, Forward, Mult, Col = Ang:Up(), Ang:Right(), Ang:Forward(), (Fuel > 150 and 1) or .5, self:GetColor()
			local R, G, B = math.Clamp(Col.r + 20, 0, 255), math.Clamp(Col.g + 20, 0, 255), math.Clamp(Col.b + 20, 0, 255)
			local DLight = DynamicLight(self:EntIndex())

			if DLight then
				DLight.Pos = Pos + Up * 10 + Vector(0, 0, 20)
				DLight.r = R
				DLight.g = G
				DLight.b = B
				DLight.Brightness = math.Rand(.5, 1) * Mult ^ 2
				DLight.Size = math.random(1300, 1500) * Mult ^ 2
				DLight.Decay = 15000
				DLight.DieTime = CurTime() + .3
				DLight.Style = 0
			end
		end
	end

	local GlowSprite = Material("sprites/mat_jack_basicglow")

	function ENT:Draw()
		self:DrawModel()
		local State, Fuel, Pos, Ang = self:GetState(), self:GetFuel(), self:GetPos(), self:GetAngles()
		local Up, Right, Forward, Mult, Col = Ang:Up(), Ang:Right(), Ang:Forward(), (Fuel > 150 and 1) or .5, self:GetColor()
		local R, G, B = math.Clamp(Col.r + 20, 0, 255), math.Clamp(Col.g + 20, 0, 255), math.Clamp(Col.b + 20, 0, 255)

		if State == STATE_BURNIN then
			render.SetMaterial(GlowSprite)
			local EyeVec = EyePos() - Pos
			local EyeDir, Dist = EyeVec:GetNormalized(), EyeVec:Length()
			local DistFrac = math.Clamp(Dist, 0, 400) / 400
			render.DrawSprite(Pos + Up * 8 + EyeDir * 10, 200 * Mult, 200 * Mult, Color(R, G, B, 255 * DistFrac))

			for i = 1, 10 do
				render.DrawSprite(Pos + Up * (8 + i) * Mult + VectorRand(), 20 * Mult - i, 20 * Mult - i, Color(R, G, B, math.random(100, 200)))
				render.DrawSprite(Pos + Up * (8 + i) * Mult + VectorRand(), 10 * Mult - i, 10 * Mult - i, Color(255, 255, 255, math.random(100, 200)))
			end
		elseif State == STATE_OFF then
			local CapAng = Ang:GetCopy()
			CapAng:RotateAroundAxis(Right, 180)
			JMod.RenderModel(self.Cap, Pos - Up * 1, CapAng, nil, Vector(.85, 1, .8), nil, true)
		end
	end

	language.Add("ent_jack_gmod_ezroadflare", "EZ Road Flare")
end
