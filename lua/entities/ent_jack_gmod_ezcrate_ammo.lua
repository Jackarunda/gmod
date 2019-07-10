-- Jackarunda 2019
AddCSLuaFile()
ENT.Type="anim"
ENT.PrintName="EZ Ammo Crate"
ENT.Author="Jackarunda"
ENT.Category="JMod - EZ"
ENT.Information="glhfggwpezpznore"
ENT.Spawnable=true
ENT.AdminSpawnable=true
---
ENT.ConsumesEZammo=true
ENT.JModPreferredCarryAngles=Angle(0,90,0)
ENT.MaxAmmo=JMod_EZammoBoxSize*JMod_EZammoCrateSize
---
function ENT:SetupDataTables()
	self:NetworkVar("Int",0,"Ammo")
end
---
if(SERVER)then
	function ENT:SpawnFunction(ply,tr)
		local SpawnPos=tr.HitPos+tr.HitNormal*40
		local ent=ents.Create(self.ClassName)
		ent:SetAngles(Angle(0,0,0))
		ent:SetPos(SpawnPos)
		ent.Owner=ply
		ent:Spawn()
		ent:Activate()
		--local effectdata=EffectData()
		--effectdata:SetEntity(ent)
		--util.Effect("propspawn",effectdata)
		return ent
	end
	function ENT:Initialize()
		self.Entity:SetModel("models/props_junk/wood_crate002a.mdl")
		self:SetModelScale(1.5,0)
		self.Entity:PhysicsInit(SOLID_VPHYSICS)
		self.Entity:SetMoveType(MOVETYPE_VPHYSICS)	
		self.Entity:SetSolid(SOLID_VPHYSICS)
		self.Entity:DrawShadow(true)
		self.Entity:SetUseType(SIMPLE_USE)
		---
		self:SetAmmo(0)
		---
		timer.Simple(.01,function() self:GetPhysicsObject():SetMass(250) end)
	end
	function ENT:PhysicsCollide(data,physobj)
		if(data.DeltaTime>0.2)then
			if(data.Speed>100)then
				self.Entity:EmitSound("Wood_Crate.ImpactHard")
				self.Entity:EmitSound("Wood_Box.ImpactHard")
			end
		end
	end
	function ENT:OnTakeDamage(dmginfo)
		self.Entity:TakePhysicsDamage(dmginfo)
		if(dmginfo:GetDamage()>140)then
			local Pos=self:GetPos()
			sound.Play("Wood_Crate.Break",Pos)
			sound.Play("Wood_Box.Break",Pos)
			for i=1,math.floor(self:GetAmmo()/JMod_EZammoBoxSize) do
				local Box=ents.Create("ent_jack_gmod_ezammo")
				Box:SetPos(Pos+self:GetUp()*20)
				Box:SetAngles(self:GetAngles())
				Box:Spawn()
				Box:Activate()
			end
			self:Remove()
		end
	end
	function ENT:Use(activator)
		local Ammo=self:GetAmmo()
		if(Ammo<=0)then return end
		local Box,Given=ents.Create("ent_jack_gmod_ezammo"),math.min(Ammo,JMod_EZammoBoxSize)
		Box:SetPos(self:GetPos()+self:GetUp()*20)
		Box:SetAngles(self:GetAngles())
		Box:Spawn()
		Box:Activate()
		Box:SetAmmo(Given)
		activator:PickupObject(Box)
		Box.NextLoad=CurTime()+1
		self:SetAmmo(Ammo-Given)
		self:EmitSound("AmmoCrate.Close")
	end
	function ENT:Think()
		--pfahahaha
	end
	function ENT:OnRemove()
		--aw fuck you
	end
	function ENT:TryLoadAmmo(amt)
		if(amt<=0)then return 0 end
		local Ammo=self:GetAmmo()
		local Missing=self.MaxAmmo-Ammo
		if(Missing<=0)then return 0 end
		local Accepted=math.min(Missing,amt)
		self:SetAmmo(Ammo+Accepted)
		return Accepted
	end
elseif(CLIENT)then
	local TxtCol=Color(10,10,10,220)
	function ENT:Draw()
		local Ang,Pos=self:GetAngles(),self:GetPos()
		local Up,Right,Forward=Ang:Up(),Ang:Right(),Ang:Forward()
		local Closeness=LocalPlayer():GetFOV()*(EyePos():Distance(Pos))
		local DetailDraw=Closeness<45000 -- cutoff point is 500 units when the fov is 90 degrees
		self:DrawModel()
		if(DetailDraw)then
			Ang:RotateAroundAxis(Ang:Right(),90)
			Ang:RotateAroundAxis(Ang:Up(),-90)
			cam.Start3D2D(Pos+Up*18-Forward*29.8,Ang,.4)
			draw.SimpleText("JACKARUNDA INDUSTRIES","JMod-Stencil-S",0,0,TxtCol,TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
			draw.SimpleText("AMMO","JMod-Stencil",0,15,TxtCol,TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
			draw.SimpleText(tostring(self:GetAmmo()).." COUNT","JMod-Stencil-S",0,70,TxtCol,TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
			cam.End3D2D()
			---
			Ang:RotateAroundAxis(Ang:Right(),180)
			cam.Start3D2D(Pos+Up*18+Forward*29.9,Ang,.4)
			draw.SimpleText("JACKARUNDA INDUSTRIES","JMod-Stencil-S",0,0,TxtCol,TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
			draw.SimpleText("AMMO","JMod-Stencil",0,15,TxtCol,TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
			draw.SimpleText(tostring(self:GetAmmo()).." COUNT","JMod-Stencil-S",0,70,TxtCol,TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
			cam.End3D2D()
		end
	end
	language.Add("ent_jack_gmod_ezcrate_ammo","EZ Ammo Crate")
end