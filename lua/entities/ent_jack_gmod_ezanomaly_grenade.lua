-- Jackarunda 2021
AddCSLuaFile()
ENT.Base = "ent_jack_gmod_ezgrenade"
ENT.Author = "Jackarunda"
ENT.PrintName = "T H E  G R E N A D E"
ENT.Category = "JMod - EZ Explosives"
ENT.Spawnable = false
ENT.JModPreferredCarryAngles = Angle(0, -140, 0)
ENT.Model = "models/jmodels/explosives/grenades/fragnade/w_fragjade.mdl"
ENT.Material = "models/shiny"
ENT.ModelScale = 3
ENT.SpoonScale = 3
ENT.Mass = 20

local DetonationEffects = {
	balls = {
		col = Color(128, 255, 128),
		func = function(self, pos, owner)
			JMod.Sploom(owner, pos, 10)

			for i = 1, 100 do
				local Nade = ents.Create("sent_ball")
				Nade:SetPos(pos)
				Nade.Owner = owner
				Nade:Spawn()

				timer.Simple(0, function()
					Nade:SetBallSize(math.random(20, 50))
					Nade:GetPhysicsObject():SetVelocity(VectorRand() * math.Rand(10, 300))
				end)
			end
		end
	}, -- b a l l s
	cheese = {
		col = Color(255, 220, 0),
		func = function(self, pos, owner)
			JMod.Sploom(owner, pos, 10)

			for k, v in pairs(ents.FindInSphere(pos, 1000)) do
				if v:IsPlayer() then
					net.Start("JMod_SFX")
					net.WriteString("snds_jack_gmod/cheeseforeveryone.mp3")
					net.Send(v)
				end
			end

			for i = 1, 20 do
				timer.Simple(i / 10 + .1, function()
					for j = 1, 10 do
						local Nade = ents.Create("ent_jack_gmod_ezcheese")
						Nade:SetPos(pos)
						Nade.Owner = owner
						Nade:Spawn()

						timer.Simple(0, function()
							Nade:GetPhysicsObject():SetVelocity(VectorRand() * math.Rand(10, 300) + Vector(0, 0, 1500))
						end)
					end
				end)
			end
		end
	}, -- CHEESE! FOR EVERYONE!
	ravebreak = {
		col = Color(0, 255, 255),
		func = function(self, pos, owner)
			if IsValid(self) then
				self:PoofEffect()
			end

			net.Start("JMod_Ravebreak")
			net.Broadcast()

			for k, v in pairs(player.GetAll()) do
				if v:IsBot() then
					v.JMod_RavebreakStartTime = CurTime() + 2.325
					v.JMod_RavebreakEndTime = CurTime() + 25.5
				end
			end
		end
	}, -- RAVEBREAK!
	-- dude fucking hell yes i love ravebreak
	nope = {
		col = Color(255, 255, 255),
		func = function(self, pos, owner)
			sound.Play("snds_jack_gmod/nope.wav", pos, 100, 100)
			sound.Play("snds_jack_gmod/nope.wav", pos, 100, 100)

			if IsValid(self) then
				self:PoofEffect()
			end

			for k, v in pairs(ents.FindInSphere(pos, 1000)) do
				if v:IsPlayer() then
					v:StripWeapons()
					v:Give("wep_jack_gmod_hands")
					v:SelectWeapon("wep_jack_gmod_hands")
					v:ViewPunch(Angle(0, 30, 0))
					v:EmitSound("physics/body/body_medium_impact_hard6.wav", 50, 100)
				end
			end
		end
	}, -- stop fightin damnit
	fart = {
		col = Color(50, 40, 0),
		func = function(self, pos, owner)
			sound.Play("snds_jack_gmod/sadfart.wav", pos, 100, 100)

			if IsValid(self) then
				self:PoofEffect()
			end
		end
	}, -- sad fart
	cluster = {
		col = Color(128, 128, 128),
		func = function(self, pos, owner)
			JMod.Sploom(owner, pos, 10)

			for i = 1, 5 do
				local Nade = ents.Create("ent_jack_gmod_ezanomaly_grenade")
				Nade:SetPos(pos)
				Nade.Owner = owner
				Nade:Spawn()

				timer.Simple(0, function()
					Nade:GetPhysicsObject():SetVelocity(VectorRand() * math.Rand(10, 1000))
					Nade:Arm()
				end)
			end
		end
	}, -- chaotic neutral
	revenge = {
		col = Color(20, 40, 0),
		func = function(self, pos, owner)
			if not IsValid(self) then
				print("doesn't work without a nade")

				return
			end

			for i = 1, 20 do
				timer.Simple(i / 2, function()
					if IsValid(self) then
						local SelfPos = self:GetPos() + Vector(0, 0, 10)
						local Targets = {}

						for k, v in pairs(ents.FindInSphere(self:GetPos(), 2000)) do
							if v:IsPlayer() or v:IsNPC() then
								local TargPos = v:GetPos() + Vector(0, 0, 30)

								local Tr = util.TraceLine({
									start = self:GetPos(),
									endpos = v:GetShootPos(),
									filter = {self, v}
								})

								if not Tr.Hit then
									table.insert(Targets, (TargPos - SelfPos):GetNormalized())
								end
							end
						end

						local Target = table.Random(Targets)

						if Target then
							self:GetPhysicsObject():SetVelocity(Target * 2000)
						end

						if i == 20 then
							timer.Simple(2, function()
								if IsValid(self) then
									sound.Play("snds_jack_gmod/sadfart.wav", SelfPos, 100, 100)
									self:PoofEffect()
									self:Remove()
								end
							end)
						end
					end
				end)
			end

			return true
		end
	}, -- if you can dodge a grenade you can dodge a dick
	up = {
		col = Color(128, 128, 255),
		func = function(self, pos, owner)
			if IsValid(self) then
				self:PoofEffect()
			end

			for k, v in pairs(ents.FindInSphere(pos, 2000)) do
				if v:IsPlayer() then
					v:SetMoveType(MOVETYPE_WALK)
					v:SetVelocity(Vector(0, 0, math.random(1500, 2000)))
					net.Start("JMod_SFX")
					net.WriteString("snds_jack_gmod/whee.wav")
					net.Send(v)
				elseif v:IsNPC() then
					v:SetVelocity(Vector(0, 0, math.random(1500, 2000)))
				elseif IsValid(v:GetPhysicsObject()) then
					v:GetPhysicsObject():SetVelocity(Vector(0, 0, math.random(1500, 2000)))
				end
			end
		end
	}, -- U P
	knockout = {
		col = Color(239, 163, 112),
		func = function(self, pos, owner)
			if IsValid(self) then
				self:PoofEffect()
			end

			local Cena = math.random(1, 2) == 1 -- otherwise randy orton

			for k, v in pairs(ents.FindInSphere(pos, 1000)) do
				if v:IsPlayer() or v:IsNPC() then
					if v:IsPlayer() then
						net.Start("JMod_SFX")
						net.WriteString((Cena and "snds_jack_gmod/johncena.mp3") or "snds_jack_gmod/ohwatchout.mp3")
						net.Send(v)
					end

					timer.Simple((Cena and 1.9) or 4, function()
						local Dmg = DamageInfo()
						Dmg:SetDamage(1000)
						Dmg:SetDamageType(DMG_CLUB)
						Dmg:SetAttacker(owner)
						Dmg:SetInflictor(game.GetWorld())
						Dmg:SetDamageForce((Cena and Vector(0, 0, -10000000000000000)) or -v:GetForward() * 1000000000000)
						Dmg:SetDamagePosition(v:GetPos())
						v:TakeDamageInfo(Dmg)
					end)
				end
			end
		end
	}, -- AND HIS NAME IS JOHN CENA slithering in oh WATCH OUT WATCH OUT WATCH OUT
	spiders = {
		col = Color(60, 60, 60),
		func = function(self, pos, owner)
			JMod.Sploom(owner, pos, 0)
			sound.Play("snds_jack_gmod/spiders.wav", pos, 100, 100)

			for i = 1, 100 do
				local Nade = ents.Create("npc_headcrab_fast")
				Nade:SetPos(pos + VectorRand() * 10 + Vector(0, 0, 10))
				Nade.Owner = owner
				Nade:Spawn()
				Nade:SetModelScale(math.Rand(.3, .5), 0)
				local col = math.random(0, 50)
				Nade:SetColor(Color(col, col, col))

				timer.Simple(0, function()
					if IsValid(Nade) then
						Nade:SetVelocity(VectorRand() * 1000 + Vector(0, 0, 1000))
					end
				end)
			end
		end
	}, -- SPIDERS AAAAAAAAAAAAAAAAAAAAAAAA
	inferno = {
		col = Color(255, 100, 50),
		func = function(self, pos, owner)
			JMod.Sploom(owner, pos, 0)
			sound.Play("snds_jack_gmod/soldier_firefirefire.wav", pos, 100, 100)
			sound.Play("snds_jack_gmod/soldier_firefirefire.wav", pos, 100, 100)

			for k, v in pairs(ents.FindInSphere(pos, 1000)) do
				if v.Ignite then
					v:Ignite(math.random(5, 30))
				end
			end

			for i = 1, 80 do
				local FireVec = (VectorRand() + Vector(0, 0, .5)):GetNormalized()
				FireVec.z = FireVec.z / 2
				local Flame = ents.Create("ent_jack_gmod_eznapalm")
				Flame:SetPos(pos + Vector(0, 0, 10))
				Flame:SetAngles(FireVec:Angle())
				Flame:SetOwner(owner)
				Flame.Owner = owner
				Flame.SpeedMul = .8
				Flame.Creator = self or game.GetWorld()
				Flame.HighVisuals = false
				Flame:Spawn()
				Flame:Activate()
			end
		end
	}, -- Instant Inferno
	gas = {
		col = Color(128, 255, 128),
		func = function(self, pos, owner)
			JMod.Sploom(owner, pos, 10)

			for i = 1, 200 do
				timer.Simple(math.Rand(0, 1), function()
					local Nade = ents.Create("ent_jack_gmod_ezgasparticle")
					Nade:SetPos(pos)
					Nade.Owner = owner
					Nade:Spawn()

					timer.Simple(0, function()
						Nade:GetPhysicsObject():SetVelocity(VectorRand() * math.random(1, 200))
					end)
				end)
			end
		end
	}, -- g a s
	mines = {
		col = Color(50, 100, 0),
		func = function(self, pos, owner)
			JMod.Sploom(owner, pos, 1)

			for i = 1, 30 do
				local Nade = ents.Create("ent_jack_gmod_ezlandmine")
				Nade:SetPos(pos)
				Nade.Owner = owner
				Nade:Spawn()

				timer.Simple(0, function()
					Nade:GetPhysicsObject():SetVelocity(VectorRand() * math.Rand(10, 2000))

					timer.Simple(math.Rand(0, 4), function()
						if IsValid(Nade) then
							Nade:Arm()
						end
					end)
				end)
			end
		end
	}, -- MINES! FOR EVERYONE!
	frags = {
		col = Color(50, 100, 0),
		func = function(self, pos, owner)
			JMod.Sploom(owner, pos, 1)

			for i = 1, 15 do
				local Nade = ents.Create("ent_jack_gmod_ezfragnade")
				Nade:SetPos(pos)
				Nade.Owner = owner
				Nade:Spawn()

				timer.Simple(0, function()
					Nade:GetPhysicsObject():SetVelocity(VectorRand() * math.Rand(10, 1500))
					Nade.FuzeTimeOverride = math.Rand(2, 6)
					Nade:Arm()
				end)
			end
		end
	}, -- FRAGS! FOR EVERYONE!
	wtfboom = {
		col = Color(200, 0, 0),
		func = function(self, pos, owner)
			if IsValid(self) then
				self:PoofEffect()
			end

			for k, v in pairs(ents.FindInSphere(pos, 2000)) do
				if v:IsPlayer() then
					net.Start("JMod_SFX")
					net.WriteString("snds_jack_gmod/wtfboom.mp3")
					net.Send(v)
				end
			end

			timer.Simple(1.6, function()
				local Whoah = ents.Create("ent_jack_gmod_eznuke_small")
				Whoah:SetPos(pos)
				Whoah.Owner = owner
				Whoah:Spawn()

				timer.Simple(0, function()
					Whoah:Detonate()
				end)
			end)
		end
	}, -- wtf boom
	yee = {
		-- credits for Dr. Lalve
		col = Color(200, 255, 0),
		func = function(self, pos, owner)
			if IsValid(self) then
				self:PoofEffect()
			end

			for i = 1, 30 do
				timer.Simple(math.Rand(0, 1), function()
					local Engie = ents.Create("npc_jack_gmod_tinydeskengineer")
					Engie:SetPos(pos + VectorRand() * 50)
					Engie.Owner = owner
					Engie:Spawn()
					Engie:Activate()
				end)
			end
		end
	}, -- YEEEEEEEEEEEEEEEEEEEEEEEEE
	succ = {
		col = Color(0, 0, 0),
		func = function(self, pos, owner)
			JMod.Sploom(owner, pos, 10)
			local Whoah = ents.Create("ent_jack_gmod_ezblackhole")
			Whoah:SetPos(pos)
			Whoah.Owner = owner
			Whoah:Spawn()
		end
	}, -- SUCC
	tsarbomba = {
		col = Color(150, 0, 0),
		func = function(self, pos, owner)
			JMod.Sploom(owner, pos, 10)
			local Whoah = ents.Create("ent_jack_gmod_eznuke_big")
			Whoah:SetPos(pos)
			Whoah.Owner = owner
			Whoah:Spawn()

			timer.Simple(0, function()
				Whoah:Detonate()
			end)
		end
	}, -- tsar bomba
	oof = {
		col = Color(10, 10, 10),
		func = function(self, pos, owner)
			if IsValid(self) then
				self:PoofEffect()
			end

			for k, v in pairs(player.GetAll()) do
				v:KillSilent()
			end

			timer.Simple(0, function()
				game.CleanUpMap()

				timer.Simple(0, function()
					net.Start("JMod_SFX")
					net.WriteString("snds_jack_gmod/oof.wav")
					net.Broadcast()

					for k, v in pairs(player.GetAll()) do
						v:ScreenFade(SCREENFADE.IN, Color(255, 255, 255, 255), 1, 0)
					end
				end)
			end)
		end
	}, -- T H E   B I G   O O F
	damnitgarry = {
		col = Color(255, 255, 0),
		func = function(self, pos, owner)
			if IsValid(self) then
				self:PoofEffect()
			end

			net.Start("JMod_SFX")
			net.WriteString("snds_jack_gmod/windowsfuckup.mp3")
			net.Broadcast()

			timer.Simple(3.8, function()
				for k, v in pairs(ents.GetAll()) do
					local CanModel = v.SetModel and v.GetPhysicsObject and IsValid(v:GetPhysicsObject()) and not v:IsWorld()
					local CanMaterial = v.SetMaterial and not v:IsWorld()

					if string.find(v:GetClass(), "func_") then
						CanModel = false
					end

					if math.random(1, 2) == 2 then
						if CanMaterial then
							v:SetColor(Color(255, 255, 255))
							v:SetMaterial("models/missingtexture")
							v.JackyMatDeathUnset = true
						elseif CanModel then
							v:SetColor(Color(255, 255, 255))
							v:SetMaterial("")
							v:SetModel("models/error.mdl")
						end
					else
						if CanModel then
							v:SetColor(Color(255, 255, 255))
							v:SetMaterial("")
							v:SetModel("models/error.mdl")
						elseif CanMaterial then
							v:SetColor(Color(255, 255, 255))
							v:SetMaterial("models/missingtexture")
							v.JackyMatDeathUnset = true
						end
					end
				end
			end)
		end
	} -- damnit garry
	
}

