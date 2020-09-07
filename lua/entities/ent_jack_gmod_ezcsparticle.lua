-- Based off of JMOD EZ Gas Particle, created by Freaking Fission, uses some code from GChem
AddCSLuaFile()
ENT.Type="anim"
ENT.PrintName="EZ CS Gas"
ENT.Author="Jackarunda, Freaking Fission"
ENT.NoSitAllowed=true
ENT.Editable=true
ENT.Spawnable=false
ENT.AdminSpawnable=false
ENT.AdminOnly=false
ENT.RenderGroup=RENDERGROUP_TRANSLUCENT
ENT.EZgasParticle=true

function ENT:SetupDataTables()
	self:NetworkVar("Int",0,"Siz")
	self:NetworkVar("Int",1,"Opacity")
end

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
		self:SetSiz(1)
		self:SetOpacity(93.75)
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
				local distanceBetween = SelfPos:DistToSqr (obj:GetPos())
				if(not obj.EZgasParticle)then
					if((self:ShouldDamage(obj)) and self.NextDmg<Time)then
						
						FaceProtected = false
						respiratorMultiplier =1
						
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
									local SubtractAmt = math.Rand (0.264,1.056) * JMOD_CONFIG.ArmorDegredationMult / 100
									v.chrg.chemicals = math.Clamp(v.chrg.chemicals - SubtractAmt, 0, 9e9)
								end
								if v.name == "Respirator" and v.tgl == false and v.chrg.chemicals > 0 then 
									respiratorMultiplier = .5 
									local SubtractAmt = .5 * math.Rand (0.264,1.056) * JMOD_CONFIG.ArmorDegredationMult / 100
									v.chrg.chemicals = math.Clamp(v.chrg.chemicals - SubtractAmt, 0, 9e9)
								end
							end
						end
						
						if (FaceProtected == false) then
						
							if not obj.EZblindness then obj.EZblindness = 0 end
							obj.EZblindness = math.Clamp(obj.EZblindness + (10*respiratorMultiplier),0,100)
							
							JMod_TryCough(obj)
							
							if math.random(1,20) == 1 then
								local Dmg,Helf=DamageInfo(),obj:Health()
								Dmg:SetDamageType(DMG_NERVEGAS)
								Dmg:SetDamage(math.random(1,4)*JMOD_CONFIG.PoisonGasDamage)
								Dmg:SetInflictor(self)
								Dmg:SetAttacker(self.Owner or self)
								Dmg:SetDamagePosition(obj:GetPos())
								obj:TakeDamageInfo(Dmg)
							end
							
						end
						if obj:IsPlayer() then JMod_Hint(obj, "tear gas") end
					end
				elseif (obj.EZgasParticle and (distanceBetween < 250*250))then -- Push Gas
					local Vec=(obj:GetPos()-SelfPos):GetNormalized()
					Force=Force-Vec*32
				end
			end
		end
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
		Phys:EnableGravity(true)
		Phys:SetMaterial("gmod_silent")
	end
	function ENT:PhysicsCollide(data,physobj)
		self:GetPhysicsObject():ApplyForceCenter(-data.HitNormal*100)
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
	function ENT:PhysicsUpdate (Phys)
		if FrameTime() != 0 then
			local size = self:GetSiz()
			local opacity = self:GetOpacity()
			local SizeTarget = (750)
			local OpacityTarget = (93.75)
			
			if (size < SizeTarget) then
				size = size+FrameTime()*375
				if (size > SizeTarget) then
					size = SizeTarget
				end
			end
			if (size > SizeTarget) then
				size = size-FrameTime()*375
				if (size < SizeTarget) then
					size = SizeTarget
				end
			end
			if (opacity < OpacityTarget) then
				opacity = opacity+FrameTime()*46.875
				if (opacity > OpacityTarget) then
					opacity = OpacityTarget
				end
			end
			if (opacity > OpacityTarget) then
				opacity = opacity-FrameTime()*46.875
				if (opacity < OpacityTarget) then
					opacity = OpacityTarget
				end
			end
			self:SetSiz(size)
			self:SetOpacity(opacity)
			
			Phys:ApplyForceCenter (Vector (0,0, 8.8))
			Phys:SetVelocity ((Phys:GetVelocity() * .993))
			self:Extinguish()
		end
	end
elseif(CLIENT)then
	local Mat=Material("effects/smoke_b")
	function ENT:Initialize()
		self.Col=Color(255,255,255)
		self.Siz=1
		self.Visible=true
		self.Show=true
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
			local opacity = self:GetOpacity()
			local siz = self:GetSiz()
			local SelfPos=self:GetPos()
			render.SetMaterial(Mat)
			render.DrawSprite(SelfPos,siz,siz,Color(self.Col.r,self.Col.g,self.Col.b,opacity))
		end
	end
end