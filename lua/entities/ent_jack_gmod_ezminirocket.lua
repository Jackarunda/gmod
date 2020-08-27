-- Jackarunda 2019
AddCSLuaFile()
ENT.Type="anim"
ENT.Author="Jackarunda"
ENT.Category="JMod - EZ Explosives"
ENT.Information="glhfggwpezpznore"
ENT.PrintName="EZ Mini Rocket"
ENT.Spawnable=false
ENT.AdminSpawnable=false
---
ENT.JModPreferredCarryAngles=Angle(0,0,90)
ENT.JModNoGunHitWall=true
---
local STATE_BROKEN,STATE_OFF,STATE_ARMED,STATE_LAUNCHED=-1,0,1,2
function ENT:SetupDataTables()
	self:NetworkVar("Int",0,"State")
end
---
if(SERVER)then
	function ENT:SpawnFunction(ply,tr)
		local SpawnPos=tr.HitPos+tr.HitNormal*40
		local ent=ents.Create(self.ClassName)
		ent:SetAngles(Angle(180,0,0))
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
		self.Entity:SetModel("models/hunter/plates/plate075.mdl")
		self.Entity:PhysicsInit(SOLID_VPHYSICS)
		self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
		self.Entity:SetSolid(SOLID_VPHYSICS)
		self.Entity:DrawShadow(true)
		self.Entity:SetUseType(SIMPLE_USE)
		---
		timer.Simple(.01,function()
			if(IsValid(self))then
				self:GetPhysicsObject():SetMass(20)
				self:GetPhysicsObject():Wake()
				self:GetPhysicsObject():EnableDrag(false)
			end
		end)
		---
		self:SetState(STATE_OFF)
		self.NextDet=0
		self.FuelLeft=100
	end
	function ENT:PhysicsCollide(data,physobj)
		if not(IsValid(self))then return end
		if(data.DeltaTime>0.2)then
			if(data.Speed>150)then
				self:EmitSound("Canister.ImpactHard")
			elseif(data.Speed>50)then
				self:EmitSound("Canister.ImpactSoft")
			end
			local DetSpd=100
			if((data.Speed>DetSpd)and(self:GetState()==STATE_LAUNCHED))then
				self:Detonate()
				return
			end
			if(data.Speed>2000)then
				self:Break()
			end
		end
	end
	function ENT:Break()
		if(self:GetState()==STATE_BROKEN)then return end
		self:SetState(STATE_BROKEN)
		self:EmitSound("snd_jack_turretbreak.wav",70,math.random(80,120))
		for i=1,20 do
			self:DamageSpark()
		end
		SafeRemoveEntityDelayed(self,10)
	end
	function ENT:DamageSpark()
		local effectdata=EffectData()
		effectdata:SetOrigin(self:GetPos()+self:GetUp()*10+VectorRand()*math.random(0,10))
		effectdata:SetNormal(VectorRand())
		effectdata:SetMagnitude(math.Rand(2,4)) --amount and shoot hardness
		effectdata:SetScale(math.Rand(.5,1.5)) --length of strands
		effectdata:SetRadius(math.Rand(2,4)) --thickness of strands
		util.Effect("Sparks",effectdata,true,true)
		self:EmitSound("snd_jack_turretfizzle.wav",70,100)
	end
	function ENT:OnTakeDamage(dmginfo)
		self.Entity:TakePhysicsDamage(dmginfo)
		if(dmginfo:GetDamage()>=100)then
			if(math.random(1,20)==1)then
				self:Break()
			elseif(dmginfo:IsDamageType(DMG_BLAST))then
				JMod_Owner(self,dmginfo:GetAttacker())
				self:Detonate()
			end
		end
	end
	function ENT:Use(activator)
		-- no
	end
	function ENT:Detonate()
		if(self.NextDet>CurTime())then return end
		if(self.Exploded)then return end
		self.Exploded=true
		local SelfPos,Att,Dir=self:GetPos()+Vector(0,0,30),self.Owner or game.GetWorld(),-self:GetRight()
		JMod_Sploom(Att,SelfPos,150)
		---
		util.ScreenShake(SelfPos,1000,3,2,700)
		self:EmitSound("snd_jack_fragsplodeclose.wav",90,100)
		---
		util.BlastDamage(game.GetWorld(),Att,SelfPos+Vector(0,0,50),self.BlastRadius or 100,self.Dmg or 100)
		for k,ent in pairs(ents.FindInSphere(SelfPos,200))do
			if(ent:GetClass()=="npc_helicopter")then
				if(math.random(1,2)==1)then
					ent:Fire("selfdestruct","",math.Rand(0,2))
				end
			end
		end
		---
		JMod_WreckBuildings(self,SelfPos,.4)
		JMod_BlastDoors(self,SelfPos,2)
		---
		timer.Simple(.2,function()
			local Tr=util.QuickTrace(SelfPos-Dir*100,Dir*300)
			if(Tr.Hit)then util.Decal("Scorch",Tr.HitPos+Tr.HitNormal,Tr.HitPos-Tr.HitNormal) end
		end)
		---
		self:Remove()
		local Ang=self:GetAngles()
		Ang:RotateAroundAxis(Ang:Forward(),-90)
		timer.Simple(.1,function()
			ParticleEffect("50lb_air",SelfPos-Dir*20,Ang)
			ParticleEffect("50lb_air",SelfPos-Dir*50,Ang)
		end)
	end
	function ENT:OnRemove()
		--
	end
	function ENT:Launch()
		if(self:GetState()~=STATE_ARMED)then return end
		self:SetState(STATE_LAUNCHED)
		local Phys=self:GetPhysicsObject()
		---
		self:EmitSound("snds_jack_gmod/rocket_launch.wav",70,math.random(135,145))
		local Eff=EffectData()
		Eff:SetOrigin(self:GetPos())
		Eff:SetNormal(self:GetRight())
		Eff:SetScale(3)
		util.Effect("eff_jack_gmod_rocketthrust",Eff,true,true)
		---
		self.NextDet=0
		---
		timer.Simple(20,function()
			if(IsValid(self))then self:Detonate() end
		end)
	end
	function ENT:EZdetonateOverride(detonator)
		self:Detonate()
	end
	function ENT:Think()
		local Phys=self:GetPhysicsObject()
		JMod_AeroDrag(self,-self:GetRight(),.75)
		if(self:GetState()==STATE_LAUNCHED)then
			if(self.FuelLeft>0)then
				Phys:ApplyForceCenter(-self:GetRight()*20000)
				self.FuelLeft=self.FuelLeft-5
				-- counter gravity a little to account for how slow gmod rockets are
				--Phys:ApplyForceCenter(Vector(0,0,500))
				---
				local Eff=EffectData()
				Eff:SetOrigin(self:GetPos())
				Eff:SetNormal(self:GetRight())
				Eff:SetScale(.5)
				util.Effect("eff_jack_gmod_rocketthrust",Eff,true,true)
			end
		end
		self:NextThink(CurTime()+.05)
		return true
	end
