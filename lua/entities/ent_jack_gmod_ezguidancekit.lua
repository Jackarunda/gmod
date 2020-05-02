-- Jackarunda 2019
AddCSLuaFile()
ENT.Type="anim"
ENT.Author="Jackarunda"
ENT.Category="JMod - EZ Misc."
ENT.Information="glhfggwpezpznore"
ENT.PrintName="EZ Bomb Guidance Kit"
ENT.NoSitAllowed=true
ENT.Spawnable=false -- todo: guidance code
ENT.AdminSpawnable=false
---
ENT.JModPreferredCarryAngles=Angle(0,180,0)
ENT.JModEZstorable=true
---
if(SERVER)then
	function ENT:SpawnFunction(ply,tr)
		local SpawnPos=tr.HitPos+tr.HitNormal*15
		local ent=ents.Create(self.ClassName)
		ent:SetAngles(Angle(0,0,0))
		ent:SetPos(SpawnPos)
		JMod_Owner(ent,ply)
		ent:Spawn()
		ent:Activate()
		--local effectdata=EffectData()
		--effectdata:SetEntity(ent)
		--util.Effect("propspawn",effectdata)
		return ent
	end
	function ENT:Initialize()
		self:SetModel("models/kali/props/cases/hard case b.mdl")
		self:SetModelScale(.4,0)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)	
		self:SetSolid(SOLID_VPHYSICS)
		self:DrawShadow(true)
		self:SetUseType(SIMPLE_USE)
		---
		timer.Simple(.01,function()
			self:GetPhysicsObject():SetMass(40)
			self:GetPhysicsObject():Wake()
		end)
	end
	function ENT:PhysicsCollide(data,physobj)
		if(data.DeltaTime>0.2 and data.Speed>25)then
			self:EmitSound("DryWall.ImpactHard")
		end
		if((data.HitEntity.EZguidable)and not(data.HitEntity:GetGuided())and(self:IsPlayerHolding()))then
			self:EmitSound("snd_jack_metallicload.wav",60,math.random(90,110))
			for i=1,5 do
				self:EmitSound("snds_jack_gmod/ez_tools/"..math.random(1,27)..".wav",60,math.random(90,110))
			end
			data.HitEntity:SetGuided(true)
			self:Remove()
		end
	end
	function ENT:OnTakeDamage(dmginfo)
		if(self.Exploded)then return end
		if(dmginfo:GetInflictor()==self)then return end
		self:TakePhysicsDamage(dmginfo)
		if(dmginfo:GetDamage()>100)then sound.Play("Metal_Box.Break",self:GetPos());self:Remove() end
	end
	function ENT:Use(activator,activatorAgain,onOff)
		local Dude=activator or activatorAgain
		JMod_Owner(self,Dude)
		
		Dude:PickupObject(self)
	end
elseif(CLIENT)then
	local TxtCol=Color(255,255,255,80)
	function ENT:Draw()
		local Ang,Pos=self:GetAngles(),self:GetPos()
		local Closeness=LocalPlayer():GetFOV()*(EyePos():Distance(Pos))
		local DetailDraw=Closeness<18000 -- cutoff point is 200 units when the fov is 90 degrees
		self:DrawModel()
		if(DetailDraw)then
			local Up,Right,Forward=Ang:Up(),Ang:Right(),Ang:Forward()
			Ang:RotateAroundAxis(Ang:Right(),90)
			Ang:RotateAroundAxis(Ang:Forward(),180)
			Ang:RotateAroundAxis(Ang:Up(),-90)
			cam.Start3D2D(Pos+Forward*2.6+Up*9,Ang,.02)
			draw.SimpleText("JACKARUNDA INDUSTRIES","JMod-Stencil",0,0,TxtCol,TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
			draw.SimpleText("EZ BOMB GUIDANCE KIT","JMod-Stencil",0,50,TxtCol,TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
			cam.End3D2D()
		end
	end
	language.Add("ent_jack_gmod_ezguidancekit","EZ Bomb Guidance Kit")
end