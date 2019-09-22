-- Jackarunda 2019
AddCSLuaFile()
ENT.Type="anim"
ENT.PrintName="EZ Manufacturer"
ENT.Author="Jackarunda"
ENT.Category="JMod - EZ"
ENT.Information="glhfggwpezpznore"
ENT.Spawnable=false
ENT.AdminSpawnable=false
ENT.RenderGroup=RENDERGROUP_TRANSLUCENT
ENT.EZconsumes={"power","parts","medsupplies"}
ENT.EZbuildCost=JMod_EZbuildCostAFH
ENT.PropModels={"models/props_lab/reciever01d.mdl","models/props/cs_office/computer_caseb_p2a.mdl","models/props/cs_office/computer_caseb_p3a.mdl","models/props/cs_office/computer_caseb_p4a.mdl","models/props/cs_office/computer_caseb_p5a.mdl","models/props/cs_office/computer_caseb_p5b.mdl","models/props/cs_office/computer_caseb_p6a.mdl","models/props/cs_office/computer_caseb_p6b.mdl","models/props/cs_office/computer_caseb_p7a.mdl","models/props/cs_office/computer_caseb_p8a.mdl","models/props/cs_office/computer_caseb_p9a.mdl"}
----
local STATE_BROKEN,STATE_OFF,STATE_ON,STATE_WORKING=-1,0,1,2,3
function ENT:SetupDataTables()
	self:NetworkVar("Int",0,"State")
	self:NetworkVar("Float",0,"Electricity")
	self:NetworkVar("Int",1,"Supplies")
