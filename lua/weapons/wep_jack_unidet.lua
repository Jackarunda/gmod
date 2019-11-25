SWEP.PrintName			= "Universal Detonator"
SWEP.Author = "TheOnly8Z"
SWEP.Slot				= 5
SWEP.SlotPos			= 100
SWEP.DrawWeaponInfoBox  = false
SWEP.DrawCrosshair      = false

SWEP.ViewModelFlip		= true
SWEP.ViewModel			= "models/weapons/c_slam.mdl"
SWEP.WorldModel			= "models/weapons/w_slam.mdl"
SWEP.UseHands=true

SWEP.ViewModelFOV       = 70

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= false

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo		    = "none"

SWEP.ShowViewModel = true
SWEP.ShowWorldModel = false

SWEP.DetModes = {"remote", "timer", "proximity", "impact"}

SWEP.ViewModelBoneMods = {
	["Slam_base"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
	["Slam_panel"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) }
}

function SWEP:SetupDataTables()
	self:NetworkVar("Int",0,"DetMode")
	self:NetworkVar("Int",1,"Timer")
end

function SWEP:CanSee(selfent, ent)
	if not(IsValid(ent))then return false end
	local TargPos,SelfPos=ent:LocalToWorld(ent:OBBCenter()),selfent:LocalToWorld(selfent:OBBCenter())
	local Tr=util.TraceLine({
		start=SelfPos,
		endpos=TargPos,
		filter={selfent,ent},
		mask=MASK_SHOT+MASK_WATER
	})
	return not Tr.Hit
end

function SWEP:ShouldAttack(ent)
	if not(IsValid(ent))then return false end
	local Gaymode,PlayerToCheck=engine.ActiveGamemode(),nil
	if(ent:IsPlayer())then
		PlayerToCheck=ent
	elseif(ent:IsNPC())then
		local Class=ent:GetClass()
		return ent:Health()>0
	elseif(ent:IsVehicle())then
		PlayerToCheck=ent:GetDriver()
	end
	if(IsValid(PlayerToCheck))then
		if(PlayerToCheck.EZkillme)then return true end -- for testing
		if((self.Owner)and(PlayerToCheck==self.Owner))then return false end
		local Allies=(self.Owner and self.Owner.JModFriends)or {}
		if(table.HasValue(Allies,PlayerToCheck))then return false end
		local OurTeam=nil
		if(IsValid(self.Owner))then OurTeam=self.Owner:Team() end
		if(Gaymode=="sandbox")then return PlayerToCheck:Alive() end
		if(OurTeam)then return PlayerToCheck:Alive() and PlayerToCheck:Team()~=OurTeam end
		return PlayerToCheck:Alive()
	end
	return false
end

function SWEP:Initialize()
	self:SetHoldType("slam")
	self:SCKInitialize()
	self:SetDetMode(0)
	self:SetTimer(10)
	self.DetList = {}
	self.ProxList = {}
	
	timer.Create("UniDet_Proximity_" .. self:EntIndex(), 3, 0, function()
	
		for k, v in pairs(self.ProxList) do
			if !IsValid(v) or v:GetState() != 1 then table.remove(self.ProxList, k) continue end
			v:EmitSound("buttons/blip1.wav", 60, 40)
			for _,targ in pairs(ents.FindInSphere(v:GetPos(),150))do
				if(not(targ==self)and((targ:IsPlayer())or(targ:IsNPC())or(targ:IsVehicle())))then
					print(self:ShouldAttack(targ), self:CanSee(v, targ))
					if((self:ShouldAttack(targ))and(self:CanSee(v, targ)))then
						sound.Play("snds_jack_gmod/mine_warn.wav",v:GetPos(),60,50)
						timer.Simple(1*JMOD_CONFIG.MineDelay,function() if(IsValid(self))then v:Detonate() end end)
					end
				end
			end
		end
		
	end)
	
end

function SWEP:Deploy()
	self.Weapon:SendWeaponAnim(ACT_SLAM_DETONATOR_DRAW)
end

function SWEP:OnRemove()
	timer.Remove("UniDet_Proximity_" .. self:EntIndex())
