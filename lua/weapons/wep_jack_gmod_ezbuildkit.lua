-- Jackarunda 2019
AddCSLuaFile()

SWEP.PrintName	= "EZ Build Kit"

SWEP.Author		= "Jackarunda"
SWEP.Purpose	= ""

SWEP.Spawnable	= true
SWEP.UseHands	= true
SWEP.DrawAmmo	= false
SWEP.DrawCrosshair=false

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
SWEP.VElements = {
	["wrench"] = { type = "Model", model = "models/props_c17/tools_wrench01a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(3.5, 1.5, 0), angle = Angle(0, 90, -90), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["pliers"] = { type = "Model", model = "models/props_c17/tools_pliers01a.mdl", bone = "ValveBiped.Bip01_L_Hand", rel = "", pos = Vector(2.8, 2.4, -2.5), angle = Angle(0, 180, 90), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}
SWEP.WElements = {
	["saw"] = { type = "Model", model = "models/props_forest/circularsaw01.mdl", bone = "ValveBiped.Bip01_Spine", rel = "", pos = Vector(-6.753, -0.519, 10.909), angle = Angle(104.026, -12.858, -157.793), size = Vector(0.75, 0.75, 0.75), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["wrench"] = { type = "Model", model = "models/props_c17/tools_wrench01a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(2.596, 1, 3.635), angle = Angle(0, -90, -90), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["pliers"] = { type = "Model", model = "models/props_c17/tools_pliers01a.mdl", bone = "ValveBiped.Bip01_L_Hand", rel = "", pos = Vector(4.675, 0, -1.558), angle = Angle(0, 0, 90), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["torch"] = { type = "Model", model = "models/props_silo/welding_torch.mdl", bone = "ValveBiped.Bip01_Spine", rel = "", pos = Vector(-1.558, 2.596, -8.832), angle = Angle(180, 26.882, 38.57), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["pickaxe"] = { type = "Model", model = "models/props_mining/pickaxe01.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "", pos = Vector(-22.338, 2.596, -1.558), angle = Angle(-92.338, 0, 0), size = Vector(0.75, 0.75, 0.75), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["mask"] = { type = "Model", model = "models/props_silo/welding_helmet.mdl", bone = "ValveBiped.Bip01_Head1", rel = "", pos = Vector(2, 4, 0), angle = Angle(90, -20, 0), size = Vector(1.1, 1.1, 1.1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["axe"] = { type = "Model", model = "models/props_forest/axe.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "", pos = Vector(-7.792, 2, 4), angle = Angle(118.052, 87.662, 180), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["toolbox"] = { type = "Model", model = "models/weapons/w_models/w_tooljox.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "", pos = Vector(-7, 6, 0.518), angle = Angle(-180, 85.324, 87.662), size = Vector(0.5, 0.5, 0.5), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["pack1"] = { type = "Model", model = "models/weapons/w_defuser.mdl", bone = "ValveBiped.Bip01_Spine", rel = "", pos = Vector(-4.676, -7.792, 0), angle = Angle(180, 108.7, 90), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["pack2"] = { type = "Model", model = "models/weapons/w_defuser.mdl", bone = "ValveBiped.Bip01_Spine", rel = "", pos = Vector(-3.636, 3.635, 0), angle = Angle(3.506, 68.96, 90), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}

function SWEP:Initialize()
	self:SetHoldType("fist")
	self:SCKInitialize()
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
	if(self.Owner:KeyDown(IN_SPEED))then
		Downness=Lerp(FT*2,Downness,10)
	else
		Downness=Lerp(FT*2,Downness,0)
	end
	ang:RotateAroundAxis(ang:Right(),-Downness*5)
	return pos,ang
end
function SWEP:SetupDataTables()
	self:NetworkVar("Float",0,"NextMeleeAttack")
	self:NetworkVar("Float",1,"NextIdle")
	self:NetworkVar("Int",0,"Combo")
	self:NetworkVar("Int",1,"SelectedBuild")
end
function SWEP:UpdateNextIdle()
	local vm=self.Owner:GetViewModel()
	self:SetNextIdle(CurTime()+vm:SequenceDuration())
end
function SWEP:CanSee(ent)
	return not util.TraceLine({
		start=self.Owner:GetShootPos(),
		endpos=ent:LocalToWorld(ent:OBBCenter()),
		filter={self.Owner,ent},
		mask=MASK_OPAQUE
	}).Hit
end
function SWEP:CountResourcesInRange()
	local Results={}
	for k,obj in pairs(ents.FindInSphere(self:GetPos(),150))do
		if((obj.IsJackyEZresource)and(self:CanSee(obj)))then
			local Typ=obj.ResourceType
			Results[Typ]=(Results[Typ] or 0)+obj:GetResource()
		end
	end
	return Results
end
function SWEP:HaveResourcesToPerformTask(requirements)
	local RequirementsMet,ResourcesInRange=true,self:CountResourcesInRange()
	for typ,amt in pairs(requirements)do
		if(not((ResourcesInRanges[typ])and(ResourcesInRange[typ]>=amt)))then
			RequirementsMet=false
			break
		end
	end
	return RequirementsMet
end
function SWEP:FindResourceContainer(typ,amt)
	for k,obj in pairs(ents.FindInSphere(self:GetPos(),150))do
		if((obj.IsJackyEZresource)and(obj.EZsupplies==typ)and(obj:GetResource()>=amt)and(self:CanSee(obj)))then
			return obj
		end
	end
end
function SWEP:PrimaryAttack(right)
	if(self.Owner:KeyDown(IN_SPEED))then return end
	self:Pawnch()
	self:SetNextMeleeAttack(CurTime()+.2)
	self:SetNextPrimaryFire(CurTime()+1)
	self:SetNextSecondaryFire(CurTime()+1)
	if(SERVER)then
		local Built,Upgraded,SelectedBuild=false,false,self:GetSelectedBuild()
		local Ent,Pos=self:WhomIlookinAt()
		if((IsValid(Ent))and(Ent.EZupgrades))then
			local State=Ent:GetState()
			if(State==-1)then
				self.Owner:PrintMessage(HUD_PRINTCENTER,"device must be repaired before upgrading")
			elseif(State~=0)then
				self.Owner:PrintMessage(HUD_PRINTCENTER,"device must be turned off to upgrade")
			else
				local Grade=Ent:GetGrade()
				if(Grade<5)then
					local UpgradeInfo,UpgradeRate=Ent.EZupgrades.grades[Grade],Ent.EZupgrades.rate
					for resourceType,requiredAmt in pairs(UpgradeInfo)do
						local CurAmt=Ent.UpgradeProgress[resourceType] or 0
						if(CurAmt<requiredAmt)then
							local ResourceContainer=self:FindResourceContainer(resourceType,UpgradeRate)
							if(ResourceContainer)then
								self:UpgradeEntWithResource(Ent,ResourceContainer,UpgradeRate)
								Upgraded=true
								break
							end
						end
					end
					if not(Upgraded)then self.Owner:PrintMessage(HUD_PRINTCENTER,"missing supplies for upgrade") end
				else
					self.Owner:PrintMessage(HUD_PRINTCENTER,"device already highest grade")
				end
			end
		elseif((not(IsValid(Ent))or not(Ent.EZupgrades))and(SelectedBuild>0))then
			--
		end
		if((Built)or(Upgraded))then
			if(Built)then
				self:BuildEffect(Pos)
			elseif(Upgraded)then
				self:UpgradeEffect(Pos)
			end
		end
	end
end
function SWEP:UpgradeEntWithResource(recipient,donor,amt)
	local Type,Grade=donor.EZsupplies,recipient:GetGrade()
	local RequiredSupplies=recipient.EZupgrades.grades[Grade]
	if not(Type)then return end
	local CurAmt,DonorCurAmt=recipient.UpgradeProgress[Type] or 0,donor:GetResource()
	local Limit=RequiredSupplies[Type]
	local Given=math.min(DonorCurAmt,Limit-CurAmt,amt)
	recipient.UpgradeProgress[Type]=CurAmt+Given
	---
	local Msg="UPGRADING\n"
	for typ,amount in pairs(RequiredSupplies)do
		Msg=Msg..typ..": "..tostring(recipient.UpgradeProgress[typ] or 0).."/"..tostring(RequiredSupplies[typ]).."\n"
	end
	self.Owner:PrintMessage(HUD_PRINTCENTER,Msg)
	---
	if((DonorCurAmt-Given)<=0)then
		donor:Remove()
	else
		donor:SetResource(DonorCurAmt-Given)
	end
	local HaveEverything=true
	for typ,amount in pairs(RequiredSupplies)do
		if((recipient.UpgradeProgress[typ] or 0)<amount)then HaveEverything=false end
	end
	if(HaveEverything)then
		recipient:Upgrade(Grade+1)
	end
end
function SWEP:Pawnch()
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
	local anim = "fists_left"
	if ( math.random(1,2)==1 ) then anim = "fists_right" end
	if ( self:GetCombo() >= 2 ) then
		anim = "fists_uppercut"
	end
	local vm = self.Owner:GetViewModel()
	vm:SendViewModelMatchingSequence( vm:LookupSequence( anim ) )
	self:UpdateNextIdle()
end
function SWEP:FlingProp(mdl,force)
	local Prop=ents.Create("prop_physics")
	Prop:SetPos(self:GetPos()+self:GetUp()*25+VectorRand()*math.Rand(1,25))
	Prop:SetAngles(VectorRand():Angle())
	Prop:SetModel(mdl)
	Prop:Spawn()
	Prop:Activate()
	Prop:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	constraint.NoCollide(Prop,self)
	local Phys=Prop:GetPhysicsObject()
	Phys:SetVelocity(self:GetPhysicsObject():GetVelocity()+VectorRand()*math.Rand(1,300)+self:GetUp()*100)
	Phys:AddAngleVelocity(VectorRand()*math.Rand(1,10000))
	if(force)then Phys:ApplyForceCenter(force/7) end
	SafeRemoveEntityDelayed(Prop,math.random(5,10))
end
function SWEP:BuildEffect(pos)
	--
end
function SWEP:UpgradeEffect(pos)
	local effectdata=EffectData()
	effectdata:SetOrigin(pos+VectorRand())
	effectdata:SetNormal((VectorRand()+Vector(0,0,1)):GetNormalized())
	effectdata:SetMagnitude(math.Rand(1,2)) --amount and shoot hardness
	effectdata:SetScale(math.Rand(.5,1.5)) --length of strands
	effectdata:SetRadius(math.Rand(2,4)) --thickness of strands
	util.Effect("Sparks",effectdata,true,true)
	sound.Play("snds_jack_gmod/ez_tools/hit.wav",pos+VectorRand(),60,math.random(80,120))
	sound.Play("snds_jack_gmod/ez_tools/"..math.random(1,27)..".wav",pos,60,math.random(80,120))
end
function SWEP:WhomIlookinAt()
	local Tr=util.QuickTrace(self.Owner:GetShootPos(),self.Owner:GetAimVector()*80,{self.Owner})
	return Tr.Entity,Tr.HitPos
end
function SWEP:SecondaryAttack()
	self:PrimaryAttack(true)
end
function SWEP:OnRemove()
	self:SCKHolster()
	if ( IsValid( self.Owner ) && CLIENT && self.Owner:IsPlayer() ) then
		local vm = self.Owner:GetViewModel()
		if ( IsValid( vm ) ) then vm:SetMaterial( "" ) end
	end
end
function SWEP:Holster( wep )
	self:SCKHolster()
	self:OnRemove()
	return true
end
function SWEP:Deploy()
	local vm = self.Owner:GetViewModel()
	vm:SendViewModelMatchingSequence( vm:LookupSequence( "fists_draw" ) )
	self:UpdateNextIdle()
	if ( SERVER ) then
		self:SetCombo( 0 )
	end
	return true
end
function SWEP:Think()
	local vm = self.Owner:GetViewModel()
	local curtime = CurTime()
	local idletime = self:GetNextIdle()
	if ( idletime > 0 && CurTime() > idletime ) then
		vm:SendViewModelMatchingSequence( vm:LookupSequence( "fists_idle_0" .. math.random( 1, 2 ) ) )
		self:UpdateNextIdle()
	end
	local meleetime = self:GetNextMeleeAttack()
	if ( meleetime > 0 && CurTime() > meleetime ) then
		self:SetNextMeleeAttack( 0 )
	end
	if ( SERVER && CurTime() > self:GetNextPrimaryFire() + 0.1 ) then
		self:SetCombo( 0 )
	end
end
function SWEP:DrawHUD()
	local W,H=ScrW(),ScrH()
	draw.SimpleTextOutlined("R: select build item","Trebuchet24",W*.4,H*.8,Color(255,255,255,50),TEXT_ALIGN_LEFT,TEXT_ALIGN_TOP,3,Color(0,0,0,50))
	draw.SimpleTextOutlined("LMB: build/upgrade","Trebuchet24",W*.4,H*.8+30,Color(255,255,255,50),TEXT_ALIGN_LEFT,TEXT_ALIGN_TOP,3,Color(0,0,0,50))
	draw.SimpleTextOutlined("RMB: salvage/drop kit","Trebuchet24",W*.4,H*.8+60,Color(255,255,255,50),TEXT_ALIGN_LEFT,TEXT_ALIGN_TOP,3,Color(0,0,0,50))
end

----------------- shit -------------------

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

		// Create the clientside models here because Garry says we can't do it in the render hook
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