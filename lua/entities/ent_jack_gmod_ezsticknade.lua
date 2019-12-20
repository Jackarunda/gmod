-- Jackarunda 2019
AddCSLuaFile()
ENT.Base="ent_jack_gmod_ezgrenade"
ENT.Author="Jackarunda, TheOnly8Z"
ENT.Category="JMod - EZ Explosives"
ENT.PrintName="EZ Stick Grenade"
ENT.Spawnable=true

ENT.Model = "models/grenades/stick_grenade.mdl" -- "models/mechanics/robotics/a2.mdl"
ENT.ModelScale = 1.25
ENT.SpoonModel = "models/grenades/stick_grenade_cap.mdl"
ENT.HardThrowStr = 800
ENT.SoftThrowStr = 400
ENT.JModPreferredCarryAngles=Angle(0,0,0)
ENT.EZspinThrow=true

local BaseClass = baseclass.Get(ENT.Base)

if(SERVER)then

	function ENT:Prime()
		self:SetState(JMOD_EZ_STATE_PRIMED)
		self:EmitSound("weapons/pinpull.wav",60,100)
	end

	function ENT:Arm()
		self:SetState(JMOD_EZ_STATE_ARMED)
		timer.Simple(4,function()
			if(IsValid(self))then self:Detonate() end
		end)
		self:SpoonEffect()
	end
	
	function ENT:Detonate()
		if(self.Exploded)then return end
		self.Exploded=true
		local SelfPos=self:GetPos()
		JMod_Sploom(self.Owner or game.GetWorld(),SelfPos,150)
		self:EmitSound("snd_jack_fragsplodeclose.wav",90,100)
		local Blam=EffectData()
		Blam:SetOrigin(SelfPos)
		Blam:SetScale(.8)
		util.Effect("eff_jack_plastisplosion",Blam,true,true)
		util.ScreenShake(SelfPos,20,20,1,1000)
		self:Remove()
	end
	
elseif(CLIENT)then
	language.Add("ent_jack_gmod_ezsticknade","EZ Stick Grenade")
end