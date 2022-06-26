-- Jackarunda 2021
AddCSLuaFile()
ENT.Type = "anim"
ENT.Author = "Jackarunda"
ENT.Category = "JMod - EZ Explosives"
ENT.Information = "The deployment submunition for the EZ Cluster Buster"
ENT.PrintName = "Cluster Buster submunition deployer"
ENT.Spawnable = true
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
	function ENT:SpawnFunction(ply,tr)
		local SpawnPos = tr.HitPos + tr.HitNormal*15
		local ent = ents.Create(self.ClassName)
		ent:SetAngles(Angle(0, 0, 0))
		ent:SetPos(SpawnPos)
		JMod.Owner(ent, ply)
		ent:Spawn()
		ent:Activate()
		return ent
	end
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
		--self:GetPhysicsObject():EnableGravity(false) -- DEBUG
		self:SetState(STATE_OFF)
		timer.Simple(math.Rand(.5,2),function()
			if(IsValid(self))then
				self:StartParachuting()
			end
		end)
	end
	function ENT:StartParachuting()
		self:SetState(STATE_PARACHUTING)
		self:GetPhysicsObject():SetDragCoefficient(40)
		self:GetPhysicsObject():SetAngleDragCoefficient(10)
		--[[timer.Simple(0.5, function () 
			if (self:IsValid()) then
				local Phys = self:GetPhysicsObject()
				Phys:SetAngles(Angle(0, 0, 90)) 
				Phys:SetVelocity(Vector(0, 0, 0))
				--print("I'm turned the right way")
			end
		end)]]--
	end
	function ENT:StartRocketing()
		self:SetState(STATE_ROCKETING)
		local Phys = self:GetPhysicsObject()
		Phys:SetDragCoefficient(1)
		Phys:SetAngleDragCoefficient(0)
		self:SetAngles(Angle(0, 0, 90)) 
		Phys:SetVelocity(Vector(0, 0, 0))
		Phys:AddAngleVelocity(Vector(0, 2500, 0))
		timer.Simple(0.5, function()
			if(self:IsValid()) then
				self:Detonate()
			end
		end)
	end
	function ENT:PhysicsCollide(data,physobj)
		if not(IsValid(self))then return end
		if(data.HitEntity.EZclusterBusterMunition)then return end
		if(data.DeltaTime>0.2) then
			--self:Detonate()
		end
	end
	function ENT:OnTakeDamage(dmginfo)
		if(self.Exploded)then return end
		if(dmginfo:GetInflictor() == self or dmginfo:GetInflictor().EZclusterBusterMunition == true)then return end
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
		self.Exploded = true
		local Att = self.Owner or game.GetWorld()
		local Vel,Pos,Ang = self:GetPhysicsObject():GetVelocity(),self:LocalToWorld(self:OBBCenter()),self:GetAngles()
		local Up,Right,Forward,SkeetAng = Ang:Up(),Ang:Right(),Ang:Forward(),Ang:GetCopy()
		for i = 1, 4 do
			local Pos = self:LocalToWorld(self:OBBCenter())
			local Skeet = ents.Create("ent_jack_gmod_ezclusterbuster_skeet")
			JMod.Owner(Skeet, Att)
			--Skeet:SetPos(Pos + Vector(math.random(-500, 500), math.random(-500, 500), 0)) -- To cheap
			Skeet:SetPos(Pos + Vector(50, 0, 0))
			print("Here is the rotated vector", Vector(50, 0, 0))
			Skeet:SetAngles(SkeetAng*i*90)
			Skeet:Spawn()
			Skeet:Activate()
			Skeet:GetPhysicsObject():SetVelocity(Vel + Skeet:GetForward()*5000)

			--[[timer.Simple(i*0.25, function() -- Older more, complicated, approach (Or less complicated, IDK)
				if (self:IsValid()) then
					local Pos = self:LocalToWorld(self:OBBCenter())
					local Skeet = ents.Create("ent_jack_gmod_ezclusterbuster_skeet")
					JMod.Owner(Skeet, Att)
					Skeet:SetPos(Pos + self:GetRight()*50)
					Skeet:SetAngles(SkeetAng*i*90)
					Skeet:Spawn()
					Skeet:Activate()
					Skeet:GetPhysicsObject():SetVelocity(Vel + Skeet:GetForward()*5000)
					--Skeet:SetVelocity(Vel + self:LocalToWorld(Skeet:GetPos())*5000)
					--[[timer.Simple(0.5, function() --DEBUG
						if (Skeet:IsValid()) then 
							Skeet:GetPhysicsObject():EnableMotion(false)
						end
					end)]]--
				--end
			--end)]]--
		end
		timer.Simple(1, function()
			if (self:IsValid()) then
				local Pos = self:LocalToWorld(self:OBBCenter())
				self:Remove()
				JMod.Sploom(Att, Pos, 10)
			end
		end)
	end
	local VelCurve = 1
	function ENT:Think()
		local Time = CurTime()
		local State = self:GetDTInt(0)
		local Phys = self:GetPhysicsObject()
		local Vel,Pos,Ang = Phys:GetVelocity(),self:LocalToWorld(self:OBBCenter()),self:GetAngles()
		local Up,Forward,Right = self:GetUp(), self:GetForward(), self:GetRight()
		local Att=self.Owner or game.GetWorld()
		if (State == STATE_PARACHUTING) then
			-- these 4 lines are SUPPOSED to make the thing point straight up and down, not sure why it doesn't work
			--[[local Up = Angle(0, 100, 0)
			local Top = self:LocalToWorld(Vector(0, 100, 0))
			Phys:ApplyForceOffset(Vector(0, 0, 1000), Top)
			local Bottom = self:LocalToWorld(Vector(0, -100, 0))
			Phys:ApplyForceOffset(Vector(0, 0, -1000), Bottom)--]]
			local Tr = util.QuickTrace(self:GetPos(), Phys:GetVelocity():GetNormalized()*600, self)
			if (Tr.Hit) then
				self:StartRocketing()
			end
		end
		if (State == STATE_ROCKETING) then
			Phys:ApplyForceCenter(Vector(0, 0, 4500*VelCurve))
			VelCurve = VelCurve - 0.005
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
