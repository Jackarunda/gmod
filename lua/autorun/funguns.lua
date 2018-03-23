local PowerTypeToEntClassTable={
	["High-Density Rechargeable Lithium-Ion Battery"]="ent_jack_fgc_energy_lithium",
	["Self-Contained Micro Nuclear Fission Reactor"]="ent_jack_fgcartridge_energy",
	["Radiosotope Thermoelectric Generator/Battery Module"]="ent_jack_fgc_energy_rite"
}

if(CLIENT)then
	/*-local fr=1
	local avg=0
	local Length=1
	local function GiveFrameRate()
		avg=avg+FrameTime()
		fr=fr+1
		if(fr==51)then
			avg=avg/50
			fr=1
			Length=(1/avg)*5
		end
		draw.RoundedBox(10,0,0,Length,100,Color(0,0,0,180));
		draw.DrawText(tostring(math.Round(Length/5)),"default",50,40,Color(255,255,255,255),TEXT_ALIGN_CENTER)
	end
	hook.Add("HUDPaint","JackysFrameRateChecker",GiveFrameRate)-*/
	
	local function LoadWeapon(data)
		data:ReadEntity():LoadEnergyCartridge(data:ReadEntity())
	end
	usermessage.Hook("JackyFGEnergyLoad",LoadWeapon)
	
	local function LoadWeaponAgain(data)
		data:ReadEntity():LoadIronSlug(data:ReadEntity())
	end
	usermessage.Hook("JackyFGIronLoad",LoadWeaponAgain)

	function FG_Scope()
		local Ply=LocalPlayer()
		local Wep=Ply:GetActiveWeapon()
		if(IsValid(Wep))then
			if(Wep.Jack_FG_Scoped)then
				Wep.rtmat:SetTexture("$basetexture",Wep.FGScope)
				old=render.GetRenderTarget()
				local CamData={}
				CamData.angles=Ply:GetAimVector():Angle()
				CamData.origin=Ply:GetShootPos()
				CamData.x=0
				CamData.y=0
				CamData.w=400
				CamData.h=400
				CamData.fov=8
				CamData.drawviewmodel=false
				CamData.drawhud=false
				render.SetRenderTarget(Wep.FGScope)
				render.SetViewPort(0,0,400,400)
				cam.Start2D()
				render.RenderView(CamData)
				cam.End2D()
				render.SetViewPort(0,0,ScrW(),ScrH())
				render.SetRenderTarget(old)
			end
		end
	end
	hook.Add("RenderScene","Jacky_FG_Scope",FG_Scope)
	
	local function Adjust(default)
		local Ply=LocalPlayer()
		local Wep=Ply:GetActiveWeapon()
		if(IsValid(Wep))then
			if(Wep.IsAJackyFunGun)then
				if(Wep.MouseAdjust)then
					if(Ply:KeyDown(IN_ATTACK2))then return Wep.MouseAdjust end
				end
			end
		end
	end
	hook.Add("AdjustMouseSensitivity","JackysFunGunMouseSensitivity",Adjust)

	local function ChangeMovement(data)
		local Wep=data:ReadEntity()
		local Num=data:ReadFloat()
		if((Wep)and(Num))then
			Wep.BobScale=Num
			Wep.SwayScale=Num
		end
	end
	usermessage.Hook("JackysDynamicFGBobSwayScaling",ChangeMovement)

	local function MakeMagHot(data)
		local self=data:ReadEntity()
		local Type=data:ReadString()
		if(Type=="Self-Contained Micro Nuclear Fission Reactor")then
			self.VElements["herp"].surpresslightning=true
			self.VElements["herp"].material="models/debug/debugwhite"
		elseif(Type=="High-Density Rechargeable Lithium-Ion Battery")then
			self.VElements["herp"].material="models/mat_jack_fgc_energy_lithium"
		elseif(Type=="Radiosotope Thermoelectric Generator/Battery Module")then
			self.VElements["herp"].material="models/mat_jack_fgc_energy_rite"
		end
	end
	usermessage.Hook("JackysFGMagHot",MakeMagHot)

	local function MakeMagCool(data)
		local self=data:ReadEntity()
		local Type=data:ReadString()
		if(Type=="Self-Contained Micro Nuclear Fission Reactor")then
			self.VElements["herp"].surpresslightning=false
			self.VElements["herp"].material=nil
		elseif(Type=="High-Density Rechargeable Lithium-Ion Battery")then
			self.VElements["herp"].material="models/mat_jack_fgc_energy_lithium"
		elseif(Type=="Radiosotope Thermoelectric Generator/Battery Module")then
			self.VElements["herp"].material="models/mat_jack_fgc_energy_rite"
		end
	end
	usermessage.Hook("JackysFGMagCool",MakeMagCool)
	
	function JackIndFunGunAmmoDisplay(self)
		if not(self.DisplaysOn)then return end
		local Flicker=math.Rand(.5,1)
		local Ammo
		if(self.dt.Ammo)then Ammo=self.dt.Ammo else Ammo=self.dt.Energy end
		if(Ammo<.01)then Flicker=math.Rand(0,.5) end
		local Frac=1-Ammo
		surface.SetDrawColor((4*Frac-1)*255,(-2*Frac+2)*255,(-4*Frac+1)*255,75*Flicker)
		for i=0,16 do
			surface.DrawLine(-5,i,19,i)
		end
		surface.SetDrawColor(255,255,255,200*Flicker)
		surface.DrawOutlinedRect(-5,0,25,17)
		surface.SetTextColor(255,255,255,200*Flicker)
		surface.SetTextPos(0,2)
		surface.SetFont("Default")
		surface.DrawText(tostring(math.Clamp(math.floor(Ammo*100),0,100)))
	end

	local function JackIndFontSet()
		surface.CreateFont("JackIndFunGunLargeFont",{font="coolvetica",size=20,weight=200})
		surface.CreateFont("JackIndFunGunSmallFont",{font="coolvetica",size=6,weight=150})
		surface.CreateFont("JackIndFunGunSemiSmallFont",{font="coolvetica",size=7,weight=150})
	end
	hook.Add("Initialize","JackIndFontCreation",JackIndFontSet)

	function JackIndFunGunIronDisplay(self)
		if not(self.DisplaysOn)then return end
		local Flicker=math.Rand(.5,1)
		local Ammo=self.dt.Mass
		local Frac=1-Ammo/self.MaxRoundCapacity
		if(self.dt.Energy<.01)then Flicker=math.Rand(0,.5) end
		surface.SetDrawColor(255,255,255,200*Flicker)
		for i=0,24 do
			surface.DrawLine(-15,i,19,i)
		end
		surface.SetDrawColor((4*Frac-1)*255,(-2*Frac+2)*255,(-4*Frac+1)*255,75*Flicker)
		for i=25,38 do
			surface.DrawLine(-15,i,19,i)
		end
		surface.SetDrawColor(255,255,255,200*Flicker)
		surface.DrawOutlinedRect(-15,0,35,40)
		surface.SetTextColor(0,0,0,240*Flicker)
		surface.SetTextPos(-13,1)
		surface.SetFont("JackIndFunGunSemiSmallFont")
		surface.DrawText("26")
		surface.SetTextPos(5,1)
		surface.DrawText("55.85")
		surface.SetTextPos(-5,5)
		surface.SetFont("JackIndFunGunLargeFont")
		surface.DrawText("Fe")
		surface.SetTextColor(255,255,255,200*Flicker)
		surface.SetTextPos(-4,26)
		surface.SetFont("Default")
		surface.DrawText(tostring(self.dt.Mass))
	end
	
	local Tab={
		{4,5},{4,5},{4,6},{4,6},
		{3,7},{3,7},{3,7},{2,8},
		{2,8},{2,8},{2,8},{2,8},
		{2,8},{2,8},{2,8},{2,8},
		{2,8},{2,8},{2,8},{2,8},
		{2,8},{2,9}
	}
	function JackIndFunGunIronChamberDisplay(self)
		if not(self.DisplaysOn)then return end
		local Flicker=math.Rand(.5,1)
		if(self.dt.Energy<.01)then Flicker=math.Rand(0,.5) end
		surface.SetDrawColor(255,255,255,200*Flicker)
		surface.DrawLine(5,8,8,15)
		surface.DrawLine(5,8,2,15)
		surface.DrawLine(8,15,9,20)
		surface.DrawLine(2,15,1,20)
		surface.DrawLine(9,20,9,30)
		surface.DrawLine(1,20,1,30)
		surface.DrawLine(1,30,9,30)
		if not(self.RoundChambered)then
			local Opacity=((math.sin(CurTime()*6)+1)/2)*100
			surface.SetDrawColor(255,0,0,Opacity*Flicker)
		end
		for k,v in pairs(Tab) do
			surface.DrawLine(v[1],8+k,v[2],8+k)
		end
	end
	
	local function ChangeInteger(data)
		data:ReadEntity()[data:ReadString()]=data:ReadInt()
	end
	usermessage.Hook("JackysFGIntChange",ChangeInteger)
	
	local function ChangeBool(data)
		data:ReadEntity()[data:ReadString()]=data:ReadBool()
	end
	usermessage.Hook("JackysFGBoolChange",ChangeBool)
	
	local function ChangeFloat(data)
		local Wep=data:ReadEntity()
		local Field=data:ReadString()
		local Value=data:ReadFloat()
		Wep[Field]=Value
		if((Field=="CurrentCapacitorCharge")and(Value==0))then if(Wep.ChargingSound)then Wep.ChargingSound:Stop() end end
	end
	usermessage.Hook("JackysFGFloatChange",ChangeFloat)
	
	local LastViewAng = false
	local function SimilarizeAngles(ang1, ang2)
		ang1.y = math.fmod (ang1.y, 360)
		ang2.y = math.fmod (ang2.y, 360)
		if math.abs (ang1.y - ang2.y) > 180 then
			if ang1.y - ang2.y < 0 then
				ang1.y = ang1.y + 360
			else
				ang1.y = ang1.y - 360
			end
		end
	end
	local staggerdir=VectorRand()
	local function Stagger(uCmd)
		local ply=LocalPlayer()
		if not(ply)then return end
		local Wep=ply:GetActiveWeapon()
		if(IsValid(Wep))then
			if not(Wep.IsAJackyFunGun)then return end
			local newAng = uCmd:GetViewAngles()
			if LastViewAng then
				SimilarizeAngles (LastViewAng, newAng)
				local ft = FrameTime()*5
				local argh=.2
				if(ply:Crouching())then argh=argh-.05 end
				if(ply:KeyDown(IN_ATTACK2))then argh=argh-.05 end
				staggerdir =((staggerdir + ft * VectorRand()):GetNormalized())*argh
				local diff = newAng - LastViewAng
				diff = diff * ((LocalPlayer():GetFOV())/75)
				local DerNeuAngle=LastViewAng+diff
				local addpitch=staggerdir.z*ft
				local addyaw=staggerdir.x*ft
				DerNeuAngle.pitch=DerNeuAngle.pitch+addpitch
				DerNeuAngle.yaw=DerNeuAngle.yaw+addyaw
				uCmd:SetViewAngles(DerNeuAngle)
			end
		end
		LastViewAng = uCmd:GetViewAngles()
	end 
	hook.Add("CreateMove","JackyFGStagger",Stagger)
	
	local function RemoveExplodoCrabRagdollClient(data)
		local Pos=data:ReadVector()
		for key,rag in pairs(ents.FindInSphere(Pos,50))do
			if(rag:GetClass()=="class C_ClientRagdoll")then
				if(rag:GetModel()=="models/headcrabclassic.mdl")then
					rag:Remove()
				end
			end
		end
	end
	usermessage.Hook("JackysExplodoRagdollCrabClient",RemoveExplodoCrabRagdollClient)
