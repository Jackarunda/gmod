// Variables that are used on both client and server

SWEP.ViewModelFlip		= true
SWEP.ViewModel			= "models/weapons/v_eq_fragjrenade.mdl"
SWEP.WorldModel			= "models/weapons/w_eq_fraggrenade.mdl"
SWEP.ViewModelFOV	  =75

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
SWEP.ViewModelBoneMods={
	["v_weapon.Flashbang_Parent"]={ scale=Vector(0.009, 0.009, 0.009), pos=Vector(0, 0, 0), angle=Angle(0, 0, 0) }
}
SWEP.VElements={
	["grenade"]={ type="Model", model="models/weapons/w_fragjade.mdl", bone="v_weapon.Flashbang_Parent", rel="", pos=Vector(0.5, -4, -0.101), angle=Angle(-90, -90, 0), size=Vector(1.5, 1.5, 1.5), color=Color(255, 255, 255, 255), surpresslightning=false, material="models/weapons/w_models/gnd", skin=0, bodygroup={} }
}
SWEP.WElements={
	["grenade"]={ type="Model", model="models/weapons/w_fragjade.mdl", bone="ValveBiped.Bip01_R_Hand", rel="", pos=Vector(3.181, 2.273, 0), angle=Angle(-180, 0, 0), size=Vector(1, 1, 1), color=Color(255, 255, 255, 255), surpresslightning=false, material="models/weapons/w_models/gnd", skin=0, bodygroup={} }
}

function SWEP:SetupDataTables()
	/*-------------------------------
		1=drawing
		2=idle
		3=pulling pin
		4=replacing pin
		5=preparing to throw
		6=throwing
	---------------------------------*/
	self:DTVar("Int",0,"State")
	self:DTVar("Bool",0,"Primed")
	self:DTVar("Bool",1,"Armed")
	self:DTVar("Float",0,"FuzeLength")
	self:DTVar("Float",1,"ArmTime")
	self:DTVar("Bool",2,"CanThrow")
end

function SWEP:Initialize()
	self.dt.State=1
	self.dt.Primed=false
	self.dt.Armed=false
	self.dt.FuzeLength=math.Rand(3.5,4.5)
	self.JustExploded=false
	self.NextReloadTime=CurTime()+0.25
	
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
			self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
		end
	end)
	timer.Simple(.75,function()
		if(IsValid(self))then
			self.dt.State=2
			self.Weapon:SendWeaponAnim(ACT_VM_IDLE)
		end
	end)

	return true
end

/*---------------------------------------------------------
   Name: SWEP:PrimaryAttack()
   Desc: +attack1 has been pressed.
---------------------------------------------------------*/
function SWEP:PrimaryAttack()
	if(self.Owner:IsNPC())then
		local grenade=ents.Create("ent_jack_fraggrenade")
		grenade:SetPos(self.Owner:GetPos()+Vector(0,0,40)+self.Owner:GetAimVector()*20)
		grenade.Owner=self.Owner
		grenade.FuzeTime=self.dt.FuzeLength
		grenade:Spawn()
		grenade:Activate()
		grenade:GetPhysicsObject():SetVelocity(self.Owner:GetVelocity()+self.Owner:GetAimVector()*1500)
		grenade:GetPhysicsObject():AddAngleVelocity(VectorRand()*150)

		self.Weapon:EmitSound("weapons/iceaxe/iceaxe_swing1.wav")
		return
	end
	
	if(self.Owner:KeyDown(IN_SPEED))then return end
	
	if not(self.dt.State==2)then return end

	self.dt.State=5
	self.dt.CanThrow=false
	timer.Simple(.25,function()
		if(IsValid(self))then
			self.dt.CanThrow=true
		end
	end)

	self.Weapon:EmitSound("snd_jack_throwprepare.wav",80,90)
	self.Weapon:SendWeaponAnim(ACT_VM_IDLE)

end

