-- Jackarunda 2019
AddCSLuaFile()
ENT.Type="anim"
ENT.Author="Jackarunda, TheOnly8Z"
ENT.Category="JMod - EZ"
ENT.Information="glhfggwpezpznore"
ENT.PrintName="EZ Stick Grenade"
ENT.Spawnable=true
ENT.AdminSpawnable=true
---
ENT.JModPreferredCarryAngles=Angle(90,0,0)
ENT.JModEZtimedNade=true
---
local STATE_BROKEN,STATE_OFF,STATE_PRIMED,STATE_ARMED=-1,0,1,2
function ENT:SetupDataTables()
	self:NetworkVar("Int",0,"State")
end
---
if(SERVER)then

	util.PrecacheModel("models/codww2/equipment/model 24 stielhandgranate with frag sleeve.mdl")
	util.AddNetworkString("JModStickNade")

	function ENT:SpawnFunction(ply,tr)
		local SpawnPos=tr.HitPos+tr.HitNormal*20
		local ent=ents.Create(self.ClassName)
		ent:SetAngles(Angle(0,0,0))
		ent:SetPos(SpawnPos)
		ent.Owner=ply
		ent:Spawn()
		ent:Activate()
		--local effectdata=EffectData()
		--effectdata:SetEntity(ent)
		--util.Effect("propspawn",effectdata)
		return ent
	end
	function ENT:Initialize()
		--models/codww2/equipment/model 24 stielhandgranate with frag sleeve.mdl

		self:SetModel("models/mechanics/robotics/a2.mdl")
		self:SetModelScale(0.35)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:DrawShadow(false)
		self:SetUseType(ONOFF_USE)
		
		--[[
		self.Deco = ents.Create("prop_physics")
		self.Deco:SetModel("models/codww2/equipment/model 24 stielhandgranate with frag sleeve.mdl")
		self.Deco:SetPos(self:GetPos() + self:GetForward() * 5)
		local ang = self:GetAngles()
		ang:RotateAroundAxis(ang:Right(), 90)
		self.Deco:SetAngles(ang)
		self.Deco:PhysicsInit(SOLID_NONE)
		self.Deco:Spawn()
		self.Deco:SetParent(self)
		]]

		
		---
		timer.Simple(.01,function()
			self:GetPhysicsObject():SetMass(15)
			self:GetPhysicsObject():Wake()
		end)
		---
		self:SetState(STATE_OFF)
	end
	function ENT:PhysicsCollide(data,physobj)
		if(data.DeltaTime>0.2 and data.Speed>30)then
			self:EmitSound("Grenade.ImpactHard")
		end
	end
	function ENT:OnTakeDamage(dmginfo)
		if(self.Exploded)then return end
		if(dmginfo:GetInflictor()==self)then return end
		self:TakePhysicsDamage(dmginfo)
		local Dmg=dmginfo:GetDamage()
		if(Dmg>=4)then
			local Pos,State,DetChance=self:GetPos(),self:GetState(),0
			if(dmginfo:IsDamageType(DMG_BLAST))then DetChance=DetChance+Dmg/150 end
			if(math.Rand(0,1)<DetChance)then self:Detonate() end
			if((math.random(1,10)==3)and not(State==STATE_BROKEN))then
				sound.Play("Metal_Box.Break",Pos)
				self:SetState(STATE_BROKEN)
				SafeRemoveEntityDelayed(self,10)
			end
		end
	end
	function ENT:Use(activator,activatorAgain,onOff)
		local Dude=activator or activatorAgain
		self.Owner=Dude
		local Time=CurTime()
		if(tobool(onOff))then
			local State=self:GetState()
			if(State<0)then return end
			local Alt=Dude:KeyDown(IN_WALK)
			if(State==STATE_OFF and Alt)then
				self:SetState(STATE_PRIMED)
				self:EmitSound("weapons/pinpull.wav",60,100)
			end
			JMod_Hint(activator,"grenade")
			JMod_ThrowablePickup(Dude,self,900,400)
		end
	end
	function ENT:Think()
		local State,Time=self:GetState(),CurTime()
		if(State==STATE_PRIMED)then
			if not(self:IsPlayerHolding())then
				self:SetState(STATE_ARMED)
				local Spewn=ents.Create("ent_jack_spoon")
				Spewn:SetPos(self:GetPos())
				Spewn:Spawn()
				Spewn:SetModel("models/codww2/equipment/model 24 stielhandgranate with frag sleeve cap.mdl")
				Spewn:Activate()
				Spewn:GetPhysicsObject():SetVelocity(self:GetPhysicsObject():GetVelocity()+VectorRand()*200)
				self:EmitSound("snd_jack_spoonfling.wav",60,math.random(90,110))
				--self.Deco:SetBodygroup(4,1)
				net.Start("JModStickNade")
					net.WriteEntity(self)
				net.Broadcast()
				timer.Simple(4,function()
					if(IsValid(self))then self:Detonate() end
				end)
			end
			self:NextThink(Time+.1)
			return true
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
	--[[
	function ENT:OnRemove()
		if IsValid(self.Deco) then self.Deco:Remove() end
	end
	]]
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
	local GlowSprite=Material("sprites/mat_jack_basicglow")
	function ENT:Draw()
		--self:DrawModel()
		local State,Vary=self:GetState(),math.sin(CurTime()*50)/2+.5
		if(State==STATE_ARMING)then
			render.SetMaterial(GlowSprite)
			render.DrawSprite(self:GetPos()+Vector(0,0,4),20,20,Color(255,0,0))
			render.DrawSprite(self:GetPos()+Vector(0,0,4),10,10,Color(255,255,255))
		elseif(State==STATE_WARNING)then
			render.SetMaterial(GlowSprite)
			render.DrawSprite(self:GetPos()+Vector(0,0,4),30*Vary,30*Vary,Color(255,0,0))
			render.DrawSprite(self:GetPos()+Vector(0,0,4),15*Vary,15*Vary,Color(255,255,255))
		end
	end
	language.Add("ent_jack_gmod_ezfragnade","EZ Frag Grenade")
end