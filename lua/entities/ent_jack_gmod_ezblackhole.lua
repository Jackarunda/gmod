-- Jackarunda 2021
AddCSLuaFile()
ENT.Type = "anim"
ENT.Author = "Jackarunda"
ENT.Information = "glhfggwpezpznore"
ENT.PrintName = "EZ Micro Black Hole"
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.NoSitAllowed = true

ENT.Blacklist = {"func_", "_dynamic"}

ENT.Whitelist = {"func_physbox", "func_breakable"}

ENT.DamageEnts = {"func_breakable"}

ENT.PhyslessPointEnts = {"rpg_missile", "crossbow_bolt", "grenade_ar2", "grenade_spit", "npc_grenade_bugbait"}

ENT.PhysNPCs = {"npc_cscanner", "npc_clawscanner", "npc_turret_floor", "npc_rollermine"}

ENT.RagdollifyEnts = {"npc_combinegunship", "npc_strider", "npc_manhack", "npc_combinedropship"}

---
function ENT:SetupDataTables()
	self:NetworkVar("Float", 0, "Age")
end

---
function ENT:SUCC(Time, Phys, Age, Pos, MaxRange)
	for k, obj in pairs(ents.FindInSphere(Pos, MaxRange)) do
		local ObjPhys, Class = obj:GetPhysicsObject(), obj:GetClass()

		if table.HasValue(self.PhyslessPointEnts, Class) then
			if SERVER then
				local Vec = Pos - obj:GetPos()
				local Dist = Vec:Length()
				local ToDir = Vec:GetNormalized()
				obj:Fire("becomeragdoll", "", 0)
				obj:SetPos(obj:GetPos() + ToDir * 40)
			end
		elseif table.HasValue(self.RagdollifyEnts, Class) then
			if SERVER and (math.random(1, 100) == 42) then
				obj:Fire("becomeragdoll", "", 0)
			end
		elseif table.HasValue(self.DamageEnts, Class) then
			local Vec = Pos - obj:GetPos()
			local Dist, Dir = Vec:Length(), Vec:GetNormalized()

			if obj.TakeDamage then
				obj:TakeDamage((MaxRange - Dist) / MaxRange * 50, obj.Owner, obj)
			end
		elseif IsValid(ObjPhys) and not (obj == self) and not self:IsBlacklisted(obj) then
			-- not(obj:IsWorld())and 
			local Vec = Pos - obj:GetPos()
			local Dist, Dir = Vec:Length(), Vec:GetNormalized()

			if Dist < Age ^ 1.3 * .75 then
				self:Rape(obj)
			else
				-- inverse square law bitchins
				local PullStrength = ((1 - Dist / MaxRange) ^ 2) * ((JMod.Config and JMod.Config.MicroBlackHoleGravityStrength) or 1)
				local Mass = ObjPhys:GetMass()
				local ApplyForce, Mul = true, 1

				if obj:IsPlayer() then
					ApplyForce = false
					Mul = Age ^ 2 / 5000
				elseif obj:IsNPC() then
					if not table.HasValue(self.PhysNPCs, Class) then
						ApplyForce = false
					end
				end

				if ApplyForce then
					local Force = Mass * 200 * PullStrength

					if SERVER then
						local BreakThreshold = (Age ^ 2 / Dist) * 30

						if BreakThreshold > 100 then
							constraint.RemoveAll(obj)
							ObjPhys:EnableMotion(true)
							ObjPhys:EnableDrag(false)
						end
					elseif CLIENT then
						Force = Force * 3
					end

					ObjPhys:ApplyForceCenter(Dir * Force * Mul)
				else
					obj:SetGroundEntity(nil)
					obj:SetVelocity(Dir * 200 * PullStrength * Mul)
				end
			end
		end
	end
end

function ENT:IsBlacklisted(ent)
	local Class = ent:GetClass()
	if table.HasValue(self.Whitelist, Class) then return false end

	for k, v in pairs(self.Blacklist) do
		if string.find(Class, v) then return true end
	end

	return false
end

function ENT:Rape(ent)
	ent.SUCCd = true

	if SERVER then
		local Dmg, SelfPos = DamageInfo(), self:GetPos()
		Dmg:SetDamage(9e9)
		Dmg:SetDamageType(DMG_CRUSH)
		Dmg:SetDamagePosition(SelfPos)
		Dmg:SetDamageForce((SelfPos - ent:GetPos()) * 10)
		Dmg:SetInflictor(self)
		Dmg:SetAttacker((IsValid(self.Owner) and self.Owner) or self)
		ent:TakeDamageInfo(Dmg)

		timer.Simple(0, function()
			SafeRemoveEntity(ent)
		end)
	elseif CLIENT then
		if string.find(string.lower(ent:GetClass()), "c_hl2mpragdoll") then
			ent:SetNoDraw(true)
			ent:GetPhysicsObject():EnableMotion(false)
		else
			SafeRemoveEntity(ent)
		end
	end
end

