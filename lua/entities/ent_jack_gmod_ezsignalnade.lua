-- Jackarunda 2019
AddCSLuaFile()
ENT.Base = "ent_jack_gmod_ezgrenade"
ENT.Author="Jackarunda, TheOnly8Z"
ENT.PrintName="EZ Signal Grenade"
ENT.Category="JMod - EZ Explosives"
ENT.Spawnable=true
ENT.JModPreferredCarryAngles=Angle(0,140,0)
ENT.Model = "models/grenades/incendiary_grenade.mdl"
ENT.Material="models/mats_jack_nades/smokesignal"
ENT.Color=Color(128,128,128)
ENT.ModelScale = 1.5
ENT.SpoonScale = 2
if(SERVER)then
	function ENT:Use(activator,activatorAgain,onOff)
		if(self.Exploded)then return end
		local Dude=activator or activatorAgain
		JMod_Owner(self,Dude)
		local Time=CurTime()
		if(tobool(onOff))then
			local State=self:GetState()
			if(State<0)then return end
			local Alt=Dude:KeyDown(JMOD_CONFIG.AltFunctionKey)
			if(State==JMOD_EZ_STATE_OFF and Alt)then
				net.Start("JMod_SignalNade")
				net.WriteEntity(self)
				net.Send(Dude)
			end
			JMod_ThrowablePickup(Dude,self,self.HardThrowStr,self.SoftThrowStr)
		end
	end
	function ENT:Prime()
		self:SetState(JMOD_EZ_STATE_PRIMED)
		self:EmitSound("weapons/pinpull.wav",60,100)
		self:SetBodygroup(3,1)
	end
	function ENT:Arm()
		self:SetBodygroup(2,1)
		self:SetState(JMOD_EZ_STATE_ARMED)
		self:SpoonEffect()
		timer.Simple(2,function()
			if(IsValid(self))then self:Detonate() end
		end)
	end
	function ENT:Detonate()
		if(self.Exploded)then return end
		self.Exploded=true
		self.FuelLeft=100
		self:EmitSound("snd_jack_fragsplodeclose.wav",70,150)
	end
	function ENT:CustomThink()
		if(self.Exploded)then
			local Foof=EffectData()
			Foof:SetOrigin(self:GetPos())
			Foof:SetNormal(self:GetUp())
			Foof:SetScale(self.FuelLeft/100)
			Foof:SetStart(self:GetPhysicsObject():GetVelocity())
			local Col=self:GetColor()
			Foof:SetAngles(Angle(Col.r,Col.g,Col.b))
			util.Effect("eff_jack_gmod_ezsmokesignal",Foof,true,true)
			self:EmitSound("snd_jack_sss.wav",55,80)
			self.FuelLeft=self.FuelLeft-.5
			if(self.FuelLeft<=0)then SafeRemoveEntityDelayed(self,1) end
		end
	end
elseif(CLIENT)then
	function ENT:Draw()
		self:DrawModel()
	end
	language.Add("ent_jack_gmod_ezsignalnade","EZ Smoke Signal Grenade")
end