elseif(CLIENT)then
	function ENT:Initialize()
		self.Mdl=ClientsideModel("models/military2/missile/missile_patriot.mdl")
		self.Mdl:SetMaterial("models/military2/missile/he")
		self.Mdl:SetPos(self:GetPos())
		self.Mdl:SetParent(self)
		self.Mdl:SetNoDraw(true)
	end
	function ENT:Think()
		--
	end
	local GlowSprite=Material("mat_jack_gmod_glowsprite")
	function ENT:Draw()
		local Pos,Ang,Dir=self:GetPos(),self:GetAngles(),self:GetRight()
		Ang:RotateAroundAxis(Ang:Up(),90)
		--self:DrawModel()
		self.Mdl:SetRenderOrigin(Pos+Ang:Up()*1.5-Ang:Right()*0-Ang:Forward()*1)
		self.Mdl:SetRenderAngles(Ang)
		local Matricks=Matrix()
		Matricks:Scale(Vector(.2,.4,.4))
		self.Mdl:EnableMatrix("RenderMultiply",Matricks)
		self.Mdl:DrawModel()
		if(self:GetState()==STATE_LAUNCHED)then
			self.BurnoutTime=self.BurnoutTime or CurTime()+1
			if(self.BurnoutTime>CurTime())then
				render.SetMaterial(GlowSprite)
				for i=1,10 do
					local Inv=10-i
					render.DrawSprite(Pos+Dir*(i*5+math.random(30,40)-15),3*Inv,3*Inv,Color(255,255-i*10,255-i*20,255))
				end
				local dlight=DynamicLight(self:EntIndex())
				if(dlight)then
					dlight.pos=Pos+Dir*35
					dlight.r=255
					dlight.g=175
					dlight.b=100
					dlight.brightness=1
					dlight.Decay=200
					dlight.Size=400
					dlight.DieTime=CurTime()+.5
				end
			end
		end
	end
	language.Add("ent_jack_gmod_ezherocket","EZ HE Rocket")
end