if SERVER then
	function ENT:Initialize()
		self.Entity:SetModel("models/dav0r/hoverball.mdl")
		self.Entity:SetMaterial("models/debug/debugwhite")
		self.Entity:SetColor(Color(0, 0, 0))
		self.Entity:SetModelScale(4, 1)
		self.Entity:PhysicsInit(SOLID_VPHYSICS)
		self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
		self.Entity:SetSolid(SOLID_VPHYSICS)
		self.Entity:DrawShadow(true)

		---
		timer.Simple(.01, function()
			self:GetPhysicsObject():SetMass(50000)
			self:GetPhysicsObject():Wake()
			self:GetPhysicsObject():EnableMotion(false)
		end)

		---
		self:SetAge(.01)
		self.SoundLoop = CreateSound(self, "snds_jack_gmod/ezblackhole.mp3")
		self.SoundLoop:PlayEx(1, 100)
		self.SoundLoop:SetSoundLevel(160)
		self.SoundLoop2 = CreateSound(self, "snds_jack_gmod/ezblackhole.mp3")
		self.SoundLoop2:PlayEx(1, 100)
		self.SoundLoop2:SetSoundLevel(150)
		---
		JMod.BlackHole = self -- global var for ease of comps for bullet hook
	end

	function ENT:PhysicsCollide(data, physobj)
		self:Rape(data.HitEntity)
	end

	function ENT:Think()
		local Time, Phys, Age, Pos = CurTime(), self:GetPhysicsObject(), self:GetAge(), self:LocalToWorld(self:OBBCenter())
		Phys:EnableMotion(false)
		self:SetAge(Age + .05 * JMod.Config.MicroBlackHoleEvaporateSpeed)
		local MaxRange = Age * 150
		self:SUCC(Time, Phys, Age, Pos, MaxRange)

		if Age > 90 then
			self:EmitHawkingRadiation(Age - 90)
		end

		if Age >= 100 then
			self:Die()

			return
		end

		self:NextThink(Time + .05)

		return true
	end

	function ENT:EmitHawkingRadiation(power)
		local Dmg = DamageInfo()
		Dmg:SetDamage(power / 10)
		Dmg:SetDamageType(DMG_RADIATION)
		Dmg:SetInflictor(self)
		Dmg:SetAttacker((IsValid(self.Owner) and self.Owner) or self)
		util.BlastDamageInfo(Dmg, self:GetPos(), 10000)
	end

	function ENT:Die()
		local SelfPos = self:GetPos()

		for i = 1, 50 do
			timer.Simple(i / 150, function()
				sound.Play("ambient/machines/thumper_hit.wav", SelfPos + VectorRand() * math.random(1, 1000), 140, math.random(120, 130))
			end)
		end

		RunConsoleCommand("r_cleardecals")
		self:Remove()
	end

	function ENT:OnRemove()
		if self.SoundLoop then
			self.SoundLoop:Stop()
		end

		if self.SoundLoop2 then
			self.SoundLoop2:Stop()
		end

		if JMod.BlackHole and (JMod.BlackHole == self) then
			JMod.BlackHole = nil
		end
	end
elseif CLIENT then
	function ENT:Initialize()
		self.EventHorizon = ClientsideModel("models/dav0r/hoverball.mdl")
		self.EventHorizon:SetMaterial("models/debug/debugwhite")
		self.EventHorizon:SetColor(Color(0, 0, 0, 255))
		self.EventHorizon:SetPos(self:GetPos())
		self.EventHorizon:SetParent(self)
		self.EventHorizon:SetNoDraw(true)
		JMod.BlackHole = self
	end

	function ENT:Think()
		local Time, Phys, Age, Pos = CurTime(), self:GetPhysicsObject(), self:GetAge(), self:LocalToWorld(self:OBBCenter())
		local MaxRange = Age * 100
		self:SUCC(Time, Phys, Age, Pos, MaxRange)
		self:NextThink(Time + .05)

		return true
	end

	local Refract, Up, Down, White, AccretionDisk, Glow, Tilt, GargantuaGlow = Material("mat_jack_gmod_gravlens"), Vector(0, 0, 1), Vector(0, 0, -1), Color(255, 255, 255, 255), Material("sprites/mat_jack_gmod_blurrycircle"), Material("sprites/mat_jack_basicglow"), Vector(0, .2, .8), Color(255, 200, 150, 150)

	function ENT:Draw()
		--self:DrawModel()
		local Pos, AgeSize, ViewPos = self:LocalToWorld(self:OBBCenter()), self:GetAge() ^ .9 / 2.5, EyePos()
		--local ViewVec=ViewPos-Pos
		--local ViewDir=ViewVec:GetNormalized()
		render.SetMaterial(Refract)
		local QuadPos = Pos - Vector(0, 0, AgeSize * 4)
		render.DrawQuadEasy(QuadPos, Up, 200 * AgeSize, 200 * AgeSize, White)
		render.DrawQuadEasy(QuadPos, Down, 200 * AgeSize, 200 * AgeSize, White)
		local Matricks = Matrix()
		Matricks:Scale(Vector(2, 2, 2) * AgeSize)
		self.EventHorizon:EnableMatrix("RenderMultiply", Matricks)
		--
		render.DrawSprite(Pos, 200 * AgeSize, 200 * AgeSize, White)
		render.SetMaterial(AccretionDisk)
		render.DrawSprite(Pos, 40 * AgeSize, 40 * AgeSize, White)
		render.SetMaterial(Glow)
		render.DrawSprite(Pos, 200 * AgeSize, 200 * AgeSize, GargantuaGlow)
		self.EventHorizon:DrawModel()
		render.SetMaterial(AccretionDisk)
		render.DrawQuadEasy(Pos, Tilt, 35 * AgeSize, 35 * AgeSize, White)
		render.DrawQuadEasy(Pos, Tilt, 50 * AgeSize, 50 * AgeSize, GargantuaGlow)
		render.DrawQuadEasy(Pos, -Tilt, 35 * AgeSize, 35 * AgeSize, White)
		render.DrawQuadEasy(Pos, -Tilt, 50 * AgeSize, 50 * AgeSize, GargantuaGlow)
	end

	language.Add("ent_jack_gmod_ezblackhole", "Micro Black Hole")
end
