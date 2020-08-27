--[[
	5 assault rifle - CW2.0 MWR - M16A4
	5 battle rifle - Robotnik's CoD4 SWEPs - G3
	5 carbine - CW2.0 MWR - G36C
	5 designated marksman rifle - Mac's CoD MW2 SWEPs - M21 EBR
	3 bolt action rifle - Robotnik's CoD4 SWEPs - R700
	4 sniper rifle - Robotnik's CoD4 SWEPs - M40A3
	5 anti-materiel sniper rifle - Mac's CoD MW2 SWEPs - Intervention
	5 semiautomatic shotgun - Mac's CoD MW2 SWEPs - M1014
	3 pump-action shotgun - Robotnik's CoD4 SWEPs - W1200
	1 break-action shotgun - cod over-under shotty
	4 pistol - Mac's CoD Black Ops II SWEPs - B23R
	4 pocket pistol - cod4 usp
	4 plinking pistol - cod4 usp
	5 machine pistol - Mac's Black Ops SWEPs - MAC11s
	5 submachine gun - Robotnik's CoD4 SWEPs - MP5
	6 light machine gun - Robotnik's CoD4 SWEPs - M249
	6 medium machine gun - Mac's CoD MW2 SWEPs - M240
	3 magnum revolver - Mac's CoD MW2 SWEPs - .44 Magnum
	5 magnum pistol - Mac's CoD MW2 SWEPs - Desert Eagle
	2 revolver - Mac's CoD Black Ops SWEPs - Python
	3 shot revolver - Mac's CoD Black Ops II SWEPs - Executioner
	3 lever-action rifle - the dangerman one
	1 single shot rifle - matini henry
	6 anti-materiel rifle - Mac's CoD MW2 SWEPs - Barret .50 Cal
	6 fully-automatic shotgun - mw2 aa12
	4 grenade launcher - Mac's CoD MW2 SWEPs - Thumper
	6 multiple grenade launcher - Mac's CoD Black Ops II SWEPs - War Machine
	5 rocket launcher - Mac's CoD MW2 SWEPs - AT4
6 multiple rocket launcher - Mac's CoD Black Ops SWEPs - Grim Reaper
4 crossbow - Mac's CoD Black Ops SWEPs - Crossbow
1 combat knife - TFA-CoD-IW-Combat-Knife
flamethrower?
-------------------------------
"VertexlitGeneric"
{
       "$basetexture" "models/weapons/v_models/CoD4/m4a1/weapon_m4_col"
        $bumpmap   "models/weapons/v_models/CoD4/m4a1/normal"
 
        $phong  "1"
        $phongboost  ".2"
        $phongfresnelranges     "[1 1 1]"
        $phongexponent 20
        $nocull  1	
}
$attachment "muzzle" "ValveBiped.Bip01_R_Hand" 38 0 -12 rotate 15 0 0
$attachment "shell" "ValveBiped.Bip01_R_Hand" 9.5 -0.7 -5 rotate 30 90 -90

$definebone "ValveBiped.Bip01_R_Hand" "" -0.678304 13.183071 4.586786 10.000006 -89.999982 -179.999978 0 0 0 0 0 0
--]]
JMod_WeaponTable={
	["Assault Rifle"]={
		mdl="models/weapons/w_jmod_m16.mdl",
		swep="wep_jack_gmod_assaultrifle",
		ent="ent_jack_gmod_ezweapon_ar"
	},
	["Battle Rifle"]={
		mdl="models/weapons/w_jmod_g3.mdl",
		swep="wep_jack_gmod_battlerifle",
		ent="ent_jack_gmod_ezweapon_br"
	},
	["Carbine"]={
		mdl="models/weapons/w_jmod_g36.mdl",
		swep="wep_jack_gmod_carbine",
		ent="ent_jack_gmod_ezweapon_car"
	},
	["Designated Marksman Rifle"]={
		mdl="models/weapons/w_jmod_m21.mdl",
		swep="wep_jack_gmod_dmr",
		ent="ent_jack_gmod_ezweapon_dmr"
	},
	["Bolt Action Rifle"]={
		mdl="models/weapons/w_jmod_r700.mdl",
		swep="wep_jack_gmod_boltactionrifle",
		ent="ent_jack_gmod_ezweapon_bar"
	},
	["Sniper Rifle"]={
		mdl="models/weapons/w_jmod_m40a3.mdl",
		swep="wep_jack_gmod_sniperrifle",
		ent="ent_jack_gmod_ezweapon_sr"
	},
	["Anti-Materiel Sniper Rifle"]={
		mdl="models/weapons/w_jmod_intervention.mdl",
		swep="wep_jack_gmod_amsr",
		ent="ent_jack_gmod_ezweapon_amsr"
	},
	["Semi-Automatic Shotgun"]={
		mdl="models/weapons/w_jmod_m1014.mdl",
		swep="wep_jack_gmod_sas",
		ent="ent_jack_gmod_ezweapon_sas"
	},
	["Pump-Action Shotgun"]={
		mdl="models/weapons/w_jmod_w1200.mdl",
		swep="wep_jack_gmod_pas",
		ent="ent_jack_gmod_ezweapon_pas"
	},
	["Break-Action Shotgun"]={
		mdl="models/weapons/w_jmod_breakshotty.mdl",
		swep="wep_jack_gmod_bas",
		ent="ent_jack_gmod_ezweapon_bas",
		size=1.1
	},
	["Pistol"]={
		mdl="models/weapons/w_jmod_b23r.mdl",
		swep="wep_jack_gmod_pistol",
		ent="ent_jack_gmod_ezweapon_pistol",
		size=1.2
	},
	["Pocket Pistol"]={
		mdl="models/weapons/w_jmod_usp.mdl",
		swep="wep_jack_gmod_pocketpistol",
		ent="ent_jack_gmod_ezweapon_pocketpistol"
	},
	["Plinking Pistol"]={
		mdl="models/weapons/w_jmod_usp.mdl",
		swep="wep_jack_gmod_plinkingpistol",
		ent="ent_jack_gmod_ezweapon_plinkingpistol",
		size=1.1
	},
	["Machine Pistol"]={
		mdl="models/weapons/w_jmod_mac11.mdl",
		swep="wep_jack_gmod_machinepistol",
		ent="ent_jack_gmod_ezweapon_machinepistol",
		size=1.1
	},
	["Sub Machine Gun"]={
		mdl="models/weapons/w_jmod_mp5.mdl",
		swep="wep_jack_gmod_smg",
		ent="ent_jack_gmod_ezweapon_smg"
	},
	["Light Machine Gun"]={
		mdl="models/weapons/w_jmod_m249.mdl",
		swep="wep_jack_gmod_lmg",
		ent="ent_jack_gmod_ezweapon_lmg"
	},
	["Medium Machine Gun"]={
		mdl="models/weapons/w_jmod_m240.mdl",
		swep="wep_jack_gmod_mmg",
		ent="ent_jack_gmod_ezweapon_mmg"
	},
	["Magnum Revolver"]={
		mdl="models/weapons/w_jmod_44mag.mdl",
		swep="wep_jack_gmod_magrevolver",
		ent="ent_jack_gmod_ezweapon_magrevolver",
		size=1.1
	},
	["Magnum Pistol"]={
		mdl="models/weapons/w_jmod_deagle.mdl",
		swep="wep_jack_gmod_magpistol",
		ent="ent_jack_gmod_ezweapon_magpistol",
		size=1.4
	},
	["Revolver"]={
		mdl="models/weapons/w_jmod_revolver.mdl",
		swep="wep_jack_gmod_revolver",
		ent="ent_jack_gmod_ezweapon_revolver",
		size=1.1
	},
	["Shot Revolver"]={
		mdl="models/weapons/w_jmod_shotrevolver.mdl",
		swep="wep_jack_gmod_shotrevolver",
		ent="ent_jack_gmod_ezweapon_shotrevolver",
		size=1.1
	},
	["Lever-Action Carbine"]={
		mdl="models/weapons/w_jmod_levergun.mdl",
		swep="wep_jack_gmod_lac",
		ent="ent_jack_gmod_ezweapon_lac",
		--size=1.1 -- CRASH
	},
	["Single-Shot Rifle"]={
		mdl="models/weapons/w_snip_blast_martini-henry_arccw.mdl",
		swep="wep_jack_gmod_ssr",
		ent="ent_jack_gmod_ezweapon_ssr",
		size=1.1
	},
	["Anti-Materiel Rifle"]={
		mdl="models/weapons/w_jmod_m107.mdl",
		swep="wep_jack_gmod_amr",
		ent="ent_jack_gmod_ezweapon_amr",
		size=1.1
	},
	["Fully-Automatic Shotgun"]={
		mdl="models/weapons/w_jmod_fullautoshotty.mdl",
		swep="wep_jack_gmod_fas",
		ent="ent_jack_gmod_ezweapon_fas",
		size=1.1
	},
	["Grenade Launcher"]={
		mdl="models/weapons/w_jmod_m79.mdl",
		swep="wep_jack_gmod_gl",
		ent="ent_jack_gmod_ezweapon_gl",
		size=1.1
	},
	["Multiple Grenade Launcher"]={
		mdl="models/weapons/w_jmod_milkormgl.mdl",
		swep="wep_jack_gmod_mgl",
		ent="ent_jack_gmod_ezweapon_mgl",
		size=1.1
	},
	["Rocket Launcher"]={
		mdl="models/weapons/w_jmod_at4.mdl",
		swep="wep_jack_gmod_rocketlauncher",
		ent="ent_jack_gmod_ezweapon_rocketlauncher",
		size=1.1
	},
	["Multiple Rocket Launcher"]={
		mdl="models/weapons/w_jmod_m202.mdl",
		swep="wep_jack_gmod_mrl",
		ent="ent_jack_gmod_ezweapon_mrl",
		size=1.1
	}
}
JMod_AmmoTable={
	["Light Rifle Round"]={
		resourcetype="ammo",
		sizemult=6,
		carrylimit=200
	},
	["Medium Rifle Round"]={
		resourcetype="ammo",
		sizemult=12,
		carrylimit=100
	},
	["Heavy Rifle Round"]={
		resourcetype="ammo",
		sizemult=24,
		carrylimit=25
	},
	["Magnum Rifle Round"]={
		resourcetype="ammo",
		sizemult=18,
		carrylimit=50
	},
	["Shotgun Round"]={
		resourcetype="ammo",
		sizemult=14,
		carrylimit=70
	},
	["Pistol Round"]={
		resourcetype="ammo",
		sizemult=3,
		carrylimit=300
	},
	["Plinking Round"]={
		resourcetype="ammo",
		sizemult=1,
		carrylimit=600
	},
	["Magnum Pistol Round"]={
		resourcetype="ammo",
		sizemult=6,
		carrylimit=150
	},
	["Small Shotgun Round"]={
		resourcetype="ammo",
		sizemult=6,
		carrylimit=150
	},
	["40mm Grenade"]={
		resourcetype="munitions",
		sizemult=30,
		carrylimit=20,
		ent="ent_jack_gmod_ezprojectilenade",
		nicename="EZ 40mm Grenade"
	},
	["Mini Rocket"]={
		resourcetype="munitions",
		sizemult=60,
		carrylimit=6,
		ent="ent_jack_gmod_ezminirocket",
		nicename="EZ Mini Rocket"
	}
}
for k,v in pairs(JMod_AmmoTable)do
	game.AddAmmoType({name=k})
	if(CLIENT)then
		language.Add(k.."_ammo",k)
		if(v.ent)then
			language.Add(v.ent,v.nicename)
		end
	end
