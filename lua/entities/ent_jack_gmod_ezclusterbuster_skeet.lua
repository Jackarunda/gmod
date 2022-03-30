-- Jackarunda 2021
AddCSLuaFile()
ENT.Type = "anim"
ENT.Author = "Jackarunda"
ENT.Category = "JMod - EZ Explosives"
ENT.Information = "The smart skeet submunition for the EZ Cluster Buster"
ENT.PrintName = "Cluster Buster submunition"
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
			self:GetPhysicsObject():SetMass(15)
			self:GetPhysicsObject():Wake()
		end)
		---
		self.Owner=self.Owner or game.GetWorld()
		---
		self.Active=false
		timer.Simple(math.Rand(.5,1.5),function()
			if(IsValid(self))then self.Active=true end
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
			self:Detonate()
		end
	end
	function ENT:Detonate(delay, dmg)
		if(self.Exploded)then return end
		self.Exploded=true
		local Att=self.Owner or game.GetWorld()
		local Vel,Pos,Ang=self:GetPhysicsObject():GetVelocity(),self:LocalToWorld(self:OBBCenter()),self:GetAngles()
		JMod.Sploom(Att,Pos,50)
		--JMod.RicPenBullet(self, SelfPos, Dir,(dmg or 600)*JMod.Config.MinePower, true, true)
		self:Remove()
	end
	function ENT:Think()
		local Time=CurTime()
		if(self.Active)then

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