end

if(SERVER)then
	local NextGoTime=CurTime()
	local function Energy()
		local Time=CurTime()
		if(NextGoTime<Time)then
			NextGoTime=Time+.1
			local Guns=ents.FindByClass("wep_jack_fungun_*")
			local Carts=ents.FindByClass("ent_jack_fgc_energy_rite")
			for key,wep in pairs(Guns)do
				if(wep.DisplaysOn)then
					if(wep.dt.Ammo)then
						wep.dt.Ammo=wep.dt.Ammo-.000001*wep.ConsumptionMul
					elseif(wep.dt.Energy)then
						wep.dt.Energy=wep.dt.Energy-.000001*wep.ConsumptionMul
					end
				end
				if(wep.PowerType=="Radiosotope Thermoelectric Generator/Battery Module")then
					if(wep.dt.Ammo)then
						wep.dt.Ammo=math.Clamp(wep.dt.Ammo+.0035,0,1)
					elseif(wep.dt.Energy)then
						wep.dt.Energy=math.Clamp(wep.dt.Energy+.0035,0,1)
					end
				end
			end
			for key,cart in pairs(Carts)do
				cart.Charge=math.Clamp(cart.Charge+.0035,0,1)
			end
		end
	end
	hook.Add("Think","JackysFunGunGlobalEnergy",Energy)
	
	local function AllahuAckbar(victim,dmginfo) -- not really. The God of the book FTW
		local Attacker=dmginfo:GetAttacker()
		if(Attacker.ShouldRandomlyExplode)then
			if not(dmginfo:GetDamageType()==DMG_BLAST)then
				local Pos=dmginfo:GetDamagePosition()
				local SplooTable={}
				for i=0,10 do
					SplooTable[i]=ents.Create("env_explosion")
					SplooTable[i]:SetPos(Pos+VectorRand()*math.Rand(0,100))
					SplooTable[i]:SetKeyValue("iMagnitude","40")
					SplooTable[i]:SetOwner(Attacker)
					SplooTable[i]:Spawn()
					SplooTable[i]:Activate()
				end
				Attacker:Remove()
				for key,sploo in pairs(SplooTable) do
					sploo:Fire("explode","",0)
				end
				timer.Simple(.02,function()
					umsg.Start("JackysExplodoRagdollCrabClient")
					umsg.Vector(Pos)
					umsg.End()
				end)
			end
		end
	end
	hook.Add("EntityTakeDamage","JackysLolExplodoAttacks",AllahuAckbar)
	
	local function AwShitIDied(npc,attacker,inflictor)
		if(npc.ShouldRandomlyExplode)then
			if not(attacker==npc)then
				local Pos=npc:GetPos()
				local Sploo=ents.Create("env_explosion")
				Sploo:SetPos(Pos+VectorRand()*math.Rand(0,100))
				Sploo:SetKeyValue("iMagnitude","50")
				Sploo:SetOwner(npc)
				Sploo:Spawn()
				Sploo:Activate()
				npc:Remove()
				Sploo:Fire("explode","",0)
				timer.Simple(.02,function()
					umsg.Start("JackysExplodoRagdollCrabClient")
					umsg.Vector(Pos)
					umsg.End()
				end)
			end
		end
	end
	hook.Add("OnNPCKilled","JackysLolExplodoDeaths",AwShitIDied)
	
	--[[local function MakeExplodoCrab(ply,npc)
		if(npc:GetClass()=="npc_headcrab")then
			npc.ShouldRandomlyExplode=true
			npc:SetMaterial("models/mat_jack_explodocrab")
		end
	end
	hook.Add("PlayerSpawnedNPC","JackysLolExplodoCrabs",MakeExplodoCrab)--]]
	
	local function MakeExplodoCrabsCommand(args)
		for key,found in pairs(ents.FindByClass("npc_headcrab")) do
			found.ShouldRandomlyExplode=true
			found:SetMaterial("models/mat_jack_explodocrab")
		end
	end
	concommand.Add("ExplodoCrabs",MakeExplodoCrabsCommand)
