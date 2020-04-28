-- Jackarunda 2019
AddCSLuaFile()
ENT.Base = "ent_jack_gmod_ezgrenade"
ENT.Author="Jackarunda, TheOnly8Z"
ENT.Information="glhfggwpezpznore"
ENT.PrintName="EZ Mininade Base"
ENT.Spawnable=false

ENT.JModPreferredCarryAngles=Angle(0,-140,0)
ENT.Model = "models/weapons/w_fragjade.mdl"
ENT.Material = "models/mats_jack_nades/gnd"
ENT.ModelScale = 1.25
ENT.Hints = {"grenade", "mininade"}

ENT.MiniNadeDamage=100
ENT.Mass=7

local BaseClass = baseclass.Get(ENT.Base)

if(SERVER)then

	function ENT:Initialize()
		BaseClass.Initialize(self)
		self.LastVel=Vector(0,0,0)
		self.NextDet=0
	end
	
	function ENT:OnTakeDamage(dmginfo)
	
		self.Entity:TakePhysicsDamage(dmginfo)
		
		if dmginfo:GetInflictor() != self and dmginfo:GetDamage() >= 5 and !self.Exploded and self:GetState() != JMOD_EZ_STATE_BROKEN then
			self:EmitSound("physics/metal/metal_box_impact_bullet2.wav", 75, 200)
			self:SetState(JMOD_EZ_STATE_BROKEN)
			local eff = EffectData()
			eff:SetOrigin(self:GetPos())
			eff:SetScale(1) -- how far
			eff:SetRadius(8) -- how thick
			eff:SetMagnitude(4) -- how much
			util.Effect("Sparks", eff)
			SafeRemoveEntity(self)
		end
		
	end
    
	function ENT:Use(activator,activatorAgain,onOff)
		if(self.Exploded)then return end
		local Dude=activator or activatorAgain
		JMod_Owner(self,Dude)
		local Time=CurTime()
		if((self.ShiftAltUse)and(Dude:KeyDown(JMOD_CONFIG.AltFunctionKey))and(Dude:KeyDown(IN_SPEED)))then
			return self:ShiftAltUse(Dude,tobool(onOff))
		end
		if(tobool(onOff))then
			local State=self:GetState()
			if(State<0)then return end
			local Alt=Dude:KeyDown(JMOD_CONFIG.AltFunctionKey)
			if(State==JMOD_EZ_STATE_OFF and Alt)then
				self:Prime()
                JMod_Hint(Dude, "grenade", self)
            else
                if not JMod_Hint(Dude, "prime", self) then JMod_Hint(Dude, "mininade", self) end
			end
			if self.Hints then  end
			JMod_ThrowablePickup(Dude,self,self.HardThrowStr,self.SoftThrowStr)
		end
	end
	
	function ENT:PhysicsCollide(data,physobj)
		if((not(IsValid(self.AttachedBomb)))and(self:IsPlayerHolding())and(data.HitEntity.EZdetonateOverride))then
			self.Entity:EmitSound("Grenade.ImpactHard")
			self:SetPos(data.HitPos-data.HitNormal)
			self.AttachedBomb=data.HitEntity
			self.LastVel=data.HitEntity:GetVelocity()
			timer.Simple(0,function() self:SetParent(data.HitEntity) end)
		else
			BaseClass.PhysicsCollide(self, data, physobj)
		end
	end

	function ENT:Detonate()
		if(self.Exploded)then return end
		self.Exploded=true
		local SelfPos=self:GetPos()
		if(IsValid(self.AttachedBomb))then
			JMod_Owner(self.AttachedBomb,self.Owner or self.AttachedBomb.Owner or game.GetWorld())
			self.AttachedBomb:EZdetonateOverride(self)
			JMod_Sploom(self.Owner,SelfPos,3)
			self:Remove()
			return
		end
		JMod_Sploom(self.Owner,SelfPos,self.MiniNadeDamage,self.MiniNadeDamageMax)
		util.ScreenShake(SelfPos,20,20,1,500)
		self:Remove()
	end
	
elseif(CLIENT)then

end