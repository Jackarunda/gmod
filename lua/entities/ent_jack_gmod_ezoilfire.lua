-- Jackarunda 2021
AddCSLuaFile()
ENT.Type="anim"
ENT.Author="Jackarunda"
ENT.Category="JMod - EZ Explosives"
ENT.Information="glhfggwpezpznore"
ENT.PrintName="EZ Oil Fire"
ENT.NoSitAllowed=true
ENT.Spawnable=true
ENT.AdminSpawnable=true
---
ENT.EZscannerDanger=true
ENT.Ignited=false
if(SERVER)then
	function ENT:SpawnFunction(ply,tr)
		local SpawnPos=tr.HitPos-tr.HitNormal*2
		local ent=ents.Create(self.ClassName)
		ent:SetAngles(Angle(180, 0, 90))
		ent:SetPos(SpawnPos)
		JMod.Owner(ent, ply)
		ent:Spawn()
		ent:Activate()
		--local effectdata=EffectData()
		--effectdata:SetEntity(ent)
		--util.Effect("propspawn",effectdata)
		return ent
	end
	function ENT:Initialize()
		self.Entity:SetModel("models/props_wasteland/prison_pipefaucet001a.mdl")
		---self.Entity:SetMaterial("models/mat_jack_gmod_ezfougasse")
		self.Entity:PhysicsInit(SOLID_VPHYSICS)
		self.Entity:SetMoveType(MOVETYPE_NONE)	
		self.Entity:SetSolid(SOLID_VPHYSICS)
		self.Entity:DrawShadow(true)
		---
		timer.Simple(.01,function()
			self:GetPhysicsObject():SetMass(100)
			self:GetPhysicsObject():Wake()
			self:GetPhysicsObject():EnableMotion(false)
		end)
		---
	end
	function ENT:OnTakeDamage(dmginfo)
		---
	end
	function ENT:Detonate()
		local SelfPos=self:LocalToWorld(self:OBBCenter())
		local Sploom=EffectData()
		Sploom:SetOrigin(SelfPos)
		util.Effect("Explosion",Sploom,true,true)
		util.BlastDamage(self,self.Owner or self,SelfPos,150*JMod.Config.MinePower,math.random(50,100)*JMod.Config.MinePower)
		util.ScreenShake(SelfPos,99999,99999,1,500)
		self.Entity:EmitSound("BaseExplosionEffect.Sound")
		--self:EmitSound("snd_jack_fragsplodeclose.wav",90,100)
		local Pos=self:GetPos()
		if(self)then self:Remove() end
		timer.Simple(.1,function()
			local Tr=util.QuickTrace(Pos+Vector(0,0,10),Vector(0,0,-20))
			if(Tr.Hit)then util.Decal("Scorch",Tr.HitPos+Tr.HitNormal,Tr.HitPos-Tr.HitNormal) end
		end)
		for i=1,50 do
			local FireAng=(self:GetUp()+VectorRand()*.2+Vector(0,0,.1)):Angle()
			local Flame=ents.Create("ent_jack_gmod_eznapalm")
			Flame:SetPos(SelfPos)
			Flame:SetAngles(FireAng)
			Flame:SetOwner(self.Owner or game.GetWorld())
			JMod.Owner(Flame,self.Owner or self)
			Flame:Spawn()
			Flame:Activate()
		end
	end
	function ENT:Think()
		local Time=CurTime()
		
		self:NextThink(Time+.3)
		return true
	end
	function ENT:OnRemove()
		---
	end
elseif(CLIENT)then
	function ENT:Initialize()
		---
	end
	local GlowSprite=Material("sprites/mat_jack_basicglow")
	function ENT:Draw()
		self:DrawModel()
	end
	language.Add("ent_jack_gmod_ezfougasse","EZ Fougasse Mine")
end