ENT.DetonationEffects = {}

for k, v in pairs(DetonationEffects) do
	table.insert(ENT.DetonationEffects, v)
end

if SERVER then
	function ENT:Arm()
		self:SetBodygroup(2, 1)
		self:SetState(JMod.EZ_STATE_ARMED)
		self:SpoonEffect()

		timer.Simple(math.Rand(1, 20), function()
			if IsValid(self) then
				self:Detonate()
			end
		end)

		self.StopIt = true
	end

	function ENT:SpoonEffect()
		if self.SpoonEnt then
			local Spewn = ents.Create(self.SpoonEnt)

			if self.SpoonModel then
				Spewn.Model = self.SpoonModel
			end

			if self.SpoonScale then
				Spewn.ModelScale = self.SpoonScale
			end

			if self.SpoonSound then
				Spewn.Sound = self.SpoonSound
			end

			Spewn:SetPos(self:GetPos())
			Spewn:Spawn()
			Spewn:SetMaterial(self.Material)
			Spewn:SetColor(self:GetColor())
			Spewn:GetPhysicsObject():SetVelocity(self:GetPhysicsObject():GetVelocity() + VectorRand() * 250)
			self:EmitSound("snd_jack_spoonfling.wav", 60, math.random(80, 100))
		end
	end

	function ENT:CustomThink(state, tim)
		-- that means we just spawned
		if not self.CurEff then
			self.CurEff = math.random(1, #self.DetonationEffects)
			self:SetColor(self.DetonationEffects[self.CurEff].col)
			self.NextEffSwitch = tim + .7
		elseif self.NextEffSwitch < tim then
			if self.StopIt then return end
			self.NextEffSwitch = tim + .7
			self.CurEff = self.CurEff + 1

			if self.CurEff > #self.DetonationEffects then
				self.CurEff = 1
			end

			self:SetColor(self.DetonationEffects[self.CurEff].col)
		end
	end

	function ENT:Detonate()
		--self.CurEff=16 -- DEBUG
		local pos = self:GetPos() + Vector(0, 0, 10)
		local NoRemove = self.DetonationEffects[self.CurEff].func(self, pos, self.Owner or self:GetOwner() or game.GetWorld())

		if not NoRemove then
			self:Remove()
		end
	end

	function ENT:PoofEffect(pos, scl)
		local eff = EffectData()
		eff:SetOrigin((pos or self:GetPos()) + VectorRand())
		eff:SetScale(scl or .5)
		util.Effect("eff_jack_gmod_ezbuildsmoke", eff, true, true)
	end

	-- concommands for convenience
	concommand.Add("jacky_ravebreak", function(ply, cmd, args)
		if not ply:IsSuperAdmin() then return end
		net.Start("JMod_Ravebreak")
		net.Broadcast()

		for k, v in pairs(player.GetAll()) do
			if v:IsBot() then
				v.JMod_RavebreakStartTime = CurTime() + 2.325
				v.JMod_RavebreakEndTime = CurTime() + 25.5
			end
		end
	end)

	concommand.Add("jacky_crazy_effect", function(ply, cmd, args)
		if not ply:IsSuperAdmin() then return end
		local effName = args[1]

		if not DetonationEffects[effName] then
			print("not a valid effect")
			print("the names are:")

			for k, v in pairs(DetonationEffects) do
				print(k)
			end

			return
		end

		local self, pos, owner = nil, ply:GetShootPos() + ply:GetAimVector() * 100, ply
		DetonationEffects[effName].func(self, pos, owner)
	end)
elseif CLIENT then
	function ENT:Draw()
		self:DrawModel()
	end

	language.Add("ent_jack_gmod_ezanomaly_grenade", "T H E  G R E N A D E")
end
