-- Jackarunda 2021
AddCSLuaFile()
ENT.Type = "anim"
ENT.Author = "Jackarunda"
ENT.Information = "glhfggwpezpznore"
ENT.PrintName = "EZ Compact Box"
ENT.NoSitAllowed = true
ENT.Spawnable = false
ENT.AdminSpawnable = false
---
ENT.EZunpackagable = true
ENT.JModPreferredCarryAngles = Angle(0, 0, 0)
ENT.DamageThreshold = 120

ENT.ScaleSpecs = {
	{.25, 10, 5, .025}, -- lol
	{.5, 35, 10, .05}, -- max mass for E-carry
	{1, 250, 20, .1}, -- max mass for gravgun carry
	{2, 1000, 40, .2},
	{4, 4000, 80, .4},
	{8, 16000, 160, .8}
}

---
function ENT:SetupDataTables()
	self:NetworkVar("Entity", 0, "Contents")
	self:NetworkVar("Int", 0, "SizeScale")
end

---
if SERVER then
	function ENT:Initialize()
		local Contents = self:GetContents()
		local ContentsPhys = Contents:GetPhysicsObject()

		if not IsValid(ContentsPhys) then
			print("EZ compact box error: WAT")
			self:Remove()

			return
		end

		local Mass = ContentsPhys:GetMass()

		if Mass <= 35 then
			self:SetSizeScale(1)
		elseif Mass <= 300 then
			self:SetSizeScale(2)
		elseif Mass <= 1200 then
			self:SetSizeScale(3)
		elseif Mass <= 4800 then
			self:SetSizeScale(4)
		elseif Mass <= 19200 then
			self:SetSizeScale(5)
		else
			self:SetSizeScale(6)
		end

		local Specs = self.ScaleSpecs[self:GetSizeScale()]
		---
		self.Entity:SetModel("models/props_junk/wood_crate001a.mdl")
		self:SetModelScale(Specs[1], 0)
		self.Entity:PhysicsInit(SOLID_VPHYSICS)
		self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
		self.Entity:SetSolid(SOLID_VPHYSICS)
		self.Entity:DrawShadow(true)
		self.Entity:SetUseType(SIMPLE_USE)
		---
		self.LastUsedTime = 0
		self.Unpackaging = false

		timer.Simple(.01, function()
			self:GetPhysicsObject():SetMass(Specs[2])
			self:GetPhysicsObject():Wake()
		end)

		---
		Contents:SetNoDraw(true)
		Contents:SetNotSolid(true)
		ContentsPhys:Sleep()
	end

	function ENT:PhysicsCollide(data, physobj)
		if data.DeltaTime > 0.2 then
			if data.Speed > 100 then
				self.Entity:EmitSound("Wood_Crate.ImpactHard")
				self.Entity:EmitSound("Wood_Box.ImpactHard")
			end
		end
	end

	function ENT:OnTakeDamage(dmginfo)
		self.Entity:TakePhysicsDamage(dmginfo)

		if dmginfo:GetDamage() > self.DamageThreshold then
			local Pos = self:GetPos()
			sound.Play("Wood_Crate.Break", Pos)
			sound.Play("Wood_Box.Break", Pos)
			self:ReleaseItem()
		end
	end

	function ENT:OpenEffect(pos)
		if CLIENT then return end
		local Scale = self:GetSizeScale() ^ .5
		local eff = EffectData()
		eff:SetOrigin(pos + VectorRand())
		eff:SetScale(Scale)
		util.Effect("eff_jack_gmod_ezbuildsmoke", eff, true, true)
		local effectdata = EffectData()
		effectdata:SetOrigin(pos + VectorRand())
		effectdata:SetNormal((VectorRand() + Vector(0, 0, 1)):GetNormalized())
		effectdata:SetMagnitude(math.Rand(4, 8) * Scale) --amount and shoot hardness
		effectdata:SetScale(math.Rand(2, 6) * Scale) --length of strands
		effectdata:SetRadius(math.Rand(8, 16) * Scale) --thickness of strands
		util.Effect("Sparks", effectdata, true, true)
		sound.Play("snds_jack_gmod/unpackage.wav", pos, 60, math.random(90, 110))

		for i = 1, 4 do
			timer.Simple(i / 5, function()
				sound.Play("snds_jack_gmod/ez_tools/" .. math.random(1, 27) .. ".wav", pos, 60, math.random(80, 120))
			end)
		end
	end

	function ENT:Unpackage()
		if self.Unpackaging then return end
		self.Unpackaging = true
		self:EmitSound("snd_jack_metallicclick.wav", 60, 100)

		for i = 1, 4 do
			timer.Simple(i, function()
				if i < 4 then
					self:EmitSound("snd_jack_metallicclick.wav", 50, 100)
				else
					self:ReleaseItem()
				end
			end)
		end
	end

	function ENT:ReleaseItem()
		local Pos, Ang, Contents, Vel = self:LocalToWorld(self:OBBCenter()), self:GetAngles(), self:GetContents(), self:GetPhysicsObject():GetVelocity()

		if IsValid(Contents) then
			self:OpenEffect(Pos)
			Contents:SetPos(Pos + Vector(0, 0, 30))
			Contents:SetAngles(Ang)
			Contents:SetNoDraw(false)
			Contents:SetNotSolid(false)
			local Phys = Contents:GetPhysicsObject()

			if IsValid(Phys) then
				Phys:Wake()
				Phys:SetVelocity(Vel)
			end

			self:SetContents(nil)
		end

		self:Remove()
	end

	function ENT:Use(activator)
		local Time = CurTime()
		JMod.Hint(activator, "unpackage")

		if activator:KeyDown(JMod.Config.AltFunctionKey) then
			self:Unpackage()
		else
			if self:GetSizeScale() <= 2 then
				activator:PickupObject(self)
			end
		end
	end

	function ENT:Think()
		local Contents = self:GetContents()

		if IsValid(Contents) then
			Contents:SetPos(self:GetPos())
			self:NextThink(CurTime() + 1)

			return true
		else
			self:Remove()
		end
	end

	function ENT:OnRemove()
		local Contents = self:GetContents()

		if IsValid(Contents) then
			Contents:Remove()
		end
	end
