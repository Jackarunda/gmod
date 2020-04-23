
ENT.Type="anim"

ENT.PrintName		= "Explosion"
ENT.Author			= "Jackarunda"

ENT.Spawnable			= false
ENT.AdminSpawnable		= false

if(CLIENT)then
	killicon.Add("entityflame","vgui/killicons/ent_jack_napalmpoint_KI",Color(255,255,255,255))
	killicon.Add("env_fire","vgui/killicons/ent_jack_napalmpoint_KI",Color(255,255,255,255))
	killicon.Add("ent_jack_napalmpoint","vgui/killicons/ent_jack_napalmpoint_KI",Color(255,255,255,255))
	language.Add("ent_jack_napalmpoint","Fire")
	language.Add("env_fire","Fire")
	language.Add("entityflame","Fire")
end