local function Initialize()
	if(CLIENT)then
		local FontTable={
			font="DefaultFixedOutline",
			size=30,
			weight=1500,
			outline=true,
			antialias=true
		}
		surface.CreateFont("JackyDetGearFont",FontTable)
		FontTable.size=20
		surface.CreateFont("JackyDetGearFontSmall",FontTable)
	end
	JackieSplosivesFireMult=1
end
hook.Add("Initialize","JackySplosivesInitialize",Initialize)

local function Think()
	if(SERVER)then
		for key,playah in pairs(player.GetAll())do
			if(playah.JackyDetonatingOrdnance)then
				local Wap=playah:GetActiveWeapon()
				if(IsValid(Wap))then Wap:SendWeaponAnim(ACT_VM_DRAW) end
				if(math.random(1,15)==8)then playah:ViewPunch(Angle(math.Rand(-1,1),math.Rand(-.5,.5),math.Rand(-.1,.1))) end
			end
		end 
	end
end
hook.Add("Think","JackySplosivesThink",Think)

if(SERVER)then
	function JackyOrdnanceArm(item,playah,armType)
		local Num=playah:GetNetworkedInt("JackyDetGearCount")
		if(Num>0)then
			playah:SetNetworkedInt("JackyDetGearCount",Num-1)
			if(armType=="Remote")then
				numpad.OnDown(playah,KEY_PAD_0,"JackarundasRemoteOrdnanceDetonation")
			end
			item:EmitSound("snd_jack_ordnancearm.wav")
			JackyDetGearNotify(playah,"Set: "..armType)
			item.Armed=true
			if not(item.Owner)then item.Owner=playah end
		end
	end
	
	function JackyOrdnanceDisarm(item,playah,armType)
		if(item.Armed)then
			item:EmitSound("snd_jack_ordnancedisarm.wav")
			playah:SetNetworkedInt("JackyDetGearCount",math.Clamp(playah:GetNetworkedInt("JackyDetGearCount")+1,0,5))
			JackyDetGearNotify(playah,"")
		end
	end
	
	function JackySimpleOrdnanceArm(item,playah,message)
		playah:SetNetworkedInt("JackyDetGearCount",playah:GetNetworkedInt("JackyDetGearCount")-1)
		JackyDetGearNotify(playah,message)
		item:EmitSound("snd_jack_ordnancearm.wav")
		local Wap=playah:GetActiveWeapon()
		if(IsValid(Wap))then Wap:SendWeaponAnim(ACT_VM_DRAW) end
	end
	
	local function SetMult(ply,cmd,args)
		local Num=tonumber(args[1])
		if(Num)then
			print(args[1])
			JackieSplosivesFireMult=args[1]
			umsg.Start("JackieSplosivesFireMult")
			umsg.Short(args[1])
			umsg.End()
		end
	end
	concommand.Add("jackie_firemult",SetMult)

	local function RemoteOrdnanceDet(playah,cmd)
		if(playah.JackyDetonatingOrdnance)then return end
		local RemoteDetonatableItemTable={}
		for key,obj in pairs(ents.FindByClass("ent_jack_claymore"))do table.ForceInsert(RemoteDetonatableItemTable,obj) end
		for key,obj in pairs(ents.FindByClass("ent_jack_c4block"))do table.ForceInsert(RemoteDetonatableItemTable,obj) end
		--for key,obj in pairs(ents.FindByClass("ent_jack_firebomb"))do table.ForceInsert(RemoteDetonatableItemTable,obj) end
		local Items=0
		for key,item in pairs(RemoteDetonatableItemTable)do
			if not(item.Triggered)then
				if(item.Armed)then
					if(item.Owner==playah)then
						playah.JackyDetonatingOrdnance=true
						timer.Simple(1,function()
							if(IsValid(item))then
								item:Detonate()
								item.Triggered=true
							end
							timer.Simple(.65,function()
								if(IsValid(playah))then
									playah.JackyDetonatingOrdnance=false
								end
							end)
						end)
						Items=Items+1
					end
				end
			end
		end
		if(Items>0)then
			playah:EmitSound("snd_jack_detonator.wav")
			if(cmd)then
				umsg.Start("JackyDetSound",playah)
				umsg.End()
			end
		end
	end
	
	local function NumPadDet(ply) RemoteOrdnanceDet(ply,false) end
	numpad.Register("JackarundasRemoteOrdnanceDetonation",NumPadDet)
	
	local function ComDet(ply,cmd,args) RemoteOrdnanceDet(ply,true) end
	concommand.Add("jackie_rdet",ComDet)

	local function Remove(ply)
		ply:SetNetworkedInt("JackyDetGearCount",0)
	end
	hook.Add("DoPlayerDeath","JackyRemoveDetGearOnDeath",Remove)
	
	function JackyDetGearNotify(playah,message)
		umsg.Start("JackyDetGearNotify",playah)
		umsg.String(message)
		umsg.End()
	end
	
	local function Damage(target,dmginfo)
		if(target.AreJackyTailFins)then
			dmginfo:SetDamage(0)
			if(target:IsOnFire())then 
				timer.Simple(.1,function()
					if(IsValid(target))then target:Extinguish() end
				end)
			end
		end
	end
	hook.Add("EntityTakeDamage","JackySplosivesDamageHook",Damage)
