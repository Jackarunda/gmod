-- Jackarunda 2021
AddCSLuaFile()
ENT.Type="anim"
ENT.Author="AdventureBoots, Jackarunda"
ENT.Category="JMod - EZ Explosives"
ENT.Information="The deployment submunition for the EZ Cluster Buster"
ENT.PrintName="BLU-108"
ENT.Spawnable=false
ENT.AdminSpawnable=false
ENT.EZclusterBusterMunition=true
---
ENT.JModPreferredCarryAngles=Angle(0,0,0)
---
local STATE_OFF,STATE_PARACHUTING,STATE_ROCKETING=-1,0,1
function ENT:SetupDataTables()
	self:NetworkVar("Int",0,"State")
end
---
if(SERVER)then
	function ENT:Initialize()
		--self:SetModel("models/xqm/cylinderx2.mdl")
		self:SetModel("models/hunter/blocks/cube025x075x025.mdl")
		self:SetMaterial("phoenix_storms/Future_vents")
		--self:SetModelScale(1.25,0)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:DrawShadow(true)
		---
		timer.Simple(.01,function()
			self:GetPhysicsObject():SetMass(25)
			self:GetPhysicsObject():Wake()
		end)
		---
		self:SetState(STATE_OFF)
		timer.Simple(1,function()
			if(IsValid(self))then self:StartParachuting() end
		end)
	end
	function ENT:StartParachuting()
		self:SetState(STATE_PARACHUTING)
		self:GetPhysicsObject():SetDragCoefficient(50)
		self:GetPhysicsObject():SetAngleDragCoefficient(200)
	end
	function ENT:StartRocketing()
		local Pos=self:GetPos()
		self:SetState(STATE_ROCKETING)
		local Phys=self:GetPhysicsObject()
		Phys:SetDragCoefficient(1)
		Phys:SetAngleDragCoefficient(1)
		self:SetAngles(Angle(0,0,90))
		Phys:AddAngleVelocity(Vector(0,2500,0))
		local Pitch=math.random(95,105)
		self:EmitSound("snds_jack_gmod/rocket_launch.wav",90,Pitch)
		sound.Play("snds_jack_gmod/rocket_launch.wav",Pos,90,Pitch)
		local Eff=EffectData()
		Eff:SetOrigin(Pos)
		Eff:SetNormal(self:GetRight())
		Eff:SetScale(2)
		util.Effect("eff_jack_gmod_rocketthrust",Eff,true,true)
		timer.Simple(1,function()
			if(IsValid(self))then self:Detonate() end
		end)
	end
	function ENT:PhysicsCollide(data,physobj)
		if not(IsValid(self))then return end
		if(data.HitEntity.EZclusterBusterMunition)then return end
		if(data.DeltaTime>0.2) then
			self:Detonate()
		end
	end
	function ENT:OnTakeDamage(dmginfo)
		if(self.Exploded)then return end
		if(dmginfo:GetInflictor()==self or dmginfo:GetInflictor().EZclusterBusterMunition==true)then return end
		self:TakePhysicsDamage(dmginfo)
		local Dmg=dmginfo:GetDamage()
		if(JMod.LinCh(Dmg, 20, 100))then
			local Pos, State=self:GetPos(), self:GetState()
			if(State==JMod.EZ_STATE_ARMED)then
				--self:Detonate()
			elseif(not(State==JMod.EZ_STATE_BROKEN))then
				sound.Play("Metal_Box.Break", Pos)
				self:SetState(JMod.EZ_STATE_BROKEN)
				SafeRemoveEntityDelayed(self, 10)
			end
		end
	end
	function ENT:Detonate(delay,dmg)
		if(self.Exploded)then return end
		self.Exploded=true
		local Att=self.Owner or game.GetWorld()
		local Vel,Pos,Ang=self:GetVelocity(),self:LocalToWorld(self:OBBCenter()),self:GetAngles()
		local Up,Right,Forward=Ang:Up(),Ang:Right(),Ang:Forward()
		self:Remove()
		JMod.Sploom(Att,Pos,10)
		for i=1,4 do
			local Pos=self:LocalToWorld(self:OBBCenter())
			local Skeet=ents.Create("ent_jack_gmod_ezclusterbuster_skeet")
			JMod.Owner(Skeet,Att)
			Skeet:SetPos(Pos+VectorRand()*10)
			Skeet:SetAngles(Angle(0,0,0))
			Skeet:Spawn()
			Skeet:Activate()
			Skeet:GetPhysicsObject():SetVelocity(Vel+Vector(math.random(-500,500),math.random(-500,500),0))
		end
	end
	function ENT:Think()
		local Time,State,Phys,Att=CurTime(),self:GetState(),self:GetPhysicsObject(),self.Owner or game.GetWorld()
		local Vel,Pos,Ang=Phys:GetVelocity(),self:GetPos(),self:GetAngles()
		local Up,Forward,Right=self:GetUp(),self:GetForward(),self:GetRight()
		if(State==STATE_PARACHUTING)then
			-- use phys torque to point us upward
			Phys:ApplyForceOffset(Vector(0,0,50),Pos+Right*100)
			Phys:ApplyForceOffset(Vector(0,0,-50),Pos-Right*100)
			-- check to see if we're close enough to the ground
			local Tr=util.QuickTrace(Pos,Vector(0,0,-500),self)
			if(Tr.Hit)then self:StartRocketing() end
		elseif(State==STATE_ROCKETING)then
			local Eff=EffectData()
			Eff:SetOrigin(Pos)
			Eff:SetNormal(Right)
			Eff:SetScale(1)
			util.Effect("eff_jack_gmod_rocketthrust",Eff,true,true)
			Phys:ApplyForceCenter(Vector(0,0,4500))
		end
		self:NextThink(CurTime()+.1)
		return true
	end
elseif(CLIENT)then
	function ENT:Initialize()
		---
	end
	function ENT:Draw()
		self:DrawModel()
		local State,Pos,Up,Right,Forward=self:GetState(),self:GetPos(),self:GetUp(),self:GetRight(),self:GetForward()
		if (State==STATE_PARACHUTING)then
			if(self.Parachute)then
				local Vel=self:GetVelocity()
				if Vel:Length()>0 then
					local Dir=Vel:GetNormalized()
					Dir=Dir+Vector(.01,0,0) -- stop the turn spasming
					local Ang=Dir:Angle()
					Ang:RotateAroundAxis(Ang:Right(),90)
					self.Parachute:SetRenderOrigin(Pos+Right*15-Forward*1)
					self.Parachute:SetRenderAngles(Ang)
					self.Parachute:DrawModel()
				end
			else
				self.Parachute=ClientsideModel("models/jessev92/rnl/items/parachute_deployed.mdl")
				self.Parachute:SetModelScale(0.3, 0)
				self.Parachute:SetNoDraw(true)
				self.Parachute:SetParent(self)
			end
		elseif(State==STATE_ROCKETING)then
			if(self.Parachute)then self.Parachute:Remove();self.Parachute=nil end
			-- todo: draw rocket thrust
		end
	end
	language.Add("ent_jack_gmod_ezclusterbuster_sub","EZ Cluster Buster Submunition")
end