end

function GlobalJackyFGHGDeploy(self)
	self.dt.State=1
	timer.Simple(.6,function()
		if(IsValid(self))then
			self:EmitSound("snd_jack_fgpistoldraw.wav",65,100)
		end
	end)
	if(self.NewCartridge)then
		timer.Simple(.7,function()
			if(IsValid(self))then
				self:EmitSound("snd_jack_smallcharge.wav",65,100)
				self.NewCartridge=false
				if(self.PowerType=="Self-Contained Micro Nuclear Fission Reactor")then self.Weapon:EmitSound("snd_jack_nuclearfgc_start.wav") end
				self.DisplaysOn=true
				if(SERVER)then
					umsg.Start("JackysFGBoolChange")
					umsg.Entity(self)
					umsg.String("DisplaysOn")
					umsg.Bool(self.DisplaysOn)
					umsg.End()
				end
			end
		end)
	end
	self.Weapon:SendWeaponAnim(ACT_VM_DEPLOY)
	self.Owner:GetViewModel():SetPlaybackRate(1.3)
	timer.Simple(1,function()
		if(IsValid(self))then
			self.dt.State=2
			self.Weapon:SendWeaponAnim(ACT_VM_IDLE)
		end
	end)
end

function GlobalJackyFGLGDeploy(self)
	if(self.dt.State==1)then return end
	self.dt.State=1
 	if(SERVER)then self.Owner:EmitSound("snd_jack_fglonggundraw.wav") end
	if(self.NewCartridge)then
		timer.Simple(1.4,function()
			if(IsValid(self))then
				self:EmitSound("snd_jack_smallcharge.wav",65,100)
				self.NewCartridge=false
				if(self.PowerType=="Self-Contained Micro Nuclear Fission Reactor")then self.Weapon:EmitSound("snd_jack_nuclearfgc_start.wav") end
				self.DisplaysOn=true
				if(SERVER)then
					umsg.Start("JackysFGBoolChange")
					umsg.Entity(self)
					umsg.String("DisplaysOn")
					umsg.Bool(self.DisplaysOn)
					umsg.End()
				end
			end
		end)
	end
	self.Weapon:SendWeaponAnim(ACT_VM_DEPLOY)
	self.Owner:GetViewModel():SetPlaybackRate(.5)
	timer.Simple(2,function()
		if(IsValid(self))then
			self.dt.State=2
			self.Weapon:SendWeaponAnim(ACT_VM_IDLE)
		end
	end)