end

function SWEP:PrimaryAttack()
	if self:GetNextPrimaryFire() > CurTime() then return end
	
	local trace = self.Owner:GetEyeTrace()
	local exp = trace.Entity
	if (IsValid(exp) and exp.JModUniDet == true and exp:GetState() == 0 and trace.HitPos:Distance(self.Owner:GetPos()) <= 100) then
		exp:SetDetMode(self:GetDetMode())
		exp:SetOwner(self.Owner)
		exp:SetState(1)
		if self:GetDetMode() == 0 then
			table.insert(self.DetList, exp)
		elseif self:GetDetMode() == 1 then
			local t = self:GetTimer()
			exp:EmitSound("buttons/blip1.wav", 60, 100)
			timer.Create("UniDet_" .. exp:EntIndex(), 1, t, function() 
				if !IsValid(exp) then return end
				if exp:GetState() != 1 then return end
				local rep = timer.RepsLeft("UniDet_" .. exp:EntIndex())
				if rep == 0 then exp:Detonate() 
				else exp:EmitSound("buttons/blip1.wav", 60, 100 + (t-rep)/t*100)
				end 
			end)
		elseif self:GetDetMode() == 2 then
			table.insert(self.ProxList, exp)
		elseif self:GetDetMode() == 3 then
			-- Handled per entity
		end
		self:SetNextPrimaryFire(CurTime() + 0.5)
		self:EmitSound("snd_jack_minearm.wav",60,100)
	end
	

end

function SWEP:SecondaryAttack()
	if self:GetNextSecondaryFire() > CurTime() then return end
	if table.Count(self.DetList) == 0 then self:EmitSound("buttons/button10.wav") return end
	self.Weapon:SendWeaponAnim(ACT_SLAM_DETONATOR_DETONATE)
	self:EmitSound("snd_jack_detonator.wav")
	self:SetNextSecondaryFire(CurTime() + 2)
	timer.Simple(1, function()
		if !IsValid(self) then return end
		for k, v in pairs(self.DetList) do
			if IsValid(v) then v:Detonate() end
		end
		self.DetList = {}
	end)
end

local NextReload = 0
function SWEP:Reload()
	if NextReload > CurTime() then return end
	NextReload = CurTime() + 0.3
	
	if self:GetDetMode() == 1 then
		if self:GetTimer() >= 20 then
			self:SetDetMode(2)
		else
			self:SetTimer(self:GetTimer() + 5)
		end
	else
		self:SetDetMode(self:GetDetMode() + 1)
		if self:GetDetMode() >= 4 then 
			self:SetDetMode(0)
		elseif self:GetDetMode() == 1 then 
			self:SetTimer(5)
		end
	end
	self:EmitSound("common/wpn_select.wav", 30, 150)
	self.Weapon:SendWeaponAnim(ACT_SLAM_DETONATOR_DETONATE)
end

function SWEP:DrawHUD()
	local W,H=ScrW(),ScrH()
	local str = "Arming mode: " .. self.DetModes[self:GetDetMode()+1]
	if self:GetDetMode() == 1 then str = str .. " (" .. self:GetTimer() .. "s)" end
	draw.SimpleTextOutlined(str,"Trebuchet24",W*.5,H*.9-30,Color(255,255,255,200),TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP,3,Color(0,0,0,200))
	draw.SimpleTextOutlined("LMB: Arm explosives","Trebuchet24",W*.4,H*.9,Color(255,255,255,150),TEXT_ALIGN_LEFT,TEXT_ALIGN_TOP,3,Color(0,0,0,100))
	draw.SimpleTextOutlined("RMB: Trigger detonator (remote)","Trebuchet24",W*.4,H*.9+30,Color(255,255,255,150),TEXT_ALIGN_LEFT,TEXT_ALIGN_TOP,3,Color(0,0,0,100))
	draw.SimpleTextOutlined("R: Select detonation mode","Trebuchet24",W*.4,H*.9+60,Color(255,255,255,150),TEXT_ALIGN_LEFT,TEXT_ALIGN_TOP,3,Color(0,0,0,100))
