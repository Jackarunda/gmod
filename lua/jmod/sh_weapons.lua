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
--]]
--[[
 - changes to arccw base:
 0) 3DHUD only now lol
 1) 3DHUD only shows when reloading or holding reload key or mag is empty, not when firing
 2) ArcCW no longer overrides the health hud
 3) 3DHUD draws a little down and to the left so as not to cover center of screen
 4) crosshair completely disabled
 5) the 3DHUD no longer draws in 3rd person... not sure why it ever did
 6) new var, DamageRand, representing by what fraction each shot's damage will randomly vary
 7) new var, ShootSoundExtraMult, representing how many extra times to play the shoot sound each shot, making it louder
 8) changed EmitSound in PlaySoundTable to sound.Play so that it actually plays instead of skipping
 9) added a debugSights bool to the ironsightsstruct so i can easily adjust ironsight positions
 --]]
game.AddAmmoType({
	name = "Light Rifle Round"
})
if(CLIENT)then
	concommand.Add("jacky_vm_debug",function(ply,cmd,args)
		for i=0,100 do
			PrintTable(ply:GetViewModel():GetSequenceInfo(i))
		end
	end)
end