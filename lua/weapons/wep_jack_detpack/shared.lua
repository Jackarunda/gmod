// Variables that are used on both client and server

SWEP.ViewModelFlip		= true
SWEP.ViewModel			= "models/weapons/c_slam.mdl"
SWEP.WorldModel			= "models/weapons/w_slam.mdl"
SWEP.UseHands=true

SWEP.ViewModelFOV	  =80

SWEP.Spawnable			= false
SWEP.AdminSpawnable		= false

SWEP.Primary.Recoil		= 5
SWEP.Primary.Damage		= 0
SWEP.Primary.NumShots	= 0
SWEP.Primary.Cone		= 0.075
SWEP.Primary.Delay 		= 1.5

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.HasJackyDynamicHoldTypes=true

SWEP.ShowViewModel=true
SWEP.ShowWorldModel=false
SWEP.VElements={
	["block"]={ type="Model", model="models/props_misc/tobacco_box-1.mdl", bone="ValveBiped.Bip01_R_Hand", rel="", pos=Vector(6.5, -3, -2), angle=Angle(-29, -110, -23.524), size=Vector(1, 1, 1), color=Color(255, 255, 255, 255), surpresslightning=false, material="models/entities/mat_jack_c4", skin=0, bodygroup={} }
}
SWEP.WElements={
	["pack"]={ type="Model", model="models/props_misc/tobacco_box-1.mdl", bone="ValveBiped.Bip01_R_Hand", rel="", pos=Vector(3.099, 6.5, -2.274), angle=Angle(-68.524, 7.158, 0), size=Vector(1, 1, 1), color=Color(255, 255, 255, 255), surpresslightning=false, material="models/entities/mat_jack_c4", skin=0, bodygroup={} }
}
SWEP.ViewModelBoneMods={
	["Slam_base"]={ scale=Vector(0.009, 0.009, 0.009), pos=Vector(0, 0, 0), angle=Angle(0, 0, 0) },
	["Slam_panel"]={ scale=Vector(0.009, 0.009, 0.009), pos=Vector(0, 0, 0), angle=Angle(0, 0, 0) }
}

function SWEP:SetupDataTables()
	/*-------------------------------
		1=drawing
		2=idle
		3=throwing
		4=ready to place
		5=placing
		6=transitioning
	---------------------------------*/
	self:DTVar("Int",0,"State")
end

function SWEP:Initialize()
	self.NextReloadTime=CurTime()+0.25
	self:SetWeaponHoldType("slam")
	
	self:SCKInitialize()
	
	self:Deploy()
end

/*---------------------------------------------------------
   Name: SWEP:Deploy()
   Desc: Whip it out.
---------------------------------------------------------*/
function SWEP:Deploy()
	if(IsValid(self.Owner))then
		if(self.Owner:KeyDown(IN_SPEED))then return end
	end

	self.Weapon:SetNextPrimaryFire(CurTime()+0.25)
	self.Weapon:SetNextSecondaryFire(CurTime()+0.77)
	self.Weapon:SetNextSecondaryFire(CurTime()+0.77)
	
	self.dt.State=1
	timer.Simple(.01,function()
		if(IsValid(self))then
			self.Weapon:SendWeaponAnim(ACT_SLAM_THROW_ND_DRAW)
		end
	end)
	timer.Simple(.75,function()
		if(IsValid(self))then
			self.dt.State=2
			self.Weapon:SendWeaponAnim(ACT_SLAM_THROW_ND_IDLE)
		end
	end)

	return true
end

/*---------------------------------------------------------
   Name: SWEP:PrimaryAttack()
   Desc: +attack1 has been pressed.
---------------------------------------------------------*/
function SWEP:PrimaryAttack()
	if(self.Owner:KeyDown(IN_SPEED))then return end
	if(self.dt.State==2)then
		self.dt.State=3
		self.Weapon:SendWeaponAnim(ACT_SLAM_THROW_THROW_ND)
		self.Owner:SetAnimation(PLAYER_ATTACK1)
		timer.Simple(.5,function()
			if(IsValid(self))then
				self:ThrowDetpack(false)
				if(SERVER)then self.Owner:StripWeapon("wep_jack_detpack") end
			end
		end)
	elseif(self.dt.State==4)then
		self.dt.State=5
		self.Weapon:SendWeaponAnim(ACT_SLAM_TRIPMINE_ATTACH)
		self.Owner:SetAnimation(PLAYER_ATTACK1)
		self.Owner:GetViewModel():SetPlaybackRate(.75)
		timer.Simple(.5,function()
			if(IsValid(self))then
				self:StickDetpack(false)
				if(SERVER)then self.Owner:StripWeapon("wep_jack_detpack") end
			end
		end)
	end
end

