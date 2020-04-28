-- Jackarunda 2019
AddCSLuaFile()
ENT.Type="anim"
ENT.PrintName="ANOMALOUS CRATE"
ENT.Author="Jackarunda"
ENT.NoSitAllowed=true
ENT.Spawnable=false
ENT.AdminSpawnable=false
---
ENT.JModPreferredCarryAngles=Angle(0,0,0)
ENT.DamageThreshold=120
---
ENT.MaxResource=1
ENT.ChildEntity=""
ENT.ChildEntityResourceAmount=0
ENT.MainTitleWord="RESOURCES"
ENT.ResourceUnit="Units"
---
function ENT:SetupDataTables()
	--
end
---
if(SERVER)then
	function ENT:Initialize()
		self.Entity:SetModel("models/props_junk/wood_crate002a.mdl")
		self.Entity:SetModelScale(.4,0)
		self.Entity:PhysicsInit(SOLID_VPHYSICS)
		self.Entity:SetMoveType(MOVETYPE_VPHYSICS)	
		self.Entity:SetSolid(SOLID_VPHYSICS)
		self.Entity:DrawShadow(true)
		self.Entity:SetUseType(SIMPLE_USE)
		self.Durability=100
		local Phys=self:GetPhysicsObject()
		if(IsValid(Phys))then
			Phys:Wake()
		end
		timer.Simple(0,function()
			self.Entity:SetModelScale(1,.5)
			self.Entity:PhysicsInit(SOLID_VPHYSICS)
			local Phys=self:GetPhysicsObject()
			if(IsValid(Phys))then
				Phys:Wake()
			end
		end)
	end
	function ENT:PhysicsCollide(data,physobj)
		if(data.DeltaTime>0.2)then
			if(data.Speed>100)then
				self.Entity:EmitSound("Wood_Crate.ImpactHard")
				self.Entity:EmitSound("Wood_Box.ImpactHard")
				if(data.Speed>500)then
					self.Durability=self.Durability-data.Speed/10
					if(self.Durability<=0)then self:BreakOpen() end
				end
			end
		end
	end
	function ENT:OnTakeDamage(dmginfo)
		self.Entity:TakePhysicsDamage(dmginfo)
		self.Durability=self.Durability-dmginfo:GetDamage()
		self.LastDmgForce=dmginfo:GetDamageForce()
		if(self.Durability<=0)then self:BreakOpen() end
	end
	function ENT:Use(activator)
		---
	end
	function ENT:Think()
		--pfahahaha
	end
	local GibNums={1,2,3,4,5,6,7,9}
	function ENT:BreakOpen()
		local Pos,Ang,Mdl,Vel=self:LocalToWorld(self:OBBCenter()),self:GetAngles(),self:GetModel(),self:GetVelocity()
		self:Remove()
		local Eff=EffectData()
		Eff:SetOrigin(Pos)
		Eff:SetStart(Vel)
		util.Effect("eff_jack_gmod_woodsplosion",Eff,true,true)
		for i=1,10 do
			local Gib=ents.Create("prop_physics")
			Gib:SetModel("models/props_junk/wood_crate001a_chunk0"..table.Random(GibNums)..".mdl")
			Gib:SetPos(Pos+VectorRand()*30+Vector(0,0,10))
			Gib:SetAngles(Ang)
			Gib:Spawn()
			Gib:Activate()
			Gib:SetCollisionGroup(COLLISION_GROUP_WORLD)
			Gib:GetPhysicsObject():SetVelocity(Vel+VectorRand()*math.random(10,1000)+Vector(0,0,50))
			SafeRemoveEntityDelayed(Gib,math.random(3,6))
		end
	end
	function ENT:OnRemove()
		--if(true)then return end
		local Pos,Ang,Up,Right,Forward,Class,Vel=self:GetPos(),self:GetAngles(),self:GetUp(),self:GetRight(),self:GetForward(),self.ClassName,self:GetVelocity()
		timer.Simple(0,function()
			local Box1=ents.Create(Class)
			Box1:SetPos(Pos+Right*20)
			Ang:RotateAroundAxis(Up,90)
			Box1:SetAngles(Ang)
			Box1:Spawn()
			Box1:Activate()
			timer.Simple(0,function() Box1:GetPhysicsObject():SetVelocity(Vel) end)
			local Box2=ents.Create(Class)
			Box2:SetPos(Pos-Right*20)
			Ang:RotateAroundAxis(Up,180)
			Box2:SetAngles(Ang)
			Box2:Spawn()
			Box2:Activate()
			timer.Simple(0,function() Box2:GetPhysicsObject():SetVelocity(Vel) end)
		end)
	end
elseif(CLIENT)then
	function ENT:Draw()
		self:DrawModel()
	end
	language.Add("ent_jack_gmod_ezanomaly_crare","ANOMALOUS CRATE")
end
