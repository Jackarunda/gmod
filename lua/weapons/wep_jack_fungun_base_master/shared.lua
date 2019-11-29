if(SERVER)then
	AddCSLuaFile("shared.lua")
end

if(CLIENT)then
	SWEP.DrawAmmo=false
	SWEP.DrawCrosshair=false -- crosshairs are for sopping wet pussies
	SWEP.DrawWeaponInfoBox=false
	SWEP.BounceWeaponIcon=false
end

SWEP.DrawAmmo=false
SWEP.Spawnable=false
SWEP.AdminSpawnable=false

SWEP.Primary.ClipSize=-1
SWEP.Primary.DefaultClize=-1
SWEP.Primary.Ammo="none"
SWEP.Primary.Automatic=false
SWEP.Secondary.ClipSize=-1
SWEP.Secondary.DefaultClip=-1
SWEP.Secondary.Ammo="none"
SWEP.Secondary.Automatic=false

SWEP.IsAJackyFunGun=true
SWEP.DisplaysOn=false
SWEP.ShowWorldModel=false
SWEP.PowerType="High-Density Rechargeable Lithium-Ion Battery"
SWEP.HeatMul=.6
SWEP.ConsumptionMul=17.5

function SWEP:SecondaryAttack()
	GlobalJackyFGDisplayToggle(self)
end

function SWEP:Reload()
	GlobalJackyFGReloadKey(self)
end

function SWEP:OnRemove()
	self:SCKHolster()
end

/*------------------------------------------------------------------------------------

	Below this line is Clavus' SWEP Construction Kit base code.
	Clavus is KREDIT TO TEEM
	ALL HAIL CLAVUS

------------------------------------------------------------------------------------*/

function SWEP:SCKInitialize()

	if CLIENT then
	
		// Create a new table for every weapon instance
		self.VElements=table.FullCopy( self.VElements )
		self.WElements=table.FullCopy( self.WElements )
		self.ViewModelBoneMods=table.FullCopy( self.ViewModelBoneMods )

		self:CreateModels(self.VElements) // create viewmodels
		self:CreateModels(self.WElements) // create worldmodels
		
		// init view model bone build function
		if IsValid(self.Owner)then
			local vm=self.Owner:GetViewModel()
			if IsValid(vm)then
				self:ResetBonePositions(vm)
			end
			
			// Init viewmodel visibility
			if(self.ShowViewModel==nil or self.ShowViewModel)then
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

function SWEP:SCKHolster()
	if CLIENT and IsValid(self.Owner)then
		local vm=self.Owner:GetViewModel()
		if IsValid(vm)then
			self:ResetBonePositions(vm)
		end
	end

end

