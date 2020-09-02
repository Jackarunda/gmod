-- Jackarunda 2020
AddCSLuaFile()
ENT.Type="anim"
ENT.Author="Jackarunda"
ENT.Category="JMod - EZ Ammo Types"
ENT.Information="glhfggwpezpznore"
ENT.PrintName="EZ Ammo Box"
ENT.NoSitAllowed=true
ENT.Spawnable=false
ENT.AdminSpawnable=false
---
ENT.JModEZstorable=true
ENT.JModPreferredCarryAngles=Angle(0,90,0)
---
function ENT:SetupDataTables()
	self:NetworkVar("Int",0,"Count")
end
if(SERVER)then
	function ENT:SpawnFunction(ply,tr)
		local SpawnPos=tr.HitPos+tr.HitNormal*40
		local ent=ents.Create(self.ClassName)
		ent:SetAngles(Angle(0,0,0))
		ent:SetPos(SpawnPos)
		JMod_Owner(ent,ply)
		ent:Spawn()
		ent:Activate()
		--local effectdata=EffectData()
		--effectdata:SetEntity(ent)
		--util.Effect("propspawn",effectdata)
		return ent
	end
	function ENT:Initialize()
		self.Specs=JMod_GetAmmoSpecs(self.EZammo)
		self.Entity:SetModel("models/props_junk/cardboard_box004a.mdl")
		self.Entity:SetMaterial(self.Specs.mat or "")
		--self.Entity:PhysicsInitBox(Vector(-10,-10,-10),Vector(10,10,10))
		if((self.ModelScale)and not(self.Specs.gayPhysics))then self:SetModelScale(self.ModelScale) end
		self.Entity:PhysicsInit(SOLID_VPHYSICS)
		self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
		self.Entity:SetSolid(SOLID_VPHYSICS)
		self.Entity:DrawShadow(true)
		self.Entity:SetUseType(SIMPLE_USE)
		if(self.Specs.size)then self:SetModelScale(self.Specs.size,0) end
		self:GetPhysicsObject():SetMass(10)
		timer.Simple(.01,function()
			self:GetPhysicsObject():SetMass(10)
			self:GetPhysicsObject():Wake()
		end)
		self.Entity:SetColor(Color(50,50,50))
		---
		self.EZID=self.EZID or JMod_GenerateGUID()
		---
		self:SetCount(self.Specs.carrylimit) -- default to full
	end
	function ENT:PhysicsCollide(data,physobj)
		if(data.DeltaTime>0.1)then
			self.Entity:EmitSound("weapon.ImpactSoft")
		end
	end
	function ENT:OnTakeDamage(dmginfo)
		self.Entity:TakePhysicsDamage(dmginfo)
		if(dmginfo:GetDamage()>=110)then
			self:Remove()
		end
	end
	function ENT:UseEffect()
		-- stub
	end
	function ENT:Use(activator)
		local Alt=activator:KeyDown(JMOD_CONFIG.AltFunctionKey)
		if(Alt)then
			activator:PickupObject(self)
		else
			JMod_GiveAmmo(activator,self)
		end
	end
elseif(CLIENT)then
	local TxtCol=Color(255,255,255,80)
	function ENT:Initialize()
		self.Graphic=Material("ez_ammo_graphics/"..self.EZammo..".png")
	end
	function ENT:Draw()
		local Ang,Pos=self:GetAngles(),self:GetPos()
		local Closeness=LocalPlayer():GetFOV()*(EyePos():Distance(Pos))
		local DetailDraw=Closeness<18000 -- cutoff point is 200 units when the fov is 90 degrees
		self:DrawModel()
		if(DetailDraw)then
			local Up,Right,Forward,Ammo=Ang:Up(),Ang:Right(),Ang:Forward(),tostring(self:GetCount())
			Ang:RotateAroundAxis(Up,180)
			cam.Start3D2D(Pos+Up*4.1+Right*5,Ang,.019)
			draw.SimpleText("JACKARUNDA INDUSTRIES","JMod-Stencil-MS",0,340,TxtCol,TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
			draw.SimpleText(self.PrintName,"JMod-Stencil-MS",0,390,TxtCol,TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
			draw.SimpleText(Ammo.." COUNT","JMod-Stencil-MS",0,440,TxtCol,TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
			---
			local LightCol=render.GetLightColor(Pos)
			LightCol.x=math.Clamp(LightCol.x*512,25,255)
			LightCol.y=math.Clamp(LightCol.y*512,25,255)
			LightCol.z=math.Clamp(LightCol.z*512,25,255)
			surface.SetMaterial(self.Graphic)
			surface.SetDrawColor(LightCol.x,LightCol.y,LightCol.z,240)
			surface.DrawTexturedRect(-300,0,600,300)
			cam.End3D2D()
			---
			Ang:RotateAroundAxis(Forward,-90)
			cam.Start3D2D(Pos+Up*3.1-Right*5.45,Ang,.019)
			surface.SetMaterial(self.Graphic)
			surface.SetDrawColor(LightCol.x,LightCol.y,LightCol.z,240)
			surface.DrawTexturedRect(-300,0,600,300)
			cam.End3D2D()
		end
	end
	language.Add("ent_jack_gmod_ezammobox","EZ Ammo Box")
end