end

function GlobalJackyFGDisplayToggle(self)
	if(CLIENT)then return end
	if(self.Owner:KeyDown(IN_USE))then
		if(self.DisplaysOn)then
			self.DisplaysOn=false
			umsg.Start("JackysFGBoolChange")
			umsg.Entity(self)
			umsg.String("DisplaysOn")
			umsg.Bool(self.DisplaysOn)
			umsg.End()
			self:EmitSound("snd_jack_displaysoff.wav",60,100)
		else
			self.DisplaysOn=true
			umsg.Start("JackysFGBoolChange")
			umsg.Entity(self)
			umsg.String("DisplaysOn")
			umsg.Bool(self.DisplaysOn)
			umsg.End()
			self:EmitSound("snd_jack_displayson.wav",60,100)
		end
	end
end

function GlobalJackyFGReloadKey(self)
	if not(self.dt.State==2)then return end
	if(self.dt.Heat>.15)then
		self:BurstCool()
		return
	end
end

function GlobalJackyFGLongReloadKey(self)
	if not(self.dt.State==2)then return end
	if(self.dt.Heat>.15)then
		self:BurstCool()
		self.Owner:SetAnimation(PLAYER_RELOAD)
	end
end

function GlobalJackyLoadIronSlug(self,cartridge)
	if not(self.dt.State==2)then return end
	local InitialMassRemaining=self.dt.Mass
	if(InitialMassRemaining<self.MaxRoundCapacity)then
		self.dt.State=5
		self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
		self.Owner:SetAnimation(PLAYER_RELOAD)
		self.Weapon:EmitSound("snd_jack_massload.wav",70,130)
		self.Owner:ViewPunch(Angle(1,0,0))
		timer.Simple(.2,function()
			if(IsValid(self))then
				self.Owner:ViewPunch(Angle(1,0,0))
				self.Weapon:EmitSound("snd_jack_load_iron.wav",70,130)
				self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
			end
		end)
		timer.Simple(.4,function()
			if(IsValid(self))then
				self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
				self.Owner:GetViewModel():SetPlaybackRate(1.4)
			end
		end)
		timer.Simple(.8,function()
			if(IsValid(self))then
				if(SERVER)then self.dt.Mass=self.dt.Mass+1 end
			end
		end)
		timer.Simple(1.1,function()
			if(IsValid(self))then
				self.dt.State=2
			end
		end)
		if(SERVER)then cartridge:Remove() end
	end
