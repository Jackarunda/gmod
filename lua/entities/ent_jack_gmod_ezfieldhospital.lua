-- Jackarunda 2019
AddCSLuaFile()
ENT.Type="anim"
ENT.PrintName="EZ Automated Field Hospital"
ENT.Author="Jackarunda"
ENT.Category="JMod - EZ Misc."
ENT.Information="glhfggwpezpznore"
ENT.Spawnable=true
ENT.AdminSpawnable=true
ENT.EZconsumes={"power","parts","medsupplies"}
ENT.EZupgrades={
	rate=2,
	grades={
		{parts=20,advparts=40},
		{parts=40,advparts=80},
		{parts=60,advparts=160},
		{parts=80,advparts=320}
	}
}
ENT.PropModels={"models/props_lab/reciever01d.mdl","models/props/cs_office/computer_caseb_p2a.mdl","models/props/cs_office/computer_caseb_p3a.mdl","models/props/cs_office/computer_caseb_p4a.mdl","models/props/cs_office/computer_caseb_p5a.mdl","models/props/cs_office/computer_caseb_p5b.mdl","models/props/cs_office/computer_caseb_p6a.mdl","models/props/cs_office/computer_caseb_p6b.mdl","models/props/cs_office/computer_caseb_p7a.mdl","models/props/cs_office/computer_caseb_p8a.mdl","models/props/cs_office/computer_caseb_p9a.mdl"}
-- config --
ENT.StaticPerfSpecs={
	MaxElectricity=100,
	MaxDurability=100
}
ENT.DynamicPerfSpecs={
	MaxSupplies=50,
	ElectricalEfficiency=1,
	HealEfficiency=1,
	HealSpeed=1
}
----
function ENT:InitPerfSpecs()
	local Grade=self:GetGrade()
	for specName,value in pairs(self.StaticPerfSpecs)do self[specName]=value end
	for specName,value in pairs(self.DynamicPerfSpecs)do self[specName]=math.ceil(value*EZ_GRADE_BUFFS[Grade]) end
end
function ENT:Upgrade(level)
	if not(level)then level=self:GetGrade()+1 end
	if(level>5)then return end
	self:SetGrade(level)
	self:InitPerfSpecs()
	self.UpgradeProgress={}
end
local STATE_BROKEN,STATE_OFF,STATE_ON,STATE_OCCUPIED,STATE_WORKING=-1,0,1,2,3
function ENT:SetupDataTables()
	self:NetworkVar("Int",0,"State")
	self:NetworkVar("Float",0,"Electricity")
	self:NetworkVar("Int",1,"Supplies")
	self:NetworkVar("Int",2,"Grade")
