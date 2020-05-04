-- Jackarunda 2019
AddCSLuaFile()
ENT.Type="anim"
ENT.PrintName="EZ Aid Radio"
ENT.Author="Jackarunda"
ENT.Category="JMod - EZ Misc."
ENT.Information="glhfggwpezpznore"
ENT.Spawnable=true
ENT.AdminSpawnable=true
ENT.NoSitAllowed=true
ENT.EZconsumes={"power","parts"}
ENT.JModPreferredCarryAngles=Angle(0,0,0)
ENT.PropModels={"models/props_lab/reciever01d.mdl","models/props/cs_office/computer_caseb_p2a.mdl","models/props/cs_office/computer_caseb_p3a.mdl","models/props/cs_office/computer_caseb_p4a.mdl","models/props/cs_office/computer_caseb_p5a.mdl","models/props/cs_office/computer_caseb_p5b.mdl","models/props/cs_office/computer_caseb_p6a.mdl","models/props/cs_office/computer_caseb_p6b.mdl","models/props/cs_office/computer_caseb_p7a.mdl","models/props/cs_office/computer_caseb_p8a.mdl","models/props/cs_office/computer_caseb_p9a.mdl"}
----
local STATE_BROKEN,STATE_OFF,STATE_CONNECTING,STATE_READY=-1,0,1,2
function ENT:SetupDataTables()
	self:NetworkVar("Int",0,"State")
	self:NetworkVar("Float",0,"Electricity")
	self:NetworkVar("String",0,"StationID")
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
		self.Entity:SetModel("models/props_phx/oildrum001_explosive.mdl")
		self.Entity:SetMaterial("models/mat_jack_gmod_ezradio")
		self.Entity:PhysicsInit(SOLID_VPHYSICS)
		self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
		self.Entity:SetSolid(SOLID_VPHYSICS)
		self.Entity:DrawShadow(true)
		self:SetUseType(SIMPLE_USE)
		local phys=self.Entity:GetPhysicsObject()
		if phys:IsValid()then
			phys:Wake()
			phys:SetMass(150)
			phys:SetBuoyancyRatio(.3)
		end
		---
		JMod_Colorify(self)
		---
		self.MaxDurability=100
		self.MaxElectricity=100
		self.ThinkSpeed=1
		self.Efficiency=1
		---
		self:SetElectricity(self.MaxElectricity)
		self.Durability=self.MaxDurability
		self.NextWhine=0
		self.NextRealThink=0
		self.NextUseTime=0
		self:SetStationID("")
		self.HaveCheckedForSky=false
		self.ConnectionAttempts=0
		self.ConnectionlessThinks=0
		if(JMOD_CONFIG.Blueprints["EZ Supply Radio"])then
			self.EZbuildCost=JMOD_CONFIG.Blueprints["EZ Supply Radio"][2]
		end
		---
		local Path="/npc/combine_soldier/vo/"
		local Files,Folders=file.Find("sound"..Path.."*.wav","GAME")
		self.Voices=Files
	end
	function ENT:PhysicsCollide(data,physobj)
		if((data.Speed>80)and(data.DeltaTime>0.2))then
			self.Entity:EmitSound("Canister.ImpactHard")
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
		amt=(amt or .1)/self.Efficiency
		local NewAmt=math.Clamp(self:GetElectricity()-amt,0,self.MaxElectricity)
		self:SetElectricity(NewAmt)
		if(NewAmt<=0)then self:TurnOff() end
	end
	function ENT:DamageSpark()
		local effectdata=EffectData()
		effectdata:SetOrigin(self:GetPos()+self:GetUp()*30+VectorRand()*math.random(0,10))
		effectdata:SetNormal(VectorRand())
		effectdata:SetMagnitude(math.Rand(2,4)) --amount and shoot hardness
		effectdata:SetScale(math.Rand(.5,1.5)) --length of strands
		effectdata:SetRadius(math.Rand(2,4)) --thickness of strands
		util.Effect("Sparks",effectdata,true,true)
		self:EmitSound("snd_jack_turretfizzle.wav",70,100)
		self:ConsumeElectricity(.2)
	end
	function ENT:OnTakeDamage(dmginfo)
		if(self)then
			self:TakePhysicsDamage(dmginfo)
			self.Durability=self.Durability-dmginfo:GetDamage()/3
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
		SafeRemoveEntityDelayed(Prop,math.random(20,40))
	end
	function ENT:Break(dmginfo)
		if(self:GetState()==STATE_BROKEN)then return end
		self:EmitSound("snd_jack_turretbreak.wav",70,math.random(80,120))
		for i=1,10 do self:DamageSpark() end
		self.Durability=0
		self:SetState(STATE_BROKEN)
		local Force=dmginfo:GetDamageForce()
		for i=1,4 do
			self:FlingProp(table.Random(self.PropModels),Force)
		end
	end
	function ENT:Destroy(dmginfo)
		self:EmitSound("snd_jack_turretbreak.wav",70,math.random(80,120))
		for i=1,10 do self:DamageSpark() end
		local Force=dmginfo:GetDamageForce()
		self:FlingProp("models/props_rooftop/satellitedish02.mdl",Force)
		for i=1,3 do
			self:FlingProp(table.Random(self.PropModels),Force)
			self:FlingProp("models/props_c17/oildrumchunk01d.mdl",Force)
			self:FlingProp("models/props_c17/oildrumchunk01e.mdl",Force)
			self:FlingProp(table.Random(self.PropModels),Force)
		end
		self:Remove()
	end
	function ENT:Use(activator)
		local Time=CurTime()
		if(self.NextUseTime>Time)then return end
		self.NextUseTime=Time+.25
		if(activator:IsPlayer())then
			local State=self:GetState()
			if(State==STATE_BROKEN)then JMod_Hint(self.Owner, "destroyed", self) return end
			local Alt=activator:KeyDown(JMOD_CONFIG.AltFunctionKey)
			if State > 0 then
                if Alt and State == STATE_READY then
                    net.Start("JMod_EZradio")
                        net.WriteBool(false)
                        net.WriteTable(JMOD_CONFIG.RadioSpecs.AvailablePackages)
                        net.WriteEntity(self)
                        net.WriteString(JMod_EZradioStatus(self,self:GetStationID(),activator,false))
                    net.Send(activator)
                else
                    self:TurnOff()
                    JMod_Hint(activator, "toggle", self)
                end
			else
				if (self:GetElectricity()>0) then self:TurnOn(activator) JMod_Hint(activator, "aid help", self)
                else JMod_Hint(self.Owner, "nopower", self) end
			end
		end
	end
	function ENT:TurnOff()
		local State=self:GetState()
		if((State==STATE_OFF)or(State==STATE_BROKEN))then return end
		self:SetState(STATE_OFF)
		self:EmitSound("snds_jack_gmod/ezsentry_shutdown.wav",65,100)
	end
	function ENT:Speak(msg,parrot)
		if(self:GetState()<1)then return end
		self:ConsumeElectricity()
		if(parrot)then
            for _, ply in pairs(player.GetAll()) do
                if ply:Alive() and ply:GetPos():DistToSqr(self:GetPos()) <= 200 * 200 then
                    net.Start("JMod_EZradio")
                        net.WriteBool(true)
                        net.WriteBool(true)
                        net.WriteString(parrot)
                        net.WriteEntity(self)
                    net.Send(ply)
                end
            end
		end
		local MsgLength,Path=string.len(msg),"/npc/combine_soldier/vo/"
		for i=1,math.Round(MsgLength/15) do
			timer.Simple(i*.75,function()
				if((IsValid(self))and(self:GetState()>0))then
					self:EmitSound(Path..self.Voices[math.random(1,#self.Voices)],65,120)
				end
			end)
		end
		timer.Simple(.5,function()
			if(IsValid(self))then
                for _, ply in pairs(player.GetAll()) do
                    if ply:Alive() and ply:GetPos():DistToSqr(self:GetPos()) <= 200 * 200 then
                        net.Start("JMod_EZradio")
                            net.WriteBool(true)
                            net.WriteBool(false)
                            net.WriteString(msg)
                            net.WriteEntity(self)
                        net.Send(ply)
                    end
                end
			end
		end)
	end
	function ENT:TurnOn(activator)
		local OldOwner=self.Owner
		JMod_Owner(self,activator)
		if(IsValid(self.Owner))then
			if(OldOwner~=self.Owner)then -- if owner changed then reset team color
				JMod_Colorify(self)
			end
		end
		self:SetState(STATE_CONNECTING)
		self:EmitSound("snds_jack_gmod/ezsentry_startup.wav",65,100)
		self.ConnectionAttempts=0
	end
	function ENT:Connect(ply)
		-- station key is important because it defines who has access to what and provides rate-limiting on requests
		local StationKey=math.random(1,999999)
		if(engine.ActiveGamemode()=="sandbox")then
			local ID=ply:AccountID()
			if(ID)then StationKey=ID end
		else
			local Teem=ply:Team()
			if(Teem)then StationKey=Teem end
		end
		StationKey="J.I. Aid Outpost #"..tostring(StationKey)
		self:SetStationID(StationKey)
		JMod_EZradioEstablish(self,StationKey)
		self:SetState(STATE_READY)
		timer.Simple(1,function()
			if(IsValid(self))then
				self:Speak("Comm line established with "..StationKey..". This unit's ID is "..tostring(self:EntIndex()))
			end
		end)
	end
	function ENT:Think()
		local State,Time=self:GetState(),CurTime()
		if(self.NextRealThink<Time)then
			local Electricity=self:GetElectricity()
			self.NextRealThink=Time+4/self.ThinkSpeed
			if(State==STATE_CONNECTING)then
				self:ConsumeElectricity()
				if(self:TryFindSky())then
					self:Speak("Broadcast received, establishing comm line...")
					self:Connect(self.Owner)
				else
                    JMod_Hint(self.Owner, "aid sky", self)
					self.ConnectionAttempts = self.ConnectionAttempts + 1
					if(self.ConnectionAttempts>5)then
						self:Speak("Can not establish connection to any outpost. Shutting down.")
						timer.Simple(1,function()
							if(IsValid(self))then self:TurnOff() end
						end)
					end
				end
			elseif(State>0)then
				self:ConsumeElectricity()
				if not(self:TryFindSky())then
					self.ConnectionlessThinks=self.ConnectionlessThinks+1
					if(self.ConnectionlessThinks>5)then
						self:Speak("Connection to outpost lost. Shutting down.")
						timer.Simple(1,function()
							if(IsValid(self))then self:TurnOff() end
						end)
					end
				else
					self.ConnectionlessThinks=0
				end
				if(Electricity<self.MaxElectricity*.1)then self:Whine() end
				if(Electricity<=0)then self:TurnOff() end
			end
		end
		self:NextThink(Time+.05)
		return true
	end
	function ENT:TryFindSky()
		local SelfPos,Up=self:GetPos(),self:GetUp()
		for i=1,50 do
			local CheckDir=VectorRand()+Up
			local Tr=util.TraceLine({start=SelfPos,endpos=SelfPos+CheckDir*20000,filter={self},mask=MASK_OPAQUE})
			if(Tr.HitSky)then return true end
		end
		return false
	end
	function ENT:Whine(serious)
		local Time=CurTime()
		if(self.NextWhine<Time)then
			self.NextWhine=Time+4
			self:EmitSound("snds_jack_gmod/ezsentry_whine.wav",70,100)
			self:ConsumeElectricity(.02)
		end
	end
	function ENT:OnRemove()
		--
	end
	function ENT:UserIsAuthorized(ply)
		if not(ply)then return false end
		if not(ply:IsPlayer())then return false end
		if((self.Owner)and(ply==self.Owner))then return true end
		local Allies=(self.Owner and self.Owner.JModFriends)or {}
		if(table.HasValue(Allies,ply))then return true end
		if(engine.ActiveGamemode()~="sandbox")then
			local OurTeam=nil
			if(IsValid(self.Owner))then OurTeam=self.Owner:Team() end
			return (OurTeam and ply:Team()==OurTeam) or false
		end
		return false
	end
	function ENT:EZreceiveSpeech(ply,txt)
		local State=self:GetState()
		if(State<2)then return end
		if not(self:UserIsAuthorized(ply))then return end
		txt=string.lower(txt)
		local NormalReq,BFFreq=string.sub(txt,1,14)=="supply radio: ",string.sub(txt,1,6)=="heyo: "
		if((NormalReq)or(BFFreq))then
			local Name,ParrotPhrase=string.sub(txt,15),txt
			if(BFFreq)then
				Name=string.sub(txt,7)
			end
			if(Name=="help")then
				if(State==2)then
					--local Msg,Num='stand near radio\nsay in chat: "status", or "supply radio: [package]"\navailable packages are:\n',1
                    local Msg,Num='stand near radio and say in chat "supply radio: status", or "supply radio: [package]". available packages are:',1
					self:Speak(Msg,ParrotPhrase)
                    local str = ""
					for name,items in pairs(JMOD_CONFIG.RadioSpecs.AvailablePackages) do
                        str = str .. name
                        if Num > 0 and Num % 10 == 0 then
                            local newStr = str
                            timer.Simple(Num/10,function()
                                if(IsValid(self))then self:Speak(newStr) end
                            end)
                            str = ""
                        else
                            str = str .. ", "
                        end
						Num=Num+1
					end
                    timer.Simple(Num/10,function()
                        if(IsValid(self))then self:Speak(str) end
                    end)
                    JMod_Hint(self.Owner, "aid package", self)
					return true
				end
			elseif(Name=="status")then
				self:Speak(JMod_EZradioStatus(self,self:GetStationID(),ply,BFFreq),ParrotPhrase)
				return true
			elseif(JMOD_CONFIG.RadioSpecs.AvailablePackages[Name])then
				self:Speak(JMod_EZradioRequest(self,self:GetStationID(),ply,Name,BFFreq),ParrotPhrase)
				return true
			end
		end
		return false
	end
	function ENT:EZsalvage()
		if not(self.EZbuildCost)then return end
		if(self.Salvaged)then return end
		self.Salvaged=true
		local scale,pos=1,self:GetPos()+self:GetUp()*20
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
		self.Dish=JMod_MakeModel(self,"models/props_rooftop/satellitedish02.mdl")
		self.Panel=JMod_MakeModel(self,"models/props_lab/reciever01a.mdl",nil,.8)
		self.Headset=JMod_MakeModel(self,"models/lt_c/sci_fi/headset_2.mdl")
		self.LeftHandle=JMod_MakeModel(self,"models/props_wasteland/panel_leverhandle001a.mdl","phoenix_storms/metal")
		self.RightHandle=JMod_MakeModel(self,"models/props_wasteland/panel_leverhandle001a.mdl","phoenix_storms/metal")
		self.MaxElectricity=100
	end
	local function ColorToVector(col)
		return Vector(col.r/255,col.g/255,col.b/255)
	end
	local GlowSprite,StateMsgs=Material("sprites/mat_jack_basicglow"),{[STATE_CONNECTING]="Connecting...",[STATE_READY]="Ready"}
	function ENT:Draw()
		local SelfPos,SelfAng,State=self:GetPos(),self:GetAngles(),self:GetState()
		local Up,Right,Forward,FT=SelfAng:Up(),SelfAng:Right(),SelfAng:Forward(),FrameTime()
		---
		local BasePos=SelfPos+Up*32
		local Obscured=util.TraceLine({start=EyePos(),endpos=BasePos,filter={LocalPlayer(),self},mask=MASK_OPAQUE}).Hit
		local Closeness=LocalPlayer():GetFOV()*(EyePos():Distance(SelfPos))
		local DetailDraw=Closeness<36000 -- cutoff point is 400 units when the fov is 90 degrees
		if((not(DetailDraw))and(Obscured))then return end -- if player is far and sentry is obscured, draw nothing
		if(Obscured)then DetailDraw=false end -- if obscured, at least disable details
		if(State==STATE_BROKEN)then DetailDraw=false end -- look incomplete to indicate damage, save on gpu comp too
		---
		local Matricks=Matrix()
		Matricks:Scale(Vector(1,1,.5))
		self:EnableMatrix("RenderMultiply",Matricks)
		self:DrawModel()
		---
		local DishAng=SelfAng:GetCopy()
		DishAng:RotateAroundAxis(Right,20)
		JMod_RenderModel(self.Dish,BasePos+Up*8+Forward*8,DishAng,nil,Vector(.7,.7,.7))
		---
		if(DetailDraw)then
			local PanelAng=SelfAng:GetCopy()
			PanelAng:RotateAroundAxis(Right,90)
			JMod_RenderModel(self.Panel,BasePos-Up*15-Forward*6,PanelAng,nil,Vector(.7,.7,.7))
			---
			local HeadsetAng=SelfAng:GetCopy()
			HeadsetAng:RotateAroundAxis(Right,-110)
			JMod_RenderModel(self.Headset,BasePos-Up*4,HeadsetAng,nil,ColorToVector(self:GetColor()))
			---
			local LeftHandleAng=SelfAng:GetCopy()
			LeftHandleAng:RotateAroundAxis(LeftHandleAng:Up(),90)
			LeftHandleAng:RotateAroundAxis(LeftHandleAng:Right(),173)
			JMod_RenderModel(self.LeftHandle,SelfPos+Up*20+Right*13.7,LeftHandleAng)
			---
			local RightHandleAng=SelfAng:GetCopy()
			RightHandleAng:RotateAroundAxis(RightHandleAng:Up(),-90)
			RightHandleAng:RotateAroundAxis(RightHandleAng:Right(),173)
			JMod_RenderModel(self.RightHandle,SelfPos+Up*20-Right*13.7,RightHandleAng)
			if((Closeness<20000)and(State>0))then
				local DisplayAng=SelfAng:GetCopy()
				DisplayAng:RotateAroundAxis(DisplayAng:Right(),80)
				DisplayAng:RotateAroundAxis(DisplayAng:Up(),-90)
				local Opacity=math.random(50,150)
				cam.Start3D2D(SelfPos+Up*38-Forward*5,DisplayAng,.075)
				if(State>1)then
					draw.SimpleTextOutlined("Connected to:","JMod-Display",0,0,Color(255,255,255,Opacity),TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP,2,Color(0,0,0,Opacity))
					draw.SimpleTextOutlined(self:GetStationID(),"JMod-Display",0,40,Color(255,255,255,Opacity),TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP,2,Color(0,0,0,Opacity))
				end
				local ElecFrac=self:GetElectricity()/self.MaxElectricity
				local R,G,B=JMod_GoodBadColor(ElecFrac)
				draw.SimpleTextOutlined("Power: "..math.Round(ElecFrac*100).."%","JMod-Display",0,70,Color(R,G,B,Opacity),TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP,2,Color(0,0,0,Opacity))
				draw.SimpleTextOutlined(StateMsgs[State],"JMod-Display",0,100,Color(255,255,255,Opacity),TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP,2,Color(0,0,0,Opacity))
				if(State==STATE_READY)then
					draw.SimpleTextOutlined('say "supply radio: help"',"JMod-Display-S",0,140,Color(255,255,255,Opacity/2),TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP,1,Color(0,0,0,Opacity/2))
				end
				cam.End3D2D()
			end
		end
	end
	language.Add("ent_jack_gmod_ezaidradio","EZ Aid Radio")
end