end

function GlobalJackyFGHGLoadEnCart(self,cartridge,powerType,heatMul,consumptionMul,charge)
	if not(self.dt.State==2)then return end
	local NewType=cartridge.PowerType
	local InitialRemaining=self.dt.Ammo
	if(((InitialRemaining<=.01)and(self.PowerType=="Self-Contained Micro Nuclear Fission Reactor"))or(self.PowerType=="High-Density Rechargeable Lithium-Ion Battery")or(self.PowerType=="Radiosotope Thermoelectric Generator/Battery Module"))then
		self.dt.State=5
		local Orig=self.DisplaysOn
		if(SERVER)then
			umsg.Start("JackysFGMagHot",self.Owner)
			umsg.Entity(self.Weapon)
			umsg.String(self.PowerType)
			umsg.End()
		end
		local TimeToStart=0.001
		if(self.PowerType=="Self-Contained Micro Nuclear Fission Reactor")then if(SERVER)then self.Weapon:EmitSound("snd_jack_nuclearfgc_end.wav") end;TimeToStart=2 end
		timer.Simple(TimeToStart,function()
			if(IsValid(self))then
				self.Weapon:SendWeaponAnim(ACT_VM_RELOAD)
				self.Owner:GetViewModel():SetPlaybackRate(.8)
				self.Owner:SetAnimation(PLAYER_RELOAD)
				self.Weapon:EmitSound(self.ReloadNoise[1],self.ReloadNoise[2],self.ReloadNoise[3])
				timer.Simple(.4,function()
					if(IsValid(self))then
						if(SERVER)then
							local Empty=ents.Create(PowerTypeToEntClassTable[self.PowerType])
							local LolAng=self.Owner:EyeAngles()
							local Pos,Ang=self.Owner:GetBonePosition(self.Owner:LookupBone("ValveBiped.Bip01_R_Hand"))
							Empty:SetPos((Pos+Ang:Up()*10-Ang:Forward()*10)+self.Owner:GetAimVector()*10)
							LolAng:RotateAroundAxis(LolAng:Forward(),90)
							LolAng:RotateAroundAxis(LolAng:Up(),180)
							Empty:SetAngles(LolAng)
							if(InitialRemaining<=.02)then Empty:SetDTBool(0,true) end
							Empty.Charge=InitialRemaining
							Empty:Spawn()
							Empty:Activate()
							Empty:GetPhysicsObject():SetVelocity(self.Owner:GetVelocity())
						end
						self.dt.Ammo=0
						
						self.DisplaysOn=false
						if(SERVER)then
							umsg.Start("JackysFGBoolChange")
							umsg.Entity(self)
							umsg.String("DisplaysOn")
							umsg.Bool(self.DisplaysOn)
							umsg.End()
						end
					end
				end)
				timer.Simple(.6,function()
					if(IsValid(self))then
						if(SERVER)then
							umsg.Start("JackysFGMagCool",self.Owner)
							umsg.Entity(self.Weapon)
							umsg.String(NewType)
							umsg.End()
						end
					end
				end)
				timer.Simple(1.5,function()
					if(IsValid(self))then
						self.DisplaysOn=Orig
						if(SERVER)then
							self.dt.Ammo=charge
							self.PowerType=powerType
							self.ConsumptionMul=consumptionMul
							self.HeatMul=heatMul
						end
						if(SERVER)then
							umsg.Start("JackysFGBoolChange")
							umsg.Entity(self)
							umsg.String("DisplaysOn")
							umsg.Bool(self.DisplaysOn)
							umsg.End()
						end
						if(NewType=="Self-Contained Micro Nuclear Fission Reactor")then self.Weapon:EmitSound("snd_jack_nuclearfgc_start.wav") end
						self:EmitSound("snd_jack_smallcharge.wav",65,100)
					end
				end)
				timer.Simple(2,function()
					if(IsValid(self))then
						self.dt.State=2
					end
				end)
			end
		end)
		if(SERVER)then cartridge:Remove() end
	end