end

-- SCK code

function SWEP:SCKHolster()
	if CLIENT and IsValid(self.Owner) then
		local vm = self.Owner:GetViewModel()
		if IsValid(vm) then
			self:ResetBonePositions(vm)
		end
	end
end

function SWEP:SCKInitialize()

	if CLIENT then
	
		// Create a new table for every weapon instance
		self.VElements = table.FullCopy( self.VElements )
		self.WElements = table.FullCopy( self.WElements )
		self.ViewModelBoneMods = table.FullCopy( self.ViewModelBoneMods )

		self:CreateModels(self.VElements) // create viewmodels
		self:CreateModels(self.WElements) // create worldmodels
		
		// init view model bone build function
		if IsValid(self.Owner) then
			local vm = self.Owner:GetViewModel()
			if IsValid(vm) then
				self:ResetBonePositions(vm)
			end
			
			// Init viewmodel visibility
			if (self.ShowViewModel == nil or self.ShowViewModel) then
				if(IsValid(vm))then
					vm:SetColor(Color(255,255,255,255))
				end
			else
				// we set the alpha to 1 instead of 0 because else ViewModelDrawn stops being called
				vm:SetColor(Color(255,255,255,1))
				// ^ stopped working in GMod 13 because you have to do Entity:SetRenderMode(1) for translucency to kick in
				// however for some reason the view model resets to render mode 0 every frame so we just apply a debug material to prevent it from drawing
				vm:SetMaterial("Debug/hsv")
			end
		end
		
	end

end

