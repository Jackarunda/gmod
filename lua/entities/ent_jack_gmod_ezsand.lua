-- Jackarunda 2021
AddCSLuaFile()
ENT.Base = "ent_jack_gmod_ezresource"
ENT.PrintName = "EZ Sand"
ENT.Category = "JMod - EZ Resources"
ENT.IconOverride = "materials/ez_resource_icons/sand.png"
ENT.Spawnable = true
ENT.AdminSpawnable = true
---
ENT.EZsupplies = JMod.EZ_RESOURCE_TYPES.SAND
ENT.JModPreferredCarryAngles = Angle(0, 0, 0)
--ENT.Model = "models/hunter/blocks/cube05x075x025.mdl"
ENT.Model = "models/jmod/resources/sandbag.mdl"
--ENT.Material = "phoenix_storms/egg"
ENT.Color = Color(255, 237, 197)
ENT.ModelScale = 1
ENT.Mass = 100
ENT.ImpactNoise1 = "Dirt.ImpactHard"
ENT.DamageThreshold = 300
ENT.BreakNoise = "Dirt.ImpactHard"

if SERVER then
	function ENT:OnTakeDamage(dmginfo)
		local DmgAmt, ResourceAmt = dmginfo:GetDamage(), self:GetResource()
		local DmgVec = dmginfo:GetDamageForce()
		dmginfo:SetDamage(DmgAmt / ResourceAmt)
		dmginfo:SetDamageForce(DmgVec / (ResourceAmt^1.1))
		self:TakePhysicsDamage(dmginfo)
		self:SetResource(math.Clamp(ResourceAmt - DmgAmt / 100, 0, 100))

		if dmginfo:GetDamage() > self.DamageThreshold then
			local Pos = self:GetPos()
			sound.Play(self.BreakNoise, Pos)

			JMod.ResourceEffect(self.EZsupplies, self:LocalToWorld(self:OBBCenter()), nil, self:GetResource() / self.MaxResources, 1, 1)
			if self.UseEffect then
				for i = 1, self:GetResource() / 10 do			
					self:UseEffect(Pos, game.GetWorld(), true)
				end
			end

			self:Remove()
		end
	end
elseif CLIENT then

	function ENT:Initialize()
		--self.Bag = JMod.MakeModel(self, "models/jmod/resources/sandbag.mdl", nil, .97)
		--self.ScaleVec =  Vector(1.2, 1.2, 1.2)
		--self.ColorVec = self.Color:ToVector()
	end

	function ENT:Draw()
		local Ang, Pos = self:GetAngles(), self:GetPos()
		local Up, Right, Forward = Ang:Up(), Ang:Right(), Ang:Forward()
		self:DrawModel()
		--local BasePos = Pos
		--local JugAng = Ang:GetCopy()
		--JMod.RenderModel(self.Bag, BasePos, Ang, self.ScaleVec, self.ColorVec)

		JMod.HoloGraphicDisplay(self, Vector(-2, -13, 0), Angle(90, 0, 90), .04, 300, function()
			JMod.StandardResourceDisplay(JMod.EZ_RESOURCE_TYPES.SAND, self:GetResource(), nil, 0, 0, 200, false, "JMod-Stencil", 220)
		end)
	end

	--language.Add(ENT.ClassName, ENT.PrintName)
end
