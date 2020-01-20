-- Jackarunda 2019
AddCSLuaFile()
ENT.Type="anim"
ENT.Author="Jackarunda"
ENT.Category="JMod - EZ Explosives"
ENT.Information="glhfggwpezpznore"
ENT.PrintName="EZ Black Powder Pile"
ENT.NoSitAllowed=true
ENT.Spawnable=false
ENT.AdminSpawnable=false
ENT.EZpowderIgnitable=true
if(SERVER)then
	function ENT:SpawnFunction(ply,tr)
		local SpawnPos=tr.HitPos+tr.HitNormal*15
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
		self:SetModel("models/cheeze/pcb2/pcb2.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)	
		self:SetSolid(SOLID_VPHYSICS)
		self:DrawShadow(false)
		self:SetUseType(SIMPLE_USE)
		---
		timer.Simple(.01,function()
			self:GetPhysicsObject():SetMass(1)
			self:GetPhysicsObject():Wake()
		end)
		self.Ignited=false
		SafeRemoveEntityDelayed(self,300)
	end
	function ENT:PhysicsCollide(data,physobj)
		if not(data.HitEntity:IsWorld())then
			if(math.random(1,2)==1)then self:Remove() end
		end
	end
	function ENT:OnTakeDamage(dmginfo)
		if(self.Ignited)then return end
		if(dmginfo:IsDamageType(DMG_BLAST))then self:Remove() return end
		if(dmginfo:IsDamageType(DMG_BURN))then
			self.Owner=dmginfo:GetAttacker() or game.GetWorld()
			self:Ignite()
		end
	end
	function ENT:Use(activator,activatorAgain,onOff)
		local Dude=activator or activatorAgain
		self.Owner=Dude
		JMod_Hint(activator,"black powder pile","black powder ignite")
		local Time=CurTime()
		if(Dude:KeyDown(JMOD_CONFIG.AltFunctionKey))then
			self:Arm()
		else
			if(math.random(1,2)==2)then self:Remove() end
		end
	end
	function ENT:Arm()
		if(self.Ignited)then return end
		self.Ignited=true
		self.Entity:EmitSound("snd_jack_sss.wav",60,math.Rand(90,110))
		for i=1,8 do
			local Fsh=EffectData()
			Fsh:SetOrigin(self:GetPos())
			Fsh:SetScale(1)
			Fsh:SetNormal(VectorRand())
			util.Effect("eff_jack_fuzeburn",Fsh,true,true)
		end
		timer.Simple(.075,function()
			if not(IsValid(self))then return end
			for k,v in pairs(ents.FindInSphere(self:GetPos(),30))do
				if(v.EZpowderIgnitable)then
					v.Owner=self.Owner
					v:Arm()
				elseif(v.EZpowderDetonatable)then
					v.Owner=self.Owner
					v:Detonate()
				end
			end
			self:Remove()
		end)
	end
	function ENT:Think()
		--
	end
	function ENT:OnRemove()
		--aw fuck you
	end
elseif(CLIENT)then
	function ENT:Initialize()
		self.NextDrawTime=CurTime()+1
		self.Rot=math.random(0,360)
	end
	local Mat=Material("sprites/mat_jack_gmod_blackpowderpile")
	function ENT:Draw()
		if(self.NextDrawTime<CurTime())then
			render.SetMaterial(Mat)
			render.DrawQuadEasy(self:GetPos(),vector_up,15,15,Color(0,0,0,255),self.Rot)
			--self:DrawModel()
		end
	end
	language.Add("ent_jack_gmod_ezblackpowderpile","EZ Black Powder Pile")
end