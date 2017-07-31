if(SERVER)then
	--[[
	local function ASS(p,k)
		JPrint(p:GetEyeTrace().Entity:GetModel())
	end
	hook.Add("KeyPress","TITS",ASS)
	--]]
	JackieNPCSpawningTable={
		Enhanced={},
		Modified={}
	}
	function JackyAlterAllegiances(npc,friendly)
		npc:AddEntityRelationship(npc,D_NU,100)
		local Fr,En,Sq="D_LI","D_HT","JIGlobalComms"
		if not(friendly)then Fr="D_HT";En="D_LI";Sq="JIGlobalEnemyComms" end
		npc:SetKeyValue("SquadName",Sq)
		npc:AddRelationship("player "..Fr.." 70")
		npc:AddRelationship("npc_citizen "..Fr.." 70")
		npc:AddRelationship("npc_combine_s "..En.." 60")
		npc:AddRelationship("npc_metropolice "..En.." 60")
		npc:AddRelationship("npc_manhack "..En.." 60")
		npc:AddRelationship("npc_rollermine "..En.." 60")
		npc:AddRelationship("npc_strider "..En.." 60")
		npc:AddRelationship("npc_helicopter "..En.." 60")
		npc:AddRelationship("npc_combinedropship "..En.." 60")
		npc:AddRelationship("npc_combinegunship "..En.." 60")
		npc:AddRelationship("npc_hunter "..En.." 60")
		npc:AddRelationship("npc_synthscanner "..En.." 60")
		npc:AddRelationship("npc_cscanner "..En.." 60")
		npc:AddRelationship("npc_turret_floor "..En.." 60")
		npc:AddRelationship("npc_turret_ceiling "..En.." 60")
		Fr,En=D_LI,D_HT
		if not(friendly)then Fr=D_HT;En=D_LI end
		npc.JIFaction=Sq
		for k,v in pairs(ents.FindByClass("npc_*"))do
			if(v.JIFaction)then
				if(v.JIFaction==Sq)then
					npc:AddEntityRelationship(v,D_LI,70)
					v:AddEntityRelationship(npc,D_LI,70)
				else
					npc:AddEntityRelationship(v,D_HT,70)
					v:AddEntityRelationship(npc,D_HT,70)
				end
			end
		end
	end
	function JackyOpSquadSpawnEvent(ent)
		local Delay=.4
		if(string.find(ent:GetClass(),"antlion"))then Delay=.8 end -- antlions burrow
		ent:DrawShadow(false)
		local effectdata=EffectData()
		effectdata:SetEntity(ent)
		--util.Effect("propspawn",effectdata)
		timer.Simple(Delay,function()
			if(IsValid(ent))then
				ent:DrawShadow(true)
			end
		end)
		ent.JackyOpSquadNPC=true
		timer.Simple(.5,function()
			if(IsValid(ent))then
				umsg.Start("JackySetClientBoolean")
					umsg.Entity(ent)
					umsg.String("JackyOpSquadNPC")
					umsg.Bool(true)
				umsg.End()
			end
		end)
	end
	function JPrint(msg)
		player.GetAll()[1]:PrintMessage(HUD_PRINTCENTER,tostring(msg))
		player.GetAll()[1]:PrintMessage(HUD_PRINTTALK,"["..tostring(math.Round(CurTime(),1)).."] "..tostring(msg))
	end
	function JackyPlayNPCAnim(npc,name,stationary,time)
		npc:RestartGesture(npc:GetSequenceInfo(npc:LookupSequence(name)).activity)
		if(stationary)then
			npc:StopMoving()
			timer.Create("JackyAnim"..npc:EntIndex(),.1,math.Round(time*10),function()
				if(IsValid(npc))then
					npc:StopMoving()
				end
			end)
		end
		--[[
		JPrint(npc:GetSequenceInfo(npc:LookupSequence(name)).activityname)
		table.foreach(npc:GetSequenceList(),print)
		--]]
	end
	JackyOpSquadsMustPreCacheHumans=true
	local AllCreatureTable={} -- cache this table. Why? *crysis nanosuit voice*: MAXIMUM EFFICIENCY.
	local NoCannonTable={"npc_helicopter","npc_combinedropship","npc_combinegunship"}
	local WarningTable={"vo/npc/male01/getdown02.wav","vo/npc/male01/headsup01.wav","vo/npc/male01/headsup02.wav","vo/npc/male01/watchout.wav"}
	local function VictimShotInFace(victim,dmginfo)
		local AttackDir=dmginfo:GetDamageForce():GetNormalized()
		local FaceDir=victim:GetAimVector()
		local DotProduct=AttackDir:DotProduct(FaceDir)
		local ApproachAngle=(-math.deg(math.asin(DotProduct))+90)
		if(ApproachAngle>=140)then
			return true
		else
			return false
		end
	end
	local function ThrowBallistically(ent,targetPos)
		local Vec=targetPos-ent:GetPos()
		local Dist=Vec:Length()
		ent:SetVelocity(1500*(Vec:GetNormalized()+Vector(0,0,Dist^1.5/500000)):GetNormalized()+VectorRand()*math.Rand(0,200))
		ent:SetAngles(ent:GetVelocity():Angle())
	end
	local function MoveCloser(shooter,enemy)
		local EnemyPos=enemy:GetPos()
		local SelfPos=shooter:GetPos()
		local Vec=EnemyPos-SelfPos
		if(Vec:Length()>2000)then
			shooter:SetLastPosition(SelfPos+Vec:GetNormalized()*495+Vector(0,0,100))
			shooter:SetSchedule(SCHED_FORCED_GO_RUN)
		end
	end
	local function ClearLoSBetween(entOne,entTwo)
		local PosOne=entOne:LocalToWorld(entOne:OBBCenter())
		local PosTwo=entTwo:LocalToWorld(entTwo:OBBCenter())
		local TrDat={}
		TrDat.start=PosOne
		TrDat.endpos=PosTwo
		TrDat.filter={entOne,entTwo}
		local Tr=util.TraceLine(TrDat)
		return not(Tr.Hit)
	end
	local function FarNotice(npc,target)
		local TargPos=target:GetPos()
		npc:UpdateEnemyMemory(target,TargPos)
		npc:EmitSound("snd_jack_mgs4alert.wav",70,100)
		local Ang=(target:GetPos()-npc:GetPos())
		Ang=Vector(Ang.x,Ang.y,0)
		npc:SetAngles(Ang:Angle())
		npc:SetEnemy(target)
		local Class=npc:GetClass()
		if(Class=="npc_combine_s")then
			JackyPlayNPCAnim(npc,"signal_advance",false,.75)
		end
	end
	local function CloseNotice(npc,target)
		if not(target:Health()>0)then return end
		local TargPos=target:GetPos()
		npc:UpdateEnemyMemory(target,TargPos)
		npc:EmitSound("snd_jack_mgs4alert.wav",70,100)
		npc:SetEnemy(target)
		local Class=npc:GetClass()
		if(Class=="npc_combine_s")then
			JackyPlayNPCAnim(npc,"signal_takecover",false,.75)
		end
	end
	local function RayClear(posOne,posTwo,ent)
		local TrDat={
			start=posOne,
			endpos=posTwo,
			filter={ent}
		}
		local Tr=util.TraceLine(TrDat)
		return !Tr.Hit
	end
	local function WithinSoManyUnitsOfEachother(entOne,entTwo,dist)
		local PosOne=entOne:GetPos()
		local PosTwo=entTwo:GetPos()
		local RealDist=(PosOne-PosTwo):Length()
		return RealDist<=dist
	end
	local function Facing(looker,lookee)
		local TrueVec=(lookee:GetPos()-looker:GetPos()):GetNormalized()
		local LookVec=looker:GetAimVector()
		local DotProduct=LookVec:DotProduct(TrueVec)
		local ApproachAngle=(-math.deg(math.asin(DotProduct))+90)
		if(ApproachAngle<=60)then
			return true
		else
			return false
		end
	end
	local function HeliRotorStrike(heli,thing)
		local Kaschling=DamageInfo()
		Kaschling:SetDamage(75)
		Kaschling:SetDamageType(DMG_SLASH)
		Kaschling:SetDamagePosition(thing:GetPos())
		Kaschling:SetDamageForce(VectorRand()*999999999*3) --9 nines
		Kaschling:SetAttacker(heli)
		Kaschling:SetInflictor(heli)
		thing:TakeDamageInfo(Kaschling)
		thing:EmitSound("ambient/machines/slicer1.wav")
		heli:EmitSound("ambient/machines/slicer2.wav")
		heli:SetVelocity(VectorRand()*500)
	end
	--[[----------------------------------------------------------
		This is the general damage scaling function
	-----------------------------------------------------------]]
	local function JackyOpSquadDamageHook(victim,dmginfo)
		local attacker=dmginfo:GetAttacker()
		local inflictor=dmginfo:GetInflictor()
		if not(IsValid(attacker))then return end
		if not(IsValid(victim))then return end
		if not((attacker.JackyOpSquadNPC)or(victim.JackyOpSquadNPC)or(victim.OpSquadCustomDamageTaker))then return end
		local VictimPos=victim:GetPos()
		local AttackerPos=attacker:GetPos()
		local DamType=dmginfo:GetDamageType()
		local DmgType=dmginfo:GetDamageType()
		local Mult=1
		if(attacker.JackyFirePowerMult)then
			Mult=Mult*attacker.JackyFirePowerMult
		end
		if(victim.JackyProtectionMult)then
			Mult=Mult/victim.JackyProtectionMult
		end
		if((attacker.JackyDamageGroup)and(victim.JackyDamageGroup))then
			if((attacker.JackyDamageGroup==victim.JackyDamageGroup)and not(attacker==victim))then
				Mult=Mult*.1
			end
		end
		if(victim.OpSquadAware)then -- if you get shot
			local Enemy=victim:GetEnemy()
			if not(IsValid(Enemy))then -- and you can't find the shooter
				if not((attacker:IsWorld())or(attacker:GetClass()=="trigger_hurt"))then
					local Pos=victim:GetPos()+Vector(math.random(-1000,1000),math.random(-1000,1000),0)
					victim:SetLastPosition(Pos)
					victim:StopMoving() -- then drop what you're doing
					victim:SetSchedule(SCHED_FORCED_GO_RUN) -- and fucking run
				end
			else
				if(math.random(1,4)==4)then
					victim:SetSchedule(SCHED_RUN_RANDOM)
				end
			end
		end
		if(victim.OpSquadVengeful)then
			local TheD=victim:Disposition(attacker)
			if(((TheD==D_HT)or(TheD==D_FR))and not(string.find(attacker:GetClass(),"turret")))then
				victim:AddEntityRelationship(attacker,D_HT,95)
			end
		end
		if(victim.OpSquadAutoHealer)then
			victim.OpSquadLastAlertTime=CurTime()
		end
		if((attacker.OpSquadHardHitter)and(DamType==DMG_CLUB))then
			Mult=Mult*2
			dmginfo:SetDamageForce(attacker:GetAimVector()*1e5)
		end
		if((attacker.OpSquadUltraMegaSuperPowerDeathZombie)and((DamType==DMG_CLUB)or(DamType==DMG_SLASH)))then
			Mult=Mult*10 -- HULK SMASH
			dmginfo:SetDamageForce(dmginfo:GetDamageForce():GetNormalized()*1e5*dmginfo:GetDamage())
		end
		if(victim.OpSquadStabResistantClothing)then
			local Class=attacker:GetClass()
			if((Class=="npc_headcrab_poison")or(Class=="npc_headcrab_black"))then
				if(math.Rand(0,1)<.8)then
					Mult=Mult*.01
				end
			end
		end
		if((victim.OpSquadCustomDamageTaker)and(dmginfo:IsDamageType(DMG_BLAST)))then
			if(math.random(1,5)==2)then
				victim.OpSquadCustomDamageTaker=false
				for k,ent in pairs(ents.FindInSphere(victim:GetPos(),500))do
					if(ent:GetClass()=="npc_combinedropship")then SafeRemoveEntityDelayed(ent,.05) end
				end
				SafeRemoveEntityDelayed(victim,.05)
				for i=0,20 do
					local explo=ents.Create("env_explosion")
					explo:SetOwner(attacker or game.GetWorld())
					explo:SetPos(victim:GetPos()+VectorRand()*math.Rand(0,500))
					explo:SetKeyValue("iMagnitude","100")
					explo:Spawn()
					explo:Activate()
					explo:Fire("Explode","",0)
				end
			end
		end
		if(victim.OpSquadFlameRetardantSuit)then
			if(math.random(1,6)==3)then
				if(victim:IsOnFire())then
					victim:Extinguish()
				end
			end
		end
		if(victim.OpSquadFullBodySuit)then
			if((DamType==DMG_ACID)or(DamType==DMG_POISON)or(DamType==DMG_NERVEGAS))then
				local Class=attacker:GetClass()
				if not((Class=="npc_headcrab_black")or(Class=="npc_headcrab_poison"))then -- these can circumvent the suit by piercing it
					Mult=Mult*.01
				end
			end
		end
		if(victim.OpSquadNoHeadcrab)then
			if(victim:Health()<=1)then
				local Pos=victim:GetPos()+Vector(0,0,30)
				timer.Simple(.01,function()
					for key,crab in pairs(ents.FindInSphere(Pos,90))do
						local Class=crab:GetClass()
						if((Class=="npc_headcrab")or(Class=="npc_headcrab_fast"))then
							SafeRemoveEntity(crab)
						elseif(Class=="prop_ragdoll")then
							local Moddel=crab:GetModel()
							if((Moddel=="models/headcrabclassic.mdl")or(Moddel=="models/headcrab.mdl"))then
								SafeRemoveEntity(crab)
							end
						elseif((Class=="npc_zombie")or(Class=="npc_fastzombie"))then
							crab:SetBodygroup(1,0)
						end
					end
				end)
				umsg.Start("JackyClientHeadcrabRemoval")
					umsg.Vector(Pos)
				umsg.End()
			end
		elseif(victim.OpSquadStalker)then
			if(victim.OpSquadStalkerState=="Stalking")then
				victim.OpSquadStalkerState="Normal"
				victim.OpSquadStalkerCamoAmount=victim.OpSquadStalkerCamoAmount-10
				local Zap=EffectData()
				Zap:SetEntity(victim)
				util.Effect("entity_remove",Zap,true,true)
			end
		end
		dmginfo:ScaleDamage(Mult)
	end
	hook.Add("EntityTakeDamage","JackyOpSquadDamageHook",JackyOpSquadDamageHook)
	local function JackyScaleNPCDamage(victim,hitgroup,dmginfo)
		if not(victim.JackyOpSquadNPC)then return end
		local Mult=1
		if(hitgroup==HITGROUP_HEAD)then
			if(victim.OpSquadGoodHelmet)then
				local dtype=dmginfo:GetDamageType()
				if((dtype==DMG_BULLET)or(dtype==DMG_BUCKSHOT)or(dtype==4098)or(dtype==8194)or(dtype==536875008)or(dtype==536879104)or(dtype==134217792)or(dtype==536875010))then
					local Pos=victim:GetPos()+Vector(0,0,60)+victim:GetAimVector()*10
					local Dir=VectorRand()
					Mult=Mult*.2
					victim:EmitSound("snd_jack_helmetricochet_"..math.random(1,2)..".wav",75,100)
					local Bewlat={}
					Bewlat.Num=2
					Bewlat.Src=Pos
					Bewlat.Dir=Dir
					Bewlat.Spread=Vector(0,0,0)
					Bewlat.Tracer=1
					Bewlat.TracerName="Tracer"
					Bewlat.Force=dmginfo:GetDamageForce()/2
					Bewlat.Damage=dmginfo:GetDamage()/2
					Bewlat.Attacker=dmginfo:GetAttacker()
					Bewlat.Inflictor=dmginfo:GetInflictor()
					victim:FireBullets(Bewlat)
					local effectdata=EffectData()
					effectdata:SetOrigin(Pos)
					effectdata:SetNormal(Dir)
					effectdata:SetMagnitude(2) --amount and shoot hardness
					effectdata:SetScale(.5) --length of strands
					effectdata:SetRadius(1) --thickness of strands
					util.Effect("Sparks",effectdata,true,true)
					victim:SetSequence(ACT_FLINCH_HEAD)
				end
			elseif(victim.OpSquadHelmet)then
				local dtype=dmginfo:GetDamageType()
				if((dtype==DMG_BULLET)or(dtype==DMG_BUCKSHOT)or(dtype==4098)or(dtype==8194)or(dtype==536875008)or(dtype==536879104)or(dtype==134217792)or(dtype==536875010))then
					if not(VictimShotInFace(victim,dmginfo))then
						local Pos=victim:GetPos()+Vector(0,0,60)+victim:GetAimVector()*10
						local Dir=VectorRand()
						Mult=Mult*.2
						victim:EmitSound("snd_jack_helmetricochet_"..math.random(1,2)..".wav",75,100)
						local Bewlat={}
						Bewlat.Num=2
						Bewlat.Src=Pos
						Bewlat.Dir=Dir
						Bewlat.Spread=Vector(0,0,0)
						Bewlat.Tracer=1
						Bewlat.TracerName="Tracer"
						Bewlat.Force=dmginfo:GetDamageForce()/2
						Bewlat.Damage=dmginfo:GetDamage()/2
						Bewlat.Attacker=dmginfo:GetAttacker()
						Bewlat.Inflictor=dmginfo:GetInflictor()
						victim:FireBullets(Bewlat)
						local effectdata=EffectData()
						effectdata:SetOrigin(Pos)
						effectdata:SetNormal(Dir)
						effectdata:SetMagnitude(2) --amount and shoot hardness
						effectdata:SetScale(.5) --length of strands
						effectdata:SetRadius(1) --thickness of strands
						util.Effect("Sparks",effectdata,true,true)
						victim:SetSequence(ACT_FLINCH_HEAD)
					end
				end
			end
		elseif(hitgroup==HITGROUP_CHEST)then
			if(victim.AmericanBulletResistantVest)then
				Mult=Mult*.75
			end
		end
		dmginfo:ScaleDamage(Mult)
	end
	hook.Add("ScaleNPCDamage","JackyScaleNPCDamage",JackyScaleNPCDamage)
	local NextThinkTime=CurTime()
	local NextInfrequentThinkTime=CurTime()
	local NextRandomThinkTime=CurTime()
	local NextRapidThinkTime=CurTime()
	local NextQuickThinkTime=CurTime()
	local NextSomewhatInfrequentThinkTime=CurTime()
	local NextRapidRandomThinkTime=CurTime()
	local function JackyOpSquadThinkHook()
		local Time=CurTime()
		if(NextRapidRandomThinkTime<Time)then
			--nope
			NextRapidRandomThinkTime=NextRapidRandomThinkTime+math.Rand(.05,.5)
		end
		if(NextRapidThinkTime<Time)then
			for key,found in pairs(AllCreatureTable)do
				if(found.JackyOpSquadNPC)then
					if(found.OpSquadRotorDamage)then
						local SelfPos=found:GetPos()
						for key,thing in pairs(ents.FindInSphere(SelfPos,350))do
							local Class=thing:GetClass()
							if not((Class=="npc_helicopter")or(Class=="npc_gunship")or(Class=="npc_strider"))then
								if(Class=="player")then
									if(thing:Alive())then
										local HeliToVictimVector=(thing:GetPos()-SelfPos):GetNormalized()
										local DotProduct=HeliToVictimVector:DotProduct(found:GetUp())
										local InspectionAngle=(-math.deg(math.asin(DotProduct)))
										if(InspectionAngle<10)then --if you're aBOVE the helicopter's level
											HeliRotorStrike(found,thing)
										end
									end
								elseif(thing:IsNPC())then
									if(thing:Health()>0)then
										local HeliToVictimVector=(thing:GetPos()-SelfPos):GetNormalized()
										local DotProduct=HeliToVictimVector:DotProduct(found:GetUp())
										local InspectionAngle=(-math.deg(math.asin(DotProduct)))
										if(InspectionAngle<10)then --if you're aBOVE the helicopter's level
											HeliRotorStrike(found,thing)
										end
									end
								end
							end
						end
					end
				end
			end
			NextRapidThinkTime=Time+.25
		end
		if(NextQuickThinkTime<Time)then
			for key,found in pairs(AllCreatureTable)do
				if(found.JackyOpSquadNPC)then
					if(found.OpSquadCareful)then
						local Enemy=found:GetEnemy()
						local SelfPos=found:GetPos()
						if(IsValid(Enemy))then
							local EnemyPos=Enemy:GetPos()
							local OhShit=false
							for key,crap in pairs(ents.FindInSphere(SelfPos,200))do
								local Disp=found:Disposition(crap)
								if((Disp==D_HT)or(Disp==D_FR))then
									OhShit=true
									break
								end
							end
							local Vec=EnemyPos-SelfPos
							if(OhShit)then
								if(math.random(1,6)==2)then
									if(found:GetClass()=="npc_combine_s")then
										if(math.random(1,4)==3)then
											JackyPlayNPCAnim(found,"signal_halt",false,.5)
										end
										found:SetSchedule(SCHED_RUN_FROM_ENEMY_MOB)
									else
										found:SetLastPosition(SelfPos-Vec:GetNormalized()*500)
										found:SetSchedule(SCHED_FORCED_GO_RUN)
									end
								else
									if not(found:GetClass()=="npc_combine_s")then
										found:SetSchedule(SCHED_RUN_FROM_ENEMY_MOB)
									end
								end
							end
						end
					end
				end
			end
			NextQuickThinkTime=Time+.5
		end
		if(NextThinkTime<Time)then
			for key,found in pairs(AllCreatureTable)do
				if(IsValid(found))then
					if(found.JackyOpSquadNPC)then
						local Enemy=found:GetEnemy()
						local SelfPos=found:GetPos()
						if(found.OpSquadAggressive)then
							if(IsValid(Enemy))then
								if(found:IsCurrentSchedule(SCHED_RUN_FROM_ENEMY_FALLBACK))then -- you pussy
									if(math.Rand(0,1)>.25)then
										found:StopMoving()
										found:ClearSchedule()
										if(math.random(1,2)==1)then
											found:SetLastPosition(SelfPos+found:GetRight()*75+found:GetForward()*75)
										else
											found:SetLastPosition(SelfPos-found:GetRight()*75+found:GetForward()*75)
										end
										found:SetSchedule(SCHED_FORCED_GO_RUN)
									end
								end
							end
						end
						if(found.OpSquadAware)then
							--hear shit
							if(math.random(1,2)==1)then
								if not(IsValid(found:GetEnemy()))then
									for key,thing in pairs(ents.FindInSphere(SelfPos,200))do
										if not(thing==found)then
											local Disp=found:Disposition(thing)
											if((Disp==D_HT)or(Disp==D_FR))then
												if((thing:IsPlayer())and not(GetConVar("ai_ignoreplayers")))then
													CloseNotice(found,thing)
												elseif(thing:IsNPC())then
													CloseNotice(found,thing)
												end
											end
										end
									end
								end
							end
						end
					end
				end
			end
			NextThinkTime=Time+1
		end
		if(NextSomewhatInfrequentThinkTime<Time)then
			for key,found in pairs(AllCreatureTable)do
				if(found.JackyOpSquadNPC)then
					local Enemy=found:GetEnemy()
					if(found.OpSquadAggressive)then
						if(IsValid(Enemy))then
							MoveCloser(found,Enemy)
						end
					end
					if(found.OpSquadAutoHealer)then
						local Time=CurTime()
						if not(IsValid(Enemy))then
							if not(found.OpSquadLastAlertTime)then
								found.OpSquadLastAlertTime=Time
							else
								local Health=found:Health()
								local MaxHealth=found:GetMaxHealth()
								if(Health<MaxHealth)then
									if((found.OpSquadLastAlertTime+25)<Time)then
										if(math.random(1,2)==1)then
											found:SetHealth(found:Health()+15)
										end
										found:EmitSound("snd_jack_cyborgheal.wav",65,80)
										found:StopMoving()
										if((found:Health()+1)>=MaxHealth)then
											found:RemoveAllDecals()
										end
										JackyPlayNPCAnim(found,"deathpose_back",true,5.5)
									end
								end
							end
						else
							found.OpSquadLastAlertTime=Time
						end
					end
					if(found.JackyFaction)then
						if(math.random(1,2)==1)then
							for key,dude in pairs(AllCreatureTable)do
								if not((dude.JackyFaction)and(dude.JackyFaction==found.JackyFaction))then
									if((dude.AddEntityRelationship)and(IsValid(found))and(IsValid(dude)))then
										found:AddEntityRelationship(dude,D_HT,72)
										dude:AddEntityRelationship(found,D_HT,72)
									end
								end
							end
						end
					end
				end
			end
			NextSomewhatInfrequentThinkTime=Time+7
		end
		if(NextInfrequentThinkTime<Time)then
			AllCreatureTable=ents.FindByClass("npc_*") -- less responsive but more efficient to cache this table
			if not(GetConVar("ai_ignoreplayers"))then
				table.Add(AllCreatureTable,player.GetAll()) -- players too
			end
			for key,found in pairs(AllCreatureTable)do
				if(IsValid(found))then
					if(found.JackyOpSquadNPC)then
						local Enemy=found:GetEnemy()
						local SelfPos=found:GetPos()
						if(found.JackyFinickyAmmoGiver)then
							if(math.Rand(0,1)>.333)then
								found:Fire("setammoresupplieroff","",math.Rand(0,5))
							else
								found:Fire("setammoresupplieron","",math.Rand(0,5))
							end
						end
						if(found.OpSquadAmazingHunter)then
							if not(IsValid(Enemy))then
								for key,target in pairs(AllCreatureTable)do
									if not(target==found)then
										local Disp=found:Disposition(target)
										if((Disp==D_HT)or(Disp==D_FR))then
											if(Facing(found,target))then
												if(ClearLoSBetween(found,target))then
													FarNotice(found,target)
												end
											end
										end
									end
								end
							end
						end
						if(found.OpSquadMedic)then
							if(math.random(1,2)==1)then
								local Cur=found:Health()
								local Max=found:GetMaxHealth()
								if((Cur<(Max*.9))and not(IsValid(Enemy)))then
									found:StopMoving()
									local Missing=Max-Cur
									found:SetHealth(Cur+Missing*.5)
									found:SetSequence(ACT_COWER)
									found:EmitSound("snd_jack_bandage.wav",65,100)
									JackyPlayNPCAnim(found,"deathpose_back",true,5)
									if(found:Health()>(Max*.8))then
										found:RemoveAllDecals()
									end
								end
							end
						end
						if(found.OpSquadStickTogether)then
							if(math.Rand(0,1)<=.55)then
								local MeetUpPoint=SelfPos
								local Num=1
								for key,other in pairs(AllCreatureTable)do
									if((other.JackyOpSquadNPC)and(other.OpSquadStickTogether)and(other:GetClass()==found:GetClass())and not(other==found))then
										MeetUpPoint=MeetUpPoint+other:GetPos()
										Num=Num+1
									end
								end
								MeetUpPoint=MeetUpPoint/Num -- this is known as the Centroid or Geometric Center
								found:SetLastPosition(MeetUpPoint+Vector(0,0,100))
								if(IsValid(Enemy))then
									found:SetSchedule(SCHED_FORCED_GO_RUN)
								else
									found:SetSchedule(SCHED_FORCED_GO)
								end
								if(math.random(1,4)==2)then
									if(found:GetClass()=="npc_combine_s")then
										JackyPlayNPCAnim(found,"signal_group",false,.75)
									end
								end
							end
						end
					end
				end
			end
			NextInfrequentThinkTime=Time+15
		end
		if(NextRandomThinkTime<Time)then
			for key,found in pairs(AllCreatureTable)do
				if(IsValid(found))then
					if(found.JackyOpSquadNPC)then
						local SelfPos=found:GetPos()
						local Enemy=found:GetEnemy()
						if(found.OpSquadIonBaller)then
							if(math.Rand(0,1)>.333)then
								if(IsValid(Enemy))then
									if(ClearLoSBetween(found,Enemy))then
										if(math.random(1,4)==3)then
											JackyPlayNPCAnim(found,"signal_forward",false,.5)
										end
										timer.Simple(.5,function()
											if((IsValid(Enemy))and(IsValid(found)))then
												local Index=Enemy:EntIndex()
												Enemy:SetName("AboutToGetFuckedUp"..Index)
												found:Fire("throwgrenadeattarget","AboutToGetFuckedUp"..Index)
											end
										end)
									end
								end
							end
						elseif(found.OpSquadGrenadier)then
							if(math.Rand(0,1)>.45)then
								if(IsValid(Enemy))then
									if(found:GetClass()=="npc_citizen")then
										local DangerClose=false
										for key,enpeesee in pairs(ents.FindInSphere(Enemy:GetPos(),200))do
											if(enpeesee:IsNPC())then
												if(enpeesee:GetClass()=="npc_citizen")then --MOVE!!
													DangerClose=true
												end
											elseif(enpeesee:IsPlayer())then --MOVE!!
												DangerClose=true
											end
										end
										if not(DangerClose)then
											if(Facing(found,Enemy))then
												if(ClearLoSBetween(found,Enemy))then
													JackyPlayNPCAnim(found,"reload_ar2",true,1.5)
													timer.Simple(1.5,function()
														if(IsValid(found))then
															if(IsValid(Enemy))then
																if(ClearLoSBetween(found,Enemy))then
																	JackyPlayNPCAnim(found,"shoot_ar2_alt",true,.75)
																	timer.Simple(.1,function()
																		if(IsValid(found))then
																			if(IsValid(Enemy))then
																				local Vec=found:GetAimVector()
																				local Pos=found:GetShootPos()+Vec*20-Vector(0,0,10)
																				local Tr=util.QuickTrace(Pos,Vec*200,found)
																				if not(Tr.Hit)then
																					found:EmitSound("weapons/ar2/ar2_altfire.wav",80,110)
																					sound.Play("weapons/ar2/ar2_altfire.wav",SelfPos,110,80)
																					local Poop=ents.Create("grenade_ar2")
																					Poop:SetPos(Pos)
																					Poop:SetOwner(found)
																					Poop:Spawn()
																					Poop:Activate()
																					ThrowBallistically(Poop,Enemy:GetPos())
																					local Kapang=EffectData()
																					Kapang:SetStart(Pos+Vector(0,0,3))
																					Kapang:SetScale(1)
																					Kapang:SetNormal(Vec)
																					util.Effect("eff_jack_gmod_normalmuzzle",Kapang,true,true)
																				end
																			end
																		end
																	end)
																end
															end
														end
													end)
												end
											end
										else
											if not(found.OpSquadStoic)then
												found:EmitSound(WarningTable[math.random(1,4)])
											end
										end
									else
										if(WithinSoManyUnitsOfEachother(found,Enemy,900))then
											if(math.random(1,4)==3)then
												JackyPlayNPCAnim(found,"signal_forward",false,.5)
											end
											timer.Simple(.5,function()
												if((IsValid(Enemy))and(IsValid(found)))then
													local Index=Enemy:EntIndex()
													Enemy:SetName("AboutToGetFuckedUp"..Index)
													found:Fire("throwgrenadeattarget","AboutToGetFuckedUp"..Index)
												end
											end)
										end
									end
								end
							end
						elseif(found.OpSquadMineDropper)then
							local Chance=.1
							if(IsValid(found:GetTarget()))then Chance=.9 end
							if(math.Rand(0,1)<Chance)then
								found:Fire("equipmine","1",0)
								found:Fire("deploymine","1",2)
							end
						end
						if(found.OpSquadWarspaceCannoneer)then
							if(math.random(1,3)==3)then
								if(IsValid(Enemy))then
									if not((Enemy:IsPlayer())and not(Enemy:Alive()))then
										if not(table.HasValue(NoCannonTable,Enemy:GetClass()))then
											if(ClearLoSBetween(found,Enemy))then
												local name="AboutToGetFuckedUp"..Enemy:EntIndex()
												Enemy:SetName(name)
												found:Fire("setcannontarget",name,0)
												found:Fire("dogroundattack",name,0)
											end
										end
									end
								end
							end
						end
						if(found.OpSquadRandomCroucher)then
							if(math.random(1,2)==1)then
								found:Fire("crouch","",0)
							else
								found:Fire("stand","",0)
							end
						end
						if(found.OpSquadWanderer)then
							if not(IsValid(Enemy))then
								local npcpos=SelfPos
								local Pos=npcpos+VectorRand()*750
								if(math.random(1,3)==2)then Pos=npcpos+found:GetForward()*500 end
								found:SetLastPosition(Pos)
								found:SetSchedule(SCHED_FORCED_GO_RUN)
							end
						end
						if(found.OpSquadBombDropper)then
							if(IsValid(Enemy))then
								if not((Enemy:IsPlayer())and not(Enemy:Alive()))then
									if(Enemy:GetPos().z<SelfPos.z)then			
										local name="AboutToGetFuckedUp"..Enemy:EntIndex()
										Enemy:SetName(name)
										found:Fire("dropbombattargetalways",name,0)
										found:EmitSound("npc/attack_helicopter/aheli_mine_drop1.wav")
										if(math.random(1,3)==1)then
											found:Fire("startcarpetbombing","",0)
										else
											found:Fire("stopcarpetbombing","",0)
										end
									end
								end
							else
								found:Fire("stopcarpetbombing","",0)
							end
						end
						if(found.OpSquadInconsistentHeliGunner)then
							local Random=math.random(1,10)
							if(Random==1)then
								found:Fire("disabledeadlyshooting","",0)
							elseif(Random==2)then
								found:Fire("enabledeadlyshooting","",0)
							elseif(Random==3)then
								found:Fire("startlongcycleshooting","",0)
							elseif(Random==4)then
								found:Fire("startnormalshooting","",0)
							end
						end
						if(found.OpSquadStalker)then
							if not(IsValid(Enemy))then
								if(math.random(1,3)==2)then
									if(math.Rand(0,1)>.4)then
										if not(found.OpSquadStalkerCamoIncreasing)then
											found.OpSquadStalkerCamoIncreasing=true
											found:EmitSound("snd_jack_cloakon.wav")
										end
									else
										if(found.OpSquadStalkerCamoIncreasing)then
											found.OpSquadStalkerCamoIncreasing=false
											found:EmitSound("snd_jack_cloakoff.wav")
										end
									end
								end
								if not(IsValid(found.ScannerBuddy))then
									JackyPlayNPCAnim(found,"deploy",true,1)
									timer.Simple(1.1,function()
										if(IsValid(found))then
											local Pop=ents.Create("npc_cscanner")
											Pop:SetKeyValue("SquadName","JackyCombineOpSquad")
											Pop:SetPos(SelfPos+Vector(0,0,70))
											Pop:SetKeyValue("SpotlightDisabled","1")
											Pop:SetHealth(1)
											Pop:SetMaxHealth(1)
											Pop:SetOwner(found)
											Pop.JackyOpSquadDrop={"item_battery"}
											Pop:Spawn()
											Pop:Activate()
											Pop:SetMaterial("models/mat_jack_stalkerscanner")
											Pop:SetModelScale(.25,0)
											Pop:SetColor(Color(50,50,50,255))
											Pop:GetPhysicsObject():SetVelocity(Vector(0,0,100))
											found.ScannerBuddy=Pop
										end
									end)
								else
									if not(IsValid(found.ScannerBuddy:GetEnemy()))then
										if(math.random(1,4)==1)then
											found.ScannerBuddy:SetLastPosition(SelfPos+Vector(0,0,100))
											found.ScannerBuddy:SetSchedule(SCHED_FORCED_GO_RUN)
										elseif(math.random(1,4)==2)then
											found.ScannerBuddy:SetLastPosition(SelfPos+VectorRand()*math.random(1000,20000))
											found.ScannerBuddy:SetSchedule(SCHED_FORCED_GO_RUN)
										end
									end
								end
							else
								if(found.State=="Stalking")then
									local For=found:GetForward()
									if(math.random(1,2)==1)then
										found:SetPos(SelfPos-For*10)
										found:SetLastPosition(SelfPos+found:GetRight()*100)
										found:SetSchedule(SCHED_FORCED_GO_RUN)
									else
										found:SetPos(SelfPos-For*10)
										found:SetLastPosition(SelfPos-found:GetRight()*100)
										found:SetSchedule(SCHED_FORCED_GO_RUN)
									end
								end
							end
						end
					end
				end
			end
			NextRandomThinkTime=Time+math.Rand(1,10)
		end
	end
	hook.Add("Think","JackyOpSquadThinkHook",JackyOpSquadThinkHook)
	function JackyOpSquadDeathHook(ent,attacker,inflictor)
		if not(IsValid(ent))then return end
		if not(ent.JackyOpSquadNPC)then return end
		local EntPos=ent:GetPos()
		if((ent.OpSquadHelmet)and not(ent.BuiltInHelmet))then
			umsg.Start("JackyOpSquadRemoveHelmet")
				umsg.Entity(ent)
			umsg.End()
			local Ow=ents.Create("prop_physics")
			Ow:SetModel("models/haloreach/jarinehelmet.mdl")
			local Pos,Ang=ent:GetBonePosition(6) --head
			local Right=Ang:Right()
			local Up=Ang:Up()
			local Forward=Ang:Forward()
			Ow:SetPos(Pos-Forward*59.3+Right*30-Up*2)
			Ang:RotateAroundAxis(Up,-190)
			Ang:RotateAroundAxis(Right,-95)
			Ang:RotateAroundAxis(Forward,102)
			Ang:RotateAroundAxis(Ang:Right(),20)
			Ow:SetAngles(Ang)
			Ow:Spawn()
			Ow:Activate()
			Ow:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
			SafeRemoveEntityDelayed(Ow,20)
		end
		if(ent.JackyOpSquadDrop)then
			local Pos=ent:LocalToWorld(ent:OBBCenter())
			local Vel=ent:GetVelocity()/10
			for key,val in pairs(ent.JackyOpSquadDrop)do
				if(math.Rand(0,1)>.333)then -- a 66 percent chance
					local item=ents.Create(val)
					item:SetPos(Pos+VectorRand()*math.Rand(1,20))
					item:SetAngles(VectorRand():Angle())
					item:Spawn()
					item:Activate()
					item:SetPos(ent:GetPos())
					timer.Simple(0.1,function()
						if(IsValid(item))then
							if(IsValid(item:GetPhysicsObject()))then
								item:GetPhysicsObject():SetVelocity(Vel+VectorRand())
							end
						end
					end)
				end
			end
		end
		if(ent.OpSquadStalker)then
			ent:SetMaterial("")
		end
		if(ent.OpSquadUltraMegaSuperPowerDeathZombie)then
			local explo=ents.Create("env_explosion")
			explo:SetOwner(ent)
			explo:SetPos(ent:GetPos()+Vector(0,0,20))
			explo:SetKeyValue("iMagnitude","135")
			explo:Spawn()
			explo:Activate()
			explo:Fire("Explode","",0)
			local Poof=EffectData()
			Poof:SetOrigin(ent:LocalToWorld(ent:OBBCenter())-Vector(0,0,10))
			util.Effect("eff_jack_gmod_bloodsplosion",Poof,true,true)
			umsg.Start("JackyOpSquadNoRagdoll")
				umsg.Vector(ent:GetPos())
			umsg.End()
		end
	end
	hook.Add("OnNPCKilled","JackyOpSquadDeathHook",JackyOpSquadDeathHook)
	function JackyOpSquadCreateRagdollHook(ent,ragdoll)
		if not(ent.JackyOpSquadNPC)then return end
		if(ent.OpSquadUltraMegaSuperPowerDeathZombie)then
			ragdoll:Remove()
			return
		end
		ragdoll:SetMaterial(ent:GetMaterial())
	end
	hook.Add("CreateEntityRagdoll","JackyOpSquadCreateRagdollHook",JackyOpSquadCreateRagdollHook)
