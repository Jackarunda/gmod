-- Jackarunda 2019
AddCSLuaFile()
ENT.Type="anim"
ENT.PrintName="EZ Ammo Box"
ENT.Author="Jackarunda"
ENT.Category="JMod - EZ"
ENT.Information="glhfggwpezpznore"
ENT.Spawnable=true
ENT.AdminSpawnable=true
---
ENT.SuppliesEZammo=true
ENT.JModPreferredCarryAngles=Angle(0,90,0)
ENT.MaxAmmo=JMod_EZammoBoxSize
---
function ENT:SetupDataTables()
	self:NetworkVar("Int",0,"Ammo")
end
---
ENT.ShellEffects={"RifleShellEject","PistolShellEject","ShotgunShellEject"}
if(SERVER)then
	function ENT:SpawnFunction(ply,tr)
		local SpawnPos=tr.HitPos+tr.HitNormal*20
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
		self.Entity:SetModel("models/Items/BoxSRounds.mdl")
		self.Entity:SetMaterial("models/mat_jack_gmod_ezammobox")
		self:SetModelScale(2,0)
		self.Entity:PhysicsInit(SOLID_VPHYSICS)
		self.Entity:SetMoveType(MOVETYPE_VPHYSICS)	
		self.Entity:SetSolid(SOLID_VPHYSICS)
		self.Entity:DrawShadow(true)
		self.Entity:SetUseType(SIMPLE_USE)
		---
		self:SetAmmo(self.MaxAmmo)
		---
		self.NextLoad=0
		self.Loaded=false
		---
		timer.Simple(.01,function() self:GetPhysicsObject():SetMass(50) end)
	end
	function ENT:PhysicsCollide(data,physobj)
		if(self.Loaded)then return end
		if(data.DeltaTime>0.2)then
			if((data.HitEntity.ConsumesEZammo)and(self.NextLoad<CurTime())and(self:IsPlayerHolding()))then
				local Ammo=self:GetAmmo()
				local Used=data.HitEntity:TryLoadAmmo(Ammo)
				if(Used>0)then
					self:SetAmmo(Ammo-Used)
					for i=1,20 do
						local Eff=EffectData()
						Eff:SetOrigin(data.HitPos)
						Eff:SetAngles(VectorRand():Angle())
						Eff:SetEntity(data.HitEntity)
						util.Effect(table.Random(self.ShellEffects),Eff,true,true)
					end
					if(Used>=Ammo)then
						self.Loaded=true
						timer.Simple(.1,function() if(IsValid(self))then self:Remove() end end)
					end
					return
				end
			end
			if(data.Speed>80)then
				self.Entity:EmitSound("Metal_Box.ImpactHard")
				self.Entity:EmitSound("Weapon.ImpactSoft")
			end
		end
	end
	function ENT:OnTakeDamage(dmginfo)
		self.Entity:TakePhysicsDamage(dmginfo)
		if(dmginfo:GetDamage()>140)then
			local Pos=self:GetPos()
			sound.Play("Metal_Box.Break",Pos)
			for i=1,self:GetAmmo()/2 do
				local Eff=EffectData()
				Eff:SetOrigin(Pos)
				Eff:SetAngles((VectorRand()+Vector(0,0,1):GetNormalized()):Angle())
				Eff:SetEntity(game.GetWorld())
				util.Effect(table.Random(self.ShellEffects),Eff,true,true)
			end
			self:Remove()
		end
	end
	function ENT:Use(activator)
		activator:PickupObject(self)
	end
	function ENT:Think()
		--pfahahaha
	end
	function ENT:OnRemove()
		--aw fuck you
	end
elseif(CLIENT)then
	local TxtCol=Color(255,240,150,80)
	function ENT:Draw()
		local Ang,Pos=self:GetAngles(),self:GetPos()
		local Up,Right,Forward=Ang:Up(),Ang:Right(),Ang:Forward()
		local Closeness=LocalPlayer():GetFOV()*(EyePos():Distance(Pos))
		local DetailDraw=Closeness<27000 -- cutoff point is 300 units when the fov is 90 degrees
		self:DrawModel()
		if(DetailDraw)then
			Ang:RotateAroundAxis(Ang:Right(),90)
			Ang:RotateAroundAxis(Ang:Up(),-90)
			cam.Start3D2D(Pos+Up*16-Right*.6-Forward*5.9,Ang,.05)
			draw.SimpleText("JACKARUNDA INDUSTRIES","JMod-Stencil",0,0,TxtCol,TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
			draw.SimpleText("EZ LINKED CARTRIDGES","JMod-Stencil",0,50,TxtCol,TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
			draw.SimpleText(tostring(self:GetAmmo()).." COUNT","JMod-Stencil",0,100,TxtCol,TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
			cam.End3D2D()
			---
			Ang:RotateAroundAxis(Ang:Right(),180)
			cam.Start3D2D(Pos+Up*16-Right*.6+Forward*5.9,Ang,.05)
			draw.SimpleText("JACKARUNDA INDUSTRIES","JMod-Stencil",0,0,TxtCol,TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
			draw.SimpleText("EZ LINKED CARTRIDGES","JMod-Stencil",0,50,TxtCol,TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
			draw.SimpleText(tostring(self:GetAmmo()).." COUNT","JMod-Stencil",0,100,TxtCol,TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
			cam.End3D2D()
		end
	end
	language.Add("ent_jack_gmod_ezammo","EZ Ammo Box")
end