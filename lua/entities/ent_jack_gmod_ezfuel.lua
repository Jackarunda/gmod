-- Jackarunda 2019
AddCSLuaFile()
ENT.Base="ent_jack_gmod_ezresource"
ENT.PrintName="EZ Fuel Can"
ENT.Category="JMod - EZ Resources"
ENT.Spawnable=true
ENT.AdminSpawnable=true
---
ENT.EZsupplies="fuel"
ENT.JModPreferredCarryAngles=Angle(0,0,0)
ENT.MaxResource=JMod_EZfuelCanSize
ENT.Model="models/props_junk/gascan001a.mdl"
ENT.Material=nil
ENT.ModelScale=1.25
ENT.Mass=50
ENT.ImpactNoise1="Weapon.ImpactSoft"
ENT.ImpactNoise2="Metal_Box.ImpactHard"
ENT.DamageThreshold=120
ENT.BreakNoise="Metal_Box.Break"
ENT.Hint=nil
---
if(SERVER)then
	function ENT:UseEffect(pos,ent,destructive)
		if destructive and vFireInstalled then
			CreateVFireBall(math.random(5, 15), math.random(5, 15), pos, VectorRand() * math.random(100, 200))
		end
		for i=1,3 do
			local Eff=EffectData()
			Eff:SetOrigin(pos+VectorRand()*10)
			util.Effect("StriderBlood",Eff,true,true)
			if destructive and not vFireInstalled then
				local Tr=util.QuickTrace(pos,Vector(math.random(-200,200),math.random(-200,200),math.random(0,-200)),{self})
				if(Tr.Hit)then
					local Fiah=ents.Create("env_fire")
					Fiah:SetPos(Tr.HitPos+Tr.HitNormal)
					Fiah:SetKeyValue("health",30)
					Fiah:SetKeyValue("fireattack",1)
					Fiah:SetKeyValue("firesize",math.random(20,200))
					Fiah:SetOwner(self.Owner or game.GetWorld())
					Fiah:Spawn()
					Fiah:Activate()
					Fiah:Fire("StartFire","",0)
					Fiah:Fire("kill","",math.random(3,10))
				end
			end
		end
	end
	function ENT:AltUse(ply)
		--
	end
	function ENT:OnTakeDamage(dmginfo)
		self:TakePhysicsDamage(dmginfo)
		if dmginfo:GetDamage() > self.DamageThreshold then
			local Pos = self:GetPos()
			sound.Play(self.BreakNoise,Pos)
			for i = 1, self:GetResource() / 2 do self:UseEffect(Pos,game.GetWorld(),true) end
			self:Remove()
		elseif (dmginfo:IsDamageType(DMG_BURN) or dmginfo:IsDamageType(DMG_DIRECT)) and math.random() <= 0.1 * math.Clamp(dmginfo:GetDamage() / 10, 1, 5) then
			local Pos = self:GetPos()
			sound.Play("ambient/fire/gascan_ignite1.wav",Pos,70,90)
			for i = 1, self:GetResource() / 2 do self:UseEffect(Pos,game.GetWorld(),true) end
			self:Remove()
		end
	end
elseif(CLIENT)then
	local TxtCol=Color(255,255,255,80)
	function ENT:Draw()
		local Ang,Pos=self:GetAngles(),self:GetPos()
		local Closeness=LocalPlayer():GetFOV()*(EyePos():Distance(Pos))
		local DetailDraw=Closeness<18000 -- cutoff point is 200 units when the fov is 90 degrees
		self:DrawModel()
		if(DetailDraw)then
			local Up,Right,Forward,Ammo=Ang:Up(),Ang:Right(),Ang:Forward(),tostring(self:GetResource())
			Ang:RotateAroundAxis(Ang:Right(),90)
			Ang:RotateAroundAxis(Ang:Up(),-90)
			cam.Start3D2D(Pos+Up*8-Right*.6-Forward*4.85,Ang,.03)
			draw.SimpleText("JACKARUNDA INDUSTRIES","JMod-Stencil",0,0,TxtCol,TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
			draw.SimpleText("EZ FUEL","JMod-Stencil",0,50,TxtCol,TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
			draw.SimpleText(Ammo.." UNITS","JMod-Stencil",0,100,TxtCol,TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
			cam.End3D2D()
			---
			Ang:RotateAroundAxis(Ang:Right(),180)
			cam.Start3D2D(Pos+Up*8-Right*.6+Forward*4.85,Ang,.03)
			draw.SimpleText("JACKARUNDA INDUSTRIES","JMod-Stencil",0,0,TxtCol,TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
			draw.SimpleText("EZ FUEL","JMod-Stencil",0,50,TxtCol,TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
			draw.SimpleText(Ammo.." UNITS","JMod-Stencil",0,100,TxtCol,TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
			cam.End3D2D()
		end
	end
	language.Add(ENT.ClassName,ENT.PrintName)
end