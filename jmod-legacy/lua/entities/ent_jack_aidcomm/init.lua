--box
--By Jackarunda
AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')
local TAKEOFF_TIME=10
local DELIVER_TIME=60
local STATE_AWAITINGSTART=1
local STATE_AWAITINGNEXT=2
local STATE_AWAITINGDROP=3
local STATE_AWAITINGTAKEOFF=4
local NatoAlphabet={"alpha","bravo","charlie","delta","echo","foxtrot","golf","hotel","india","juliet","kilo","lima","mike","november","oscar","papa","quebec","romeo","sierra","tango","uniform","victor","whiskey","xray","yankee","zulu"}
local Numbers={"one","two","three","four","five","six","seven","eight","nine","ten","eleven","twelve","thirteen","fourteen","fifteen","sixteen","seventeen","eighteen","nineteen","twenty"}
local PackageContentsTable={
	["survival supplies"]={4,{"ent_jack_aidfood","ent_jack_aidwater","ent_jack_aidfuel_gasoline","ent_jack_aidfuel_diesel","ent_jack_aidfuel_kerosene","ent_jack_aidfuel_propane","ent_jack_aidfuel_naturalgas"}},
	["infantry munitions"]={2,{"item_ammo_357","item_ammo_ar2","item_ammo_ar2_altfire","item_ammo_crossbow","item_ammo_pistol","item_rpg_round","item_box_buckshot","item_ammo_smg1","item_ammo_smg1_grenade","item_battery","weapon_frag","weapon_slam","ent_jack_mischl2ammobox"}},
	["medical supplies"]={2,{"item_healthkit","item_healthkit","item_healthvial","item_healthvial","item_healthvial","item_healthvial","item_healthvial","item_healthvial"}},
	["40mm linked ammo"]={1,{"ent_jack_turretammobox_40mm"}},
	["9mm linked ammo"]={1,{"ent_jack_turretammobox_9mm"}},
	[".22 linked ammo"]={1,{"ent_jack_turretammobox_22"}},
	[".338 linked ammo"]={1,{"ent_jack_turretammobox_338"}},
	["9mm linked ammo"]={1,{"ent_jack_turretammobox_9mm"}},
	["5.56mm linked ammo"]={1,{"ent_jack_turretammobox_556"}},
	["7.62mm linked ammo"]={1,{"ent_jack_turretammobox_762"}},
	["12ga linked ammo"]={1,{"ent_jack_turretammobox_shot"}},
	["battery"]={1,{"ent_jack_turretbattery"}},
	["sentry turret repair kit"]={3,{"ent_jack_turretrepairkit"}},
	["radio repair kit"]={1,{"ent_jack_radiorepairkit"}},
	["sentry turret missile"]={1,{"ent_jack_turretmissilepod"}},
	["sentry turret rocket"]={1,{"ent_jack_turretrocketpod"}},
	["war mine"]={2,{"ent_jack_warmine"}},
	["paint kit"]={.5,{"ent_jack_paintcan"}},
	["small land mine"]={.25,{"ent_jack_landmine_sml"}},
	["medium land mine"]={.5,{"ent_jack_landmine_med"}},
	["large land mine"]={1,{"ent_jack_landmine_lrg"}},
	["landmine cluster bomb"]={4,{"ent_jack_clusterminebomb"}},
	["naval mine"]={3,{"ent_jack_seamine"}},
	["bounding mine"]={1,{"ent_jack_boundingmine"}},
	["slam mine"]={1,{"ent_jack_slam"}},
	["claymore mine"]={1,{"ent_jack_claymore"}}
}
ENT.Voices={}
ENT.PoweredOn=false
ENT.StructuralIntegrity=300
ENT.Broken=false
ENT.PlugPosition=Vector(0,0,1)
ENT.BatteryMaxCharge=100
ENT.HasBattery=true
function ENT:ExternalCharge(amt)
	self.BatteryCharge=self.BatteryCharge+amt
	if(self.BatteryCharge>self.BatteryMaxCharge)then self.BatteryCharge=self.BatteryMaxCharge end
