-- Jackarunda 2019
AddCSLuaFile()

SWEP.PrintName	= "EZ Medkit"

SWEP.Author		= "Jackarunda"
SWEP.Purpose	= ""

SWEP.Spawnable	= false
SWEP.UseHands	= true
SWEP.DrawAmmo	= false
SWEP.DrawCrosshair=false

SWEP.InstantPickup=true -- Fort Fights compatibility

SWEP.ViewModel	= "models/weapons/c_arms_citizen.mdl"
SWEP.WorldModel	= "models/props_c17/tools_wrench01a.mdl"

SWEP.ViewModelFOV	= 52
SWEP.Slot			= 0
SWEP.SlotPos		= 5

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= true
SWEP.Secondary.Ammo			= "none"

SWEP.ShowWorldModel=false
SWEP.VElements={
	["syringe"]={ type="Model", model="models/weapons/w_models/w_syringe.mdl", bone="ValveBiped.Bip01_R_Hand", rel="", pos=Vector(3, 1.5, 4), angle=Angle(0, 0, 180), size=Vector(.5, .5, .5), color=Color(255, 255, 255, 255), surpresslightning=false, material="", skin=0, bodygroup={} },
	["bandage"]={ type="Model", model="models/bandages.mdl", bone="ValveBiped.Bip01_L_Hand", rel="", pos=Vector(1.8, 3.2, -.8), angle=Angle(0, 50, 0), size=Vector(.5, .5, .5), color=Color(255, 255, 255, 255), surpresslightning=false, material="", skin=0, bodygroup={} }
}
SWEP.WElements={
	["saw"]={ type="Model", model="models/weapons/w_models/w_bonesaw.mdl", bone="ValveBiped.Bip01_Pelvis", rel="", pos=Vector(7.791, 0.518, 0.518), angle=Angle(8.182, -65.974, 0), size=Vector(0.75, 0.75, 0.75), color=Color(255, 255, 255, 255), surpresslightning=false, material="", skin=0, bodygroup={} },
	["vial"]={ type="Model", model="models/healthvial.mdl", bone="ValveBiped.Bip01_Pelvis", rel="", pos=Vector(-9, -1.558, 0), angle=Angle(99.35, 92.337, 0), size=Vector(1, 1, 1), color=Color(255, 255, 255, 255), surpresslightning=false, material="", skin=0, bodygroup={} },
	["bandage3"]={ type="Model", model="models/bandages.mdl", bone="ValveBiped.Bip01_Pelvis", rel="", pos=Vector(-5.715, 2.596, 3.635), angle=Angle(20.169, -87.663, 0), size=Vector(1, 1, 1), color=Color(255, 255, 255, 255), surpresslightning=false, material="", skin=0, bodygroup={} },
	["box"]={ type="Model", model="models/items/medjit_large.mdl", bone="ValveBiped.Bip01_Spine4", rel="", pos=Vector(-14.027, 3.635, -0.519), angle=Angle(-90, 73.636, 90), size=Vector(0.75, 0.75, 0.75), color=Color(255, 255, 255, 255), surpresslightning=false, material="", skin=0, bodygroup={} },
	["big_syringe"]={ type="Model", model="models/weapons/w_models/w_syringe.mdl", bone="ValveBiped.Bip01_R_Hand", rel="", pos=Vector(0, 0.557, 4.675), angle=Angle(-180, -118.053, -30.17), size=Vector(0.75, 0.75, 0.75), color=Color(255, 255, 255, 255), surpresslightning=false, material="", skin=0, bodygroup={} },
	["small_syringe"]={ type="Model", model="models/weapons/w_models/w_syringe_proj.mdl", bone="ValveBiped.Bip01_Pelvis", rel="", pos=Vector(-6.753, 5.714, 2.596), angle=Angle(3.506, -90, 101.688), size=Vector(1, 1, 1), color=Color(255, 255, 255, 255), surpresslightning=false, material="", skin=0, bodygroup={} },
	["bandage1"]={ type="Model", model="models/bandages.mdl", bone="ValveBiped.Bip01_L_Hand", rel="", pos=Vector(0, 1.557, 0.518), angle=Angle(-97.014, 0, 0), size=Vector(0.75, 0.75, 0.75), color=Color(255, 255, 255, 255), surpresslightning=false, material="", skin=0, bodygroup={} },
	["bandage2"]={ type="Model", model="models/bandages.mdl", bone="ValveBiped.Bip01_Pelvis", rel="", pos=Vector(-0.519, 4.675, -5.715), angle=Angle(1.169, 5.843, -164.805), size=Vector(1.25, 1.25, 1.25), color=Color(255, 255, 255, 255), surpresslightning=false, material="", skin=0, bodygroup={} },
	["bottle"]={ type="Model", model="models/items/medjit_small.mdl", bone="ValveBiped.Bip01_Pelvis", rel="", pos=Vector(-11.948, 9.869, -6.753), angle=Angle(-75.974, 3.506, -52.598), size=Vector(0.75, 0.75, 0.75), color=Color(255, 255, 255, 255), surpresslightning=false, material="", skin=0, bodygroup={} },
	["container"]={ type="Model", model="models/items/medjit_medium.mdl", bone="ValveBiped.Bip01_Pelvis", rel="", pos=Vector(6.752, 9.869, -1.558), angle=Angle(-115.714, 5.843, -61.949), size=Vector(0.5, 0.5, 0.5), color=Color(255, 255, 255, 255), surpresslightning=false, material="", skin=0, bodygroup={} },
	["kit"]={ type="Model", model="models/items/healthkit.mdl", bone="ValveBiped.Bip01_Spine4", rel="", pos=Vector(-15.065, 0.518, 4.675), angle=Angle(-92.338, -12.858, 97.013), size=Vector(1, 1, 1), color=Color(255, 255, 255, 255), surpresslightning=false, material="", skin=0, bodygroup={} },
	["mask"]={ type="Model", model="models/bloocobalt/l4d/items/cim_fallen_survivor_pocket03.mdl", bone="ValveBiped.Bip01_Head1", rel="", pos=Vector(-1, 4.5, 0), angle=Angle(-40.91, -87.663, -90), size=Vector(1.5, 1.5, 1.3), color=Color(255, 255, 255, 255), surpresslightning=false, material="models/debug/debugwhite", skin=0, bodygroup={} },
	["redkit"]={ type="Model", model="models/bloocobalt/l4d/items/w_eq_fieldkit.mdl", bone="ValveBiped.Bip01_Spine4", rel="", pos=Vector(-15.065, -1.558, 9.869), angle=Angle(-97.014, -104.027, 3.506), size=Vector(1, 1, 1), color=Color(255, 255, 255, 255), surpresslightning=false, material="", skin=0, bodygroup={} },
	["defib"]={ type="Model", model="models/bloocobalt/l4d/items/w_eq_defibrillator.mdl", bone="ValveBiped.Bip01_Spine4", rel="", pos=Vector(-18.182, 1.557, -6.753), angle=Angle(90, 73.636, -5.844), size=Vector(1.5, 1.5, 1.5), color=Color(255, 255, 255, 255), surpresslightning=false, material="", skin=0, bodygroup={} }
}
SWEP.Props={
	"models/healthvial.mdl",
	"models/bandages.mdl",
	"models/items/medjit_small.mdl",
	"models/items/medjit_small.mdl",
	"models/bloocobalt/l4d/items/w_eq_adrenaline.mdl",
	"models/bloocobalt/l4d/items/w_eq_adrenaline_cap.mdl",
	"models/bloocobalt/l4d/items/w_eq_pills.mdl",
	"models/bloocobalt/l4d/items/w_eq_pills_cap.mdl",
	"models/bandages.mdl"
}
function SWEP:Initialize()
	self:SetHoldType("fist")
	self:SCKInitialize()
	self.NextIdle=0
	self:Deploy()
	self:SetSupplies(100)