elseif(CLIENT)then
	function JPrint(msg)
		LocalPlayer():ChatPrint("["..tostring(math.Round(CurTime(),1)).."] "..tostring(msg))
	end
	local function JackyOpSquadGiveHelmet(data)
		local Helm=ClientsideModel("models/haloreach/jarinehelmet.mdl")
		local Ent=data:ReadEntity()
		Helm:SetBodygroup(2,math.random(1,2))
		--Helm:SetBodygroup(1,math.random(0,1)) --their face-models vary too much for this to work
		if not(Ent)then return end
		Helm:SetPos(Ent:GetPos())
		Helm.Wearer=Ent
		Helm.IsJackyOpSquadHelmet=true
		Ent.Helmet=Helm
		local Mat=Matrix()
		Mat:Scale(Vector(1.15,1,1))
		Helm:EnableMatrix("RenderMultiply",Mat)
		Helm:SetParent(Ent)
		--Helm:SetColor(Color(200,200,200))
		Helm:SetNoDraw(true)
		Helm:FollowBone(Ent,6)
	end
	usermessage.Hook("JackyOpSquadGiveHelmet",JackyOpSquadGiveHelmet)
	local function JackyOpSquadCreateRagdollClientHook(ent,ragdoll)
		if not(ent.JackyOpSquadNPC)then return end
		ragdoll:SetMaterial(ent:GetMaterial())
	end
	hook.Add("CreateClientsideRagdoll","JackyOpSquadCreateRagdollClientHook",JackyOpSquadCreateRagdollClientHook)
	local function JackySetClientBoolean(data)
		local Ent=data:ReadEntity()
		local Key=data:ReadString()
		local Value=data:ReadBool()
		Ent[Key]=Value
	end
	usermessage.Hook("JackySetClientBoolean",JackySetClientBoolean)
	local function JackyClientHeadcrabRemoval(data)
		local Pos=data:ReadVector()
		timer.Simple(.01,function()
			for key,rag in pairs(ents.FindInSphere(Pos,90))do
				if(rag:GetClass()=="class C_ClientRagdoll")then
					local Moddel=rag:GetModel()
					if((Moddel=="models/headcrabclassic.mdl")or(Moddel=="models/headcrab.mdl"))then
						SafeRemoveEntity(rag)
					end
				end
			end
		end)
	end
	usermessage.Hook("JackyClientHeadcrabRemoval",JackyClientHeadcrabRemoval)
	local function JackyClientRagdollRemoval(data)
		local Pos=data:ReadVector()
		timer.Simple(.01,function()
			for key,rag in pairs(ents.FindInSphere(Pos,90))do
				if(rag:GetClass()=="class C_ClientRagdoll")then
					SafeRemoveEntity(rag)
				end
			end
		end)
	end
	usermessage.Hook("JackyOpSquadNoRagdoll",JackyClientRagdollRemoval)
	local function JackyOpSquadRemoveHelmet(data)
		SafeRemoveEntity(data:ReadEntity().Helmet)
	end
	usermessage.Hook("JackyOpSquadRemoveHelmet",JackyOpSquadRemoveHelmet)
	--local Avg=0
	--local Count=0
	local function JackyOpSquadOpaqueDrawFunc(bDrawingDepth,bDrawingSkybox)
		--Avg=Avg+FrameTime()
		--Count=Count+1
		--if(Count>=300)then
		--	Count=0
		--	JPrint(Avg/300)
		--	Avg=0
		--end
		for key,helm in pairs(ents.FindByClass("class C_BaseFlex"))do
			if(helm.IsJackyOpSquadHelmet)then
				if not(IsValid(helm.Wearer))then
					SafeRemoveEntity(helm)
					return
				end
				local Pos,Ang=helm.Wearer:GetBonePosition(6) --head
				local Right=Ang:Right()
				local Up=Ang:Up()
				local Forward=Ang:Forward()
				helm:SetRenderOrigin(Pos-Forward*59+Right*29.7-Up*1.8)
				Ang:RotateAroundAxis(Up,-190)
				Ang:RotateAroundAxis(Right,-95)
				Ang:RotateAroundAxis(Forward,102)
				Ang:RotateAroundAxis(Ang:Right(),20)
				helm:SetAngles(Ang)
				local PosTwo=Pos+Vector(0,0,40) -- all this shit could be avoided if the damn model just had a proper origin
				local Col=render.GetLightColor(PosTwo)
				render.SuppressEngineLighting(true)
				render.SetModelLighting(BOX_TOP,Col.r*1.5,Col.g*1.5,Col.b*1.5)
				render.SetModelLighting(BOX_BOTTOM,Col.r*.25,Col.g*.25,Col.b*.25)
				render.SetModelLighting(BOX_RIGHT,Col.r*.25,Col.g*.25,Col.b*.25)
				render.SetModelLighting(BOX_LEFT,Col.r*.25,Col.g*.25,Col.b*.25)
				render.SetModelLighting(BOX_FRONT,Col.r*.25,Col.g*.25,Col.b*.25)
				render.SetModelLighting(BOX_BACK,Col.r*.25,Col.g*.25,Col.b*.25)
				helm:DrawModel()
				render.ResetModelLighting(1,1,1)
				render.SuppressEngineLighting(false)
			end
		end
	end
	hook.Add("PostDrawOpaqueRenderables","JackyOpSquadOpaqueDrawFunc",JackyOpSquadOpaqueDrawFunc)
