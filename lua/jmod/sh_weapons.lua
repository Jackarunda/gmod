--[[
assault rifle - CW2.0 MWR - M16A4
battle rifle - Robotnik's CoD4 SWEPs - G3
carbine - CW2.0 MWR - G36C
designated marksman rifle - Mac's CoD MW2 SWEPs - M21 EBR
bolt action rifle - Robotnik's CoD4 SWEPs - R800
sniper rifle - Robotnik's CoD4 SWEPs - M40A3
magnum sniper rifle - Mac's CoD MW2 SWEPs - Intervention
semiautomatic shotgun - Mac's CoD MW2 SWEPs - M1014
pump-action shotgun - Robotnik's CoD4 SWEPs - W1200
break-action shotgun - cod over-under shotty
pistol - Mac's CoD Black Ops II SWEPs - B23R
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
lever-action rifle - 
----------------------------
 - changes to arccw base:
 0) 3DHUD permanently enabled
 1) 3DHUD only shows when reloading or holding reload key or mag is empty, not when firing
 2) ArcCW no longer overrides the health hud
 3) 3DHUD draws a little down and to the left so as not to cover center of screen
 4) crosshair completely disabled
 5) the 3DHUD no longer draws in 3rd person... not sure why it ever did
 6) new var, DamageRand, representing by what fraction each shot's damage will randomly vary
 7) new var, ShootSoundExtraMult, representing how many extra times to play the shoot sound each shot, making it louder
 8) changed EmitSound in PlaySoundTable to sound.Play so that it actually plays instead of skipping
 9) added a debugSights bool to the ironsightsstruct so i can easily adjust ironsight positions
 10) added aim sway, with a new var, AimSwayFactor, allows you to change how much sway there is when aiming the weapon
	- as well as the ability to reduce sway by holding ALT, with breathing control and SFX
	- crouching and ArcCW bipod use also reduces sway
 11) added left-hand view tracking to make reload animations more immersive (DISABLED, NEED TO FIX ANGLE CALCS)
 12) reduced Lerp speed of viewmodel movements by 20%
 13) fixed a bug in sh_deploy 257
 14) added hexed css shells, jhells, with much nicer materials
 15) added an IsFirstTimePredicted() call to sh_firing to prevent gun sounds from earraping during slowmo or lag
 16) new var, ShellEffect, to specify which lua shell effect a weapon should use
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
game.AddAmmoType({
	name = "Light Rifle Round"
})
game.AddAmmoType({
	name = "Medium Rifle Round"
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
if(CLIENT)then
	language.Add("Light Rifle Round_ammo","Light Rifle Round")
	language.Add("Medium Rifle Round_ammo","Medium Rifle Round")
	concommand.Add("jacky_vm_debug",function(ply,cmd,args)
		local VM=ply:GetViewModel()
		print(VM:GetModel())
		for i=0,100 do
			local Info=VM:GetSequenceInfo(i)
			if(Info)then print(i);PrintTable(Info) end
		end
		print("---------------------")
		for i=0,100 do
			local Name=VM:GetBoneName(i)
			if(Name)then print(i);print(Name) end
		end
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