-- Jackarunda 2019
AddCSLuaFile()
ENT.Type="anim"
ENT.PrintName="EZ Nuclear Fallout"
ENT.Author="Jackarunda"
ENT.NoSitAllowed=true
ENT.Editable=true
ENT.Spawnable=false
ENT.AdminSpawnable=false
ENT.AdminOnly=false
ENT.RenderGroup=RENDERGROUP_TRANSLUCENT
ENT.EZfalloutParticle=true
if(SERVER)then
	function ENT:Initialize()
		local Time=CurTime()
		self.LifeTime=math.random(100,200)*JMOD_CONFIG.NuclearRadiationMult
		self.DieTime=Time+self.LifeTime
		self:SetModel("models/dav0r/hoverball.mdl")
		self:SetMaterial("models/debug/debugwhite")
		self:RebuildPhysics()
		self:DrawShadow(false)
		self.NextDmg=Time+math.random(1,10)
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
		local Force=VectorRand()*10-Vector(0,0,50)
		for key,obj in pairs(ents.FindInSphere(SelfPos,2500))do
			if(not(obj==self)and(self:CanSee(obj)))then
				if(obj.EZfalloutParticle)then
					local Vec=(obj:GetPos()-SelfPos):GetNormalized()
					Force=Force-Vec*7
				elseif((self:ShouldDamage(obj))and(math.random(1,5)==1)and(self.NextDmg<Time))then
					local DmgAmt=math.random(4,20)*JMOD_CONFIG.NuclearRadiationMult
					if(obj:WaterLevel()>=3)then DmgAmt=DmgAmt/3 end
					---
					local Dmg,Helf=DamageInfo(),obj:Health()
					Dmg:SetDamageType(DMG_RADIATION)
					Dmg:SetDamage(DmgAmt)
					Dmg:SetInflictor(self)
					Dmg:SetAttacker(self.Owner or self)
					Dmg:SetDamagePosition(obj:GetPos())
					if(obj:IsPlayer())then
						DmgAmt=DmgAmt/4
						Dmg:SetDamage(DmgAmt)
						obj:TakeDamageInfo(Dmg)
						---
						obj:EmitSound("player/geiger"..math.random(1,3)..".wav",55,math.random(90,110))
						timer.Simple(math.Rand(.1,1),function()
							if(IsValid(obj))then obj:EmitSound("player/geiger"..math.random(1,3)..".wav",55,math.random(90,110)) end
						end)
						---
						local DmgTaken=Helf-obj:Health()
						if((DmgTaken>0)and(JMOD_CONFIG.NuclearRadiationSickness))then
							obj.EZirradiated=(obj.EZirradiated or 0)+DmgTaken*3
                            JMod_Hint(obj, "rad damage")
						end
					else
						obj:TakeDamageInfo(Dmg)
					end
				end
			end
		end
		local Phys=self:GetPhysicsObject()
		Phys:SetVelocity(Phys:GetVelocity()*.7)
		Phys:ApplyForceCenter(Force)
		self:NextThink(Time+math.Rand(4,8))
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
	function ENT:Initialize()
		self.DebugShow=LocalPlayer().EZshowGasParticles or false
		if(self.DebugShow)then self:SetModelScale(10) end
	end
	function ENT:DrawTranslucent()
		if(self.DebugShow)then self:DrawModel() end
	end
end