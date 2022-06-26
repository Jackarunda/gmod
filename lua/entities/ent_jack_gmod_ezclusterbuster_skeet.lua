-- Jackarunda 2021
AddCSLuaFile()
ENT.Type = "anim"
ENT.Author = "Jackarunda"
ENT.Category = "JMod - EZ Explosives"
ENT.Information = "The smart skeet submunition for the EZ Cluster Buster"
ENT.PrintName = "Cluster Buster submunition"
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.EZclusterBusterMunition = true
---
local STATE_BROKEN, STATE_OFF, STATE_SEEKING = -1, 0, 1
function ENT:SetupDataTables()
	self:NetworkVar("Int",0,"State")
end
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
	function ENT:Initialize()
		self:SetModel("models/xqm/cylinderx1.mdl")
		self:SetMaterial("phoenix_storms/Future_vents")
		--self:SetModelScale(1.25,0)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:DrawShadow(true)
		---
		timer.Simple(.01,function()
			self:GetPhysicsObject():SetMass(50)
			self:GetPhysicsObject():Wake()
		end)
		---
		self.Owner = self.Owner or game.GetWorld()
		---
		self:SetState(STATE_OFF)
		timer.Simple(0.25, function()
			if(IsValid(self))then self:StartSeeking() end
		end)
	end
	function ENT:StartSeeking()
		self:SetState(STATE_SEEKING)
		--self:SetVelocity(self:GetForward()*1000)
		Phys = self:GetPhysicsObject()
		Forward = self:GetForward()
		Phys:ApplyForceCenter(Forward*2000)
		timer.Simple(4, function ()
			if(self:IsValid()) then
				--local WarcrimeChance = math.Round(math.Rand(0, 1))
				--if(WarcrimeChance == 1) then
				--	self:Break()
				--else
					self:Detonate()
				--end
			end
		end)
	end
	function ENT:Break()
		self:SetState(STATE_BROKEN)
		SafeRemoveEntityDelayed(self, 10)
	end
	function ENT:PhysicsCollide(data,physobj)
		if not(IsValid(self))then return end
		if(data.HitEntity.EZclusterBusterMunition)then return end
		if(data.DeltaTime>0.2 and data.Speed>25)then
			self:Detonate()
			--self:Break()
		end
	end
	function ENT:OnTakeDamage(dmginfo)
		if(self.Exploded)then return end
		if(dmginfo:GetInflictor() == self)then return end
		self:TakePhysicsDamage(dmginfo)
		local Dmg = dmginfo:GetDamage()
		if(JMod.LinCh(Dmg, 20, 100))then
			--self:Detonate()
		end
	end
	function ENT:Detonate(delay, dmg)
		if(self.Exploded)then return end
		self.Exploded = true
		local Att = self.Owner or game.GetWorld()
		local Vel,Pos,Ang=self:GetPhysicsObject():GetVelocity(),self:LocalToWorld(self:OBBCenter()),self:GetAngles()
		JMod.Sploom(Att,Pos,50)
		--JMod.RicPenBullet(self, SelfPos, Dir,(dmg or 600)*JMod.Config.MinePower, true, true)
		self:Remove()
	end

	local VelCurve = 1
	function ENT:Think()
		local Time = CurTime()
		local Phys = self:GetPhysicsObject()
		local Up,Forward,Right = self:GetUp(), self:GetForward(), self:GetRight()
		if(self:GetState() == STATE_SEEKING)then
			--Phys:ApplyForceCenter(Vector(0, 0, 1200*VelCurve))
			--Phys:ApplyForceCenter(Forward*2000)
			VelCurve = VelCurve - 0.0005
			
		end
		self:NextThink(Time+.1)
		return true
	end
elseif(CLIENT)then
	function ENT:Initialize()
		---
	end
	function ENT:Draw()
		self:DrawModel()
	end
	language.Add("ent_jack_gmod_ezclusterbuster_skeet","EZ Smart EFP Submunition")
end