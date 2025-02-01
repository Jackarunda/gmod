-- Jackarunda 2021
AddCSLuaFile()
--DEFINE_BASECLASS("ent_jack_gmod_ezbomb")
ENT.Base = "ent_jack_gmod_ezbomb"
ENT.Author = "Jackarunda"
ENT.Category = "JMod - EZ Explosives"
ENT.Information = "glhfggwpezpznore"
ENT.PrintName = "EZ Small Bomb"
ENT.Spawnable = true
ENT.AdminSpawnable = true
---
ENT.JModPreferredCarryAngles = Angle(0, -90, 0)
ENT.EZrackOffset = Vector(0, 0, 10)
ENT.EZrackAngles = Angle(0, -90, 0)
ENT.EZbombBaySize = 6
---
ENT.Model = "models/hunter/blocks/cube025x125x025.mdl"
ENT.Mass = 80
ENT.DetSpeed = 500
ENT.EZguidable = false

local STATE_BROKEN, STATE_OFF, STATE_ARMED = -1, 0, 1

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "State")
	self:NetworkVar("Bool", 0, "Snakeye")
end

---
if SERVER then
	function ENT:SetupWire()
		if istable(WireLib) then
			self.Inputs = WireLib.CreateInputs(self, {"Detonate", "Arm", "Drop"}, {"Directly detonates the bomb", "Arms bomb when > 0", "Drop the bomb"})

			self.Outputs = WireLib.CreateOutputs(self, {"State", "Dropped", "Snakeye"}, {"-1 broken \n 0 off \n 1 armed", "Outputs 1 when dropped", "Outputs 1 when fins are deployed"})
		end
	end

	function ENT:Detonate()
		if self.Exploded then return end
		self.Exploded = true
		local SelfPos, Att = self:GetPos() + Vector(0, 0, 30), JMod.GetEZowner(self)
		JMod.Sploom(Att, SelfPos, 100)
		---
		util.ScreenShake(SelfPos, 1000, 3, 2, 2000)
		local Eff = "100lb_ground"

		if not util.QuickTrace(SelfPos, Vector(0, 0, -300), {self}).HitWorld then
			Eff = "100lb_air"
		end

		for i = 1, 2 do
			sound.Play("ambient/explosions/explode_" .. math.random(1, 9) .. ".wav", SelfPos + VectorRand() * 1000, 160, math.random(80, 110))
		end

		---
		util.BlastDamage(game.GetWorld(), Att, SelfPos + Vector(0, 0, 300), 300, 80)

		timer.Simple(.25, function()
			util.BlastDamage(game.GetWorld(), Att, SelfPos, 600, 80)
		end)

		for k, ent in pairs(ents.FindInSphere(SelfPos, 200)) do
			if ent:GetClass() == "npc_helicopter" then
				ent:Fire("selfdestruct", "", math.Rand(0, 2))
			end
		end

		---
		JMod.WreckBuildings(self, SelfPos, 4)
		JMod.BlastDoors(self, SelfPos, 4)

		---
		timer.Simple(.2, function()
			local Tr = util.QuickTrace(SelfPos + Vector(0, 0, 100), Vector(0, 0, -400))

			if Tr.Hit then
				util.Decal("BigScorch", Tr.HitPos + Tr.HitNormal, Tr.HitPos - Tr.HitNormal)
			end
		end)

		---
		JMod.FragSplosion(self, SelfPos, 2500, 100, 4000, JMod.GetEZowner(self), nil, nil, 15)
		---
		self:Remove()

		timer.Simple(.1, function()
			ParticleEffect(Eff, SelfPos, Angle(0, 0, 0))
		end)
	end

	function ENT:AeroDragThink()
		local Phys = self:GetPhysicsObject()

		if (self:GetState() == STATE_ARMED) and (Phys:GetVelocity():Length() > 400) and not self:IsPlayerHolding() and not constraint.HasConstraints(self) then
			self.FreefallTicks = self.FreefallTicks + 1

			if (self.FreefallTicks >= 10) and not self:GetSnakeye() then
				self.DetSpeed = 300
				self:SetSnakeye(true)
				Phys:EnableDrag(true)
				Phys:SetDragCoefficient(20)
				self:EmitSound("buttons/lever6.wav", 70, 120)
			end
		else
			self.FreefallTicks = 0
		end

		if istable(WireLib) then
			WireLib.TriggerOutput(self, "Snakeye", tonumber(self:GetSnakeye(), 10))
		end
		local AeroDragMult = .5

		if self:GetSnakeye() then
			AeroDragMult = 4
		end

		JMod.AeroDrag(self, -self:GetRight(), AeroDragMult)
		self:NextThink(CurTime() + .1)

		return true
	end
elseif CLIENT then
	function ENT:Initialize()
		self.Mdl = ClientsideModel("models/jmod/explosives/bombs/mk82.mdl")
		self.Mdl:SetModelScale(.9, 0)
		self.Mdl:SetPos(self:GetPos())
		self.Mdl:SetParent(self)
		self.Mdl:SetNoDraw(true)
		self.Snakeye = false
	end

	function ENT:Think()
		if (not self.Snakeye) and self:GetSnakeye() then
			self.Snakeye = true
			self.Mdl:SetBodygroup(0, 1)
		end
	end

	function ENT:Draw()
		local Pos, Ang = self:GetPos(), self:GetAngles()
		Ang:RotateAroundAxis(Ang:Up(), 90)
		--self:DrawModel()
		self.Mdl:SetRenderOrigin(Pos + Ang:Up() * 6 - Ang:Right() * 6 - Ang:Forward() * 20)
		self.Mdl:SetRenderAngles(Ang)
		self.Mdl:DrawModel()
	end

	language.Add("ent_jack_gmod_ezsmallbomb", "EZ Small Bomb")
end
