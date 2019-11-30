AddCSLuaFile()
ENT.Type 			= "anim"
ENT.PrintName		= "J.I. Superhack"
ENT.Author			= "Jackarunda"
ENT.Information	="One Jackarunda Industries Mk.1 Mod 0 Viscerator. This is a manhack captured \nfrom the Combine and re-engineered for greater combat effectiveness. It is more compactly constructed with a frame \nof high-grade titanium instead of cheap mass-produced steel. It also has a significantly larger Combine dark-energy \npower core. Its razor-sharp blades spin much faster than that of normal hacks, allowing it to fly faster and dive \nharder into targets. It also has steel-backed carbide-ceramic armor slats for added protection. Its sophisticated, \naggressive J.I. software suite allows it to spot targets at over 5 kilometers, tear toward a target at breakneck \nspeed and dispatch it with ruthless efficiency. Every J.I. Viscerator shares information with others via onboard wireless \nnetwork hardware. Hold E while clicking to spawn as hostile."
ENT.Category		= "JMod - LEGACY NPCs"

ENT.Spawnable		= true
ENT.AdminSpawnable	= true
if(SERVER)then
	function ENT:SpawnFunction(ply, tr)

		local selfpos=tr.HitPos+tr.HitNormal*16
		
		local HostileHacks=false
		if(ply:KeyDown(IN_USE))then HostileHacks=true end
		
		self.HeightTable={
			["npc_zombie"]=45,
			["npc_zombine"]=40,
			["npc_fastzombie"]=40,
			["npc_antlionguard"]=50,
			["npc_fastzombie_torso"]=10,
			["npc_zombie_torso"]=10,
			["npc_hunter"]=60,
			["npc_antlion"]=30,
			["npc_citizen"]=45,
			["npc_combine_s"]=45,
			["npc_poisonzombie"]=40,
			["npc_combine_s"]=45,
			["npc_breen"]=45,
			["npc_antlion_worker"]=30,
			["npc_turret_floor"]=35,
			["npc_headcrab"]=5,
			["npc_headcrab_fast"]=5,
			["npc_headcrab_black"]=5,
			["npc_headcrab_poison"]=5,
			["npc_metropolice"]=38,
			["player"]=45
		}
		
		self.WidthTable={
			[HULL_HUMAN]=30, --hull_human
			[HULL_SMALL_CENTERED]=28, --hull_small_centered
			[HULL_WIDE_HUMAN]=34, --hull_wide_human
			[HULL_TINY]=11, --hull_tiny
			[HULL_WIDE_SHORT]=40, --hull_wide_short
			[HULL_MEDIUM]=40, --hull_medium
			[HULL_TINY_CENTERED]=16, --hull_tiny_centered
			[HULL_LARGE]=80, --hull_large
			[HULL_LARGE_CENTERED]=40, --hull_large_centered
			[HULL_MEDIUM_TALL]=40 --hull_medium_tall
		}
		
		local hack1
		
		local manhack=ents.Create("npc_manhack")
		manhack:SetPos(selfpos)
		manhack:SetKeyValue("spawnflags","65794") --256+65536=65792
		manhack.NeedsMoarFirePower=true
		manhack.HasHighTechJIArmor=true
		manhack.IsAJIViscerator=true
		manhack.InAJackyManhackSquad=true
		manhack.NextLungeTime=CurTime()
		manhack:Spawn()
		manhack:Activate()
		manhack:SetModel("models/janhack.mdl")
		manhack:SetMaxHealth(30)
		manhack:SetHealth(30)
		manhack:SetKeyValue("WakeSquad","1")
		manhack:SetKeyValue("IgnoreUnseenEnemies","0")
		manhack:SetKeyValue("SquadName","JIVisceratorSquad")
		
		JackyAlterAllegiances(manhack,!HostileHacks)
		
		local timername="BeepManhack"..manhack:EntIndex()
		timer.Create(timername,1.75,0,function()
			if not(IsValid(manhack))then timer.Destroy(timername) return end
			local hackpos=manhack:GetPos()
			if not(IsValid(manhack:GetEnemy()))then
				manhack:EmitSound("snds_jack_gmod/search.wav",65,100)
			end
			for key,found in pairs(ents.FindByClass("npc_*"))do
				local enemypos=found:GetPos()
				if(manhack:Disposition(found)==D_HT)then
					if not(IsValid(manhack:GetEnemy()))then
						if(found:Visible(manhack))then
							manhack:SetTarget(found)
							manhack:UpdateEnemyMemory(found,enemypos)
						end
					end
				end
			end
		end)
		
		local timername="FastManhack"..manhack:EntIndex()
		timer.Create(timername,0.1,0,function()
			if not(IsValid(manhack))then timer.Destroy(timername) return end
			local hackpos=manhack:GetPos()
			if(IsValid(manhack:GetEnemy()))then
				if(manhack.NextTargetTime<CurTime())then
					manhack.ChargeUpSoundPlayed=false
					local enemy=manhack:GetEnemy()
					local height=self.HeightTable[enemy:GetClass()]
					if not(height)then height=5 end
					local enemypos=enemy:GetPos()+Vector(0,0,height)
					local dir=(enemypos-hackpos):GetNormalized()
					local dist=(enemypos-hackpos):Length()
					if(dist<200)then
						if(manhack.NextLungeTime<CurTime())then
							local health=manhack:Health()
							manhack:SetAngles(dir:Angle())
							manhack:TakeDamage(1,worldspawn)
							manhack:SetHealth(health)
							manhack:EmitSound("snds_jack_gmod/lunge.wav")
							if(IsValid(manhack:GetPhysicsObject()))then
								if(enemy:GetVelocity():Length()>200)then
									manhack:GetPhysicsObject():ApplyForceCenter(dir*8000)
									ThrustSmoke(hackpos,dir)
									timer.Simple(0.05,function()
										if(IsValid(manhack))then
											ThrustSmoke(manhack:GetPos(),dir)
										end
									end)
								else
									manhack:GetPhysicsObject():ApplyForceCenter(dir*4000)
									ThrustSmoke(hackpos,dir)
									timer.Simple(0.05,function()
										if(IsValid(manhack))then
											ThrustSmoke(manhack:GetPos(),dir)
										end
									end)
								end
							end
							manhack.NextLungeTime=CurTime()+1.2
						end
					else
						local traceinfo={}
						traceinfo.start=hackpos
						traceinfo.endpos=enemypos
						traceinfo.filter={manhack,enemy}
						local trace=util.TraceLine(traceinfo)
						if not(trace.Hit)then
							local health=manhack:Health()
							manhack:SetAngles(dir:Angle())
							manhack:TakeDamage(1,worldspawn)
							manhack:SetHealth(health)
							if(IsValid(manhack:GetPhysicsObject()))then
								local Vel=manhack:GetPhysicsObject():GetVelocity()
								if(dist>1000)then
									if not(manhack.TakeOffSoundPlayed)then
										manhack:EmitSound("snds_jack_gmod/take_off.wav")
										manhack.TakeOffSoundPlayed=true
									end
									manhack:GetPhysicsObject():ApplyForceCenter(dir*16000)
									AirVwoosh(hackpos,Vel,1)
									if not(manhack.RotorWashEntity)then MakeRotorWash(manhack) end
								else
									if(enemy:GetVelocity():Length()>450)then
										if not(manhack.TakeOffSoundPlayed)then
											manhack:EmitSound("snds_jack_gmod/take_off.wav")
											manhack.TakeOffSoundPlayed=true
										end
										manhack:GetPhysicsObject():ApplyForceCenter(dir*10000)
										AirVwoosh(hackpos,Vel,0.525)
										if not(manhack.RotorWashEntity)then MakeRotorWash(manhack) end
									else
										manhack:GetPhysicsObject():ApplyForceCenter(dir*4000)
										if(manhack.RotorWashEntity)then RemoveRotorWash(manhack) end
										manhack.TakeOffSoundPlayed=false
									end
								end
							end
						end
					end
				else
					if not(manhack.ChargeUpSoundPlayed)then
						manhack:EmitSound("snds_jack_gmod/go_charge.wav")
						manhack.ChargeUpSoundPlayed=true
					end
				end
			else
				manhack.NextTargetTime=CurTime()+1.75
				if(manhack.RotorWashEntity)then RemoveRotorWash(manhack) end
				manhack.ChargeUpSoundPlayed=false
				manhack.TakeOffSoundPlayed=false
			end
		end)
		
		manhack:Fire("unpack","",0)
		
		manhack:ManipulateBoneScale(manhack:LookupBone("Manhack.MH_Control"),Vector(.75,.75,.75))
		manhack:ManipulateBoneScale(manhack:LookupBone("Manhack.MH_ControlBodyUpper"),Vector(.75,.75,.75))
		manhack:ManipulateBoneScale(manhack:LookupBone("Manhack.MH_ControlPincerTop"),Vector(.5,.5,.5))
		manhack:ManipulateBoneScale(manhack:LookupBone("Manhack.MH_ControlPanel1"),Vector(1.25,1.25,1.25))
		manhack:ManipulateBoneScale(manhack:LookupBone("Manhack.MH_ControlPanel2"),Vector(1.25,1.25,1.25))
		manhack:ManipulateBoneScale(manhack:LookupBone("Manhack.MH_ControlPanel3"),Vector(1.25,1.25,1.25))
		manhack:ManipulateBoneScale(manhack:LookupBone("Manhack.MH_ControlPanel4"),Vector(1.25,1.25,1.25))
		manhack:ManipulateBoneScale(manhack:LookupBone("Manhack.MH_ControlPanel5"),Vector(1.25,1.25,1.25))
		manhack:ManipulateBoneScale(manhack:LookupBone("Manhack.MH_ControlPanel6"),Vector(.75,.75,.75))
		manhack:ManipulateBoneScale(manhack:LookupBone("Manhack.MH_ControlExhaust"),Vector(.75,.75,.75))
		manhack:ManipulateBoneScale(manhack:LookupBone("Manhack.MH_ControlBodyLower"),Vector(.75,.75,.75))
		manhack:ManipulateBoneScale(manhack:LookupBone("Manhack.MH_ControlPincerBottom"),Vector(.5,.5,.5))
		manhack:ManipulateBoneScale(manhack:LookupBone("Manhack.MH_ControlCamera"),Vector(.75,.75,.75))
		manhack:ManipulateBoneScale(manhack:LookupBone("Manhack.MH_ControlBlade"),Vector(2,2,2))
		manhack:ManipulateBoneScale(manhack:LookupBone("Manhack.MH_ControlBlade1"),Vector(2,2,2))
		
		local effectdata=EffectData()
		effectdata:SetEntity(manhack)
		--util.Effect("propspawn",effectdata)
		
		hack1=manhack

		//PrintTable(manhack:GetKeyValues()) --DEBUG: GOTTA SEE SOME STUFF
		//for i=0, manhack:GetBoneCount() - 1 do
		//	print(manhack:GetBoneName(i)) --DEBUG: GOTTA SEE SOME MOAR STUFF
		//end
		
		timer.Simple(0.05,function()
			undo.Create("Manhack")
				if(IsValid(hack1))then undo.AddEntity(hack1) end
				undo.SetCustomUndoText("Undone JI Viscerator.")
				undo.SetPlayer(ply)
			undo.Finish()
		end)
	end

	/*----------------------------------------------------------------------------------
		This creates epic shrapnel whenever a JI Viscerator is destroyed
	----------------------------------------------------------------------------------*/
	function KaBewm(npc,attacker,inflictor)
		if((npc.IsAJIViscerator)and not(npc.IsAJIGunhack))then
			JMod_Sploom(npc,npc:GetPos()+Vector(0,0,20),50)
			
			//local poz=npc:GetPos()
			//util.BlastDamage(npc,npc,poz,100,500)

			local gib=ents.Create("prop_physics")
			gib:SetModel("models/Gibs/manhack_gib06.mdl")
			gib:SetMaterial("models/janhack/manhackgib_sheet")
			gib:SetPos(npc:GetPos()+VectorRand()*math.Rand(2,20))
			gib:Spawn()
			gib:Activate()
			gib:GetPhysicsObject():SetMass(10)
			gib:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
			local dir=((attacker:GetPos()+Vector(0,0,20))-npc:GetPos()):GetNormalized()
			gib:GetPhysicsObject():SetVelocity(dir*math.Rand(1500,2000))
			SafeRemoveEntityDelayed(gib,math.Rand(10,20))
			
			local gib=ents.Create("prop_physics")
			gib:SetModel("models/Gibs/manhack_gib06.mdl")
			gib:SetMaterial("models/janhack/manhackgib_sheet")
			gib:SetPos(npc:GetPos()+VectorRand()*math.Rand(2,20))
			gib:Spawn()
			gib:Activate()
			gib:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
			gib:GetPhysicsObject():SetMass(10)
			gib:GetPhysicsObject():SetVelocity(VectorRand()*math.Rand(1500,2000))
			SafeRemoveEntityDelayed(gib,math.Rand(10,20))
			
			local gib=ents.Create("prop_physics")
			gib:SetModel("models/Gibs/manhack_gib06.mdl")
			gib:SetMaterial("models/janhack/manhackgib_sheet")
			gib:SetPos(npc:GetPos()+VectorRand()*math.Rand(2,20))
			gib:Spawn()
			gib:Activate()
			gib:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
			gib:GetPhysicsObject():SetMass(10)
			gib:GetPhysicsObject():SetVelocity(VectorRand()*math.Rand(1500,2000))
			SafeRemoveEntityDelayed(gib,math.Rand(10,20))
			
			local gib=ents.Create("prop_physics")
			gib:SetModel("models/Gibs/manhack_gib05.mdl")
			gib:SetMaterial("models/janhack/manhackgib_sheet")
			gib:SetPos(npc:GetPos()+VectorRand()*math.Rand(2,20))
			gib:Spawn()
			gib:Activate()
			gib:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
			gib:GetPhysicsObject():SetMass(10)
			local dir=((attacker:GetPos()+VectorRand()*100)-npc:GetPos()):GetNormalized()
			gib:GetPhysicsObject():SetVelocity(dir*math.Rand(1500,2000))
			SafeRemoveEntityDelayed(gib,math.Rand(10,20))
			
			local gib=ents.Create("prop_physics")
			gib:SetModel("models/Gibs/manhack_gib05.mdl")
			gib:SetMaterial("models/janhack/manhackgib_sheet")
			gib:SetPos(npc:GetPos()+VectorRand()*math.Rand(2,20))
			gib:Spawn()
			gib:Activate()
			gib:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
			gib:GetPhysicsObject():SetMass(10)
			gib:GetPhysicsObject():SetVelocity(VectorRand()*math.Rand(1500,2000))
			SafeRemoveEntityDelayed(gib,math.Rand(10,20))
			
			local gib=ents.Create("prop_physics")
			gib:SetModel("models/Gibs/manhack_gib05.mdl")
			gib:SetMaterial("models/janhack/manhackgib_sheet")
			gib:SetPos(npc:GetPos()+VectorRand()*math.Rand(2,20))
			gib:Spawn()
			gib:Activate()
			gib:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
			gib:GetPhysicsObject():SetMass(10)
			gib:GetPhysicsObject():SetVelocity(VectorRand()*math.Rand(1500,2000))
			SafeRemoveEntityDelayed(gib,math.Rand(10,20))
			
			local gib=ents.Create("prop_physics")
			gib:SetModel("models/Gibs/manhack_gib04.mdl")
			gib:SetMaterial("models/janhack/manhackgib_sheet")
			gib:SetPos(npc:GetPos()+VectorRand()*math.Rand(2,20))
			gib:Spawn()
			gib:Activate()
			gib:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
			gib:GetPhysicsObject():SetMass(10)
			gib:GetPhysicsObject():SetVelocity(VectorRand()*math.Rand(1500,2000))
			SafeRemoveEntityDelayed(gib,math.Rand(10,20))
			
			local gib=ents.Create("prop_physics")
			gib:SetModel("models/Gibs/manhack_gib03.mdl")
			gib:SetMaterial("models/janhack/manhackgib_sheet")
			gib:SetPos(npc:GetPos()+VectorRand()*math.Rand(2,20))
			gib:Spawn()
			gib:Activate()
			gib:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
			gib:GetPhysicsObject():SetMass(10)
			gib:GetPhysicsObject():SetVelocity(VectorRand()*math.Rand(1500,2000))
			SafeRemoveEntityDelayed(gib,math.Rand(10,20))
			
			local gib=ents.Create("prop_physics")
			gib:SetModel("models/Gibs/manhack_gib01.mdl")
			gib:SetMaterial("models/janhack/manhackgib_sheet")
			gib:SetPos(npc:GetPos()+VectorRand()*math.Rand(2,20))
			gib:Spawn()
			gib:Activate()
			gib:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
			gib:GetPhysicsObject():SetMass(10)
			gib:GetPhysicsObject():SetVelocity(VectorRand()*math.Rand(1500,2000))
			SafeRemoveEntityDelayed(gib,math.Rand(10,20))
			
			local gib=ents.Create("prop_physics")
			gib:SetModel("models/Gibs/manhack_gib01.mdl")
			gib:SetMaterial("models/janhack/manhackgib_sheet")
			gib:SetPos(npc:GetPos()+VectorRand()*math.Rand(2,20))
			gib:Spawn()
			gib:Activate()
			gib:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
			gib:GetPhysicsObject():SetMass(10)
			gib:GetPhysicsObject():SetVelocity(VectorRand()*math.Rand(1500,2000))
			SafeRemoveEntityDelayed(gib,math.Rand(10,20))
		end
	end
	hook.Add("OnNPCKilled","JIVisceratorDeath",KaBewm)

	function ThrustSmoke(position,direction)
		local Smoak=EffectData()
		Smoak:SetOrigin(position)
		Smoak:SetStart(VectorRand())
		Smoak:SetNormal(-direction)
		util.Effect("eff_jack_gmod_thrustsmoke",Smoak)
	end

	function AirVwoosh(position,velocity,size)
		local Vwoosh=EffectData()
		Vwoosh:SetOrigin(position+velocity*0.2)
		Vwoosh:SetScale(size)
		util.Effect("eff_jack_gmod_airdestruction",Vwoosh)
	end

	function MakeRotorWash(npc)
		npc.RotorWashEntity=ents.Create("env_rotorwash_emitter")
		npc.RotorWashEntity:SetPos(npc:GetPos())
		npc.RotorWashEntity:SetParent(npc)
		npc.RotorWashEntity:Activate()
	end

	function RemoveRotorWash(npc)
		npc.RotorWashEntity:Remove()
		npc.RotorWashEntity=nil
	end
end