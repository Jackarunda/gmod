-- Jackarunda 2019
AddCSLuaFile()
ENT.Type="anim"
ENT.Author="Jackarunda"
ENT.Category="JMod - EZ Explosives"
ENT.Information="glhfggwpezpznore"
ENT.PrintName="EZ Bomblet"
ENT.Spawnable=false
ENT.AdminSpawnable=false
ENT.NoEZbombletDet=true
---
if(SERVER)then
	function ENT:Initialize()
		self.Entity:SetModel("models/Items/AR2_Grenade.mdl")
		self.Entity:SetColor(Color(50,50,50))
		self.Entity:PhysicsInit(SOLID_VPHYSICS)
		self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
		self.Entity:SetSolid(SOLID_VPHYSICS)
		self.Entity:DrawShadow(true)
		self.IgnoreBlastTime=CurTime()+2
	end
	function ENT:PhysicsCollide(data,physobj)
		if not(IsValid(self))then return end
		if(data.HitEntity.NoEZbombletDet)then return end
		if(data.DeltaTime>0.2)then
			if(data.Speed>50)then
				self:Detonate()
			end
		end
	end
	function ENT:OnTakeDamage(dmginfo)
		if(self.IgnoreBlastTime<CurTime())then
			self.Entity:TakePhysicsDamage(dmginfo)
		end
		if(dmginfo:GetDamage()>=80)then
			JMod_Owner(self,dmginfo:GetAttacker())
			self:Detonate()
		end
	end
	function ENT:Detonate()
		if(self.Exploded)then return end
		self.Exploded=true
		local SelfPos,Att=self:GetPos()+Vector(0,0,30),self.Owner or game.GetWorld()
		---
		local splad=EffectData()
		splad:SetOrigin(SelfPos)
		splad:SetScale(1)
		util.Effect("eff_jack_bombletdetonate",splad,true,true)
		---
		util.BlastDamage(game.GetWorld(),Att,SelfPos+Vector(0,0,20),150,90)
		---
		util.ScreenShake(SelfPos,1000,3,1,500)
		---
		self:EmitSound("BaseExplosionEffect.Sound")
		---
		local Tr=util.QuickTrace(SelfPos,Vector(0,0,-100),self)
		if(Tr.Hit)then util.Decal("Scorch",Tr.HitPos+Tr.HitNormal,Tr.HitPos-Tr.HitNormal) end
		self:Remove()
	end
elseif(CLIENT)then
	function ENT:Draw()
		self:DrawModel()
	end
	language.Add("ent_jack_gmod_ezbomblet","EZ Bomblet")
end