-- Jackarunda 2019
AddCSLuaFile()
ENT.Base="ent_jack_gmod_ezresource"
ENT.PrintName="EZ Medical Supplies Box"
ENT.Category="JMod - EZ"
ENT.Spawnable=true
ENT.AdminSpawnable=true
---
ENT.EZsupplies="medsupplies"
ENT.JModPreferredCarryAngles=Angle(0,90,0)
ENT.MaxResource=JMod_EZnutrientBoxSize
ENT.Model="models/items/medjit_large.mdl"
ENT.Material=""
ENT.ModelScale=1
ENT.Mass=50
ENT.ImpactNoise1="Cardboard.ImpactHard"
ENT.ImpactNoise2="Weapon.ImpactSoft"
ENT.DamageThreshold=140
ENT.BreakNoise="Cardboard_Box.Break"
---
ENT.MediModels={"models/items/healthkit.mdl","models/healthvial.mdl","models/items/medjit_medium.mdl","models/items/medjit_small.mdl","models/weapons/w_models/w_syringe.mdl","models/weapons/w_models/w_syringe_proj.mdl","models/weapons/w_models/w_bonesaw.mdl","models/bandages.mdl"}
if(SERVER)then
	function ENT:FlingProp(mdl)
		local Prop=ents.Create("prop_physics")
		Prop:SetPos(self:GetPos())
		Prop:SetAngles(VectorRand():Angle())
		Prop:SetModel(mdl)
		Prop:SetModelScale(.75,0)
		Prop:Spawn()
		Prop:Activate()
		if(math.random(1,2)==1)then Prop:SetHealth(100) end
		Prop:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
		constraint.NoCollide(Prop,self,0,0)
		local Phys=Prop:GetPhysicsObject()
		Phys:SetVelocity((VectorRand()+Vector(0,0,1)):GetNormalized()*math.Rand(10,300))
		Phys:AddAngleVelocity(VectorRand()*math.Rand(1,1000))
		SafeRemoveEntityDelayed(Prop,math.Rand(5,10))
	end
	function ENT:UseEffect(pos,ent)
		for i=1,7 do
			self:FlingProp(table.Random(self.FoodModels))
		end
	end
	function ENT:AltUse(ply)
		ply.EZnutrition=ply.EZnutrition or {NextEat=0,Nutrients=0}
		local Time=CurTime()
		if(ply.EZnutrition.NextEat<Time)then
			if(ply.EZnutrition.Nutrients<100)then
				for i=0,3 do
					timer.Simple(i/4,function()
						if(IsValid(ply))then
							if(math.random(1,2)==1)then
								ply:EmitSound("snd_jack_eat"..tostring(math.random(1,9))..".wav",75,math.Rand(90,110))
							else
								ply:EmitSound("snd_jack_drink"..tostring(math.random(1,2))..".wav",75,math.Rand(90,110))
							end
						end
					end)
				end
				self:UseEffect()
				ply.EZnutrition.NextEat=Time+100/JMOD_CONFIG.FoodSpecs.EatSpeed
				ply.EZnutrition.Nutrients=ply.EZnutrition.Nutrients+20*JMOD_CONFIG.FoodSpecs.ConversionEfficiency
				self:SetResource(self:GetResource()-10)
				if(self:GetResource()<=0)then self:Remove() end
				ply:PrintMessage(HUD_PRINTCENTER,"nutrition: "..ply.EZnutrition.Nutrients.."/100")
			else
				ply:PrintMessage(HUD_PRINTCENTER,"too full already")
			end
		else
			ply:PrintMessage(HUD_PRINTCENTER,"can't eat more right now")
		end
	end
elseif(CLIENT)then
	local TxtCol=Color(255,255,255,80)
	function ENT:Initialize()
		--
	end
	function ENT:Draw()
		local Ang,Pos,Up,Right,Forward=self:GetAngles(),self:GetPos(),self:GetUp(),self:GetRight(),self:GetForward()
		local Closeness=LocalPlayer():GetFOV()*(EyePos():Distance(Pos))
		local DetailDraw=Closeness<18000 -- cutoff point is 200 units when the fov is 90 degrees
		self:DrawModel()
		if(DetailDraw)then
			local Up,Right,Forward,Ammo=Ang:Up(),Ang:Right(),Ang:Forward(),tostring(self:GetResource())
			Ang:RotateAroundAxis(Ang:Right(),90)
			Ang:RotateAroundAxis(Ang:Up(),-90)
			cam.Start3D2D(Pos+Up*1-Right*2.5-Forward*7.5,Ang,.04)
			draw.SimpleText("JACKARUNDA INDUSTRIES","JMod-Stencil",0,0,TxtCol,TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
			draw.SimpleText("EZ NUTRIENTS","JMod-Stencil",0,50,TxtCol,TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
			draw.SimpleText(Ammo.." COUNT","JMod-Stencil",0,100,TxtCol,TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
			cam.End3D2D()
			---
			Ang:RotateAroundAxis(Ang:Right(),180)
			cam.Start3D2D(Pos+Up*1-Right*2.6+Forward*17.5,Ang,.04)
			draw.SimpleText("JACKARUNDA INDUSTRIES","JMod-Stencil",0,0,TxtCol,TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
			draw.SimpleText("EZ NUTRIENTS","JMod-Stencil",0,50,TxtCol,TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
			draw.SimpleText(Ammo.." COUNT","JMod-Stencil",0,100,TxtCol,TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
			cam.End3D2D()
		end
	end
	language.Add(ENT.ClassName,ENT.PrintName)
end