end
--[[ -- Bone reference table for combine soldiers
	ValveBiped.Bip01_Pelvis
	ValveBiped.Bip01_L_Thigh
	ValveBiped.Bip01_L_Calf
	ValveBiped.Bip01_L_Foot
	ValveBiped.Bip01_L_Toe0
	ValveBiped.Bip01_R_Thigh
	ValveBiped.Bip01_R_Calf
	ValveBiped.Bip01_R_Foot
	ValveBiped.Bip01_R_Toe0
	ValveBiped.Bip01_Spine
	ValveBiped.Bip01_Spine1
	ValveBiped.Bip01_Spine2
	ValveBiped.Bip01_Spine4
	ValveBiped.Bip01_Neck1
	ValveBiped.Bip01_Head1
	ValveBiped.Bip01_L_Clavicle
	ValveBiped.Bip01_L_UpperArm
	ValveBiped.Bip01_L_Forearm
	ValveBiped.Bip01_L_Hand
	ValveBiped.Bip01_L_Finger2
	ValveBiped.Bip01_L_Finger21
	ValveBiped.Bip01_L_Finger22
	ValveBiped.Bip01_L_Finger1
	ValveBiped.Bip01_L_Finger11
	ValveBiped.Bip01_L_Finger12
	ValveBiped.Bip01_L_Finger0
	ValveBiped.Bip01_L_Finger01
	ValveBiped.Bip01_L_Finger02
	ValveBiped.Bip01_R_Clavicle
	ValveBiped.Bip01_R_UpperArm
	ValveBiped.Bip01_R_Forearm
	ValveBiped.Bip01_R_Hand
	ValveBiped.Bip01_R_Finger2
	ValveBiped.Bip01_R_Finger21
	ValveBiped.Bip01_R_Finger22
	ValveBiped.Bip01_R_Finger1
	ValveBiped.Bip01_R_Finger11
	ValveBiped.Bip01_R_Finger12
	ValveBiped.Bip01_R_Finger0
	ValveBiped.Bip01_R_Finger01
	ValveBiped.Bip01_R_Finger02
	ValveBiped.Cod
	ValveBiped.Anim_Attachment_LH
	ValveBiped.Anim_Attachment_RH

	Bone reference table for citizens
	ValveBiped.Bip01_Pelvis
	ValveBiped.Bip01_Spine
	ValveBiped.Bip01_Spine1
	ValveBiped.Bip01_Spine2
	ValveBiped.Bip01_Spine4
	ValveBiped.Bip01_Neck1
	ValveBiped.Bip01_Head1
	ValveBiped.forward
	ValveBiped.Bip01_R_Clavicle
	ValveBiped.Bip01_R_UpperArm
	ValveBiped.Bip01_R_Forearm
	ValveBiped.Bip01_R_Hand
	ValveBiped.Anim_Attachment_RH
	ValveBiped.Bip01_L_Clavicle
	ValveBiped.Bip01_L_UpperArm
	ValveBiped.Bip01_L_Forearm
	ValveBiped.Bip01_L_Hand
	ValveBiped.Anim_Attachment_LH
	ValveBiped.Bip01_R_Thigh
	ValveBiped.Bip01_R_Calf
	ValveBiped.Bip01_R_Foot
	ValveBiped.Bip01_R_Toe0
	ValveBiped.Bip01_L_Thigh
	ValveBiped.Bip01_L_Calf
	ValveBiped.Bip01_L_Foot
	ValveBiped.Bip01_L_Toe0
	ValveBiped.Bip01_L_Finger4
	ValveBiped.Bip01_L_Finger41
	ValveBiped.Bip01_L_Finger42
	ValveBiped.Bip01_L_Finger3
	ValveBiped.Bip01_L_Finger31
	ValveBiped.Bip01_L_Finger32
	ValveBiped.Bip01_L_Finger2
	ValveBiped.Bip01_L_Finger21
	ValveBiped.Bip01_L_Finger22
	ValveBiped.Bip01_L_Finger1
	ValveBiped.Bip01_L_Finger11
	ValveBiped.Bip01_L_Finger12
	ValveBiped.Bip01_L_Finger0
	ValveBiped.Bip01_L_Finger01
	ValveBiped.Bip01_L_Finger02
	ValveBiped.Bip01_R_Finger4
	ValveBiped.Bip01_R_Finger41
	ValveBiped.Bip01_R_Finger42
	ValveBiped.Bip01_R_Finger3
	ValveBiped.Bip01_R_Finger31
	ValveBiped.Bip01_R_Finger32
	ValveBiped.Bip01_R_Finger2
	ValveBiped.Bip01_R_Finger21
	ValveBiped.Bip01_R_Finger22
	ValveBiped.Bip01_R_Finger1
	ValveBiped.Bip01_R_Finger11
	ValveBiped.Bip01_R_Finger12
	ValveBiped.Bip01_R_Finger0
	ValveBiped.Bip01_R_Finger01
	ValveBiped.Bip01_R_Finger02
	ValveBiped.Bip01_L_Elbow
	ValveBiped.Bip01_L_Ulna
	ValveBiped.Bip01_R_Ulna
	ValveBiped.Bip01_R_Shoulder
	ValveBiped.Bip01_L_Shoulder
	ValveBiped.Bip01_R_Trapezius
	ValveBiped.Bip01_R_Wrist
	ValveBiped.Bip01_R_Bicep
	ValveBiped.Bip01_L_Bicep
	ValveBiped.Bip01_L_Trapezius
	ValveBiped.Bip01_L_Wrist
	ValveBiped.Bip01_R_Elbow
	
	1	idle_subtle
	2	idle_angry
	3	LineIdle01
	4	LineIdle02
	5	LineIdle03
	6	LineIdle04
	7	Crouch_idleD
	8	layer_crouch_walk_no_weapon
	9	layer_crouch_run_no_weapon
	10	walk_all_Moderate
	11	walk_all
	12	run_all
	13	sprint_all
	14	Crouch_walk_all
	15	crouch_run_all_delta
	16	crouchRUNALL1
	17	Stand_to_crouch
	18	Crouch_to_stand
	19	Open_door_away
	20	Open_door_towards_right
	21	Open_door_towards_left
	22	turnleft
	23	turnright
	24	gesture_turn_left_45default
	25	gesture_turn_left_45inDelta
	26	gesture_turn_left_45outDelta
	27	gesture_turn_left_45
	28	gesture_turn_left_90default
	29	gesture_turn_left_90inDelta
	30	gesture_turn_left_90outDelta
	31	gesture_turn_left_90
	32	gesture_turn_left_180default
	33	gesture_turn_left_180inDelta
	34	gesture_turn_left_180outDelta
	35	gesture_turn_left_180
	36	gesture_turn_right_45default
	37	gesture_turn_right_45inDelta
	38	gesture_turn_right_45outDelta
	39	gesture_turn_right_45
	40	gesture_turn_right_90default
	41	gesture_turn_right_90inDelta
	42	gesture_turn_right_90outDelta
	43	gesture_turn_right_90
	44	gesture_turn_right_180default
	45	gesture_turn_right_180inDelta
	46	gesture_turn_right_180outDelta
	47	gesture_turn_right_180
	48	gesture_turn_left_45_flatdefault
	49	gesture_turn_left_45_flatinDelta
	50	gesture_turn_left_45_flatoutDelta
	51	gesture_turn_left_45_flat
	52	gesture_turn_left_90_flatdefault
	53	gesture_turn_left_90_flatinDelta
	54	gesture_turn_left_90_flatoutDelta
	55	gesture_turn_left_90_flat
	56	gesture_turn_left_180_flatdefault
	57	gesture_turn_left_180_flatinDelta
	58	gesture_turn_left_180_flatoutDelta
	59	gesture_turn_left_180_flat
	60	gesture_turn_right_45_flatdefault
	61	gesture_turn_right_45_flatinDelta
	62	gesture_turn_right_45_flatoutDelta
	63	gesture_turn_right_45_flat
	64	gesture_turn_right_90_flatdefault
	65	gesture_turn_right_90_flatinDelta
	66	gesture_turn_right_90_flatoutDelta
	67	gesture_turn_right_90_flat
	68	gesture_turn_right_180_flatdefault
	69	gesture_turn_right_180_flatinDelta
	70	gesture_turn_right_180_flatoutDelta
	71	gesture_turn_right_180_flat
	72	Startle_behind
	73	photo_react_blind
	74	photo_react_startle
	75	ThrowItem
	76	Heal
	77	Wave
	78	Wave_close
	79	DuckUnder
	80	crouchidlehide
	81	standtocrouchhide
	82	crouchhidetostand
	83	scaredidle
	84	preSkewer
	85	Fear_Reaction
	86	Fear_Reaction_Idle
	87	cower
	88	cower_Idle
	89	layer_run_protected
	90	run_protected_all
	91	run_all_panicked
	92	layer_crouchwalk_panicked
	93	walk_panicked_all
	94	crouchIdle_panicked4
	95	layer_luggage_walk
	96	luggage_walk_all
	97	layer_pace
	98	pace_all
	99	layer_walk_midspeed
	100	plaza_walk_all
	101	deathpose_front
	102	deathpose_back
	103	deathpose_right
	104	deathpose_left
	105	hunter_cit_throw_ground
	106	hunter_cit_tackle_di
	107	hunter_cit_stomp
	108	hunter_cit_tackle
	109	hunter_cit_tackle_postI
	110	cit_door
	111	injured1
	112	injured3
	113	injured1preidle
	114	injured1postidle
	115	injured4
	116	injured4_standing
	117	injured4_sit
	118	injured4_sitpostidle
	119	citizen2
	120	citizen2_stand
	121	citizen4_preaction
	122	citizen4_rise
	123	citizen4_valve
	124	gman_freeze_pose_shooting
	125	gman_freeze_pose_shot
	126	welder_idle
	127	welder_loop
	128	ss_alyx_move_pre
	129	ss_alyx_move
	130	ss_alyx_move_post
	131	ss_advisor
	132	silo_sit
	133	Idle_Angry_SMG1
	134	Idle_Angry_Shotgun
	135	Idle_SMG1_Aim
	136	Idle_SMG1_Aim_Alert
	137	idle_angry_Ar2
	138	idle_ar2_aim
	139	shoot_smg1
	140	shoot_ar2
	141	shoot_ar2_alt
	142	shoot_shotgun
	143	shoot_rpg
	144	reload_smg1
	145	reload_shotgun1
	146	reload_ar2
	147	gesture_reload_smg1spine
	148	gesture_reload_smg1arms
	149	gesture_reload_smg1
	150	gesture_reload_ar2spine
	151	gesture_reload_ar2arms
	152	gesture_reload_ar2
	153	gesture_shoot_ar2
	154	gesture_shoot_smg1
	155	gesture_shoot_shotgun
	156	gesture_shoot_rpg
	157	IdleAngryToShootDelta
	158	IdleAngryToShoot
	159	ShootToIdleAngryDelta
	160	ShootToIdleAngry
	161	IdleAngry_AR2_ToShootDelta
	162	IdleAngry_AR2_ToShoot
	163	Shoot_AR2_ToIdleAngryDelta
	164	Shoot_AR2_ToIdleAngry
	165	CrouchDToShoot
	166	ShootToCrouchD
	167	CrouchDToStand
	168	StandToCrouchD
	169	CrouchDToCrouchShoot
	170	CrouchShootToCrouchD
	171	Cover_R
	172	Cover_L
	173	CoverLow_R
	174	CoverLow_L
	175	Cover_LToShootSMG1
	176	Cover_RToShootSMG1
	177	CoverLow_LToShootSMG1
	178	CoverLow_RToShootSMG1
	179	ShootSMG1ToCover_L
	180	ShootSMG1ToCover_R
	181	ShootSMG1ToCoverLow_L
	182	ShootSMG1ToCoverLow_R
	183	crouch_shoot_smg1
	184	crouch_aim_smg1
	185	crouch_reload_smg1
	186	shootp1
	187	gesture_shootp1
	188	reload_pistol
	189	crouch_shoot_pistol
	190	crouch_reload_pistol
	191	throw1
	192	swing
	193	idle_angry_melee
	194	MeleeAttack01
	195	pickup
	196	gunrack
	197	smgdraw
	198	Fear_Reaction_gesturespine
	199	Fear_Reaction_gesturearms
	200	Fear_Reaction_gesture
	201	Wave_SMG1
	202	layer_Aim_all
	203	layer_Aim_AR2_all
	204	layer_Aim_Alert_all
	205	layer_Aim_AR2_Alert_all
	206	layer_runAim_all
	207	layer_runAim_ar2_all
	208	layer_walkAlertAim_all
	209	layer_walkAlertAim_AR2_all
	210	layer_walk_aiming
	211	layer_walk_holding
	212	layer_run_aiming
	213	layer_crouch_run_aiming
	214	layer_crouch_walk_aiming
	215	layer_walk_AR2_aiming
	216	layer_walk_AR2_holding
	217	layer_run_AR2_aiming
	218	layer_walk_alert_holding
	219	walkAlertHOLDALL1
	220	layer_walk_alert_aiming
	221	walkAlertAimALL1
	222	layer_walk_alert_holding_AR2
	223	walkAlertHOLD_AR2_ALL1
	224	layer_walk_alert_aiming_AR2
	225	walkAlertAim_AR2_ALL1
	226	layer_run_alert_holding
	227	run_alert_holding_all
	228	layer_run_alert_holding_AR2
	229	run_alert_holding_AR2_all
	230	layer_run_alert_aiming
	231	run_alert_aiming_all
	232	layer_run_alert_aiming_ar2
	233	run_alert_aiming_ar2_all
	234	walkAIMALL1
	235	walkHOLDALL1
	236	walkAIMALL1_ar2
	237	walkHOLDALL1_ar2
	238	layer_run_holding
	239	run_holding_all
	240	run_aiming_all
	241	layer_run_holding_ar2
	242	run_holding_ar2_all
	243	run_aiming_ar2_all
	244	layer_crouch_run_holding
	245	crouchRUNHOLDINGALL1
	246	crouchRUNAIMINGALL1
	247	layer_crouch_walk_holding
	248	Crouch_walk_holding_all
	249	Crouch_walk_aiming_all
	250	Man_Gun_Aim_all
	251	Man_Gun
	252	Idle_SMG1_Relaxed
	253	layer_walk_holding_SMG1_Relaxed
	254	walk_SMG1_Relaxed_all
	255	layer_run_holding_SMG1_Relaxed
	256	run_SMG1_Relaxed_all
	257	Idle_AR2_Relaxed
	258	layer_walk_holding_AR2_Relaxed
	259	walk_AR2_Relaxed_all
	260	layer_run_holding_AR2_Relaxed
	261	run_AR2_Relaxed_all
	262	Idle_RPG_Relaxed
	263	Idle_Angry_RPG
	264	Idle_RPG_Aim
	265	Crouch_Idle_RPG
	266	StandToShootRPGfake
	267	ShootToStandRPGfake
	268	CrouchToShootRPGfake
	269	ShootToCrouchRPGfake
	270	layer_walk_holding_RPG
	271	walk_holding_RPG_all
	272	layer_run_holding_RPG
	273	run_holding_RPG_all
	274	layer_crouch_walk_holding_RPG
	275	Crouch_walk_holding_RPG_all
	276	layer_crouch_run_holding_RPG
	277	crouch_run_holding_RPG_all
	278	layer_Aim_RPG_all
	279	layer_walk_holding_RPG_Relaxed
	280	walk_RPG_Relaxed_all
	281	layer_run_holding_RPG_Relaxed
	282	run_RPG_Relaxed_all
	283	layer_walk_holding_package
	284	walk_holding_package_all
	285	idle_noise
	286	Idle_Relaxed_SMG1_1
	287	Idle_Relaxed_SMG1_2
	288	Idle_Relaxed_SMG1_3
	289	Idle_Relaxed_SMG1_4
	290	Idle_Relaxed_SMG1_5
	291	Idle_Relaxed_SMG1_6
	292	Idle_Relaxed_SMG1_7
	293	Idle_Relaxed_SMG1_8
	294	Idle_Relaxed_SMG1_9
	295	Idle_Relaxed_AR2_1
	296	Idle_Relaxed_AR2_2
	297	Idle_Relaxed_AR2_3
	298	Idle_Relaxed_AR2_4
	299	Idle_Relaxed_AR2_5
	300	Idle_Relaxed_AR2_6
	301	Idle_Relaxed_AR2_7
	302	Idle_Relaxed_AR2_8
	303	Idle_Relaxed_AR2_9
	304	Idle_Alert_SMG1_1
	305	Idle_Alert_SMG1_2
	306	Idle_Alert_SMG1_3
	307	Idle_Alert_SMG1_4
	308	Idle_Alert_SMG1_5
	309	Idle_Alert_SMG1_6
	310	Idle_Alert_SMG1_7
	311	Idle_Alert_SMG1_8
	312	Idle_Alert_SMG1_9
	313	Idle_Alert_AR2_1
	314	Idle_Alert_AR2_2
	315	Idle_Alert_AR2_3
	316	Idle_Alert_AR2_4
	317	Idle_Alert_AR2_5
	318	Idle_Alert_AR2_6
	319	Idle_Alert_AR2_7
	320	Idle_Alert_AR2_8
	321	Idle_Alert_AR2_9
	322	Idle_Relaxed_Shotgun_1
	323	Idle_Relaxed_Shotgun_2
	324	Idle_Relaxed_Shotgun_3
	325	Idle_Relaxed_Shotgun_4
	326	Idle_Relaxed_Shotgun_5
	327	Idle_Relaxed_Shotgun_6
	328	Idle_Relaxed_Shotgun_7
	329	Idle_Relaxed_Shotgun_8
	330	Idle_Relaxed_Shotgun_9
	331	Idle_Alert_Shotgun_1
	332	Idle_Alert_Shotgun_2
	333	Idle_Alert_Shotgun_3
	334	Idle_Alert_Shotgun_4
	335	Idle_Alert_Shotgun_5
	336	Idle_Alert_Shotgun_6
	337	Idle_Alert_Shotgun_7
	338	Idle_Alert_Shotgun_8
	339	Idle_Alert_Shotgun_9
	340	jump_holding_jump
	341	jump_holding_glide
	342	jump_holding_land
	343	Seafloor_Poses
	344	Idle_to_Lean_Left
	345	Lean_Left
	346	Lean_Left_to_Idle
	347	Idle_to_Lean_Back
	348	Lean_Back
	349	Lean_Back_to_Idle
	350	Idle_to_Sit_Ground
	351	Sit_Ground
	352	Sit_Ground_to_Idle
	353	Idle_to_Sit_Chair
	354	Sit_Chair
	355	Sit_Chair_to_Idle
	356	body_rot_z
	357	spine_rot_z
	358	neck_trans_x
	359	head_rot_z
	360	head_rot_y
	361	head_rot_x
	362	idle_reference
	363	roofidle1
	364	roofidle2
	365	roofwatch1
	366	forcescanner
	367	preforcescanner
	368	postforcescanner
	369	sitchair1
	370	sitchairtable1
	371	sitcouchfeet1
	372	sitcouchknees1
	373	sitcouch1
	374	sitccouchtv1
	375	laycouch1
	376	laycouch1_exit
	377	drinker_sit
	378	drinker_sit_idle
	379	drinker_sit_ss
	380	drinker_sit_idle_ss
	381	takepackage
	382	idlepackage
	383	spreadwallidle
	384	roofwatch2
	385	lookoutidle
	386	lookoutrun
	387	roofslide
	388	plazaidle1
	389	plazaidle2
	390	plazaidle3
	391	plazaidle4
	392	plazastand1
	393	plazastand2
	394	plazastand3
	395	plazastand4
	396	apcarrestidle
	397	apcarrestslam
	398	arrestidle
	399	arrestcurious
	400	d1_t01_TrainRide_Sit_Idle
	401	d1_t01_TrainRide_Sit_Exit
	402	d1_t01_TrainRide_Stand
	403	d1_t01_TrainRide_Stand_Exit
	404	d1_t01_Luggage_Idle
	405	d1_t01_Luggage_Drop
	406	Idle_to_d1_t01_BreakRoom_Sit01
	407	d1_t01_BreakRoom_Sit01_Idle
	408	d1_t01_BreakRoom_Sit01_to_Idle
	409	d1_t01_BreakRoom_Sit02_Entry
	410	d1_t01_BreakRoom_Sit02
	411	d1_t01_BreakRoom_Sit02_Exit
	412	idlenoise
	413	d1_t01_BreakRoom_WatchClock
	414	d1_t01_BreakRoom_WatchBreen
	415	d1_t01_BreakRoom_WatchClock_Sit_Entry
	416	d1_t01_BreakRoom_WatchClock_Sit
	417	d1_t01_Interrogation_Idle
	418	d1_t02_Plaza_Scan_ID
	419	d1_t02_Playground_Cit1_Arms_Crossed
	420	d1_t02_Playground_Cit2_Pockets
	421	d1_t02_Plaza_Sit02
	422	d1_t02_Plaza_Sit01_Idle
	423	d1_t03_Tenements_Look_Out_Door_Idle
	424	d1_t03_Tenements_Look_Out_Door_Close
	425	d1_t03_Tenements_Look_Out_Window_Idle
	426	d1_t03_PreRaid_Peek_Idle
	427	d1_t03_PreRaid_Peek_Exit
	428	doorBracer_PreIdle
	429	doorBracer_ShutDoor
	430	doorBracer_Closed
	431	doorBracer_Struggle
	432	doorBracer_BustThru
	433	d1_t03_sit_couch_consoling
	434	luggageidle
	435	luggageshrug
	436	luggagepush
	437	ts_luggageShove_all
	438	Streetwar_CoverShoot_L
	439	Trainstation_Int
	440	Lying_Down
	441	podpose
	442	arrestpreidle
	443	arrestpunch
	444	arrestpostidle
	445	boxcaropen
	446	Canals_Matt_laydown
	447	Canals_Matt_whoareyou
	448	Canals_Matt_sitonedge
	449	Canals_Matt_beglad
	450	Canals_Matt_OhShit
	451	d1_canals_06_bridge_check
	452	mapcircle
	453	idlenoise2
	454	d1_town05_Winston_Down
	455	d1_town05_Wounded_Idle_1
	456	d1_town05_Wounded_Idle_2
	457	d1_town05_Daniels_Kneel_Entry
	458	d1_town05_Daniels_Kneel_Idle
	459	d1_town05_Leon_Idle_SMG1
	460	d1_town05_Leon_Door_Knock
	461	d1_town05_Leon_Lean_Table_Entry
	462	d1_town05_Leon_Lean_Table_Idle
	463	d1_town05_Leon_Lean_Table_Exit
	464	d1_town05_Leon_Lean_Table_Entry_NoGun
	465	d1_town05_Leon_Lean_Table_Posture_Entry
	466	d1_town05_Leon_Lean_Table_Posture_Idle
	467	d1_town05_Leon_Lean_Table_Posture_Exit
	468	headcrabbed
	469	headcrabbedpost
	470	d2_coast03_Odessa_RPG_Give
	471	d2_coast03_Odessa_RPG_Give_Idle
	472	d2_coast03_Odessa_RPG_Give_Exit
	473	d2_coast03_Odessa_Stand_RPG
	474	idle_alert_01
	475	idle_alert_02
	476	d2_coast03_PreBattle_Scan_Skies
	477	d2_coast03_PreBattle_Scan_Skies02
	478	d2_coast03_PreBattle_Scan_Skies03
	479	d2_coast03_PreBattle_Scan_Skies_Respond
	480	d2_coast03_PreBattle_Kneel_Idle
	481	d2_coast03_PreBattle_Stand_Look
	482	d2_coast03_PostBattle_Idle01_Entry
	483	d2_coast03_PostBattle_Idle01
	484	d2_coast03_PostBattle_Idle02_Entry
	485	d2_coast03_PostBattle_Idle02
	486	d2_coast_03_antlion_shove
	487	d2_coast11_Tobias
	488	antmanidle
	489	antmanstand
	490	d3_c17_03_tower_idle
	491	d3_c17_03_tower_wave
	492	d3_c17_03_throw_from_tower
	493	d3_c17_03_climb_rope
	494	d3_c17_03_climb_edge
	495	pullrope1idle
	496	pullrope2idle
	497	pullrope3idle
	498	droprope1
	499	droprope3
	500	cheer1
	501	cheer2
	502	sniper_victim_pre
	503	sniper_victim_die
	504	sniper_victim_post
	505	reference
	506	g_placeholderapexArms
	507	g_placeholderapexSpine
	508	g_placeholderapexDelta
	509	g_placeholderloopArms
	510	g_placeholderloopSpine
	511	g_placeholderaccentDelta
	512	g_placeholder
	513	g_preRaid_BeckonapexArms
	514	g_preRaid_BeckonapexSpine
	515	g_preRaid_BeckonapexDelta
	516	g_preRaid_BeckonloopArms
	517	g_preRaid_BeckonloopSpine
	518	g_preRaid_BeckonaccentDelta
	519	g_preRaid_Beckon
	520	g_BreakRoom_WatchClockapexArms
	521	g_BreakRoom_WatchClockapexSpine
	522	g_BreakRoom_WatchClockapexDelta
	523	g_BreakRoom_WatchClockloopArms
	524	g_BreakRoom_WatchClockloopSpine
	525	g_BreakRoom_WatchClockaccentDelta
	526	g_BreakRoom_WatchClock
	527	g_BreakRoom_Sit_01apexArms
	528	g_BreakRoom_Sit_01apexSpine
	529	g_BreakRoom_Sit_01apexDelta
	530	g_BreakRoom_Sit_01loopArms
	531	g_BreakRoom_Sit_01loopSpine
	532	g_BreakRoom_Sit_01accentDelta
	533	g_BreakRoom_Sit_01
	534	g_Breencast_Watcher_ResponseapexArms
	535	g_Breencast_Watcher_ResponseapexSpine
	536	g_Breencast_Watcher_ResponseapexDelta
	537	g_Breencast_Watcher_ResponseloopArms
	538	g_Breencast_Watcher_ResponseloopSpine
	539	g_Breencast_Watcher_ResponseaccentDelta
	540	g_Breencast_Watcher_Response
	541	g_Pacer_ArmsCrossedapexArms
	542	g_Pacer_ArmsCrossedapexSpine
	543	g_Pacer_ArmsCrossedapexDelta
	544	g_Pacer_ArmsCrossedloopArms
	545	g_Pacer_ArmsCrossedloopSpine
	546	g_Pacer_ArmsCrossedaccentDelta
	547	g_Pacer_ArmsCrossed
	548	g_Tenements_Look_Out_Window_RespondapexArms
	549	g_Tenements_Look_Out_Window_RespondapexSpine
	550	g_Tenements_Look_Out_Window_RespondapexDelta
	551	g_Tenements_Look_Out_Window_RespondloopArms
	552	g_Tenements_Look_Out_Window_RespondloopSpine
	553	g_Tenements_Look_Out_Window_RespondaccentDelta
	554	g_Tenements_Look_Out_Window_Respond
	555	g_Tenements_Look_Out_Window_Respond_bapexArms
	556	g_Tenements_Look_Out_Window_Respond_bapexSpine
	557	g_Tenements_Look_Out_Window_Respond_bapexDelta
	558	g_Tenements_Look_Out_Window_Respond_bloopArms
	559	g_Tenements_Look_Out_Window_Respond_bloopSpine
	560	g_Tenements_Look_Out_Window_Respond_baccentDelta
	561	g_Tenements_Look_Out_Window_Respond_b
	562	g_scan_IDapexArms
	563	g_scan_IDapexSpine
	564	g_scan_IDapexDelta
	565	g_scan_IDloopArms
	566	g_scan_IDloopSpine
	567	g_scan_IDaccentDelta
	568	g_scan_ID
	569	g_plead_01apexArms
	570	g_plead_01apexSpine
	571	g_plead_01apexDelta
	572	g_plead_01loopArms
	573	g_plead_01loopSpine
	574	g_plead_01accentDelta
	575	g_plead_01
	576	G_medpuct_midapexArms
	577	G_medpuct_midapexSpine
	578	G_medpuct_midapexDelta
	579	G_medpuct_midloopArms
	580	G_medpuct_midloopSpine
	581	G_medpuct_midaccentDelta
	582	G_medpuct_mid
	583	G_noway_smallapexArms
	584	G_noway_smallapexSpine
	585	G_noway_smallapexDelta
	586	G_noway_smallloopArms
	587	G_noway_smallloopSpine
	588	G_noway_smallaccentDelta
	589	G_noway_small
	590	G_noway_bigapexArms
	591	G_noway_bigapexSpine
	592	G_noway_bigapexDelta
	593	G_noway_bigloopArms
	594	G_noway_bigloopSpine
	595	G_noway_bigaccentDelta
	596	G_noway_big
	597	G_shrugapexArms
	598	G_shrugapexSpine
	599	G_shrugapexDelta
	600	G_shrugloopArms
	601	G_shrugloopSpine
	602	G_shrugaccentDelta
	603	G_shrug
	604	G_medurgent_midapexArms
	605	G_medurgent_midapexSpine
	606	G_medurgent_midapexDelta
	607	G_medurgent_midloopArms
	608	G_medurgent_midloopSpine
	609	G_medurgent_midaccentDelta
	610	G_medurgent_mid
	611	G_whatapexArms
	612	G_whatapexSpine
	613	G_whatapexDelta
	614	G_whatloopArms
	615	G_whatloopSpine
	616	G_whataccentDelta
	617	G_what
	618	G_lookapexArms
	619	G_lookapexSpine
	620	G_lookapexDelta
	621	G_lookloopArms
	622	G_lookloopSpine
	623	G_lookaccentDelta
	624	G_look
	625	G_look_smallapexArms
	626	G_look_smallapexSpine
	627	G_look_smallapexDelta
	628	G_look_smallloopArms
	629	G_look_smallloopSpine
	630	G_look_smallaccentDelta
	631	G_look_small
	632	G_lookatthisapexArms
	633	G_lookatthisapexSpine
	634	G_lookatthisapexDelta
	635	G_lookatthisloopArms
	636	G_lookatthisloopSpine
	637	G_lookatthisaccentDelta
	638	G_lookatthis
	639	G_righthandrollapexArms
	640	G_righthandrollapexSpine
	641	G_righthandrollapexDelta
	642	G_righthandrollloopArms
	643	G_righthandrollloopSpine
	644	G_righthandrollaccentDelta
	645	G_righthandroll
	646	G_righthandheavyapexArms
	647	G_righthandheavyapexSpine
	648	G_righthandheavyapexDelta
	649	G_righthandheavyloopArms
	650	G_righthandheavyloopSpine
	651	G_righthandheavyaccentDelta
	652	G_righthandheavy
	653	G_righthandpointapexArms
	654	G_righthandpointapexSpine
	655	G_righthandpointapexDelta
	656	G_righthandpointloopArms
	657	G_righthandpointloopSpine
	658	G_righthandpointaccentDelta
	659	G_righthandpoint
	660	G_lefthandmotionapexArms
	661	G_lefthandmotionapexSpine
	662	G_lefthandmotionapexDelta
	663	G_lefthandmotionloopArms
	664	G_lefthandmotionloopSpine
	665	G_lefthandmotionaccentDelta
	666	G_lefthandmotion
	667	G_righthandmotionapexArms
	668	G_righthandmotionapexSpine
	669	G_righthandmotionapexDelta
	670	G_righthandmotionloopArms
	671	G_righthandmotionloopSpine
	672	G_righthandmotionaccentDelta
	673	G_righthandmotion
	674	G_puncuateapexArms
	675	G_puncuateapexSpine
	676	G_puncuateapexDelta
	677	G_puncuateloopArms
	678	G_puncuateloopSpine
	679	G_puncuateaccentDelta
	680	G_puncuate
	681	GestureButtonapexArms
	682	GestureButtonapexSpine
	683	GestureButtonapexDelta
	684	GestureButtonloopArms
	685	GestureButtonloopSpine
	686	GestureButtonaccentDelta
	687	GestureButton
	688	g_SMG1_StopapexArms
	689	g_SMG1_StopapexSpine
	690	g_SMG1_StopapexDelta
	691	g_SMG1_StoploopArms
	692	g_SMG1_StoploopSpine
	693	g_SMG1_StopaccentDelta
	694	g_SMG1_Stop
	695	g_antman_staybackdefault
	696	g_antman_staybackapexDelta
	697	g_antman_staybackloopDelta
	698	g_antman_stayback
	699	g_antman_dontmovedefault
	700	g_antman_dontmoveapexDelta
	701	g_antman_dontmoveloopDelta
	702	g_antman_dontmove
	703	g_antman_punctuatedefault
	704	g_antman_punctuateapexDelta
	705	g_antman_punctuateloopDelta
	706	g_antman_punctuate
	707	g_fistapexArms
	708	g_fistapexSpine
	709	g_fistapexDelta
	710	g_fistloopArms
	711	g_fistloopSpine
	712	g_fistaccentDelta
	713	g_fist
	714	g_fist_LapexArms
	715	g_fist_LapexSpine
	716	g_fist_LapexDelta
	717	g_fist_LloopArms
	718	g_fist_LloopSpine
	719	g_fist_LaccentDelta
	720	g_fist_L
	721	g_fist_swing_acrossapexArms
	722	g_fist_swing_acrossapexSpine
	723	g_fist_swing_acrossapexDelta
	724	g_fist_swing_acrossloopArms
	725	g_fist_swing_acrossloopSpine
	726	g_fist_swing_acrossaccentDelta
	727	g_fist_swing_across
	728	g_point_swingapexArms
	729	g_point_swingapexSpine
	730	g_point_swingapexDelta
	731	g_point_swingloopArms
	732	g_point_swingloopSpine
	733	g_point_swingaccentDelta
	734	g_point_swing
	735	g_point_swing_acrossapexArms
	736	g_point_swing_acrossapexSpine
	737	g_point_swing_acrossapexDelta
	738	g_point_swing_acrossloopArms
	739	g_point_swing_acrossloopSpine
	740	g_point_swing_acrossaccentDelta
	741	g_point_swing_across
	742	g_mid_relaxed_fist_accentapexArms
	743	g_mid_relaxed_fist_accentapexSpine
	744	g_mid_relaxed_fist_accentapexDelta
	745	g_mid_relaxed_fist_accentloopArms
	746	g_mid_relaxed_fist_accentloopSpine
	747	g_mid_relaxed_fist_accentaccentDelta
	748	g_mid_relaxed_fist_accent
	749	g_presentapexArms
	750	g_presentapexSpine
	751	g_presentapexDelta
	752	g_presentloopArms
	753	g_presentloopSpine
	754	g_presentaccentDelta
	755	g_present
	756	g_d2_coast03_Kneel_CallapexArms
	757	g_d2_coast03_Kneel_CallapexSpine
	758	g_d2_coast03_Kneel_CallapexDelta
	759	g_d2_coast03_Kneel_CallloopArms
	760	g_d2_coast03_Kneel_CallloopSpine
	761	g_d2_coast03_Kneel_CallaccentDelta
	762	g_d2_coast03_Kneel_Call
	763	g_d2_coast03_PostBattle_Idle01apexArms
	764	g_d2_coast03_PostBattle_Idle01apexSpine
	765	g_d2_coast03_PostBattle_Idle01apexDelta
	766	g_d2_coast03_PostBattle_Idle01loopArms
	767	g_d2_coast03_PostBattle_Idle01loopSpine
	768	g_d2_coast03_PostBattle_Idle01accentDelta
	769	g_d2_coast03_PostBattle_Idle01
	770	g_d2_coast03_PostBattle_Idle02apexArms
	771	g_d2_coast03_PostBattle_Idle02apexSpine
	772	g_d2_coast03_PostBattle_Idle02apexDelta
	773	g_d2_coast03_PostBattle_Idle02loopArms
	774	g_d2_coast03_PostBattle_Idle02loopSpine
	775	g_d2_coast03_PostBattle_Idle02accentDelta
	776	g_d2_coast03_PostBattle_Idle02
	777	g_Leon_Lean_Table_Map_RespondapexArms
	778	g_Leon_Lean_Table_Map_RespondapexSpine
	779	g_Leon_Lean_Table_Map_RespondapexDelta
	780	g_Leon_Lean_Table_Map_RespondloopArms
	781	g_Leon_Lean_Table_Map_RespondloopSpine
	782	g_Leon_Lean_Table_Map_RespondaccentDelta
	783	g_Leon_Lean_Table_Map_Respond
	784	g_OverHere_LeftapexArms
	785	g_OverHere_LeftapexSpine
	786	g_OverHere_LeftapexDelta
	787	g_OverHere_LeftloopArms
	788	g_OverHere_LeftloopSpine
	789	g_OverHere_LeftaccentDelta
	790	g_OverHere_Left
	791	g_OverHere_RightapexArms
	792	g_OverHere_RightapexSpine
	793	g_OverHere_RightapexDelta
	794	g_OverHere_RightloopArms
	795	g_OverHere_RightloopSpine
	796	g_OverHere_RightaccentDelta
	797	g_OverHere_Right
	798	g_head_backapexArms
	799	g_head_backapexSpine
	800	g_head_backapexDelta
	801	g_head_backloopArms
	802	g_head_backloopSpine
	803	g_head_backaccentDelta
	804	g_head_back
	805	g_head_forwardapexArms
	806	g_head_forwardapexSpine
	807	g_head_forwardapexDelta
	808	g_head_forwardloopArms
	809	g_head_forwardloopSpine
	810	g_head_forwardaccentDelta
	811	g_head_forward
	812	b_OverHere_Leftdefault
	813	b_OverHere_LeftapexDelta
	814	b_OverHere_LeftloopDelta
	815	b_OverHere_Left
	816	b_OverHere_Rightdefault
	817	b_OverHere_RightapexDelta
	818	b_OverHere_RightloopDelta
	819	b_OverHere_Right
	820	b_head_backdefault
	821	b_head_backapexDelta
	822	b_head_backloopDelta
	823	b_head_back
	824	b_head_forwarddefault
	825	b_head_forwardapexDelta
	826	b_head_forwardloopDelta
	827	b_head_forward
	828	b_d2_coast03_PostBattle_Idle02default
	829	b_d2_coast03_PostBattle_Idle02apexDelta
	830	b_d2_coast03_PostBattle_Idle02loopDelta
	831	b_d2_coast03_PostBattle_Idle02
	832	hg_nod_rightdefault
	833	hg_nod_rightapexDelta
	834	hg_nod_rightloopDelta
	835	hg_nod_right
	836	hg_nod_leftdefault
	837	hg_nod_leftapexDelta
	838	hg_nod_leftloopDelta
	839	hg_nod_left
	840	hg_puncuate_downdefault
	841	hg_puncuate_downapexDelta
	842	hg_puncuate_downloopDelta
	843	hg_puncuate_down
	844	hg_headshakedefault
	845	hg_headshakeapexDelta
	846	hg_headshakeloopDelta
	847	hg_headshake
	848	g_buttonpush_rifleapexArms
	849	g_buttonpush_rifleapexSpine
	850	g_buttonpush_rifleapexDelta
	851	g_buttonpush_rifleloopArms
	852	g_buttonpush_rifleloopSpine
	853	g_buttonpush_rifleaccentDelta
	854	g_buttonpush_rifle
	855	g_drop_meleeweaponapexArms
	856	g_drop_meleeweaponapexSpine
	857	g_drop_meleeweaponapexDelta
	858	g_drop_meleeweaponloopArms
	859	g_drop_meleeweaponloopSpine
	860	g_drop_meleeweaponaccentDelta
	861	g_drop_meleeweapon
	862	g_righthand_flickapexArms
	863	g_righthand_flickapexSpine
	864	g_righthand_flickapexDelta
	865	g_righthand_flickloopArms
	866	g_righthand_flickloopSpine
	867	g_righthand_flickaccentDelta
	868	g_righthand_flick
	869	bg_accentUpdefault
	870	bg_accentUpapexDelta
	871	bg_accentUploopDelta
	872	bg_accentUp
	873	bg_accentFwddefault
	874	bg_accentFwdapexDelta
	875	bg_accentFwdloopDelta
	876	bg_accentFwd
	877	bg_accent_leftdefault
	878	bg_accent_leftapexDelta
	879	bg_accent_leftloopDelta
	880	bg_accent_left
	881	g_waveinDelta
	882	g_waveinFrameArms
	883	g_waveinFrameSpine
	884	g_waveinLoopDelta
	885	g_waveloopFrameArms
	886	g_waveloopFrameSpine
	887	g_waveloopDelta
	888	g_waveoutLoopDelta
	889	g_waveOutFrameArms
	890	g_waveOutFrameSpine
	891	g_waveoutDelta
	892	g_wave
	893	g_frustrated_pointinDelta
	894	g_frustrated_pointinFrameArms
	895	g_frustrated_pointinFrameSpine
	896	g_frustrated_pointinLoopDelta
	897	g_frustrated_pointloopFrameArms
	898	g_frustrated_pointloopFrameSpine
	899	g_frustrated_pointloopDelta
	900	g_frustrated_pointoutLoopDelta
	901	g_frustrated_pointOutFrameArms
	902	g_frustrated_pointOutFrameSpine
	903	g_frustrated_pointoutDelta
	904	g_frustrated_point
	905	g_pumpleft_RPGrightapexArms
	906	g_pumpleft_RPGrightapexSpine
	907	g_pumpleft_RPGrightapexDelta
	908	g_pumpleft_RPGrightloopArms
	909	g_pumpleft_RPGrightloopSpine
	910	g_pumpleft_RPGrightaccentDelta
	911	g_pumpleft_RPGright
	912	g_pumpleft_rpgdownapexArms
	913	g_pumpleft_rpgdownapexSpine
	914	g_pumpleft_rpgdownapexDelta
	915	g_pumpleft_rpgdownloopArms
	916	g_pumpleft_rpgdownloopSpine
	917	g_pumpleft_rpgdownaccentDelta
	918	g_pumpleft_rpgdown
	919	g_armsupapexArms
	920	g_armsupapexSpine
	921	g_armsupapexDelta
	922	g_armsuploopArms
	923	g_armsuploopSpine
	924	g_armsupaccentDelta
	925	g_armsup
	926	g_clapapexArms
	927	g_clapapexSpine
	928	g_clapapexDelta
	929	g_claploopArms
	930	g_claploopSpine
	931	g_clapaccentDelta
	932	g_clap
	933	g_rarmpumpapexArms
	934	g_rarmpumpapexSpine
	935	g_rarmpumpapexDelta
	936	g_rarmpumploopArms
	937	g_rarmpumploopSpine
	938	g_rarmpumpaccentDelta
	939	g_rarmpump
	940	g_armsoutapexArms
	941	g_armsoutapexSpine
	942	g_armsoutapexDelta
	943	g_armsoutloopArms
	944	g_armsoutloopSpine
	945	g_armsoutaccentDelta
	946	g_armsout
	947	g_armsout_highapexArms
	948	g_armsout_highapexSpine
	949	g_armsout_highapexDelta
	950	g_armsout_highloopArms
	951	g_armsout_highloopSpine
	952	g_armsout_highaccentDelta
	953	g_armsout_high
	954	g_pumplowapexArms
	955	g_pumplowapexSpine
	956	g_pumplowapexDelta
	957	g_pumplowloopArms
	958	g_pumplowloopSpine
	959	g_pumplowaccentDelta
	960	g_pumplow
	961	g_R_typeapexArms
	962	g_R_typeapexSpine
	963	g_R_typeapexDelta
	964	g_R_typeloopArms
	965	g_R_typeloopSpine
	966	g_R_typeaccentDelta
	967	g_R_type
	968	g_saluteapexArms
	969	g_saluteapexSpine
	970	g_saluteapexDelta
	971	g_saluteloopArms
	972	g_saluteloopSpine
	973	g_saluteaccentDelta
	974	g_salute
	975	g_thumbsupapexArms
	976	g_thumbsupapexSpine
	977	g_thumbsupapexDelta
	978	g_thumbsuploopArms
	979	g_thumbsuploopSpine
	980	g_thumbsupaccentDelta
	981	g_thumbsup
	982	hg_chest_twistLdefault
	983	hg_chest_twistLapexDelta
	984	hg_chest_twistLloopDelta
	985	hg_chest_twistL
	986	sit_breathinDelta
	987	sit_breathinFrameArms
	988	sit_breathinFrameSpine
	989	sit_breathCoreDelta
	990	sit_breathOutFrameArms
	991	sit_breathOutFrameSpine
	992	sit_breathoutDelta
	993	sit_breath
	994	g_breath_lyingdowninDelta
	995	g_breath_lyingdowninFrameArms
	996	g_breath_lyingdowninFrameSpine
	997	g_breath_lyingdownCoreDelta
	998	g_breath_lyingdownOutFrameArms
	999	g_breath_lyingdownOutFrameSpine
	1000	g_breath_lyingdownoutDelta
	1001	g_breath_lyingdown
	1002	g_fistshakeapexArms
	1003	g_fistshakeapexSpine
	1004	g_fistshakeapexDelta
	1005	g_fistshakeloopArms
	1006	g_fistshakeloopSpine
	1007	g_fistshakeaccentDelta
	1008	g_fistshake
	1009	g_pointleft_linDelta
	1010	g_pointleft_linFrameArms
	1011	g_pointleft_linFrameSpine
	1012	g_pointleft_linLoopDelta
	1013	g_pointleft_lloopFrameArms
	1014	g_pointleft_lloopFrameSpine
	1015	g_pointleft_lloopDelta
	1016	g_pointleft_loutLoopDelta
	1017	g_pointleft_lOutFrameArms
	1018	g_pointleft_lOutFrameSpine
	1019	g_pointleft_loutDelta
	1020	g_pointleft_l
	1021	g_pointright_linDelta
	1022	g_pointright_linFrameArms
	1023	g_pointright_linFrameSpine
	1024	g_pointright_linLoopDelta
	1025	g_pointright_lloopFrameArms
	1026	g_pointright_lloopFrameSpine
	1027	g_pointright_lloopDelta
	1028	g_pointright_loutLoopDelta
	1029	g_pointright_lOutFrameArms
	1030	g_pointright_lOutFrameSpine
	1031	g_pointright_loutDelta
	1032	g_pointright_l
	1033	g_point_linDelta
	1034	g_point_linFrameArms
	1035	g_point_linFrameSpine
	1036	g_point_linLoopDelta
	1037	g_point_lloopFrameArms
	1038	g_point_lloopFrameSpine
	1039	g_point_lloopDelta
	1040	g_point_loutLoopDelta
	1041	g_point_lOutFrameArms
	1042	g_point_lOutFrameSpine
	1043	g_point_loutDelta
	1044	g_point_l
	1045	g_point_l_rpginDelta
	1046	g_point_l_rpginFrameArms
	1047	g_point_l_rpginFrameSpine
	1048	g_point_l_rpginLoopDelta
	1049	g_point_l_rpgloopFrameArms
	1050	g_point_l_rpgloopFrameSpine
	1051	g_point_l_rpgloopDelta
	1052	g_point_l_rpgoutLoopDelta
	1053	g_point_l_rpgOutFrameArms
	1054	g_point_l_rpgOutFrameSpine
	1055	g_point_l_rpgoutDelta
	1056	g_point_l_rpg
	1057	hg_turn_ldefault
	1058	hg_turn_lapexDelta
	1059	hg_turn_lloopDelta
	1060	hg_turn_l
	1061	hg_turn_rdefault
	1062	hg_turn_rapexDelta
	1063	hg_turn_rloopDelta
	1064	hg_turn_r
	1065	g_weld_3inDelta
	1066	g_weld_3inFrameArms
	1067	g_weld_3inFrameSpine
	1068	g_weld_3inLoopDelta
	1069	g_weld_3loopFrameArms
	1070	g_weld_3loopFrameSpine
	1071	g_weld_3loopDelta
	1072	g_weld_3outLoopDelta
	1073	g_weld_3OutFrameArms
	1074	g_weld_3OutFrameSpine
	1075	g_weld_3outDelta
	1076	g_weld_3
	1077	g_weld_2inDelta
	1078	g_weld_2inFrameArms
	1079	g_weld_2inFrameSpine
	1080	g_weld_2inLoopDelta
	1081	g_weld_2loopFrameArms
	1082	g_weld_2loopFrameSpine
	1083	g_weld_2loopDelta
	1084	g_weld_2outLoopDelta
	1085	g_weld_2OutFrameArms
	1086	g_weld_2OutFrameSpine
	1087	g_weld_2outDelta
	1088	g_weld_2
	1089	g_weld_downinDelta
	1090	g_weld_downinFrameArms
	1091	g_weld_downinFrameSpine
	1092	g_weld_downinLoopDelta
	1093	g_weld_downloopFrameArms
	1094	g_weld_downloopFrameSpine
	1095	g_weld_downloopDelta
	1096	g_weld_downoutLoopDelta
	1097	g_weld_downOutFrameArms
	1098	g_weld_downOutFrameSpine
	1099	g_weld_downoutDelta
	1100	g_weld_down
	1101	g_ep2_09_holdbeacon_idleapexArms
	1102	g_ep2_09_holdbeacon_idleapexSpine
	1103	g_ep2_09_holdbeacon_idleapexDelta
	1104	g_ep2_09_holdbeacon_idleloopArms
	1105	g_ep2_09_holdbeacon_idleloopSpine
	1106	g_ep2_09_holdbeacon_idleaccentDelta
	1107	g_ep2_09_holdbeacon_idle
	1108	g_ep2_09_holdbeacon_startcarapexArms
	1109	g_ep2_09_holdbeacon_startcarapexSpine
	1110	g_ep2_09_holdbeacon_startcarapexDelta
	1111	g_ep2_09_holdbeacon_startcarloopArms
	1112	g_ep2_09_holdbeacon_startcarloopSpine
	1113	g_ep2_09_holdbeacon_startcaraccentDelta
	1114	g_ep2_09_holdbeacon_startcar
	1115	g_ep2_09_holdbeacon_pointatbeaconapexArms
	1116	g_ep2_09_holdbeacon_pointatbeaconapexSpine
	1117	g_ep2_09_holdbeacon_pointatbeaconapexDelta
	1118	g_ep2_09_holdbeacon_pointatbeaconloopArms
	1119	g_ep2_09_holdbeacon_pointatbeaconloopSpine
	1120	g_ep2_09_holdbeacon_pointatbeaconaccentDelta
	1121	g_ep2_09_holdbeacon_pointatbeacon
	1122	g_ep2_09_holdbeacon_shakebeaconapexArms
	1123	g_ep2_09_holdbeacon_shakebeaconapexSpine
	1124	g_ep2_09_holdbeacon_shakebeaconapexDelta
	1125	g_ep2_09_holdbeacon_shakebeaconloopArms
	1126	g_ep2_09_holdbeacon_shakebeaconloopSpine
	1127	g_ep2_09_holdbeacon_shakebeaconaccentDelta
	1128	g_ep2_09_holdbeacon_shakebeacon
	1129	g_ep2_09_holdbeacon_circusapexArms
	1130	g_ep2_09_holdbeacon_circusapexSpine
	1131	g_ep2_09_holdbeacon_circusapexDelta
	1132	g_ep2_09_holdbeacon_circusloopArms
	1133	g_ep2_09_holdbeacon_circusloopSpine
	1134	g_ep2_09_holdbeacon_circusaccentDelta
	1135	g_ep2_09_holdbeacon_circus
	1136	g_ep2_09_holdbeacon_thumbbehindapexArms
	1137	g_ep2_09_holdbeacon_thumbbehindapexSpine
	1138	g_ep2_09_holdbeacon_thumbbehindapexDelta
	1139	g_ep2_09_holdbeacon_thumbbehindloopArms
	1140	g_ep2_09_holdbeacon_thumbbehindloopSpine
	1141	g_ep2_09_holdbeacon_thumbbehindaccentDelta
	1142	g_ep2_09_holdbeacon_thumbbehind
	1143	g_plead_01_leftapexArms
	1144	g_plead_01_leftapexSpine
	1145	g_plead_01_leftapexDelta
	1146	g_plead_01_leftloopArms
	1147	g_plead_01_leftloopSpine
	1148	g_plead_01_leftaccentDelta
	1149	g_plead_01_left
	1150	GestureButton_rightapexArms
	1151	GestureButton_rightapexSpine
	1152	GestureButton_rightapexDelta
	1153	GestureButton_rightloopArms
	1154	GestureButton_rightloopSpine
	1155	GestureButton_rightaccentDelta
	1156	GestureButton_right
	1157	bg_up_ldefault
	1158	bg_up_lapexDelta
	1159	bg_up_lloopDelta
	1160	bg_up_l
	1161	bg_up_rdefault
	1162	bg_up_rapexDelta
	1163	bg_up_rloopDelta
	1164	bg_up_r
	1165	bg_downdefault
	1166	bg_downapexDelta
	1167	bg_downloopDelta
	1168	bg_down
	1169	bg_leftdefault
	1170	bg_leftapexDelta
	1171	bg_leftloopDelta
	1172	bg_left
	1173	bg_rightdefault
	1174	bg_rightapexDelta
	1175	bg_rightloopDelta
	1176	bg_right
	1177	g_palm_up_lapexArms
	1178	g_palm_up_lapexSpine
	1179	g_palm_up_lapexDelta
	1180	g_palm_up_lloopArms
	1181	g_palm_up_lloopSpine
	1182	g_palm_up_laccentDelta
	1183	g_palm_up_l
	1184	g_palm_up_high_lapexArms
	1185	g_palm_up_high_lapexSpine
	1186	g_palm_up_high_lapexDelta
	1187	g_palm_up_high_lloopArms
	1188	g_palm_up_high_lloopSpine
	1189	g_palm_up_high_laccentDelta
	1190	g_palm_up_high_l
	1191	g_ar2_downinDelta
	1192	g_ar2_downinFrameArms
	1193	g_ar2_downinFrameSpine
	1194	g_ar2_downinLoopDelta
	1195	g_ar2_downloopFrameArms
	1196	g_ar2_downloopFrameSpine
	1197	g_ar2_downloopDelta
	1198	g_ar2_downoutLoopDelta
	1199	g_ar2_downOutFrameArms
	1200	g_ar2_downOutFrameSpine
	1201	g_ar2_downoutDelta
	1202	g_ar2_down
	1203	g_palm_out_lapexArms
	1204	g_palm_out_lapexSpine
	1205	g_palm_out_lapexDelta
	1206	g_palm_out_lloopArms
	1207	g_palm_out_lloopSpine
	1208	g_palm_out_laccentDelta
	1209	g_palm_out_l
	1210	g_frustrated_point_linDelta
	1211	g_frustrated_point_linFrameArms
	1212	g_frustrated_point_linFrameSpine
	1213	g_frustrated_point_linLoopDelta
	1214	g_frustrated_point_lloopFrameArms
	1215	g_frustrated_point_lloopFrameSpine
	1216	g_frustrated_point_lloopDelta
	1217	g_frustrated_point_loutLoopDelta
	1218	g_frustrated_point_lOutFrameArms
	1219	g_frustrated_point_lOutFrameSpine
	1220	g_frustrated_point_loutDelta
	1221	g_frustrated_point_l
	1222	g_palm_out_high_lapexArms
	1223	g_palm_out_high_lapexSpine
	1224	g_palm_out_high_lapexDelta
	1225	g_palm_out_high_lloopArms
	1226	g_palm_out_high_lloopSpine
	1227	g_palm_out_high_laccentDelta
	1228	g_palm_out_high_l
	1229	hg_nod_yesdefault
	1230	hg_nod_yesapexDelta
	1231	hg_nod_yesloopDelta
	1232	hg_nod_yes
	1233	hg_nod_nodefault
	1234	hg_nod_noapexDelta
	1235	hg_nod_noloopDelta
	1236	hg_nod_no
	1237	g_fist_rapexArms
	1238	g_fist_rapexSpine
	1239	g_fist_rapexDelta
	1240	g_fist_rloopArms
	1241	g_fist_rloopSpine
	1242	g_fist_raccentDelta
	1243	g_fist_r
	1244	g_palm_out_rapexArms
	1245	g_palm_out_rapexSpine
	1246	g_palm_out_rapexDelta
	1247	g_palm_out_rloopArms
	1248	g_palm_out_rloopSpine
	1249	g_palm_out_raccentDelta
	1250	g_palm_out_r
	1251	g_palm_out_high_rapexArms
	1252	g_palm_out_high_rapexSpine
	1253	g_palm_out_high_rapexDelta
	1254	g_palm_out_high_rloopArms
	1255	g_palm_out_high_rloopSpine
	1256	g_palm_out_high_raccentDelta
	1257	g_palm_out_high_r
	1258	g_smg_downinDelta
	1259	g_smg_downinFrameArms
	1260	g_smg_downinFrameSpine
	1261	g_smg_downinLoopDelta
	1262	g_smg_downloopFrameArms
	1263	g_smg_downloopFrameSpine
	1264	g_smg_downloopDelta
	1265	g_smg_downoutLoopDelta
	1266	g_smg_downOutFrameArms
	1267	g_smg_downOutFrameSpine
	1268	g_smg_downoutDelta
	1269	g_smg_down
	1270	p_L_forwthrowapexArms
	1271	p_L_forwthrowapexSpine
	1272	p_L_forwthrowapexDelta
	1273	p_L_forwthrowloopArms
	1274	p_L_forwthrowloopSpine
	1275	p_L_forwthrowaccentDelta
	1276	p_L_forwthrow
	1277	g_chestupapexArms
	1278	g_chestupapexSpine
	1279	g_chestupapexDelta
	1280	g_chestuploopArms
	1281	g_chestuploopSpine
	1282	g_chestupaccentDelta
	1283	g_chestup
	1284	g_LhandeaseapexArms
	1285	g_LhandeaseapexSpine
	1286	g_LhandeaseapexDelta
	1287	g_LhandeaseloopArms
	1288	g_LhandeaseloopSpine
	1289	g_LhandeaseaccentDelta
	1290	g_Lhandease
	1291	hg_turnRdefault
	1292	hg_turnRapexDelta
	1293	hg_turnRloopDelta
	1294	hg_turnR
	1295	hg_turnLdefault
	1296	hg_turnLapexDelta
	1297	hg_turnLloopDelta
	1298	hg_turnL
	1299	g_openarmsapexArms
	1300	g_openarmsapexSpine
	1301	g_openarmsapexDelta
	1302	g_openarmsloopArms
	1303	g_openarmsloopSpine
	1304	g_openarmsaccentDelta
	1305	g_openarms
	1306	g_openarms_rightapexArms
	1307	g_openarms_rightapexSpine
	1308	g_openarms_rightapexDelta
	1309	g_openarms_rightloopArms
	1310	g_openarms_rightloopSpine
	1311	g_openarms_rightaccentDelta
	1312	g_openarms_right
	1313	g_pointapexArms
	1314	g_pointapexSpine
	1315	g_pointapexDelta
	1316	g_pointloopArms
	1317	g_pointloopSpine
	1318	g_pointaccentDelta
	1319	g_point
	1320	shiftrightloop
	1321	shiftrightin
	1322	shiftrightout
	1323	shiftright
	1324	shiftrightbigloop
	1325	shiftrightbigin
	1326	shiftrightbigout
	1327	shiftrightbig
	1328	shiftleftloop
	1329	shiftleftin
	1330	shiftleftout
	1331	shiftleft
	1332	P_Drinker_lookrightloop
	1333	P_Drinker_lookrightin
	1334	P_Drinker_lookrightout
	1335	P_Drinker_lookright
	1336	P_Drinker_lookleftloop
	1337	P_Drinker_lookleftin
	1338	P_Drinker_lookleftout
	1339	P_Drinker_lookleft
	1340	P_BreakRoom_WatchClockloop
	1341	P_BreakRoom_WatchClockin
	1342	P_BreakRoom_WatchClockout
	1343	P_BreakRoom_WatchClock
	1344	P_BreakRoom_Sit_01loop
	1345	P_BreakRoom_Sit_01in
	1346	P_BreakRoom_Sit_01out
	1347	P_BreakRoom_Sit_01
	1348	Scan_Skies_Respondloop
	1349	Scan_Skies_Respondin
	1350	Scan_Skies_Respondout
	1351	Scan_Skies_Respond
	1352	p_ConsoleType_Rifleloop
	1353	p_ConsoleType_Riflein
	1354	p_ConsoleType_Rifleout
	1355	p_ConsoleType_Rifle
	1356	p_town05_RadioLeanloop
	1357	p_town05_RadioLeanin
	1358	p_town05_RadioLeanout
	1359	p_town05_RadioLean
	1360	p_bouncingloop
	1361	p_bouncingin
	1362	p_bouncingout
	1363	p_bouncing
	1364	p_stepleftloop
	1365	p_stepleftin
	1366	p_stepleftout
	1367	p_stepleft
	1368	p_jumpuploop
	1369	p_jumpupin
	1370	p_jumpupout
	1371	p_jumpup
	1372	p_balance_toesloop
	1373	p_balance_toesin
	1374	p_balance_toesout
	1375	p_balance_toes
	1376	p_bendoverloop
	1377	p_bendoverin
	1378	p_bendoverout
	1379	p_bendover
	1380	p_stepinloop
	1381	p_stepinin
	1382	p_stepinout
	1383	p_stepin
	1384	P_lean_on_carloop
	1385	P_lean_on_carin
	1386	P_lean_on_carout
	1387	P_lean_on_car
	1388	p_kickloop
	1389	p_kickin
	1390	p_kickout
	1391	p_kick
	1392	p_ar2_step_lloop
	1393	p_ar2_step_lin
	1394	p_ar2_step_lout
	1395	p_ar2_step_l
	1396	p_ar2_relaxedloop
	1397	p_ar2_relaxedin
	1398	p_ar2_relaxedout
	1399	p_ar2_relaxed
	1400	p_point_down_leftloop
	1401	p_point_down_leftin
	1402	p_point_down_leftout
	1403	p_point_down_left
	1404	p_fingerpointuploop
	1405	p_fingerpointupin
	1406	p_fingerpointupout
	1407	p_fingerpointup
	1408	p_readyloop
	1409	p_readyin
	1410	p_readyout
	1411	p_ready
	1412	p_L_foot_forwloop
	1413	p_L_foot_forwin
	1414	p_L_foot_forwout
	1415	p_L_foot_forw
	
	--citizen animations. These are names, not enums
	0	ragdoll
	1	idle_subtle
	2	idle_angry
	3	LineIdle01
	4	LineIdle02
	5	LineIdle03
	6	LineIdle04
	7	Crouch_idleD
	8	layer_crouch_walk_no_weapon
	9	layer_crouch_run_no_weapon
	10	walk_all_Moderate
	11	walk_all
	12	run_all
	13	sprint_all
	14	Crouch_walk_all
	15	crouch_run_all_delta
	16	crouchRUNALL1
	17	Stand_to_crouch
	18	Crouch_to_stand
	19	Open_door_away
	20	Open_door_towards_right
	21	Open_door_towards_left
	22	turnleft
	23	turnright
	24	gesture_turn_left_45default
	25	gesture_turn_left_45inDelta
	26	gesture_turn_left_45outDelta
	27	gesture_turn_left_45
	28	gesture_turn_left_90default
	29	gesture_turn_left_90inDelta
	30	gesture_turn_left_90outDelta
	31	gesture_turn_left_90
	32	gesture_turn_left_180default
	33	gesture_turn_left_180inDelta
	34	gesture_turn_left_180outDelta
	35	gesture_turn_left_180
	36	gesture_turn_right_45default
	37	gesture_turn_right_45inDelta
	38	gesture_turn_right_45outDelta
	39	gesture_turn_right_45
	40	gesture_turn_right_90default
	41	gesture_turn_right_90inDelta
	42	gesture_turn_right_90outDelta
	43	gesture_turn_right_90
	44	gesture_turn_right_180default
	45	gesture_turn_right_180inDelta
	46	gesture_turn_right_180outDelta
	47	gesture_turn_right_180
	48	gesture_turn_left_45_flatdefault
	49	gesture_turn_left_45_flatinDelta
	50	gesture_turn_left_45_flatoutDelta
	51	gesture_turn_left_45_flat
	52	gesture_turn_left_90_flatdefault
	53	gesture_turn_left_90_flatinDelta
	54	gesture_turn_left_90_flatoutDelta
	55	gesture_turn_left_90_flat
	56	gesture_turn_left_180_flatdefault
	57	gesture_turn_left_180_flatinDelta
	58	gesture_turn_left_180_flatoutDelta
	59	gesture_turn_left_180_flat
	60	gesture_turn_right_45_flatdefault
	61	gesture_turn_right_45_flatinDelta
	62	gesture_turn_right_45_flatoutDelta
	63	gesture_turn_right_45_flat
	64	gesture_turn_right_90_flatdefault
	65	gesture_turn_right_90_flatinDelta
	66	gesture_turn_right_90_flatoutDelta
	67	gesture_turn_right_90_flat
	68	gesture_turn_right_180_flatdefault
	69	gesture_turn_right_180_flatinDelta
	70	gesture_turn_right_180_flatoutDelta
	71	gesture_turn_right_180_flat
	72	Startle_behind
	73	photo_react_blind
	74	photo_react_startle
	75	ThrowItem
	76	Heal
	77	Wave
	78	Wave_close
	79	DuckUnder
	80	crouchidlehide
	81	standtocrouchhide
	82	crouchhidetostand
	83	scaredidle
	84	preSkewer
	85	Fear_Reaction
	86	Fear_Reaction_Idle
	87	cower
	88	cower_Idle
	89	layer_run_protected
	90	run_protected_all
	91	run_all_panicked
	92	layer_crouchwalk_panicked
	93	walk_panicked_all
	94	crouchIdle_panicked4
	95	layer_luggage_walk
	96	luggage_walk_all
	97	layer_pace
	98	pace_all
	99	layer_walk_midspeed
	100	plaza_walk_all
	101	deathpose_front
	102	deathpose_back
	103	deathpose_right
	104	deathpose_left
	105	hunter_cit_throw_ground
	106	hunter_cit_tackle_di
	107	hunter_cit_stomp
	108	hunter_cit_tackle
	109	hunter_cit_tackle_postI
	110	cit_door
	111	injured1
	112	injured3
	113	injured1preidle
	114	injured1postidle
	115	injured4
	116	injured4_standing
	117	injured4_sit
	118	injured4_sitpostidle
	119	citizen2
	120	citizen2_stand
	121	citizen4_preaction
	122	citizen4_rise
	123	citizen4_valve
	124	gman_freeze_pose_shooting
	125	gman_freeze_pose_shot
	126	welder_idle
	127	welder_loop
	128	ss_alyx_move_pre
	129	ss_alyx_move
	130	ss_alyx_move_post
	131	ss_advisor
	132	silo_sit
	133	Idle_Angry_SMG1
	134	Idle_Angry_Shotgun
	135	Idle_SMG1_Aim
	136	Idle_SMG1_Aim_Alert
	137	idle_angry_Ar2
	138	idle_ar2_aim
	139	shoot_smg1
	140	shoot_ar2
	141	shoot_ar2_alt
	142	shoot_shotgun
	143	shoot_rpg
	144	reload_smg1
	145	reload_shotgun1
	146	reload_ar2
	147	gesture_reload_smg1spine
	148	gesture_reload_smg1arms
	149	gesture_reload_smg1
	150	gesture_reload_ar2spine
	151	gesture_reload_ar2arms
	152	gesture_reload_ar2
	153	gesture_shoot_ar2
	154	gesture_shoot_smg1
	155	gesture_shoot_shotgun
	156	gesture_shoot_rpg
	157	IdleAngryToShootDelta
	158	IdleAngryToShoot
	159	ShootToIdleAngryDelta
	160	ShootToIdleAngry
	161	IdleAngry_AR2_ToShootDelta
	162	IdleAngry_AR2_ToShoot
	163	Shoot_AR2_ToIdleAngryDelta
	164	Shoot_AR2_ToIdleAngry
	165	CrouchDToShoot
	166	ShootToCrouchD
	167	CrouchDToStand
	168	StandToCrouchD
	169	CrouchDToCrouchShoot
	170	CrouchShootToCrouchD
	171	Cover_R
	172	Cover_L
	173	CoverLow_R
	174	CoverLow_L
	175	Cover_LToShootSMG1
	176	Cover_RToShootSMG1
	177	CoverLow_LToShootSMG1
	178	CoverLow_RToShootSMG1
	179	ShootSMG1ToCover_L
	180	ShootSMG1ToCover_R
	181	ShootSMG1ToCoverLow_L
	182	ShootSMG1ToCoverLow_R
	183	crouch_shoot_smg1
	184	crouch_aim_smg1
	185	crouch_reload_smg1
	186	shootp1
	187	gesture_shootp1
	188	reload_pistol
	189	crouch_shoot_pistol
	190	crouch_reload_pistol
	191	throw1
	192	swing
	193	idle_angry_melee
	194	MeleeAttack01
	195	pickup
	196	gunrack
	197	smgdraw
	198	Fear_Reaction_gesturespine
	199	Fear_Reaction_gesturearms
	200	Fear_Reaction_gesture
	201	Wave_SMG1
	202	layer_Aim_all
	203	layer_Aim_AR2_all
	204	layer_Aim_Alert_all
	205	layer_Aim_AR2_Alert_all
	206	layer_runAim_all
	207	layer_runAim_ar2_all
	208	layer_walkAlertAim_all
	209	layer_walkAlertAim_AR2_all
	210	layer_walk_aiming
	211	layer_walk_holding
	212	layer_run_aiming
	213	layer_crouch_run_aiming
	214	layer_crouch_walk_aiming
	215	layer_walk_AR2_aiming
	216	layer_walk_AR2_holding
	217	layer_run_AR2_aiming
	218	layer_walk_alert_holding
	219	walkAlertHOLDALL1
	220	layer_walk_alert_aiming
	221	walkAlertAimALL1
	222	layer_walk_alert_holding_AR2
	223	walkAlertHOLD_AR2_ALL1
	224	layer_walk_alert_aiming_AR2
	225	walkAlertAim_AR2_ALL1
	226	layer_run_alert_holding
	227	run_alert_holding_all
	228	layer_run_alert_holding_AR2
	229	run_alert_holding_AR2_all
	230	layer_run_alert_aiming
	231	run_alert_aiming_all
	232	layer_run_alert_aiming_ar2
	233	run_alert_aiming_ar2_all
	234	walkAIMALL1
	235	walkHOLDALL1
	236	walkAIMALL1_ar2
	237	walkHOLDALL1_ar2
	238	layer_run_holding
	239	run_holding_all
	240	run_aiming_all
	241	layer_run_holding_ar2
	242	run_holding_ar2_all
	243	run_aiming_ar2_all
	244	layer_crouch_run_holding
	245	crouchRUNHOLDINGALL1
	246	crouchRUNAIMINGALL1
	247	layer_crouch_walk_holding
	248	Crouch_walk_holding_all
	249	Crouch_walk_aiming_all
	250	Man_Gun_Aim_all
	251	Man_Gun
	252	Idle_SMG1_Relaxed
	253	layer_walk_holding_SMG1_Relaxed
	254	walk_SMG1_Relaxed_all
	255	layer_run_holding_SMG1_Relaxed
	256	run_SMG1_Relaxed_all
	257	Idle_AR2_Relaxed
	258	layer_walk_holding_AR2_Relaxed
	259	walk_AR2_Relaxed_all
	260	layer_run_holding_AR2_Relaxed
	261	run_AR2_Relaxed_all
	262	Idle_RPG_Relaxed
	263	Idle_Angry_RPG
	264	Idle_RPG_Aim
	265	Crouch_Idle_RPG
	266	StandToShootRPGfake
	267	ShootToStandRPGfake
	268	CrouchToShootRPGfake
	269	ShootToCrouchRPGfake
	270	layer_walk_holding_RPG
	271	walk_holding_RPG_all
	272	layer_run_holding_RPG
	273	run_holding_RPG_all
	274	layer_crouch_walk_holding_RPG
	275	Crouch_walk_holding_RPG_all
	276	layer_crouch_run_holding_RPG
	277	crouch_run_holding_RPG_all
	278	layer_Aim_RPG_all
	279	layer_walk_holding_RPG_Relaxed
	280	walk_RPG_Relaxed_all
	281	layer_run_holding_RPG_Relaxed
	282	run_RPG_Relaxed_all
	283	layer_walk_holding_package
	284	walk_holding_package_all
	285	idle_noise
	286	Idle_Relaxed_SMG1_1
	287	Idle_Relaxed_SMG1_2
	288	Idle_Relaxed_SMG1_3
	289	Idle_Relaxed_SMG1_4
	290	Idle_Relaxed_SMG1_5
	291	Idle_Relaxed_SMG1_6
	292	Idle_Relaxed_SMG1_7
	293	Idle_Relaxed_SMG1_8
	294	Idle_Relaxed_SMG1_9
	295	Idle_Relaxed_AR2_1
	296	Idle_Relaxed_AR2_2
	297	Idle_Relaxed_AR2_3
	298	Idle_Relaxed_AR2_4
	299	Idle_Relaxed_AR2_5
	300	Idle_Relaxed_AR2_6
	301	Idle_Relaxed_AR2_7
	302	Idle_Relaxed_AR2_8
	303	Idle_Relaxed_AR2_9
	304	Idle_Alert_SMG1_1
	305	Idle_Alert_SMG1_2
	306	Idle_Alert_SMG1_3
	307	Idle_Alert_SMG1_4
	308	Idle_Alert_SMG1_5
	309	Idle_Alert_SMG1_6
	310	Idle_Alert_SMG1_7
	311	Idle_Alert_SMG1_8
	312	Idle_Alert_SMG1_9
	313	Idle_Alert_AR2_1
	314	Idle_Alert_AR2_2
	315	Idle_Alert_AR2_3
	316	Idle_Alert_AR2_4
	317	Idle_Alert_AR2_5
	318	Idle_Alert_AR2_6
	319	Idle_Alert_AR2_7
	320	Idle_Alert_AR2_8
	321	Idle_Alert_AR2_9
	322	Idle_Relaxed_Shotgun_1
	323	Idle_Relaxed_Shotgun_2
	324	Idle_Relaxed_Shotgun_3
	325	Idle_Relaxed_Shotgun_4
	326	Idle_Relaxed_Shotgun_5
	327	Idle_Relaxed_Shotgun_6
	328	Idle_Relaxed_Shotgun_7
	329	Idle_Relaxed_Shotgun_8
	330	Idle_Relaxed_Shotgun_9
	331	Idle_Alert_Shotgun_1
	332	Idle_Alert_Shotgun_2
	333	Idle_Alert_Shotgun_3
	334	Idle_Alert_Shotgun_4
	335	Idle_Alert_Shotgun_5
	336	Idle_Alert_Shotgun_6
	337	Idle_Alert_Shotgun_7
	338	Idle_Alert_Shotgun_8
	339	Idle_Alert_Shotgun_9
	340	jump_holding_jump
	341	jump_holding_glide
	342	jump_holding_land
	343	Seafloor_Poses
	344	Idle_to_Lean_Left
	345	Lean_Left
	346	Lean_Left_to_Idle
	347	Idle_to_Lean_Back
	348	Lean_Back
	349	Lean_Back_to_Idle
	350	Idle_to_Sit_Ground
	351	Sit_Ground
	352	Sit_Ground_to_Idle
	353	Idle_to_Sit_Chair
	354	Sit_Chair
	355	Sit_Chair_to_Idle
	356	body_rot_z
	357	spine_rot_z
	358	neck_trans_x
	359	head_rot_z
	360	head_rot_y
	361	head_rot_x
	362	idle_reference
	363	roofidle1
	364	roofidle2
	365	roofwatch1
	366	forcescanner
	367	preforcescanner
	368	postforcescanner
	369	sitchair1
	370	sitchairtable1
	371	sitcouchfeet1
	372	sitcouchknees1
	373	sitcouch1
	374	sitccouchtv1
	375	laycouch1
	376	laycouch1_exit
	377	drinker_sit
	378	drinker_sit_idle
	379	drinker_sit_ss
	380	drinker_sit_idle_ss
	381	takepackage
	382	idlepackage
	383	spreadwallidle
	384	roofwatch2
	385	lookoutidle
	386	lookoutrun
	387	roofslide
	388	plazaidle1
	389	plazaidle2
	390	plazaidle3
	391	plazaidle4
	392	plazastand1
	393	plazastand2
	394	plazastand3
	395	plazastand4
	396	apcarrestidle
	397	apcarrestslam
	398	arrestidle
	399	arrestcurious
	400	d1_t01_TrainRide_Sit_Idle
	401	d1_t01_TrainRide_Sit_Exit
	402	d1_t01_TrainRide_Stand
	403	d1_t01_TrainRide_Stand_Exit
	404	d1_t01_Luggage_Idle
	405	d1_t01_Luggage_Drop
	406	Idle_to_d1_t01_BreakRoom_Sit01
	407	d1_t01_BreakRoom_Sit01_Idle
	408	d1_t01_BreakRoom_Sit01_to_Idle
	409	d1_t01_BreakRoom_Sit02_Entry
	410	d1_t01_BreakRoom_Sit02
	411	d1_t01_BreakRoom_Sit02_Exit
	412	idlenoise
	413	d1_t01_BreakRoom_WatchClock
	414	d1_t01_BreakRoom_WatchBreen
	415	d1_t01_BreakRoom_WatchClock_Sit_Entry
	416	d1_t01_BreakRoom_WatchClock_Sit
	417	d1_t01_Interrogation_Idle
	418	d1_t02_Plaza_Scan_ID
	419	d1_t02_Playground_Cit1_Arms_Crossed
	420	d1_t02_Playground_Cit2_Pockets
	421	d1_t02_Plaza_Sit02
	422	d1_t02_Plaza_Sit01_Idle
	423	d1_t03_Tenements_Look_Out_Door_Idle
	424	d1_t03_Tenements_Look_Out_Door_Close
	425	d1_t03_Tenements_Look_Out_Window_Idle
	426	d1_t03_PreRaid_Peek_Idle
	427	d1_t03_PreRaid_Peek_Exit
	428	doorBracer_PreIdle
	429	doorBracer_ShutDoor
	430	doorBracer_Closed
	431	doorBracer_Struggle
	432	doorBracer_BustThru
	433	d1_t03_sit_couch_consoling
	434	luggageidle
	435	luggageshrug
	436	luggagepush
	437	ts_luggageShove_all
	438	Streetwar_CoverShoot_L
	439	Trainstation_Int
	440	Lying_Down
	441	podpose
	442	arrestpreidle
	443	arrestpunch
	444	arrestpostidle
	445	boxcaropen
	446	Canals_Matt_laydown
	447	Canals_Matt_whoareyou
	448	Canals_Matt_sitonedge
	449	Canals_Matt_beglad
	450	Canals_Matt_OhShit
	451	d1_canals_06_bridge_check
	452	mapcircle
	453	idlenoise2
	454	d1_town05_Winston_Down
	455	d1_town05_Wounded_Idle_1
	456	d1_town05_Wounded_Idle_2
	457	d1_town05_Daniels_Kneel_Entry
	458	d1_town05_Daniels_Kneel_Idle
	459	d1_town05_Leon_Idle_SMG1
	460	d1_town05_Leon_Door_Knock
	461	d1_town05_Leon_Lean_Table_Entry
	462	d1_town05_Leon_Lean_Table_Idle
	463	d1_town05_Leon_Lean_Table_Exit
	464	d1_town05_Leon_Lean_Table_Entry_NoGun
	465	d1_town05_Leon_Lean_Table_Posture_Entry
	466	d1_town05_Leon_Lean_Table_Posture_Idle
	467	d1_town05_Leon_Lean_Table_Posture_Exit
	468	headcrabbed
	469	headcrabbedpost
	470	d2_coast03_Odessa_RPG_Give
	471	d2_coast03_Odessa_RPG_Give_Idle
	472	d2_coast03_Odessa_RPG_Give_Exit
	473	d2_coast03_Odessa_Stand_RPG
	474	idle_alert_01
	475	idle_alert_02
	476	d2_coast03_PreBattle_Scan_Skies
	477	d2_coast03_PreBattle_Scan_Skies02
	478	d2_coast03_PreBattle_Scan_Skies03
	479	d2_coast03_PreBattle_Scan_Skies_Respond
	480	d2_coast03_PreBattle_Kneel_Idle
	481	d2_coast03_PreBattle_Stand_Look
	482	d2_coast03_PostBattle_Idle01_Entry
	483	d2_coast03_PostBattle_Idle01
	484	d2_coast03_PostBattle_Idle02_Entry
	485	d2_coast03_PostBattle_Idle02
	486	d2_coast_03_antlion_shove
	487	d2_coast11_Tobias
	488	antmanidle
	489	antmanstand
	490	d3_c17_03_tower_idle
	491	d3_c17_03_tower_wave
	492	d3_c17_03_throw_from_tower
	493	d3_c17_03_climb_rope
	494	d3_c17_03_climb_edge
	495	pullrope1idle
	496	pullrope2idle
	497	pullrope3idle
	498	droprope1
	499	droprope3
	500	cheer1
	501	cheer2
	502	sniper_victim_pre
	503	sniper_victim_die
	504	sniper_victim_post
	505	reference
	506	g_placeholderapexArms
	507	g_placeholderapexSpine
	508	g_placeholderapexDelta
	509	g_placeholderloopArms
	510	g_placeholderloopSpine
	511	g_placeholderaccentDelta
	512	g_placeholder
	513	g_preRaid_BeckonapexArms
	514	g_preRaid_BeckonapexSpine
	515	g_preRaid_BeckonapexDelta
	516	g_preRaid_BeckonloopArms
	517	g_preRaid_BeckonloopSpine
	518	g_preRaid_BeckonaccentDelta
	519	g_preRaid_Beckon
	520	g_BreakRoom_WatchClockapexArms
	521	g_BreakRoom_WatchClockapexSpine
	522	g_BreakRoom_WatchClockapexDelta
	523	g_BreakRoom_WatchClockloopArms
	524	g_BreakRoom_WatchClockloopSpine
	525	g_BreakRoom_WatchClockaccentDelta
	526	g_BreakRoom_WatchClock
	527	g_BreakRoom_Sit_01apexArms
	528	g_BreakRoom_Sit_01apexSpine
	529	g_BreakRoom_Sit_01apexDelta
	530	g_BreakRoom_Sit_01loopArms
	531	g_BreakRoom_Sit_01loopSpine
	532	g_BreakRoom_Sit_01accentDelta
	533	g_BreakRoom_Sit_01
	534	g_Breencast_Watcher_ResponseapexArms
	535	g_Breencast_Watcher_ResponseapexSpine
	536	g_Breencast_Watcher_ResponseapexDelta
	537	g_Breencast_Watcher_ResponseloopArms
	538	g_Breencast_Watcher_ResponseloopSpine
	539	g_Breencast_Watcher_ResponseaccentDelta
	540	g_Breencast_Watcher_Response
	541	g_Pacer_ArmsCrossedapexArms
	542	g_Pacer_ArmsCrossedapexSpine
	543	g_Pacer_ArmsCrossedapexDelta
	544	g_Pacer_ArmsCrossedloopArms
	545	g_Pacer_ArmsCrossedloopSpine
	546	g_Pacer_ArmsCrossedaccentDelta
	547	g_Pacer_ArmsCrossed
	548	g_Tenements_Look_Out_Window_RespondapexArms
	549	g_Tenements_Look_Out_Window_RespondapexSpine
	550	g_Tenements_Look_Out_Window_RespondapexDelta
	551	g_Tenements_Look_Out_Window_RespondloopArms
	552	g_Tenements_Look_Out_Window_RespondloopSpine
	553	g_Tenements_Look_Out_Window_RespondaccentDelta
	554	g_Tenements_Look_Out_Window_Respond
	555	g_Tenements_Look_Out_Window_Respond_bapexArms
	556	g_Tenements_Look_Out_Window_Respond_bapexSpine
	557	g_Tenements_Look_Out_Window_Respond_bapexDelta
	558	g_Tenements_Look_Out_Window_Respond_bloopArms
	559	g_Tenements_Look_Out_Window_Respond_bloopSpine
	560	g_Tenements_Look_Out_Window_Respond_baccentDelta
	561	g_Tenements_Look_Out_Window_Respond_b
	562	g_scan_IDapexArms
	563	g_scan_IDapexSpine
	564	g_scan_IDapexDelta
	565	g_scan_IDloopArms
	566	g_scan_IDloopSpine
	567	g_scan_IDaccentDelta
	568	g_scan_ID
	569	g_plead_01apexArms
	570	g_plead_01apexSpine
	571	g_plead_01apexDelta
	572	g_plead_01loopArms
	573	g_plead_01loopSpine
	574	g_plead_01accentDelta
	575	g_plead_01
	576	G_medpuct_midapexArms
	577	G_medpuct_midapexSpine
	578	G_medpuct_midapexDelta
	579	G_medpuct_midloopArms
	580	G_medpuct_midloopSpine
	581	G_medpuct_midaccentDelta
	582	G_medpuct_mid
	583	G_noway_smallapexArms
	584	G_noway_smallapexSpine
	585	G_noway_smallapexDelta
	586	G_noway_smallloopArms
	587	G_noway_smallloopSpine
	588	G_noway_smallaccentDelta
	589	G_noway_small
	590	G_noway_bigapexArms
	591	G_noway_bigapexSpine
	592	G_noway_bigapexDelta
	593	G_noway_bigloopArms
	594	G_noway_bigloopSpine
	595	G_noway_bigaccentDelta
	596	G_noway_big
	597	G_shrugapexArms
	598	G_shrugapexSpine
	599	G_shrugapexDelta
	600	G_shrugloopArms
	601	G_shrugloopSpine
	602	G_shrugaccentDelta
	603	G_shrug
	604	G_medurgent_midapexArms
	605	G_medurgent_midapexSpine
	606	G_medurgent_midapexDelta
	607	G_medurgent_midloopArms
	608	G_medurgent_midloopSpine
	609	G_medurgent_midaccentDelta
	610	G_medurgent_mid
	611	G_whatapexArms
	612	G_whatapexSpine
	613	G_whatapexDelta
	614	G_whatloopArms
	615	G_whatloopSpine
	616	G_whataccentDelta
	617	G_what
	618	G_lookapexArms
	619	G_lookapexSpine
	620	G_lookapexDelta
	621	G_lookloopArms
	622	G_lookloopSpine
	623	G_lookaccentDelta
	624	G_look
	625	G_look_smallapexArms
	626	G_look_smallapexSpine
	627	G_look_smallapexDelta
	628	G_look_smallloopArms
	629	G_look_smallloopSpine
	630	G_look_smallaccentDelta
	631	G_look_small
	632	G_lookatthisapexArms
	633	G_lookatthisapexSpine
	634	G_lookatthisapexDelta
	635	G_lookatthisloopArms
	636	G_lookatthisloopSpine
	637	G_lookatthisaccentDelta
	638	G_lookatthis
	639	G_righthandrollapexArms
	640	G_righthandrollapexSpine
	641	G_righthandrollapexDelta
	642	G_righthandrollloopArms
	643	G_righthandrollloopSpine
	644	G_righthandrollaccentDelta
	645	G_righthandroll
	646	G_righthandheavyapexArms
	647	G_righthandheavyapexSpine
	648	G_righthandheavyapexDelta
	649	G_righthandheavyloopArms
	650	G_righthandheavyloopSpine
	651	G_righthandheavyaccentDelta
	652	G_righthandheavy
	653	G_righthandpointapexArms
	654	G_righthandpointapexSpine
	655	G_righthandpointapexDelta
	656	G_righthandpointloopArms
	657	G_righthandpointloopSpine
	658	G_righthandpointaccentDelta
	659	G_righthandpoint
	660	G_lefthandmotionapexArms
	661	G_lefthandmotionapexSpine
	662	G_lefthandmotionapexDelta
	663	G_lefthandmotionloopArms
	664	G_lefthandmotionloopSpine
	665	G_lefthandmotionaccentDelta
	666	G_lefthandmotion
	667	G_righthandmotionapexArms
	668	G_righthandmotionapexSpine
	669	G_righthandmotionapexDelta
	670	G_righthandmotionloopArms
	671	G_righthandmotionloopSpine
	672	G_righthandmotionaccentDelta
	673	G_righthandmotion
	674	G_puncuateapexArms
	675	G_puncuateapexSpine
	676	G_puncuateapexDelta
	677	G_puncuateloopArms
	678	G_puncuateloopSpine
	679	G_puncuateaccentDelta
	680	G_puncuate
	681	GestureButtonapexArms
	682	GestureButtonapexSpine
	683	GestureButtonapexDelta
	684	GestureButtonloopArms
	685	GestureButtonloopSpine
	686	GestureButtonaccentDelta
	687	GestureButton
	688	g_SMG1_StopapexArms
	689	g_SMG1_StopapexSpine
	690	g_SMG1_StopapexDelta
	691	g_SMG1_StoploopArms
	692	g_SMG1_StoploopSpine
	693	g_SMG1_StopaccentDelta
	694	g_SMG1_Stop
	695	g_antman_staybackdefault
	696	g_antman_staybackapexDelta
	697	g_antman_staybackloopDelta
	698	g_antman_stayback
	699	g_antman_dontmovedefault
	700	g_antman_dontmoveapexDelta
	701	g_antman_dontmoveloopDelta
	702	g_antman_dontmove
	703	g_antman_punctuatedefault
	704	g_antman_punctuateapexDelta
	705	g_antman_punctuateloopDelta
	706	g_antman_punctuate
	707	g_fistapexArms
	708	g_fistapexSpine
	709	g_fistapexDelta
	710	g_fistloopArms
	711	g_fistloopSpine
	712	g_fistaccentDelta
	713	g_fist
	714	g_fist_LapexArms
	715	g_fist_LapexSpine
	716	g_fist_LapexDelta
	717	g_fist_LloopArms
	718	g_fist_LloopSpine
	719	g_fist_LaccentDelta
	720	g_fist_L
	721	g_fist_swing_acrossapexArms
	722	g_fist_swing_acrossapexSpine
	723	g_fist_swing_acrossapexDelta
	724	g_fist_swing_acrossloopArms
	725	g_fist_swing_acrossloopSpine
	726	g_fist_swing_acrossaccentDelta
	727	g_fist_swing_across
	728	g_point_swingapexArms
	729	g_point_swingapexSpine
	730	g_point_swingapexDelta
	731	g_point_swingloopArms
	732	g_point_swingloopSpine
	733	g_point_swingaccentDelta
	734	g_point_swing
	735	g_point_swing_acrossapexArms
	736	g_point_swing_acrossapexSpine
	737	g_point_swing_acrossapexDelta
	738	g_point_swing_acrossloopArms
	739	g_point_swing_acrossloopSpine
	740	g_point_swing_acrossaccentDelta
	741	g_point_swing_across
	742	g_mid_relaxed_fist_accentapexArms
	743	g_mid_relaxed_fist_accentapexSpine
	744	g_mid_relaxed_fist_accentapexDelta
	745	g_mid_relaxed_fist_accentloopArms
	746	g_mid_relaxed_fist_accentloopSpine
	747	g_mid_relaxed_fist_accentaccentDelta
	748	g_mid_relaxed_fist_accent
	749	g_presentapexArms
	750	g_presentapexSpine
	751	g_presentapexDelta
	752	g_presentloopArms
	753	g_presentloopSpine
	754	g_presentaccentDelta
	755	g_present
	756	g_d2_coast03_Kneel_CallapexArms
	757	g_d2_coast03_Kneel_CallapexSpine
	758	g_d2_coast03_Kneel_CallapexDelta
	759	g_d2_coast03_Kneel_CallloopArms
	760	g_d2_coast03_Kneel_CallloopSpine
	761	g_d2_coast03_Kneel_CallaccentDelta
	762	g_d2_coast03_Kneel_Call
	763	g_d2_coast03_PostBattle_Idle01apexArms
	764	g_d2_coast03_PostBattle_Idle01apexSpine
	765	g_d2_coast03_PostBattle_Idle01apexDelta
	766	g_d2_coast03_PostBattle_Idle01loopArms
	767	g_d2_coast03_PostBattle_Idle01loopSpine
	768	g_d2_coast03_PostBattle_Idle01accentDelta
	769	g_d2_coast03_PostBattle_Idle01
	770	g_d2_coast03_PostBattle_Idle02apexArms
	771	g_d2_coast03_PostBattle_Idle02apexSpine
	772	g_d2_coast03_PostBattle_Idle02apexDelta
	773	g_d2_coast03_PostBattle_Idle02loopArms
	774	g_d2_coast03_PostBattle_Idle02loopSpine
	775	g_d2_coast03_PostBattle_Idle02accentDelta
	776	g_d2_coast03_PostBattle_Idle02
	777	g_Leon_Lean_Table_Map_RespondapexArms
	778	g_Leon_Lean_Table_Map_RespondapexSpine
	779	g_Leon_Lean_Table_Map_RespondapexDelta
	780	g_Leon_Lean_Table_Map_RespondloopArms
	781	g_Leon_Lean_Table_Map_RespondloopSpine
	782	g_Leon_Lean_Table_Map_RespondaccentDelta
	783	g_Leon_Lean_Table_Map_Respond
	784	g_OverHere_LeftapexArms
	785	g_OverHere_LeftapexSpine
	786	g_OverHere_LeftapexDelta
	787	g_OverHere_LeftloopArms
	788	g_OverHere_LeftloopSpine
	789	g_OverHere_LeftaccentDelta
	790	g_OverHere_Left
	791	g_OverHere_RightapexArms
	792	g_OverHere_RightapexSpine
	793	g_OverHere_RightapexDelta
	794	g_OverHere_RightloopArms
	795	g_OverHere_RightloopSpine
	796	g_OverHere_RightaccentDelta
	797	g_OverHere_Right
	798	g_head_backapexArms
	799	g_head_backapexSpine
	800	g_head_backapexDelta
	801	g_head_backloopArms
	802	g_head_backloopSpine
	803	g_head_backaccentDelta
	804	g_head_back
	805	g_head_forwardapexArms
	806	g_head_forwardapexSpine
	807	g_head_forwardapexDelta
	808	g_head_forwardloopArms
	809	g_head_forwardloopSpine
	810	g_head_forwardaccentDelta
	811	g_head_forward
	812	b_OverHere_Leftdefault
	813	b_OverHere_LeftapexDelta
	814	b_OverHere_LeftloopDelta
	815	b_OverHere_Left
	816	b_OverHere_Rightdefault
	817	b_OverHere_RightapexDelta
	818	b_OverHere_RightloopDelta
	819	b_OverHere_Right
	820	b_head_backdefault
	821	b_head_backapexDelta
	822	b_head_backloopDelta
	823	b_head_back
	824	b_head_forwarddefault
	825	b_head_forwardapexDelta
	826	b_head_forwardloopDelta
	827	b_head_forward
	828	b_d2_coast03_PostBattle_Idle02default
	829	b_d2_coast03_PostBattle_Idle02apexDelta
	830	b_d2_coast03_PostBattle_Idle02loopDelta
	831	b_d2_coast03_PostBattle_Idle02
	832	hg_nod_rightdefault
	833	hg_nod_rightapexDelta
	834	hg_nod_rightloopDelta
	835	hg_nod_right
	836	hg_nod_leftdefault
	837	hg_nod_leftapexDelta
	838	hg_nod_leftloopDelta
	839	hg_nod_left
	840	hg_puncuate_downdefault
	841	hg_puncuate_downapexDelta
	842	hg_puncuate_downloopDelta
	843	hg_puncuate_down
	844	hg_headshakedefault
	845	hg_headshakeapexDelta
	846	hg_headshakeloopDelta
	847	hg_headshake
	848	g_buttonpush_rifleapexArms
	849	g_buttonpush_rifleapexSpine
	850	g_buttonpush_rifleapexDelta
	851	g_buttonpush_rifleloopArms
	852	g_buttonpush_rifleloopSpine
	853	g_buttonpush_rifleaccentDelta
	854	g_buttonpush_rifle
	855	g_drop_meleeweaponapexArms
	856	g_drop_meleeweaponapexSpine
	857	g_drop_meleeweaponapexDelta
	858	g_drop_meleeweaponloopArms
	859	g_drop_meleeweaponloopSpine
	860	g_drop_meleeweaponaccentDelta
	861	g_drop_meleeweapon
	862	g_righthand_flickapexArms
	863	g_righthand_flickapexSpine
	864	g_righthand_flickapexDelta
	865	g_righthand_flickloopArms
	866	g_righthand_flickloopSpine
	867	g_righthand_flickaccentDelta
	868	g_righthand_flick
	869	bg_accentUpdefault
	870	bg_accentUpapexDelta
	871	bg_accentUploopDelta
	872	bg_accentUp
	873	bg_accentFwddefault
	874	bg_accentFwdapexDelta
	875	bg_accentFwdloopDelta
	876	bg_accentFwd
	877	bg_accent_leftdefault
	878	bg_accent_leftapexDelta
	879	bg_accent_leftloopDelta
	880	bg_accent_left
	881	g_waveinDelta
	882	g_waveinFrameArms
	883	g_waveinFrameSpine
	884	g_waveinLoopDelta
	885	g_waveloopFrameArms
	886	g_waveloopFrameSpine
	887	g_waveloopDelta
	888	g_waveoutLoopDelta
	889	g_waveOutFrameArms
	890	g_waveOutFrameSpine
	891	g_waveoutDelta
	892	g_wave
	893	g_frustrated_pointinDelta
	894	g_frustrated_pointinFrameArms
	895	g_frustrated_pointinFrameSpine
	896	g_frustrated_pointinLoopDelta
	897	g_frustrated_pointloopFrameArms
	898	g_frustrated_pointloopFrameSpine
	899	g_frustrated_pointloopDelta
	900	g_frustrated_pointoutLoopDelta
	901	g_frustrated_pointOutFrameArms
	902	g_frustrated_pointOutFrameSpine
	903	g_frustrated_pointoutDelta
	904	g_frustrated_point
	905	g_pumpleft_RPGrightapexArms
	906	g_pumpleft_RPGrightapexSpine
	907	g_pumpleft_RPGrightapexDelta
	908	g_pumpleft_RPGrightloopArms
	909	g_pumpleft_RPGrightloopSpine
	910	g_pumpleft_RPGrightaccentDelta
	911	g_pumpleft_RPGright
	912	g_pumpleft_rpgdownapexArms
	913	g_pumpleft_rpgdownapexSpine
	914	g_pumpleft_rpgdownapexDelta
	915	g_pumpleft_rpgdownloopArms
	916	g_pumpleft_rpgdownloopSpine
	917	g_pumpleft_rpgdownaccentDelta
	918	g_pumpleft_rpgdown
	919	g_armsupapexArms
	920	g_armsupapexSpine
	921	g_armsupapexDelta
	922	g_armsuploopArms
	923	g_armsuploopSpine
	924	g_armsupaccentDelta
	925	g_armsup
	926	g_clapapexArms
	927	g_clapapexSpine
	928	g_clapapexDelta
	929	g_claploopArms
	930	g_claploopSpine
	931	g_clapaccentDelta
	932	g_clap
	933	g_rarmpumpapexArms
	934	g_rarmpumpapexSpine
	935	g_rarmpumpapexDelta
	936	g_rarmpumploopArms
	937	g_rarmpumploopSpine
	938	g_rarmpumpaccentDelta
	939	g_rarmpump
	940	g_armsoutapexArms
	941	g_armsoutapexSpine
	942	g_armsoutapexDelta
	943	g_armsoutloopArms
	944	g_armsoutloopSpine
	945	g_armsoutaccentDelta
	946	g_armsout
	947	g_armsout_highapexArms
	948	g_armsout_highapexSpine
	949	g_armsout_highapexDelta
	950	g_armsout_highloopArms
	951	g_armsout_highloopSpine
	952	g_armsout_highaccentDelta
	953	g_armsout_high
	954	g_pumplowapexArms
	955	g_pumplowapexSpine
	956	g_pumplowapexDelta
	957	g_pumplowloopArms
	958	g_pumplowloopSpine
	959	g_pumplowaccentDelta
	960	g_pumplow
	961	g_R_typeapexArms
	962	g_R_typeapexSpine
	963	g_R_typeapexDelta
	964	g_R_typeloopArms
	965	g_R_typeloopSpine
	966	g_R_typeaccentDelta
	967	g_R_type
	968	g_saluteapexArms
	969	g_saluteapexSpine
	970	g_saluteapexDelta
	971	g_saluteloopArms
	972	g_saluteloopSpine
	973	g_saluteaccentDelta
	974	g_salute
	975	g_thumbsupapexArms
	976	g_thumbsupapexSpine
	977	g_thumbsupapexDelta
	978	g_thumbsuploopArms
	979	g_thumbsuploopSpine
	980	g_thumbsupaccentDelta
	981	g_thumbsup
	982	hg_chest_twistLdefault
	983	hg_chest_twistLapexDelta
	984	hg_chest_twistLloopDelta
	985	hg_chest_twistL
	986	sit_breathinDelta
	987	sit_breathinFrameArms
	988	sit_breathinFrameSpine
	989	sit_breathCoreDelta
	990	sit_breathOutFrameArms
	991	sit_breathOutFrameSpine
	992	sit_breathoutDelta
	993	sit_breath
	994	g_breath_lyingdowninDelta
	995	g_breath_lyingdowninFrameArms
	996	g_breath_lyingdowninFrameSpine
	997	g_breath_lyingdownCoreDelta
	998	g_breath_lyingdownOutFrameArms
	999	g_breath_lyingdownOutFrameSpine
	1000	g_breath_lyingdownoutDelta
	1001	g_breath_lyingdown
	1002	g_fistshakeapexArms
	1003	g_fistshakeapexSpine
	1004	g_fistshakeapexDelta
	1005	g_fistshakeloopArms
	1006	g_fistshakeloopSpine
	1007	g_fistshakeaccentDelta
	1008	g_fistshake
	1009	g_pointleft_linDelta
	1010	g_pointleft_linFrameArms
	1011	g_pointleft_linFrameSpine
	1012	g_pointleft_linLoopDelta
	1013	g_pointleft_lloopFrameArms
	1014	g_pointleft_lloopFrameSpine
	1015	g_pointleft_lloopDelta
	1016	g_pointleft_loutLoopDelta
	1017	g_pointleft_lOutFrameArms
	1018	g_pointleft_lOutFrameSpine
	1019	g_pointleft_loutDelta
	1020	g_pointleft_l
	1021	g_pointright_linDelta
	1022	g_pointright_linFrameArms
	1023	g_pointright_linFrameSpine
	1024	g_pointright_linLoopDelta
	1025	g_pointright_lloopFrameArms
	1026	g_pointright_lloopFrameSpine
	1027	g_pointright_lloopDelta
	1028	g_pointright_loutLoopDelta
	1029	g_pointright_lOutFrameArms
	1030	g_pointright_lOutFrameSpine
	1031	g_pointright_loutDelta
	1032	g_pointright_l
	1033	g_point_linDelta
	1034	g_point_linFrameArms
	1035	g_point_linFrameSpine
	1036	g_point_linLoopDelta
	1037	g_point_lloopFrameArms
	1038	g_point_lloopFrameSpine
	1039	g_point_lloopDelta
	1040	g_point_loutLoopDelta
	1041	g_point_lOutFrameArms
	1042	g_point_lOutFrameSpine
	1043	g_point_loutDelta
	1044	g_point_l
	1045	g_point_l_rpginDelta
	1046	g_point_l_rpginFrameArms
	1047	g_point_l_rpginFrameSpine
	1048	g_point_l_rpginLoopDelta
	1049	g_point_l_rpgloopFrameArms
	1050	g_point_l_rpgloopFrameSpine
	1051	g_point_l_rpgloopDelta
	1052	g_point_l_rpgoutLoopDelta
	1053	g_point_l_rpgOutFrameArms
	1054	g_point_l_rpgOutFrameSpine
	1055	g_point_l_rpgoutDelta
	1056	g_point_l_rpg
	1057	hg_turn_ldefault
	1058	hg_turn_lapexDelta
	1059	hg_turn_lloopDelta
	1060	hg_turn_l
	1061	hg_turn_rdefault
	1062	hg_turn_rapexDelta
	1063	hg_turn_rloopDelta
	1064	hg_turn_r
	1065	g_weld_3inDelta
	1066	g_weld_3inFrameArms
	1067	g_weld_3inFrameSpine
	1068	g_weld_3inLoopDelta
	1069	g_weld_3loopFrameArms
	1070	g_weld_3loopFrameSpine
	1071	g_weld_3loopDelta
	1072	g_weld_3outLoopDelta
	1073	g_weld_3OutFrameArms
	1074	g_weld_3OutFrameSpine
	1075	g_weld_3outDelta
	1076	g_weld_3
	1077	g_weld_2inDelta
	1078	g_weld_2inFrameArms
	1079	g_weld_2inFrameSpine
	1080	g_weld_2inLoopDelta
	1081	g_weld_2loopFrameArms
	1082	g_weld_2loopFrameSpine
	1083	g_weld_2loopDelta
	1084	g_weld_2outLoopDelta
	1085	g_weld_2OutFrameArms
	1086	g_weld_2OutFrameSpine
	1087	g_weld_2outDelta
	1088	g_weld_2
	1089	g_weld_downinDelta
	1090	g_weld_downinFrameArms
	1091	g_weld_downinFrameSpine
	1092	g_weld_downinLoopDelta
	1093	g_weld_downloopFrameArms
	1094	g_weld_downloopFrameSpine
	1095	g_weld_downloopDelta
	1096	g_weld_downoutLoopDelta
	1097	g_weld_downOutFrameArms
	1098	g_weld_downOutFrameSpine
	1099	g_weld_downoutDelta
	1100	g_weld_down
	1101	g_ep2_09_holdbeacon_idleapexArms
	1102	g_ep2_09_holdbeacon_idleapexSpine
	1103	g_ep2_09_holdbeacon_idleapexDelta
	1104	g_ep2_09_holdbeacon_idleloopArms
	1105	g_ep2_09_holdbeacon_idleloopSpine
	1106	g_ep2_09_holdbeacon_idleaccentDelta
	1107	g_ep2_09_holdbeacon_idle
	1108	g_ep2_09_holdbeacon_startcarapexArms
	1109	g_ep2_09_holdbeacon_startcarapexSpine
	1110	g_ep2_09_holdbeacon_startcarapexDelta
	1111	g_ep2_09_holdbeacon_startcarloopArms
	1112	g_ep2_09_holdbeacon_startcarloopSpine
	1113	g_ep2_09_holdbeacon_startcaraccentDelta
	1114	g_ep2_09_holdbeacon_startcar
	1115	g_ep2_09_holdbeacon_pointatbeaconapexArms
	1116	g_ep2_09_holdbeacon_pointatbeaconapexSpine
	1117	g_ep2_09_holdbeacon_pointatbeaconapexDelta
	1118	g_ep2_09_holdbeacon_pointatbeaconloopArms
	1119	g_ep2_09_holdbeacon_pointatbeaconloopSpine
	1120	g_ep2_09_holdbeacon_pointatbeaconaccentDelta
	1121	g_ep2_09_holdbeacon_pointatbeacon
	1122	g_ep2_09_holdbeacon_shakebeaconapexArms
	1123	g_ep2_09_holdbeacon_shakebeaconapexSpine
	1124	g_ep2_09_holdbeacon_shakebeaconapexDelta
	1125	g_ep2_09_holdbeacon_shakebeaconloopArms
	1126	g_ep2_09_holdbeacon_shakebeaconloopSpine
	1127	g_ep2_09_holdbeacon_shakebeaconaccentDelta
	1128	g_ep2_09_holdbeacon_shakebeacon
	1129	g_ep2_09_holdbeacon_circusapexArms
	1130	g_ep2_09_holdbeacon_circusapexSpine
	1131	g_ep2_09_holdbeacon_circusapexDelta
	1132	g_ep2_09_holdbeacon_circusloopArms
	1133	g_ep2_09_holdbeacon_circusloopSpine
	1134	g_ep2_09_holdbeacon_circusaccentDelta
	1135	g_ep2_09_holdbeacon_circus
	1136	g_ep2_09_holdbeacon_thumbbehindapexArms
	1137	g_ep2_09_holdbeacon_thumbbehindapexSpine
	1138	g_ep2_09_holdbeacon_thumbbehindapexDelta
	1139	g_ep2_09_holdbeacon_thumbbehindloopArms
	1140	g_ep2_09_holdbeacon_thumbbehindloopSpine
	1141	g_ep2_09_holdbeacon_thumbbehindaccentDelta
	1142	g_ep2_09_holdbeacon_thumbbehind
	1143	g_plead_01_leftapexArms
	1144	g_plead_01_leftapexSpine
	1145	g_plead_01_leftapexDelta
	1146	g_plead_01_leftloopArms
	1147	g_plead_01_leftloopSpine
	1148	g_plead_01_leftaccentDelta
	1149	g_plead_01_left
	1150	GestureButton_rightapexArms
	1151	GestureButton_rightapexSpine
	1152	GestureButton_rightapexDelta
	1153	GestureButton_rightloopArms
	1154	GestureButton_rightloopSpine
	1155	GestureButton_rightaccentDelta
	1156	GestureButton_right
	1157	bg_up_ldefault
	1158	bg_up_lapexDelta
	1159	bg_up_lloopDelta
	1160	bg_up_l
	1161	bg_up_rdefault
	1162	bg_up_rapexDelta
	1163	bg_up_rloopDelta
	1164	bg_up_r
	1165	bg_downdefault
	1166	bg_downapexDelta
	1167	bg_downloopDelta
	1168	bg_down
	1169	bg_leftdefault
	1170	bg_leftapexDelta
	1171	bg_leftloopDelta
	1172	bg_left
	1173	bg_rightdefault
	1174	bg_rightapexDelta
	1175	bg_rightloopDelta
	1176	bg_right
	1177	g_palm_up_lapexArms
	1178	g_palm_up_lapexSpine
	1179	g_palm_up_lapexDelta
	1180	g_palm_up_lloopArms
	1181	g_palm_up_lloopSpine
	1182	g_palm_up_laccentDelta
	1183	g_palm_up_l
	1184	g_palm_up_high_lapexArms
	1185	g_palm_up_high_lapexSpine
	1186	g_palm_up_high_lapexDelta
	1187	g_palm_up_high_lloopArms
	1188	g_palm_up_high_lloopSpine
	1189	g_palm_up_high_laccentDelta
	1190	g_palm_up_high_l
	1191	g_ar2_downinDelta
	1192	g_ar2_downinFrameArms
	1193	g_ar2_downinFrameSpine
	1194	g_ar2_downinLoopDelta
	1195	g_ar2_downloopFrameArms
	1196	g_ar2_downloopFrameSpine
	1197	g_ar2_downloopDelta
	1198	g_ar2_downoutLoopDelta
	1199	g_ar2_downOutFrameArms
	1200	g_ar2_downOutFrameSpine
	1201	g_ar2_downoutDelta
	1202	g_ar2_down
	1203	g_palm_out_lapexArms
	1204	g_palm_out_lapexSpine
	1205	g_palm_out_lapexDelta
	1206	g_palm_out_lloopArms
	1207	g_palm_out_lloopSpine
	1208	g_palm_out_laccentDelta
	1209	g_palm_out_l
	1210	g_frustrated_point_linDelta
	1211	g_frustrated_point_linFrameArms
	1212	g_frustrated_point_linFrameSpine
	1213	g_frustrated_point_linLoopDelta
	1214	g_frustrated_point_lloopFrameArms
	1215	g_frustrated_point_lloopFrameSpine
	1216	g_frustrated_point_lloopDelta
	1217	g_frustrated_point_loutLoopDelta
	1218	g_frustrated_point_lOutFrameArms
	1219	g_frustrated_point_lOutFrameSpine
	1220	g_frustrated_point_loutDelta
	1221	g_frustrated_point_l
	1222	g_palm_out_high_lapexArms
	1223	g_palm_out_high_lapexSpine
	1224	g_palm_out_high_lapexDelta
	1225	g_palm_out_high_lloopArms
	1226	g_palm_out_high_lloopSpine
	1227	g_palm_out_high_laccentDelta
	1228	g_palm_out_high_l
	1229	hg_nod_yesdefault
	1230	hg_nod_yesapexDelta
	1231	hg_nod_yesloopDelta
	1232	hg_nod_yes
	1233	hg_nod_nodefault
	1234	hg_nod_noapexDelta
	1235	hg_nod_noloopDelta
	1236	hg_nod_no
	1237	g_fist_rapexArms
	1238	g_fist_rapexSpine
	1239	g_fist_rapexDelta
	1240	g_fist_rloopArms
	1241	g_fist_rloopSpine
	1242	g_fist_raccentDelta
	1243	g_fist_r
	1244	g_palm_out_rapexArms
	1245	g_palm_out_rapexSpine
	1246	g_palm_out_rapexDelta
	1247	g_palm_out_rloopArms
	1248	g_palm_out_rloopSpine
	1249	g_palm_out_raccentDelta
	1250	g_palm_out_r
	1251	g_palm_out_high_rapexArms
	1252	g_palm_out_high_rapexSpine
	1253	g_palm_out_high_rapexDelta
	1254	g_palm_out_high_rloopArms
	1255	g_palm_out_high_rloopSpine
	1256	g_palm_out_high_raccentDelta
	1257	g_palm_out_high_r
	1258	g_smg_downinDelta
	1259	g_smg_downinFrameArms
	1260	g_smg_downinFrameSpine
	1261	g_smg_downinLoopDelta
	1262	g_smg_downloopFrameArms
	1263	g_smg_downloopFrameSpine
	1264	g_smg_downloopDelta
	1265	g_smg_downoutLoopDelta
	1266	g_smg_downOutFrameArms
	1267	g_smg_downOutFrameSpine
	1268	g_smg_downoutDelta
	1269	g_smg_down
	1270	p_L_forwthrowapexArms
	1271	p_L_forwthrowapexSpine
	1272	p_L_forwthrowapexDelta
	1273	p_L_forwthrowloopArms
	1274	p_L_forwthrowloopSpine
	1275	p_L_forwthrowaccentDelta
	1276	p_L_forwthrow
	1277	g_chestupapexArms
	1278	g_chestupapexSpine
	1279	g_chestupapexDelta
	1280	g_chestuploopArms
	1281	g_chestuploopSpine
	1282	g_chestupaccentDelta
	1283	g_chestup
	1284	g_LhandeaseapexArms
	1285	g_LhandeaseapexSpine
	1286	g_LhandeaseapexDelta
	1287	g_LhandeaseloopArms
	1288	g_LhandeaseloopSpine
	1289	g_LhandeaseaccentDelta
	1290	g_Lhandease
	1291	hg_turnRdefault
	1292	hg_turnRapexDelta
	1293	hg_turnRloopDelta
	1294	hg_turnR
	1295	hg_turnLdefault
	1296	hg_turnLapexDelta
	1297	hg_turnLloopDelta
	1298	hg_turnL
	1299	g_openarmsapexArms
	1300	g_openarmsapexSpine
	1301	g_openarmsapexDelta
	1302	g_openarmsloopArms
	1303	g_openarmsloopSpine
	1304	g_openarmsaccentDelta
	1305	g_openarms
	1306	g_openarms_rightapexArms
	1307	g_openarms_rightapexSpine
	1308	g_openarms_rightapexDelta
	1309	g_openarms_rightloopArms
	1310	g_openarms_rightloopSpine
	1311	g_openarms_rightaccentDelta
	1312	g_openarms_right
	1313	g_pointapexArms
	1314	g_pointapexSpine
	1315	g_pointapexDelta
	1316	g_pointloopArms
	1317	g_pointloopSpine
	1318	g_pointaccentDelta
	1319	g_point
	1320	shiftrightloop
	1321	shiftrightin
	1322	shiftrightout
	1323	shiftright
	1324	shiftrightbigloop
	1325	shiftrightbigin
	1326	shiftrightbigout
	1327	shiftrightbig
	1328	shiftleftloop
	1329	shiftleftin
	1330	shiftleftout
	1331	shiftleft
	1332	P_Drinker_lookrightloop
	1333	P_Drinker_lookrightin
	1334	P_Drinker_lookrightout
	1335	P_Drinker_lookright
	1336	P_Drinker_lookleftloop
	1337	P_Drinker_lookleftin
	1338	P_Drinker_lookleftout
	1339	P_Drinker_lookleft
	1340	P_BreakRoom_WatchClockloop
	1341	P_BreakRoom_WatchClockin
	1342	P_BreakRoom_WatchClockout
	1343	P_BreakRoom_WatchClock
	1344	P_BreakRoom_Sit_01loop
	1345	P_BreakRoom_Sit_01in
	1346	P_BreakRoom_Sit_01out
	1347	P_BreakRoom_Sit_01
	1348	Scan_Skies_Respondloop
	1349	Scan_Skies_Respondin
	1350	Scan_Skies_Respondout
	1351	Scan_Skies_Respond
	1352	p_ConsoleType_Rifleloop
	1353	p_ConsoleType_Riflein
	1354	p_ConsoleType_Rifleout
	1355	p_ConsoleType_Rifle
	1356	p_town05_RadioLeanloop
	1357	p_town05_RadioLeanin
	1358	p_town05_RadioLeanout
	1359	p_town05_RadioLean
	1360	p_bouncingloop
	1361	p_bouncingin
	1362	p_bouncingout
	1363	p_bouncing
	1364	p_stepleftloop
	1365	p_stepleftin
	1366	p_stepleftout
	1367	p_stepleft
	1368	p_jumpuploop
	1369	p_jumpupin
	1370	p_jumpupout
	1371	p_jumpup
	1372	p_balance_toesloop
	1373	p_balance_toesin
	1374	p_balance_toesout
	1375	p_balance_toes
	1376	p_bendoverloop
	1377	p_bendoverin
	1378	p_bendoverout
	1379	p_bendover
	1380	p_stepinloop
	1381	p_stepinin
	1382	p_stepinout
	1383	p_stepin
	1384	P_lean_on_carloop
	1385	P_lean_on_carin
	1386	P_lean_on_carout
	1387	P_lean_on_car
	1388	p_kickloop
	1389	p_kickin
	1390	p_kickout
	1391	p_kick
	1392	p_ar2_step_lloop
	1393	p_ar2_step_lin
	1394	p_ar2_step_lout
	1395	p_ar2_step_l
	1396	p_ar2_relaxedloop
	1397	p_ar2_relaxedin
	1398	p_ar2_relaxedout
	1399	p_ar2_relaxed
	1400	p_point_down_leftloop
	1401	p_point_down_leftin
	1402	p_point_down_leftout
	1403	p_point_down_left
	1404	p_fingerpointuploop
	1405	p_fingerpointupin
	1406	p_fingerpointupout
	1407	p_fingerpointup
	1408	p_readyloop
	1409	p_readyin
	1410	p_readyout
	1411	p_ready
	1412	p_L_foot_forwloop
	1413	p_L_foot_forwin
	1414	p_L_foot_forwout
	1415	p_L_foot_forw
--]]