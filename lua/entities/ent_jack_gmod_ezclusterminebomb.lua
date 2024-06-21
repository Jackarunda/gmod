-- Jackarunda 2021
AddCSLuaFile()
ENT.Base = "ent_jack_gmod_ezbomb"
ENT.Author = "Jackarunda"
ENT.Category = "JMod - EZ Explosives"
ENT.Information = "glhfggwpezpznore"
ENT.PrintName = "EZ Cluster Mine Layer"
ENT.Spawnable = true
ENT.AdminSpawnable = true
---
ENT.JModPreferredCarryAngles = Angle(0, 0, 0)
ENT.EZbombBaySize = 33
---
ENT.EZguidable = false
ENT.Model = "models/jmod/explosives/bombs/bomb_cbu.mdl"
--ENT.Material = "models/jmod/explosives/bombs/cluster_minelayer"
ENT.Skin = 2
ENT.Mass = 200
ENT.DetSpeed = 500
ENT.DetType = "airburst"
ENT.Durability = 150
ENT.Payload = "ent_jack_gmod_ezlandmine"
ENT.PayloadAmt = 6

local STATE_BROKEN, STATE_OFF, STATE_ARMED = -1, 0, 1

---
if SERVER then
	concommand.Add("jmod_debug_cluster_minelayer", function(ply, cmd, args, argStr)
		if not JMod.IsAdmin(ply) then return end
		local SpawnPos = ply:GetEyeTrace().HitPos + Vector(0, 0, 5000)
		local Bomb = ents.Create("ent_jack_gmod_ezclusterminebomb")
		Bomb:SetPos(SpawnPos)
		JMod.SetEZowner(Bomb, ply)
		Bomb:Spawn()
		Bomb:Activate()
		Bomb:SetState(STATE_ARMED)
		Bomb.Payload = "ent_jack_gmod_ezatmine"
		Bomb.PayloadAmt = 2
	end, nil, nil)

	function ENT:Detonate()
		if self.Exploded then return end
		self.Exploded = true
		local SelfPos, Att = self:GetPos() + Vector(0, 0, 30), JMod.GetEZowner(self)
		JMod.Sploom(Att, SelfPos, 100)
		---
		local Vel, Pos = self:GetPhysicsObject():GetVelocity(), self:LocalToWorld(self:OBBCenter())

		---
		timer.Simple(0, function()
			for i = 1, self.PayloadAmt do
				local NumberOfMinesForThisRing, RingThrowDistance, Dir = 4 + i, 6 * i, Angle(0, 0, 0)
				Dir:RotateAroundAxis(vector_up, i * 20)
				local AngleRotationPerThrow = 360 / NumberOfMinesForThisRing

				for j = 1, NumberOfMinesForThisRing do
					local Mine = ents.Create(self.Payload)
					JMod.SetEZowner(Mine, Att)
					Mine:SetPos(Pos + Dir:Forward() * RingThrowDistance + Vector(0, 0, math.random(-10, 10)))
					Mine:SetAngles(Angle(90, 0, 0))
					Mine.AutoArm = true
					Mine:Spawn()
					Mine:Activate()
					Mine:GetPhysicsObject():SetVelocity(Dir:Forward() * RingThrowDistance * 12)
					Dir:RotateAroundAxis(vector_up, AngleRotationPerThrow)
				end
			end
		end)

		---
		self:Remove()
	end


	function ENT:AeroDragThink()
		local Phys = self:GetPhysicsObject()
		if (self:GetState() == STATE_ARMED) and (Phys:GetVelocity():Length() > 400) and not self:IsPlayerHolding() and not constraint.HasConstraints(self) then
			self.FreefallTicks = self.FreefallTicks + 1

			if self.FreefallTicks >= 10 then
				local Tr = util.QuickTrace(self:GetPos(), Phys:GetVelocity():GetNormalized() * 1500, self)

				if Tr.Hit then
					self:Detonate()
				end
			end
		else
			self.FreefallTicks = 0
		end

		JMod.AeroDrag(self, self:GetForward())
		self:NextThink(CurTime() + .1)

		return true
	end
elseif CLIENT then
	function ENT:Initialize()
	end

	--
	function ENT:Think()
	end

	--
	function ENT:Draw()
		self:DrawModel()
	end

	language.Add("ent_jack_gmod_ezclusterminebomb", "EZ Cluster Mine Layer")
end
