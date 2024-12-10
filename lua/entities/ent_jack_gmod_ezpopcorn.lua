-- Jackarunda 2023
AddCSLuaFile()
ENT.Type = "anim"
ENT.Author = "Jackarunda"
ENT.Information = "glhfggwpezpznore"
ENT.PrintName = "EZ Popcorn"
ENT.Category = "JMod - EZ Misc."
ENT.Spawnable = true
ENT.AdminOnly = false
ENT.JModEZstorable = true

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "Pop")
end

if SERVER then
	function ENT:Initialize()
		self:SetModel("models/jmod/props/popcorn_packet.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:DrawShadow(true)
		self:SetUseType(SIMPLE_USE)
		---
		local Phys = self:GetPhysicsObject()
		timer.Simple(.01, function()
			if IsValid(Phys) then
				Phys:SetMass(5)
				Phys:Wake()
			end
		end)
		---
		self:SetPop(5)
	end

	--[[function ENT:PhysicsCollide(data, physobj)
		if data.DeltaTime > 0.2 and data.Speed > 50 then
			self:EmitSound("garrysmod/balloon_pop_cute.wav", 60, math.random(70, 130))
		end
	end--]]
	
	function ENT:OnTakeDamage(damage)
		if damage:IsDamageType(DMG_BURN) or damage:IsDamageType(DMG_SLOWBURN) then
			self:EmitSound("garrysmod/balloon_pop_cute.wav", 60, math.random(70, 130))
		end
	end

	function ENT:Use(ply)
		local Time = CurTime()
		local Alt = JMod.IsAltUsing(ply)

		if Alt then
			if JMod.ConsumeNutrients(ply, 1) then
				sound.Play("snds_jack_gmod/nom" .. math.random(1, 5) .. ".ogg", self:GetPos(), 60, math.random(90, 110))
				self:EmitSound("garrysmod/balloon_pop_cute.wav", 60, math.random(70, 130))

				self:SetPop(self:GetPop() - 1)

				local Eff = EffectData()
				Eff:SetOrigin(self:GetPos() + self:GetUp() * 10)
				util.Effect("eff_jack_gmod_ezpopcorn", Eff, true, true)
				if self.Mutated and not(ply.JMod_WillAsplode) and (math.random(1, 3) == 3) then
					ply.JMod_WillAsplode = true
					timer.Simple(math.random(1, 3), function()
						if IsValid(ply) then
							ply:EmitSound("vo/npc/male01/ohno.ogg")
							timer.Simple(1, function()
								if not IsValid(ply) then return end
								ply:EmitSound("vo/npc/male01/question27.ogg")
								timer.Simple(2, function()
									if not IsValid(ply) then return end
									local Pos, Range = ply:GetPos() + Vector(0, 0, 40), 40
									ply:KillSilent()
									for i = 1, 20 do
										JMod.Sploom(ply, Pos + VectorRand() * Range, 1, 10)
									end
								end)
							end)
						end
					end)
				end
			end
		else
			ply:PickupObject(self)
			JMod.Hint(ply, "alt to eat")
			self.EZremoveSelf = false
			self.LastTouchedTime = Time
		end

		if self:GetPop() <= 0 then
			self:Remove()
		end
	end

	function ENT:Degenerate() 
		constraint.RemoveAll(self)
		self:SetNotSolid(true)
		self:DrawShadow(false)
		self:GetPhysicsObject():EnableCollisions(false)
		self:GetPhysicsObject():EnableGravity(false)
		self:GetPhysicsObject():SetVelocity(Vector(0, 0, -5))
		timer.Simple(2, function()
			if (IsValid(self)) then self:Remove() end
		end)
	end

	function ENT:Think()
		if self:GetPop() <= 0 then
			self:Remove()
		end
	end
elseif CLIENT then
	function ENT:Initialize()
		--
	end

	function ENT:Draw()
		local Matricks = Matrix()
		Matricks:Scale(Vector(1*(self:GetPop()/5), 1, 1))
		self:EnableMatrix("RenderMultiply", Matricks)
		self:DrawModel()
	end

	language.Add("ent_jack_gmod_ezpopcorn", "EZ Popcorn")
end