elseif CLIENT then
	local TxtCol = Color(10, 10, 10, 220)

	function ENT:Draw()
		local Ang, Pos = self:GetAngles(), self:GetPos()
		local Closeness = LocalPlayer():GetFOV() * EyePos():Distance(Pos)
		local DetailDraw = Closeness < 45000 -- cutoff point is 500 units when the fov is 90 degrees
		self:DrawModel()

		if DetailDraw then
			local Specs = self.ScaleSpecs[self:GetSizeScale()]
			local Contents = self:GetContents()
			if not IsValid(Contents) then return end
			local Txt = Contents.PrintName or Contents:GetClass()
			local MdlParts = string.Explode("/", Contents:GetModel())
			local Txt2 = string.Replace(MdlParts[#MdlParts], ".mdl", "")
			local Up, Right, Forward = Ang:Up(), Ang:Right(), Ang:Forward()
			Ang:RotateAroundAxis(Ang:Right(), 90)
			Ang:RotateAroundAxis(Ang:Up(), -90)
			cam.Start3D2D(Pos + Up * Specs[3] / 2 - Forward * Specs[3], Ang, Specs[4])
			draw.SimpleText(Txt, "JMod-SharpieHandwriting", 0, 15, TxtCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
			draw.SimpleText(Txt2, "JMod-SharpieHandwriting", 0, 60, TxtCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
			cam.End3D2D()
			---
			Ang:RotateAroundAxis(Ang:Right(), 180)
			cam.Start3D2D(Pos + Up * Specs[3] / 2 + Forward * (Specs[3] + .2), Ang, Specs[4])
			draw.SimpleText(Txt, "JMod-SharpieHandwriting", 0, 15, TxtCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
			draw.SimpleText(Txt2, "JMod-SharpieHandwriting", 0, 60, TxtCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
			cam.End3D2D()
		end
	end

	language.Add("ent_jack_gmod_ezcompactbox", "EZ Storage Box")
end
