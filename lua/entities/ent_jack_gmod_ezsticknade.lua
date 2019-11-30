-- Jackarunda 2019
AddCSLuaFile()
ENT.Base="ent_jack_gmod_ezgrenade"
ENT.Author="Jackarunda, TheOnly8Z"
ENT.Category="JMod - EZ Explosives"
ENT.PrintName="EZ Stick Grenade"
ENT.Spawnable=true

ENT.Model = "models/mechanics/robotics/a2.mdl" --"models/codww2/equipment/model 24 stielhandgranate with frag sleeve.mdl"
ENT.ModelScale = 0.35
ENT.SpoonModel = "models/codww2/equipment/model 24 stielhandgranate with frag sleeve cap.mdl"
ENT.JModPreferredCarryAngles=Angle(90,0,0)

local BaseClass = baseclass.Get(ENT.Base)

if(SERVER)then

	util.PrecacheModel("models/codww2/equipment/model 24 stielhandgranate with frag sleeve.mdl")
	util.AddNetworkString("JModStickNade")

	function ENT:Initialize()
		BaseClass.Initialize(self)
		self:DrawShadow(false)
		timer.Simple(4,function()
			if(IsValid(self))then self:Detonate() end
		end)
	end
	

	function ENT:Prime()
		self:SetState(JMOD_EZ_STATE_PRIMED)
		self:EmitSound("weapons/pinpull.wav",60,100)
	end

	function ENT:Arm()
		net.Start("JModStickNade")
			net.WriteEntity(self)
		net.Broadcast()
		self:SetState(JMOD_EZ_STATE_ARMED)
		timer.Simple(4,function()
			if(IsValid(self))then self:Detonate() end
		end)
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
		for i=1,300 do
			timer.Simple(i/3000,function()
				local Dir=VectorRand()
				Dir.z=Dir.z/5+.1
				self:FireBullets({
					Attacker=self.Owner or game.GetWorld(),
					Damage=math.random(40,60),
					Force=math.random(1000,10000),
					Num=1,
					Src=SelfPos,
					Tracer=1,
					Dir=Dir:GetNormalized(),
					Spread=Vector(0,0,0)
				})
				if(i==300)then self:Remove() end
			end)
		end
	end
	
elseif(CLIENT)then

	net.Receive("JModStickNade", function()
		local ent = net.ReadEntity()
		if IsValid(ent) and IsValid(ent.Deco) then ent.Deco:SetBodygroup(4, 1) end
	end)

	function ENT:Initialize()
		self.Deco = ClientsideModel("models/codww2/equipment/model 24 stielhandgranate with frag sleeve.mdl")
		self.Deco:SetModel("models/codww2/equipment/model 24 stielhandgranate with frag sleeve.mdl")
		self.Deco:SetPos(self:GetPos() + self:GetForward() * 3)
		local ang = self:GetAngles()
		ang:RotateAroundAxis(ang:Right(), 90)
		self.Deco:SetAngles(ang)
		self.Deco:SetParent(self)
	end
	
	function ENT:OnRemove()
		if IsValid(self.Deco) then self.Deco:Remove() end
	end

	function ENT:Draw()
		--self:DrawModel()
	end
	language.Add("ent_jack_gmod_ezsticknade","EZ Stick Grenade")
end