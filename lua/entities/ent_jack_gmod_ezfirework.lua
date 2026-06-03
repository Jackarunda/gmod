-- Jackarunda 2024
AddCSLuaFile()
DEFINE_BASECLASS("ent_jack_gmod_ezherocket")
ENT.Base = "ent_jack_gmod_ezherocket"
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
-- Inherits the HE rocket motion controller. Only the differences below.
ENT.Model = "models/jmod/explosives/ez_fireworks.mdl"
ENT.Mass = 20
ENT.ImpactSound = "Drywall.ImpactHard"
ENT.ThrustForce = 100000
ENT.ThrustJitter = 400
ENT.UpLiftMult = .1
ENT.DetonationSpeed = 300
ENT.CollideDetState = 2 -- STATE_LAUNCHED, only detonates on impact once flying
ENT.AeroDragMult = .1
ENT.UseClientModel = false
-- This rocket points/thrusts along its up axis.
ENT.LaunchSoundVol = 50
---
local STATE_BROKEN, STATE_OFF, STATE_ARMED, STATE_LAUNCHED = -1, 0, 1, 2

if SERVER then
	function ENT:GetNoseDir()
		return self:GetUp()
	end

	-- Fireworks have a short, random fuse rather than the long default.
	function ENT:GetFuseTime()
		return math.Rand(1, 3)
	end

	function ENT:Initialize()
		BaseClass.Initialize(self)
		self:SetSkin(math.random(0, 1))
		self:SetColor(Color(0, 0, 255))
	end

	function ENT:OnLaunch()
		sound.Play("snds_jack_gmod/bottle_rocket_scream.ogg", self:GetPos(), 100, math.random(90, 110))
		self:SetBodygroup(1, 1)
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
		local BurnDmg = DamageInfo()
		BurnDmg:SetDamageType(DMG_BURN)
		BurnDmg:SetDamage(10)
		BurnDmg:SetAttacker(Att)
		BurnDmg:SetInflictor(self)
		BurnDmg:SetDamagePosition(SelfPos)
		BurnDmg:SetDamageForce(Dir * 1)
		util.BlastDamageInfo(BurnDmg, SelfPos, 200)
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
elseif CLIENT then
	function ENT:Initialize()
		self:SetModel("models/jmod/explosives/ez_fireworks.mdl")
	end

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