/*---------------------------------------------------------
   Name: SWEP:SecondaryAttack()
   Desc: +attack2 has been pressed.
---------------------------------------------------------*/
function SWEP:SecondaryAttack()
	if((self.dt.State==2)or(self.dt.State==5))then
		if(not(self.dt.Primed))then
			if(self.dt.State==2)then
				self.Weapon:SendWeaponAnim(ACT_VM_PULLPIN)
			
				self.dt.State=3
				timer.Simple(0.2,function()
					if(IsValid(self.Weapon))then
						self.Owner:ViewPunch(Angle(-1,0,0))
					end
				end)
				timer.Simple(0.625,function()
					if(IsValid(self.Weapon))then
						self.dt.Primed=true
						self.dt.State=2
						if(SERVER)then self.Weapon:EmitSound("snd_jack_pinpull.wav") end
						self.Owner:ViewPunch(Angle(1,1,0))
					end
				end)
				timer.Simple(self.Weapon:SequenceDuration(),function()
					if(IsValid(self.Weapon))then
						if(self.Owner:KeyDown(IN_ATTACK))then
							if not(self.Owner:KeyDown(IN_SPEED))then
								self:PrimaryAttack()
							end
						end
					end
				end)
				return
			end
		elseif(not(self.dt.Armed))then
			self.dt.Armed=true
			self.dt.ArmTime=CurTime()
			
			if(SERVER)then
				local Spewn=ents.Create("ent_jack_spoon")
				Spewn:SetPos(self.Owner:GetShootPos()-self.Owner:GetForward()*20+self.Owner:GetRight()*20)
				Spewn:Spawn()
				Spewn:Activate()
				Spewn:GetPhysicsObject():SetVelocity(VectorRand()*750)
				Spewn:GetPhysicsObject():AddAngleVelocity(VectorRand()*750)
				self.Owner:EmitSound("snd_jack_spoonfling.wav")
			end
			return
		end
	end
end

/*---------------------------------------------------------
   Name: SWEP:Think()
   Desc: Called every frame.
---------------------------------------------------------*/
function SWEP:Think()
	if(self.dt.State==5)then
		if not(self.Owner:KeyDown(IN_SPEED))then
			if not(self.Owner:KeyDown(IN_ATTACK))then
				if(self.dt.CanThrow)then
					self.dt.State=6
					self.Weapon:SendWeaponAnim(ACT_VM_THROW)
					self.Weapon:EmitSound("snd_jack_grenadethrow.wav",90,95)
					self.Owner:ViewPunch(Angle(-20,0,0))
					timer.Simple(0.25,function()
						if(IsValid(self.Weapon))then
							self.Owner:SetAnimation(PLAYER_ATTACK1)
						end
					end)
					timer.Simple(0.4,function()
						if(IsValid(self.Weapon))then
							if not(self.dt.Armed)then
								self.dt.ArmTime=CurTime()
							end
							if(SERVER)then
								self:ThrowGrenade()
								self.Owner:ViewPunch(Angle(20,0,0))
								timer.Simple(0.4,function()
									if(IsValid(self.Weapon))then
										if(SERVER)then
											self.Owner:StripWeapon("wep_jack_fraggrenade")
										end
									end
								end)
							end
						end
					end)
				end
			end
		end
	end
	if(self.dt.Armed)then
		if((self.dt.ArmTime+self.dt.FuzeLength)<CurTime())then
			if(SERVER)then
				local Agh=ents.Create("ent_jack_fragsplosion")
				Agh:SetPos(self.Owner:GetShootPos()+self.Owner:GetRight()*10+self.Owner:GetUp()*10)
				Agh.Owner=self.Owner
				Agh:Spawn()
				Agh:Activate()
			end
			self.JustExploded=true
			if(SERVER)then self.Owner:StripWeapon("wep_jack_fraggrenade") end
		end
	end
end

