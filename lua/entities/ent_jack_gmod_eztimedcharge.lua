-- Jackarunda 2019
AddCSLuaFile()
ENT.Type="anim"
ENT.Author="Jackarunda"
ENT.Category="JMod - EZ"
ENT.Information="glhfggwpezpznore"
ENT.PrintName="EZ Timed Charge"
ENT.Spawnable=true
ENT.AdminSpawnable=true
---
ENT.JModPreferredCarryAngles=Angle(-90,0,0)
ENT.JModEZstorable = true
---
local STATE_BROKEN,STATE_OFF,STATE_ARMED=-1,0,1
function ENT:SetupDataTables()
	self:NetworkVar("Int",0,"State")
	self:NetworkVar("Int",1,"Timer")
end
---
if(SERVER)then

	util.AddNetworkString("JModTimedCharge_GetUI")
	util.AddNetworkString("JModTimedCharge_Arm")
	
	net.Receive("JModTimedCharge_Arm", function(len, ply)
		local ent = net.ReadEntity()
		local time = net.ReadUInt(16)
		if ent:GetState() == STATE_OFF and ent.Owner == ply and (ply:GetPos()-ent:GetPos()):Length() <= 100 then
			ent:SetTimer(math.min(time, 600))
			ent:NextThink(CurTime() + 1)
			ent:SetState(STATE_ARMED)
			ent:EmitSound("weapons/c4/c4_plant.wav",60, 120)
			ent:EmitSound("snd_jack_minearm.wav",60,100)
		end
	end)

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
		self.Entity:SetModel("models/weapons/w_c4_planted.mdl")
		self.Entity:SetModelScale(0.5)
		self.Entity:PhysicsInit(SOLID_VPHYSICS)
		self.Entity:SetMoveType(MOVETYPE_VPHYSICS)	
		self.Entity:SetSolid(SOLID_VPHYSICS)
		self.Entity:DrawShadow(true)
		self.Entity:SetUseType(ONOFF_USE)
		---
		timer.Simple(.01,function()
			self:GetPhysicsObject():SetMass(15)
			self:GetPhysicsObject():Wake()
		end)
		---
		self:SetState(STATE_OFF)
		self.NextStick=0
	end
	function ENT:PhysicsCollide(data,physobj)
		if(data.DeltaTime>0.2)then
			if(data.Speed>25)then
				self.Entity:EmitSound("snd_jack_claythunk.wav",55,math.random(80,120))
			end
		end
	end
	function ENT:OnTakeDamage(dmginfo)
		if(dmginfo:GetInflictor()==self)then return end
		self.Entity:TakePhysicsDamage(dmginfo)
		local Dmg=dmginfo:GetDamage()
		if(Dmg>=4)then
			local Pos,State,DetChance=self:GetPos(),self:GetState(),0
			if(State==STATE_ARMED)then DetChance=DetChance+.3 end
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
		JMod_Hint(activator,"arm")
		local Time=CurTime()
		if(tobool(onOff))then
			local State=self:GetState()
			if(State<0)then return end
			local Alt=Dude:KeyDown(IN_WALK)
			if(State==STATE_OFF)then
				if(Alt)then
					net.Start("JModTimedCharge_GetUI")
						net.WriteEntity(self)
					net.Send(Dude)
				else
					constraint.RemoveAll(self)
					self.StuckStick=nil
					self.StuckTo=nil
					Dude:PickupObject(self)
					self.NextStick=Time+.5
				end
			else
				if(Alt)then
					self:SetState(STATE_OFF)
					self:EmitSound("weapons/c4/c4_disarm.wav", 60, 120)
				else
					constraint.RemoveAll(self)
					self.StuckStick=nil
					self.StuckTo=nil
					Dude:PickupObject(self)
					self.NextStick=Time+.5
				end
			end
		else -- player just released the USE key
			if((self:IsPlayerHolding())and(self.NextStick<Time))then
				local Tr=util.QuickTrace(Dude:GetShootPos(),Dude:GetAimVector()*80,{self,Dude})
				if(Tr.Hit)then
					if((IsValid(Tr.Entity:GetPhysicsObject()))and not(Tr.Entity:IsNPC())and not(Tr.Entity:IsPlayer()))then
						self.NextStick=Time+.5
						local Ang=Tr.HitNormal:Angle()
						Ang:RotateAroundAxis(Ang:Right(),-90)
						Ang:RotateAroundAxis(Ang:Up(),180)
						self:SetAngles(Ang)
						self:SetPos(Tr.HitPos+Tr.HitNormal*2.35)
						local Weld=constraint.Weld(self,Tr.Entity,0,Tr.PhysicsBone,10000,false,false)
						self.Entity:EmitSound("snd_jack_claythunk.wav",65,math.random(80,120))
						Dude:DropObject()
						self.StuckTo=Tr.Entity
						self.StuckStick=Weld
					end
				end
			end
		end
	end
	function ENT:IncludeSympatheticDetpacks(origin)
		local Powa,FilterEnts,Points=1,ents.FindByClass("ent_jack_gmod_ezdetpack"),{origin}
		for k,pack in pairs(ents.FindInSphere(origin,100))do
			if((pack~=self)and(pack.JModEZdetPack))then
				local PackPos=pack:LocalToWorld(pack:OBBCenter())
				if not(util.TraceLine({start=origin,endpos=PackPos,filter=FilterEnts}).Hit)then
					Powa=Powa+1
					table.insert(Points,PackPos)
					pack.SympatheticDetonated=true
					pack:Remove()
				end
			end
		end
		local Cumulative=Vector(0,0,0)
		for k,point in pairs(Points)do
			Cumulative=Cumulative+point
		end
		return Cumulative/Powa,Powa
	end
	function ENT:WreckBuildings(pos,power)
		local LoosenThreshold,DestroyThreshold=400*power,100*power
		for k,prop in pairs(ents.FindInSphere(pos,100*power))do
			local Phys=prop:GetPhysicsObject()
			if(not(prop==self)and(IsValid(Phys)))then
				local PropPos=prop:LocalToWorld(prop:OBBCenter())
				if(prop:Visible(self))then
					local Mass=Phys:GetMass()
					if(Mass<=DestroyThreshold)then
						SafeRemoveEntity(prop)
					elseif(Mass<=LoosenThreshold)then
						Phys:EnableMotion(true)
						constraint.RemoveAll(prop)
						Phys:ApplyForceOffset((PropPos-pos):GetNormalized()*300*power*Mass,PropPos+VectorRand()*10)
					else
						Phys:ApplyForceOffset((PropPos-pos):GetNormalized()*300*power*Mass,PropPos+VectorRand()*10)
					end
				end
			end
		end
	end
	function ENT:BlastDoors(pos,power)
		for k,door in pairs(ents.FindInSphere(pos,50*power))do
			if((self:Visible(door))and(JMod_IsDoor(door)))then
				local Vel=(door:LocalToWorld(door:OBBCenter())-pos):GetNormalized()*1000
				JMod_BlastThatDoor(door,Vel)
			end
		end
	end
	function ENT:Detonate()
		if(self.SympatheticDetonated)then return end
		if(self.Exploded)then return end
		self.Exploded=true
		timer.Simple(math.Rand(0,.1),function()
			if(IsValid(self))then
				if(self.SympatheticDetonated)then return end
				local SelfPos,PowerMult=self:IncludeSympatheticDetpacks(self:LocalToWorld(self:OBBCenter()))
				PowerMult=(PowerMult^.75)*JMOD_CONFIG.DetpackPowerMult
				--
				local Blam=EffectData()
				Blam:SetOrigin(SelfPos)
				Blam:SetScale(PowerMult)
				util.Effect("eff_jack_plastisplosion",Blam,true,true)
				util.ScreenShake(SelfPos,99999,99999,1,750*PowerMult)
				for i=1,PowerMult do sound.Play("BaseExplosionEffect.Sound",SelfPos,120,math.random(90,110)) end
				if(PowerMult>1)then
					for i=1,PowerMult do sound.Play("ambient/explosions/explode_"..math.random(1,9)..".wav",SelfPos+VectorRand()*1000,140,math.random(90,110)) end
				end
				self:EmitSound("snd_jack_fragsplodeclose.wav",90,100)
				timer.Simple(.1,function()
					for i=1,5 do
						local Tr=util.QuickTrace(SelfPos,VectorRand()*20)
						if(Tr.Hit)then util.Decal("Scorch",Tr.HitPos+Tr.HitNormal,Tr.HitPos-Tr.HitNormal) end
					end
				end)
				self:WreckBuildings(SelfPos,PowerMult)
				self:BlastDoors(SelfPos,PowerMult)
				timer.Simple(0,function()
					local ZaWarudo=game.GetWorld()
					local Infl,Att=(IsValid(self) and self) or ZaWarudo,(IsValid(self) and IsValid(self.Owner) and self.Owner) or (IsValid(self) and self) or ZaWarudo
					util.BlastDamage(Infl,Att,SelfPos,300*PowerMult,200*PowerMult)
					if((IsValid(self.StuckTo))and(IsValid(self.StuckStick)))then
						util.BlastDamage(Infl,Att,SelfPos,50*PowerMult,600*PowerMult)
					end
					self:Remove()
				end)
			end
		end)
	end
	function ENT:Think()
		if self:GetState() == STATE_ARMED then
		
			self:EmitSound("weapons/c4/c4_beep1.wav", 60, 100)
			self:SetTimer(self:GetTimer() - 1)
			if self:GetTimer() <= 0 then self:Detonate() return end
		
			self:NextThink(CurTime() + 1)
			return true
		end
	end
