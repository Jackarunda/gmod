AddCSLuaFile()ENT.Type 			= "anim"
ENT.PrintName		= "Headcrabs"
ENT.Author			= "Jackarunda and Jimbomcb"
ENT.Information		= ""
ENT.Category		= "JMod - LEGACY NPCs"

ENT.Spawnable		= true
ENT.AdminSpawnable	= true
if(SERVER)then
	local Delay=4
	local ModelTable={
		[1]="models/props_debris/concrete_chunk03a.mdl",
		[2]="models/props_debris/concrete_chunk04a.mdl",
		[3]="models/props_debris/concrete_chunk02a.mdl",
		[4]="models/props_debris/concrete_chunk05g.mdl",
	}
	local MaterialTable={
		[MAT_CONCRETE]="models/props_debris/plasterwall021a",
		[MAT_DIRT]="models/props_foliage/tree_deciduous_01a_trunk",
		[MAT_SAND]="models/props_foliage/tree_deciduous_01a_trunk"
	}
	local function ThrowShit(Pod,Position,GroundType)
		if(GroundType==MAT_METAL)then return end
		local ChunkMaterial="models/props_debris/plasterwall021a"
		if(MaterialTable[GroundType])then
			ChunkMaterial=MaterialTable[GroundType]
		end
		for i=0,15 do
			local Chunk=ents.Create("prop_physics")
			Chunk:SetModel(ModelTable[math.random(1,4)])
			Chunk:SetPos(Position)
			Chunk:SetMaterial(ChunkMaterial)
			Chunk:Spawn()
			Chunk:Activate()
			Chunk:GetPhysicsObject():SetMass(75)
			Chunk:GetPhysicsObject():SetVelocity(Vector(0,0,math.Rand(100,1000))+VectorRand()*math.Rand(100,1000))
			SafeRemoveEntityDelayed(Chunk,math.Rand(10,20))
		end
	end
	function ENT:SpawnFunction(ply,tr)
		if(!tr.Hit)then return end
		//Jimbomcb wrote this code really, I just copied it from his SWEP and modified it a little
		//now to do calculations
		local InitialPositionVector=tr.HitPos
		local SurfaceNormalAngle=tr.HitNormal:Angle()
		local Right=SurfaceNormalAngle:Right()
		local Up=SurfaceNormalAngle:Up()
		local PodPositionOne=InitialPositionVector+Right*100
		local PodPositionTwo=InitialPositionVector-Right*70+Up*100
		local PodPositionThree=InitialPositionVector-Right*70-Up*100
		util.PrecacheModel("models/headcrabclassic.mdl")
		util.PrecacheModel("models/headcrab.mdl")
		util.PrecacheModel("models/headcrabblack.mdl")
		util.PrecacheModel("models/props_combine/headcrabcannister01a.mdl")
		util.PrecacheModel("models/props_combine/headcrabcannister01b.mdl")
		local pod1
		local pod2
		local pod3
		local explosion1
		local explosion2
		local explosion3
		//valve, you lazy game developer you. I have to make an explosion myself to make the pods' impacts look realistic
		local YawIncrement=20
		local PitchIncrement=10
		if(SERVER)then
			local CanistersCouldntLaunch=0
			local aBaseAngle=tr.HitNormal:Angle()
			local aBasePos=PodPositionOne
			local bScanning=true
			local iPitch=10
			local iYaw=-180
			local iLoopLimit=0
			local iProcessedTotal=0
			local tValidHits={}
			while((bScanning==true)and(iLoopLimit<500))do
				iYaw=iYaw+YawIncrement
				iProcessedTotal=iProcessedTotal+1
				if(iYaw>=180)then
					iYaw=-180
					iPitch=iPitch-PitchIncrement
				end
				local tLoop=util.QuickTrace(aBasePos,(aBaseAngle+Angle(iPitch,iYaw,0)):Forward()*40000)
				if(tLoop.HitSky)then
					table.insert(tValidHits,tLoop)
				end
				if(iPitch<=-80)then
					bScanning=false
				end
				iLoopLimit=iLoopLimit+1
			end
			local iHits=table.Count(tValidHits)
			if(iHits>0)then
				local iRand=math.random(1,iHits)
				local tRand=tValidHits[iRand]
				pod1=ents.Create("env_headcrabcanister")
				pod1:SetPos(aBasePos)
				pod1:SetAngles((tRand.HitPos-tRand.StartPos):Angle())
				pod1:SetKeyValue("HeadcrabType",2)
				pod1:SetKeyValue("HeadcrabCount",10)
				pod1:SetKeyValue("FlightSpeed",7500)
				pod1:SetKeyValue("FlightTime",4)
				pod1:SetKeyValue("Damage",75)
				pod1:SetKeyValue("DamageRadius",300)
				pod1:SetKeyValue("SmokeLifetime",10)
				pod1:SetKeyValue("StartingHeight",1500)
				pod1:SetKeyValue("spawnflags",8192)
				pod1:Spawn()
				pod1:Input("FireCanister",ply,ply)
				explosion1=ents.Create("env_explosion")
				explosion1:SetOwner(pod1)
				explosion1:SetPos(aBasePos)
				explosion1:SetKeyValue("iMagnitude", "10")
				explosion1:Spawn()
				explosion1:Activate()
				explosion1:Fire("Explode","",Delay)
				timer.Simple(Delay,function()
					if(IsValid(pod1))then
						util.ScreenShake(aBasePos,5000,99,5,500)
					end
				end)
				timer.Simple(Delay,function()
					if(IsValid(pod1))then
						ThrowShit(pod1,aBasePos,tr.MatType)
					end
				end)
			else
				CanistersCouldntLaunch=CanistersCouldntLaunch+1
			end
			YawIncrement=20
			PitchIncrement=10
			timer.Simple(0.2,function()
				local aBaseAngle=tr.HitNormal:Angle()
				local aBasePos=PodPositionTwo
				local bScanning=true
				local iPitch=10
				local iYaw=-180
				local iLoopLimit=0
				local iProcessedTotal=0
				local tValidHits={}
				while((bScanning==true)and(iLoopLimit<500))do
					iYaw=iYaw+YawIncrement
					iProcessedTotal=iProcessedTotal+1
					if(iYaw>=180)then
						iYaw=-180
						iPitch=iPitch-PitchIncrement
					end
					local tLoop=util.QuickTrace(aBasePos,(aBaseAngle+Angle(iPitch,iYaw,0)):Forward()*40000)
					if(tLoop.HitSky)then
						table.insert(tValidHits,tLoop)
					end
					if(iPitch<=-80)then
						bScanning=false
					end
					iLoopLimit=iLoopLimit+1
				end
				local iHits=table.Count(tValidHits)
				if(iHits>0)then
					local iRand=math.random(1,iHits)
					local tRand=tValidHits[iRand]
					pod2=ents.Create("env_headcrabcanister")
					pod2:SetPos(aBasePos)
					pod2:SetAngles((tRand.HitPos-tRand.StartPos):Angle())
					pod2:SetKeyValue("HeadcrabType",1)
					pod2:SetKeyValue("HeadcrabCount",20)
					pod2:SetKeyValue("FlightSpeed",7500)
					pod2:SetKeyValue("FlightTime",4)
					pod2:SetKeyValue("Damage",75)
					pod2:SetKeyValue("DamageRadius",300)
					pod2:SetKeyValue("SmokeLifetime",10)
					pod2:SetKeyValue("StartingHeight",1500)
					pod2:SetKeyValue("spawnflags",8192)
					pod2:Spawn()
					pod2:Input("FireCanister",ply,ply)
					explosion2=ents.Create("env_explosion")
					explosion2:SetOwner(pod2)
					explosion2:SetPos(aBasePos)
					explosion2:SetKeyValue("iMagnitude", "10")
					explosion2:Spawn()
					explosion2:Activate()
					explosion2:Fire("Explode","",Delay)
					timer.Simple(Delay,function()
						if(IsValid(pod2))then
							ThrowShit(pod1,aBasePos,tr.MatType)
						end
					end)
				else
					CanistersCouldntLaunch=CanistersCouldntLaunch+1
				end
			end)
			YawIncrement=20
			PitchIncrement=10
			timer.Simple(0.4,function()
				local aBaseAngle=tr.HitNormal:Angle()
				local aBasePos=PodPositionThree
				local bScanning=true
				local iPitch=10
				local iYaw=-180
				local iLoopLimit=0
				local iProcessedTotal=0
				local tValidHits={}
				while((bScanning==true)and(iLoopLimit<500))do
					iYaw=iYaw+YawIncrement
					iProcessedTotal=iProcessedTotal+1
					if(iYaw>=180)then
						iYaw=-180
						iPitch=iPitch-PitchIncrement
					end
					local tLoop=util.QuickTrace(aBasePos,(aBaseAngle+Angle(iPitch,iYaw,0)):Forward()*40000)
					if(tLoop.HitSky)then
						table.insert(tValidHits,tLoop)
					end
					if(iPitch<=-80)then
						bScanning=false
					end
					iLoopLimit=iLoopLimit+1
				end
				local iHits=table.Count(tValidHits)
				if(iHits>0)then
					local iRand=math.random(1,iHits)
					local tRand=tValidHits[iRand]
					pod3=ents.Create("env_headcrabcanister")
					pod3:SetPos(aBasePos)
					pod3:SetAngles((tRand.HitPos-tRand.StartPos):Angle())
					pod3:SetKeyValue("HeadcrabType",0)
					pod3:SetKeyValue("HeadcrabCount",30)
					pod3:SetKeyValue("FlightSpeed",7500)
					pod3:SetKeyValue("FlightTime",4)
					pod3:SetKeyValue("Damage",75)
					pod3:SetKeyValue("DamageRadius",300)
					pod3:SetKeyValue("SmokeLifetime",10)
					pod3:SetKeyValue("StartingHeight",1500)
					pod3:SetKeyValue("spawnflags",8192)
					pod3:Spawn()
					pod3:Input("FireCanister",ply,ply)
					explosion3=ents.Create("env_explosion")
					explosion3:SetOwner(pod3)
					explosion3:SetPos(aBasePos)
					explosion3:SetKeyValue("iMagnitude", "10")
					explosion3:Spawn()
					explosion3:Activate()
					explosion3:Fire("Explode","",Delay)
					timer.Simple(Delay,function()
						if(IsValid(pod3))then
							ThrowShit(pod1,aBasePos,tr.MatType)
						end
					end)
				else
					CanistersCouldntLaunch=CanistersCouldntLaunch+1
				end
			end)
			timer.Simple(0.6,function()
				if(CanistersCouldntLaunch>0)then
					local plural="canister"
					if(CanistersCouldntLaunch>1)then
						plural="canisters"
					end
					ply:PrintMessage(HUD_PRINTCENTER,CanistersCouldntLaunch.." "..plural.." couldn't be launched.")
				end
			end)
		end
		timer.Simple(0.8,function()
			undo.Create("Headcrab Pods")
				undo.SetPlayer(ply)
				if(IsValid(pod1))then undo.AddEntity(pod1) end
				if(IsValid(pod2))then undo.AddEntity(pod2) end
				if(IsValid(pod3))then undo.AddEntity(pod3) end
				if(IsValid(explosion1))then undo.AddEntity(explosion1) end
				if(IsValid(explosion2))then undo.AddEntity(explosion2) end
				if(IsValid(explosion3))then undo.AddEntity(explosion3) end
				undo.AddFunction(function(undo)
					for key,found in pairs(ents.FindByClass("npc_headcrab_poison"))do
						if(found:GetOwner()==pod1)then SafeRemoveEntity(found) end
					end
					for key,found in pairs(ents.FindByClass("npc_headcrab_fast"))do
						if(found:GetOwner()==pod2)then SafeRemoveEntity(found) end
					end
					for key,found in pairs(ents.FindByClass("npc_headcrab"))do
						if(found:GetOwner()==pod3)then SafeRemoveEntity(found) end
					end
				end)
				undo.SetCustomUndoText("Undone Headcrab Pods")
			undo.Finish()
		end)
	end
	JackieNPCSpawningTable.Enhanced["Headcrab Canister"]=function(selfpos)
		local InitialPositionVector=selfpos
		local SurfaceNormalAngle=Vector(0,0,1):Angle()
		local Right=SurfaceNormalAngle:Right()
		local Up=SurfaceNormalAngle:Up()
		local PodPositionOne=InitialPositionVector
		util.PrecacheModel("models/headcrabclassic.mdl")
		util.PrecacheModel("models/headcrab.mdl")
		util.PrecacheModel("models/headcrabblack.mdl")
		util.PrecacheModel("models/props_combine/headcrabcannister01a.mdl")
		util.PrecacheModel("models/props_combine/headcrabcannister01b.mdl")
		local pod1
		local explosion1
		local explosion2
		local explosion3
		//valve, you lazy game developer you. I have to make an explosion myself to make the pods' impacts look realistic
		local YawIncrement=20
		local PitchIncrement=10
		if(SERVER)then
			local CanistersCouldntLaunch=0
			local aBaseAngle=Vector(0,0,1):Angle()
			local aBasePos=PodPositionOne
			local bScanning=true
			local iPitch=10
			local iYaw=-180
			local iLoopLimit=0
			local iProcessedTotal=0
			local tValidHits={}
			while((bScanning==true)and(iLoopLimit<500))do
				iYaw=iYaw+YawIncrement
				iProcessedTotal=iProcessedTotal+1
				if(iYaw>=180)then
					iYaw=-180
					iPitch=iPitch-PitchIncrement
				end
				local tLoop=util.QuickTrace(aBasePos,(aBaseAngle+Angle(iPitch,iYaw,0)):Forward()*40000)
				if(tLoop.HitSky)then
					table.insert(tValidHits,tLoop)
				end
				if(iPitch<=-80)then
					bScanning=false
				end
				iLoopLimit=iLoopLimit+1
			end
			local iHits=table.Count(tValidHits)
			if(iHits>0)then
				local iRand=math.random(1,iHits)
				local tRand=tValidHits[iRand]
				pod1=ents.Create("env_headcrabcanister")
				pod1:SetPos(aBasePos)
				pod1:SetAngles((tRand.HitPos-tRand.StartPos):Angle())
				pod1:SetKeyValue("HeadcrabType",0)
				pod1:SetKeyValue("HeadcrabCount",100)
				pod1:SetKeyValue("FlightSpeed",7500)
				pod1:SetKeyValue("FlightTime",4)
				pod1:SetKeyValue("Damage",75)
				pod1:SetKeyValue("DamageRadius",300)
				pod1:SetKeyValue("SmokeLifetime",10)
				pod1:SetKeyValue("StartingHeight",1500)
				pod1:SetKeyValue("spawnflags",8192)
				pod1:Spawn()
				pod1:Input("FireCanister",ply,ply)
				explosion1=ents.Create("env_explosion")
				explosion1:SetOwner(pod1)
				explosion1:SetPos(aBasePos)
				explosion1:SetKeyValue("iMagnitude", "10")
				explosion1:Spawn()
				explosion1:Activate()
				explosion1:Fire("Explode","",Delay)
				timer.Simple(Delay,function()
					if(IsValid(pod1))then
						util.ScreenShake(aBasePos,5000,99,5,500)
					end
				end)
				timer.Simple(Delay,function()
					if(IsValid(pod1))then
						ThrowShit(pod1,aBasePos,MAT_DIRT)
					end
				end)
			else
				CanistersCouldntLaunch=CanistersCouldntLaunch+1
			end
		end
		return pod1
	end
end