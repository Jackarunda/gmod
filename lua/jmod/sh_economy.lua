JMod.NaturalResourceTable=JMod.NaturalResourceTable or {}
local ResourceInfo={
	[JMod.EZ_RESOURCE_TYPES.WATER]={
		frequency=12,
		avgrate=1,
		avgsize=400,
		limits={nowater=true},
		boosts={sand=2}
	},
	[JMod.EZ_RESOURCE_TYPES.OIL]={
		frequency=8,
		avgamt=1000,
		avgsize=300,
		boosts={water=2},
		limits={}
	},
	[JMod.EZ_RESOURCE_TYPES.COAL]={
		frequency=8,
		avgamt=1000,
		avgsize=200,
		limits={nowater=true},
		boosts={rock=2}
	},
	[JMod.EZ_RESOURCE_TYPES.IRONORE]={
		frequency=8,
		avgamt=1000,
		avgsize=200,
		limits={nowater=true},
		boosts={rock=2}
	},
	[JMod.EZ_RESOURCE_TYPES.LEADORE]={
		frequency=8,
		avgamt=1000,
		avgsize=200,
		limits={nowater=true},
		boosts={rock=2}
	},
	[JMod.EZ_RESOURCE_TYPES.ALUMINUMORE]={
		frequency=10,
		avgamt=1000,
		avgsize=200,
		limits={nowater=true},
		boosts={rock=2}
	},
	[JMod.EZ_RESOURCE_TYPES.COPPERORE]={
		frequency=6,
		avgamt=1000,
		avgsize=200,
		limits={nowater=true},
		boosts={rock=2}
	},
	[JMod.EZ_RESOURCE_TYPES.TUNGSTENORE]={
		frequency=5,
		avgamt=1000,
		avgsize=100,
		limits={nowater=true},
		boosts={rock=2}
	},
	[JMod.EZ_RESOURCE_TYPES.TITANIUMORE]={
		frequency=5,
		avgamt=1000,
		avgsize=100,
		limits={nowater=true},
		boosts={rock=2}
	},
	[JMod.EZ_RESOURCE_TYPES.SILVERORE]={
		frequency=3,
		avgamt=1000,
		avgsize=100,
		limits={nowater=true},
		boosts={rock=2}
	},
	[JMod.EZ_RESOURCE_TYPES.GOLDORE]={
		frequency=1,
		avgamt=1000,
		avgsize=100,
		limits={nowater=true},
		boosts={rock=2}
	},
	[JMod.EZ_RESOURCE_TYPES.URANIUMORE]={
		frequency=3,
		avgamt=1000,
		avgsize=100,
		limits={nowater=true},
		boosts={rock=2}
	},
	[JMod.EZ_RESOURCE_TYPES.PLATINUMORE]={
		frequency=1,
		avgamt=1000,
		avgsize=100,
		limits={nowater=true},
		boosts={rock=2}
	},
	[JMod.EZ_RESOURCE_TYPES.DIAMOND]={
		dependency=JMod.EZ_RESOURCE_TYPES.COAL,
		frequency=.2,
		avgamt=300,
		avgsize=100,
		limits={}, -- covered by the limits of coal already
		boosts={}
	},
	["geothermal"]={
		frequency=2,
		avgrate=1,
		avgsize=100,
		limits={nowater=true},
		boosts={snow=2}
	}
}
if(SERVER)then
	local function RemoveOverlaps(tbl)
		local Finished,Tries,RemovedCount=false,0,0
		while not(Finished)do
			local Removed=false
			for k,v in pairs(tbl)do
				for l,w in pairs(tbl)do
					if(l~=k)then
						local Info=ResourceInfo[v.typ]
						if not(Info.dependency)then -- dependent resources are meant to overlap
							local Dist,Min=v.pos:Distance(w.pos),v.siz+w.siz
							if(Dist<Min)then
								table.remove(tbl,k)
								RemovedCount=RemovedCount+1
								Removed=true
								break
							end
						end
					end
				end
				if(Removed)then break end
			end
			if not(Removed)then Finished=true end
			Tries=Tries+1
			if(Tries>10000)then return end
		end
		print("JMOD: removed "..RemovedCount.." overlapping resource deposits")
	end
	--[[
	local function WeightByAltitude(tbl,low,deweightOthers)
		local AvgAltitude,Count=0,0
		for k,v in pairs(tbl)do
			AvgAltitude=AvgAltitude+v.pos.z
			Count=Count+1
		end
		AvgAltitude=AvgAltitude/Count
		for k,v in pairs(tbl)do
			if(low)then
				if(v.pos.z<AvgAltitude)then v.amt=v.amt*2 end
			else
				if(v.pos.z>AvgAltitude)then v.amt=v.amt*2 end
			end
			if(deweightOthers)then
				if(low)then
					if(v.pos.z>AvgAltitude)then v.amt=v.amt/2 end
				else
					if(v.pos.z<AvgAltitude)then v.amt=v.amt/2 end
				end
			end
		end
	end
	--]]
	local NatureMats,MaxTries,SurfacePropBlacklist,RockNames={MAT_SNOW,MAT_SAND,MAT_FOLIAGE,MAT_SLOSH,MAT_GRASS,MAT_DIRT},10000,{"paper","plaster","rubber","carpet"},{"rock","boulder"}
	local function TabContainsSubString(tbl,str)
		if not(str)then return false end
		for k,v in pairs(tbl)do
			if(string.find(v,str))then return true end
		end
		return false
	end
	local function IsSurfaceSuitable(tr,props,mat,tex)
		if not(tr.Hit and tr.HitWorld and not tr.StartSolid and not tr.HitSky)then return false end
		if not(table.HasValue(NatureMats,tr.MatType))then return false end
		if(TabContainsSubString(SurfacePropBlacklist,mat))then return false end
		if(TabContainsSubString(SurfacePropBlacklist,HitTexture))then return false end
		return true
	end
	local function DetermineMapBounds(endFunc)
		print("JMOD: measuring map bounds...")
		local xMin,xMax,yMin,yMax,zMin,zMax,SkyCamPos,SkyCamElims=9e9,-9e9,9e9,-9e9,9e9,-9e9,nil,0
		for k,v in pairs(ents.FindByClass("sky_camera"))do
			SkyCamPos=v:GetPos() -- only if this is found
			print("JMOD: skybox camera located at:",SkyCamPos)
		end
		for i=1,10000 do
			timer.Simple(i/1000,function()
				local Pos=Vector(math.random(-20000,20000),math.random(-20000,20000),math.random(-20000,20000))
				if(util.IsInWorld(Pos))then
					local IsInSkyBox=false
					if(SkyCamPos)then
						local Tr=util.TraceLine({start=SkyCamPos+Vector(0,0,1000),endpos=Pos+Vector(0,0,100)})
						if not(Tr.Hit)then IsInSkyBox=true end
					end
					if not(IsInSkyBox)then
						xMin=math.min(xMin,Pos.x)
						xMax=math.max(xMax,Pos.x)
						yMin=math.min(yMin,Pos.y)
						yMax=math.max(yMax,Pos.y)
						zMin=math.min(zMin,Pos.z)
						zMax=math.max(zMax,Pos.z)
					else
						SkyCamElims=SkyCamElims+1
					end
				end
				if(i==10000)then
					print("JMOD: "..SkyCamElims.." detection positions eliminated due to being in the skybox")
					print("JMOD: map bounds determined to be:",xMin,xMax,yMin,yMax,zMin,zMax)
					endFunc(xMin,xMax,yMin,yMax,zMin,zMax)
				elseif(i%1000==0)then
					print(math.Round(i/10000*100).."%")
				end
			end)
		end
	end
	function JMod.GenerateNaturalResources()
		JMod.NaturalResourceTable={}
		-- first, we have to find the ground
		DetermineMapBounds(function(xMin,xMax,yMin,yMax,zMin,zMax)
			local GroundVectors={}
			print("JMOD: generating natural resources...")
			for i=1,MaxTries do
				timer.Simple(i/1000,function()
					local CheckPos=Vector(math.random(xMin,xMax),math.random(yMin,yMax),math.random(zMin,zMax))
					-- we're in the world... start the worldhit trace
					local Tr=util.QuickTrace(CheckPos,Vector(0,0,-1000))
					local Props=util.GetSurfaceData(Tr.SurfaceProps)
					local MatName=string.lower((Props and Props.name) or "")
					local HitTexture=string.lower(Tr.HitTexture)
					if(IsSurfaceSuitable(Tr,Props,MatName,HitTexture))then
						-- alright... we've found a good world surface
						table.insert(GroundVectors,{
							pos=Tr.HitPos,
							mat=Tr.MatType,
							rock=TabContainsSubString(RockNames,MatName),
							water=bit.band(util.PointContents(Tr.HitPos+Vector(0,0,1)),CONTENTS_WATER)==CONTENTS_WATER
						})
					end
					if(i==MaxTries)then
						local Frequencies={}
						for k,v in pairs(ResourceInfo)do
							for i=1,v.frequency do table.insert(Frequencies,k) end
						end
						local Resources={}
						for k,PosInfo in pairs(GroundVectors)do
							local ChosenType=table.Random(Frequencies)
							local ChosenInfo=ResourceInfo[ChosenType]
							if not(ChosenInfo.dependency)then -- we'll handle these afterward
								if not(PosInfo.water and ChosenInfo.limits.nowater)then
									local Amt,Decimals=(ChosenInfo.avgrate or ChosenInfo.avgamt)*math.Rand(.5,1.5),0
									if(ChosenInfo.avgrate)then Decimals=2 end
									if(PosInfo.water and ChosenInfo.boosts.water)then Amt=Amt*math.Rand(2,4) end
									if(PosInfo.rock and ChosenInfo.boosts.rock)then Amt=Amt*math.Rand(2,4) end
									if(PosInfo.sand and PosInfo.mat==MAT_SAND)then Amt=Amt*math.Rand(2,4) end
									if(PosInfo.snow and PosInfo.mat==MAT_SNOW)then Amt=Amt*math.Rand(2,4) end
									-- randomly boost the amt in order to create the potential for conflict ( ͡° ͜ʖ ͡°)
									if(math.random(1,5)==4)then Amt=Amt*math.Rand(1,5) end
									Amt=math.Round(Amt,Decimals)
									table.insert(Resources,{
										typ=ChosenType,
										pos=PosInfo.pos,
										siz=math.Round(ChosenInfo.avgsize*math.Rand(.5,1.5)),
										amt=Amt
									})
								end
							end
						end
						-- now let's handle dependent resources
						local ResourcesToAdd={}
						for name,info in pairs(ResourceInfo)do
							if(info.dependency)then
								for k,resourceData in pairs(Resources)do
									if(resourceData.typ==info.dependency)then
										if(math.Rand(0,1)<info.frequency)then
											local Amt=info.avgamt*math.Rand(.5,1.5)
											if(math.random(1,5)==4)then Amt=Amt*math.Rand(1,5) end
											Amt=math.Round(Amt)
											table.insert(ResourcesToAdd,{
												typ=name,
												pos=resourceData.pos+Vector(math.random(-100,100),math.random(-100,100),0),
												siz=math.Round(info.avgsize*math.Rand(.5,1.5)),
												Amt=Amt
											})
										end
									end
								end
							end
						end
						RemoveOverlaps(Resources)
						JMod.NaturalResourceTable=Resources
						print("JMOD: resource generation finished with "..#Resources.." resource deposits")
					elseif(i%1000==0)then
						print(math.Round(i/MaxTries*100).."%")
					end
				end)
			end
		end)
	end
	hook.Add("InitPostEntity","JMod_InitPostEntityServer",function()
		JMod.GenerateNaturalResources()
	end)
	concommand.Add("jmod_debug_shownaturalresources",function(ply,cmd,args)
		if not(GetConVar("sv_cheats"):GetBool())then return end
		if((IsValid(ply))and not(ply:IsSuperAdmin()))then return end
		net.Start("JMod_NaturalResources")
		net.WriteTable(JMod.NaturalResourceTable)
		net.Send(ply)
	end)
elseif(CLIENT)then
	local ShowNaturalResources=false
	net.Receive("JMod_NaturalResources",function()
		ShowNaturalResources=not ShowNaturalResources
		print("natural resource display: "..tostring(ShowNaturalResources))
		JMod.NaturalResourceTable=net.ReadTable()
	end)
	hook.Add("PostDrawTranslucentRenderables","JMod_EconTransRend",function()
		if(ShowNaturalResources)then
			for k,v in pairs(JMod.NaturalResourceTable)do
				JMod.HoloGraphicDisplay(nil,v.pos,Angle(0,0,0),1,30000,function()
					JMod.StandardResourceDisplay(v.typ,v.amt,nil,0,0,v.siz*2,true)
				end)
			end
		end
	end)
end