end
function ENT:SpawnFunction(ply,tr)
	local SpawnPos=tr.HitPos+tr.HitNormal*16
	local ent=ents.Create("ent_jack_aidcomm")
	ent:SetPos(SpawnPos)
	ent:SetNetworkedEntity("Owenur",ply)
	ent:Spawn()
	ent:Activate()
	local effectdata=EffectData()
	effectdata:SetEntity(ent)
	util.Effect("propspawn",effectdata)
	return ent
end
function ENT:Initialize()
	self.Entity:SetModel("models/props_lab/reciever01b.mdl")
	self.Entity:SetMaterial("models/mat_jack_aidradio")
	self.Entity:SetColor(Color(50,50,50))
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)	
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.Entity:DrawShadow(true)
	local phys=self.Entity:GetPhysicsObject()
	if phys:IsValid()then
		phys:Wake()
		phys:SetMass(60)
	end
	self.State=STATE_AWAITINGSTART
	self.NextUseTime=0
	self.PackageRoomLeft=4
	self.PackageContents={}
	local Path="/npc/combine_soldier/vo/"
	local Files,Folders=file.Find("sound"..Path.."*.wav","GAME")
	self.Voices=Files
	local Settins=physenv.GetPerformanceSettings()
	if(Settins.MaxVelocity<3000)then
		Settins.MaxVelocity=3000
		physenv.SetPerformanceSettings(Settins)
	end
	self.BatteryCharge=self.BatteryMaxCharge
end
function ENT:PhysicsCollide(data, physobj)
	if((data.Speed>80)and(data.DeltaTime>0.2))then
		self.Entity:EmitSound("Computer.ImpactSoft")
		self.Entity:EmitSound("Computer.ImpactHard")
	end
	if(data.Speed>750)then
		self.StructuralIntegrity=self.StructuralIntegrity-data.Speed/10
		if(self.StructuralIntegrity<=0)then
			self:Break()
		end
	end
end
function ENT:OnTakeDamage(dmginfo)
	self.Entity:TakePhysicsDamage(dmginfo)
	local DType=dmginfo:GetDamageType()
	if((DType==536870914)or(DType==DMG_BUCKSHOT)or(DType==DMG_BULLET)or(DType==DMG_BLAST)or(DType==DMG_CLUB)or(DType==DMG_SLASH)or(DType==DMG_FALL)or(DType==DMG_CRUSH))then
		self.StructuralIntegrity=self.StructuralIntegrity-dmginfo:GetDamage()
		if(self.StructuralIntegrity<=0)then
			self:Break()
		end
	end
end
function ENT:Break()
	if not(self.Broken)then
		self:EmitSound("snd_jack_turretbreak.wav")
		self.Broken=true
		self:PowerOff()
	end
end
function ENT:FindRepairKit()
	for key,potential in pairs(ents.FindInSphere(self:GetPos(),40))do
		if(potential:GetClass()=="ent_jack_radiorepairkit")then
			return potential
		end
	end
	return nil
end
function ENT:Fix(kit)
	self.StructuralIntegrity=300
	self:EmitSound("snd_jack_turretrepair.wav",70,120)
	timer.Simple(2,function()
		if(IsValid(self))then
			self.Broken=false
			self:RemoveAllDecals()
		end
	end)
	local Empty=ents.Create("prop_ragdoll")
	Empty:SetModel("models/props_junk/cardboard_box004a_gib01.mdl")
	Empty:SetMaterial("models/mat_jack_turretrepairkit")
	Empty:SetPos(kit:GetPos())
	Empty:SetAngles(kit:GetAngles())
	Empty:Spawn()
	Empty:Activate()
	Empty:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	Empty:GetPhysicsObject():ApplyForceCenter(Vector(0,0,1000))
	Empty:GetPhysicsObject():AddAngleVelocity(VectorRand()*1000)
	SafeRemoveEntityDelayed(Empty,20)
	SafeRemoveEntity(kit)
end
function ENT:Use(activator,caller)
	if(self.StructuralIntegrity<=0)then
		local Kit=self:FindRepairKit()
		if(IsValid(Kit))then self:Fix(Kit);JackaGenericUseEffect(activator) end
	end
	if(self.Broken)then return end
	if not(self.NextUseTime<CurTime())then return end
	self.NextUseTime=CurTime()+1
	if not(self.PoweredOn)then
		self:PowerOn()
		JackaGenericUseEffect(activator)
	else
		self:PowerOff()
		JackaGenericUseEffect(activator)
	end
