JMod.NaturalResourceTable=JMod.NaturalResourceTable or {}
if(SERVER)then
	local function RemoveOverlaps(tbl)
		local Finished,Tries=false,0
		while not(Finished)do
			local Removed=false
			for k,v in pairs(tbl)do
				for l,w in pairs(tbl)do
					if(l~=k and v.typ==w.typ)then
						local Dist,Min=v.pos:Distance(w.pos),v.siz+w.siz
						if(Dist<Min)then
							table.remove(tbl,k)
							Removed=true
							break
						end
					end
				end
				if(Removed)then break end
			end
			if not(Removed)then Finished=true end
			Tries=Tries+1
			if(Tries>1000)then return end
		end
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
		for k,v in pairs(tbl)do
			if(string.find(v,str))then return true end
		end
		return false
	end
	function JMod.GenerateNaturalResources(tryFlat)
		JMod.NaturalResourceTable={}
		-- first, we have to find the ground
		local GroundVectors={}
		print("JMOD: generating natural resources...")
		for i=1,MaxTries do
			timer.Simple(i/1000,function()
				local CheckPos=Vector(math.random(-20000,20000),math.random(-20000,20000),math.random(-20000,5000))
				if(tryFlat)then CheckPos.z=math.random(-500,500) end
				if(util.IsInWorld(CheckPos))then
					-- we're in the world... start the worldhit trace
					local Tr=util.QuickTrace(CheckPos,Vector(0,0,-1000))
					local Props=util.GetSurfaceData(Tr.SurfaceProps)
					local MatName=string.lower((Props and Props.name) or "")
					local HitTexture=string.lower(Tr.HitTexture)
					if(Tr.Hit and Tr.HitWorld and not Tr.StartSolid and not Tr.HitSky and table.HasValue(NatureMats,Tr.MatType) and not TabContainsSubString(SurfacePropBlacklist,MatName) and not TabContainsSubString(SurfacePropBlacklist,HitTexture))then
						-- alright... we've found a good world surface
						table.insert(GroundVectors,{
							pos=Tr.HitPos,
							mat=Tr.MatType,
							rock=TabContainsSubString(RockNames,MatName),
							water=bit.band(util.PointContents(Tr.HitPos+Vector(0,0,1)),CONTENTS_WATER)==CONTENTS_WATER
						})
					end
				end
				if(i==MaxTries)then
					local ResourceInfo={
						[JMod.EZ_RESOURCE_TYPES.WATER]={
							frequency=15,
							avgrate=1,
							avgsize=400,
							limits={nowater=true},
							boosts={sand=2}
						},
						[JMod.EZ_RESOURCE_TYPES.OIL]={
							frequency=10,
							avgamt=1000,
							avgsize=300,
							boosts={water=2},
							limits={}
						},
						[JMod.EZ_RESOURCE_TYPES.COAL]={
							frequency=10,
							avgamt=1000,
							avgsize=200,
							limits={nowater=true},
							boosts={rock=2}
						},
						[JMod.EZ_RESOURCE_TYPES.IRONORE]={
							frequency=10,
							avgamt=1000,
							avgsize=200,
							limits={nowater=true},
							boosts={rock=2}
						},
						[JMod.EZ_RESOURCE_TYPES.LEADORE]={
							frequency=10,
							avgamt=1000,
							avgsize=200,
							limits={nowater=true},
							boosts={rock=2}
						},
						[JMod.EZ_RESOURCE_TYPES.ALUMINUMORE]={
							frequency=12,
							avgamt=1000,
							avgsize=200,
							limits={nowater=true},
							boosts={rock=2}
						},
						[JMod.EZ_RESOURCE_TYPES.COPPERORE]={
							frequency=7,
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
							frequency=2,
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
							frequency=.1,
							avgamt=300,
							avgsize=100,
							limits={}, -- covered by the limits of coal already
							boosts={}
						},
						["geothermal"]={
							frequency=3,
							avgrate=1,
							avgsize=100,
							limits={nowater=true},
							boosts={snow=2}
						}
					}
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
								local Amt,Decimals=(ChosenInfo.avgrate or ChosenInfo.avgamt)*math.Rand(.5,1.5),1
								if(ChosenInfo.avgrate)then Decimals=3 end
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
											pos=resourceData.pos,
											siz=math.Round(info.avgsize*math.Rand(.5,1.5)),
											Amt=Amt
										})
									end
								end
							end
						end
					end
					if((#Resources<=2)and not(tryFlat))then
						-- if we couldn't find anything, it might be an RP map which is really flat
						JMod.GenerateNaturalResources(true)
					else
						RemoveOverlaps(Resources)
						JMod.NaturalResourceTable=Resources
						print("JMOD: resource generation finished with "..#Resources.." resource deposits")
						
					end
				elseif(i%1000==0)then
					print(math.Round(i/MaxTries*100).."%")
				end
			end)
		end
	end
	hook.Add("InitPostEntity","JMod_InitPostEntityServer",function()
		JMod.GenerateNaturalResources()
	end)
	concommand.Add("jmod_debug_shownaturalresources",function(ply,cmd,args)
		if not(GetConVar("sv_cheats"):GetBool())then return end
		if((IsValid(ply))and not(ply:IsSuperAdmin()))then return end
		net.Start("JMod_NaturalResources")
		net.WriteTable(JMod.OilReserves)
		net.WriteTable(JMod.OreDeposits)
		net.WriteTable(JMod.GeoThermalReservoirs)
		net.WriteTable(JMod.WaterReservoirs)
		net.Send(ply)
	end)
elseif(CLIENT)then
	local ShowNaturalResources=false
	net.Receive("JMod_NaturalResources",function()
		ShowNaturalResources=not ShowNaturalResources
		print("natural resource display: "..tostring(ShowNaturalResources))
		JMod.OilReserves=net.ReadTable()
		JMod.OreDeposits=net.ReadTable()
		JMod.GeoThermalReservoirs=net.ReadTable()
		JMod.WaterReservoirs=net.ReadTable()
	end)
	local Circle=Material("sprites/sent_ball")
	local function RenderPoints(tbl,col)
		for k,v in pairs(tbl)do
			cam.Start3D2D(v.pos+Vector(0,0,50),Angle(0,0,0),10)
			surface.SetDrawColor(col.r,col.g,col.b,col.a)
			surface.SetMaterial(Circle)
			surface.DrawTexturedRect(-v.siz/10,-v.siz/10,v.siz*2/10,v.siz*2/10)
			draw.DrawText(v.amt,"DermaLarge",0,0,color_white,TEXT_ALIGN_CENTER)
			cam.End3D2D()
		end
	end
	hook.Add("PostDrawTranslucentRenderables","JMod_EconTransRend",function()
		if(ShowNaturalResources)then
			RenderPoints(JMod.OilReserves,Color(10,10,10,200))
			RenderPoints(JMod.OreDeposits,Color(120,120,120,200))
			RenderPoints(JMod.GeoThermalReservoirs,Color(150,20,10,200))
			RenderPoints(JMod.WaterReservoirs,Color(20,70,150,200))
		end
	end)
end