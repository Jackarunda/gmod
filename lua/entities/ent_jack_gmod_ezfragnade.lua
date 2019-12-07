-- Jackarunda 2019
AddCSLuaFile()
ENT.Base = "ent_jack_gmod_ezgrenade"
ENT.Author="Jackarunda, TheOnly8Z"
ENT.Category="JMod - EZ"
ENT.PrintName="EZ Frag Grenade"
ENT.Spawnable=true

ENT.JModPreferredCarryAngles=Angle(0,-140,0)
ENT.Model = "models/weapons/w_fragjade.mdl"
ENT.Material = "models/mats_jack_nades/gnd"
ENT.ModelScale = 2
ENT.SpoonScale = 2

if(SERVER)then
	
	function ENT:Arm()
		self:SetBodygroup(2,1)
		self:SetState(JMOD_EZ_STATE_ARMED)
		self:PinEffect()
		timer.Simple(4,function()
			if(IsValid(self))then self:Detonate() end
		end)
	end

	function ENT:Detonate()
		if(self.Exploded)then return end
		self.Exploded=true
		local SelfPos=self:GetPos()
		JMod_Sploom(self.Owner,self:GetPos(),math.random(10,20))
		self:EmitSound("snd_jack_fragsplodeclose.wav",90,100)
		local plooie=EffectData()
		plooie:SetOrigin(SelfPos)
		plooie:SetScale(.5)
		plooie:SetRadius(1)
		plooie:SetNormal(vector_up)
		util.Effect("eff_jack_minesplode",plooie,true,true)
		util.ScreenShake(SelfPos,20,20,1,1000)
		util.BlastDamage(self,self.Owner or game.GetWorld(),SelfPos,700,20)
		local OnGround=util.QuickTrace(SelfPos+Vector(0,0,5),Vector(0,0,-15),{self}).Hit
		local Spred=Vector(0,0,0)
		for i=1,400 do
			timer.Simple(i/4000+.01,function()
				local Dir=VectorRand()
				if(OnGround)then
					Dir.z=Dir.z/4+.2
				else
					Dir.z=Dir.z/4-.2
				end
				self:FireBullets({
					Attacker=self.Owner or game.GetWorld(),
					Damage=math.random(40,50),
					Force=math.random(10,100),
					Num=1,
					Src=SelfPos,
					Tracer=1,
					Dir=Dir:GetNormalized(),
					Spread=Spred
				})
				if(i==400)then
					self:Remove()
				end
			end)
		end
	end
	
elseif(CLIENT)then

	local GlowSprite = Material("sprites/mat_jack_circle")
	function ENT:Draw()
		self:DrawModel()
		-- sprites for calibrating the lethality/casualty radius
		--[[
		local State,Vary=self:GetState(),math.sin(CurTime()*50)/2+.5
		if(State==STATE_ARMED)then
			render.SetMaterial(GlowSprite)
			render.DrawSprite(self:GetPos()+Vector(0,0,4),15*52*2,15*52*2,Color(255,0,0))
			render.DrawSprite(self:GetPos()+Vector(0,0,4),5*52*2,5*52*2,Color(255,255,255))
		end
		--]]
	end
	language.Add("ent_jack_gmod_ezfragnade","EZ Frag Grenade")
	
end