if CLIENT then

	SWEP.vRenderOrder=nil
	function SWEP:SCKViewModelDrawn()

		local vm=self.Owner:GetViewModel()
		if !IsValid(vm)then return end
		
		if(!self.VElements)then return end
		
		self:UpdateBonePositions(vm)

		if(!self.vRenderOrder)then
			
			// we build a render order because sprites need to be drawn after models
			self.vRenderOrder={}

			for k, v in pairs( self.VElements ) do
				if(v.type=="Model")then
					table.insert(self.vRenderOrder, 1, k)
				elseif(v.type=="Sprite" or v.type=="Quad")then
					table.insert(self.vRenderOrder, k)
				end
			end
			
		end

		for k, name in ipairs( self.vRenderOrder ) do
		
			local v=self.VElements[name]
			if(!v)then self.vRenderOrder=nil break end
			if(v.hide)then continue end
			
			local model=v.modelEnt
			local sprite=v.spriteMaterial
			
			if(!v.bone)then continue end
			
			local pos, ang=self:GetBoneOrientation( self.VElements, v, vm )
			
			if(!pos)then continue end
			
			if(v.type=="Model" and IsValid(model))then

				model:SetPos(pos+ang:Forward()*v.pos.x+ang:Right()*v.pos.y+ang:Up()*v.pos.z )
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)

				model:SetAngles(ang)
				//model:SetModelScale(v.size)
				local matrix=Matrix()
				matrix:Scale(v.size)
				model:EnableMatrix( "RenderMultiply", matrix )
				
				if(v.material=="")then
					model:SetMaterial("")
				elseif(model:GetMaterial() != v.material)then
					model:SetMaterial( v.material )
				end
				
				if(v.skin and v.skin != model:GetSkin())then
					model:SetSkin(v.skin)
				end
				
				if(v.bodygroup)then
					for k, v in pairs( v.bodygroup ) do
						if(model:GetBodygroup(k) != v)then
							model:SetBodygroup(k, v)
						end
					end
				end
				
				if(v.surpresslightning)then
					render.SuppressEngineLighting(true)
				end
				
				render.SetColorModulation(v.color.r/255, v.color.g/255, v.color.b/255)
				render.SetBlend(v.color.a/255)
				model:DrawModel()
				render.SetBlend(1)
				render.SetColorModulation(1, 1, 1)
				
				if(v.surpresslightning)then
					render.SuppressEngineLighting(false)
				end
				
			elseif(v.type=="Sprite" and sprite)then
				
				local drawpos=pos+ang:Forward()*v.pos.x+ang:Right()*v.pos.y+ang:Up()*v.pos.z
				render.SetMaterial(sprite)
				render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)
				
			elseif(v.type=="Quad" and v.draw_func)then
				
				local drawpos=pos+ang:Forward()*v.pos.x+ang:Right()*v.pos.y+ang:Up()*v.pos.z
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				
				cam.Start3D2D(drawpos, ang, v.size)
					v.draw_func( self )
				cam.End3D2D()

			end
			
		end
		
	end

	SWEP.wRenderOrder=nil
	function SWEP:SCKDrawWorldModel()
		
		if(self.ShowWorldModel==nil or self.ShowWorldModel)then
			self:DrawModel()
		end
		
		if(!self.WElements)then return end
		
		if(!self.wRenderOrder)then

			self.wRenderOrder={}

			for k, v in pairs( self.WElements ) do
				if(v.type=="Model")then
					table.insert(self.wRenderOrder, 1, k)
				elseif(v.type=="Sprite" or v.type=="Quad")then
					table.insert(self.wRenderOrder, k)
				end
			end

		end
		
		if(IsValid(self.Owner))then
			bone_ent=self.Owner
		else
			// when the weapon is dropped
			bone_ent=self
		end
		
		for k, name in pairs( self.wRenderOrder ) do
		
			local v=self.WElements[name]
			if(!v)then self.wRenderOrder=nil break end
			if(v.hide)then continue end
			
			local pos, ang
			
			if(v.bone)then
				pos, ang=self:GetBoneOrientation( self.WElements, v, bone_ent )
			else
				pos, ang=self:GetBoneOrientation( self.WElements, v, bone_ent, "ValveBiped.Bip01_R_Hand" )
			end
			
			if(!pos)then continue end
			
			local model=v.modelEnt
			local sprite=v.spriteMaterial
			
			if(v.type=="Model" and IsValid(model))then

				model:SetPos(pos+ang:Forward()*v.pos.x+ang:Right()*v.pos.y+ang:Up()*v.pos.z )
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)

				model:SetAngles(ang)
				//model:SetModelScale(v.size)
				local matrix=Matrix()
				matrix:Scale(v.size)
				model:EnableMatrix( "RenderMultiply", matrix )
				
				if(v.material=="")then
					model:SetMaterial("")
				elseif(model:GetMaterial() != v.material)then
					model:SetMaterial( v.material )
				end
				
				if(v.skin and v.skin != model:GetSkin())then
					model:SetSkin(v.skin)
				end
				
				if(v.bodygroup)then
					for k, v in pairs( v.bodygroup ) do
						if(model:GetBodygroup(k) != v)then
							model:SetBodygroup(k, v)
						end
					end
				end
				
				if(v.surpresslightning)then
					render.SuppressEngineLighting(true)
				end
				
				render.SetColorModulation(v.color.r/255, v.color.g/255, v.color.b/255)
				render.SetBlend(v.color.a/255)
				model:DrawModel()
				render.SetBlend(1)
				render.SetColorModulation(1, 1, 1)
				
				if(v.surpresslightning)then
					render.SuppressEngineLighting(false)
				end
				
			elseif(v.type=="Sprite" and sprite)then
				
				local drawpos=pos+ang:Forward()*v.pos.x+ang:Right()*v.pos.y+ang:Up()*v.pos.z
				render.SetMaterial(sprite)
				render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)
				
			elseif(v.type=="Quad" and v.draw_func)then
				
				local drawpos=pos+ang:Forward()*v.pos.x+ang:Right()*v.pos.y+ang:Up()*v.pos.z
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
		if(tab.rel and tab.rel != "")then
			
			local v=basetab[tab.rel]
			
			if(!v)then return end
			
			// Technically, if there exists an element with the same name as a bone
			// you can get in an infinite loop. Let's just hope nobody's that stupid.
			pos, ang=self:GetBoneOrientation( basetab, v, ent )
			
			if(!pos)then return end
			
			pos=pos+ang:Forward()*v.pos.x+ang:Right()*v.pos.y+ang:Up()*v.pos.z
			ang:RotateAroundAxis(ang:Up(), v.angle.y)
			ang:RotateAroundAxis(ang:Right(), v.angle.p)
			ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				
		else
		
			bone=ent:LookupBone(bone_override or tab.bone)

			if(!bone)then return end
			
			pos, ang=Vector(0,0,0), Angle(0,0,0)
			local m=ent:GetBoneMatrix(bone)
			if(m)then
				pos, ang=m:GetTranslation(), m:GetAngles()
			end
			
			if(IsValid(self.Owner) and self.Owner:IsPlayer() and 
				ent==self.Owner:GetViewModel() and self.ViewModelFlip)then
				ang.r=-ang.r // Fixes mirrored models
			end
		
		end
		
		return pos, ang
	end

	function SWEP:CreateModels( tab )

		if(!tab)then return end

		// Create the clientside models here because Garry says we can't do it in the render hook
		for k, v in pairs( tab ) do
			if(v.type=="Model" and v.model and v.model != "" and (!IsValid(v.modelEnt) or v.createdModel != v.model) and 
					string.find(v.model, ".mdl") and file.Exists (v.model, "GAME") )then
				
				v.modelEnt=ClientsideModel(v.model, RENDER_GROUP_VIEW_MODEL_OPAQUE)
				if(IsValid(v.modelEnt))then
					v.modelEnt:SetPos(self:GetPos())
					v.modelEnt:SetAngles(self:GetAngles())
					v.modelEnt:SetParent(self)
					v.modelEnt:SetNoDraw(true)
					v.createdModel=v.model
				else
					v.modelEnt=nil
				end
				
			elseif(v.type=="Sprite" and v.sprite and v.sprite != "" and (!v.spriteMaterial or v.createdSprite != v.sprite) 
				and file.Exists ("materials/"..v.sprite..".vmt", "GAME"))then
				
				local name=v.sprite.."-"
				local params={ ["$basetexture"]=v.sprite }
				// make sure we create a unique name based on the selected options
				local tocheck={ "nocull", "additive", "vertexalpha", "vertexcolor", "ignorez" }
				for i, j in pairs( tocheck ) do
					if(v[j])then
						params["$"..j]=1
						name=name.."1"
					else
						name=name.."0"
					end
				end

				v.createdSprite=v.sprite
				v.spriteMaterial=CreateMaterial(name,"UnlitGeneric",params)
				
			end
		end
		
	end
	
	local allbones
	local hasGarryFixedBoneScalingYet=false

	function SWEP:UpdateBonePositions(vm)
		
		if self.ViewModelBoneMods then
			
			if(!vm:GetBoneCount())then return end
			
			// !! WORKAROUND !! //
			// We need to check all model names :/
			local loopthrough=self.ViewModelBoneMods
			if(!hasGarryFixedBoneScalingYet)then
				allbones={}
				for i=0, vm:GetBoneCount() do
					local bonename=vm:GetBoneName(i)
					if(self.ViewModelBoneMods[bonename])then 
						allbones[bonename]=self.ViewModelBoneMods[bonename]
					else
						allbones[bonename]={ 
							scale=Vector(1,1,1),
							pos=Vector(0,0,0),
							angle=Angle(0,0,0)
						}
					end
				end
				
				loopthrough=allbones
			end
			// !! ----------- !! //
			
			for k, v in pairs( loopthrough ) do
				local bone=vm:LookupBone(k)
				if(!bone)then continue end
				
				// !! WORKAROUND !! //
				local s=Vector(v.scale.x,v.scale.y,v.scale.z)
				local p=Vector(v.pos.x,v.pos.y,v.pos.z)
				local ms=Vector(1,1,1)
				if(!hasGarryFixedBoneScalingYet)then
					local cur=vm:GetBoneParent(bone)
					while(cur>=0) do
						local pscale=loopthrough[vm:GetBoneName(cur)].scale
						ms=ms*pscale
						cur=vm:GetBoneParent(cur)
					end
				end
				
				s=s*ms
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
		
		if(!vm:GetBoneCount())then return end
		for i=0, vm:GetBoneCount() do
			vm:ManipulateBoneScale( i, Vector(1, 1, 1) )
			vm:ManipulateBoneAngles( i, Angle(0, 0, 0) )
			vm:ManipulateBonePosition( i, Vector(0, 0, 0) )
		end
		
	end
	
end