elseif(CLIENT)then
	function ENT:Initialize()
		--
	end

	function ENT:Draw()
		self:DrawModel()
		if(self:GetState()==STATE_ARMED)then
			local ang = self:GetAngles()
			--ang:RotateAroundAxis(ang:Right(),70)
			ang:RotateAroundAxis(ang:Up(),-90)
			local Up,Right,Forward,FT=ang:Up(),ang:Right(),ang:Forward(),FrameTime()
			local Opacity=math.random(50,150)
			cam.Start3D2D(self:GetPos()+Up*4.5-Right*2.25-Forward*-2.4,ang,.05)
				draw.SimpleTextOutlined(tostring(self:GetTimer()),"JMod-Display",0,0,Color(255,0,0,Opacity),TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP,3,Color(0,0,0,Opacity))
			cam.End3D2D()
		end
	end
	
	net.Receive("JModTimedCharge_GetUI", function()
		local ent = net.ReadEntity()
		
		local frame = vgui.Create("DFrame")
		frame:SetSize(300, 100)
		frame:SetTitle("Timed Charge")
		frame:SetDraggable(true)
		frame:Center()
		frame:MakePopup()
		
		local time = vgui.Create("DNumSlider", frame)
		time:SetText("Time (s)")
		time:SetSize(280, 20)
		time:SetPos(10,30)
		time:SetMin(5)
		time:SetMax(600)
		time:SetValue(10)
		time:SetDecimals(0)
		
		local apply = vgui.Create("DButton", frame)
		apply:SetSize(100, 30)
		apply:SetPos(100, 55)
		apply:SetText("ARM")
		apply.DoClick = function()
			net.Start("JModTimedCharge_Arm")
				net.WriteEntity(ent)
				net.WriteUInt(time:GetValue(), 16)
			net.SendToServer()
			frame:Close()
		end
		
	end)
	
	language.Add("ent_jack_gmod_ezdetpack","EZ Detpack")
end