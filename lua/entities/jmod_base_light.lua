AddCSLuaFile()
DEFINE_BASECLASS("base_anim")
ENT.Spawnable = false
ENT.DisableDuplicator = false
ENT.Editable = true
ENT.Author = "tau"
ENT.Contact = "http://steamcommunity.com/id/blue_orng/"
ENT.Category = "Render"
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
util.PrecacheModel("models/error.mdl")

function ENT:ColorC(val)
	return math.Clamp(math.Round(val), 0, 255)
end

function ENT:ColorToString(rgb)
	return tostring(self:ColorC(rgb.r)) .. " " .. tostring(self:ColorC(rgb.g)) .. " " .. tostring(self:ColorC(rgb.b))
end

function ENT:ColorIntensityToString(rgb, i)
	local i_int = math.Round(i)
	if i_int < 1 then return "0 0 0 0" end

	return self:ColorToString(rgb) .. " " .. tostring(i_int)
end

function ENT:BoolToString(b)
	if b then
		return "1"
	else
		return "0"
	end
end

function ENT:VectorToColor(vec)
	return Color(self:ColorC(vec.x), self:ColorC(vec.y), self:ColorC(vec.z))
end

if SERVER then
	function ENT:Initialize()
		self:SetModel("models/error.mdl")
		self:SetRenderMode(RENDERMODE_TRANSALPHA)
		self:DrawShadow(false)
		local min, max = Vector(-2, -2, -2), Vector(2, 2, 2)
		self:PhysicsInitBox(min, max)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetCollisionGroup(COLLISION_GROUP_WORLD)
		self:SetCollisionBounds(min, max)
		local physobj = self:GetPhysicsObject()

		if IsValid(physobj) then
			physobj:EnableGravity(false)
			physobj:Wake()
		end
	end

	function ENT:material_tool(ply, trace)
		if not IsValid(ply) then return end
		local wep = ply:GetActiveWeapon()
		if (not IsValid(wep)) or (wep:GetClass() ~= "gmod_tool") or (wep.Mode ~= "material") then return end
		local toolobj = wep.Tool["material"]
		if not toolobj then return end

		if ply:KeyPressed(IN_ATTACK) then
			local texname = "effects/flashlight001"
			local matname = toolobj:GetClientInfo("override")

			if isstring(matname) then
				local mat = Material(matname)

				if mat and (not mat:IsError()) then
					local shader = mat:GetShader()

					if isstring(shader) and (string.lower(string.sub(shader, 1, 7)) == "refract") then
						texname = mat:GetString("$refracttinttexture")
					else
						texname = mat:GetString("$basetexture")
					end

					if not isstring(texname) then
						texname = "effects/flashlight001"
					end
				end
			end

			self:SetLightTexture(texname)
			wep:DoShootEffect(trace.HitPos, trace.HitNormal, self, trace.PhysicsBone, IsFirstTimePredicted())
		elseif ply:KeyPressed(IN_ATTACK2) then
			self:SetLightTexture("effects/flashlight001")
			wep:DoShootEffect(trace.HitPos, trace.HitNormal, self, trace.PhysicsBone, IsFirstTimePredicted())
		end
	end

	function ENT:lamp_tool(ply, trace)
		if not IsValid(ply) then return end
		local wep = ply:GetActiveWeapon()
		if (not IsValid(wep)) or (wep:GetClass() ~= "gmod_tool") or (wep.Mode ~= "lamp") then return end
		local toolobj = wep.Tool["lamp"]
		if not toolobj then return end

		if ply:KeyPressed(IN_ATTACK) then
			local texname = "effects/flashlight001"
			local matname = toolobj:GetClientInfo("texture")

			if isstring(matname) then
				local mat = Material(matname)

				if mat and (not mat:IsError()) then
					texname = mat:GetString("$basetexture")

					if not isstring(texname) then
						texname = "effects/flashlight001"
					end
				end
			end

			self:SetLightTexture(texname)
			wep:DoShootEffect(trace.HitPos, trace.HitNormal, self, trace.PhysicsBone, IsFirstTimePredicted())
		end
	end

	function ENT:colour_tool(ply, trace)
		if not IsValid(ply) then return end
		local wep = ply:GetActiveWeapon()
		if (not IsValid(wep)) or (wep:GetClass() ~= "gmod_tool") or (wep.Mode ~= "colour") then return end
		local toolobj = wep.Tool["colour"]
		if not toolobj then return end

		if ply:KeyPressed(IN_ATTACK) then
			self:SetLightColor(Vector(toolobj:GetClientNumber("r", 255), toolobj:GetClientNumber("g", 255), toolobj:GetClientNumber("b", 255)))
			wep:DoShootEffect(trace.HitPos, trace.HitNormal, self, trace.PhysicsBone, IsFirstTimePredicted())
		elseif ply:KeyPressed(IN_ATTACK2) then
			self:SetLightColor(Vector(255, 255, 255))
			wep:DoShootEffect(trace.HitPos, trace.HitNormal, self, trace.PhysicsBone, IsFirstTimePredicted())
		end
	end

	function ENT:light_tool(ply, trace)
		if not IsValid(ply) then return end
		local wep = ply:GetActiveWeapon()
		if (not IsValid(wep)) or (wep:GetClass() ~= "gmod_tool") or (wep.Mode ~= "light") then return end
		local toolobj = wep.Tool["light"]
		if not toolobj then return end

		if ply:KeyPressed(IN_ATTACK) or ply:KeyPressed(IN_ATTACK2) then
			self:SetLightColor(Vector(toolobj:GetClientNumber("r", 255), toolobj:GetClientNumber("g", 255), toolobj:GetClientNumber("b", 255)))
			wep:DoShootEffect(trace.HitPos, trace.HitNormal, self, trace.PhysicsBone, IsFirstTimePredicted())
		end
	end
end

if CLIENT then
	ENT.c_r = Color(255, 0, 0, 255)
	ENT.c_c = Color(0, 255, 255, 255)
	ENT.c_g = Color(0, 255, 0, 255)
	ENT.c_m = Color(255, 0, 255, 255)
	ENT.c_b = Color(0, 0, 255, 255)
	ENT.c_y = Color(255, 255, 0, 255)

	function ENT:Camera()
		local wep = LocalPlayer():GetActiveWeapon()

		return IsValid(wep) and (wep:GetClass() == "gmod_camera")
	end
end