end
function SWEP:PreDrawViewModel(vm,wep,ply)
	vm:SetMaterial("engine/occlusionproxy") -- Hide that view model with hacky material
end
function SWEP:ViewModelDrawn()
	self:SCKViewModelDrawn()
end
function SWEP:DrawWorldModel()
	self:SCKDrawWorldModel()
end
local Downness=0
function SWEP:GetViewModelPosition(pos,ang)
	local FT=FrameTime()
	if((self.Owner:KeyDown(IN_SPEED))or(self.Owner:KeyDown(IN_ATTACK2)))then
		Downness=Lerp(FT*2,Downness,10)
	else
		Downness=Lerp(FT*2,Downness,0)
	end
	ang:RotateAroundAxis(ang:Right(),-Downness*5)
	return pos,ang
end
function SWEP:SetupDataTables()
	self:NetworkVar("Int",1,"Supplies")
end
function SWEP:UpdateNextIdle()
	local vm=self.Owner:GetViewModel()
	self.NextIdle=CurTime()+vm:SequenceDuration()
end
function SWEP:PrimaryAttack()
	if(self.Owner:KeyDown(IN_SPEED))then return end
	self:Pawnch()
	self:SetNextPrimaryFire(CurTime()+.65)
	self:SetNextSecondaryFire(CurTime()+.85)
	if(SERVER)then
		local Ent,Pos,Norm=self:WhomIlookinAt()
		local AimVec=self.Owner:GetAimVector()
		if(IsValid(Ent))then
			local Hit=false
			if(Ent:IsPlayer())then
				local Helf,Max=Ent:Health(),Ent:GetMaxHealth()
				if((Helf<0)or(Helf>=Max))then return end
				Ent.EZhealth=(Ent.EZhealth or 0)
				local Missing=Max-(Helf+Ent.EZhealth)
				if(Missing<=0)then return end
				local AddAmt=math.min(Missing,3)
				self:SetSupplies(self:GetSupplies()-1)
				Ent.EZhealth=Ent.EZhealth+AddAmt
				self.Owner:PrintMessage(HUD_PRINTCENTER,"treatment "..Ent.EZhealth+Helf.."/"..Max)
				Ent:ViewPunch(Angle(math.Rand(-2,2),math.Rand(-2,2),math.Rand(-2,2)))
				Hit=true
			elseif((Ent:IsNPC())and(Ent.Health)and(Ent:Health())and(tonumber(Ent:Health())))then
				local Helf,Max=Ent:Health(),Ent:GetMaxHealth()
				if((Helf<0)or(Helf>=Max))then return end
				local Missing=Max-Helf
				if(Missing<=0)then return end
				local AddAmt=math.min(Missing,3)
				self:SetSupplies(self:GetSupplies()-1)
				Ent:SetHealth(Helf+AddAmt)
				self.Owner:PrintMessage(HUD_PRINTCENTER,"health "..Ent:Health().."/"..Max)
				Hit=true
			end
			if(Hit)then
				sound.Play("snds_jack_gmod/ez_medical/hit.wav",Pos+Vector(0,0,1),60,math.random(90,110))
				sound.Play("snds_jack_gmod/ez_medical/"..math.random(1,27)..".wav",Pos,60,math.random(90,110))
				for i=1,2 do
					local EffPos=Pos+VectorRand()*3
					local Eff=EffectData()
					Eff:SetOrigin(EffPos)
					Eff:SetFlags(3)
					Eff:SetColor(0)
					Eff:SetScale(6)
					util.Effect("bloodspray",Eff,true,true)
					local EffTwo=EffectData()
					EffTwo:SetOrigin(EffPos)
					util.Effect("BloodImpact",EffTwo,true,true)
					local Tr=util.QuickTrace(EffPos,VectorRand()*30-Vector(0,0,40),{Ent,self.Owner})
					if(Tr.Hit)then
						util.Decal("Blood",Tr.HitPos+Tr.HitNormal,Tr.HitPos-Tr.HitNormal)
					end
				end
				Ent:RemoveAllDecals()
				if(self:GetSupplies()<=0)then self:Remove();return end
				timer.Simple(.05,function()
					if(IsValid(self))then
						for i=1,2 do
							self:FlingProp(table.Random(self.Props),Pos)
						end
					end
				end)
			end
		end
	end
