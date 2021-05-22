JMOD_OIL_RESERVES=JMOD_OIL_RESERVES or {}
JMOD_ORE_DEPOSITS=JMOD_ORE_DEPOSITS or {}
JMOD_GEO_THERMALS=JMOD_GEO_THERMALS or {}
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
							table.Remove(tbl,k)
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
	local NatureMats,MaxTries,SurfacePropBlacklist={MAT_SNOW,MAT_SAND,MAT_FOLIAGE,MAT_SLOSH,MAT_GRASS,MAT_DIRT},5000,{"paper","plaster"}
	function JMod_GenerateNaturalResources(tryFlat)
		JMOD_OIL_RESERVES={}
		JMOD_ORE_DEPOSITS={}
		JMOD_GEO_THERMALS={}
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
					local OilCount,MaxOil,OreCount,MaxOre,GeoCount,MaxGeo,Alternate=0,50*JMOD_CONFIG.ResourceEconomy.OilFrequency,0,50*JMOD_CONFIG.ResourceEconomy.OreFrequency,0,3,true
					for k,v in pairs(GroundVectors)do
						local InWater=bit.band(util.PointContents(v.pos+Vector(0,0,1)),CONTENTS_WATER)==CONTENTS_WATER
						if(GeoCount<MaxGeo)then
							local amt=math.Rand(.001,.005)*JMOD_CONFIG.ResourceEconomy.GeothermalPowerMult
							if(math.random(1,5)==2)then amt=amt*math.Rand(5,10) end
							if(v.mat==MAT_SNOW)then amt=amt*2 end -- better geothermal in cold places
							table.insert(JMOD_GEO_THERMALS,{
								pos=v.pos,
								amt=math.Round(amt,5),
								siz=math.random(100,1000)
							})
							GeoCount=GeoCount+1
						elseif(Alternate)then
							if(OilCount<MaxOil)then
								local amt=math.random(70,180)*JMOD_CONFIG.ResourceEconomy.OilRichness
								if(math.random(1,14)==10)then amt=amt*math.Rand(5,10) end
								if(InWater)then amt=amt*2 end -- fracking time
								table.insert(JMOD_OIL_RESERVES,{
									pos=v.pos,
									amt=math.Round(amt),
									siz=math.random(100,1000)
								})
								OilCount=OilCount+1
							end
							Alternate=false
						else
							if(OreCount<MaxOre)then
								local amt=math.random(70,180)*JMOD_CONFIG.ResourceEconomy.OreRichness
								if(math.random(1,14)==10)then amt=amt*math.Rand(5,10) end
								table.insert(JMOD_ORE_DEPOSITS,{
									pos=v.pos,
									amt=math.Round(amt),
									siz=math.random(100,1000)
								})
								OreCount=OreCount+1
							end
							Alternate=true
						end
					end
					if(((OilCount<2)or(OreCount<2))and not(tryFlat))then
						-- if we couldn't find anything, it might be an RP map which is really flat
						JMod_GenerateNaturalResources(true)
					else
						RemoveOverlaps(JMOD_OIL_RESERVES)
						RemoveOverlaps(JMOD_ORE_DEPOSITS)
						RemoveOverlaps(JMOD_GEO_THERMALS)
						print("JMOD: resource generation finished with "..#JMOD_OIL_RESERVES.." oil reserves, "..#JMOD_ORE_DEPOSITS.." ore deposits and "..#JMOD_GEO_THERMALS.." geothermal reservoirs")
					end
				end
			end)
		end
	end
	hook.Add("InitPostEntity","JMod_InitPostEntityServer",function()
		JMod_GenerateNaturalResources()
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
		net.WriteTable(JMOD_OIL_RESERVES)
		net.WriteTable(JMOD_ORE_DEPOSITS)
		net.WriteTable(JMOD_GEO_THERMALS)
		net.Send(ply)
	end)
elseif(CLIENT)then
	local ShowNaturalResources=false
	net.Receive("JMod_NaturalResources",function()
		ShowNaturalResources=not ShowNaturalResources
		print("natural resource display: "..tostring(ShowNaturalResources))
		JMOD_OIL_RESERVES=net.ReadTable()
		JMOD_ORE_DEPOSITS=net.ReadTable()
		JMOD_GEO_THERMALS=net.ReadTable()
	end)
	local Circle=Material("sprites/sent_ball")
	local function RenderPoints(tbl,col)
		for k,v in pairs(JMOD_OIL_RESERVES)do
			cam.Start3D2D(v.pos+Vector(0,0,50),Angle(0,0,0),10)
			surface.SetDrawColor(col)
			surface.SetMaterial(Circle)
			surface.DrawTexturedRect(-v.siz/10,-v.siz/10,v.siz*2/10,v.siz*2/10)
			draw.DrawText(v.amt,"DermaLarge",0,0,color_white,TEXT_ALIGN_CENTER)
			cam.End3D2D()
		end
	end
	hook.Add("PostDrawTranslucentRenderables","JMod_EconTransRend",function()
		if(ShowNaturalResources)then
			RenderPoints(JMOD_OIL_RESERVES,Color(20,20,20,200))
			RenderPoints(JMOD_ORE_DEPOSITS,Color(120,120,120,200))
			RenderPoints(JMOD_GEO_THERMALS,Color(120,60,20,200))
		end
	end)
end