-- Jackarunda 2021
AddCSLuaFile()
ENT.Base = "ent_jack_gmod_ezresource"
ENT.PrintName = "A N O M A L O U S  R E S O U R C E"
ENT.Category = "JMod - EZ Resources"
ENT.IconOverride = "materials/ez_resource_icons/anomaly resource.png"
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.AdminOnly = true
---
ENT.JModPreferredCarryAngles = Angle(0, 180, 0)
ENT.Model = "models/jmod/resources/hard_case_b.mdl"
ENT.Material = nil
ENT.Color = Color(100, 100, 100)
ENT.ModelScale = 1
ENT.Mass = 50000
ENT.ImpactNoise1 = "drywall.ImpactHard"
ENT.ImpactNoise2 = "Weapon.ImpactSoft"
ENT.DamageThreshold = 120
ENT.BreakNoise = "Metal_Box.Break"

function ENT:GetEZsupplies(typ)
	if typ then
		return 9e9
	else
		local AllResTable = {}
		for _, res in pairs(JMod.EZ_RESOURCE_TYPES) do
			AllResTable[res] = 9e9
		end
		return AllResTable
	end
end

function ENT:SetEZsupplies(typ, amt, setter)
	if not SERVER then return end -- Important because this is shared as well
end

---
if SERVER then
	function ENT:CustomInit()
		self:SetResource(5000)
	end

	function ENT:CustomThink()
		local Phys = self:GetPhysicsObject()
		Phys:ApplyForceCenter(VectorRand() * math.random(1, 1000 * (Phys:GetMass() / self.Mass)))
		self:NextThink(CurTime() + math.Rand(2, 4))

		return true
	end

	function ENT:Use(activator)
		local AltPressed, Count = JMod.IsAltUsing(activator), self:GetResource()

		if AltPressed then
			local Wep = activator:GetActiveWeapon()
			if IsValid(Wep) and Wep.TryLoadResource then
				for _, res in pairs(JMod.EZ_RESOURCE_TYPES) do
					local Consumed = Wep:TryLoadResource(res, 9e9)
					if Consumed > 0 then
						JMod.ResourceEffect(res, self:LocalToWorld(self:OBBCenter()), activator:LocalToWorld(activator:OBBCenter()), Consumed / self.MaxResource, 1, 1)
					end
				end
			end
		else
			JMod.Hint(activator, "resource manage")
			activator:PickupObject(self)

			if JMod.Hints[self:GetClass() .. " use"] then
				JMod.Hint(activator, self:GetClass() .. " use")
			end
		end
	end

	function ENT:PhysicsCollide(data, physobj)
		if self.Loaded then return end

		if data.DeltaTime > 0.2 then
			local Time = CurTime()

			if data.HitEntity.EZconsumes and (self.NextLoad < Time) and (self:IsPlayerHolding() or JMod.Config.ResourceEconomy.ForceLoadAllResources) then
				for _, res in pairs(JMod.EZ_RESOURCE_TYPES) do
					local Used = data.HitEntity:TryLoadResource(res, 9e9)

					if Used > 0 then
						JMod.ResourceEffect(res, self:LocalToWorld(self:OBBCenter()), data.HitEntity:LocalToWorld(data.HitEntity:OBBCenter()), Used / self.MaxResource, 1, 1)
					end
				end
			end

			if (data.Speed > 80) and self and self.ImpactNoise1 then
				self:EmitSound(self.ImpactNoise1)

				if self.ImpactNoise2 then
					self:EmitSound(self.ImpactNoise2)
				end
			end
		end
	end

	function ENT:UseEffect(pos, ent, destructive)
		if destructive and not self.Sploomd then
			local Resources = 100
			self.Sploomd = true
			local Blam = EffectData()
			Blam:SetOrigin(pos)
			Blam:SetScale(5 * (Resources / 200))
			util.Effect("eff_jack_plastisplosion", Blam, true, true)
			util.ScreenShake(pos, 99999, 99999, 1, 750 * 5)

			for i = 1, 2 do
				sound.Play("BaseExplosionEffect.Sound", pos, 120, math.random(90, 110))
			end

			for i = 1, 2 do
				sound.Play("ambient/explosions/explode_" .. math.random(1, 9) .. ".wav", pos + VectorRand() * 1000, 140, math.random(90, 110))
			end

			timer.Simple(.1, function()
				local MeltBlast = DamageInfo()
				MeltBlast:SetInflictor(game.GetWorld())
				MeltBlast:SetAttacker(game.GetWorld())
				MeltBlast:SetDamage(Resources * 5)
				MeltBlast:SetDamageType(DMG_DISSOLVE)
				util.BlastDamageInfo(MeltBlast, pos, Resources * 8)
				for k, v in pairs(ents.FindInSphere(pos, Resources * 5)) do 
					if v:GetClass() == "npc_strider" then
						v:Fire("break")
					end
				end
			end)
		end
	end

elseif CLIENT then
    local drawvec, drawang = Vector(0, 3.5, 1), Angle(-90, 0, 90)
	function ENT:Draw()
		self:DrawModel()

		JMod.HoloGraphicDisplay(self, drawvec, drawang, .035, 300, function()
			JMod.StandardResourceDisplay("anomalous resource", nil, nil, 0, 0, 200, true)
			--draw.DrawText("T H E  R E S O U R C E", "JMod-Display", 0, 0, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)
		end)
	end

	--language.Add(ENT.ClassName, ENT.PrintName)
end