if(CLIENT)then
	SWEP.vRenderOrder = nil
	function SWEP:SCKViewModelDrawn()
		local vm = self.Owner:GetViewModel()
		if !IsValid(vm) then return end
		
		if (!self.VElements) then return end
		
		self:UpdateBonePositions(vm)

		if (!self.vRenderOrder) then
			
			// we build a render order because sprites need to be drawn after models
			self.vRenderOrder = {}

			for k, v in pairs( self.VElements ) do
				if (v.type == "Model") then
					table.insert(self.vRenderOrder, 1, k)
				elseif (v.type == "Sprite" or v.type == "Quad") then
					table.insert(self.vRenderOrder, k)
				end
			end
			
		end

		for k, name in ipairs( self.vRenderOrder ) do
		
			local v = self.VElements[name]
			if (!v) then self.vRenderOrder = nil break end
			if (v.hide) then continue end
			
			local model = v.modelEnt
			local sprite = v.spriteMaterial
			
			if (!v.bone) then continue end
			
			local pos, ang = self:GetBoneOrientation( self.VElements, v, vm )
			
			if (!pos) then continue end
			
			if (v.type == "Model" and IsValid(model)) then

				model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z )
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)

				model:SetAngles(ang)
				//model:SetModelScale(v.size)
				local matrix = Matrix()
				matrix:Scale(v.size)
				model:EnableMatrix( "RenderMultiply", matrix )
				
				if (v.material == "") then
					model:SetMaterial("")
				elseif (model:GetMaterial() != v.material) then
					model:SetMaterial( v.material )
				end
				
				if (v.skin and v.skin != model:GetSkin()) then
					model:SetSkin(v.skin)
				end
				
				if (v.bodygroup) then
					for k, v in pairs( v.bodygroup ) do
						if (model:GetBodygroup(k) != v) then
							model:SetBodygroup(k, v)
						end
					end
				end
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(true)
				end
				
				render.SetColorModulation(v.color.r/255, v.color.g/255, v.color.b/255)
				render.SetBlend(v.color.a/255)
				model:DrawModel()
				render.SetBlend(1)
				render.SetColorModulation(1, 1, 1)
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(false)
				end
				
			elseif (v.type == "Sprite" and sprite) then
				
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				render.SetMaterial(sprite)
				render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)
				
			elseif (v.type == "Quad" and v.draw_func) then
				
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				
				cam.Start3D2D(drawpos, ang, v.size)
					v.draw_func( self )
				cam.End3D2D()

			end
			
		end
		
	end

	SWEP.wRenderOrder = nil
	function SWEP:SCKDrawWorldModel()
		if (self.ShowWorldModel == nil or self.ShowWorldModel) then
			self:DrawModel()
		end
		
		if (!self.WElements) then return end
		
		if (!self.wRenderOrder) then

			self.wRenderOrder = {}

			for k, v in pairs( self.WElements ) do
				if (v.type == "Model") then
					table.insert(self.wRenderOrder, 1, k)
				elseif (v.type == "Sprite" or v.type == "Quad") then
					table.insert(self.wRenderOrder, k)
				end
			end

		end
		
		if (IsValid(self.Owner)) then
			bone_ent = self.Owner
		else
			// when the weapon is dropped
			bone_ent = self
		end
		
		for k, name in pairs( self.wRenderOrder ) do
		
			local v = self.WElements[name]
			if (!v) then self.wRenderOrder = nil break end
			if (v.hide) then continue end
			
			local pos, ang
			
			if (v.bone) then
				pos, ang = self:GetBoneOrientation( self.WElements, v, bone_ent )
			else
				pos, ang = self:GetBoneOrientation( self.WElements, v, bone_ent, "ValveBiped.Bip01_R_Hand" )
			end
			
			if (!pos) then continue end
			
			local model = v.modelEnt
			local sprite = v.spriteMaterial
			
			if (v.type == "Model" and IsValid(model)) then

				model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z )
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)

				model:SetAngles(ang)
				//model:SetModelScale(v.size)
				local matrix = Matrix()
				matrix:Scale(v.size)
				model:EnableMatrix( "RenderMultiply", matrix )
				
				if (v.material == "") then
					model:SetMaterial("")
				elseif (model:GetMaterial() != v.material) then
					model:SetMaterial( v.material )
				end
				
				if (v.skin and v.skin != model:GetSkin()) then
					model:SetSkin(v.skin)
				end
				
				if (v.bodygroup) then
					for k, v in pairs( v.bodygroup ) do
						if (model:GetBodygroup(k) != v) then
							model:SetBodygroup(k, v)
						end
					end
				end
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(true)
				end
				
				render.SetColorModulation(v.color.r/255, v.color.g/255, v.color.b/255)
				render.SetBlend(v.color.a/255)
				model:DrawModel()
				render.SetBlend(1)
				render.SetColorModulation(1, 1, 1)
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(false)
				end
				
			elseif (v.type == "Sprite" and sprite) then
				
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				render.SetMaterial(sprite)
				render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)
				
			elseif (v.type == "Quad" and v.draw_func) then
				
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				
				cam.Start3D2D(drawpos, ang, v.size)
					v.draw_func( self )
				cam.End3D2D()

			end
			
		end
		
	end

	function SWEP:GetBoneOrientation( basetab, tab, ent, bone_override )
		
		local bone, pos, ang
		if (tab.rel and tab.rel != "") then
			
			local v = basetab[tab.rel]
			
			if (!v) then return end
			
			// Technically, if there exists an element with the same name as a bone
			// you can get in an infinite loop. Let's just hope nobody's that stupid.
			pos, ang = self:GetBoneOrientation( basetab, v, ent )
			
			if (!pos) then return end
			
			pos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
			ang:RotateAroundAxis(ang:Up(), v.angle.y)
			ang:RotateAroundAxis(ang:Right(), v.angle.p)
			ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				
		else
		
			bone = ent:LookupBone(bone_override or tab.bone)

			if (!bone) then return end
			
			pos, ang = Vector(0,0,0), Angle(0,0,0)
			local m = ent:GetBoneMatrix(bone)
			if (m) then
				pos, ang = m:GetTranslation(), m:GetAngles()
			end
			
			if (IsValid(self.Owner) and self.Owner:IsPlayer() and 
				ent == self.Owner:GetViewModel() and self.ViewModelFlip) then
				ang.r = -ang.r // Fixes mirrored models
			end
		
		end
		
		return pos, ang
	end

	function SWEP:CreateModels( tab )

		if (!tab) then return end

		-- Create the clientside models here because Garry says we can't do it in the render hook
		for k, v in pairs( tab ) do
			if (v.type == "Model" and v.model and v.model != "" and (!IsValid(v.modelEnt) or v.createdModel != v.model) and 
					string.find(v.model, ".mdl") and file.Exists (v.model, "GAME") ) then
				
				v.modelEnt = ClientsideModel(v.model, RENDER_GROUP_VIEW_MODEL_OPAQUE)
				if (IsValid(v.modelEnt)) then
					v.modelEnt:SetPos(self:GetPos())
					v.modelEnt:SetAngles(self:GetAngles())
					v.modelEnt:SetParent(self)
					v.modelEnt:SetNoDraw(true)
					v.createdModel = v.model
				else
					v.modelEnt = nil
				end
				
			elseif (v.type == "Sprite" and v.sprite and v.sprite != "" and (!v.spriteMaterial or v.createdSprite != v.sprite) 
				and file.Exists ("materials/"..v.sprite..".vmt", "GAME")) then
				
				local name = v.sprite.."-"
				local params = { ["$basetexture"] = v.sprite }
				// make sure we create a unique name based on the selected options
				local tocheck = { "nocull", "additive", "vertexalpha", "vertexcolor", "ignorez" }
				for i, j in pairs( tocheck ) do
					if (v[j]) then
						params["$"..j] = 1
						name = name.."1"
					else
						name = name.."0"
					end
				end

				v.createdSprite = v.sprite
				v.spriteMaterial = CreateMaterial(name,"UnlitGeneric",params)
				
			end
		end
		
	end
	
	local allbones
	local hasGarryFixedBoneScalingYet = false

	function SWEP:UpdateBonePositions(vm)
		
		if self.ViewModelBoneMods then
			
			if (!vm:GetBoneCount()) then return end
			
			// !! WORKAROUND !! //
			// We need to check all model names :/
			local loopthrough = self.ViewModelBoneMods
			if (!hasGarryFixedBoneScalingYet) then
				allbones = {}
				for i=0, vm:GetBoneCount() do
					local bonename = vm:GetBoneName(i)
					if (self.ViewModelBoneMods[bonename]) then 
						allbones[bonename] = self.ViewModelBoneMods[bonename]
					else
						allbones[bonename] = { 
							scale = Vector(1,1,1),
							pos = Vector(0,0,0),
							angle = Angle(0,0,0)
						}
					end
				end
				
				loopthrough = allbones
			end
			// !! ----------- !! //
			
			for k, v in pairs( loopthrough ) do
				local bone = vm:LookupBone(k)
				if (!bone) then continue end
				
				// !! WORKAROUND !! //
				local s = Vector(v.scale.x,v.scale.y,v.scale.z)
				local p = Vector(v.pos.x,v.pos.y,v.pos.z)
				local ms = Vector(1,1,1)
				if (!hasGarryFixedBoneScalingYet) then
					local cur = vm:GetBoneParent(bone)
					while(cur >= 0) do
						local pscale = loopthrough[vm:GetBoneName(cur)].scale
						ms = ms * pscale
						cur = vm:GetBoneParent(cur)
					end
				end
				
				s = s * ms
				// !! ----------- !! //
				
				if vm:GetManipulateBoneScale(bone) != s then
					vm:ManipulateBoneScale( bone, s )
				end
				if vm:GetManipulateBoneAngles(bone) != v.angle then
					vm:ManipulateBoneAngles( bone, v.angle )
				end
				if vm:GetManipulateBonePosition(bone) != p then
					vm:ManipulateBonePosition( bone, p )
				end
			end
		else
			self:ResetBonePositions(vm)
		end
		   
	end
	 
	function SWEP:ResetBonePositions(vm)
		
		if (!vm:GetBoneCount()) then return end
		for i=0, vm:GetBoneCount() do
			vm:ManipulateBoneScale( i, Vector(1, 1, 1) )
			vm:ManipulateBoneAngles( i, Angle(0, 0, 0) )
			vm:ManipulateBonePosition( i, Vector(0, 0, 0) )
		end
		
	end
end