end
function ENT:PowerOn()
	if(self.Broken)then return end
	self.PoweredOn=true
	self:SetDTBool(0,self.PoweredOn)
	self:EmitSound("snd_jack_dronebeep.wav")
	self:EmitSound("snd_jack_metallicclick.wav")
	self:Speak("UNIT "..tostring(self:EntIndex())..": Connected to station "..tostring(math.random(1,100))..". This unit is authorized to transmit orders.")
end
function ENT:PowerOff()
	self.PoweredOn=false
	self:SetDTBool(0,self.PoweredOn)
	self:EmitSound("snd_jack_metallicclick.wav")
end
function ENT:Speak(msg)
	if not(self.PoweredOn)then return end
	for key,ply in pairs(ents.FindInSphere(self:GetPos(),100))do
		if(ply:IsPlayer())then
			ply:PrintMessage(HUD_PRINTTALK,msg)
		end
	end
	local Path="/npc/combine_soldier/vo/"
	self:EmitSound(Path..self.Voices[math.random(1,#self.Voices)],70,120)
	timer.Simple(.75,function()
		if(IsValid(self))then
			if(self.PoweredOn)then
				self:EmitSound(Path..self.Voices[math.random(1,#self.Voices)],70,120)
			end
		end
	end)
end
function ENT:SpeakTerse(msg)
	if not(self.PoweredOn)then return end
	for key,ply in pairs(ents.FindInSphere(self:GetPos(),100))do
		if(ply:IsPlayer())then
			ply:PrintMessage(HUD_PRINTTALK,msg)
		end
	end
	local Path="/npc/combine_soldier/vo/"
	if(math.random(1,2)==1)then
		self:EmitSound(Path..self.Voices[math.random(1,#self.Voices)],70,130)
	end
end
function ENT:SpeakTerseLoud(msg)
	if not(self.PoweredOn)then return end
	for key,ply in pairs(ents.FindInSphere(self:GetPos(),300))do
		if(ply:IsPlayer())then
			ply:PrintMessage(HUD_PRINTTALK,msg)
		end
	end
	local Path="/npc/combine_soldier/vo/"
	if(math.random(1,2)==1)then
		self:EmitSound(Path..self.Voices[math.random(1,#self.Voices)],75,120)
	end
end
function ENT:BeginOrder()
	if not(self.PoweredOn)then return end
	self.State=STATE_AWAITINGNEXT
	self:Speak("Roger, specify first need.")
end
function ENT:AddToOrder(str)
	if not(self.PoweredOn)then return end
	local Contents=PackageContentsTable[str]
	local Volume=Contents[1]
	local Items=Contents[2]
	if((self.PackageRoomLeft-Volume)<0)then
		self:Speak("Negative. Not enough space in container.")
		return
	end
	self.PackageRoomLeft=self.PackageRoomLeft-Volume
	for key,thing in pairs(Items)do
		table.ForceInsert(self.PackageContents,thing)
	end
	self:Speak("Affirmative. "..str..".")
	if(self.PackageRoomLeft==0)then
		self.State=STATE_AWAITINGTAKEOFF
		timer.Simple(1,function()
			if(IsValid(self))then
				self:Speak("Container full. Preparing package, stand by.")
				self:SendPackage()
			end
		end)
	else
		timer.Simple(1,function()
			if(IsValid(self))then
				self:Speak("Remaining capacity "..tostring(self.PackageRoomLeft*100).." liters. Specify next need.")
			end
		end)
	end
end
function ENT:ScrapOrder()
	self:Speak("Roger. Scrapping order.")
	self.PackageRoomLeft=4
	self.PackageContents={}
	self.State=STATE_AWAITINGSTART
end
function ENT:SendPackage()
	local DropZone=self:GetPos()
	timer.Simple(TAKEOFF_TIME,function()
		if(IsValid(self))then
			self:Speak("Be advised. "..NatoAlphabet[math.random(1,26)].." "..Numbers[math.random(1,20)].." is en route to "..tostring(math.Round(DropZone.x)).." "..tostring(math.Round(DropZone.y)).." "..tostring(math.Round(DropZone.z))..". ETA "..tostring(DELIVER_TIME).." seconds. Drop will be high-altitude and supersonic.")
			self.State=STATE_AWAITINGDROP
		end
	end)
	timer.Simple(DELIVER_TIME*math.Rand(.9,1.1),function()
		if(IsValid(self))then
			self:DeliverPackage(DropZone)
		end
	end)
end
function ENT:DeliverPackage(dz)
	local DropPos=self:FindSky(dz)
	local DropCont=table.Copy(self.PackageContents)
	if not(DropPos)then
		self:Speak("Pilot was unable to locate the dropzone. Mission is scrapped, craft is RTB.")
		self.State=STATE_AWAITINGSTART
		self.PackageContents={}
		self.PackageRoomLeft=4
		return
	else
		self:Speak("Package away. Clear dropzone.")
	end
	timer.Simple(3,function()
		if(IsValid(self))then
			sound.Play("snd_jack_flyby_drop.mp3",DropPos,150,100)
			sound.Play("snd_jack_flyby_drop.mp3",DropPos,150,100)
			sound.Play("snd_jack_flyby_drop.mp3",DropPos,150,100)
			for key,ply in pairs(player.GetAll())do
				ply:EmitSound("snd_jack_flyby_drop_far.mp3",70,100)
			end
		end
	end)
	timer.Simple(15,function()
		if(IsValid(self))then
			local Pack=ents.Create("ent_jack_aidbox")
			Pack:SetPos(DropPos-Vector(0,0,100))
			Pack.InitialVel=Vector(0,0,-2000)
			Pack.Contents=table.Copy(DropCont)
			Pack:Spawn()
			Pack:Activate()
			self.State=STATE_AWAITINGSTART
			self.PackageContents={}
			self.PackageRoomLeft=4
		end
	end)
end
function ENT:FindSky(pos)
	--[[local CheckPos=pos+Vector(0,0,40000)
	local Tries=0
	while(Tries<1000)do
		if(util.IsInWorld(CheckPos))then
			player.GetAll()[1]:SetPos(CheckPos)
			return CheckPos
		else
			CheckPos=CheckPos-Vector(0,0,100)
			Tries=Tries+1
		end
	end
	return nil--]]
	local CheckPos=pos+Vector(0,0,100)
	local Tries=0
	while(Tries<500)do
		local TrDat={}
		TrDat.start=CheckPos
		TrDat.endpos=CheckPos+Vector(0,0,50000)
		TrDat.filter={self}
		local Tr=util.TraceLine(TrDat)
		if(Tr.HitSky)then
			return Tr.HitPos-Vector(0,0,50)
		else
			Tries=Tries+1
			CheckPos=CheckPos+Vector(0,0,100)
		end
	end
	return nil
end
function ENT:Think()
	if(self.Broken)then
		self.BatteryCharge=0
		self:SetDTInt(0,self.BatteryCharge)
		if(math.random(1,2)==1)then
			local effectdata=EffectData()
			effectdata:SetOrigin(self:GetPos())
			effectdata:SetNormal(VectorRand())
			effectdata:SetMagnitude(2) --amount and shoot hardness
			effectdata:SetScale(1) --length of strands
			effectdata:SetRadius(3) --thickness of strands
			util.Effect("Sparks",effectdata,true,true)
			self:EmitSound("snd_jack_turretfizzle.wav",70,120)
		else
			local effectdata=EffectData()
			effectdata:SetOrigin(self:GetPos())
			effectdata:SetScale(1)
			util.Effect("eff_jack_tinyturretburn",effectdata,true,true)
		end
		self:NextThink(CurTime()+.75)
		return true
	end
	if(self.PoweredOn)then
		if not(self.State==STATE_AWAITINGDROP)then
			self.BatteryCharge=self.BatteryCharge-.75
			if(self.BatteryCharge<=0)then
				self:PowerOff()
			end
		end
	else
		self.BatteryCharge=self.BatteryCharge+.325
		if(self.BatteryCharge>self.BatteryMaxCharge)then self.BatteryCharge=self.BatteryMaxCharge end
	end
	self:SetDTBool(0,self.PoweredOn)
	self:SetDTInt(0,self.BatteryCharge)
	self:NextThink(CurTime()+1)
	return true
end
function ENT:SendDatMessage(str)
	local elems=string.Explode(" ",str)
	if not((elems[2])and(tonumber(elems[2])))then return end
	local Message=string.sub(str,5+string.len(elems[2])+2)
	local Receiver=Entity(tonumber(elems[2]))
	if not(IsValid(Receiver))then return end
	if not(Receiver:GetClass()=="ent_jack_aidcomm")then return end
	if(Receiver==self)then return end
	Receiver:ReceiveDatMessage(self:EntIndex(),Message)
	self:SpeakTerse("Sent: "..Message)
	return ""
end
function ENT:ReceiveDatMessage(from,msg)
	if(self.Broken)then return end
	local Power=self.PoweredOn
	if not(Power)then
		self.PoweredOn=true
		self:SetDTBool(0,self.PoweredOn)
		self:EmitSound("snd_jack_dronebeep.wav")
	end
	self:SpeakTerseLoud("Comm "..tostring(from)..": "..msg)
	if not(Power)then
		timer.Simple(1,function()
			if(IsValid(self))then
				self:PowerOff()
			end
		end)
	end
end
function ENT:ListShit()
	local Time=.1
	self:SpeakTerse("Roger, transmitting list")
	timer.Simple(.5,function()
		if(IsValid(self))then
			for key,thing in pairs(PackageContentsTable)do
				timer.Simple(Time,function()
					if(IsValid(self))then
						self:SpeakTerse(key)
					end
				end)
				Time=Time+.3
			end
		end
	end)
end
function ENT:OnRemove()
	--aw fuck you
end
function ENT:SecretListen(ply,tlk)
	if(self.Broken)then return false end
	if not(self.PoweredOn)then return false end
	if(self:WaterLevel()>0)then return false end
	local Dist=(self:GetPos()-ply:GetPos()):Length()
	if(Dist>100)then return false end
	self:SendDatMessage(tlk)
	return true
end
function ENT:Listen(ply,tlk)
	if(self.Broken)then return end
	if not(self.PoweredOn)then return end
	if(self:WaterLevel()>0)then return end
	local Dist=(self:GetPos()-ply:GetPos()):Length()
	if(Dist>100)then return end
	local Str=string.lower(tlk)
	Str=string.gsub(Str,"%,","")
	Str=string.gsub(Str,"%!","")
	Str=string.gsub(Str,"%?","")
	Str=string.gsub(Str,'%"',"")
	if(self.State==STATE_AWAITINGSTART)then
		if(Str=="requesting aid")then
			self:BeginOrder()
		elseif(Str=="requesting list")then
			self:ListShit()
		end
	elseif(self.State==STATE_AWAITINGNEXT)then
		if not(PackageContentsTable[Str]==nil)then
			self:AddToOrder(Str)
		elseif(Str=="nevermind")then
			self:ScrapOrder()
		end
	elseif(self.State==STATE_AWAITINGTAKEOFF)then
		--nope
	elseif(self.State==STATE_AWAITINGDROP)then
		--noap
	end
end
local function ChatListen(ply,txt)
	if(string.sub(txt,1,5)=="comm ")then
		local Sended=false
		for key,comm in pairs(ents.FindByClass("ent_jack_aidcomm"))do
			if(comm:SecretListen(ply,txt))then
				Sended=true
			end
		end
		if(Sended)then return "" end
	end
	timer.Simple(.25,function()
		if(IsValid(ply))then
			for key,comm in pairs(ents.FindByClass("ent_jack_aidcomm"))do
				comm:Listen(ply,txt)
			end
		end
	end)
end
hook.Add("PlayerSay","JackyAidChatListen",ChatListen)
local function Help()
	print("_______________INFO______________")
	print("turn radio on")
	print("stand nearby")
	print("say requesting aid")
	print("say what things you want")
	print("package will send when full")
	print("say nevermind to scrap package in progress")
	print("wait for drop")
	print("don't get hit")
	print("if radio dies, turn it off to let it charge")
	print("to see what's available, you can also say requesting list")
	print("_____________LIST______________")
	for key,thing in pairs(PackageContentsTable)do
		print(key)
	end
end
concommand.Add("jacky_radio_help",Help)