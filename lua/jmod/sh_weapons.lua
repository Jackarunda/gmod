--[[
	assault rifle - CW2.0 MWR - M16A4
	battle rifle - Robotnik's CoD4 SWEPs - G3
	carbine - CW2.0 MWR - G36C
	designated marksman rifle - Mac's CoD MW2 SWEPs - M21 EBR
	bolt action rifle - Robotnik's CoD4 SWEPs - R700
	sniper rifle - Robotnik's CoD4 SWEPs - M40A3
	anti-materiel sniper rifle - Mac's CoD MW2 SWEPs - Intervention
	semiautomatic shotgun - Mac's CoD MW2 SWEPs - M1014
	pump-action shotgun - Robotnik's CoD4 SWEPs - W1200
	break-action shotgun - cod over-under shotty
pistol - Mac's CoD Black Ops II SWEPs - B23R
pocket pistol - 
plinking pistol - 
machine pistol - Mac's Black Ops SWEPs - MAC11
submachine gun - Robotnik's CoD4 SWEPs - MP5
light machine gun - Robotnik's CoD4 SWEPs - M249
medium machine gun - Mac's CoD MW2 SWEPs - M240
magnum revolver - Mac's CoD MW2 SWEPs - .44 Magnum
magnum pistol - Mac's CoD MW2 SWEPs - Desert Eagle
shot revolver - Mac's CoD Black Ops II SWEPs - Executioner
anti-materiel rifle - Mac's CoD MW2 SWEPs - Barret .50 Cal
grenade launcher - Mac's CoD MW2 SWEPs - Thumper
rocket launcher - Mac's CoD MW2 SWEPs - AT4
multiple grenade launcher - Mac's CoD Black Ops II SWEPs - War Machine
crossbow - Mac's CoD Black Ops SWEPs - Crossbow
multiple rocket launcher - Mac's CoD Black Ops SWEPs - Grim Reaper
revolver - Mac's CoD Black Ops SWEPs - Python
combat knife - TFA-CoD-IW-Combat-Knife
lever-action rifle - the dangerman one
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
		mdl="models/nmrih/weapons/fa_sv10/w_fa_sv10.mdl",
		swep="wep_jack_gmod_bas",
		ent="ent_jack_gmod_ezweapon_bas"
	},
	["Pistol"]={
		mdl="models/weapons/w_jmod_b23r.mdl",
		swep="wep_jack_gmod_pistol",
		ent="ent_jack_gmod_ezweapon_pistol"
	}
}
game.AddAmmoType({
	name = "Light Rifle Round"
})
game.AddAmmoType({
	name = "Medium Rifle Round"
})
game.AddAmmoType({
	name = "Heavy Rifle Round"
})
game.AddAmmoType({
	name = "Magnum Rifle Round"
})
game.AddAmmoType({
	name = "Shotgun Round"
})
game.AddAmmoType({
	name = "Pistol Round"
})
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
	language.Add("Light Rifle Round_ammo","Light Rifle Round")
	language.Add("Medium Rifle Round_ammo","Medium Rifle Round")
	language.Add("Magnum Rifle Round_ammo","Magnum Rifle Round")
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
	--
end