end
if(SERVER)then
	function ENT:SpawnFunction(ply,tr)
		local SpawnPos=tr.HitPos+tr.HitNormal*20
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
		self.Entity:SetModel("models/mri-scanner/mri-scanner.mdl")
		self.Entity:PhysicsInit(SOLID_VPHYSICS)
		self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
		self.Entity:SetSolid(SOLID_VPHYSICS)
		self.Entity:DrawShadow(true)
		self:SetUseType(SIMPLE_USE)
		local phys=self.Entity:GetPhysicsObject()
		if phys:IsValid()then
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
		self:SetGrade(EZ_GRADE_BASIC)
		self:InitPerfSpecs()
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
		self.UpgradeProgress={}
		self.EZbuildCost=JMOD_CONFIG.Blueprints["EZ Automated Field Hospital"][2]
		--
		self.Pod=ents.Create("prop_vehicle_prisoner_pod")
		self.Pod:SetModel("models/vehicles/prisoner_pod_inner.mdl")
		local Ang,Up,Right,Forward=self:GetAngles(),self:GetUp(),self:GetRight(),self:GetForward()
		self.Pod:SetPos(self:GetPos()+Up*52+Right*45)
		Ang:RotateAroundAxis(Up,-90)
		Ang:RotateAroundAxis(Forward,-85)
		self.Pod:SetAngles(Ang)
		self.Pod:Spawn()
		self.Pod:Activate()
		self.Pod:SetParent(self)
		self.Pod:SetNoDraw(true)
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
		amt=((amt or .2)/self.ElectricalEfficiency^.5)/2
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
		constraint.NoCollide(Prop,self,0,0)
		local Phys=Prop:GetPhysicsObject()
		Phys:SetVelocity(self:GetPhysicsObject():GetVelocity()+VectorRand()*math.Rand(1,300)+self:GetUp()*100)
		Phys:AddAngleVelocity(VectorRand()*math.Rand(1,10000))
		if(force)then Phys:ApplyForceCenter(force/7) end
		SafeRemoveEntityDelayed(Prop,math.random(10,20))
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
		if(State==STATE_BROKEN)then  return end
		if(State==STATE_OFF)then
			
            if self:GetElectricity() > 0 then self:TurnOn() JMod_Hint(activator, "afh enter", self)
            else JMod_Hint(activator, "nopower", self)  end
		elseif(State==STATE_ON)then
			if not(IsValid(self.Pod:GetDriver()))then
				if(self.NextEnter<CurTime())then
					self.Pod.EZvehicleEjectPos=self.Pod:WorldToLocal(activator:GetPos())
					activator:EnterVehicle(self.Pod)
                    JMod_Hint(activator, "afh upgrade")
				end
			end
		end
	end
	function ENT:SFX(str,absPath)
		if(absPath)then
			sound.Play(str,self:GetPos()+Vector(0,0,20)+VectorRand()*10,60,math.random(90,110))
		else
			sound.Play("snds_jack_gmod/"..str..".wav",self:GetPos()+Vector(0,0,20)+VectorRand()*10,60,100)
		end
	end
	function ENT:TurnOn()
		if(self:GetState()==STATE_ON)then return end
		if(self:GetElectricity()<=0)then JMod_Hint(activator, "nopower", self) return end
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
	function ENT:Seal()
		self:SetState(STATE_OCCUPIED)
		self:SFX("afh_seal")
		self.Patient=self.Pod:GetDriver()
		self.NextHeal=CurTime()+3
		self:ConsumeElectricity()
	end
	function ENT:Unseal()
		self:SetState(STATE_ON)
		self:SFX("afh_unseal")
		self.Patient=nil
		self:ConsumeElectricity()
	end
	function ENT:TryStartOperation()
		if not(IsValid(self.Patient))then return end
		---
		local override = hook.Run("JMod_CanFieldHospitalStart",self,self.Patient)
		if override==false then return end
		if override~=true then
			local Helf,Max,Rads=self.Patient:Health(),self.Patient:GetMaxHealth(),self.Patient.EZirradiated or 0
			if((Helf>=Max)and(Rads<=0))then return end -- you're not hurt lol gtfo
			if(self:GetSupplies()<=0)then return end
		end
		self:SetState(STATE_WORKING)
		self:SFX("afh_spoolup")
		self:ConsumeElectricity()
	end
	function ENT:EndOperation(success)
		self:SetState(STATE_OCCUPIED)
		if(success)then
			self:SFX("ding")
		else
			self:Whine()
		end
		self:ConsumeElectricity()
	end
	function ENT:Think()
		local State,Time,Electricity=self:GetState(),CurTime(),self:GetElectricity()
		if(self.NextRealThink<Time)then
			if not(IsValid(self.Pod))then self:Remove();return end
			self.NextRealThink=Time+.15
			if(State==STATE_ON)then
				if(IsValid(self.Pod:GetDriver()))then
					self:Seal()
				else
					if(self.IdleShutOffTime<Time)then
						self:TurnOff()
						return
					end
				end
			elseif(State==STATE_OCCUPIED)then
				if(IsValid(self.Pod:GetDriver()))then
					self:TryStartOperation()
				else
					self:Unseal()
				end
				self.IdleShutOffTime=Time+5
			elseif(State==STATE_WORKING)then
				if(IsValid(self.Pod:GetDriver()))then
					self:TryHeal()
				else
					self:Unseal()
				end
				self.IdleShutOffTime=Time+5
			end
		end
		if(State>0)then
			if(self.NextHumTime<Time)then
				self.NextHumTime=Time+3
				self:SFX("afh_run")
				self:ConsumeElectricity()
			end
			if(Electricity<self.MaxElectricity*.1)then self:Whine() end
			if(self:GetSupplies()<=self.MaxSupplies*.1)then self:Whine() end
			if(Electricity<=0)then self:TurnOff() end
		end
		self:NextThink(Time+.1)
		return true
	end
	function ENT:TryHeal()
		local Time=CurTime()
		if(self.NextHeal>Time)then return end
		self.NextHeal=Time+1/self.HealSpeed^2.75
		local Helf,Max,Supplies=self.Patient:Health(),self.Patient:GetMaxHealth(),self:GetSupplies()
		if(Supplies<=0)then
            if IsValid(self.Patient) then JMod_Hint(self.Patient, "afh supply") end
			self:EndOperation(false)
			return
		end
		---
		local override = hook.Run("JMod_FieldHospitalHeal", self, self.Patient)
		if override == false then return end
		---
		local Injury,Rads=Max-Helf,self.Patient.EZirradiated or 0
		if((Injury>0)or(Rads>0))then
			if(Rads>0)then
				self.Patient.EZirradiated=math.Clamp(Rads-self.HealEfficiency*JMOD_CONFIG.MedBayHealMult*5,0,9e9)
				self:HealEffect("hl1/ambience/steamburst1.wav",true)
			else
				local HealAmt=isnumber(override) and math.min(Injury,override) or math.min(Injury,math.ceil(3*self.HealEfficiency*JMOD_CONFIG.MedBayHealMult))
				self.Patient:SetHealth(Helf+HealAmt)
				self:HealEffect()
			end
			self:ConsumeElectricity(2)
			if(math.random(1,2)==1)then self:SetSupplies(Supplies-1) end
		else
			self:EndOperation(true)
		end
	end

	function ENT:HealEffect(snd,noBlood)
		if(snd)then
			self:SFX(snd,true)
		else
			for i=1,math.random(1,2) do
				timer.Simple(math.Rand(.01,.5),function()
					if(IsValid(self))then self:SFX("ez_robotics/"..math.random(1,42)) end
				end)
				timer.Simple(math.Rand(.01,.5),function()
					if(IsValid(self))then self:SFX("ez_medical/"..math.random(1,27)) end
				end)
			end
		end
		for i=1,math.random(2,4) do
			timer.Simple(math.Rand(.01,1),function()
				if(IsValid(self))then
					local Pos=self:GetPos()+self:GetRight()*math.random(-40,50)+self:GetUp()*math.random(48,52)+self:GetForward()*math.random(-5,5)
					local Poof=EffectData()
					Poof:SetOrigin(Pos+VectorRand()*5)
					util.Effect("eff_jack_Gmod_ezhealpoof",Poof,true,true)
					if((math.random(1,2)==1)and not(noBlood))then
						local Blud=EffectData()
						Blud:SetOrigin(Pos+VectorRand()*5)
						util.Effect("BloodImpact",Blud,true,true)
					end
				end
			end)
		end
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
		self:InitPerfSpecs()
		---
		self.Camera=JMod_MakeModel(self,"models/props_combine/combinecamera001.mdl")
		self.TopCanopy=JMod_MakeModel(self,"models/props_phx/construct/windows/window_dome360.mdl")
		self.BottomCanopy=JMod_MakeModel(self,"models/props_phx/construct/windows/window_dome360.mdl")
		-- models/props_phx/construct/glass/glass_dome360.mdl
		self.MaxElectricity=100
		self.OpenAmt=1
	end
	local function ColorToVector(col)
		return Vector(col.r/255,col.g/255,col.b/255)
	end
	local GlowSprite=Material("sprites/mat_jack_basicglow")
	local GradeColors={Vector(.3,.3,.3),Vector(.2,.2,.2),Vector(.2,.2,.2),Vector(.2,.2,.2),Vector(.2,.2,.2)}
	local GradeMats={Material("phoenix_storms/metal"),Material("models/mat_jack_gmod_copper"),Material("models/mat_jack_gmod_silver"),Material("models/mat_jack_gmod_gold"),Material("models/mat_jack_gmod_platinum")}
	function ENT:Draw()
		local SelfPos,SelfAng,State,FT,Grade=self:GetPos(),self:GetAngles(),self:GetState(),FrameTime(),self:GetGrade()
		local Up,Right,Forward,FT=SelfAng:Up(),SelfAng:Right(),SelfAng:Forward(),FrameTime()
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
		---
		if(State>1)then
			self.OpenAmt=math.Clamp(self.OpenAmt-FT*1.3,0,1)--Lerp(FT*2,self.OpenAmt,0)
		else
			self.OpenAmt=math.Clamp(self.OpenAmt+FT*1.3,0,1)--Lerp(FT*2,self.OpenAmt,1)
		end
		---
		local DisplayAng=SelfAng:GetCopy()
		DisplayAng:RotateAroundAxis(Forward,90)
		if(DetailDraw)then
			local CamAng=SelfAng:GetCopy()
			CamAng:RotateAroundAxis(Up,-90)
			CamAng:RotateAroundAxis(Right,180)
			JMod_RenderModel(self.Camera,BasePos+Up*10+Forward*25,CamAng,nil,GradeColors[Grade],GradeMats[Grade])
			---
			local Matricks=Matrix()
			Matricks:Scale(Vector(.4,1.45,.5))
			self.TopCanopy:EnableMatrix("RenderMultiply",Matricks)
			local TopCanopyAng=SelfAng:GetCopy()
			TopCanopyAng:RotateAroundAxis(Forward,-10*self.OpenAmt)
			JMod_RenderModel(self.TopCanopy,BasePos-Up*(17-10*self.OpenAmt)+Right*2,TopCanopyAng)
			---
			local Matricks=Matrix()
			Matricks:Scale(Vector(.4,1.45,.5))
			self.BottomCanopy:EnableMatrix("RenderMultiply",Matricks)
			local BottomCanopyAng=SelfAng:GetCopy()
			BottomCanopyAng:RotateAroundAxis(Right,180)
			JMod_RenderModel(self.BottomCanopy,BasePos-Up*17+Right*2,BottomCanopyAng)
			---
			if(State>0)then
				local Opacity=math.random(50,200)
				local ElecFrac=self:GetElectricity()/self.MaxElectricity
				local R,G,B=JMod_GoodBadColor(ElecFrac)
				cam.Start3D2D(BasePos+Up*22+Right*22+Forward*21,DisplayAng,.08)
				draw.SimpleTextOutlined("Jackarunda Industries","JMod-Display",0,0,Color(255,255,255,Opacity),TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP,3,Color(0,0,0,Opacity))
				draw.SimpleTextOutlined("POWER "..math.Round(ElecFrac*100).."%","JMod-Display",0,40,Color(R,G,B,Opacity),TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP,3,Color(0,0,0,Opacity))
				draw.SimpleTextOutlined("SUPPLIES "..self:GetSupplies().."/"..self.MaxSupplies*EZ_GRADE_BUFFS[Grade],"JMod-Display",0,80,Color(255,255,255,Opacity),TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP,3,Color(0,0,0,Opacity))
				cam.End3D2D()
			end
		end
		if(State<=0)then
			cam.Start3D2D(BasePos+Up*40+Right*7.8-Forward*50,DisplayAng,1)
			surface.SetDrawColor(0,0,0,255)
			surface.DrawRect(39,9,22,12)
			cam.End3D2D()
			---
			cam.Start3D2D(BasePos+Up*11+Right*3.8-Forward*50,DisplayAng,1)
			surface.SetDrawColor(0,0,0,255)
			surface.DrawRect(8,9,15,10)
			surface.DrawRect(77,9,15,10)
			cam.End3D2D()
		end
	end
	language.Add("ent_jack_gmod_ezfieldhospital","EZ Automated Field Hospital")
end