end
if(SERVER)then
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
		self.Entity:SetModel("models/props_mining/antlion_detector.mdl")
		self.Entity:SetModelScale(1.5,0)
		self.Entity:PhysicsInit(SOLID_VPHYSICS)
		self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
		self.Entity:SetSolid(SOLID_VPHYSICS)
		self.Entity:DrawShadow(true)
		self:SetUseType(SIMPLE_USE)
		local phys=self.Entity:GetPhysicsObject()
		if phys:IsValid() then
			phys:Wake()
			phys:SetMass(750)
			phys:SetBuoyancyRatio(.3)
		end
		---
		if(IsValid(self.Owner))then
			local Tem=self.Owner:Team()
			if(Tem)then
				local Col=team.GetColor(Tem)
				--if(Col)then self:SetColor(Col) end
			end
		end
		---
		self.MaxElectricity=100
		self.MaxDurability=100
		self.MaxSupplies=100
		---
		self:SetElectricity(self.MaxElectricity)
		self.Durability=self.MaxDurability
		self.NextWhine=0
		self.NextRealThink=0
		self.NextUseTime=0
		self.IdleShutOffTime=0
		self.NextHumTime=0
		self:SetState(STATE_OFF)
		self:SetElectricity(self.MaxElectricity)
		self:SetSupplies(self.MaxSupplies)
		self.NextHeal=0
		self.NextEnter=0
		---
		local Ang=self:GetAngles()
		Ang:RotateAroundAxis(Ang:Right(),90)
		self.IntakeChute=ents.Create("prop_physics")
		self.IntakeChute:SetModel("models/props_phx/construct/metal_tubex2.mdl")
		self.IntakeChute:SetModelScale(.8,0)
		self.IntakeChute:SetPos(self:GetPos()+self:GetUp()*30)
		self.IntakeChute:SetAngles(Ang)
		self.IntakeChute:Spawn()
		self.IntakeChute:Activate()
		timer.Simple(0,function() self.IntakeChuteWeld=constraint.Weld(self,self.IntakeChute,1,1,0,true,true) end)
	end
	function ENT:PhysicsCollide(data,physobj)
		if((data.Speed>80)and(data.DeltaTime>0.2))then
			self.Entity:EmitSound("Metal_Box.ImpactHard")
			if(data.Speed>1000)then
				local Dam,World=DamageInfo(),game.GetWorld()
				Dam:SetDamage(data.Speed/3)
				Dam:SetAttacker(data.HitEntity or World)
				Dam:SetInflictor(data.HitEntity or World)
				Dam:SetDamageType(DMG_CRUSH)
				Dam:SetDamagePosition(data.HitPos)
				Dam:SetDamageForce(data.TheirOldVelocity)
				self:DamageSpark()
				self:TakeDamageInfo(Dam)
			end
		end
	end
	function ENT:ConsumeElectricity(amt)
		amt=(amt or .2)/self.ElectricalEfficiency
		local NewAmt=math.Clamp(self:GetElectricity()-amt,0,self.MaxElectricity)
		self:SetElectricity(NewAmt)
		if(NewAmt<=0)then self:TurnOff() end
	end
	function ENT:DamageSpark()
		local effectdata=EffectData()
		effectdata:SetOrigin(self:GetPos()+self:GetUp()*50+VectorRand()*math.random(0,30))
		effectdata:SetNormal(VectorRand())
		effectdata:SetMagnitude(math.Rand(2,4)) --amount and shoot hardness
		effectdata:SetScale(math.Rand(.5,1.5)) --length of strands
		effectdata:SetRadius(math.Rand(2,4)) --thickness of strands
		util.Effect("Sparks",effectdata,true,true)
		self:EmitSound("snd_jack_turretfizzle.wav",70,100)
		self:ConsumeElectricity(1)
	end
	function ENT:OnTakeDamage(dmginfo)
		if(self)then
			self:TakePhysicsDamage(dmginfo)
			self.Durability=self.Durability-dmginfo:GetDamage()/2
			if(self.Durability<=0)then self:Break(dmginfo) end
			if(self.Durability<=-100)then self:Destroy(dmginfo) end
		end
	end
	function ENT:FlingProp(mdl,force)
		local Prop=ents.Create("prop_physics")
		Prop:SetPos(self:GetPos()+self:GetUp()*25+VectorRand()*math.Rand(1,25))
		Prop:SetAngles(VectorRand():Angle())
		Prop:SetModel(mdl)
		Prop:Spawn()
		Prop:Activate()
		Prop:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
		constraint.NoCollide(Prop,self)
		local Phys=Prop:GetPhysicsObject()
		Phys:SetVelocity(self:GetPhysicsObject():GetVelocity()+VectorRand()*math.Rand(1,300)+self:GetUp()*100)
		Phys:AddAngleVelocity(VectorRand()*math.Rand(1,10000))
		if(force)then Phys:ApplyForceCenter(force/7) end
		SafeRemoveEntityDelayed(Prop,math.random(20,40))
	end
	function ENT:Break(dmginfo)
		if(self:GetState()==STATE_BROKEN)then return end
		self:EmitSound("snd_jack_turretbreak.wav",70,math.random(80,120))
		for i=1,20 do self:DamageSpark() end
		self.Durability=0
		self:SetState(STATE_BROKEN)
		local Force=dmginfo:GetDamageForce()
		for i=1,12 do
			self:FlingProp(table.Random(self.PropModels),Force)
		end
		if(IsValid(self.Pod:GetDriver()))then
			self.Pod:GetDriver():ExitVehicle()
		end
		self.Pod:Fire("lock","",0)
	end
	function ENT:Destroy(dmginfo)
		self:EmitSound("snd_jack_turretbreak.wav",70,math.random(80,120))
		for i=1,20 do self:DamageSpark() end
		local Force=dmginfo:GetDamageForce()
		for i=1,20 do
			self:FlingProp(table.Random(self.PropModels),Force)
			self:FlingProp("models/props_c17/oildrumchunk01d.mdl",Force)
			self:FlingProp("models/props_c17/oildrumchunk01e.mdl",Force)
			self:FlingProp(table.Random(self.PropModels),Force)
		end
		if(IsValid(self.Pod:GetDriver()))then
			self.Pod:GetDriver():ExitVehicle()
		end
		self:Remove()
	end
	function ENT:Use(activator)
		local State=self:GetState()
		if(State==STATE_BROKEN)then return end
		if(State==STATE_OFF)then
			self:TurnOn()
		elseif(State==STATE_ON)then
			self:TurnOff()
		end
	end
	function ENT:TurnOn()
		if(self:GetState()==STATE_ON)then return end
		if(self:GetElectricity()<=0)then return end
		local Time=CurTime()
		self:SetState(STATE_ON)
		self:SFX("afh_startup")
		self.IdleShutOffTime=Time+5
		self.NextHumTime=Time+4
		self.Pod:Fire("unlock","",1.4)
		self.NextEnter=Time+1.6
		self:ConsumeElectricity()
	end
	function ENT:TurnOff()
		if(self:GetState()==STATE_OFF)then return end
		self:SetState(STATE_OFF)
		self:SFX("afh_shutdown")
		self.Patient=nil
		if(IsValid(self.Pod:GetDriver()))then
			self.Pod:GetDriver():ExitVehicle()
		end
		self.Pod:Fire("lock","",0)
	end
	function ENT:Think()
		local State,Time,Electricity=self:GetState(),CurTime(),self:GetElectricity()
		if(self.NextRealThink<Time)then
			self.NextRealThink=Time+.5
			--
		end
		self:NextThink(Time+.1)
		return true
	end
	function ENT:Whine(serious)
		local Time=CurTime()
		if(self.NextWhine<Time)then
			self.NextWhine=Time+4
			self:EmitSound("snds_jack_gmod/ezsentry_whine.wav",70,100)
			self:ConsumeElectricity(.05)
		end
	end
	function ENT:OnRemove()
		--
	end
	function ENT:EZsalvage()
		if(self.Salvaged)then return end
		self.Salvaged=true
		local scale,pos=2,self:GetPos()+self:GetUp()*20
		---
		local effectdata=EffectData()
		effectdata:SetOrigin(pos+VectorRand())
		effectdata:SetNormal((VectorRand()+Vector(0,0,1)):GetNormalized())
		effectdata:SetMagnitude(math.Rand(1,2)*scale*4) --amount and shoot hardness
		effectdata:SetScale(math.Rand(.5,1.5)*scale*4) --length of strands
		effectdata:SetRadius(math.Rand(2,4)*scale*4) --thickness of strands
		util.Effect("Sparks",effectdata,true,true)
		---
		sound.Play("snds_jack_gmod/ez_tools/hit.wav",pos+VectorRand(),60,math.random(80,120))
		sound.Play("snds_jack_gmod/ez_tools/"..math.random(1,27)..".wav",pos,60,math.random(80,120))
		---
		local eff=EffectData()
		eff:SetOrigin(pos+VectorRand())
		eff:SetScale(scale)
		util.Effect("eff_jack_gmod_ezbuildsmoke",eff,true,true)
		---
		for i=1,20 do
			timer.Simple(i/100,function()
				if(IsValid(self))then
					if(i<20)then
						sound.Play("snds_jack_gmod/ez_tools/"..math.random(1,27)..".wav",pos,60,math.random(80,120))
					else
						local PartsFrac=(self.Durability+self.MaxDurability)/(self.MaxDurability*2)
						local Box=ents.Create("ent_jack_gmod_ezparts")
						Box:SetPos(pos+VectorRand()*10)
						Box:Spawn()
						Box:Activate()
						Box:SetResource(PartsFrac*self.EZbuildCost.parts*.75)
						local Box2=ents.Create("ent_jack_gmod_ezadvparts")
						Box2:SetPos(pos+VectorRand()*10)
						Box2:Spawn()
						Box2:Activate()
						Box2:SetResource(PartsFrac*self.EZbuildCost.advparts*.75)
						local Supps=self:GetSupplies()
						if(Supps>1)then
							local Box=ents.Create("ent_jack_gmod_ezmedsupplies")
							Box:SetPos(pos+VectorRand()*10)
							Box:Spawn()
							Box:Activate()
							Box:SetResource(math.floor(Supps))
						end
						local Powa=self:GetElectricity()
						if(Powa>1)then
							local Batt=ents.Create("ent_jack_gmod_ezbattery")
							Batt:SetPos(pos+VectorRand()*10)
							Batt:Spawn()
							Batt:Activate()
							Batt:SetResource(math.floor(Powa))
						end
						self:Remove()
					end
				end
			end)
		end
	end
	function ENT:TryLoadResource(typ,amt)
		if(amt<=0)then return 0 end
		if(typ=="power")then
			local Powa=self:GetElectricity()
			local Missing=self.MaxElectricity-Powa
			if(Missing<=0)then return 0 end
			if(Missing<self.MaxElectricity*.1)then return 0 end
			local Accepted=math.min(Missing,amt)
			self:SetElectricity(Powa+Accepted)
			self:EmitSound("snd_jack_turretbatteryload.wav",65,math.random(90,110))
			return math.ceil(Accepted)
		elseif(typ=="medsupplies")then
			local Supps=self:GetSupplies()
			local Missing=self.MaxSupplies-Supps
			if(Missing<=0)then return 0 end
			if(Missing<self.MaxSupplies*.1)then return 0 end
			local Accepted=math.min(Missing,amt)
			self:SetSupplies(Supps+Accepted)
			self:EmitSound("snd_jack_turretbatteryload.wav",65,math.random(90,110)) -- TODO: new sound here
			return math.ceil(Accepted)
		elseif(typ=="parts")then
			local Missing=self.MaxDurability-self.Durability
			if(Missing<=self.MaxDurability*.25)then return 0 end
			local Accepted=math.min(Missing,amt)
			self.Durability=self.Durability+Accepted
			if(self.Durability>=self.MaxDurability)then self:RemoveAllDecals() end
			self:EmitSound("snd_jack_turretrepair.wav",65,math.random(90,110))
			if(self.Durability>0)then
				if(self:GetState()==STATE_BROKEN)then self:SetState(STATE_OFF) end
			end
			return math.ceil(Accepted)
		end
		return 0
	end
