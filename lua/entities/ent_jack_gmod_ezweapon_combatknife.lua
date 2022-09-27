-- Jackarunda 2021
AddCSLuaFile()
ENT.Base = "ent_jack_gmod_ezweapon"
ENT.PrintName = "EZ Combat Knife"
ENT.Spawnable = false -- melee weapon release is delayed
ENT.Category = "JMod - EZ Weapons"
ENT.WeaponName = "Combat Knife"

---
if SERVER then
elseif CLIENT then
	--
	language.Add(ENT.ClassName, ENT.PrintName)
end
