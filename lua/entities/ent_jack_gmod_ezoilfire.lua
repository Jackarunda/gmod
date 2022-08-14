-- Jackarunda 2021
AddCSLuaFile()
ENT.Type="anim"
ENT.Author="Jackarunda"
ENT.Category="JMod - EZ Misc."
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
		self.Entity:PhysicsInit(SOLID_NONE)
		self.Entity:SetMoveType(MOVETYPE_NONE)	
		self.Entity:SetSolid(SOLID_NONE)
		self.Entity:DrawShadow(true)
		---
		timer.Simple(.01,function()
			self.Ignited = true
		end)
		--
		timer.Simple(0.2,function()
			local Tr=util.QuickTrace(self:GetPos()+Vector(2,0,10),Vector(0,0,-40))
			if(Tr.Hit)then util.Decal("BigScorch",Tr.HitPos+Tr.HitNormal,Tr.HitPos-Tr.HitNormal) end
		end)
		---
		--SafeRemoveEntityDelayed(self, 300)
	end
	function ENT:OnTakeDamage(dmginfo)
		---
	end
	function ENT:CanSee(ent)
        if not(IsValid(ent))then return false end
        local TargPos,SelfPos=ent:LocalToWorld(ent:OBBCenter()),self:LocalToWorld(self:OBBCenter())+vector_up*5
        local Tr=util.TraceLine({
            start=SelfPos,
            endpos=TargPos,
            filter={self,ent},
            mask=MASK_SHOT+MASK_WATER
        })
        return not Tr.Hit
    end
	function ENT:Think()
		local Time = CurTime()
		local SelfPos = self:LocalToWorld(self:OBBCenter())
		local Up, Forward, Right = self:GetUp(), self:GetForward(), self:GetRight()
		local MaxDistance = 250

		local Eff=EffectData()
		Eff:SetOrigin(self:GetPos()+self:GetRight()*10)
		Eff:SetNormal(self:GetRight())
		Eff:SetScale(1)
		util.Effect("eff_jack_gmod_ezoilfiresmoke",Eff,true)

		if(self.Ignited)then
			for i,ent in ipairs(ents.FindInSphere(SelfPos + Forward * 5, MaxDistance))do
				if not(IsValid(ent))then return end
				local DDistance = SelfPos:Distance(ent:GetPos())
				local DistanceFactor = (1 - DDistance / MaxDistance) ^ 2
				if(self:CanSee(ent))then
					local Dmg=DamageInfo()
					Dmg:SetDamage(100 * DistanceFactor) -- wanna scale this with distance
					Dmg:SetDamageType(DMG_BURN)
					Dmg:SetDamageForce(Vector(0 ,0, 100000) * DistanceFactor) -- some random upward force
					Dmg:SetAttacker(game.GetWorld()) -- the earth is mad at you
					Dmg:SetInflictor(game.GetWorld())
					Dmg:SetDamagePosition(ent:GetPos())
					if(ent.TakeDamageInfo)then ent:TakeDamageInfo(Dmg) end
				end
			end
			self:NextThink(Time + .1)
		end
		return true
	end
	function ENT:OnRemove()
		---
	end
elseif(CLIENT)then
	function ENT:Initialize()
		---
	end
	function ENT:Draw()
		self:DrawModel()
			if(self.Ignited)then
				---
			end
	end
	language.Add("ent_jack_gmod_ezoilfire","EZ Oil Fire")
end