elseif(CLIENT)then
	function ENT:Initialize()
		--self.Camera=JMod_MakeModel(self,"models/props_combine/combinecamera001.mdl")
		-- models/props_phx/construct/glass/glass_dome360.mdl
		self.MaxElectricity=100
	end
	local function ColorToVector(col)
		return Vector(col.r/255,col.g/255,col.b/255)
	end
	local DarkSprite=Material("white_square")
	function ENT:DrawTranslucent()
		local SelfPos,SelfAng,State,FT=self:GetPos(),self:GetAngles(),self:GetState(),FrameTime()
		local Up,Right,Forward=SelfAng:Up(),SelfAng:Right(),SelfAng:Forward()
		---
		local BasePos=SelfPos+Up*60
		local Obscured=util.TraceLine({start=EyePos(),endpos=BasePos,filter={LocalPlayer(),self},mask=MASK_OPAQUE}).Hit
		local Closeness=LocalPlayer():GetFOV()*(EyePos():Distance(SelfPos))
		local DetailDraw=Closeness<36000 -- cutoff point is 400 units when the fov is 90 degrees
		if((not(DetailDraw))and(Obscured))then return end -- if player is far and sentry is obscured, draw nothing
		if(Obscured)then DetailDraw=false end -- if obscured, at least disable details
		if(State==STATE_BROKEN)then DetailDraw=false end -- look incomplete to indicate damage, save on gpu comp too
		---
		self:DrawModel()
		local Col=Color(0,0,0,50)
		render.SetMaterial(DarkSprite)
		for i=1,30 do
			render.DrawQuadEasy(BasePos+Up*(i*1.3-5),Up,38,38,Col)
		end
		--[[
		local CamAng=SelfAng:GetCopy()
		--CamAng:RotateAroundAxis(Up,-90)
		--CamAng:RotateAroundAxis(Right,180)
		--JMod_RenderModel(self.Camera,BasePos+Up*10+Forward*25,CamAng,nil,GradeColors[Grade],GradeMats[Grade])
		
		local Matricks=Matrix()
		Matricks:Scale(Vector(.4,1.45,.5))
		self.BottomCanopy:EnableMatrix("RenderMultiply",Matricks)
		local BottomCanopyAng=SelfAng:GetCopy()
		BottomCanopyAng:RotateAroundAxis(Right,180)
		JMod_RenderModel(self.BottomCanopy,BasePos-Up*17+Right*2,BottomCanopyAng)
		
		local Opacity=math.random(50,200)
		cam.Start3D2D(BasePos+Up*22+Right*22+Forward*21,DisplayAng,.08)
		draw.SimpleTextOutlined("POWER "..math.Round(self:GetElectricity()/self.MaxElectricity*100).."%","JMod-Display",0,0,Color(255,255,255,Opacity),TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP,3,Color(0,0,0,Opacity))
		draw.SimpleTextOutlined("SUPPLIES "..self:GetSupplies().."/"..self.MaxSupplies*EZ_GRADE_BUFFS[Grade],"JMod-Display",0,40,Color(255,255,255,Opacity),TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP,3,Color(0,0,0,Opacity))
		cam.End3D2D()
		--]]
	end
	language.Add("ent_jack_gmod_ezfieldhospital","EZ Automated Field Hospital")
end