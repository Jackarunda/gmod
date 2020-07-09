--[[
assault rifle - CW2.0 MWR - M16A4
battle rifle - Robotnik's CoD4 SWEPs - G3
carbine - CW2.0 MWR - G36C
designated marksman rifle - Mac's CoD MW2 SWEPs - M21 EBR
bolt action rifle - Robotnik's CoD4 SWEPs - R800
sniper rifle - Robotnik's CoD4 SWEPs - M40A3
semiautomatic shotgun - Mac's CoD MW2 SWEPs - M1014
pump-action shotgun - Robotnik's CoD4 SWEPs - W1200 
pistol - Mac's CoD Black Ops II SWEPs - B23R
machine pistol - Mac's Black Ops SWEPs - MAC11
submachine gun - Robotnik's CoD4 SWEPs - MP5
light machine gun - Robotnik's CoD4 SWEPs - M249
medium machine gun - Mac's CoD MW2 SWEPs - M240
revolver - Mac's CoD MW2 SWEPs - .44 Magnum
magnum pistol - Mac's CoD MW2 SWEPs - Desert Eagle
shot revolver - Mac's CoD Black Ops II SWEPs - Executioner
anti-materiel rifle - Mac's CoD MW2 SWEPs - Barret .50 Cal
grenade launcher - Mac's CoD MW2 SWEPs - Thumper
rocket launcher - Mac's CoD MW2 SWEPs - AT4
grenade revolver - Mac's CoD Black Ops II SWEPs - War Machine
crossbow - Mac's CoD Black Ops SWEPs - Crossbow
lever-action rifle - 
break-action shotgun - 
combat knife - 
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
if(CLIENT)then
	language.Add("Light Rifle Round_ammo","Light Rifle Round")
	language.Add("Medium Rifle Round_ammo","Medium Rifle Round")
	concommand.Add("jacky_vm_debug",function(ply,cmd,args)
		local VM=ply:GetViewModel()
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
	local WDir,StabilityStamina,BreathStatus=VectorRand(),100,false
	local function BreatheIn()
		if not(BreathStatus)then
			BreathStatus=true
			surface.PlaySound("snds_jack_gmod/weapons/focus_inhale.wav")
		end
	end
	local function BreatheOut()
		if(BreathStatus)then
			BreathStatus=false
			surface.PlaySound("snds_jack_gmod/weapons/focus_exhale.wav")
		end
	end
	hook.Add("CreateMove","JMod_CreateMove",function(cmd)
		local ply=LocalPlayer()
		if not(ply:Alive())then return end
		local Wep=ply:GetActiveWeapon()
		if((Wep)and(IsValid(Wep))and(Wep.AimSwayFactor)and(ply:KeyDown(IN_ATTACK2)))then
			local Amt,Sporadicness,FT=30*Wep.AimSwayFactor,50,FrameTime()
			if(ply:Crouching())then Amt=Amt*.75 end
			if((Wep.InBipod)and(Wep:InBipod()))then Amt=Amt*.5 end
			if((ply:KeyDown(IN_FORWARD))or(ply:KeyDown(IN_BACK))or(ply:KeyDown(IN_MOVELEFT))or(ply:KeyDown(IN_MOVERIGHT)))then
				Sporadicness=Sporadicness*2
				Amt=Amt*2
			else
				local Key=(JMOD_CONFIG and JMOD_CONFIG.AltFunctionKey) or IN_WALK
				if(ply:KeyDown(Key))then
					StabilityStamina=math.Clamp(StabilityStamina-FT*40,0,100)
					if(StabilityStamina>0)then
						BreatheIn()
						Amt=Amt*.5
					else
						BreatheOut()
					end
				else
					StabilityStamina=math.Clamp(StabilityStamina+FT*30,0,100)
					BreatheOut()
				end
			end
			local S,EAng=.05,cmd:GetViewAngles()
			WDir=(WDir+FT*VectorRand()*Sporadicness):GetNormalized()
			EAng.pitch=math.NormalizeAngle(EAng.pitch+WDir.z*FT*Amt*S)
			EAng.yaw=math.NormalizeAngle(EAng.yaw+WDir.x*FT*Amt*S)
			cmd:SetViewAngles(EAng)
		end
	end)
	--[[
	hook.Add("PostDrawHUD","JMod_PostDrawHUD",function()
		local ply=LocalPlayer()
		if not(ply:Alive())then return end
		local Wep=ply:GetActiveWeapon()
		if((Wep)and(IsValid(Wep))and(Wep.AimSwayFactor)and(ply:KeyDown(IN_ATTACK2)))then
			if not((ply:KeyDown(IN_FORWARD))or(ply:KeyDown(IN_BACK))or(ply:KeyDown(IN_MOVELEFT))or(ply:KeyDown(IN_MOVERIGHT)))then
				local 
			end
		end
	end)
	--]]
end