end
local Anims={"fists_right","fists_right","fists_left","fists_left"}--,"fists_uppercut"} -- the uppercut looks so bad
function SWEP:Pawnch()
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
	local vm=self.Owner:GetViewModel()
	vm:SendViewModelMatchingSequence( vm:LookupSequence( table.Random(Anims) ) )
	self:UpdateNextIdle()
end
function SWEP:FlingProp(mdl,pos,force)
	local Prop=ents.Create("prop_physics")
	Prop:SetPos(pos)
	Prop:SetAngles(VectorRand():Angle())
	Prop:SetModel(mdl)
	Prop:SetModelScale(.75,0)
	Prop:Spawn()
	Prop:Activate()
	Prop:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	constraint.NoCollide(Prop,self)
	local Phys=Prop:GetPhysicsObject()
	Phys:SetMaterial("gmod_silent")
	Phys:SetVelocity(VectorRand()*math.Rand(1,300)+self:GetUp()*100)
	Phys:AddAngleVelocity(VectorRand()*math.Rand(1,10000))
	if(force)then Phys:ApplyForceCenter(force/7) end
	SafeRemoveEntityDelayed(Prop,math.random(5,10))
end
function SWEP:Reload()
	--
end
function SWEP:WhomIlookinAt()
	local Tr=util.QuickTrace(self.Owner:GetShootPos(),self.Owner:GetAimVector()*55,{self.Owner})
	return Tr.Entity,Tr.HitPos,Tr.HitNormal
