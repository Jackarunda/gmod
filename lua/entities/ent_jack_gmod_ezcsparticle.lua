-- Based off of JMOD EZ Gas Particle, created by Freaking Fission, uses some code from GChem
AddCSLuaFile()
ENT.Type="anim"
ENT.PrintName="EZ CS Gas"
ENT.Author="Jackarunda, Freaking Fission"
ENT.NoSitAllowed=true
ENT.Editable=false
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
		self.NextDmg=Time+2.5
		self:NextThink(Time+.5)
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
		local Force=VectorRand()*10-Vector(0,0,100)
		for key,obj in pairs(ents.FindInSphere(SelfPos,200))do
			if(not(obj==self)and(self:CanSee(obj)))then
				local distanceBetween = SelfPos:DistToSqr(obj:GetPos())
				local IsPlaya=obj:IsPlayer()
				if(not obj.EZgasParticle)then
					if((self.NextDmg<Time)and(self:ShouldDamage(obj)))then
						
						local FaceProtected = false
						local RespiratorMultiplier = 1
						
						if (obj.JackyArmor) then
							if (obj.JackyArmor.Suit) then
								if (obj.JackyArmor.Suit.Type == "Hazardous Material") then
									FaceProtected = true
								end
							end
						end
						
						if (obj.EZarmor) then
							for _, v in pairs(obj.EZarmor.items) do
								if v.name == "GasMask" and v.tgl == false and v.chrg.chemicals > 0 then
									FaceProtected = true 
									local SubtractAmt = math.Rand (.2,1) * JMOD_CONFIG.ArmorDegredationMult / 100
									v.chrg.chemicals = math.Clamp(v.chrg.chemicals - SubtractAmt, 0, 9e9)
								end
								if v.name == "Respirator" and v.tgl == false and v.chrg.chemicals > 0 then 
									RespiratorMultiplier = .5 
									local SubtractAmt = math.Rand (.2,1) * JMOD_CONFIG.ArmorDegredationMult / 200
									v.chrg.chemicals = math.Clamp(v.chrg.chemicals - SubtractAmt, 0, 9e9)
								end
							end
						end
						
						if not(FaceProtected)then
							if(IsPlaya)then
								net.Start("JMod_VisionBlur")
								net.WriteFloat(5*RespiratorMultiplier)
								net.Send(obj)
							elseif(obj:IsNPC())then
								obj.EZNPCincapacitate=Time+math.Rand(2,5)
							end
							
							if RespiratorMultiplier >= 1 then
								JMod_TryCough(obj)
							end

							if math.random(1,20) == 1 then
								local Dmg,Helf=DamageInfo(),obj:Health()
								Dmg:SetDamageType(DMG_NERVEGAS)
								Dmg:SetDamage(math.random(1,4)*JMOD_CONFIG.PoisonGasDamage*RespiratorMultiplier)
								Dmg:SetInflictor(self)
								Dmg:SetAttacker(self.Owner or self)
								Dmg:SetDamagePosition(obj:GetPos())
								obj:TakeDamageInfo(Dmg)
							end

						end
						if IsPlaya then JMod_Hint(obj, "tear gas") end
					end
				elseif (obj.EZgasParticle and (distanceBetween < 250*250))then -- Push Gas
					local Vec=(obj:GetPos()-SelfPos):GetNormalized()
					Force=Force-Vec*10
				end
			end
		end
		self:Extinguish()
		local Phys=self:GetPhysicsObject()
		Phys:SetVelocity(Phys:GetVelocity()*.8)
		Phys:ApplyForceCenter(Force)
		self:NextThink(Time+math.Rand(2,2.8))
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
		self:GetPhysicsObject():ApplyForceCenter(-data.HitNormal*50)
	end
	function ENT:OnTakeDamage( dmginfo )
		--self:TakePhysicsDamage( dmginfo )
	end
	function ENT:Use( activator, caller )
		--
	end
	function ENT:GravGunPickupAllowed (ply)
		return false
	end
elseif(CLIENT)then
	local Mat=Material("effects/smoke_b")
	function ENT:Initialize()
		self.Col=Color(255,255,255)
		self.Visible=true
		self.Show=math.random(1,3)==2
		timer.Simple(2,function()
			if(IsValid(self))then self.Visible=math.random(1,5)==2 end
		end)
		self.NextVisCheck=CurTime()+6
		self.DebugShow=LocalPlayer().EZshowGasParticles
		if(self.DebugShow)then self:SetModelScale(2) end
	end
	function ENT:DrawTranslucent()
		if(self.DebugShow)then
			self:DrawModel()
		end
		local Time=CurTime()
		if(self.Show)then
			local siz = 300
			local SelfPos=self:GetPos()
			render.SetMaterial(Mat)
			render.DrawSprite(SelfPos,siz,siz,Color(self.Col.r,self.Col.g,self.Col.b,10))
		end
	end
end