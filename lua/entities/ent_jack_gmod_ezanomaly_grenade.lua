-- Jackarunda 2021
AddCSLuaFile()
ENT.Base = "ent_jack_gmod_ezgrenade"
ENT.Author="Jackarunda"
ENT.PrintName="T H E  G R E N A D E"
ENT.Category="JMod - EZ Explosives"
ENT.Spawnable=false
ENT.JModPreferredCarryAngles=Angle(0,-140,0)
ENT.Model = "models/weapons/w_fragjade.mdl"
ENT.Material = "models/shiny"
ENT.ModelScale = 3
ENT.SpoonScale = 3
ENT.DetonationEffects={
	{ -- b a l l s
		col=Color(128,255,128),
		func=function(self,pos,owner)
			JMod_Sploom(owner,pos,10)
			for i=1,100 do
				local Nade=ents.Create("sent_ball")
				Nade:SetPos(pos)
				Nade.Owner=owner
				Nade:Spawn()
				timer.Simple(0,function()
					Nade:SetBallSize(math.random(20,50))
					Nade:GetPhysicsObject():SetVelocity(VectorRand()*math.Rand(10,300))
				end)
			end
		end
	},
	{ -- sad fart
		col=Color(50,40,0),
		func=function(self,pos,owner)
			sound.Play("snds_jack_gmod/sadfart.wav",pos,100,100)
			self:PoofEffect()
		end
	},
	{ -- chaotic neutral
		col=Color(128,128,128),
		func=function(self,pos,owner)
			JMod_Sploom(owner,pos,10)
			for i=1,10 do
				local Nade=ents.Create("ent_jack_gmod_ezanomaly_grenade")
				Nade:SetPos(pos)
				Nade.Owner=owner
				Nade:Spawn()
				timer.Simple(0,function()
					Nade:GetPhysicsObject():SetVelocity(VectorRand()*math.Rand(10,1000))
					Nade:Arm()
				end)
			end
		end
	},
	{ -- U P
		col=Color(128,128,255),
		func=function(self,pos,owner)
			self:PoofEffect()
			for k,v in pairs(ents.FindInSphere(pos,2000))do
				if(v:IsPlayer())then
					v:SetMoveType(MOVETYPE_WALK)
					v:SetVelocity(Vector(0,0,math.random(1500,2000)))
					net.Start("JMod_SFX")
					net.WriteString("snds_jack_gmod/whee.wav")
					net.Send(v)
				elseif(v:IsNPC())then
					v:SetVelocity(Vector(0,0,math.random(1500,2000)))
				elseif(IsValid(v:GetPhysicsObject()))then
					v:GetPhysicsObject():SetVelocity(Vector(0,0,math.random(1500,2000)))
				end
			end
		end
	},
	{ -- Instant Infestation
		col=Color(180,128,0),
		func=function(self,pos,owner)
			JMod_Sploom(owner,pos,0)
			for i=1,50 do
				local Nade=ents.Create("npc_headcrab_fast")
				Nade:SetPos(pos+VectorRand()*10+Vector(0,0,10))
				Nade.Owner=owner
				Nade:Spawn()
				timer.Simple(0,function() if(IsValid(Nade))then Nade:SetVelocity(VectorRand()*1000+Vector(0,0,1000)) end end)
			end
		end
	},
	{ -- g a s
		col=Color(128,255,128),
		func=function(self,pos,owner)
			JMod_Sploom(owner,pos,10)
			for i=1,200 do
				timer.Simple(math.Rand(0,1),function()
					local Nade=ents.Create("ent_jack_gmod_ezgasparticle")
					Nade:SetPos(pos)
					Nade.Owner=owner
					Nade:Spawn()
					timer.Simple(0,function()
						Nade:GetPhysicsObject():SetVelocity(VectorRand()*math.random(1,200))
					end)
				end)
			end
		end
	},
	{ -- MINES! FOR EVERYONE!
		col=Color(50,100,0),
		func=function(self,pos,owner)
			JMod_Sploom(owner,pos,1)
			for i=1,30 do
				local Nade=ents.Create("ent_jack_gmod_ezlandmine")
				Nade:SetPos(pos)
				Nade.Owner=owner
				Nade:Spawn()
				timer.Simple(0,function()
					Nade:GetPhysicsObject():SetVelocity(VectorRand()*math.Rand(10,2000))
					timer.Simple(math.Rand(0,4),function()
						if(IsValid(Nade))then Nade:Arm() end
					end)
				end)
			end
		end
	},
	{ -- FRAGS! FOR EVERYONE!
		col=Color(50,100,0),
		func=function(self,pos,owner)
			JMod_Sploom(owner,pos,1)
			for i=1,10 do
				local Nade=ents.Create("ent_jack_gmod_ezfragnade")
				Nade:SetPos(pos)
				Nade.Owner=owner
				Nade:Spawn()
				timer.Simple(0,function()
					Nade:GetPhysicsObject():SetVelocity(VectorRand()*math.Rand(10,1000))
					Nade.FuzeTimeOverride=math.Rand(2,6)
					Nade:Arm()
				end)
			end
		end
	},
	{ -- davy crocket
		col=Color(200,0,0),
		func=function(self,pos,owner)
			JMod_Sploom(owner,pos,10)
			local Whoah=ents.Create("ent_jack_gmod_eznuke_small")
			Whoah:SetPos(pos)
			Whoah.Owner=owner
			Whoah:Spawn()
			timer.Simple(0,function()
				Whoah:Detonate()
			end)
		end
	},
	{ -- SUCC
		col=Color(0,0,0),
		func=function(self,pos,owner)
			JMod_Sploom(owner,pos,10)
			local Whoah=ents.Create("ent_jack_gmod_ezblackhole")
			Whoah:SetPos(pos)
			Whoah.Owner=owner
			Whoah:Spawn()
		end
	},
	{ -- tsar bomba
		col=Color(150,0,0),
		func=function(self,pos,owner)
			JMod_Sploom(owner,pos,10)
			local Whoah=ents.Create("ent_jack_gmod_eznuke_big")
			Whoah:SetPos(pos)
			Whoah.Owner=self.Owner
			Whoah:Spawn()
			timer.Simple(0,function()
				Whoah:Detonate()
			end)
		end
	},
	{ -- T H E   B I G   O O F
		col=Color(10,10,10),
		func=function(self,pos,owner)
			self:PoofEffect()
			for k,v in pairs(player.GetAll())do
				v:KillSilent()
			end
			timer.Simple(0,function()
				game.CleanUpMap()
				timer.Simple(0,function()
					net.Start("JMod_SFX")
					net.WriteString("snds_jack_gmod/oof.wav")
					net.Broadcast()
					for k,v in pairs(player.GetAll())do
						v:ScreenFade(SCREENFADE.IN,Color(255,255,255,255),1,0)
					end
				end)
			end)
		end
	}
}
if(SERVER)then
	function ENT:Arm()
		self:SetBodygroup(2,1)
		self:SetState(JMOD_EZ_STATE_ARMED)
		self:SpoonEffect()
		timer.Simple(5,function()
			if(IsValid(self))then self:Detonate() end
		end)
	end
	function ENT:SpoonEffect()
		if self.SpoonEnt then
			local Spewn=ents.Create(self.SpoonEnt)
			if self.SpoonModel then Spewn.Model = self.SpoonModel end
			if self.SpoonScale then Spewn.ModelScale = self.SpoonScale end
			if self.SpoonSound then Spewn.Sound = self.SpoonSound end
			Spewn:SetPos(self:GetPos())
			Spewn:Spawn()
			Spewn:SetMaterial(self.Material)
			Spewn:SetColor(self:GetColor())
			Spewn:GetPhysicsObject():SetVelocity(self:GetPhysicsObject():GetVelocity()+VectorRand()*250)
			self:EmitSound("snd_jack_spoonfling.wav",60,math.random(80,100))
		end
	end
	function ENT:CustomThink(state,tim)
		if not(self.CurEff)then -- that means we just spawned
			self.CurEff=math.random(1,#self.DetonationEffects)
			self:SetColor(self.DetonationEffects[self.CurEff].col)
			self.NextEffSwitch=tim+1
		elseif(self.NextEffSwitch<tim)then
			self.NextEffSwitch=tim+1
			self.CurEff=self.CurEff+1
			if(self.CurEff>#self.DetonationEffects)then self.CurEff=1 end
			self:SetColor(self.DetonationEffects[self.CurEff].col)
		end
	end
	function ENT:Detonate()
		self.CurEff=6 -- DEBUG
		local pos=self:GetPos()+Vector(0,0,10)
		self.DetonationEffects[self.CurEff].func(self,pos,self.Owner or self:GetOwner() or game.GetWorld())
		self:Remove()
	end
	function ENT:PoofEffect(pos,scl)
		local eff=EffectData()
		eff:SetOrigin((pos or self:GetPos())+VectorRand())
		eff:SetScale(scl or .5)
		util.Effect("eff_jack_gmod_ezbuildsmoke",eff,true,true)
	end
elseif(CLIENT)then
	function ENT:Draw()
		self:DrawModel()
	end
	language.Add("ent_jack_gmod_ezanomaly","T H E  G R E N A D E")
end