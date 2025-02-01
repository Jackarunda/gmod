-- Jackarunda 2024
AddCSLuaFile()
ENT.Type = "anim"
ENT.Author = "Jackarunda"
ENT.Category = "JMod - EZ Explosives"
ENT.Information = "glhfggwpezpznore"
ENT.PrintName = "EZ Firework Rocket"
ENT.Spawnable = true
ENT.AdminSpawnable = true
---
ENT.JModHighlyFlammableFunc = "Launch"
ENT.JModPreferredCarryAngles = Angle(90, 0, 0)
ENT.EZrackOffset = Vector(0, -1.5, -2)
ENT.EZrackAngles = Angle(0, 0, 0)
ENT.EZrocket = true
ENT.UsableMats = {MAT_DIRT, MAT_FOLIAGE, MAT_SAND, MAT_SLOSH, MAT_GRASS, MAT_SNOW}
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
		ent:SetAngles(Angle(0, 0, 90))
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
		--self:SetModel("models/hunter/plates/plate1.mdl")
		self:SetModel("models/jmod/explosives/ez_fireworks.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:DrawShadow(true)
		self:SetUseType(SIMPLE_USE)
		---
		self:SetSkin(math.random(0, 1))
		self:SetColor(Color(0, 0, 255))
		---
		timer.Simple(.01, function()
			self:GetPhysicsObject():SetMass(20)
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
	function ENT:PhysicsCollide(data, physobj)
		if not IsValid(self) then return end
		if data.DeltaTime > 0.2 then
			if data.Speed > 50 then
				self:EmitSound("Drywall.ImpactHard")
			end
			local DetSpd = 300
			if (data.Speed > DetSpd) and (self:GetState() == STATE_LAUNCHED) then
				self:Detonate()
				return
			end
			if (data.Speed > 2000) and not(self:IsPlayerHolding()) then
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
	function ENT:Bury(activator)
		local Tr = util.QuickTrace(activator:GetShootPos(), activator:GetAimVector() * 100, {activator, self})
		if Tr.Hit and table.HasValue(self.UsableMats, Tr.MatType) and IsValid(Tr.Entity:GetPhysicsObject()) then
			local Ang = (Tr.HitNormal + VectorRand() * .3):GetNormalized():Angle()
			Ang:RotateAroundAxis(Ang:Right(), -90)
			local Pos = Tr.HitPos + Tr.HitNormal * 25
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
			--JackaGenericUseEffect(activator)
			return true
		end
		return false
	end
	function ENT:Use(activator)
		local State = self:GetState()
		if State < 0 then return end
		local Alt = JMod.IsAltUsing(activator)
		if State == STATE_OFF then
			if Alt then
				JMod.SetEZowner(self, activator, true)
				if (self:Bury(activator)) then
					self:SetState(STATE_ARMED)
					self.EZlaunchableWeaponArmedTime = CurTime()
					JMod.Hint(activator, "launch")
					-- todo: hint fuze
				else
					self:EmitSound("snds_jack_gmod/bomb_arm.ogg", 60, 120)
					self:SetState(STATE_ARMED)
					self.EZlaunchableWeaponArmedTime = CurTime()
					JMod.Hint(activator, "launch")
				end
			else
				constraint.RemoveAll(self)
				activator:PickupObject(self)
				JMod.Hint(activator, "arm")
			end
		elseif State == STATE_ARMED then
			self:EmitSound("snds_jack_gmod/bomb_disarm.ogg", 60, 120)
			self:SetState(STATE_OFF)
			constraint.RemoveAll(self)
			JMod.SetEZowner(self, activator)
			self.EZlaunchableWeaponArmedTime = nil
		end
	end
	function ENT:Detonate()
		if self.NextDet > CurTime() then return end
		if self.Exploded then return end
		self.Exploded = true
		local SelfPos, Att, Dir = self:GetPos() + Vector(0, 0, 30), JMod.GetEZowner(self), -self:GetUp()
		JMod.Sploom(Att, SelfPos, 100)
		local InitialVel = VectorRand() * 100
		timer.Simple(0, function()
			local Flame = ents.Create("ent_jack_gmod_eznapalm")
			Flame:SetPos(SelfPos)
			Flame:SetOwner(Att)
			Flame.InitialVel = InitialVel
			Flame.HighVisuals = false
			Flame.LifeTime = 1
			Flame:Spawn()
			Flame:Activate()
		end)
		---
		util.ScreenShake(SelfPos, 1000, 3, 1, 1500)
		local pitch = math.random(95, 105)
		self:EmitSound("snds_jack_gmod/firework_pop_crackle.ogg", 100, pitch)
		for k, v in player.Iterator() do
			local plyPos = v:GetShootPos()
			if (plyPos:Distance(SelfPos) < 10000) then
				sound.Play("snds_jack_gmod/firework_pop_crackle.ogg", plyPos, 40, pitch)
			end
		end
		---
		timer.Simple(.2, function()
			local Tr = util.QuickTrace(SelfPos - Dir * 100, Dir * 300)
			if Tr.Hit then
				util.Decal("Scorch", Tr.HitPos + Tr.HitNormal, Tr.HitPos - Tr.HitNormal)
			end
		end)
		---
		self:Remove()
		timer.Simple(0, function()
			local EffData = EffectData()
			EffData:SetOrigin(SelfPos - Dir * 100)
			util.Effect("eff_jack_gmod_firework", EffData, true, true)
		end)
	end
	function ENT:OnRemove()
		---
	end
	--
	function ENT:Launch()
		if self:GetState() ~= STATE_ARMED then return end
		local LaunchDir = -self:GetUp()
		self:SetState(STATE_LAUNCHED)
		self.UpLift = Vector(0, 0, GetConVar("sv_gravity"):GetFloat() * .75)
		local Phys = self:GetPhysicsObject()
		constraint.RemoveAll(self)
		Phys:EnableMotion(true)
		Phys:Wake()
		Phys:ApplyForceCenter(-LaunchDir * 5000 + self.UpLift)
		---
		self:EmitSound("snds_jack_gmod/rocket_launch.ogg", 50, math.random(95, 105))
		sound.Play("snds_jack_gmod/bottle_rocket_scream.ogg", self:GetPos(), 100, math.random(90, 110))
		local Eff = EffectData()
		Eff:SetOrigin(self:GetPos())
		Eff:SetNormal(LaunchDir)
		Eff:SetScale(4)
		util.Effect("eff_jack_gmod_rocketthrust", Eff, true, true)
		---
		for i = 1, 4 do
			util.BlastDamage(self, JMod.GetEZowner(self), self:GetPos() + LaunchDir * i * 40, 50, 50)
		end
		util.ScreenShake(self:GetPos(), 20, 255, .5, 200)
		---
		self.NextDet = CurTime() + .25
		---
		timer.Simple(math.Rand(1, 3), function()
			if IsValid(self) then
				self:Detonate()
			end
		end)
		self:SetBodygroup(1, 1)
	end
	function ENT:EZdetonateOverride(detonator)
		self:Detonate()
	end
	function ENT:Think()
		if istable(WireLib) then
			WireLib.TriggerOutput(self, "State", self:GetState())
			WireLib.TriggerOutput(self, "Fuel", self.FuelLeft)
		end
		local LaunchDir = -self:GetUp()
		local Phys = self:GetPhysicsObject()
		JMod.AeroDrag(self, -LaunchDir, 1)
		if self:GetState() == STATE_LAUNCHED then
			if self.FuelLeft > 0 then
				Phys:ApplyForceCenter(-LaunchDir * 2000 + self.UpLift)
				self.FuelLeft = self.FuelLeft - 5
				---
				local Eff = EffectData()
				Eff:SetOrigin(self:GetPos())
				Eff:SetNormal(LaunchDir)
				Eff:SetScale(1)
				util.Effect("eff_jack_gmod_rockettrail", Eff, true, true)
			end
		end
		self:NextThink(CurTime() + .05)
		return true
	end
elseif CLIENT then
	function ENT:Initialize()
		self:SetModel("models/jmod/explosives/ez_fireworks.mdl")
	end--]]
	function ENT:Think()
		local Pos, Dir = self:GetPos(), -self:GetUp()
		local Time = CurTime()
		if self:GetState() == STATE_LAUNCHED then
			self.BurnoutTime = self.BurnoutTime or Time + 1
			if self.BurnoutTime > Time then
				local dlight = DynamicLight(self:EntIndex())
				if dlight then
					dlight.pos = Pos + Dir * 45
					dlight.r = 255
					dlight.g = 175
					dlight.b = 100
					dlight.brightness = 2
					dlight.Decay = 200
					dlight.Size = 400
					dlight.DieTime = Time + .5
				end
			end
		end
	end
	--
	local GlowSprite = Material("mat_jack_gmod_glowsprite")
	function ENT:Draw()
		local Pos, Ang, Dir = self:GetPos(), self:GetAngles(), -self:GetUp()
		local Time = CurTime()
		Ang:RotateAroundAxis(Ang:Forward(), -90)
		self:DrawModel()
		if self:GetState() == STATE_LAUNCHED then
			self.BurnoutTime = self.BurnoutTime or Time + 1
			if self.BurnoutTime > Time then
				render.SetMaterial(GlowSprite)
				for i = 1, 10 do
					local Inv = 10 - i
					render.DrawSprite(Pos + Dir * (i * 10 + math.random(30, 40)), 5 * Inv, 5 * Inv, Color(255, 255 - i * 10, 255 - i * 20, 255))
				end
			end
		end
	end
	language.Add("ent_jack_gmod_ezfirework", "EZ Firework Rocket")
end
