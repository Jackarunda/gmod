-- Jackarunda 2021
AddCSLuaFile()
ENT.Type = "anim"
ENT.Author = "Jackarunda"
ENT.Category = "JMod - EZ Explosives"
ENT.Information = "The deployment submunition for the EZ Cluster Buster"
ENT.PrintName = "Cluster Buster submunition deployer"
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.EZclusterBusterMunition = true
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
		self.Owner=self.Owner or game.GetWorld()
		---
		self:GetPhysicsObject():EnableGravity(false) -- DEBUG
		self:SetState(STATE_OFF)
		timer.Simple(math.Rand(.5,1),function()
			if(IsValid(self))then
				self:StartParachuting()
				timer.Simple(math.Rand(1,2),function()
					if(IsValid(self))then
						self:StartRocketing()
						timer.Simple(math.Rand(.5,1),function()
							if(IsValid(self))then self:Detonate() end
						end)
					end
				end)
			end
		end)
	end
	function ENT:StartParachuting()
		self:SetState(STATE_PARACHUTING)
		self:GetPhysicsObject():SetDragCoefficient(40)
		self:GetPhysicsObject():SetAngleDragCoefficient(10)
	end
	function ENT:StartRocketing()
		self:SetState(STATE_ROCKETING)
		self:GetPhysicsObject():SetDragCoefficient(1)
		self:GetPhysicsObject():SetAngleDragCoefficient(1)
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
		if(dmginfo:GetInflictor() == self)then return end
		self:TakePhysicsDamage(dmginfo)
		local Dmg = dmginfo:GetDamage()
		if(JMod.LinCh(Dmg, 20, 100))then
			local Pos, State = self:GetPos(), self:GetState()
			if(State == JMod.EZ_STATE_ARMED)then
				--self:Detonate()
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
		local Phys=self:GetPhysicsObject()
		if(State==STATE_PARACHUTING)then
			-- these 4 lines are SUPPOSED to make the thing point straight up and down, not sure why it doesn't work
			local Top=self:LocalToWorld(Vector(0,100,0))
			Phys:ApplyForceOffset(Vector(0,0,1000),Top)
			local Bottom=self:LocalToWorld(Vector(0,-100,0))
			Phys:ApplyForceOffset(Vector(0,0,-1000),Bottom)
		end
		self:NextThink(CurTime() + .1)
		return true
	end
elseif(CLIENT)then
	function ENT:Initialize()
		---
	end
	function ENT:Draw()
		self:DrawModel()
		local State,Pos,Up,Right,Forward=self:GetDTInt(0),self:GetPos(),self:GetUp(),self:GetRight(),self:GetForward()
		if (State==STATE_PARACHUTING)then
			if(self.Parachute)then
				local Vel = self:GetVelocity()
				if(Vel:Length()>0)then
					local Dir=Vel:GetNormalized()
					Dir=Dir+Vector(.01, 0, 0) -- stop the turn spasming
					local Ang=Dir:Angle()
					Ang:RotateAroundAxis(Ang:Right(), 90)
					self.Parachute:SetRenderOrigin(Pos + Up*6 + -Forward*6 + Right*5 + Dir*50*self.Parachute:GetModelScale())
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
