--[[
1 axe
1 bat
1 bow
1 combat knife
1 hatchet
1 pocket knife
1 sledgehammer
1 sword
2 blunderbuss
2 musket
3 cap and ball revolver
4 break-action shotgun
4 revolver
4 single shot rifle
5 crossbow
6 bolt action rifle
6 lever-action rifle
6 magnum revolver
6 pump-action shotgun
6 shot revolver
7 grenade launcher
7 pistol
7 plinking pistol
7 pocket pistol
7 sniper rifle
8 anti-materiel sniper rifle
8 assault rifle
8 battle rifle
8 carbine
8 designated marksman rifle
8 machine pistol
8 magnum pistol
8 rocket launcher
8 semiautomatic shotgun
8 submachine gun
9 anti-materiel rifle
9 fully-automatic shotgun
9 light machine gun
9 medium machine gun
10 multiple grenade launcher
10 multiple rocket launcher
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
JMod.WeaponTable={
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
	["Bolt-Action Rifle"]={
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
		mdl="models/weapons/w_jmod_ujp.mdl",
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
	},
	["Crossbow"]={
		mdl="models/weapons/w_jmod_crossbow.mdl",
		swep="wep_jack_gmod_crossbow",
		ent="ent_jack_gmod_ezweapon_crossbow"
	},
	["Flintlock Musket"]={
		mdl="models/weapons/w_jmod_musket.mdl",
		swep="wep_jack_gmod_flintlockmusket",
		ent="ent_jack_gmod_ezweapon_flm"
	},
	["Flintlock Blunderbuss"]={
		mdl="models/weapons/blunder/blunder.mdl",
		swep="wep_jack_gmod_blunderbuss",
		ent="ent_jack_gmod_ezweapon_flb"
	},
	["Flintlock Pistol"]={
		mdl="models/weapons/w_jmod_musket.mdl",
		swep="wep_jack_gmod_flintlockmusket",
		ent="ent_jack_gmod_ezweapon_flp"
	},
	["Cap and Ball Revolver"]={
		mdl="models/krazy/gtav/weapons/navyrevolver_w.mdl",
		swep="wep_jack_gmod_cabr",
		ent="ent_jack_gmod_ezweapon_cabr"
	},
	["Magnum Trapdoor Revolver"]={
		mdl="models/krazy/gtav/weapons/navyrevolver_w.mdl",
		swep="wep_jack_gmod_bigiron",
		ent="ent_jack_gmod_ezweapon_bigiron"
	},
	["Pocket Knife"]={
		mdl="models/weapons/w_jmod_pocketknife.mdl",
		swep="wep_jack_gmod_pocketknife",
		ent="ent_jack_gmod_ezweapon_pocketknife"
	},
	["Combat Knife"]={
		mdl="models/weapons/w_jmod_pocketknife.mdl",
		swep="wep_jack_gmod_combatknife",
		ent="ent_jack_gmod_ezweapon_combatknife"
	}
	-- keepcorpses caauses floating arrow bug
}
JMod.AmmoTable={
	["Light Rifle Round"]={
		resourcetype="ammo",
		sizemult=6,
		carrylimit=200,
		basedmg=40,
		effrange=100,
		terminaldmg=10,
		penetration=40
	},
	["Light Rifle Round-Armor Piercing"]={
		armorpiercing=.2,
		penetration=70
	},
	["Light Rifle Round-Ballistic Tip"]={
		expanding=.4,
		penetration=30
	},
	["Light Rifle Round-Tracer"]={
		tracer=true
	},
	["Medium Rifle Round"]={
		resourcetype="ammo",
		sizemult=12,
		carrylimit=100,
		basedmg=60,
		effrange=200,
		terminaldmg=20,
		penetration=70
	},
	["Heavy Rifle Round"]={
		resourcetype="ammo",
		sizemult=24,
		carrylimit=25,
		basedmg=200,
		effrange=300,
		terminaldmg=30,
		penetration=120
	},
	["Magnum Rifle Round"]={
		resourcetype="ammo",
		sizemult=18,
		carrylimit=50,
		basedmg=110,
		effrange=400,
		terminaldmg=20,
		penetration=90
	},
	["Shotgun Round"]={
		resourcetype="ammo",
		sizemult=14,
		carrylimit=70,
		basedmg=11,
		effrange=50,
		projnum=9,
		terminaldmg=1,
		penetration=10,
		dmgtype=DMG_BUCKSHOT
	},
	["Pistol Round"]={
		resourcetype="ammo",
		sizemult=3,
		carrylimit=300,
		basedmg=20,
		effrange=50,
		terminaldmg=5,
		penetration=20
	},
	["Plinking Round"]={
		resourcetype="ammo",
		sizemult=1,
		carrylimit=600,
		basedmg=11,
		effrange=50,
		terminaldmg=1,
		penetration=10
	},
	["Magnum Pistol Round"]={
		resourcetype="ammo",
		sizemult=6,
		carrylimit=150,
		basedmg=35,
		effrange=50,
		terminaldmg=15,
		penetration=25
	},
	["Small Shotgun Round"]={
		resourcetype="ammo",
		sizemult=6,
		carrylimit=120,
		basedmg=12,
		effrange=30,
		projnum=5,
		terminaldmg=1,
		penetration=10,
		dmgtype=DMG_BUCKSHOT
	},
	["40mm Grenade"]={
		resourcetype="munitions",
		sizemult=30,
		carrylimit=20,
		ent="ent_jack_gmod_ezprojectilenade",
		nicename="EZ 40mm Grenade",
		basedmg=220,
		blastrad=150
	},
	["Mini Rocket"]={
		resourcetype="munitions",
		sizemult=60,
		carrylimit=6,
		ent="ent_jack_gmod_ezminirocket",
		nicename="EZ Mini Rocket",
		basedmg=350,
		blastrad=200
	},
	["Arrow"]={
		sizemult=24,
		carrylimit=30,
		ent="ent_jack_gmod_ezarrow",
		armorpiercing=.6,
		basedmg=70
	},
	["Black Powder Paper Cartridge"]={
		sizemult=7,
		carrylimit=100,
		basedmg=95,
		effrange=50,
		terminaldmg=30,
		penetration=30,
		dmgtype=DMG_BUCKSHOT
	},
	["Black Powder Metallic Cartridge"]={
		sizemult=6,
		carrylimit=100,
		basedmg=90,
		effrange=100,
		terminaldmg=30,
		penetration=40
	}
}
for k,v in pairs(JMod.AmmoTable)do
	game.AddAmmoType({name=k})
	if(CLIENT)then
		language.Add(k.."_ammo",k)
		if(v.ent)then
			language.Add(v.ent,v.nicename)
		end
	end
end
function JMod.GetAmmoSpecs(typ)
	if not(JMod.AmmoTable[typ])then return nil end
	local Result,BaseType=table.FullCopy(JMod.AmmoTable[typ]),string.Split(typ,"-")[1]
	return table.Inherit(Result,JMod.AmmoTable[BaseType])
end
function JMod.ApplyAmmoSpecs(wep,typ,mult)
	mult=mult or 1
	wep.Primary.Ammo=typ
	local Specs=JMod.GetAmmoSpecs(typ)
	wep.Damage=Specs.basedmg*mult
	wep.Num=Specs.projnum or 1
	if(Specs.effrange)then wep.Range=Specs.effrange end
	if(Specs.terminaldmg)then wep.DamageMin=Specs.terminaldmg*mult end
	if(Specs.penetration)then wep.Penetration=Specs.penetration end
	if(Specs.blastrad)then wep.BlastRadius=Specs.blastrad end
	if(Specs.dmgtype)then wep.DamageType=Specs.dmgtype end
	if(Specs.expanding)then wep.EZexpangingAmmo=Specs.expanding end
	if(Specs.armorpiercing)then wep.EZarmorpiercingAmmo=Specs.armorpiercing end
	-- todo: implement this when we add these types
	if(Specs.tracer)then wep.Tracer=true else wep.Tracer=false end
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
JMod.GunHandlingSounds={
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
if(CLIENT)then
	net.Receive("JMod_EZweaponMod",function()
		local Type,ply=net.ReadInt(16),LocalPlayer()
		if(Type==1)then -- ammo type switch
			local Wep=ply:GetActiveWeapon()
			if(Wep)then
				Wep.Primary.Ammo=net.ReadString()
				surface.PlaySound(table.Random(JMod.GunHandlingSounds.tap.magwell))
			end
		end
	end)
	hook.Add("RenderScene", "JMod_ArcCW_RenderScene", function()
		local wpn=LocalPlayer():GetActiveWeapon()
		if not wpn.ArcCW then return end
		if wpn.ForceExpensiveScopes then
			wpn:FormRTScope()
		end
	end)
	concommand.Add("jacky_wep_debug",function(ply,cmd,args)
		local VM=ply:GetViewModel()
		print(VM:GetModel())
		print(ply:GetActiveWeapon().WorldModel)
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
	end, nil, "Helps with EZ weapon debugging.")
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
		},
		hips={
			right={
				bone="ValveBiped.Bip01_Spine1"
			},
			left={
				bone="ValveBiped.Bip01_Spine1"
			}
		}
	}		
	local function RenderHolsteredWeapon(ply,slot,side)
		local Class=ply.EZweapons.slots[slot][side]
		local CurWep=ply:GetActiveWeapon()
		if((Class)and(ply:HasWeapon(Class))and(IsValid(CurWep))and not(CurWep:GetClass()==Class))then
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
						right=nil,
						center=nil
					},
					thighs={
						left=nil,
						right=nil
					},
					hips={
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
						local mdl=ClientsideModel(wep.BodyHolsterModel or wep.WorldModel)
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
		RenderHolsteredWeapon(ply,"hips","left")
		RenderHolsteredWeapon(ply,"hips","right")
	end)
