-- from the Advanced Light Entities addon
AddCSLuaFile()
DEFINE_BASECLASS("jmod_base_light")
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.PrintName = "Expensive Light (new)"
ENT.Category = "Render"

function ENT:SetupDataTables()
	self:NetworkVar("Bool", 0, "ActiveState", {
		KeyName = "activestate",
		Edit = {
			type = "Boolean",
			title = "Enable",
			order = 1,
			category = "Main"
		}
	})

	self:NetworkVar("Bool", 1, "DrawHelper", {
		KeyName = "drawhelper",
		Edit = {
			type = "Boolean",
			title = "Draw Helper",
			order = 8,
			category = "Render"
		}
	})

	self:NetworkVar("Bool", 2, "DrawSprite", {
		KeyName = "drawsprite",
		Edit = {
			type = "Boolean",
			title = "Draw Sprite",
			order = 7,
			category = "Render"
		}
	})

	self:NetworkVar("Bool", 3, "Shadows", {
		KeyName = "shadows",
		Edit = {
			type = "Boolean",
			title = "Shadows",
			order = 6,
			category = "Effect"
		}
	})

	self:NetworkVar("Float", 0, "Brightness", {
		KeyName = "brightness",
		Edit = {
			type = "Float",
			min = 0.01,
			max = 15,
			title = "Brightness",
			order = 3,
			category = "Light"
		}
	})

	self:NetworkVar("Float", 1, "FarZ", {
		KeyName = "farz",
		Edit = {
			type = "Float",
			min = 32,
			max = 2048,
			title = "Size",
			order = 5,
			category = "Light"
		}
	})

	self:NetworkVar("Float", 2, "NearZ", {
		KeyName = "nearz",
		Edit = {
			type = "Float",
			min = 2,
			max = 16,
			title = "Near Z",
			order = 4,
			category = "Light"
		}
	})

	self:NetworkVar("Vector", 0, "LightColor", {
		KeyName = "lightcolor",
		Edit = {
			type = "RGBColor",
			title = "Color",
			order = 2,
			category = "Light"
		}
	})

	if SERVER then
		self:SetActiveState(true)
		self:SetDrawHelper(true)
		self:SetDrawSprite(true)
		self:SetShadows(true)
		self:SetBrightness(2000)
		self:SetFarZ(20000)
		self:SetNearZ(4)
		self:SetLightColor(Vector(255, 200, 175))
	end
end

if SERVER then
	function ENT:Initialize()
		BaseClass.Initialize(self)
		self.LifeDuration = 10
		self.DieTime = CurTime() + self.LifeDuration
	end

	function ENT:Think()
		self:NextThink(CurTime() + .05)

		return true
	end

	function ENT:SpawnedInSandbox(ply)
		ply:AddCleanup("advlights_expensive_lights", self)
	end

	function ENT:SpawnFunction(ply, tr, ClassName)
		if not tr.Hit then return end
		local ent = ents.Create(ClassName)
		ent:SetPos(tr.HitPos + (tr.HitNormal * 32))
		ent:Spawn()
		ent:Activate()
		ent:SpawnedInSandbox(ply)

		return ent
	end

	duplicator.RegisterEntityClass("expensive_light_new", function(ply, data)
		local ent = duplicator.GenericDuplicatorFunction(ply, data)
		if not IsValid(ent) then return end
		ent:SpawnedInSandbox(ply)

		return ent
	end, "Data")

	function ENT:CanTool(ply, trace, name)
		if name == "colour" then
			self:colour_tool(ply, trace)

			return false
		elseif name == "light" then
			self:light_tool(ply, trace)

			return false
		end

		return true
	end
end