elseif(CLIENT)then
	local function DetSound(data) surface.PlaySound("snd_jack_detonator.wav") end
	usermessage.Hook("JackyDetSound",DetSound)
	
	local function SetMult(data) JackieSplosivesFireMult=data:ReadShort() end
	usermessage.Hook("JackieSplosivesFireMult",SetMult)

	local JackyDetGearDraw=0
	local Pic=surface.GetTextureID("mat_jack_detgear_hud")
	local JackyDetGearMessage=""
	local NumberWordTable={}
	NumberWordTable[0]="Zero"
	NumberWordTable[1]="One"
	NumberWordTable[2]="Two"
	NumberWordTable[3]="Three"
	NumberWordTable[4]="Four"
	NumberWordTable[5]="Five"
	NumberWordTable[6]="Six"
	NumberWordTable[7]="Seven"
	NumberWordTable[8]="Eight"
	NumberWordTable[9]="Nine"
	NumberWordTable[10]="Ten"
	
	local function DetGearNotifyTrigger(data)
		JackyDetGearMessage=data:ReadString()
		JackyDetGearDraw=500
	end
	usermessage.Hook("JackyDetGearNotify",DetGearNotifyTrigger)
	
	local function DetGearNotify()
		if(JackyDetGearDraw>0)then
			local playah=LocalPlayer()
			local num=playah:GetNetworkedInt("JackyDetGearCount")
			if(num)then
				if(type(num)=="number")then --weird-ass-shit, bro
					if(LocalPlayer():Alive())then
						local Height=ScrH()
						local Width=ScrW()
						surface.SetTextColor(255,255,255,math.Clamp(JackyDetGearDraw,0,255))
						surface.SetFont("JackyDetGearFontSmall")
						surface.SetTextPos(Width*.81,Height*.36)
						surface.DrawText(JackyDetGearMessage)
						surface.SetDrawColor(255,255,255,math.Clamp(JackyDetGearDraw,0,255))
						surface.SetTexture(Pic)
						surface.DrawTexturedRect(Width*.75,Height*.4,256,256)
						surface.SetTextColor(255,255,255,math.Clamp(JackyDetGearDraw,0,255))
						surface.SetFont("JackyDetGearFont")
						surface.SetTextPos(Width*.82,Height*.75)
						surface.DrawText(NumberWordTable[num])
						JackyDetGearDraw=JackyDetGearDraw-1.5
					end
				end
			end
		end
	end
	hook.Add("HUDPaint","JackyDetGearNotifyPaint",DetGearNotify)
end