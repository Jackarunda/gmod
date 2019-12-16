-- Jackarunda 2019
AddCSLuaFile()
ENT.Base="ent_jack_gmod_ezgrenade"
ENT.Author="Jackarunda, TheOnly8Z"
ENT.Category="JMod - EZ Explosives"
ENT.PrintName="EZ Impact Grenade"
ENT.Spawnable=true

ENT.Model = "models/grenades/impact_grenade.mdl"
ENT.ModelScale = 1.5

ENT.SpoonModel = "models/grenades/impact_grenade_cap.mdl"
ENT.SpoonSound = "physics/cardboard/cardboard_box_impact_soft2.wav"

local BaseClass = baseclass.Get(ENT.Base)

if(SERVER)then

	function ENT:Prime()
		self:SetState(JMOD_EZ_STATE_PRIMED)
		self:EmitSound("weapons/pinpull.wav",60,100)
		self:SpoonEffect()
		self:SetBodygroup(2,1)
	end

	function ENT:Arm()
		self:SetState(JMOD_EZ_STATE_ARMING)
		timer.Simple(0.2, function()
			if IsValid(self) then
				self:SetState(JMOD_EZ_STATE_ARMED)
			end
		end)
	end
	
	function ENT:PhysicsCollide(data,physobj)
		if data.DeltaTime>0.2 and data.Speed>200 and self:GetState() == JMOD_EZ_STATE_ARMED then
			self:Detonate()
		else
			BaseClass.PhysicsCollide(self, data, physobj)
		end
	end

	function ENT:Detonate()
		if(self.Exploded)then return end
		self.Exploded=true
		local SelfPos=self:GetPos()
		local Sploom=ents.Create("env_explosion")
		Sploom:SetPos(SelfPos)
		Sploom:SetOwner(self.Owner or game.GetWorld())
		Sploom:SetKeyValue("iMagnitude",math.random(10,20))
		Sploom:Spawn()
		Sploom:Activate()
		Sploom:Fire("explode","",0)
		self:EmitSound("snd_jack_fragsplodeclose.wav",90,100)
		local Blam=EffectData()
		Blam:SetOrigin(SelfPos)
		Blam:SetScale(0.5)
		util.Effect("eff_jack_plastisplosion",Blam,true,true)
		util.ScreenShake(SelfPos,20,20,1,1000)
		util.BlastDamage(self,self.Owner or game.GetWorld(),SelfPos,200,200)
		self:Remove()
	end
elseif(CLIENT)then
	language.Add("ent_jack_gmod_ezimpactnade","EZ Impact Nade")
end