AddCSLuaFile()
ENT.Type="anim"
ENT.Base="base_anim"
ENT.PrintName="Fire Hazard"
ENT.KillName="Fire Hazard"
ENT.NoSitAllowed=true
ENT.IsRemoteKiller=true
local ThinkRate=22--Hz
if(SERVER)then
	function ENT:Initialize()
		self.Ptype=1
		self.TypeInfo={
			"Napalm",
			{
				Sound("snds_jack_gmod/fire1.wav"),
				Sound("snds_jack_gmod/fire2.wav")
			},
			"eff_jack_gmod_heavyfire",
			20,
			30,
			100
		}
		----
		self.Entity:SetMoveType(MOVETYPE_NONE)
		self.Entity:DrawShadow(false)
		self.Entity:SetCollisionBounds( Vector( -20, -20, -10 ), Vector( 20, 20, 10 ) )
		self.Entity:PhysicsInitBox( Vector( -20, -20, -10 ), Vector( 20, 20, 10 ) )
		local phys=self.Entity:GetPhysicsObject()
		if(IsValid(phys))then phys:EnableCollisions(false) end
		self.Entity:SetNotSolid(true)
		local Time=CurTime()
		self.NextFizz=0
		self.DamageMul=(self.DamageMul or 1)*math.Rand(.9,1.1)
		self.DieTime=Time+math.Rand(self.TypeInfo[4],self.TypeInfo[5])
		self.NextSound=0
		self.NextEffect=0
		self.Range=self.TypeInfo[6]
		self.Power=3
	end
	local function Inflictor(ent)
		if not(IsValid(ent))then return game.GetWorld() end
		local Infl=ent:GetDTEntity(0)
		if(IsValid(Infl))then return Infl end
		return ent
	end
	function ENT:Think()
		local Time,Pos,Dir=CurTime(),self:GetPos(),self:GetForward()
		--print(self:WaterLevel())
		if(self.NextFizz<Time)then
			self.NextFizz=Time+.5
			if(math.random(1,2)==2 or self.HighVisuals)then
				local Zap=EffectData()
				Zap:SetOrigin(Pos)
				Zap:SetStart(self:GetVelocity())
				util.Effect(self.TypeInfo[3],Zap,true,true)
			end
		end
		if(self.NextSound<Time)then
			self.NextSound=Time+1
			self:EmitSound(table.Random(self.TypeInfo[2]),65,math.random(90,110))
		end
		if(self.NextEffect<Time)then
			self.NextEffect=Time+1
			local Par,Att,Infl=self:GetParent(),self.Owner or self,Inflictor(self)
			if not(IsValid(Att))then Att=Infl end
			if((IsValid(Par))and(Par:IsPlayer())and not(Par:Alive()))then self:Remove() return end
			for k,v in pairs(ents.FindInSphere(Pos,self.Range))do
				local Class=v:GetClass()
				if not(Class=="ent_jack_gmod_ezfirehazard")then
					if((IsValid(v:GetPhysicsObject()))and(self:Visible(v)))then
						local Dam=DamageInfo()
						Dam:SetDamage(self.Power*math.Rand(.75,1.25))
						Dam:SetDamageType(DMG_BURN)
						Dam:SetDamagePosition(Pos)
						Dam:SetAttacker(Att)
						Dam:SetInflictor(Infl)
						v:TakeDamageInfo(Dam)
						if(math.random(1,30)==5)then v:Ignite(10) end
					end
				end
			end
			if(math.random(1,3)==1)then
				local Tr=util.QuickTrace(Pos,VectorRand()*self.Range,{self})
				if(Tr.Hit)then util.Decal("Scorch",Tr.HitPos+Tr.HitNormal,Tr.HitPos-Tr.HitNormal) end
			end
		end
		if(IsValid(self))then
			if(self.DieTime<Time)then self:Remove() return end
			self:NextThink(Time+(1/ThinkRate))
		end
		return true
	end
elseif(CLIENT)then
	function ENT:Initialize()
		self.Ptype=1
		self.TypeInfo={
			"Napalm",
			{
				Sound("snds_jack_gmod/fire1.wav"),
				Sound("snds_jack_gmod/fire2.wav")
			},
			"eff_jack_gmod_heavyfire",
			15,
			14,
			100
		}
		self.CastLight=math.random(1,10)==1
		self.Size=self.TypeInfo[6]
		--self.FlameSprite=Material("mats_jack_halo_sprites/flamelet"..math.random(1,5))
	end
	local GlowSprite=Material("mat_jack_gmod_glowsprite")
	function ENT:Draw()
		local Time,Pos=CurTime(),self:GetPos()
		render.SetMaterial(GlowSprite)
		render.DrawSprite(Pos+VectorRand()*self.Size*math.Rand(0,.25),self.Size*math.Rand(.75,1.25),self.Size*math.Rand(.75,1.25),Color(255,255,255,255))
		if((self.CastLight)and not(GAMEMODE.Lagging))then
			local dlight=DynamicLight(self:EntIndex())
			if(dlight)then
				dlight.pos=Pos
				dlight.r=255
				dlight.g=175
				dlight.b=100
				dlight.brightness=3
				dlight.Decay=200
				dlight.Size=400
				dlight.DieTime=CurTime()+.5
			end
		end
	end
end