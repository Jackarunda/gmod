AddCSLuaFile()
ENT.Type 			= "anim"
ENT.PrintName		= "J.I. Roller Bomb"
ENT.Author			= "Jackarunda"
ENT.Information	="This is a Combine rollermine taken and modified by JI. It can detect and pursue at greater distances \nthan a standard rollermine, is friendly toward humans, and has its shock core replaced with a simple HE \nwarhead. It will attempt to approach enemies and detonate. It will not detonate if it can see friendlies \nwithin its blast radius and will emit a warning sound to try to clear the area. Hold E to spawn with \naltered allegiances."
ENT.Category		= "JMod - LEGACY NPCs"

ENT.Spawnable		= true
ENT.AdminSpawnable	= true
if(SERVER)then
	function ENT:SpawnFunction(ply, tr)

		local selfpos=tr.HitPos+tr.HitNormal*16
		
		local HostileRoller=false
		if(ply:KeyDown(IN_USE))then HostileRoller=true end
		
		local roller=ents.Create("npc_rollermine")
		roller:SetPos(selfpos+Vector(0,0,20))
		//roller:SetKeyValue("spawnflags","65794") --256+65536=65792
		//roller:SetKeyValue("startburied","1")
		roller:SetKeyValue("uniformsightdist","1")
		roller.IsAJIRollermine=true
		roller.HasAThickMetalCasing=true
		roller:Spawn()
		roller:Activate()
		roller:SetMaterial("models/rollerbomb_sheet")
		roller:SetKeyValue("WakeSquad","1")
		roller:SetKeyValue("IgnoreUnseenEnemies","0")
		
		JackyAlterAllegiances(roller,!HostileRoller)
		
		roller.JackaRollerBomb=true
		
		local function Hego(roll,dir,force)
			local Center=roll:LocalToWorld(roll:OBBCenter())
			roll:GetPhysicsObject():ApplyForceOffset(dir*force*1.25,Center+Vector(0,0,10))
			roll:GetPhysicsObject():ApplyForceOffset(-dir*force,Center+Vector(0,0,-10))
		end
		
		local timername="SplodeRoller"..roller:EntIndex()
		timer.Create(timername,0.1,0,function()
			if not(IsValid(roller))then timer.Destroy(timername) return end
			local Enemie=roller:GetEnemy()
			if(IsValid(Enemie))then
				if not(Enemie:Health()<=0)then
					local selfpos=roller:GetPos()
					local enempos=Enemie:GetPos()
					local dist=(selfpos-enempos):Length()
					if(dist<250)then
						local DangerClose=false
						for key,found in pairs(ents.FindInSphere(selfpos,950))do
							if((found:IsNPC())or(found:IsPlayer()))then
								if not(found==roller)then
									if(found:Visible(roller))then
										local Disp=roller:Disposition(found)
										if(Disp==D_LI)then DangerClose=true;break end
									end
								end
							end
						end
						if not(DangerClose)then
							local tracdat={}
							tracdat.start=selfpos+Vector(0,0,10)
							tracdat.endpos=enempos+Vector(0,0,10)
							tracdat.filter={roller,Enemie}
							local trac=util.TraceLine(tracdat)
							if not(trac.Hit)then
								local Kableweh=EffectData()
								Kableweh:SetOrigin(selfpos)
								Kableweh:SetScale(4)
								util.Effect("eff_jack_gmod_rollersplode",Kableweh)
								util.BlastDamage(roller,roller,selfpos,900,500)
								roller:EmitSound("weapons/explode4.wav")
								sound.Play("BaseExplosionEffect.Sound",selfpos)
								sound.Play("ambient/explosions/explode_8.wav",selfpos,100,100)
								--umsg.Start("Jacky'sRollerSplosionFlashUserMessage")
								--	umsg.Entity(roller)
								--	umsg.Vector(selfpos)
								--umsg.End()
								util.ScreenShake(selfpos,99999,99999,1.5,1500)
								for i=0,5 do
									local cake=util.QuickTrace(selfpos,VectorRand()*200,roller)
									if(cake.Hit)then
										util.Decal("Scorch",cake.HitPos+cake.HitNormal,cake.HitPos-cake.HitNormal)
									end
								end
								roller:Remove()
							end
						else
							roller:Fire("turnoff","",0)
							roller:EmitSound("snds_jack_gmod/rolleralert.mp3")
							for k,other in pairs(ents.FindInSphere(roller:GetPos(),1250))do
								if((other.JackaRollerBomb)and not(other==roller))then
									local Dir=(other:GetPos()-roller:GetPos()):GetNormalized()
									Hego(other,Dir,7500)
								end
							end
						end
					else
						roller:Fire("turnon","",0)
						roller:GetPhysicsObject():Wake()
					end
				end
			else
				roller:Fire("turnon","",0)
				roller:GetPhysicsObject():Wake()
			end
		end)
		
		local timername="BeepRoller"..roller:EntIndex()
		timer.Create(timername,1.75,0,function()
			if not(IsValid(roller))then timer.Destroy(timername) return end
			local hackpos=roller:GetPos()
			if not(IsValid(roller:GetEnemy()))then
				roller:EmitSound("snds_jack_gmod/search.wav",50,100)
			end
			local Force=true
			for key,found in pairs(ents.FindByClass("npc_*"))do
				local enemypos=found:GetPos()
				if(roller:Disposition(found)==D_HT)then
					if not(IsValid(roller:GetEnemy()))then
						if(found:Visible(roller))then
							roller:SetTarget(found)
							roller:UpdateEnemyMemory(found,enemypos)
							if(Force)then
								Force=false
								local Dir=(enemypos-roller:GetPos()):GetNormalized()
								Hego(roller,Dir,30000)
							end
						end
					end
				end
			end
		end)
		
		local effectdata=EffectData()
		effectdata:SetEntity(roller)
		--util.Effect("propspawn",effectdata)
		
		timer.Simple(0.05,function()
			undo.Create("JackieRollerBomb")
				if(IsValid(roller))then undo.AddEntity(roller) end
				undo.SetCustomUndoText("Undone JI RollerMine.")
				undo.SetPlayer(ply)
			undo.Finish()
		end)
		
	end

	/*----------------------------------------------------------------------------------
		This creates the shit for a destroyed hack
	----------------------------------------------------------------------------------*/
	function Burst(npc,attacker,inflictor)
		if(npc.IsAJIRollermine)then
			local roller=npc
			local selfpos=roller:GetPos()
			local Kableweh=EffectData()
			Kableweh:SetOrigin(selfpos)
			Kableweh:SetScale(4)
			util.Effect("eff_jack_gmod_rollersplode",Kableweh)
			util.BlastDamage(roller,roller,selfpos,900,500)
			roller:EmitSound("weapons/explode4.wav")
			sound.Play("BaseExplosionEffect.Sound",selfpos)
			sound.Play("ambient/explosions/explode_8.wav",selfpos,100,100)
			umsg.Start("Jacky'sRollerSplosionFlashUserMessage")
				umsg.Entity(roller)
				umsg.Vector(selfpos)
			umsg.End()
			util.ScreenShake(selfpos,99999,99999,1.5,1500)
			for i=0,5 do
				local cake=util.QuickTrace(selfpos,VectorRand()*200,roller)
				if(cake.Hit)then
					util.Decal("Scorch",cake.HitPos+cake.HitNormal,cake.HitPos-cake.HitNormal)
				end
			end
		end
	end
	hook.Add("OnNPCKilled","JIRollerBombDeath",Burst)
elseif(CLIENT)then
	--[[------------------------------------------------------------
		Jackarunda's epic win environment-lighting splodeflashes			-- ahh i remember "epic win" like it was yesterday
	--------------------------------------------------------------]]
	function SplodeFlash(data)
		local vector=data:ReadVector()
		local entity=data:ReadEntity()
		local index
		if(entity:IsNPC())then
			index=data:ReadEntity():EntIndex()
		else
			index=data:ReadEntity():EntIndex()+1
		end
		local dlight=DynamicLight(index)
		if(dlight)then
			dlight.Pos=vector
			dlight.r=255
			dlight.g=200
			dlight.b=175
			dlight.Brightness=5
			dlight.Size=2000
			dlight.Decay=5000
			dlight.DieTime=CurTime()+0.05
			dlight.Style=0
		end
	end
	usermessage.Hook("Jacky'sRollerSplosionFlashUserMessage",SplodeFlash)
end