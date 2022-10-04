-- Jackarunda 2021
-- totally not deleted by titanicjames
AddCSLuaFile()
ENT.Type = "anim"
ENT.Author = "Jackarunda"
ENT.Information = "glhfggwpezpznore"
ENT.PrintName = "EZ Edible Chess piece"
ENT.Spawnable = false
ENT.AdminSpawnable = false

if SERVER then
	function ENT:Initialize()
		self.Piece = math.random(1, 6)

		local pieces = {"models/props_phx/games/chess/black_pawn.mdl", "models/props_phx/games/chess/black_rook.mdl", "models/props_phx/games/chess/black_bishop.mdl", "models/props_phx/games/chess/black_knight.mdl", "models/props_phx/games/chess/black_queen.mdl", "models/props_phx/games/chess/black_king.mdl"}

		self:SetModel(pieces[self.Piece])
		self:SetModelScale(math.Rand(1.5, 3), 0)
		self:SetMaterial("models/debug/debugwhite")
		self:SetColor(Color(math.random(190, 210), math.random(140, 160), 0))
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:DrawShadow(true)
		self:SetUseType(CONTINUOUS_USE)

		---
		-- some bits and pieces cobbled together from the gnome, should work as a band aid since im flippin stupid.
		for i = 1, 10 do
			local SelfPos = self:GetPos()
			local Dir = VectorRand()
			local NewPos = SelfPos + Dir * 50 + Vector(0, 0, 50) -- generate random spot within ~50 units, check to make sure it is not within map geometry.

			local Tr = util.QuickTrace(NewPos + Vector(0, 0, 0), Vector(0, 0, -300), {self})

			if Tr.Hit and not Tr.StartSolid then
				self:SetPos(NewPos)
				break
			end
		end

		-- if the loop ever ends without doing anything, that must mean this piece spawned deep in the map. shit.
		timer.Simple(.01, function()
			self:GetPhysicsObject():SetMass(100)
			self:GetPhysicsObject():Wake()
		end)
	end

	function ENT:PhysicsCollide(data, physobj)
		if data.DeltaTime > 0.2 and data.Speed > 50 then
			self:EmitSound("physics/body/body_medium_impact_soft7.wav", 60, math.random(70, 130))
		end
	end

	function ENT:Use(activator)
		sound.Play("snds_jack_gmod/nom" .. math.random(1, 5) .. ".wav", self:GetPos(), 60, math.random(90, 110))
		activator:SetHealth(activator:Health() + 15 * self.Piece)
		self:Remove()
	end
elseif CLIENT then
	function ENT:Initialize()
	end

	--
	function ENT:Draw()
		self:DrawModel()
	end

	language.Add("ent_jack_gmod_ezcheese", "EZ Edible Chess piece")
end