end

function GlobalJackyFGHGLoadEnCartNoPrim(self,cartridge,powerType,heatMul,consumptionMul,charge)
	if not(self.dt.State==2)then return end
	local NewType=cartridge.PowerType
	local InitialRemaining=self.dt.Energy
	if(((InitialRemaining<=.01)and(self.PowerType=="Self-Contained Micro Nuclear Fission Reactor"))or(self.PowerType=="High-Density Rechargeable Lithium-Ion Battery")or(self.PowerType=="Radiosotope Thermoelectric Generator/Battery Module"))then
		self.dt.State=5
		local Orig=self.DisplaysOn
		if(SERVER)then
			umsg.Start("JackysFGMagHot",self.Owner)
			umsg.Entity(self.Weapon)
			umsg.String(self.PowerType)
			umsg.End()
		end
		local TimeToStart=0.001
		if(self.PowerType=="Self-Contained Micro Nuclear Fission Reactor")then if(SERVER)then self.Weapon:EmitSound("snd_jack_nuclearfgc_end.wav") end;TimeToStart=2 end
		timer.Simple(TimeToStart,function()
			if(IsValid(self))then
				self.Weapon:SendWeaponAnim(ACT_VM_RELOAD)
				self.Owner:GetViewModel():SetPlaybackRate(.8)
				self.Owner:SetAnimation(PLAYER_RELOAD)
				self.Weapon:EmitSound(self.ReloadNoise[1],self.ReloadNoise[2],self.ReloadNoise[3])
				timer.Simple(.4,function()
					if(IsValid(self))then
						if(SERVER)then
							local Empty=ents.Create(PowerTypeToEntClassTable[self.PowerType])
							local LolAng=self.Owner:EyeAngles()
							local Pos,Ang=self.Owner:GetBonePosition(self.Owner:LookupBone("ValveBiped.Bip01_R_Hand"))
							Empty:SetPos((Pos+Ang:Up()*10-Ang:Forward()*10)+self.Owner:GetAimVector()*10)
							LolAng:RotateAroundAxis(LolAng:Forward(),90)
							LolAng:RotateAroundAxis(LolAng:Up(),180)
							Empty:SetAngles(LolAng)
							if(InitialRemaining<=.02)then Empty:SetDTBool(0,true) end
							Empty.Charge=InitialRemaining
							Empty:Spawn()
							Empty:Activate()
							Empty:GetPhysicsObject():SetVelocity(self.Owner:GetVelocity())
						end
						self.dt.Energy=0
						
						self.DisplaysOn=false
						if(SERVER)then
							umsg.Start("JackysFGBoolChange")
							umsg.Entity(self)
							umsg.String("DisplaysOn")
							umsg.Bool(self.DisplaysOn)
							umsg.End()
						end
					end
				end)
				timer.Simple(.6,function()
					if(IsValid(self))then
						if(SERVER)then
							umsg.Start("JackysFGMagCool",self.Owner)
							umsg.Entity(self.Weapon)
							umsg.String(NewType)
							umsg.End()
						end
					end
				end)
				timer.Simple(1.5,function()
					if(IsValid(self))then
						self.DisplaysOn=Orig
						if(SERVER)then
							self.dt.Energy=charge
							self.PowerType=powerType
							self.ConsumptionMul=consumptionMul
							self.HeatMul=heatMul
						end
						if(SERVER)then
							umsg.Start("JackysFGBoolChange")
							umsg.Entity(self)
							umsg.String("DisplaysOn")
							umsg.Bool(self.DisplaysOn)
							umsg.End()
						end
						if(NewType=="Self-Contained Micro Nuclear Fission Reactor")then self.Weapon:EmitSound("snd_jack_nuclearfgc_start.wav") end
						self:EmitSound("snd_jack_smallcharge.wav",65,100)
					end
				end)
				timer.Simple(2,function()
					if(IsValid(self))then
						self.dt.State=2
					end
				end)
			end
		end)
		if(SERVER)then cartridge:Remove() end
	end
