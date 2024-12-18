-- Jackarunda 2021
AddCSLuaFile()
ENT.Base = "ent_jack_gmod_ezgrenade"
ENT.Author = "Jackarunda, TheOnly8Z"
ENT.PrintName = "EZ Frag Grenade"
ENT.Category = "JMod - EZ Explosives"
ENT.Spawnable = true
ENT.JModPreferredCarryAngles = Angle(0, -180, 0)
ENT.Model = "models/jmod/explosives/grenades/fragnade/w_fragjade.mdl"
ENT.Material = "models/mats_jack_nades/gnd"
ENT.SpoonScale = 2
ENT.PinBodygroup = {1, 1}
ENT.SpoonBodygroup = {2, 1}
ENT.DetDelay = 4

if SERVER then
	function ENT:Detonate()
		if self.Exploded then return end
		self.Exploded = true
		local SelfPos = self:GetPos()
		JMod.Sploom(self.EZowner, self:GetPos(), math.random(10, 20), 254)
		self:EmitSound("snd_jack_fragsplodeclose.ogg", 90, 100)
		local plooie = EffectData()
		plooie:SetOrigin(SelfPos)
		plooie:SetScale(.5)
		plooie:SetRadius(1)
		plooie:SetNormal(vector_up)
		util.Effect("eff_jack_minesplode", plooie, true, true)
		util.ScreenShake(SelfPos, 20, 20, 1, 1000)

		local GroundTr = util.QuickTrace(SelfPos + Vector(0, 0, 5), Vector(0, 0, -15), self)

		------------------ shooter, origin, fragNum, fragDmg, fragMaxDist, attacker, direction, spread, zReduction
		if GroundTr.Hit then
			JMod.FragSplosion(self, SelfPos + Vector(0, 0, 10), 1500, 35, 2000, JMod.GetEZowner(self), GroundTr.HitNormal, .6, 10)
		else
			JMod.FragSplosion(self, SelfPos, 2000, 35, 2000, JMod.GetEZowner(self))
		end
		self:Remove()
	end
elseif CLIENT then
	local GlowSprite = Material("sprites/mat_jack_circle")

	function ENT:Draw()
		self:DrawModel()
		-- sprites for calibrating the lethality/casualty radius
		--[[
		local State,Vary=self:GetState(),math.sin(CurTime()*50)/2+.5
		if(State==JMod.EZ_STATE_ARMED)then
			render.SetMaterial(GlowSprite)
			render.DrawSprite(self:GetPos()+Vector(0,0,4),15*52*2,15*52*2,Color(255,0,0,128))
			render.DrawSprite(self:GetPos()+Vector(0,0,4),5*52*2,5*52*2,Color(255,255,255,128))
		end
		--]]
	end

	language.Add("ent_jack_gmod_ezfragnade", "EZ Frag Grenade")
end
