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