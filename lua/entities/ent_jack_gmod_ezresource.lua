-- Jackarunda 2021
AddCSLuaFile()
ENT.Type="anim"
ENT.Author="Jackarunda"
ENT.Category="JMod - EZ Resources"
ENT.Information="glhfggwpezpznore"
ENT.NoSitAllowed=true
ENT.Spawnable=false
ENT.AdminSpawnable=false
---
ENT.IsJackyEZresource=true
---
function ENT:SetupDataTables()
	self:NetworkVar("Int",0,"Resource")
end
---
if(SERVER)then
	function ENT:SpawnFunction(ply,tr)
		local SpawnPos=tr.HitPos+tr.HitNormal*(self.SpawnHeight or 20)*self.ModelScale
		local ent=ents.Create(self.ClassName)
		ent:SetAngles(Angle(0,0,0))
		ent:SetPos(SpawnPos)
		JMod.Owner(ent,ply)
		ent:Spawn()
		ent:Activate()
		--local effectdata=EffectData()
		--effectdata:SetEntity(ent)
		--util.Effect("propspawn",effectdata)
		return ent
	end
	function ENT:Initialize()
		if(self.Models)then
			self.Entity:SetModal(table.Random(self.Models))
		else
			self.Entity:SetModel(self.Model)
		end
		self.Entity:SetMaterial(self.Material)
		self:SetModelScale(self.ModelScale,0)
		if(self.Color)then self:SetColor(self.Color) end
		if(self.Skin)then self:SetSkin(self.Skin) end
		if(self.RandomSkins)then self:SetSkin(table.Random(self.RandomSkins)) end
		self.Entity:PhysicsInit(SOLID_VPHYSICS)
		self.Entity:SetMoveType(MOVETYPE_VPHYSICS)	
		self.Entity:SetSolid(SOLID_VPHYSICS)
		self.Entity:DrawShadow(true)
		self.Entity:SetUseType(SIMPLE_USE)
		---
		self:SetResource(100)
		---
		self.NextLoad=0
		self.Loaded=false
		self.NextCombine=0
		---
		timer.Simple(.01,function()
			self:GetPhysicsObject():SetMass(self.Mass)
			self:GetPhysicsObject():Wake()
		end)
	end
	function ENT:FlingProp(mdl)
		local Prop=ents.Create("prop_physics")
		Prop:SetPos(self:GetPos())
		Prop:SetAngles(VectorRand():Angle())
		Prop:SetModel(mdl)
		Prop:SetModelScale(.5,0)
		Prop:Spawn()
		Prop:Activate()
		Prop.JModNoPickup=true
		if(math.random(1,2)==1)then
			if(Prop.SetHealth)then Prop:SetHealth(100) end
		end
		Prop:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
		constraint.NoCollide(Prop,self,0,0)
		local Phys=Prop:GetPhysicsObject()
		Phys:SetVelocity((VectorRand()+Vector(0,0,1)):GetNormalized()*math.Rand(100,300))
		Phys:AddAngleVelocity(VectorRand()*math.Rand(1,10000))
		SafeRemoveEntityDelayed(Prop,math.Rand(5,10))
	end
	function ENT:PhysicsCollide(data,physobj)
		if(self.Loaded)then return end
		if(data.DeltaTime>0.2)then
			local Time=CurTime()
			if(data.HitEntity.ClassName==self.ClassName and self.NextCombine<Time and data.HitEntity.NextCombine<Time)then
				-- determine a priority, favor the item that has existed longer
				if(self:EntIndex()<data.HitEntity:EntIndex())then
					-- don't run twice on every collision
					-- try to combine
					local Sum=self:GetResource()+data.HitEntity:GetResource()
					if(Sum<=100)then
						self:SetResource(Sum)
						data.HitEntity:Remove()
						self:UseEffect(data.HitPos,data.HitEntity)
						return
					end
				end
			end
			if((data.HitEntity.EZconsumes)and(table.HasValue(data.HitEntity.EZconsumes,self.EZsupplies))and(self.NextLoad<Time)and(self:IsPlayerHolding()))then
				if(self:GetResource()<=0)then self:Remove() return end
				local Resource=self:GetResource()
				local Used=data.HitEntity:TryLoadResource(self.EZsupplies,Resource)
				if(Used>0)then
					self:SetResource(Resource-Used)
					self:UseEffect(data.HitPos,data.HitEntity)
					if(Used>=Resource)then
						self.Loaded=true
						timer.Simple(.1,function() if(IsValid(self))then self:Remove() end end)
					end
					return
				end
			end
			if((data.Speed>80)and(self)and(self.ImpactNoise1))then
				self.Entity:EmitSound(self.ImpactNoise1)
				if(self.ImpactNoise2)then self.Entity:EmitSound(self.ImpactNoise2) end
			end
			if(self.ImpactSensitivity)then
				if(data.Speed>self.ImpactSensitivity)then
					local Pos=self:GetPos()
					sound.Play(self.BreakNoise,Pos)
					for i=1,self:GetResource()/10 do self:UseEffect(Pos,game.GetWorld(),true) end
					self:Remove()
				end
			end
		end
	end
	function ENT:OnTakeDamage(dmginfo)
		self.Entity:TakePhysicsDamage(dmginfo)
		if(dmginfo:GetDamage()>self.DamageThreshold)then
			local Pos=self:GetPos()
			sound.Play(self.BreakNoise,Pos)
			for i=1,self:GetResource()/10 do self:UseEffect(Pos,game.GetWorld(),true) end
			self:Remove()
		end
	end
	function ENT:Use(activator)
		local AltPressed,Count=activator:KeyDown(JMod.Config.AltFunctionKey),self:GetResource()
		if((AltPressed)and(activator:KeyDown(IN_SPEED)))then
			-- split resource entity in half
			if(Count>1)then
				local NewCountOne,NewCountTwo=math.ceil(Count/2),math.floor(Count/2)
				local Box=ents.Create(self.ClassName)
				Box:SetPos(self:GetPos()+self:GetUp()*5)
				Box:SetAngles(self:GetAngles())
				Box:Spawn()
				Box:Activate()
				Box:SetResource(NewCountOne)
				activator:PickupObject(Box)
				Box.NextCombine=CurTime()+2
				self.NextCombine=CurTime()+2
				self:SetResource(NewCountTwo)
				self:UseEffect(self:GetPos(),self)
			end
		elseif((self.AltUse)and(AltPressed))then
			self:AltUse(activator)
		else
			JMod.Hint(activator,"resource manage")
			activator:PickupObject(self)
			if JMod.Hints[self:GetClass() .. " use"] then
				JMod.Hint(activator, self:GetClass() .. " use", self)
			end
		end
	end
	function ENT:Think()
		--
	end
	function ENT:OnRemove()
		--aw fuck you
	end
end