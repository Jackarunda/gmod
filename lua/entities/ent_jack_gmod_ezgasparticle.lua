-- Jackarunda 2019
AddCSLuaFile()
ENT.Type="anim"
ENT.PrintName="EZ Poison Gas"
ENT.Author="Jackarunda"
ENT.Editable=true
ENT.Spawnable=false
ENT.AdminSpawnable=false
ENT.AdminOnly=false
ENT.RenderGroup=RENDERGROUP_TRANSLUCENT
ENT.EZgasParticle=true
if(SERVER)then
	function ENT:Initialize()
		local Time=CurTime()
		self.LifeTime=math.random(50,100)*JMOD_CONFIG.PoisonGasLingerTime
		self.DieTime=Time+self.LifeTime
		self:SetModel("models/dav0r/hoverball.mdl")
		self:SetMaterial("models/debug/debugwhite")
		self:RebuildPhysics()
		self:DrawShadow(false)
		self.NextDmg=Time+5
	end
	function ENT:ShouldDamage(ent)
		if not(IsValid(ent))then return end
		if(ent:IsPlayer())then return ent:Alive() end
		if((ent:IsNPC())and(ent.Health)and(ent:Health()))then
			local Phys=ent:GetPhysicsObject()
			if(IsValid(Phys))then
				local Mat=Phys:GetMaterial()
				if(Mat)then
					if(Mat=="metal")then return false end
					if(Mat=="default")then return false end
				end
			end
			return ent:Health()>0
		end
		return false
	end
	function ENT:CanSee(ent)
		local Tr=util.TraceLine({
			start=self:GetPos(),
			endpos=ent:GetPos(),
			filter={self,ent},
			mask=MASK_SHOT
		})
		return not Tr.Hit
	end
	function ENT:Think()
		if(CLIENT)then return end
		local Time,SelfPos=CurTime(),self:GetPos()
		if(self.DieTime<Time)then self:Remove() return end
		local Force=VectorRand()*10
		for key,obj in pairs(ents.FindInSphere(SelfPos,300))do
			if(not(obj==self)and(self:CanSee(obj)))then
				if(obj.EZgasParticle)then
					local Vec=(obj:GetPos()-SelfPos):GetNormalized()
					Force=Force-Vec*40
				elseif((self:ShouldDamage(obj))and(math.random(1,3)==1)and(self.NextDmg<Time))then
					local Dmg,Helf=DamageInfo(),obj:Health()
					Dmg:SetDamageType(DMG_NERVEGAS)
					Dmg:SetDamage(math.random(1,4)*JMOD_CONFIG.PoisonGasDamage)
					Dmg:SetInflictor(self)
					Dmg:SetAttacker(self.Owner or self)
					Dmg:SetDamagePosition(obj:GetPos())
					obj:TakeDamageInfo(Dmg)
					if((obj:Health()<Helf)and(math.random(1,7)==3)and(obj:IsPlayer()))then
						obj:EmitSound("ambient/voices/cough"..math.random(1,4)..".wav",60,math.random(90,110))
						if(obj.ViewPunch)then obj:ViewPunch(Angle(5,0,0)) end
					end
				end
			end
		end
		local Phys=self:GetPhysicsObject()
		Phys:SetVelocity(Phys:GetVelocity()*.8)
		Phys:ApplyForceCenter(Force)
		self:NextThink(Time+3)
		return true
	end
	function ENT:RebuildPhysics()
		local size=1
		self:PhysicsInitSphere(size,"gmod_silent")
		self:SetCollisionBounds(Vector( -.1, -.1, -.1 ),Vector( .1, .1, .1 ))
		self:PhysWake()
		self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
		local Phys=self:GetPhysicsObject()
		Phys:SetMass(1)
		Phys:EnableGravity(false)
		Phys:SetMaterial("gmod_silent")
	end
	function ENT:PhysicsCollide(data,physobj)
		self:GetPhysicsObject():ApplyForceCenter(-data.HitNormal*100)
	end
	function ENT:OnTakeDamage( dmginfo )
		self:TakePhysicsDamage( dmginfo )
	end
	function ENT:Use( activator, caller )
		--
	end
elseif(CLIENT)then
	local Mat=Material("particle/smokestack")
	function ENT:Initialize()
		self.Col=Color(math.random(100,120),math.random(100,150),100)
		self.Siz=1
		self.Visible=true
		self.Show=true
		timer.Simple(2,function()
			if(IsValid(self))then self.Visible=math.random(1,5)==2 end
		end)
		self.NextVisCheck=CurTime()+6
	end
	function ENT:DrawTranslucent()
		--self:DrawModel()
		local Time=CurTime()
		if(self.NextVisCheck<Time)then
			self.NextVisCheck=Time+1
			self.Show=self.Visible and 1/FrameTime()>50
		end
		if(self.Show)then
			local SelfPos=self:GetPos()
			render.SetMaterial(Mat)
			render.DrawSprite(SelfPos,self.Siz,self.Siz,Color(self.Col.r,self.Col.g,self.Col.b,30))
			self.Siz=math.Clamp(self.Siz+FrameTime()*200,0,500)
		end
	end
end