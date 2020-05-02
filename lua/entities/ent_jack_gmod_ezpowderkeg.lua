-- Jackarunda 2019
AddCSLuaFile()
ENT.Type="anim"
ENT.Author="Jackarunda"
ENT.Category="JMod - EZ Explosives"
ENT.Information="glhfggwpezpznore"
ENT.PrintName="EZ Powder Keg"
ENT.NoSitAllowed=true
ENT.Spawnable=true
ENT.AdminSpawnable=true
---
ENT.JModPreferredCarryAngles=Angle(0,180,0)
ENT.JModEZstorable=true
ENT.EZpowderDetonatable=true
---
if(SERVER)then
	function ENT:SpawnFunction(ply,tr)
		local SpawnPos=tr.HitPos+tr.HitNormal*15
		local ent=ents.Create(self.ClassName)
		ent:SetAngles(Angle(0,0,0))
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
		self:SetModel("models/props_trainyard/distillery_barrel001.mdl")
		self:SetModelScale(.25,0)
		self:SetMaterial("models/entities/mat_jack_powderkeg")
		self:SetBodygroup(0,0)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)	
		self:SetSolid(SOLID_VPHYSICS)
		self:DrawShadow(false)
		self:SetUseType(SIMPLE_USE)
		---
		timer.Simple(.01,function()
			self:GetPhysicsObject():SetMass(50)
			self:GetPhysicsObject():Wake()
		end)
		---
		self.Powder=200
		self.Pouring=false
	end
	function ENT:PhysicsCollide(data,physobj)
		if(data.DeltaTime>0.2 and data.Speed>25)then
			self:EmitSound("DryWall.ImpactHard")
		end
	end
	function ENT:OnTakeDamage(dmginfo)
		if(self.Exploded)then return end
		if(dmginfo:GetInflictor()==self)then return end
		self:TakePhysicsDamage(dmginfo)
		local Dmg=dmginfo:GetDamage()
		if(Dmg>=4)then
			local Pos,DetChance=self:GetPos(),0
			if(dmginfo:IsDamageType(DMG_BLAST)or(dmginfo:IsDamageType(DMG_BURN))or(dmginfo:IsDamageType(DMG_DIRECT)))then DetChance=DetChance+Dmg/150 end
			if(math.Rand(0,1)<DetChance)then self:Detonate() end
		end
	end
	function ENT:Use(activator,activatorAgain,onOff)
		local Dude=activator or activatorAgain
		JMod_Owner(self,Dude)
		
		if(Dude:KeyDown(JMOD_CONFIG.AltFunctionKey))then
			self.Pouring=not self.Pouring
			if self.Pouring then Dude:PickupObject(self) end
            self:EmitSound("items/ammocrate_open.wav", 70, self.Pouring and 130 or 100)
			return
		end
		Dude:PickupObject(self)
        JMod_Hint(Dude, "arm powderkeg", self)
	end
	function ENT:EZdetonateOverride(detonator)
		self:Detonate()
	end
	function ENT:Detonate()
		if(self.Exploded)then return end
		self.Exploded=true
		local SelfPos=self:GetPos()
		self:EmitSound("snd_jack_fragsplodeclose.wav",90,80)
		local Blam=EffectData()
		Blam:SetOrigin(SelfPos)
		Blam:SetScale(.75)
		Blam:SetStart(self:GetPhysicsObject():GetVelocity())
		util.Effect("eff_jack_powdersplode",Blam,true,true)
		util.ScreenShake(SelfPos,20,20,1,700)
		-- black powder is not HE and its explosion lacks brisance, more of a push than a shock
		JMod_Sploom(self.Owner or game.GetWorld(),SelfPos,150)
		local Dmg=DamageInfo()
		Dmg:SetDamage(70)
		Dmg:SetAttacker(self.Owner or self)
		Dmg:SetInflictor(self)
		Dmg:SetDamageType(DMG_BURN)
		util.BlastDamageInfo(Dmg,SelfPos,750)
		for i=1,5 do
			timer.Simple(i/10,function()
				JMod_SimpleForceExplosion(SelfPos,400000,600,self)
			end)
		end
		self:Remove()
	end
	function ENT:Think()
		local Time=CurTime()
		if(self:IsOnFire())then
			if(math.random(1,50)==2)then self:Detonate();return end
		end
		if(self.Pouring)then
			local Eff=EffectData()
			Eff:SetOrigin(self:GetPos())
			Eff:SetStart(self:GetVelocity())
			util.Effect("eff_jack_gmod_blackpowderpour",Eff,true,true)
			local Tr=util.QuickTrace(self:GetPos(),Vector(0,0,-200),{self})
			if(Tr.Hit)then
				local Powder=ents.Create("ent_jack_gmod_ezblackpowderpile")
				Powder:SetPos(Tr.HitPos+Tr.HitNormal*.1)
				JMod_Owner(Powder,self.Owner)
				Powder:Spawn()
				Powder:Activate()
				constraint.Weld(Powder,Tr.Entity,0,0,0,true)
                JMod_Hint(self.Owner, "powder", Powder)
			end
			self.Powder=self.Powder-1
			if(self.Powder<=0)then self:Remove() return end
			self:NextThink(Time+.1)
			return true
		end
	end
	function ENT:OnRemove()
		--aw fuck you
	end
elseif(CLIENT)then
	function ENT:Initialize()
		--
	end
	function ENT:Draw()
		self:DrawModel()
	end
	language.Add("ent_jack_gmod_ezpowderkeg","EZ Powder Keg")
end