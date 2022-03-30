-- Jackarunda 2021
AddCSLuaFile()
ENT.Type = "anim"
ENT.Author = "Jackarunda"
ENT.Category = "JMod - EZ Explosives"
ENT.Information = "The deployment submunition for the EZ Cluster Buster"
ENT.PrintName = "Cluster Buster submunition deployer"
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.EZclusterBusterMunition=true
---
if(SERVER)then
	function ENT:SpawnFunction(ply,tr)
		local SpawnPos = tr.HitPos+tr.HitNormal*15
		local ent = ents.Create(self.ClassName)
		ent:SetAngles(Angle(0, 0, 0))
		ent:SetPos(SpawnPos)
		JMod.Owner(ent, ply)
		ent:Spawn()
		ent:Activate()
		return ent
	end
	--[[
	concommand.Add("SHIT",function(ply,cmd,args)
		local Drop=function(targetPos,flyVector,caller)
			local BombVel=flyVector*1000
			for i=-4,4 do
				timer.Simple(i/2+5,function()
				local DropPos=targetPos+flyVector*i*400-flyVector*3000
				local Bom=ents.Create("ent_jack_gmod_ezsmallbomb")
				JMod.Owner(Bom,caller)
				Bom:SetPos(DropPos)
				Bom:Spawn()
				Bom:Activate()
				Bom:SetState(1)
				Bom:GetPhysicsObject():SetVelocity(BombVel)
				end)
			end
		end
		---- haaaaaaaaaaaaaaaaaaaaaaaaa -----
		local FlyVec=VectorRand()
		FlyVec.z=0
		FlyVec:Normalize()
		Drop(ply:GetPos()+Vector(0,0,3000),FlyVec,ply)
	end)
	--]]
	function ENT:Initialize()
		self:SetModel("models/xqm/cylinderx2.mdl")
		self:SetMaterial("phoenix_storms/Future_vents")
		--self:SetModelScale(1.25,0)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:DrawShadow(true)
		---
		timer.Simple(.01,function()
			self:GetPhysicsObject():SetMass(15)
			self:GetPhysicsObject():Wake()
		end)
		---
		self.Owner=self.Owner or game.GetWorld()
		---
		self:SetDTInt(0,0) -- 0 = dormant, 1 = parachuting, 2 = rocketing
		timer.Simple(1,function()
			if(IsValid(self))then
				self:SetDTInt(0,1)
				self:GetPhysicsObject():SetDragCoefficient(40)
			end
		end)
	end
	function ENT:PhysicsCollide(data,physobj)
		if(data.HitEntity.EZclusterBusterMunition)then return end
		if(data.DeltaTime>0.2 and data.Speed>25)then
			self:Detonate()
		end
	end
	function ENT:OnTakeDamage(dmginfo)
		if(self.Exploded)then return end
		if(dmginfo:GetInflictor() == self)then return end
		self:TakePhysicsDamage(dmginfo)
		local Dmg = dmginfo:GetDamage()
		if(JMod.LinCh(Dmg, 20, 100))then
			local Pos, State = self:GetPos(), self:GetState()
			if(State == JMod.EZ_STATE_ARMED)then
				self:Detonate()
			elseif(not(State == JMod.EZ_STATE_BROKEN))then
				sound.Play("Metal_Box.Break", Pos)
				self:SetState(JMod.EZ_STATE_BROKEN)
				SafeRemoveEntityDelayed(self, 10)
			end
		end
	end
	function ENT:Detonate(delay, dmg)
		if(self.Exploded)then return end
		self.Exploded=true
		local Att=self.Owner or game.GetWorld()
		local Vel,Pos,Ang=self:GetPhysicsObject():GetVelocity(),self:LocalToWorld(self:OBBCenter()),self:GetAngles()
		local Up,Right,Forward,SkeetAng=Ang:Up(),Ang:Right(),Ang:Forward(),Ang:GetCopy()
		self:Remove()
		JMod.Sploom(Att,Pos,50)
		for i=1,4 do
			local Skeet=ents.Create("ent_jack_gmod_ezclusterbuster_skeet")
			JMod.Owner(Skeet,Att)
			Skeet:SetPos(Pos+VectorRand()*math.random(1,20))
			Skeet:SetVelocity(Vel+Vector(math.random(-1000,1000),math.random(-1000,1000),0))
			Skeet:Spawn()
			Skeet:Activate()
		end
	end
	function ENT:Think()
		local Time=CurTime()
		local State=self:GetDTInt(0)
		--
	end
elseif(CLIENT)then
	function ENT:Initialize()
		---
	end
	function ENT:Draw()
		self:DrawModel()
		local State,Pos,Up,Right,Forward=self:GetDTInt(0),self:GetPos(),self:GetUp(),self:GetRight(),self:GetForward()
		if(State==1)then
			if(self.Parachute)then
				local Vel=self:GetVelocity()
				if Vel:Length()>0 then
					local Dir=Vel:GetNormalized()
					Dir=Dir+Vector(.01,0,0) -- stop the turn spasming
					local Ang=Dir:Angle()
					Ang:RotateAroundAxis(Ang:Right(),90)
					self.Parachute:SetRenderOrigin(Pos+Dir*50)
					self.Parachute:SetRenderAngles(Ang)
					self.Parachute:DrawModel()
				end
			else
				self.Parachute=ClientsideModel("models/jessev92/rnl/items/parachute_deployed.mdl")
				self.Parachute:SetModelScale(.25,0)
				self.Parachute:SetNoDraw(true)
				self.Parachute:SetParent(self)
			end
		end
	end
	language.Add("ent_jack_gmod_ezclusterbuster_sub","EZ Cluster Buster Submunition")
end
