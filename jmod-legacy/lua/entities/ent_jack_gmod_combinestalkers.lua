AddCSLuaFile()
ENT.Type 			= "anim"
ENT.PrintName		= "Combine Stalkers"
ENT.Author			= "Jackarunda"
ENT.Information		= ""
ENT.Category		= "JMod - LEGACY NPCs"

ENT.Spawnable		= true
ENT.AdminSpawnable	= true
if(SERVER)then
	local SquadName="JackyCombineOpSquad"
	local function EliteOverWatchPhysique(npc)
		npc:ManipulateBoneScale(npc:LookupBone("ValveBiped.Bip01_Spine4"),Vector(1.3,1.2,1.2))
		npc:ManipulateBoneScale(npc:LookupBone("ValveBiped.Bip01_Spine2"),Vector(1,1.1,1.1))
		npc:ManipulateBoneScale(npc:LookupBone("ValveBiped.Bip01_Spine1"),Vector(1,.85,.85))
		npc:ManipulateBoneScale(npc:LookupBone("ValveBiped.Bip01_Spine"),Vector(1,.85,.85))
		npc:ManipulateBoneScale(npc:LookupBone("ValveBiped.Bip01_L_UpperArm"),Vector(1,1.1,1.1))
		npc:ManipulateBoneScale(npc:LookupBone("ValveBiped.Bip01_R_UpperArm"),Vector(1,1.1,1.1))
		npc:ManipulateBoneScale(npc:LookupBone("ValveBiped.Bip01_L_Thigh"),Vector(1,1.1,1.1))
		npc:ManipulateBoneScale(npc:LookupBone("ValveBiped.Bip01_R_Thigh"),Vector(1,1.1,1.1))
	end
	local function Stabbable(stabbee,stabber)
		local TrueVec=(stabber:GetPos()-stabbee:GetPos()):GetNormalized()
		local LookVec=stabbee:GetAimVector()
		local DotProduct=LookVec:DotProduct(TrueVec)
		local ApproachAngle=(-math.deg(math.asin(DotProduct))+90)
		if(ApproachAngle<=120)then
			return false
		else
			return true
		end
	end
	local function DoNotTarget(npc)
		for key,enem in pairs(ents.FindByClass("npc_*"))do
			if(enem:IsNPC())then
				if(enem.GetEnemy)then
					local Nemy=enem:GetEnemy()
					local Targ=enem:GetTarget()
					if(IsValid(Nemy))then
						if(Nemy==npc)then
							if not(table.HasValue(npc.FooledNPCTable,enem))then
								table.insert(npc.FooledNPCTable,enem)
								enem:AddEntityRelationship(npc,D_NU,75)
								enem:SetSchedule(SCHED_RUN_RANDOM)
							end
						end
					end
				end
			end
		end
	end
	local function SetSpecialStalkerThinking(npc)
		local TimerName="JackieInfiltratorThink"..npc:EntIndex()
		npc.OpSquadStalkerState="Normal"
		npc.OpSquadStalkerCamoAmount=0
		npc.OpSquadStalkerCamoIncreasing=false
		npc.NextStalkTime=CurTime()
		npc.LastEnemy=nil
		npc.FooledNPCTable={}
		timer.Create(TimerName,.05,0,function()
			if(IsValid(npc))then
				local Enemy=npc:GetEnemy()
				if(IsValid(Enemy))then
					local Time=CurTime()
					if(Enemy:Health()>0)then
						local SelfPos=npc:GetPos()
						local EnemPos=Enemy:GetPos()
						if(npc.OpSquadStalkerState=="Normal")then
							npc.OpSquadCareful=true
							if(npc.OpSquadStalkerCamoIncreasing)then
								npc.OpSquadStalkerCamoIncreasing=false
								npc:EmitSound("snd_jack_cloakoff.wav")
								--npc:SetCollisionGroup(COLLISION_GROUP_NONE)
								for key,dude in pairs(npc.FooledNPCTable)do
									if(IsValid(dude))then
										dude:AddEntityRelationship(npc,D_HT,80)
									end
									npc.FooledNPCTable[key]=nil
								end
							end
							if(npc.NextStalkTime<Time)then
								if(math.random(1,75)==5)then
									npc.OpSquadStalkerState="Stalking"
									npc.NextStalkTime=Time+5
								end
							end
						elseif(npc.OpSquadStalkerState=="Stalking")then
							-- there are no brakes on the FUCKING RAPE TRAIN
							npc.OpSquadCareful=false
							if not(npc.OpSquadStalkerCamoIncreasing)then
								npc.OpSquadStalkerCamoIncreasing=true
								npc:EmitSound("snd_jack_cloakon.wav")
								--npc:SetCollisionGroup(COLLISION_GROUP_WEAPON)
							end
							npc:Fire("gagenable","",0)
							npc:GetActiveWeapon().NextFire=CurTime()+1
							if not(Stabbable(Enemy,npc))then
								if not(npc:IsCurrentSchedule(SCHED_FORCED_GO_RUN))then
									npc:SetLastPosition(EnemPos-Enemy:GetForward()*70)
									npc:SetSchedule(SCHED_FORCED_GO_RUN)
								end
							else
								local Vec=EnemPos-SelfPos
								local Dist=Vec:Length()
								if(Dist<60)then
									npc.NextStalkTime=Time+5
									npc.OpSquadStalkerState="Normal"
									npc.OpSquadStalkerCamoAmount=npc.OpSquadStalkerCamoAmount-5
									npc:EmitSound("snd_jack_stalkerwindup.wav")
									npc:GetActiveWeapon():DeployBlade()
									JackyPlayNPCAnim(npc,"swing",true,.5)
									timer.Simple(.3,function()
										if((IsValid(npc))and(IsValid(Enemy)))then
											local NewSelfPos=npc:GetPos()
											local NewEnemPos=Enemy:GetPos()
											local NewDist=(NewSelfPos-NewEnemPos):Length()
											if(NewDist<70)then
												local TrDat={}
												TrDat.start=NewSelfPos
												TrDat.endpos=NewEnemPos
												TrDat.filter={npc,Enemy}
												local Tr=util.TraceLine(TrDat)
												if not(Tr.Hit)then
													local Pos=npc:GetShootPos()+npc:GetAimVector()*30
													local Dam=DamageInfo()
													Dam:SetAttacker(npc)
													Dam:SetInflictor(npc)
													Dam:SetDamage(math.random(60,120))
													Dam:SetDamageType(DMG_SLASH)
													Dam:SetDamageForce(npc:GetAimVector()*1e5)
													Dam:SetDamagePosition(Pos)
													npc:EmitSound("snd_jack_stalkerslice.wav")
													--Enemy:EmitSound("Flesh.Break")
													Enemy:TakeDamageInfo(Dam)
												end
											end
										end
									end)
								else
									if not(npc:IsCurrentSchedule(SCHED_FORCED_GO_RUN))then
										npc:SetLastPosition(EnemPos-Enemy:GetForward()*50)
										npc:SetSchedule(SCHED_FORCED_GO_RUN)
									end
								end
							end
						end
						npc.LastEnemy=Enemy
					else
						npc.OpSquadCareful=true
						npc:Fire("gagdisable","",0)
						npc.OpSquadStalkerState="Normal"
						npc.OpSquadLastEnemy=nil
					end
				else
					npc.OpSquadCareful=true
					npc:Fire("gagdisable","",0)
					npc.OpSquadStalkerState="Normal"
					npc.OpSquadLastEnemy=nil
				end
				if(npc.OpSquadStalkerCamoIncreasing)then
					npc.OpSquadStalkerCamoAmount=npc.OpSquadStalkerCamoAmount+1
					if(npc.OpSquadStalkerCamoAmount>20)then
						npc.OpSquadStalkerCamoAmount=20
						npc:RemoveAllDecals()
					end
				else
					npc.OpSquadStalkerCamoAmount=npc.OpSquadStalkerCamoAmount-1
					if(npc.OpSquadStalkerCamoAmount<0)then npc.OpSquadStalkerCamoAmount=0 end
				end
				if(npc.OpSquadStalkerCamoAmount>0)then
					local Num=npc.OpSquadStalkerCamoAmount
					npc:SetMaterial("models/no_brakes_on_the_rape_train/mat_jack_invis_"..tostring(Num))
					if(npc.OpSquadStalkerCamoAmount>5)then
						local Wep=npc:GetActiveWeapon()
						if(IsValid(Wep))then
							if not(Wep.NoSetNoDraw)then
								Wep:SetNoDraw(true)
							end
						end
						npc:DrawShadow(false)
						if(npc.OpSquadStalkerCamoAmount>7)then
							DoNotTarget(npc)
						end
					end
				else
					npc:SetMaterial("")
					local Wep=npc:GetActiveWeapon()
					if(IsValid(Wep))then
						Wep:SetNoDraw(false)
					end
					npc:DrawShadow(true)
				end
			else
				timer.Destroy(TimerName)
			end
		end)
	end
	function ENT:SpawnFunction(ply,tr)
		local selfpos=tr.HitPos+tr.HitNormal*16
		local npc1
		local npc2
		local npc=ents.Create("npc_metropolice")
		npc:SetPos(selfpos+Vector(20,-20,0))
		npc:SetAngles(Angle(0,-45,0))
		npc:SetKeyValue("additionalequipment","wep_jack_gmod_npcstalkerpistol")
		npc:SetKeyValue("spawnflags","256")
		npc:SetMaxHealth(40)
		npc:SetHealth(40)
		npc:CapabilitiesAdd(CAP_MOVE_SHOOT)
		npc:CapabilitiesAdd(CAP_NO_HIT_SQUADMATES)
		npc:Spawn()
		npc:SetModel("models/dpfilms/metropolice/jlacop.mdl")
		npc.JackyOpSquadDrop={"item_ammo_pistol_large","item_healthvial"}
		npc.JackyFirePowerMult=1.3
		npc.JackyProtectionMult=1.2
		npc.OpSquadFullBodySuit=true
		npc.OpSquadFlameRetardantSuit=true
		npc:SetBloodColor(-1)
		npc.OpSquadGoodHelmet=true
		npc:Activate()
		EliteOverWatchPhysique(npc)
		npc:SetKeyValue("SquadName",SquadName)
		npc.JackyDamageGroup=SquadName
		npc:SetCurrentWeaponProficiency(WEAPON_PROFICIENCY_PERFECT)
		npc:Fire("startpatrolling","",10)
		npc.NextHealTime=CurTime()
		npc.OpSquadAmazingHunter=true
		npc.OpSquadAware=true
		npc.OpSquadAggressive=true
		npc.OpSquadCareful=true
		npc.OpSquadStalker=true
		SetSpecialStalkerThinking(npc)
		JackyOpSquadSpawnEvent(npc)
		npc1=npc
		local npc=ents.Create("npc_metropolice")
		npc:SetPos(selfpos+Vector(-20,20,0))
		npc:SetAngles(Angle(0,135,0))
		npc:SetKeyValue("additionalequipment","wep_jack_gmod_npcstalkerpistol")
		npc:SetKeyValue("spawnflags","256")
		npc:SetMaxHealth(40)
		npc:SetHealth(40)
		npc:CapabilitiesAdd(CAP_MOVE_SHOOT)
		npc:CapabilitiesAdd(CAP_NO_HIT_SQUADMATES)
		npc:Spawn()
		npc:SetModel("models/dpfilms/metropolice/jlacop.mdl")
		npc.JackyOpSquadDrop={"item_ammo_pistol_large","item_healthvial"}
		npc.JackyFirePowerMult=1.3
		npc.JackyProtectionMult=1.2
		npc.OpSquadFullBodySuit=true
		npc.OpSquadFlameRetardantSuit=true
		npc:SetBloodColor(-1)
		npc.OpSquadGoodHelmet=true
		npc:Activate()
		EliteOverWatchPhysique(npc)
		npc:SetKeyValue("SquadName",SquadName)
		npc.JackyDamageGroup=SquadName
		npc:SetCurrentWeaponProficiency(WEAPON_PROFICIENCY_PERFECT)
		npc:Fire("startpatrolling","",10)
		npc.NextHealTime=CurTime()
		npc.OpSquadAmazingHunter=true
		npc.OpSquadAware=true
		npc.OpSquadAggressive=true
		npc.OpSquadCareful=true
		npc.OpSquadStalker=true
		SetSpecialStalkerThinking(npc)
		JackyOpSquadSpawnEvent(npc)
		npc2=npc
		timer.Simple(0.4,function()
			undo.Create("HyperElite Combine Squad")
			undo.SetPlayer(ply)
			if(IsValid(npc1))then undo.AddEntity(npc1) end
			if(IsValid(npc2))then undo.AddEntity(npc2) end
			undo.AddFunction(function(undo)
				for key,found in pairs(ents.FindByClass("npc_cscanner"))do
					if((found:GetOwner()==npc1)or(found:GetOwner()==npc2))then SafeRemoveEntity(found) end
				end
			end)
			undo.SetCustomUndoText("Undone Combine Stalkers")
			undo.Finish()
		end)
	end
	JackieNPCSpawningTable.Modified["Combine Stalker"]=function(selfpos)
		local npc=ents.Create("npc_metropolice")
		npc:SetPos(selfpos)
		npc:SetAngles(Angle(0,0,0))
		npc:SetKeyValue("additionalequipment","wep_jack_gmod_npcstalkerpistol")
		npc:SetKeyValue("spawnflags","256")
		npc:SetMaxHealth(40)
		npc:SetHealth(40)
		npc:CapabilitiesAdd(CAP_MOVE_SHOOT)
		npc:CapabilitiesAdd(CAP_NO_HIT_SQUADMATES)
		npc:Spawn()
		npc:SetModel("models/dpfilms/metropolice/jlacop.mdl")
		npc.JackyOpSquadDrop={"item_ammo_pistol_large","item_healthvial"}
		npc.JackyFirePowerMult=1.3
		npc.JackyProtectionMult=1.2
		npc.OpSquadFullBodySuit=true
		npc.OpSquadFlameRetardantSuit=true
		npc:SetBloodColor(-1)
		npc.OpSquadGoodHelmet=true
		npc:Activate()
		EliteOverWatchPhysique(npc)
		npc:SetKeyValue("SquadName",SquadName)
		npc.JackyDamageGroup=SquadName
		npc:SetCurrentWeaponProficiency(WEAPON_PROFICIENCY_PERFECT)
		npc:Fire("startpatrolling","",10)
		npc.NextHealTime=CurTime()
		npc.OpSquadAmazingHunter=true
		npc.OpSquadAware=true
		npc.OpSquadAggressive=true
		npc.OpSquadCareful=true
		npc.OpSquadStalker=true
		SetSpecialStalkerThinking(npc)
		JackyOpSquadSpawnEvent(npc)
		return npc
	end
end