end

function GlobalJackyFGLGLoadEnCart(self,cartridge,powerType,heatMul,consumptionMul,charge,rate)
	if not(self.dt.State==2)then return end
	local NewType=cartridge.PowerType
	local InitialRemaining=self.dt.Ammo
	if(((InitialRemaining<=.01)and(self.PowerType=="Self-Contained Micro Nuclear Fission Reactor"))or(self.PowerType=="High-Density Rechargeable Lithium-Ion Battery")or(self.PowerType=="Radiosotope Thermoelectric Generator/Battery Module"))then
		self.dt.State=5
		local Orig=self.DisplaysOn
		if(SERVER)then
			umsg.Start("JackysFGMagHot",self.Owner)
			umsg.Entity(self.Weapon)
			umsg.String(self.PowerType)
			umsg.End()
		end
		local TimeToStart=0.001
		if(self.PowerType=="Self-Contained Micro Nuclear Fission Reactor")then if(SERVER)then self.Weapon:EmitSound("snd_jack_nuclearfgc_end.wav") end;TimeToStart=2 end
		timer.Simple(TimeToStart,function()
			if(IsValid(self))then
				self.Weapon:SendWeaponAnim(ACT_VM_RELOAD)
				self.Owner:GetViewModel():SetPlaybackRate(.6*rate)
				self.Owner:SetAnimation(PLAYER_RELOAD)
				if(SERVER)then self.Weapon:EmitSound(self.ReloadNoise[1],self.ReloadNoise[2],self.ReloadNoise[3]) end
				timer.Simple(1.5,function()
					if(IsValid(self))then
						if(SERVER)then
							local Empty=ents.Create(PowerTypeToEntClassTable[self.PowerType])
							local LolAng=self.Owner:EyeAngles()
							local Pos,Ang=self.Owner:GetBonePosition(self.Owner:LookupBone("ValveBiped.Bip01_R_Hand"))
							Empty:SetPos(Pos+Ang:Up()*10-Ang:Forward()*10)
							LolAng:RotateAroundAxis(LolAng:Forward(),90)
							LolAng:RotateAroundAxis(LolAng:Up(),180)
							Empty:SetAngles(LolAng)
							if(InitialRemaining<=.02)then Empty:SetDTBool(0,true) end
							Empty.Charge=InitialRemaining
							Empty:Spawn()
							Empty:Activate()
							Empty:GetPhysicsObject():SetVelocity(self.Owner:GetVelocity())
						end
						self.dt.Ammo=0
						
						self.DisplaysOn=false
						if(SERVER)then
							umsg.Start("JackysFGBoolChange")
							umsg.Entity(self)
							umsg.String("DisplaysOn")
							umsg.Bool(self.DisplaysOn)
							umsg.End()
						end
					end
				end)
				timer.Simple(2/rate,function()
					if(IsValid(self))then
						if(SERVER)then
							umsg.Start("JackysFGMagCool",self.Owner)
							umsg.Entity(self.Weapon)
							umsg.String(self.PowerType)
							umsg.End()
						end
					end
				end)
				timer.Simple(5.6/rate,function()
					if(IsValid(self))then
						self.DisplaysOn=Orig
						if(SERVER)then
							self.dt.Ammo=charge
							self.PowerType=powerType
							self.ConsumptionMul=consumptionMul
							self.HeatMul=heatMul
						end
						if(SERVER)then
							umsg.Start("JackysFGBoolChange")
							umsg.Entity(self)
							umsg.String("DisplaysOn")
							umsg.Bool(self.DisplaysOn)
							umsg.End()
						end
						if(NewType=="Self-Contained Micro Nuclear Fission Reactor")then self.Weapon:EmitSound("snd_jack_nuclearfgc_start.wav") end
						self:EmitSound("snd_jack_smallcharge.wav",65,100)
					end
				end)
				timer.Simple(6/rate,function()
					if(IsValid(self))then
						self.dt.State=2
					end
				end)
			end
		end)
		if(SERVER)then cartridge:Remove() end
	end
end