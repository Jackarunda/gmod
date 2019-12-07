-- Jackarunda 2019
AddCSLuaFile()
ENT.Base="ent_jack_gmod_ezgrenade"
ENT.Author="Jackarunda, TheOnly8Z"
ENT.Category="JMod - EZ Explosives"
ENT.PrintName="EZ Stick Grenade"
ENT.Spawnable=true

ENT.Model = "models/grenades/stick_grenade.mdl" -- "models/mechanics/robotics/a2.mdl"
ENT.ModelScale = 1.5
ENT.SpoonModel = "models/grenades/stick_grenade_cap.mdl"
ENT.HardThrowStr = 1200
ENT.SoftThrowStr = 600
ENT.JModPreferredCarryAngles=Angle(0,0,0)

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
		local Sploom=ents.Create("env_explosion")
		Sploom:SetPos(SelfPos)
		Sploom:SetOwner(self.Owner or game.GetWorld())
		Sploom:SetKeyValue("iMagnitude",math.random(10,20))
		Sploom:Spawn()
		Sploom:Activate()
		Sploom:Fire("explode","",0)
		self:EmitSound("snd_jack_fragsplodeclose.wav",90,100)
		util.ScreenShake(SelfPos,20,20,1,1000)
		util.BlastDamage(self,self.Owner or game.GetWorld(),SelfPos,700,20)
		for i=1,400 do
			timer.Simple(i/4000,function()
				local Dir=VectorRand()
				Dir.z=Dir.z/5+.1
				self:FireBullets({
					Attacker=self.Owner or game.GetWorld(),
					Damage=math.random(35,50),
					Force=math.random(1000,10000),
					Num=1,
					Src=SelfPos,
					Tracer=1,
					Dir=Dir:GetNormalized(),
					Spread=Vector(0,0,0)
				})
				if(i==400)then self:Remove() end
			end)
		end
	end
	
elseif(CLIENT)then
	language.Add("ent_jack_gmod_ezsticknade","EZ Stick Grenade")
end