-- Jackarunda 2019
AddCSLuaFile()
ENT.Type="anim"
ENT.Author="Jackarunda"
ENT.Category="JMod - EZ"
ENT.Information="glhfggwpezpznore"
ENT.Spawnable=false
ENT.AdminSpawnable=false
---
ENT.JModPreferredCarryAngles=Angle(0,0,0)
ENT.DamageThreshold=120
---
function ENT:SetupDataTables()
	self:NetworkVar("Int",0,"ItemCount")
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
		self.Entity:SetModel("models/props_junk/wood_crate001a.mdl")
		self:SetModelScale(1.5,0)
		self.Entity:PhysicsInit(SOLID_VPHYSICS)
		self.Entity:SetMoveType(MOVETYPE_VPHYSICS)	
		self.Entity:SetSolid(SOLID_VPHYSICS)
		self.Entity:DrawShadow(true)
		self.Entity:SetUseType(SIMPLE_USE)
		---
		self:SetItemCount(0)
		self.EZconsumes={self.ItemType}
		---
		timer.Simple(.01,function() self:GetPhysicsObject():SetMass(125) end)
	end
	function ENT:PhysicsCollide(data,physobj)
		if(data.DeltaTime>0.2)then
			if(data.Speed>100)then
				self.Entity:EmitSound("Wood_Crate.ImpactHard")
				self.Entity:EmitSound("Wood_Box.ImpactHard")
			end
		end
		local Ent=data.HitEntity
		if((self.ChildEntity==Ent:GetClass())and(Ent:IsPlayerHolding()))then
			if(self:GetItemCount()<self.MaxItems)then
				timer.Simple(.1,function()
					if(IsValid(Ent))then
						Ent:Remove()
						self:SetItemCount(self:GetItemCount()+1)
					end
				end)
			end
		end
	end
	function ENT:OnTakeDamage(dmginfo)
		self.Entity:TakePhysicsDamage(dmginfo)
		if(dmginfo:GetDamage()>self.DamageThreshold)then
			local Pos=self:GetPos()
			sound.Play("Wood_Crate.Break",Pos)
			sound.Play("Wood_Box.Break",Pos)
			for i=1,math.floor(self:GetItemCount()) do
				local Box=ents.Create(self.ChildEntity)
				Box:SetPos(Pos+self:GetUp()*20)
				Box:SetAngles(self:GetAngles())
				Box:Spawn()
				Box:Activate()
			end
			self:Remove()
		end
	end
	function ENT:Use(activator)
		JMod_Hint(activator,"item crate")
		local Resource=self:GetItemCount()
		if(Resource<=0)then return end
		local Box=ents.Create(self.ChildEntity)
		Box:SetPos(self:GetPos()+self:GetUp()*20)
		Box:SetAngles(self:GetAngles())
		Box:Spawn()
		Box:Activate()
		self:SetItemCount(Resource-1)
		activator:PickupObject(Box)
		Box.NextLoad=CurTime()+2
		self:EmitSound("Ammo_Crate.Close")
	end
	function ENT:Think()
		--pfahahaha
	end
	function ENT:OnRemove()
		--aw fuck you
	end
elseif(CLIENT)then
	local TxtCol=Color(10,10,10,220)
	function ENT:Draw()
		local Ang,Pos=self:GetAngles(),self:GetPos()
		local Closeness=LocalPlayer():GetFOV()*(EyePos():Distance(Pos))
		local DetailDraw=Closeness<45000 -- cutoff point is 500 units when the fov is 90 degrees
		self:DrawModel()
		if(DetailDraw)then
			local Up,Right,Forward,Resource=Ang:Up(),Ang:Right(),Ang:Forward(),tostring(self:GetItemCount())
			Ang:RotateAroundAxis(Ang:Right(),90)
			Ang:RotateAroundAxis(Ang:Up(),-90)
			cam.Start3D2D(Pos+Up*18-Forward*29.8+Right,Ang,.2)
			draw.SimpleText("JACKARUNDA INDUSTRIES","JMod-Stencil-S",0,0,TxtCol,TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
			draw.SimpleText(self.MainTitleWord,"JMod-Stencil",0,15,TxtCol,TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
			draw.SimpleText(Resource.." "..self.ResourceUnit,"JMod-Stencil-S",0,70,TxtCol,TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
			cam.End3D2D()
			---
			Ang:RotateAroundAxis(Ang:Right(),180)
			cam.Start3D2D(Pos+Up*18+Forward*30.1-Right,Ang,.2)
			draw.SimpleText("JACKARUNDA INDUSTRIES","JMod-Stencil-S",0,0,TxtCol,TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
			draw.SimpleText(self.MainTitleWord,"JMod-Stencil",0,15,TxtCol,TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
			draw.SimpleText(Resource.." "..self.ResourceUnit,"JMod-Stencil-S",0,70,TxtCol,TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
			cam.End3D2D()
		end
	end
end