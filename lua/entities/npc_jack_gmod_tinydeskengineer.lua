AddCSLuaFile()
ENT.Base="base_nextbot"
ENT.Spawnable=false
ENT.PrintName="T I N Y   D E S K   E N G I N E E R"
ENT.Author="Jackarunda"
ENT.Spawnable=false
ENT.AdminSpawnable=false
function ENT:Initialize()
	self:SetModelScale(self.Scale or .15,0)
	self:SetModel("models/player/engineer.mdl")
	self:Activate()
	self:SetHealth(self.Helf or 10)
	timer.Simple(math.Rand(0,1),function()
		if(IsValid(self))then self:DoMusic() end
	end)
	timer.Simple(0,function()
		self:SetPos(self:GetPos()+VectorRand()*math.Rand(20,200)+Vector(0,0,50))
		self:SetAngles(Angle(0,math.random(0,360),0))
	end)
end
function ENT:DoMusic()
	if(self.Snd)then
		self.Snd:Stop()
		self.Snd=nil
	end
	if not(self.NoSound)then
		local Loop=CreateSound(self,"snds_jack_gmod/fiddle_loop.wav")
		Loop:SetSoundLevel(50)
		Loop:Play()
		self.Snd=Loop
	end
	for k,v in pairs(ents.FindByClass(self.ClassName))do
		-- re-sync the music across all TDEs
		if(v.Snd)then
			v.Snd:Stop()
			v.Snd:Play()
		end
	end
end
function ENT:OnRemove()
	if(self.Snd)then self.Snd:Stop() end
end
function ENT:Explode()
	local owner,pos=self.Owner or game.GetWorld(),self:GetPos()+Vector(0,0,10)
	for i=1,15*(self.SplodeAmt or 1) do
		timer.Simple(i*.1*math.Rand(.9,1.1),function()
			local Offset=VectorRand()*math.random(50,1000)
			Offset.z=Offset.z/4
			JMod.Sploom(owner,pos+Offset,100)
		end)
	end
	self:Remove()
end
function ENT:OnKilled(dmg)
	self.Owner=dmg:GetAttacker()
	self:EmitSound("snds_jack_gmod/yee.wav")
	timer.Simple(1.4,function()
		if(IsValid(self))then self:Explode() end
	end)
end
function ENT:RunBehaviour()
	while(true)do -- why is nextbot so fucking stupid
		self:PlaySequenceAndWait("taunt_russian")
		coroutine.yield()
	end
end