if CLIENT then
	local fov = math.deg(math.atan(512 / 511)) * 2
	local lx = "effects/lx"

	function ENT:UpdateProjectedTexture(L, pos, ang, Shadows, FarZ, NearZ, LightColor, Brightness)
		L:SetPos(pos)
		L:SetAngles(ang)
		L:SetEnableShadows(Shadows)
		L:SetFarZ(FarZ)
		L:SetNearZ(NearZ)
		L:SetFOV(fov)
		L:SetOrthographic(false)
		L:SetColor(LightColor)
		L:SetBrightness(Brightness)
		L:SetTexture(lx)
		L:Update()
	end

	local EMPTY_ANG = Angle(0, 0, 0)

	function ENT:CreateAllProjectedTextures()
		local Shadows = self:BoolToString(self:GetShadows())
		local FarZ = self:GetFarZ()
		local NearZ = self:GetNearZ()
		local LightColor = self:VectorToColor(self:GetLightColor())
		local Brightness = self:GetBrightness()
		local pos = self:GetPos()
		local ang = self:GetAngles()
		local L = ProjectedTexture()

		if IsValid(L) then
			self.FR = L
			self:UpdateProjectedTexture(L, pos, ang, Shadows, FarZ, NearZ, LightColor, Brightness)
		end

		local up = ang:Up()
		EMPTY_ANG:Set(ang)
		EMPTY_ANG:RotateAroundAxis(up, 180)
		L = ProjectedTexture()

		if IsValid(L) then
			self.BK = L
			self:UpdateProjectedTexture(L, pos, EMPTY_ANG, Shadows, FarZ, NearZ, LightColor, Brightness)
		end

		EMPTY_ANG:Set(ang)
		EMPTY_ANG:RotateAroundAxis(up, 90)
		L = ProjectedTexture()

		if IsValid(L) then
			self.RI = L
			self:UpdateProjectedTexture(L, pos, EMPTY_ANG, Shadows, FarZ, NearZ, LightColor, Brightness)
		end

		EMPTY_ANG:Set(ang)
		EMPTY_ANG:RotateAroundAxis(up, 270)
		L = ProjectedTexture()

		if IsValid(L) then
			self.LF = L
			self:UpdateProjectedTexture(L, pos, EMPTY_ANG, Shadows, FarZ, NearZ, LightColor, Brightness)
		end

		local ri = ang:Right()
		EMPTY_ANG:Set(ang)
		EMPTY_ANG:RotateAroundAxis(ri, 90)
		L = ProjectedTexture()

		if IsValid(L) then
			self.UP = L
			self:UpdateProjectedTexture(L, pos, EMPTY_ANG, Shadows, FarZ, NearZ, LightColor, Brightness)
		end

		EMPTY_ANG:Set(ang)
		EMPTY_ANG:RotateAroundAxis(ri, 270)
		L = ProjectedTexture()

		if IsValid(L) then
			self.DN = L
			self:UpdateProjectedTexture(L, pos, EMPTY_ANG, Shadows, FarZ, NearZ, LightColor, Brightness)
		end
	end

	function ENT:UpdateAllProjectedTextures()
		local Shadows = self:GetShadows()
		local FarZ = self:GetFarZ()
		local NearZ = self:GetNearZ()
		-- local LightColor=
		--self:VectorToColor( self:GetLightColor() )
		local Brightness = self:GetBrightness()
		local pos = self:GetPos()
		local ang = self:GetAngles()
		local L = self.FR

		if IsValid(L) then
			self:UpdateProjectedTexture(L, pos, ang, Shadows, FarZ, NearZ, LightColor, Brightness)
		end

		local up = ang:Up()
		EMPTY_ANG:Set(ang)
		EMPTY_ANG:RotateAroundAxis(up, 180)
		L = self.BK

		if IsValid(L) then
			self:UpdateProjectedTexture(L, pos, EMPTY_ANG, Shadows, FarZ, NearZ, LightColor, Brightness)
		end

		EMPTY_ANG:Set(ang)
		EMPTY_ANG:RotateAroundAxis(up, 90)
		L = self.RI

		if IsValid(L) then
			self:UpdateProjectedTexture(L, pos, EMPTY_ANG, Shadows, FarZ, NearZ, LightColor, Brightness)
		end

		EMPTY_ANG:Set(ang)
		EMPTY_ANG:RotateAroundAxis(up, 270)
		L = self.LF

		if IsValid(L) then
			self:UpdateProjectedTexture(L, pos, EMPTY_ANG, Shadows, FarZ, NearZ, LightColor, Brightness)
		end

		local ri = ang:Right()
		EMPTY_ANG:Set(ang)
		EMPTY_ANG:RotateAroundAxis(ri, 90)
		L = self.UP

		if IsValid(L) then
			self:UpdateProjectedTexture(L, pos, EMPTY_ANG, Shadows, FarZ, NearZ, LightColor, Brightness)
		end

		EMPTY_ANG:Set(ang)
		EMPTY_ANG:RotateAroundAxis(ri, 270)
		L = self.DN

		if IsValid(L) then
			self:UpdateProjectedTexture(L, pos, EMPTY_ANG, Shadows, FarZ, NearZ, LightColor, Brightness)
		end
	end

	function ENT:RemoveAllProjectedTextures()
		local L = self.FR

		if IsValid(L) then
			L:Remove()
			self.FR = NULL
		end

		L = self.BK

		if IsValid(L) then
			L:Remove()
			self.BK = NULL
		end

		L = self.RI

		if IsValid(L) then
			L:Remove()
			self.RI = NULL
		end

		L = self.LF

		if IsValid(L) then
			L:Remove()
			self.LF = NULL
		end

		L = self.UP

		if IsValid(L) then
			L:Remove()
			self.UP = NULL
		end

		L = self.DN

		if IsValid(L) then
			L:Remove()
			self.DN = NULL
		end
	end

	function ENT:Initialize()
		self.PixVis = util.GetPixelVisibleHandle()

		if self:GetActiveState() then
			self.WasActive = true
			self:CreateAllProjectedTextures()
		else
			self.WasActive = false
		end
	end

	function ENT:Think()
		if self:GetActiveState() then
			if self.WasActive then
				self:UpdateAllProjectedTextures()
			else
				self.WasActive = true
				self:CreateAllProjectedTextures()
			end
		elseif self.WasActive then
			self.WasActive = false
			self:RemoveAllProjectedTextures()
		end
	end

	function ENT:OnRemove()
		self:RemoveAllProjectedTextures()
	end

	local spritemat = Material("sprites/light_ignorez")
	local helpermat = Material("sprites/helper_tri")

	function ENT:Draw()
		if (halo.RenderedEntity() ~= self) and self:GetActiveState() and self:GetDrawSprite() then
			local pos = self:GetPos()
			local Visible = util.PixelVisible(pos, 4, self.PixVis)

			if Visible and (Visible > 0.1) then
				local c = self:GetLightColor()
				local i = self:GetBrightness()
				local s = (i / 0.25) ^ 0.5 * 32
				s = s * Visible
				render.SetMaterial(spritemat)
				render.DrawSprite(pos, s, s, Color(self:ColorC(c.x), self:ColorC(c.y), self:ColorC(c.z), math.Round(Visible * 255)))
			end
		end

		if (not self:Camera()) and self:GetDrawHelper() then
			local pos = self:GetPos()
			local ang = self:GetAngles()
			local fw = ang:Forward()
			local ri = ang:Right()
			local up = ang:Up()
			render.SetMaterial(helpermat)
			render.DrawBeam(pos + (fw * 2), pos + (fw * 4), 0.5, 1, 0, self.c_r)
			render.DrawBeam(pos + (fw * -2), pos + (fw * -4), 0.5, 1, 0, self.c_c)
			render.DrawBeam(pos + (ri * 2), pos + (ri * 4), 0.5, 1, 0, self.c_g)
			render.DrawBeam(pos + (ri * -2), pos + (ri * -4), 0.5, 1, 0, self.c_m)
			render.DrawBeam(pos + (up * 2), pos + (up * 4), 0.5, 1, 0, self.c_b)
			render.DrawBeam(pos + (up * -2), pos + (up * -4), 0.5, 1, 0, self.c_y)
		end
	end
end
