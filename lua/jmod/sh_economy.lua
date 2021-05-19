JMOD_OIL_RESERVES=JMOD_OIL_RESERVES or {}
JMOD_ORE_DEPOSITS=JMOD_ORE_DEPOSITS or {}
if(SERVER)then
	local NatureMats,MaxTries={MAT_SNOW,MAT_SAND,MAT_FOLIAGE,MAT_SLOSH,MAT_GRASS,MAT_DIRT},5000
	function JMod_GenerateNaturalResources(tryFlat)
		JMOD_OIL_RESERVES={}
		JMOD_ORE_DEPOSITS={}
		-- first, we have to find the ground
		local GroundVectors={}
		print("JMOD: generating oil reserves and ore deposits...")
		for i=1,MaxTries do
			timer.Simple(i/1000,function()
				local CheckPos=Vector(math.random(-20000,20000),math.random(-20000,20000),math.random(-20000,8000))
				if(tryFlat)then CheckPos.z=math.random(-100,100) end
				if(util.IsInWorld(CheckPos))then
					-- we're in the world... start the worldhit trace
					local Tr=util.QuickTrace(CheckPos,Vector(0,0,-9e9))
					if(Tr.Hit and Tr.HitWorld and not Tr.StartSolid and not Tr.HitSky and table.HasValue(NatureMats,Tr.MatType))then
						-- alright... we've found a good world surface
						-- let's check to make sure it's solid underneath
						local Good,Bad=0,0
						for j=1,50 do
							-- todo
						end
						table.insert(GroundVectors,Tr.HitPos)
					end 
				end
				if(i==MaxTries)then
					local OilCount,MaxOil,OreCount,MaxOre=0,60*JMOD_CONFIG.ResourceEconomy.OilFrequency,0,60*JMOD_CONFIG.ResourceEconomy.OreFrequency
					for k,v in pairs(GroundVectors)do
						if(math.random(1,2)==1)then
							if(OilCount<MaxOil)then
								local amt=math.random(80,200)*JMOD_CONFIG.ResourceEconomy.OilRichness
								if(math.random(1,11)==10)then amt=amt*math.Rand(5,10) end
								if(util.PointContents(v+Vector(0,0,1))==CONTENTS_WATER)then amt=amt*2 end
								table.insert(JMOD_OIL_RESERVES,{
									pos=v,
									amt=math.Round(amt),
									siz=math.random(100,1000)
								})
								OilCount=OilCount+1
							end
						else
							if(OreCount<MaxOre)then
								local amt=math.random(100,300)*JMOD_CONFIG.ResourceEconomy.OreRichness
								if(math.random(1,11)==10)then amt=amt*math.Rand(3,6) end
								table.insert(JMOD_ORE_DEPOSITS,{
									pos=v,
									amt=math.Round(amt),
									siz=math.random(100,1000)
								})
								OreCount=OreCount+1
							end
						end
					end
					if((OilCount<2)and(OreCount<2)and not(tryFlat))then
						-- if we couldn't find anything, it might be an RP map which is really flat
						JMod_GenerateNaturalResources(true)
					else
						print("JMOD: resource generation finished with "..#JMOD_OIL_RESERVES.." oil reserves and "..#JMOD_ORE_DEPOSITS.." ore deposits")
					end
				end
			end)
		end
	end
	hook.Add("InitPostEntity","JMod_InitPostEntityServer",function()
		JMod_GenerateNaturalResources()
	end)
	concommand.Add("jmod_debug_shownaturalresources",function(ply,cmd,args)
		if((IsValid(ply))and not(ply:IsSuperAdmin()))then return end
		net.Start("JMod_NaturalResources")
		net.WriteTable(JMOD_OIL_RESERVES)
		net.WriteTable(JMOD_ORE_DEPOSITS)
		net.Send(ply)
	end)
elseif(CLIENT)then
	local ShowNaturalResources=false
	net.Receive("JMod_NaturalResources",function()
		ShowNaturalResources=not ShowNaturalResources
		print("natural resource display: "..tostring(ShowNaturalResources))
		JMOD_OIL_RESERVES=net.ReadTable()
		JMOD_ORE_DEPOSITS=net.ReadTable()
	end)
	local Circle=Material("sprites/sent_ball")
	hook.Add("PostDrawTranslucentRenderables","JMod_EconTransRend",function()
		if(ShowNaturalResources)then
			for k,v in pairs(JMOD_OIL_RESERVES)do
				cam.Start3D2D(v.pos+Vector(0,0,100),Angle(0,0,0),10)
				surface.SetDrawColor(30,30,30,200)
				surface.SetMaterial(Circle)
				surface.DrawTexturedRect(-v.siz/10,-v.siz/10,v.siz*2/10,v.siz*2/10)
				draw.DrawText(v.amt,"DermaLarge",0,0,color_white,TEXT_ALIGN_CENTER)
				cam.End3D2D()
			end
			for k,v in pairs(JMOD_ORE_DEPOSITS)do
				cam.Start3D2D(v.pos+Vector(0,0,100),Angle(0,0,0),10)
				surface.SetDrawColor(150,150,150,200)
				surface.SetMaterial(Circle)
				surface.DrawTexturedRect(-v.siz/10,-v.siz/10,v.siz*2/10,v.siz*2/10)
				draw.DrawText(v.amt,"DermaLarge",0,0,color_white,TEXT_ALIGN_CENTER)
				cam.End3D2D()
			end
		end
	end)
end