end
function SWEP:SecondaryAttack()
	if(self.Owner:KeyDown(IN_SPEED))then return end
	if(SERVER)then
		if(self.Owner:KeyDown(IN_WALK))then
			local Kit=ents.Create("ent_jack_gmod_ezmedkit")
			Kit:SetPos(self.Owner:GetShootPos()+self.Owner:GetAimVector()*20)
			Kit:SetAngles(self.Owner:GetAimVector():Angle())
			Kit:Spawn()
			Kit:Activate()
			Kit.Supplies=self:GetSupplies()
			Kit:GetPhysicsObject():SetVelocity(self.Owner:GetVelocity())
			self:Remove()
			return
		else
			self:SetNextPrimaryFire(CurTime()+.65)
			self:SetNextSecondaryFire(CurTime()+.85)
			local Ent=self.Owner
			local AimVec=Ent:GetAimVector()
			local Pos=Ent:GetShootPos()-Vector(0,0,10)+AimVec*5
			local Helf,Max=Ent:Health(),Ent:GetMaxHealth()
			if not((Helf<0)or(Helf>=Max))then
				Ent.EZhealth=(Ent.EZhealth or 0)
				local Missing=Max-(Helf+Ent.EZhealth)
				if(Missing<=0)then return end
				local AddAmt=math.min(Missing,2)
				self:SetSupplies(self:GetSupplies()-1)
				Ent.EZhealth=Ent.EZhealth+AddAmt
				self.Owner:PrintMessage(HUD_PRINTCENTER,"treatment "..Ent.EZhealth+Helf.."/"..Max)
				Ent:ViewPunch(Angle(math.Rand(-2,2),math.Rand(-2,2),math.Rand(-2,2)))
				---
				sound.Play("snds_jack_gmod/ez_medical/hit.wav",Pos+Vector(0,0,1),60,math.random(90,110))
				sound.Play("snds_jack_gmod/ez_medical/"..math.random(1,27)..".wav",Pos,60,math.random(90,110))
				for i=1,2 do
					local EffPos=Pos+VectorRand()*3-AimVec*3
					local Eff=EffectData()
					Eff:SetOrigin(EffPos)
					Eff:SetFlags(3)
					Eff:SetColor(0)
					Eff:SetScale(6)
					util.Effect("bloodspray",Eff,true,true)
					local EffTwo=EffectData()
					EffTwo:SetOrigin(EffPos)
					util.Effect("BloodImpact",EffTwo,true,true)
					local Tr=util.QuickTrace(EffPos,VectorRand()*30-Vector(0,0,40),{Ent})
					if(Tr.Hit)then
						util.Decal("Blood",Tr.HitPos+Tr.HitNormal,Tr.HitPos-Tr.HitNormal)
					end
				end
				Ent:RemoveAllDecals()
				if(self:GetSupplies()<=0)then self:Remove();return end
				timer.Simple(.05,function()
					if(IsValid(self))then
						for i=1,2 do
							self:FlingProp(table.Random(self.Props),Pos+AimVec*5)
						end
					end
				end)
			end
		end
	end