elseif(SERVER)then
	concommand.Add("jmod_ez_dropweapon",function(ply,cmd,args)
		if not(ply:Alive())then return end
		local Wep=ply:GetActiveWeapon()
		if((IsValid(Wep))and(Wep.EZdroppable))then ply:DropWeapon(Wep) end
	end, nil, "Drops your current EZ weapon.")
	concommand.Add("jmod_ez_switchammo",function(ply,cmd,args)
		-- TODO: this is not complete, we need to modify more traits
		-- TracerNum, Penetration, DamageType, Num, maybe Accuracy and Recoil
		-- and somehow we have to keep track of the original values during swaps
		if not(ply:Alive())then return end
		local Wep=ply:GetActiveWeapon()
		if not(Wep.Primary.Ammo and JMod.AmmoTable[Wep.Primary.Ammo])then return end
		local AllTypes,OriginalType={},string.Split(Wep.Primary.Ammo,"-")[1]
		for name,info in pairs(JMod.AmmoTable)do
			if((string.find(name,OriginalType))and(ply:GetAmmoCount(name)>0))then
				table.insert(AllTypes,name)
			end
		end
		if(#AllTypes<=0)then return end
		local CurrentIndex=table.KeyFromValue(AllTypes,Wep.Primary.Ammo)
		local NewIndex=CurrentIndex+1
		if(NewIndex>#AllTypes)then NewIndex=1 end
		local NewType=AllTypes[NewIndex]
		if(NewType~=Wep.Primary.Ammo)then
			Wep:Unload()
			Wep.Primary.Ammo=NewType
			net.Start("JMod_EZweaponMod")
			net.WriteInt(1,16)
			net.WriteString(NewType)
			net.Send(ply)
		else
			JMod.Hint(ply,"no alternate ammo")
		end
	end, nil, "Switches your current ammo type for your EZ weapon.")
	function JMod.GiveAmmo(ply,ent)
		if(ent.EZsupplies)then -- it's a resource box
			local Wep=ply:GetActiveWeapon()
			if(Wep)then
				local PrimType,SecType,PrimSize,SecSize,WepClass=Wep:GetPrimaryAmmoType(),Wep:GetSecondaryAmmoType(),Wep:GetMaxClip1(),Wep:GetMaxClip2(),Wep:GetClass()
				if(table.HasValue(JMod.Config.WeaponAmmoBlacklist,WepClass))then return end
				local IsMunitionBox=ent.EZsupplies=="munitions"
				--[[ PRIMARY --]]
				local PrimName=game.GetAmmoName(PrimType)
				if((PrimName)and(JMod.AmmoTable[PrimName]))then
					-- use JMOD ammo rules
					local AmmoInfo,CurrentAmmo=JMod.AmmoTable[PrimName],ply:GetAmmoCount(PrimName)
					if(ent.EZsupplies==AmmoInfo.resourcetype)then
						local ResourceLeftInBox=ent:GetResource()*3
						local SpaceLeftInPlayerInv,MaxAmtToGive,AmtLeftInBox=AmmoInfo.carrylimit-CurrentAmmo,math.ceil(100/AmmoInfo.sizemult),math.ceil(ResourceLeftInBox*6/AmmoInfo.sizemult)
						local AmtToGive=math.min(SpaceLeftInPlayerInv,MaxAmtToGive,AmtLeftInBox)
						if(AmtToGive>0)then
							local ResourceToTake=math.ceil(AmtToGive/18*AmmoInfo.sizemult)
							ply:GiveAmmo(AmtToGive,PrimType)
							ent:UseEffect(ent:GetPos(),ent)
							ent:SetResource(ent:GetResource()-ResourceToTake)
							if(ent:GetResource()<=0)then ent:Remove();return end
						end
					end
				else
					-- use DEFAULT ammo rules
					if(table.HasValue(JMod.Config.WeaponsThatUseMunitions,WepClass))then
						if not(IsMunitionBox)then return end
					else
						if(IsMunitionBox)then return end
					end
					if((PrimType)and(PrimType~=-1))then
						if(PrimSize==-1)then PrimSize=-PrimSize end
						if(PrimSize<2)then
							PrimSize=PrimSize*4
						elseif(PrimSize<3)then
							PrimSize=PrimSize*3
						elseif(PrimSize<6)then
							PrimSize=PrimSize*2
						end
						if(ply:GetAmmoCount(PrimType)<=PrimSize*10*JMod.Config.AmmoCarryLimitMult)then
							ply:GiveAmmo(PrimSize,PrimType)
							ent:UseEffect(ent:GetPos(),ent)
							ent:SetResource(ent:GetResource()-100*.1)
							if(ent:GetResource()<=0)then ent:Remove();return end
						end
					end
				end
				--[[ SECONDARY --]]
				local SecName=game.GetAmmoName(SecType)
				if((PrimName)and(JMod.AmmoTable[PrimName]))then
					-- use JMOD ammo rules
					-- TODO, no jmod weapons use secondary ammo currently
				else
					-- use DEFAULT ammo rules
					if(table.HasValue(JMod.Config.WeaponsThatUseMunitions,WepClass))then
						if not(IsMunitionBox)then return end
					else
						if(IsMunitionBox)then return end
					end
					if((SecType)and(SecType~=-1))then
						if(SecSize==-1)then SecSize=-SecSize end
						if(ply:GetAmmoCount(SecType)<=SecSize*5*JMod.Config.AmmoCarryLimitMult)then
							ply:GiveAmmo(math.ceil(SecSize/2),SecType)
							ent:UseEffect(ent:GetPos(),ent)
							ent:SetResource(ent:GetResource()-100*.1)
							if(ent:GetResource()<=0)then ent:Remove();return end
						end
					end
				end
			end
		elseif(ent.EZammo)then -- it's a specific ammo box or ammo entity
			local Typ,CountInBox=ent.EZammo,ent:GetCount()
			local AmmoInfo,CurrentAmmo=JMod.GetAmmoSpecs(Typ),ply:GetAmmoCount(Typ)
			local SpaceLeftInPlayerInv=AmmoInfo.carrylimit-CurrentAmmo
			local AmtToGive=math.min(SpaceLeftInPlayerInv,CountInBox)
			if(AmtToGive>0)then
				ply:GiveAmmo(AmtToGive,Typ)
				ent:UseEffect(ent:GetPos(),ent)
				ent:SetCount(CountInBox-AmtToGive)
				if(ent:GetCount()<=0)then ent:Remove();return end
			end
		end
	end
end

-- todo: fix judge anims, remove the extra round