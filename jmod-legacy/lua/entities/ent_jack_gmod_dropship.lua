AddCSLuaFile()
ENT.Type 			= "anim"
ENT.PrintName		= "Combine Dropship"
ENT.Author			= "Jackarunda"
ENT.Information		= "This Combine dropship will fly all around the map, dropping rollermines on everything."
ENT.Category		= "JMod - LEGACY NPCs"

ENT.Spawnable		= true
ENT.AdminSpawnable	= true
if(SERVER)then
	function ENT:SpawnFunction(ply, tr)

		--if(!tr.Hit)then return end
		
		local selfpos=tr.HitPos+tr.HitNormal*16
		
		local Friendly=false
		
		local MyNodeBuffer={}
		local Nodes=50
		local CheckPosition=selfpos+Vector(0,0,300)
		local CheckEntity=nil
		for i=1,50 do
			local ent=ents.Create("path_track")
			if(math.random(1,7)==1)then
				ent:SetPos(Vector(math.Rand(-15000,15000),math.Rand(-15000,15000),math.Rand(selfpos.z+3000,selfpos.z+15000)))
			else
				ent:SetPos(Vector(math.Rand(-15000,15000),math.Rand(-15000,15000),math.Rand(selfpos.z+750,selfpos.z+3000)))
			end
			ent:Spawn()
			local CheckTraceData={}
			CheckTraceData.start=ent:GetPos()
			CheckTraceData.endpos=CheckPosition
			CheckTraceData.filter={ent,CheckEntity}
			local CheckTrace=util.TraceLine(CheckTraceData)
			if not(CheckTrace.Hit)then 
				table.insert(MyNodeBuffer,ent)
				CheckPosition=ent:GetPos()
				CheckEntity=ent
			else
				ent:Remove()
				Nodes=Nodes-1
			end
		end
		
		local npc=ents.Create("npc_combinedropship")
		npc:SetPos(selfpos+Vector(0,0,300))
		npc:SetAngles(Angle(0,-90,0))
		npc:SetKeyValue("cratetype","1")
		npc:SetKeyValue("invulnerable","0")
		npc:Spawn();npc:SetKeyValue("SquadName","JackyCombineOpSquad");npc.InAJackyCombineSquad=true
		npc:Activate()
		npc.HasAJackyAllegiance=true
		npc.OpSquadBlastDamageTaker=true
		npc.JackyOpSquadNPC=true
		if(Friendly)then
			npc.JackyAllegiance="Human"
		else
			npc.JackyAllegiance="Combine"
		end
		npc:SetKeyValue("SquadName",npc.JackyAllegiance)
		npc.Damage=0
		npc.Sploding=false
		npc.NeedsMoarFirePower=true
		npc.OPSQUADWillDropCombineTech=true
		npc.OPSQUADMineDroppinMotherFucker=true
		npc:Fire("setgunrange","99999")
		timer.Create("OPSQUADMineDroppinMotherFucker"..npc:EntIndex(),12.5,40,function()
			if not(IsValid(npc))then timer.Destroy("OPSQUADMineDroppinMotherFucker"..npc:EntIndex()) return end
			npc:Fire("dropmines","3",0)
		end)
		
		local effectdata=EffectData()
		effectdata:SetEntity(npc)
		--util.Effect("propspawn",effectdata)
		
		for var=1, Nodes,1  do
			MyNodeBuffer[var]:SetName(tostring(npc) .. tostring(var))
			npc:DeleteOnRemove(MyNodeBuffer[var])
		end
		for var=1, Nodes,1  do
			if(var != Nodes)then
				MyNodeBuffer[var]:Fire("addoutput","OnPass !activator,SetTrack," ..  tostring(npc) .. tostring((var+1)),1)
			else
				MyNodeBuffer[var]:Fire("addoutput","OnPass !activator,SetTrack," ..  tostring(npc) .. "1",1)
			end
		end
		
		local TrackName=tostring(npc) .. "1"
		npc:Fire("SetTrack",TrackName,0.1)
		
		timer.Simple(.1,function()
			for k,ent in pairs(ents.FindInSphere(selfpos+Vector(0,0,300),300))do
				if(ent:GetClass()=="prop_dropship_container")then ent.OpSquadCustomDamageTaker=true end
			end
		end)

		undo.Create("JackyCombineDropship")
			undo.AddEntity(npc)
			undo.SetPlayer(ply)
			undo.SetCustomUndoText("Undone Combine Dropship")
		undo.Finish()

	end
end