end
for k,v in pairs({
	"muzzleflash_g3",
	"muzzleflash_m14",
	"muzzleflash_ak47",
	"muzzleflash_ak74",
	"muzzleflash_6",
	"muzzleflash_pistol_rbull",
	"muzzleflash_pistol",
	"muzzleflash_suppressed",
	"muzzleflash_pistol_deagle",
	"muzzleflash_OTS",
	"muzzleflash_M3",
	"muzzleflash_smg",
	"muzzleflash_SR25",
	"muzzleflash_shotgun",
	"muzzle_center_M82",
	"muzzleflash_m79"
})do
	PrecacheParticleSystem(v)
end
JMod_GunHandlingSounds={
	draw={
		handgun={
			"snds_jack_gmod/ez_weapons/handling/draw_pistol1.wav",
			"snds_jack_gmod/ez_weapons/handling/draw_pistol2.wav",
			"snds_jack_gmod/ez_weapons/handling/draw_pistol3.wav",
			"snds_jack_gmod/ez_weapons/handling/draw_pistol4.wav",
			"snds_jack_gmod/ez_weapons/handling/draw_pistol5.wav",
			"snds_jack_gmod/ez_weapons/handling/draw_pistol6.wav"
		},
		longgun={
			"snds_jack_gmod/ez_weapons/handling/draw_longgun1.wav",
			"snds_jack_gmod/ez_weapons/handling/draw_longgun2.wav",
			"snds_jack_gmod/ez_weapons/handling/draw_longgun3.wav",
			"snds_jack_gmod/ez_weapons/handling/draw_longgun4.wav",
			"snds_jack_gmod/ez_weapons/handling/draw_longgun5.wav",
			"snds_jack_gmod/ez_weapons/handling/draw_longgun6.wav",
			"snds_jack_gmod/ez_weapons/handling/draw_longgun7.wav",
			"snds_jack_gmod/ez_weapons/handling/draw_longgun8.wav"
		}
	},
	tap={
		magwell={
			"snds_jack_gmod/ez_weapons/handling/tap_magwell1.wav",
			"snds_jack_gmod/ez_weapons/handling/tap_magwell2.wav",
			"snds_jack_gmod/ez_weapons/handling/tap_magwell3.wav",
			"snds_jack_gmod/ez_weapons/handling/tap_magwell4.wav",
			"snds_jack_gmod/ez_weapons/handling/tap_magwell5.wav",
			"snds_jack_gmod/ez_weapons/handling/tap_magwell6.wav"
		},
		metallic={
			"snds_jack_gmod/ez_weapons/handling/tap_metallic.wav"
		}
	},
	aim={
		inn={
			"snds_jack_gmod/ez_weapons/handling/aim1.wav",
			"snds_jack_gmod/ez_weapons/handling/aim2.wav",
			"snds_jack_gmod/ez_weapons/handling/aim3.wav",
			"snds_jack_gmod/ez_weapons/handling/aim4.wav",
			"snds_jack_gmod/ez_weapons/handling/aim5.wav",
			"snds_jack_gmod/ez_weapons/handling/aim6.wav"
		},
		out={
			"snds_jack_gmod/ez_weapons/handling/aim_out.wav"
		},
		minor={
			"snds_jack_gmod/ez_weapons/handling/aim_minor.wav"
		}
	},
	cloth={
		loud={
			"snds_jack_gmod/ez_weapons/handling/cloth_loud.wav"
		},
		quiet={
			"snds_jack_gmod/ez_weapons/handling/cloth_quiet.wav"
		},
		magpull={
			"snds_jack_gmod/ez_weapons/handling/cloth_magpull1.wav",
			"snds_jack_gmod/ez_weapons/handling/cloth_magpull2.wav",
			"snds_jack_gmod/ez_weapons/handling/cloth_magpull3.wav",
			"snds_jack_gmod/ez_weapons/handling/cloth_magpull4.wav"
		},
		move={
			"snds_jack_gmod/ez_weapons/handling/cloth_move.wav"
		}
	},
	grab={
		"snds_jack_gmod/ez_weapons/handling/grab1.wav"
	},
	shotshell={
		"snds_jack_gmod/ez_weapons/handling/shotshell_insert1.wav",
		"snds_jack_gmod/ez_weapons/handling/shotshell_insert2.wav",
		"snds_jack_gmod/ez_weapons/handling/shotshell_insert3.wav",
		"snds_jack_gmod/ez_weapons/handling/shotshell_insert4.wav"
	}
}
concommand.Add("jmod_ez_dropweapon",function(ply,cmd,args)
	if not(ply:Alive())then return end
	local Wep=ply:GetActiveWeapon()
	if((IsValid(Wep))and(Wep.EZdroppable))then ply:DropWeapon(Wep) end
end)
if(CLIENT)then
	--[[
	local Mat=Material("spherical_aberration")
	hook.Add("PostDrawHUD","AAAAAA",function()
		DrawMaterialOverlay("spherical_aberration",1)
	end)
	--]]
	hook.Add("RenderScene", "JMod_ArcCW_RenderScene", function()
		local wpn = LocalPlayer():GetActiveWeapon()
		if not wpn.ArcCW then return end
		if wpn.ForceExpensiveScopes then
			wpn:FormRTScope()
		end
	end)
	concommand.Add("jacky_vm_debug",function(ply,cmd,args)
		local VM=ply:GetViewModel()
		print(VM:GetModel())
		for i=0,20 do
			local Info=VM:GetSequenceInfo(i)
			if(Info)then print("anim",i,Info.label) end
		end
		print("---------------------")
		for i=0,100 do
			local Name=VM:GetBoneName(i)
			if(Name)then print("bone",i,Name) end
		end
		print("---------------------")
		PrintTable(VM:GetBodyGroups())
		print("---------------------")
		PrintTable(VM:GetAttachments())
	end)
	local SlotInfoTable={
		back={
			right={
				bone="ValveBiped.Bip01_Spine4"
			},
			left={
				bone="ValveBiped.Bip01_Spine4"
			}
		},
		thighs={
			right={
				bone="ValveBiped.Bip01_R_Thigh"
			},
			left={
				bone="ValveBiped.Bip01_L_Thigh"
			}
		}
	}		
	local function RenderHolsteredWeapon(ply,slot,side)
		local Class=ply.EZweapons.slots[slot][side]
		if((Class)and(ply:HasWeapon(Class))and not(ply:GetActiveWeapon():GetClass()==Class))then
			local mdl,slotInfo=ply.EZweapons.mdls[Class],SlotInfoTable[slot][side]
			local ID=ply:LookupBone(slotInfo.bone)
			if(ID)then
				local Wep=ply:GetWeapon(Class)
				local WepPos,WepAng=Wep.BodyHolsterPos,Wep.BodyHolsterAng
				if(side=="left")then WepPos=Wep.BodyHolsterPosL;WepAng=Wep.BodyHolsterAngL end
				local pos,ang=ply:GetBonePosition(ID)
				local up,right,forward=ang:Up(),ang:Right(),ang:Forward()
				pos=pos+right*WepPos.x+forward*WepPos.y+up*WepPos.z
				ang:RotateAroundAxis(right,WepAng.p)
				ang:RotateAroundAxis(up,WepAng.y)
				ang:RotateAroundAxis(forward,WepAng.r)
				mdl:SetRenderOrigin(pos)
				mdl:SetRenderAngles(ang)
				mdl:DrawModel()
			end
		else
			ply.EZweapons.slots[slot][side]=nil
		end
	end
	hook.Add("PostPlayerDraw","JMod_WeaponPlayerDraw",function(ply)
		if not(ply:Alive())then return end
		if not(ply.EZweapons)then
			ply.EZweapons={
				mdls={},
				slots={
					back={
						left=nil,
						right=nil
					},
					thighs={
						left=nil,
						right=nil
					}
				}
			}
		end
		local ActiveWep=ply:GetActiveWeapon()
		for k,wep in pairs(ply:GetWeapons())do
			if(wep.BodyHolsterSlot)then
				local Class,Slots=wep:GetClass(),ply.EZweapons.slots[wep.BodyHolsterSlot]
				if(wep~=ActiveWep)then
					if not(ply.EZweapons.mdls[Class])then
						local mdl=ClientsideModel(wep.WorldModel)
						mdl:SetPos(ply:GetPos())
						mdl:SetParent(ply)
						mdl:SetModelScale(wep.BodyHolsterScale or 1)
						mdl:SetNoDraw(true)
						ply.EZweapons.mdls[Class]=mdl
					end
					-- lul
					if(not(Slots.right)and(Slots.left~=Class))then
						Slots.right=Class
					elseif(not(Slots.left)and(Slots.right~=Class))then
						Slots.left=Class
					end
				end
			end
		end
		RenderHolsteredWeapon(ply,"back","right")
		RenderHolsteredWeapon(ply,"back","left")
		RenderHolsteredWeapon(ply,"thighs","right")
		RenderHolsteredWeapon(ply,"thighs","left")
	end)
