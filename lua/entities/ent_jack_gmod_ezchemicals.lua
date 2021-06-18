-- Jackarunda 2019
AddCSLuaFile()
ENT.Base="ent_jack_gmod_ezresource"
ENT.PrintName="EZ Chemicals"
ENT.Category="JMod - EZ Resources"
ENT.Spawnable=true
ENT.AdminSpawnable=true
---
ENT.EZsupplies="chemicals"
ENT.JModPreferredCarryAngles=Angle(0,0,0)
ENT.MaxResource=JMod.EZbasicResourceBoxSize
ENT.Model="models/props_junk/PlasticCrate01a.mdl"
ENT.Material=nil
ENT.RandomSkins={0,1,2,3,4}
ENT.ModelScale=1.25
ENT.Mass=50
ENT.ImpactNoise1="Plastic_Box.ImpactHard"
ENT.ImpactNoise2="Weapon.ImpactSoft"
ENT.DamageThreshold=120
ENT.BreakNoise="Plastic_Box.Break"
ENT.Hint=nil
---
if(SERVER)then
	function ENT:UseEffect(pos,ent,destructive)
		for i=1,3 do
			if(math.random(1,30)==2)then
				local Eff=EffectData()
				Eff:SetOrigin(pos+VectorRand()*10)
				util.Effect("StriderBlood",Eff,true,true)
			end
			if(destructive)then
				for i=1,1 do
					local Blob=ents.Create("grenade_spit")
					Blob:SetPos(pos)
					Blob:SetAngles(VectorRand():Angle())
					Blob:SetVelocity((VectorRand()+vector_up)*math.Rand(0,500))
					Blob:SetOwner(game.GetWorld())
					Blob:Spawn()
					Blob:Activate()
				end
			end
		end
	end
	function ENT:AltUse(ply)
		--
	end
elseif(CLIENT)then
	local TxtCol=Color(10,10,10,250)
	function ENT:Initialize()
		self.Jug1=JMod.MakeModel(self,"models/props_junk/garbage_plasticbottle001a.mdl","models/debug/debugwhite")
		self.Jug2=JMod.MakeModel(self,"models/props_junk/garbage_plasticbottle002a.mdl","models/debug/debugwhite")
		self.Jug3=JMod.MakeModel(self,"models/props_junk/garbage_milkcarton001a.mdl","models/debug/debugwhite")
		self.Jug4=JMod.MakeModel(self,"models/props_junk/garbage_plasticbottle003a.mdl","models/debug/debugwhite")
		self.Jug5=JMod.MakeModel(self,"models/props_junk/garbage_plasticbottle003a.mdl","models/debug/debugwhite")
		self.Jug6=JMod.MakeModel(self,"models/props_junk/metal_paintcan001a.mdl","phoenix_storms/gear_top")
		self.Jug7=JMod.MakeModel(self,"models/props_junk/garbage_glassbottle001a.mdl","models/props_combine/health_charger_glass")
		self.Jug8=JMod.MakeModel(self,"models/props_junk/glassjug01.mdl","models/props_combine/health_charger_glass",1.5)
	end
	function ENT:Draw()
		local Ang,Pos=self:GetAngles(),self:GetPos()
		local Up,Right,Forward=Ang:Up(),Ang:Right(),Ang:Forward()
		local Closeness=LocalPlayer():GetFOV()*(EyePos():Distance(Pos))
		local DetailDraw=Closeness<18000 -- cutoff point is 200 units when the fov is 90 degrees
		self:DrawModel()
		local BasePos=Pos+Up*2
		local JugAng=Ang:GetCopy()
		JMod.RenderModel(self.Jug1,BasePos+Forward*5.5+Right*10,Ang)
		JMod.RenderModel(self.Jug2,BasePos+Forward*7,Ang)
		JMod.RenderModel(self.Jug3,BasePos-Forward*4-Up*2-Right*9,Ang)
		JMod.RenderModel(self.Jug4,BasePos-Forward*6,Ang)
		JMod.RenderModel(self.Jug5,BasePos+Forward*1+Right*1,Ang)
		JMod.RenderModel(self.Jug6,BasePos-Forward*4.5+Right*9-Up*3,Ang)
		JMod.RenderModel(self.Jug7,BasePos+Forward*3-Right*4-Up*2,Ang)
		JMod.RenderModel(self.Jug8,BasePos+Forward*6-Right*10-Up*10,Ang)
		if(DetailDraw)then
			local Chems=tostring(self:GetResource())
			Ang:RotateAroundAxis(Ang:Right(),90)
			Ang:RotateAroundAxis(Ang:Up(),-90)
			cam.Start3D2D(Pos+Up*6-Right*.6-Forward*11,Ang,.03)
			draw.SimpleText("JACKARUNDA INDUSTRIES","JMod-Stencil",0,0,TxtCol,TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
			draw.SimpleText("EZ CHEMICALS","JMod-Stencil",0,50,TxtCol,TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
			draw.SimpleText(Chems.." UNITS","JMod-Stencil",0,100,TxtCol,TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
			cam.End3D2D()
			---
			Ang:RotateAroundAxis(Ang:Right(),180)
			cam.Start3D2D(Pos+Up*6-Right*.6+Forward*11,Ang,.03)
			draw.SimpleText("JACKARUNDA INDUSTRIES","JMod-Stencil",0,0,TxtCol,TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
			draw.SimpleText("EZ CHEMICALS","JMod-Stencil",0,50,TxtCol,TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
			draw.SimpleText(Chems.." UNITS","JMod-Stencil",0,100,TxtCol,TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
			cam.End3D2D()
		end
	end
	language.Add(ENT.ClassName,ENT.PrintName)
end