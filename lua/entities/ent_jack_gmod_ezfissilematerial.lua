-- Jackarunda 2019
AddCSLuaFile()
ENT.Base="ent_jack_gmod_ezresource"
ENT.PrintName="EZ Fissile Material"
ENT.Category="JMod - EZ Resources"
ENT.Spawnable=true
ENT.AdminOnly=true
---
ENT.EZsupplies="fissilematerial"
ENT.JModPreferredCarryAngles=Angle(0,0,0)
ENT.MaxResource=JMod_EZsuperRareResourceSize
ENT.Model="models/kali/props/cases/hard case c.mdl"
ENT.ModelScale=1
ENT.Skin=2
ENT.Mass=150
ENT.ImpactNoise1="Canister.ImpactHard"
ENT.ImpactNoise2="Weapon.ImpactSoft"
ENT.DamageThreshold=120
ENT.BreakNoise="Metal_Box.Break"
---
if(SERVER)then
	function ENT:UseEffect(pos,ent,destructive)
		if((destructive)and not(self.Sploomd))then
			self.Sploomd=true
			for k=1,10*JMOD_CONFIG.NuclearRadiationMult do
				local Gas=ents.Create("ent_jack_gmod_ezfalloutparticle")
				Gas:SetPos(self:GetPos())
				JMod_Owner(Gas,self.Owner or game.GetWorld())
				Gas:Spawn()
				Gas:Activate()
				Gas:GetPhysicsObject():SetVelocity(VectorRand()*math.random(1,50)+Vector(0,0,10*JMOD_CONFIG.NuclearRadiationMult))
			end
		end
	end
	function ENT:AltUse(ply)
		--
	end
elseif(CLIENT)then
	local TxtCol,Trefoil=Color(255,255,255,80),Material("png_jack_gmod_radiation.png")
	function ENT:Draw()
		local Ang,Pos=self:GetAngles(),self:GetPos()
		local Closeness=LocalPlayer():GetFOV()*(EyePos():Distance(Pos))
		local DetailDraw=Closeness<18000 -- cutoff point is 200 units when the fov is 90 degrees
		self:DrawModel()
		if(DetailDraw)then
			local Up,Right,Forward,Count=Ang:Up(),Ang:Right(),Ang:Forward(),tostring(self:GetResource())
			Ang:RotateAroundAxis(Ang:Up(),-90)
			cam.Start3D2D(Pos+Up*21.8-Right*.6+Forward*10,Ang,.05)
			draw.SimpleText("JACKARUNDA INDUSTRIES","JMod-Stencil",0,0,TxtCol,TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
			draw.SimpleText("EZ FISSILE MATERIAL","JMod-Stencil",0,50,TxtCol,TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
			draw.SimpleText(Count.." UNITS","JMod-Stencil",0,100,TxtCol,TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
			surface.SetDrawColor(255,255,255,80)
			surface.SetMaterial(Trefoil)
			surface.DrawTexturedRect(-128,160,256,256)
			cam.End3D2D()
		end
	end
	language.Add(ENT.ClassName,ENT.PrintName)
end