-- Jackarunda 2019
AddCSLuaFile()
ENT.Type="anim"
ENT.Author="Jackarunda"
ENT.Category="JMod - EZ"
ENT.Information="glhfggwpezpznore"
ENT.PrintName="EZ Armor"
ENT.Spawnable=false
ENT.AdminSpawnable=false
---
if(SERVER)then
	function ENT:Initialize()
		if not(IsMounted("tf"))then jprint("TF2 NOT MOUNTED");self:Remove() return end
		self.Entity:SetModel("models/props_phx/misc/smallcannonball.mdl")
		self.Entity:SetMaterial("")
		--self.Entity:PhysicsInitBox(Vector(-10,-10,-10),Vector(10,10,10))
		--self:SetModelScale(self.Scale or .5,0)
		self.Entity:PhysicsInit(SOLID_VPHYSICS)
		self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
		self.Entity:SetSolid(SOLID_VPHYSICS)
		self.Entity:DrawShadow(false)
		self.Entity:SetUseType(SIMPLE_USE)
		self:GetPhysicsObject():SetMass(10)
		---
		timer.Simple(.01,function()
			self:GetPhysicsObject():SetMass(10)
			self:GetPhysicsObject():Wake()
		end)
		---
		if not(self.NoSound)then
			local Loop=CreateSound(self,"snds_jack_gmod/fiddle_loop.wav")
			Loop:SetSoundLevel(40)
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
	function ENT:PhysicsCollide(data,physobj)
		if(data.DeltaTime>0.2)then
			if(data.Speed>25)then
				self.Entity:EmitSound("Body.ImpactSoft")
			end
		end
	end
	function ENT:OnTakeDamage(dmginfo)
		self.Entity:TakePhysicsDamage(dmginfo)
	end
	function ENT:Use(activator)
		--
	end
	function ENT:OnRemove()
		if(self.Snd)then self.Snd:Stop() end
	end
elseif(CLIENT)then
	function ENT:Initialize()
		self.Engie=ClientsideModel("models/player/engineer.mdl")
		self.Engie:SetPos(self:GetPos())
		self.Engie:SetNoDraw(true)
		self.LastAng=Angle(0,0,0)
		for i=0,1000 do
			local Seq=self.Engie:GetSequenceInfo(i)
			if(Seq)then
				if(string.find(Seq.label,"dance"))then
					print(i)
					PrintTable(Seq)
				end
			end
		end
		-- 316
		-- taunt_dosido_dance
	end
	function ENT:Draw()
		self:DrawModel()
		self.Engie:SetRenderOrigin(self:LocalToWorld(self:OBBCenter()))
		local Dir=self:GetVelocity():GetNormalized()
		Dir.z=0
		local Ang=Dir:Angle()
		Ang.p=0
		Ang.r=0
		self.LastAng=LerpAngle(FrameTime()*5,self.LastAng,Ang)
		self.Engie:SetRenderAngles(self.LastAng)
		self.Engie:PlaySequenceAndWait( "layer_taunt01" )
		self.Engie:PlaySequenceAndWait( "taunt_russian" )
		self.Engie:DrawModel()
	end
	language.Add("ent_jack_gmod_ezanomaly_engineeer","T I N Y   D E S K   E N G I N E E R")
end