elseif(SERVER)then
	function JMod_GiveAmmo(ply,ent)
		local Wep=ply:GetActiveWeapon()
		if(Wep)then
			local PrimType,SecType,PrimSize,SecSize=Wep:GetPrimaryAmmoType(),Wep:GetSecondaryAmmoType(),Wep:GetMaxClip1(),Wep:GetMaxClip2()
			--[[ PRIMARY --]]
			local PrimName=game.GetAmmoName(PrimType)
			if((PrimName)and(JMod_AmmoTable[PrimName]))then
				-- use JMOD ammo rules
				local AmmoInfo,CurrentAmmo=JMod_AmmoTable[PrimName],ply:GetAmmoCount(PrimName)
				if(ent.EZsupplies==AmmoInfo.resourcetype)then
					local ResourceLeftInBox=ent:GetResource()
					local SpaceLeftInPlayerInv,MaxAmtToGive,AmtLeftInBox=AmmoInfo.carrylimit-CurrentAmmo,math.ceil(100/AmmoInfo.sizemult),math.ceil(ResourceLeftInBox*6/AmmoInfo.sizemult)
					local AmtToGive=math.min(SpaceLeftInPlayerInv,MaxAmtToGive,AmtLeftInBox)
					if(AmtToGive>0)then
						local ResourceToTake=math.ceil(AmtToGive/6*AmmoInfo.sizemult)
						ply:GiveAmmo(AmtToGive,PrimType)
						ent:UseEffect(ent:GetPos(),ent)
						ent:SetResource(ent:GetResource()-ResourceToTake)
						if(ent:GetResource()<=0)then ent:Remove();return end
					end
				end
			else
				-- use DEFAULT ammo rules
				if((PrimType)and(PrimType~=-1))then
					if(PrimSize==-1)then PrimSize=-PrimSize end
					if(PrimSize<2)then
						PrimSize=PrimSize*4
					elseif(PrimSize<3)then
						PrimSize=PrimSize*3
					elseif(PrimSize<6)then
						PrimSize=PrimSize*2
					end
					if(ply:GetAmmoCount(PrimType)<=PrimSize*10*JMOD_CONFIG.AmmoCarryLimitMult)then
						ply:GiveAmmo(PrimSize,PrimType)
						ent:UseEffect(ent:GetPos(),ent)
						ent:SetResource(ent:GetResource()-ent.MaxResource*.1)
						if(ent:GetResource()<=0)then ent:Remove();return end
					end
				end
			end
			--[[ SECONDARY --]]
			local SecName=game.GetAmmoName(SecType)
			if((PrimName)and(JMod_AmmoTable[PrimName]))then
				-- use JMOD ammo rules
				
			else
				-- use DEFAULT ammo rules
				if((SecType)and(SecType~=-1))then
					if(SecSize==-1)then SecSize=-SecSize end
					if(ply:GetAmmoCount(SecType)<=SecSize*5*JMOD_CONFIG.AmmoCarryLimitMult)then
						ply:GiveAmmo(math.ceil(SecSize/2),SecType)
						ent:UseEffect(ent:GetPos(),ent)
						ent:SetResource(ent:GetResource()-ent.MaxResource*.1)
						if(ent:GetResource()<=0)then ent:Remove();return end
					end
				end
			end
		end
	end
end