/*---------------------------------------------------------
   Name: SWEP:SecondaryAttack()
   Desc: +attack2 has been pressed.
---------------------------------------------------------*/
function SWEP:SecondaryAttack()
	if(self.Owner:KeyDown(IN_SPEED))then return end
	if(self.dt.State==2)then
		self.dt.State=3
		self.Weapon:SendWeaponAnim(ACT_SLAM_THROW_THROW_ND)
		self.Owner:SetAnimation(PLAYER_ATTACK1)
		timer.Simple(.5,function()
			if(IsValid(self))then
				self:ThrowDetpack(true)
				if(SERVER)then self.Owner:StripWeapon("wep_jack_detpack") end
			end
		end)
	elseif(self.dt.State==4)then
		self.dt.State=5
		self.Weapon:SendWeaponAnim(ACT_SLAM_TRIPMINE_ATTACH)
		self.Owner:SetAnimation(PLAYER_ATTACK1)
		self.Owner:GetViewModel():SetPlaybackRate(.75)
		timer.Simple(.5,function()
			if(IsValid(self))then
				self:StickDetpack(true)
				if(SERVER)then self.Owner:StripWeapon("wep_jack_detpack") end
			end
		end)
	end
end

/*---------------------------------------------------------
   Name: SWEP:Think()
   Desc: Called every frame.
---------------------------------------------------------*/
function SWEP:Think()
	if(self.Owner:KeyDown(IN_SPEED))then return end
	if not((self.dt.State==2)or(self.dt.State==4))then return end
	local Yah=self.Owner:GetEyeTrace()
	if(Yah.Hit)then
		if((Yah.HitPos-self.Owner:GetShootPos()):Length()<70)then
			if not((self.dt.State==4)or(self.dt.State==6))then
				self.dt.State=6
				self:TransitionFromThrowingToPlacing()
			end
		else
			if not((self.dt.State==2)or(self.dt.State==6))then
				self.dt.State=6
				self:TransitionFromPlacingToThrowing()
			end
		end
	end
end

function SWEP:TransitionFromThrowingToPlacing()
	self.Weapon:SendWeaponAnim(ACT_SLAM_THROW_TO_TRIPMINE_ND)
	timer.Simple(1,function()
		if(IsValid(self))then
			self.dt.State=4
			self.Weapon:SendWeaponAnim(ACT_SLAM_TRIPMINE_IDLE)
		end
	end)
end

function SWEP:TransitionFromPlacingToThrowing()
	self.Weapon:SendWeaponAnim(ACT_SLAM_TRIPMINE_TO_THROW_ND)
	timer.Simple(1,function()
		if(IsValid(self))then
			self.dt.State=2
			self.Weapon:SendWeaponAnim(ACT_SLAM_THROW_ND_IDLE)
		end
	end)
end

/*---------------------------------------------------------
   Name: SWEP:Holster()
   Desc: Weapon wants to holster.
	   Return true to allow the weapon to holster.
---------------------------------------------------------*/
function SWEP:Holster()
	if(SERVER)then
		if((self.dt.State==2)or(self.dt.State==4))then
			local DroppedPack=ents.Create("ent_jack_c4block")
			DroppedPack:SetPos(self.Owner:GetShootPos()+self.Owner:GetAimVector()*20-self.Owner:GetUp()*20)
			DroppedPack.Owner=self.Owner
			DroppedPack:SetOwner(self.Owner)
			DroppedPack:Spawn()
			DroppedPack:Activate()
			DroppedPack:GetPhysicsObject():SetVelocity(self.Owner:GetVelocity()*0.5+self.Owner:GetAimVector()*10)
			if(SERVER)then self.Owner:StripWeapon("wep_jack_detpack") end
		end
	end
	return true
end

function SWEP:OnRemove()
	self:SCKHolster()
end

/*---------------------------------------------------------
	Reload
---------------------------------------------------------*/
function SWEP:Reload()
	if(self.dt.State==2)then
		self:Holster()
		return
	end
end

/*---------------------------------------------------------
   Name: SWEP:ThrowPenis()
---------------------------------------------------------*/
function SWEP:ThrowDetpack(willArm)
	if(SERVER)then
		local Det=ents.Create("ent_jack_c4block")
		Det:SetPos(self.Owner:GetShootPos()+self.Owner:GetAimVector()*20-self.Owner:GetUp()*20)
		Det.Owner=self.Owner
		Det:Spawn()
		Det:Activate()
		Det:GetPhysicsObject():SetVelocity(self.Owner:GetVelocity()*.75+self.Owner:GetAimVector()*200)
		Det:SetCollisionGroup(COLLISION_GROUP_WEAPON)
		if(willArm)then JackyOrdnanceArm(Det,self.Owner,"Remote") end
		timer.Simple(.5,function()
			if(IsValid(Det))then
				Det:SetCollisionGroup(COLLISION_GROUP_NONE)
			end
		end)
	end
end

function SWEP:StickDetpack(willArm)
	if(SERVER)then
		local Tr=self.Owner:GetEyeTrace()
		if(Tr.Hit)then
			if(((self.Owner:GetShootPos()-Tr.HitPos)):Length()<100)then
				local Det=ents.Create("ent_jack_c4block")
				Det:SetPos(Tr.HitPos+Tr.HitNormal*2)
				local TheAngle=Tr.HitNormal:Angle()
				TheAngle:RotateAroundAxis(TheAngle:Right(),90)
				Det:SetAngles(TheAngle)
				Det.Owner=self.Owner
				Det:Spawn()
				Det:Activate()
				if(willArm)then JackyOrdnanceArm(Det,self.Owner,"Remote") end
				constraint.Weld(Det,Tr.Entity,0,0,10000,true)
				Det:SetCollisionGroup(COLLISION_GROUP_WEAPON)
			else
				self:ThrowDetpack(willArm)
			end
		else
			self:ThrowDetpack(willArm)
		end
	end
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