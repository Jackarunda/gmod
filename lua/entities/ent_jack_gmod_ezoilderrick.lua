-- Jackarunda 2019
AddCSLuaFile()
ENT.Type="anim"
ENT.Author="Jackarunda"
ENT.Information="glhfggwpezpznore"
ENT.PrintName="EZ Oil Derrick"
ENT.Category="JMod - EZ Misc."
ENT.Spawnable=true
ENT.AdminOnly=false
ENT.EZconsumes={"power","parts"}
ENT.EZupgrades={
	rate=2,
	grades={
		{parts=40,advparts=20},
		{parts=60,advparts=40},
		{parts=80,advparts=80},
		{parts=100,advparts=160}
	}
}
local STATE_BROKEN,STATE_OFF,STATE_INOPERABLE,STATE_RUNNING=-1,0,1,2
function ENT:SetupDataTables()
	self:NetworkVar("Int",0,"State")
	self:NetworkVar("Int",1,"Grade")
	self:NetworkVar("Float",0,"Progress")
	self:NetworkVar("Float",1,"Electricity")
end
if(SERVER)then
	function ENT:Initialize()
		self:SetModel("models/hunter/blocks/cube4x4x1.mdl")
		--self:SetModelScale(math.Rand(1.5,3),0)
		--self:SetMaterial("models/debug/debugwhite")
		--self:SetColor(Color(math.random(190,210),math.random(140,160),0))
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)	
		self:SetSolid(SOLID_VPHYSICS)
		self:DrawShadow(true)
		self:SetUseType(SIMPLE_USE)
		self:SetPos(self:GetPos()+Vector(0,0,100)) -- what the fuck garry
		---
		timer.Simple(.01,function()
			self:GetPhysicsObject():SetMass(1000)
			self:GetPhysicsObject():Wake()
			-- attach us to the ground
			self:TryPlant()
		end)
		self:SetGrade(1)
		self:SetProgress(0)
		self:SetElectricity(200)
		self:SetState(STATE_OFF)
		self.Durability=300
	end
	function ENT:Upgrade(level)
		if not(level)then level=self:GetGrade()+1 end
		if(level>5)then return end
		self:SetGrade(level)
		self.UpgradeProgress={}
	end
	function ENT:TryLoadResource(typ,amt)
		if(amt<=0)then return 0 end
		if(typ=="power")then
			local Powa=self:GetElectricity()
			local Missing=200-Powa
			if(Missing<200*.1)then return 0 end
			local Accepted=math.min(Missing,amt)
			self:SetElectricity(Powa+Accepted)
			self:EmitSound("snd_jack_turretbatteryload.wav",65,math.random(90,110))
			return math.ceil(Accepted)
		elseif(typ=="parts")then
			local Missing=300-self.Durability
			if(Missing<=300*.25)then return 0 end
			local Accepted=math.min(Missing,amt)
			self.Durability=self.Durability+Accepted
			if(self.Durability>=300)then self:RemoveAllDecals() end
			self:EmitSound("snd_jack_turretrepair.wav",65,math.random(90,110))
			if(self.Durability>0)then
				if(self:GetState()==STATE_BROKEN)then self:SetState(STATE_OFF) end
			end
			return math.ceil(Accepted)
		end
		return 0
	end
	function ENT:TryPlant()
		local Tr=util.QuickTrace(self:GetPos()+Vector(0,0,100),Vector(0,0,-500),self)
		if((Tr.Hit)and(Tr.HitWorld))then
			local Yaw=self:GetAngles().y
			self:SetAngles(Angle(0,Yaw,-90))
			self:SetPos(Tr.HitPos+Tr.HitNormal*95)
			--
			local GroundIsSolid=true
			for i=1,50 do
				local Contents=util.PointContents(Tr.HitPos-Vector(0,0,10*i))
				jprint(Contents)
				if(Contents~=CONTENTS_SOLID)then GroundIsSolid=false break end
			end
			if(GroundIsSolid)then
				self.Weld=constraint.Weld(self,Tr.Entity,0,0,10000,false,false)
				self:SetState(STATE_OFF)
			else
				self:SetState(STATE_INOPERABLE)
			end
		end
	end
	function ENT:OnTakeDamage(dmginfo)
		if(self)then
			self:TakePhysicsDamage(dmginfo)
			self.Durability=self.Durability-dmginfo:GetDamage()
			if(self.Durability<=0)then self:Break(dmginfo) end
			if(self.Durability<=-300)then self:Destroy(dmginfo) end
		end
	end
	function ENT:Destroy(dmginfo)
		self:EmitSound("snd_jack_turretbreak.wav",70,math.random(80,120))
		for i=1,10 do self:DamageSpark() end
		local Force=dmginfo:GetDamageForce()
		for i=1,5*JMOD_CONFIG.SupplyEffectMult do
			self:FlingProp("models/gibs/scanner_gib02.mdl",Force)
			self:FlingProp("models/props_c17/oildrumchunk01d.mdl",Force)
			self:FlingProp("models/props_c17/oildrumchunk01e.mdl",Force)
			self:FlingProp("models/gibs/scanner_gib02.mdl",Force)
		end
		self:Remove()
	end
	function ENT:PhysicsCollide(data,physobj)
		if(data.DeltaTime>0.2 and data.Speed>100)then
			self:EmitSound("SolidMetal.ImpactHard")
		end
	end
	function ENT:TurnOn(activator)
		if(self:GetElectricity()>0)then
			self:SetState(STATE_RUNNING)
		else
			JMod_Hint(activator,"nopower")
		end
	end
	function ENT:TurnOff()
		self:SetState(STATE_OFF)
	end
	function ENT:Use(activator)
		local State=self:GetState()
		JMod_Hint(activator,"oil derrick")
		local OldOwner=self.Owner
		JMod_Owner(self,activator)
		if(IsValid(self.Owner))then
			if(OldOwner~=self.Owner)then -- if owner changed then reset team color
				JMod_Colorify(self)
			end
		end
		if(State==STATE_BROKEN)then
			JMod_Hint(activator,"destroyed",self)
			return
		elseif(State==STATE_INOPERABLE)then
			self:TryPlant()
		elseif(State==STATE_OFF)then
			self:TurnOn(activator)
		elseif(State==STATE_RUNNING)then
			self:TurnOff()
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
		self:EmitSound("snd_jack_turretbreak.wav",70,math.random(60,100))
		for i=1,10 do self:DamageSpark() end
		self.Durability=0
		self:SetState(STATE_BROKEN)
		local Force=(dmginfo and dmginfo:GetDamageForce()) or Vector(0,0,0)
		for i=1,4 do
			self:FlingProp("models/mechanics/gears/gear12x6_small.mdl",Force)
		end
	end
	function ENT:DamageSpark()
		local effectdata=EffectData()
		effectdata:SetOrigin(self:GetPos()-self:GetRight()*30-self:GetForward()*30+VectorRand()*math.random(0,10))
		effectdata:SetNormal(VectorRand())
		effectdata:SetMagnitude(math.Rand(2,4)) --amount and shoot hardness
		effectdata:SetScale(math.Rand(.5,1.5)) --length of strands
		effectdata:SetRadius(math.Rand(2,4)) --thickness of strands
		util.Effect("Sparks",effectdata,true,true)
		self:EmitSound("snd_jack_turretfizzle.wav",70,100)
		self:ConsumeElectricity(.2)
	end
	function ENT:Think()
		if not(IsValid(self.Weld))then
			if(self:GetState()>0)then self:SetState(STATE_INOPERABLE) end
		end
		local State=self:GetState()
		if(State==STATE_BROKEN)then
			if(self:GetElectricity()>0)then
				if(math.random(1,4)==2)then self:DamageSpark() end
			end
			return
		elseif(State==STATE_INOPERABLE)then
			return
		elseif(State==STATE_RUNNING)then
			if(self:GetElectricity()<=0)then self:TurnOff() return end
			self:SetProgress(self:GetProgress()+EZ_GRADE_BUFFS[self:GetGrade()])
			self:ConsumeElectricity()
			if(self:GetProgress()>=100)then
				self:SpawnOil()
				self:SetProgress(0)
			end
		end
		self:NextThink(CurTime()+1)
		return true
	end
	function ENT:SpawnOil()
		local SelfPos,Up,Forward,Right=self:GetPos(),self:GetUp(),self:GetForward(),self:GetRight()
		local Oil=ents.Create("ent_jack_gmod_ezrawresource_oil")
		Oil:SetPos(SelfPos+Forward*115-Right*90)
		Oil:Spawn()
		JMod_Owner(self.Owner)
		Oil:Activate()
	end
	function ENT:ConsumeElectricity(amt)
		amt=(amt or .1)
		local NewAmt=math.Clamp(self:GetElectricity()-amt,0,200)
		self:SetElectricity(NewAmt)
		if(NewAmt<=0)then self:TurnOff() end
	end
