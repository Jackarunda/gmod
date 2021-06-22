JMod.OilReserves=JMod.OilReserves or {}
JMod.OreDeposits=JMod.OreDeposits or {}
JMod.GeoThermalReservoirs=JMod.GeoThermalReservoirs or {}
JMod.WaterReservoirs=JMod.WaterReservoirs or {}
if(SERVER)then
	local function RemoveOverlaps(tbl)
		local Finished,Tries=false,0
		while not(Finished)do
			local Removed=false
			for k,v in pairs(tbl)do
				for l,w in pairs(tbl)do
					if(l~=k)then
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
	local function PumpItUp(tbl,numPumps,minPump,maxPump)
		if(#tbl<=0)then return end
		if(numPumps<=0)then return end
		for i=1,numPumps do
			local Deposit,Decimals=table.Random(tbl),0
			if(Deposit.amt<1)then Decimals=5 end
			Deposit.amt=math.Round(Deposit.amt*math.Rand(minPump,maxPump),Decimals)
		end
	end
	local function WeightByAltitude(tbl,low)
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
		end
	end
	local NatureMats,MaxTries,SurfacePropBlacklist={MAT_SNOW,MAT_SAND,MAT_FOLIAGE,MAT_SLOSH,MAT_GRASS,MAT_DIRT},5000,{"paper","plaster","rubber"}
	function JMod.GenerateNaturalResources(tryFlat)
		JMod.OilReserves={}
		JMod.OreDeposits={}
		JMod.GeoThermalReservoirs={}
		JMod.WaterReservoirs={}
		-- first, we have to find the ground
		local GroundVectors={}
		print("JMOD: generating natural resources...")
		for i=1,MaxTries do
			timer.Simple(i/1000,function()
				local CheckPos=Vector(math.random(-20000,20000),math.random(-20000,20000),math.random(-8000,8000))
				if(tryFlat)then CheckPos.z=math.random(-100,100) end
				if(util.IsInWorld(CheckPos))then
					-- we're in the world... start the worldhit trace
					local Tr=util.QuickTrace(CheckPos,Vector(0,0,-9e9))
					local Props=util.GetSurfaceData(Tr.SurfaceProps)
					local MatName=(Props and Props.name) or ""
					if(Tr.Hit and Tr.HitWorld and not Tr.StartSolid and not Tr.HitSky and table.HasValue(NatureMats,Tr.MatType) and not table.HasValue(SurfacePropBlacklist,MatName))then
						-- alright... we've found a good world surface
						table.insert(GroundVectors,{pos=Tr.HitPos,mat=Tr.MatType})
					end
				end
				if(i==MaxTries)then
					local OilCount,MaxOil,OreCount,MaxOre,GeoCount,MaxGeo,Alternate,WaterCount,MaxWater=0,50*JMod.Config.ResourceEconomy.OilFrequency,0,50*JMod.Config.ResourceEconomy.OreFrequency,0,3,true,0,20
					for k,v in pairs(GroundVectors)do
						local InWater=bit.band(util.PointContents(v.pos+Vector(0,0,1)),CONTENTS_WATER)==CONTENTS_WATER
						if(GeoCount<MaxGeo)then
							local amt=math.Rand(.001,.005)*JMod.Config.ResourceEconomy.GeothermalPowerMult
							if(math.random(1,4)==2)then amt=amt*math.Rand(2,4) end
							if(v.mat==MAT_SNOW)then amt=amt*2 end -- better geothermal in cold places
							table.insert(JMod.GeoThermalReservoirs,{
								pos=v.pos,
								amt=math.Round(amt,5),
								siz=math.random(150,1000)
							})
							GeoCount=GeoCount+1
						elseif(WaterCount<MaxWater)then
							if not(InWater)then
								local amt=math.random(70,180)
								if(math.random(1,4)==2)then amt=amt*math.Rand(2,4) end
								if(v.mat==MAT_SAND)then amt=amt*2 end -- need more water in arid places
								table.insert(JMod.WaterReservoirs,{
									pos=v.pos,
									amt=math.Round(amt),
									siz=math.random(150,1000)
								})
								WaterCount=WaterCount+1
							end
						elseif(Alternate)then
							if(OilCount<MaxOil)then
								local amt=math.random(70,180)*JMod.Config.ResourceEconomy.OilRichness
								if(InWater)then amt=amt*2 end -- fracking time
								table.insert(JMod.OilReserves,{
									pos=v.pos,
									amt=math.Round(amt),
									siz=math.random(150,1000)
								})
								OilCount=OilCount+1
							end
							Alternate=false
						else
							if(OreCount<MaxOre)then
								local amt=math.random(70,180)*JMod.Config.ResourceEconomy.OreRichness
								table.insert(JMod.OreDeposits,{
									pos=v.pos,
									amt=math.Round(amt),
									siz=math.random(150,1000)
								})
								OreCount=OreCount+1
							end
							Alternate=true
						end
					end
					if(((OilCount<2)or(OreCount<2)or(GeoCount<2))and not(tryFlat))then
						-- if we couldn't find anything, it might be an RP map which is really flat
						JMod.GenerateNaturalResources(true)
					else
						RemoveOverlaps(JMod.OilReserves)
						RemoveOverlaps(JMod.OreDeposits)
						RemoveOverlaps(JMod.GeoThermalReservoirs)
						RemoveOverlaps(JMod.WaterReservoirs)
						-- randomly boost a few deposits in order to create the potential for conflict ( ͡° ͜ʖ ͡°)
						if(math.random(1,2)==1)then PumpItUp(JMod.GeoThermalReservoirs,1,2,4) end
						PumpItUp(JMod.WaterReservoirs,math.random(0,2),4,10)
						PumpItUp(JMod.OilReserves,math.random(1,3),4,10)
						PumpItUp(JMod.OreDeposits,math.random(1,3),4,10)
						WeightByAltitude(JMod.OreDeposits)
						WeightByAltitude(JMod.WaterReservoirs,true)
						print("JMOD: resource generation finished with "..#JMod.OilReserves.." oil reserves, "..#JMod.OreDeposits.." ore deposits, "..#JMod.WaterReservoirs.." water reservoirs and "..#JMod.GeoThermalReservoirs.." geothermal reservoirs")
					end
				end
			end)
		end
	end
	hook.Add("InitPostEntity","JMod_InitPostEntityServer",function()
		JMod.GenerateNaturalResources()
	end)
	concommand.Add("jacky_trace_debug",function(ply)
		local Tr=ply:GetEyeTrace()
		print("--------- trace results ----------")
		PrintTable(Tr)
		local Props=util.GetSurfaceData(Tr.SurfaceProps)
		if(Props)then
			print("----------- surface properties ----------")
			PrintTable(Props)
		end
		print("---------- end trace debug -----------")
	end)
	concommand.Add("jmod_debug_shownaturalresources",function(ply,cmd,args)
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
			RenderPoints(JMod.OilReserves,Color(20,20,20,200))
			RenderPoints(JMod.OreDeposits,Color(120,120,120,200))
			RenderPoints(JMod.GeoThermalReservoirs,Color(120,60,20,200))
			RenderPoints(JMod.WaterReservoirs,Color(50,100,150,200))
		end
	end)
end