
ENT.Type="anim"

ENT.PrintName		= "Small-Medium Shrapnel Explosion"
ENT.Author			= "Jackarunda"

ENT.Spawnable			= false
ENT.AdminSpawnable		= false

if(CLIENT)then
	killicon.Add("ent_jack_fragsplosion","vgui/killicons/ent_jack_fraggrenade_KI",Color(255,255,255,255))
	language.Add("ent_jack_smallshrapnelsplosion","Shrapnel")
end