end
function SWEP:OnRemove()
	self:SCKHolster()
	if( IsValid( self.Owner ) && CLIENT && self.Owner:IsPlayer() )then
		local vm=self.Owner:GetViewModel()
		if( IsValid( vm ) )then vm:SetMaterial( "" ) end
	end
end
function SWEP:Holster( wep )
	self:SCKHolster()
	self:OnRemove()
	return true
end
function SWEP:Deploy()
	if not(IsValid(self.Owner))then return end
	local vm=self.Owner:GetViewModel()
	if(IsValid(vm))then
		vm:SendViewModelMatchingSequence( vm:LookupSequence( "fists_draw" ) )
		self:UpdateNextIdle()
		self:EmitSound("snds_jack_gmod/toolbox"..math.random(1,7)..".wav",65,math.random(90,110))
	end
	self:SetNextPrimaryFire(CurTime()+1)
	self:SetNextSecondaryFire(CurTime()+1)
	return true
end
function SWEP:Think()
	local Time=CurTime()
	local vm=self.Owner:GetViewModel()
	local idletime=self.NextIdle
	if( idletime>0 && Time>idletime )then
		vm:SendViewModelMatchingSequence( vm:LookupSequence( "fists_idle_0" .. math.random( 1, 2 ) ) )
		self:UpdateNextIdle()
	end
	local RightClickin=self.Owner:KeyDown(IN_ATTACK2)
	if not(RightClickin)then self:SetNextSecondaryFire(CurTime()+.5) end
	if(self.Owner:KeyDown(IN_SPEED))then
		self:SetHoldType("normal")
	elseif(RightClickin)then
		self:SetHoldType("passive")
	else
		self:SetHoldType("fist")
	end
end
function SWEP:DrawHUD()
	local W,H,Supplies=ScrW(),ScrH(),self:GetSupplies()
	draw.SimpleTextOutlined("Supplies: "..Supplies,"Trebuchet24",W*.4,H*.7,Color(255,255,255,200),TEXT_ALIGN_LEFT,TEXT_ALIGN_TOP,3,Color(0,0,0,50))
	draw.SimpleTextOutlined("LMB: heal target","Trebuchet24",W*.4,H*.7+30,Color(255,255,255,50),TEXT_ALIGN_LEFT,TEXT_ALIGN_TOP,3,Color(0,0,0,50))
	draw.SimpleTextOutlined("RMB: heal self","Trebuchet24",W*.4,H*.7+60,Color(255,255,255,50),TEXT_ALIGN_LEFT,TEXT_ALIGN_TOP,3,Color(0,0,0,50))
	draw.SimpleTextOutlined("HOLD ALT+RMB: drop kit","Trebuchet24",W*.4,H*.7+90,Color(255,255,255,50),TEXT_ALIGN_LEFT,TEXT_ALIGN_TOP,3,Color(0,0,0,50))
end

----------------- shit -------------------

function SWEP:SCKHolster()
	if CLIENT and IsValid(self.Owner)then
		local vm=self.Owner:GetViewModel()
		if IsValid(vm)then
			self:ResetBonePositions(vm)
		end
	end
end

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

if(CLIENT)then
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