elseif(CLIENT)then
	function ENT:Initialize()
		self.Mdl=ClientsideModel("models/tsbb/pump_jack.mdl")
		self.Mdl:SetPos(self:GetPos()-self:GetRight()*100)
		local Ang=self:GetAngles()
		Ang:RotateAroundAxis(self:GetForward(),90)
		self.Mdl:SetAngles(Ang)
		self.Mdl:SetParent(self)
		self.Mdl:SetNoDraw(true)
		self.DriveCycle=0
		self.DriveMomentum=0
	end
	--[[
	0	Base
	1	WalkingBeam
	2	CounterWeight
	--]]
	function ENT:Draw()
		local Time,SelfPos,SelfAng,State,Grade=CurTime(),self:GetPos(),self:GetAngles(),self:GetState(),self:GetGrade()
		local Up,Right,Forward,FT=SelfAng:Up(),SelfAng:Right(),SelfAng:Forward(),FrameTime()
		if(State==STATE_RUNNING)then
			self.DriveMomentum=math.Clamp(self.DriveMomentum+FT/3,0,1)
		else
			self.DriveMomentum=math.Clamp(self.DriveMomentum-FT/3,0,1)
		end
		self.DriveCycle=self.DriveCycle+self.DriveMomentum*FT*150
		if(self.DriveCycle>360)then self.DriveCycle=0 end
		local WalkingBeamDrive=math.sin((self.DriveCycle/360)*math.pi*2-math.pi)*20
		self.Mdl:ManipulateBoneAngles(1,Angle(0,0,WalkingBeamDrive))
		self.Mdl:ManipulateBoneAngles(2,Angle(0,0,self.DriveCycle))
		--render.SetBlend(.5)
		--self:DrawModel()
		--render.SetBlend(1)
		self.Mdl:SetRenderOrigin(SelfPos-Right*100)
		local MdlAng=SelfAng:GetCopy()
		MdlAng:RotateAroundAxis(Forward,90)
		self.Mdl:SetRenderAngles(MdlAng)
		self.Mdl:DrawModel()
		--
		local BasePos=SelfPos+Up*32
		local Obscured=util.TraceLine({start=EyePos(),endpos=BasePos,filter={LocalPlayer(),self},mask=MASK_OPAQUE}).Hit
		local Closeness=LocalPlayer():GetFOV()*(EyePos():Distance(SelfPos))
		local DetailDraw=Closeness<36000 -- cutoff point is 400 units when the fov is 90 degrees
		if((not(DetailDraw))and(Obscured))then return end -- if player is far and sentry is obscured, draw nothing
		if(Obscured)then DetailDraw=false end -- if obscured, at least disable details
		if(State==STATE_BROKEN)then DetailDraw=false end -- look incomplete to indicate damage, save on gpu comp too
		if(DetailDraw)then
			if((Closeness<20000)and(State==STATE_INOPERABLE or State==STATE_RUNNING))then
				local DisplayAng=SelfAng:GetCopy()
				DisplayAng:RotateAroundAxis(DisplayAng:Right(),90)
				DisplayAng:RotateAroundAxis(DisplayAng:Up(),180)
				DisplayAng:RotateAroundAxis(DisplayAng:Forward(),-30)
				local Opacity=math.random(50,150)
				cam.Start3D2D(SelfPos+Up*25-Right*50-Forward*80,DisplayAng,.1)
				draw.SimpleTextOutlined("POWER","JMod-Display",250,0,Color(255,255,255,Opacity),TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP,3,Color(0,0,0,Opacity))
				local ElecFrac=self:GetElectricity()/200
				local R,G,B=JMod_GoodBadColor(ElecFrac)
				draw.SimpleTextOutlined(tostring(math.Round(ElecFrac*100)).."%","JMod-Display",250,30,Color(R,G,B,Opacity),TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP,3,Color(0,0,0,Opacity))
				--local CoolFrac=self:GetCoolant()/100
				--draw.SimpleTextOutlined("COOLANT","JMod-Display",90,0,Color(255,255,255,Opacity),TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP,3,Color(0,0,0,Opacity))
				--local R,G,B=JMod_GoodBadColor(CoolFrac)
				--draw.SimpleTextOutlined(tostring(math.Round(CoolFrac*100)).."%","JMod-Display",90,30,Color(R,G,B,Opacity),TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP,3,Color(0,0,0,Opacity))
				cam.End3D2D()
			end
		end
	end
	language.Add("ent_jack_gmod_ezoilpump","EZ Oil Derrick")
end