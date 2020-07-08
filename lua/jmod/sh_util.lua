local ANGLE=FindMetaTable("Angle")
function ANGLE:GetCopy()
	return Angle(self.p,self.y,self.r)
end
function table.FullCopy(tab)
	if(!tab)then return nil end
	local res={}
	for k, v in pairs(tab) do
		if(type(v)=="table")then
			res[k]=table.FullCopy(v) -- we need to go derper
		elseif(type(v)=="Vector")then
			res[k]=Vector(v.x, v.y, v.z)
		elseif(type(v)=="Angle")then
			res[k]=Angle(v.p, v.y, v.r)
		else
			res[k]=v
		end
	end
	return res
end
function jprint(...)
	local items,printstr={...},""
	for k,v in pairs(items)do
		-- todo: tables
		printstr=printstr..tostring(v)..", "
	end
	print(printstr)
	if(SERVER)then
		player.GetAll()[1]:PrintMessage(HUD_PRINTTALK,printstr)
		player.GetAll()[1]:PrintMessage(HUD_PRINTCENTER,printstr)
	elseif(CLIENT)then
		LocalPlayer():ChatPrint(printstr)
	end
end
function JMod_GoodBadColor(frac)
	-- color tech from bfs2114
	local r,g,b=math.Clamp(3-frac*4,0,1),math.Clamp(frac*2,0,1),math.Clamp(-3+frac*4,0,1)
	return r*255,g*255,b*255
end
function JMOD_WhomILookinAt(ply,cone,dist)
	local CreatureTr,ObjTr,OtherTr=nil,nil,nil
	for i=1,(150*cone) do
		local Vec=(ply:GetAimVector()+VectorRand()*cone):GetNormalized()
		local Tr=util.QuickTrace(ply:GetShootPos(),Vec*dist,{ply})
		if((Tr.Hit)and not(Tr.HitSky)and(Tr.Entity))then
			local Ent,Class=Tr.Entity,Tr.Entity:GetClass()
			if((Ent:IsPlayer())or(Ent:IsNPC()))then
				CreatureTr=Tr
			elseif((Class=="prop_physics")or(Class=="prop_physics_multiplayer")or(Class=="prop_ragdoll"))then
				ObjTr=Tr
			else
				OtherTr=Tr
			end
		end
	end
	if(CreatureTr)then return CreatureTr.Entity,CreatureTr.HitPos,CreatureTr.HitNormal end
	if(ObjTr)then return ObjTr.Entity,ObjTr.HitPos,ObjTr.HitNormal end
	if(OtherTr)then return OtherTr.Entity,OtherTr.HitPos,OtherTr.HitNormal end
	return nil,nil,nil
end
--
function JMod_IsDoor(ent)
	local Class=ent:GetClass()
	return ((Class=="prop_door")or(Class=="prop_door_rotating")or(Class=="func_door")or(Class=="func_door_rotating"))
end
function JMod_VisCheck(pos,targPos,sourceEnt)
	local filter={}
	pos=(sourceEnt and sourceEnt:LocalToWorld(sourceEnt:OBBCenter())) or pos
	if(sourceEnt)then table.insert(filter,sourceEnt) end
	if(targPos and targPos.GetPos)then
		if(targPos:GetNoDraw())then return false end
		table.insert(filter,targPos)
		targPos=targPos:LocalToWorld(targPos:OBBCenter())
	end
	return not util.TraceLine({
		start=pos,
		endpos=targPos,
		filter=filter,
		mask=MASK_SOLID_BRUSHONLY
	}).Hit
end
function JMod_CountResourcesInRange(pos,range,sourceEnt)
	pos=(sourceEnt and sourceEnt:LocalToWorld(sourceEnt:OBBCenter())) or pos
	local Results={}
	for k,obj in pairs(ents.FindInSphere(pos,range or 150))do
		if((obj.IsJackyEZresource)and(JMod_VisCheck(pos,obj,sourceEnt)))then
			local Typ=obj.EZsupplies
			Results[Typ]=(Results[Typ] or 0)+obj:GetResource()
		elseif obj:GetClass() == "ent_jack_gmod_ezcrate" and JMod_VisCheck(pos,obj,sourceEnt) then
			local Typ = obj:GetResourceType()
			Results[Typ]=(Results[Typ] or 0)+obj:GetResource()
		end
	end
	return Results
end
function JMod_HaveResourcesToPerformTask(pos,range,requirements,sourceEnt)
	local RequirementsMet,ResourcesInRange=true,JMod_CountResourcesInRange(pos,range,sourceEnt)
	for typ,amt in pairs(requirements)do
		if(not((ResourcesInRange[typ])and(ResourcesInRange[typ]>=amt)))then
			RequirementsMet=false
			break
		end
	end
	return RequirementsMet
end
function JMod_ConsumeResourcesInRange(requirements,pos,range,sourceEnt)
	pos=(sourceEnt and sourceEnt:LocalToWorld(sourceEnt:OBBCenter())) or pos
	local AllDone,Attempts,RequirementsRemaining=false,0,table.FullCopy(requirements)
	while not((AllDone)or(Attempts>1000))do
		local TypesNeeded=table.GetKeys(RequirementsRemaining)
		if((TypesNeeded)and(#TypesNeeded>0))then
			local ResourceTypeToLookFor=TypesNeeded[1]
			local AmountWeNeed=RequirementsRemaining[ResourceTypeToLookFor]
			local Donor=JMod_FindResourceContainer(ResourceTypeToLookFor,1,pos,range,sourceEnt) -- every little bit helps
			if(Donor)then
				local AmountWeCanTake=Donor:GetResource()
				if(AmountWeNeed>=AmountWeCanTake)then
					Donor:SetResource(0)
					if(Donor:GetClass()=="ent_jack_gmod_ezcrate")then
						Donor:ApplySupplyType("generic")
					else
						Donor:Remove()
					end
					RequirementsRemaining[ResourceTypeToLookFor]=RequirementsRemaining[ResourceTypeToLookFor]-AmountWeCanTake
				else
					Donor:SetResource(AmountWeCanTake-AmountWeNeed)
					RequirementsRemaining[ResourceTypeToLookFor]=RequirementsRemaining[ResourceTypeToLookFor]-AmountWeNeed
				end
				if(RequirementsRemaining[ResourceTypeToLookFor]<=0)then RequirementsRemaining[ResourceTypeToLookFor]=nil end
			end
		else
			AllDone=true
		end
		Attempts=Attempts+1
	end
end
function JMod_FindResourceContainer(typ,amt,pos,range,sourceEnt)
	pos=(sourceEnt and sourceEnt:LocalToWorld(sourceEnt:OBBCenter())) or pos
	for k,obj in pairs(ents.FindInSphere(pos,range or 150))do
		if(obj.IsJackyEZresource or obj:GetClass() == "ent_jack_gmod_ezcrate")then
			if((obj.EZsupplies==typ)and(obj:GetResource()>=amt)and(JMod_VisCheck(pos,obj,sourceEnt)))then
				return obj
			end
		end
	end
end