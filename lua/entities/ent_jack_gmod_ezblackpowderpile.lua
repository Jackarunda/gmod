-- Jackarunda 2021
AddCSLuaFile()
ENT.Type = "anim"
ENT.Author = "Jackarunda"
ENT.Category = "JMod - EZ Explosives"
ENT.Information = "glhfggwpezpznore"
ENT.PrintName = "EZ Black Powder Pile"
ENT.NoSitAllowed = true
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.JModHighlyFlammableFunc = "Arm"

if SERVER then
	function ENT:Initialize()
		self:SetModel("models/cheeze/pcb2/pcb2.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:DrawShadow(false)
		self:SetUseType(SIMPLE_USE)
		self:SetCollisionGroup(COLLISION_GROUP_WEAPON)

		---
		local Phys = self:GetPhysicsObject()
		timer.Simple(.01, function()
			if IsValid(Phys) then
				Phys:SetMass(1)
				Phys:Wake()
			end
		end)

		self.Ignited = false

		if self:WaterLevel() > 0 then
			self:Remove()
		end

		SafeRemoveEntityDelayed(self, 300)
	end

	function ENT:PhysicsCollide(data, physobj)
		if not data.HitEntity:IsWorld() then
			if math.random(1, 2) == 1 then
				SafeRemoveEntityDelayed(self, 0)
			end
		end
	end

	function ENT:OnTakeDamage(dmginfo)
		if self.Ignited then return end

		if dmginfo:IsDamageType(DMG_BLAST) then
			self:Remove()

			return
		end

		if dmginfo:IsDamageType(DMG_BURN) then
			JMod.SetEZowner(self, dmginfo:GetAttacker())
			self:Arm()
		end
	end

	function ENT:Use(activator, activatorAgain, onOff)
		local Dude = activator or activatorAgain
		JMod.SetEZowner(self, Dude)

		if JMod.IsAltUsing(Dude) then
			self:Arm()
		else
			if math.random(1, 2) == 2 then
				self:Remove()
			end
		end
	end

	function ENT:Arm()
		if self.Ignited then return end
		self.Ignited = true
		self:EmitSound("snd_jack_sss.wav", 60, math.Rand(90, 110))

		for i = 1, 8 do
			local Fsh = EffectData()
			Fsh:SetOrigin(self:GetPos())
			Fsh:SetScale(1)
			Fsh:SetNormal(VectorRand())
			util.Effect("eff_jack_gmod_fuzeburn_smoky", Fsh, true, true)
		end

		timer.Simple(.075, function()
			if not IsValid(self) then return end

			for k, v in pairs(ents.FindInSphere(self:GetPos(), 80)) do
				if v.JModHighlyFlammableFunc then
					JMod.SetEZowner(v, self.EZowner)
					local Func = v[v.JModHighlyFlammableFunc]
					Func(v)
				end
			end

			self:Remove()
		end)
	end

	function ENT:Think()
	end

	--
	function ENT:OnRemove()
	end
	--aw fuck you
elseif CLIENT then
	function ENT:Initialize()
		self.NextDrawTime = CurTime() + 1
		self.Rot = math.random(0, 360)
	end

	local Mat = Material("sprites/mat_jack_gmod_blackpowderpile")

	function ENT:Draw()
		if self.NextDrawTime < CurTime() then
			render.SetMaterial(Mat)
			render.DrawQuadEasy(self:GetPos(), vector_up, 15, 15, Color(0, 0, 0, 255), self.Rot)
			--self:DrawModel()
		end
	end

	language.Add("ent_jack_gmod_ezblackpowderpile", "EZ Black Powder Pile")
end