/*---------------------------------------------------------
   Name: SWEP:Holster()
   Desc: Weapon wants to holster.
	   Return true to allow the weapon to holster.
---------------------------------------------------------*/
function SWEP:Holster()
	if(self.JustExploded)then return end
	if(SERVER)then
		local pos=self.Owner:GetShootPos()+self.Owner:GetAimVector()*20-Vector(0,0,10)
		if(self.dt.State==5)then
			pos=self.Owner:GetShootPos()+self.Owner:GetRight()*20-self.Owner:GetForward()*20
		end
		local DroppedGrenade=ents.Create("ent_jack_fraggrenade")
		DroppedGrenade:SetPos(pos)
		DroppedGrenade.PinOut=self.dt.Primed
		DroppedGrenade.SpoonOff=self.dt.Armed
		DroppedGrenade.FuzeTime=self.dt.FuzeLength
		DroppedGrenade.Owner=self.Owner
		DroppedGrenade:Spawn()
		DroppedGrenade:Activate()
		DroppedGrenade:GetPhysicsObject():SetVelocity(self.Owner:GetVelocity()*0.5+self.Owner:GetAimVector()*100)
		self.Owner:StripWeapon("wep_jack_fraggrenade")
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
	if(self.Owner:KeyDown(IN_SPEED))then return end
	if(self.NextReloadTime>CurTime())then return end
	if(not(self.dt.Primed)and(self.dt.State==5))then
		self.dt.State=1
		self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
		timer.Simple(.5,function()
			if(IsValid(self))then
				self.Weapon:SendWeaponAnim(ACT_VM_IDLE)
				self.dt.State=2
			end
		end)
		self.NextReloadTime=CurTime()+.75
		return
	end
	if((self.dt.Primed)and not(self.dt.Armed)and not(self.dt.State==6)and not(self.dt.State==4))then
		self.dt.State=1
		self.Weapon:EmitSound("snd_jack_pinreplace.wav",100,130)
		self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
		self.Owner:GetViewModel():SetPlaybackRate(1)
		timer.Simple(0.1,function()
			if(IsValid(self.Weapon))then
				self.Weapon:SendWeaponAnim(ACT_VM_PULLPIN)
				self.Owner:GetViewModel():SetPlaybackRate(2)
				self.dt.State=4
			end
		end)
		timer.Simple(0.3,function()
			if(IsValid(self.Weapon))then
				self.dt.Primed=false
				self.Weapon:SendWeaponAnim(ACT_VM_IDLE)
				self.Owner:GetViewModel():SetPlaybackRate(1)
				self.dt.State=2
			end
		end)
		self.NextReloadTime=CurTime()+0.25
	end
	if((self.dt.State==2)or(self.dt.State==6)or(self.dt.Armed))then
		self:Holster()
		return
	end
end

/*---------------------------------------------------------
   Name: SWEP:ThrowGrenade()
---------------------------------------------------------*/
function SWEP:ThrowGrenade()
	if(self.Owner:KeyDown(IN_SPEED))then return end
	local Gernad=ents.Create("ent_jack_fraggrenade")
	Gernad:SetPos(self.Owner:GetShootPos()+self.Owner:GetAimVector()*20)
	Gernad.PinOut=self.dt.Primed
	Gernad.SpoonOff=self.dt.Armed
	Gernad.FuzeTime=self.dt.FuzeLength-(CurTime()-self.dt.ArmTime)
	Gernad.Owner=self.Owner
	Gernad:Spawn()
	Gernad:Activate()
	Gernad:GetPhysicsObject():SetVelocity(self.Owner:GetVelocity()+self.Owner:GetAimVector()*1200)
	Gernad:GetPhysicsObject():AddAngleVelocity(VectorRand()*500)
	self.dt.State=2
end

local function DynamicHoldTypes()
	for key,thing in pairs(ents.FindByClass("wep_jack_fraggrenade"))do
		local State=thing.dt.State
		if((State==5)or(State==6))then
			thing:SetWeaponHoldType("grenade")
		else
			thing:SetWeaponHoldType("normal")
		end
	end
end
hook.Add("Think","JackysDynamicHoldTypes",DynamicHoldTypes)

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