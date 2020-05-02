function JMod_AeroDrag(ent,forward,mult) -- this causes an object to rotate to point forward while moving, like a dart
    if(constraint.HasConstraints(ent))then return end
    if(ent:IsPlayerHolding())then return end
    local Phys=ent:GetPhysicsObject()
    local Vel=Phys:GetVelocity()
    local Spd=Vel:Length()
    if(Spd<300)then return end
    mult=mult or 1
    local Pos,Mass=Phys:LocalToWorld(Phys:GetMassCenter()),Phys:GetMass()
    Phys:ApplyForceOffset(Vel*Mass/6*mult,Pos+forward)
    Phys:ApplyForceOffset(-Vel*Mass/6*mult,Pos-forward)
    Phys:AddAngleVelocity(-Phys:GetAngleVelocity()*Mass/1000)
end

function JMod_AeroGuide(ent,forward,targetPos,turnMult,thrustMult,angleDragMult,spdReq) -- this causes an object to rotate to point and fly to a point you give it
    --if(constraint.HasConstraints(ent))then return end
    --if(ent:IsPlayerHolding())then return end
    local Phys=ent:GetPhysicsObject()
    local Vel=Phys:GetVelocity()
    local Spd=Vel:Length()
    --if(Spd<spdReq)then return end
    local Pos,Mass=Phys:LocalToWorld(Phys:GetMassCenter()),Phys:GetMass()
    local TargetVec=targetPos-ent:GetPos()
    local TargetDir=TargetVec:GetNormalized()
    ---
    Phys:ApplyForceOffset(TargetDir*Mass*turnMult*5000,Pos+forward)
    Phys:ApplyForceOffset(-TargetDir*Mass*turnMult*5000,Pos-forward)
    Phys:AddAngleVelocity(-Phys:GetAngleVelocity()*angleDragMult*3)
    --- todo: fuck
    Phys:ApplyForceCenter(forward*20000*thrustMult) -- todo: make this function fucking work ARGH
end

function JMod_EZ_Toggle_Mask(ply)
    if not(ply.EZarmor)then return end
    if not(ply.EZarmor.slots["Face"])then return end
    if not(ply:Alive())then return end
    ply:EmitSound("snds_jack_gmod/equip1.wav",60,math.random(80,120))
    ply.EZarmor.maskOn=not ply.EZarmor.maskOn
    local ExtraEquipSound=JMod_ArmorTable["Face"][ply.EZarmor.slots["Face"][1]].eqsnd
    if((ply.EZarmor.maskOn)and(ExtraEquipSound))then
        ply:EmitSound(ExtraEquipSound,50,math.random(80,120))
    end
    JModEZarmorSync(ply)
end

function JMod_EZ_Toggle_Headset(ply)
    if not(ply.EZarmor)then return end
    if not(ply.EZarmor.slots["Ears"])then return end
    if not(ply:Alive())then return end
    ply:EmitSound("snds_jack_gmod/equip2.wav",60,math.random(80,120))
    ply.EZarmor.headsetOn=not ply.EZarmor.headsetOn
    JModEZarmorSync(ply)
end

function JMod_EZ_WeaponLaunch(ply)
    if not((IsValid(ply))and(ply:Alive()))then return end
    local Weps={}
    for k,ent in pairs(ents.GetAll())do
        if((ent.EZlaunchableWeaponArmedTime)and(ent.Owner)and(ent.Owner==ply)and(ent:GetState()==1))then
            table.insert(Weps,ent)
        end
    end
    local FirstWep,Earliest=nil,9e9
    for k,wep in pairs(Weps)do
        if(wep.EZlaunchableWeaponArmedTime<Earliest)then
            FirstWep=wep
            Earliest=wep.EZlaunchableWeaponArmedTime
        end
    end
    if(IsValid(FirstWep))then
        -- knock knock it's pizza time
        FirstWep:EmitSound("buttons/button6.wav",75,110)
        timer.Simple(.2,function()
            if(IsValid(FirstWep))then FirstWep:Launch() end
        end)
    end
end

function JMod_EZ_BombDrop(ply)
    if not((IsValid(ply))and(ply:Alive()))then return end
    local Boms={}
    for k,ent in pairs(ents.GetAll())do
        if((ent.EZdroppableBombArmedTime)and(ent.Owner)and(ent.Owner==ply))then
            table.insert(Boms,ent)
        end
    end
    local FirstBom,Earliest=nil,9e9
    for k,bom in pairs(Boms)do
        if((bom.EZdroppableBombArmedTime<Earliest)and((constraint.HasConstraints(bom))or not(bom:GetPhysicsObject():IsMotionEnabled())))then
            FirstBom=bom
            Earliest=bom.EZdroppableBombArmedTime
        end
    end
    if(IsValid(FirstBom))then
        -- knock knock it's pizza time
        FirstBom:EmitSound("buttons/button6.wav",75,80)
        timer.Simple(.5,function()
            if(IsValid(FirstBom))then
                constraint.RemoveAll(FirstBom)
                FirstBom:GetPhysicsObject():EnableMotion(true)
                FirstBom:GetPhysicsObject():Wake()
            end
        end)
    end
end

-- copied from Homicide
function JMod_BlastThatDoor(ent,vel)
    local Moddel,Pozishun,Ayngul,Muteeriul,Skin=ent:GetModel(),ent:GetPos(),ent:GetAngles(),ent:GetMaterial(),ent:GetSkin()
    sound.Play("Wood_Crate.Break",Pozishun,60,100)
    sound.Play("Wood_Furniture.Break",Pozishun,60,100)
    ent:Fire("open","",0)
    ent:SetNoDraw(true)
    ent:SetNotSolid(true)
    if((Moddel)and(Pozishun)and(Ayngul))then
        local Replacement=ents.Create("prop_physics")
        Replacement:SetModel(Moddel);Replacement:SetPos(Pozishun+Vector(0,0,1))
        Replacement:SetAngles(Ayngul)
        if(Muteeriul)then Replacement:SetMaterial(Muteeriul) end
        if(Skin)then Replacement:SetSkin(Skin) end
        Replacement:SetModelScale(.9,0)
        Replacement:Spawn()
        Replacement:Activate()
        if(vel)then Replacement:GetPhysicsObject():SetVelocity(vel) end
        timer.Simple(3,function()
            if(IsValid(Replacement))then Replacement:SetCollisionGroup(COLLISION_GROUP_WEAPON) end
        end)
        timer.Simple(30*JMOD_CONFIG.DoorBreachResetTimeMult,function()
            if(IsValid(ent))then ent:SetNotSolid(false);ent:SetNoDraw(false) end
            if(IsValid(Replacement))then Replacement:Remove() end
        end)
    end
end

function JMod_FragSplosion(shooter,origin,fragNum,fragDmg,fragMaxDist,attacker,direction,spread,zReduction)
    -- fragmentation/shrapnel simulation
    local Eff=EffectData()
    Eff:SetOrigin(origin)
    Eff:SetScale(fragNum)
    Eff:SetNormal(direction or Vector(0,0,0))
    Eff:SetMagnitude(spread or 0)
    util.Effect("eff_jack_gmod_fragsplosion",Eff,true,true)
    ---
    shooter=shooter or game.GetWorld()
    if not(JMOD_CONFIG.FragExplosions)then
        util.BlastDamage(shooter,attacker,origin,fragDmg*8,fragDmg*3)
        return
    end
    local Spred=Vector(0,0,0)
    local BulletsFired,MaxBullets,disperseTime=0,300,.5
    if(fragNum>=12000)then disperseTime=2 elseif(fragNum>=6000)then disperseTime=1 end
    for i=1,fragNum do
        timer.Simple((i/fragNum)*disperseTime,function()
            local Dir
            if((direction)and(spread))then
                Dir=Vector(direction.x,direction.y,direction.z)
                Dir=Dir+VectorRand()*math.Rand(0,spread)
                Dir:Normalize()
            else
                Dir=VectorRand()
            end
            if(zReduction)then
                Dir.z=Dir.z/zReduction
                Dir:Normalize()
            end
            local Tr=util.QuickTrace(origin,Dir*fragMaxDist,shooter)
            if((Tr.Hit)and not(Tr.HitSky)and not(Tr.HitWorld)and(BulletsFired<MaxBullets))then
                local DmgMul=1
                if(BulletsFired>200)then DmgMul=2 end
                local firer=((IsValid(shooter))and shooter) or game.GetWorld()
                firer:FireBullets({
                    Attacker=attacker,
                    Damage=fragDmg*DmgMul,
                    Force=fragDmg/8*DmgMul,
                    Num=1,
                    Src=origin,
                    Tracer=0,
                    Dir=Dir,
                    Spread=Spred
                })
                BulletsFired=BulletsFired+1
            end
        end)
    end
end

function JMod_PackageObject(ent,pos,ang,ply)
    if(pos)then
        ent=ents.Create(ent)
        ent:SetPos(pos)
        ent:SetAngles(ang)
        if(ply)then
            JMod_Owner(ent,ply)
        end
        ent:Spawn()
        ent:Activate()
    end
    local Bocks=ents.Create("ent_jack_gmod_ezcompactbox")
    Bocks:SetPos(ent:LocalToWorld(ent:OBBCenter())+Vector(0,0,20))
    Bocks:SetAngles(ent:GetAngles())
    Bocks:SetContents(ent)
    if(ply)then
        JMod_Owner(Bocks,ply)
    end
    Bocks:Spawn()
    Bocks:Activate()
end

function JMod_SimpleForceExplosion(pos,power,range,sourceEnt)
    for k,v in pairs(ents.FindInSphere(pos,range))do
        if(not(IsValid(sourceEnt))or(v~=sourceEnt))then
            local Phys=v:GetPhysicsObject()
            if(IsValid(Phys))then
                local EntPos=v:LocalToWorld(v:OBBCenter())
                local Tr=util.TraceLine({start=pos,endpos=EntPos,filter={sourceEnt,v}})
                if not(Tr.Hit)then
                    local DistFrac=(1-(EntPos:Distance(pos)/range))^2
                    local Force=power*DistFrac
                    if((v:IsNPC())or(v:IsPlayer()))then
                        v:SetVelocity((EntPos-pos):GetNormalized()*Force/500)
                    else
                        Phys:ApplyForceCenter((EntPos-pos):GetNormalized()*Force*Phys:GetMass()^.25/2)
                    end
                end
            end
        end
    end
end

function JMod_DecalSplosion(pos,decalName,range,num,sourceEnt)
    for i=1,num do
        local Dir=VectorRand()*math.random(1,range)
        Dir.z=-math.abs(Dir.z)/6
        local Tr=util.QuickTrace(pos,Dir,sourceEnt)
        if(Tr.Hit)then
            util.Decal(decalName,Tr.HitPos+Tr.HitNormal,Tr.HitPos-Tr.HitNormal)
        end
    end
end

function JMod_BlastDamageIgnoreWorld(pos,att,infl,dmg,range)
    for k,v in pairs(ents.FindInSphere(pos,range))do
        local EntPos=v:GetPos()
        local Vec=EntPos-pos
        local Dir=Vec:GetNormalized()
        local DistFrac=1-(Vec:Length()/range)
        local Dmg=DamageInfo()
        Dmg:SetDamage(dmg*DistFrac)
        Dmg:SetDamageForce(Dir*1e5*DistFrac)
        Dmg:SetDamagePosition(EntPos)
        Dmg:SetAttacker(att or game.GetWorld())
        Dmg:SetInflictor(infl or att or game.GetWorld())
        Dmg:SetDamageType(DMG_BLAST)
        v:TakeDamageInfo(Dmg)
    end
end

local WreckBlacklist={"gmod_lamp","gmod_cameraprop","gmod_light"}
function JMod_WreckBuildings(blaster,pos,power,range,ignoreVisChecks)
    local origPower=power
    power=power*JMOD_CONFIG.ExplosionPropDestroyPower
    local maxRange=250*power*(range or 1) -- todo: this still doesn't do what i want for the nuke
    local maxMassToDestroy=10*power^.8
    local masMassToLoosen=30*power
    local allProps = ents.FindInSphere(pos,maxRange)
    for k,prop in pairs(allProps)do
		if not(table.HasValue(WreckBlacklist,prop:GetClass()))then
			local physObj=prop:GetPhysicsObject()
			local propPos=prop:LocalToWorld(prop:OBBCenter())
			local DistFrac=(1-propPos:Distance(pos)/maxRange)
			local myDestroyThreshold=DistFrac*maxMassToDestroy
			local myLoosenThreshold=DistFrac*masMassToLoosen
			if(DistFrac>=.85)then myDestroyThreshold=myDestroyThreshold*7;myLoosenThreshold=myLoosenThreshold*7 end
			if((prop~=blaster)and(physObj:IsValid()))then
				local mass,proceed=physObj:GetMass(),ignoreVisChecks
				if not(proceed)then
					local tr=util.QuickTrace(pos,propPos-pos,blaster)
					proceed=((IsValid(tr.Entity))and(tr.Entity==prop))
				end
				if(proceed)then
					if(mass<=myDestroyThreshold)then
						SafeRemoveEntity(prop)
					elseif(mass<=myLoosenThreshold)then
						physObj:EnableMotion(true)
						constraint.RemoveAll(prop)
						physObj:ApplyForceOffset((propPos-pos):GetNormalized()*1000*DistFrac*power*mass,propPos+VectorRand()*10)
					else
						physObj:ApplyForceOffset((propPos-pos):GetNormalized()*1000*DistFrac*origPower*mass,propPos+VectorRand()*10)
					end
				end
			end
		end
    end
end

function JMod_BlastDoors(blaster,pos,power,range,ignoreVisChecks)
    for k,door in pairs(ents.FindInSphere(pos,40*power*(range or 1)))do
        if(JMod_IsDoor(door))then
            local proceed=ignoreVisChecks
            if not(proceed)then
                local tr=util.QuickTrace(pos,door:LocalToWorld(door:OBBCenter())-pos,blaster)
                proceed=((IsValid(tr.Entity))and(tr.Entity==door))
            end
            if(proceed)then
                JMod_BlastThatDoor(door,(door:LocalToWorld(door:OBBCenter())-pos):GetNormalized()*1000)
            end
        end
    end
end

function JMod_Sploom(attacker,pos,mag)
    local Sploom=ents.Create("env_explosion")
    Sploom:SetPos(pos)
    Sploom:SetOwner(attacker or game.GetWorld())
    Sploom:SetKeyValue("iMagnitude",mag)
    Sploom:Spawn()
    Sploom:Activate()
    Sploom:Fire("explode","",0)
end

local SurfaceHardness={
    [MAT_METAL]=.95,[MAT_COMPUTER]=.95,[MAT_VENT]=.95,[MAT_GRATE]=.95,[MAT_FLESH]=.5,[MAT_ALIENFLESH]=.3,
    [MAT_SAND]=.1,[MAT_DIRT]=.3,[MAT_GRASS]=.2,[74]=.1,[85]=.2,[MAT_WOOD]=.5,[MAT_FOLIAGE]=.5,
    [MAT_CONCRETE]=.9,[MAT_TILE]=.8,[MAT_SLOSH]=.05,[MAT_PLASTIC]=.3,[MAT_GLASS]=.6
}
function JMod_RicPenBullet(ent,pos,dir,dmg,doBlasts,wreckShit,num,penMul,tracerName,callback) -- Slayer Ricocheting/Penetrating Bullets FTW
    if not(IsValid(ent))then return end
    if((num)and(num>10))then return end
    local Attacker=ent.Owner or ent or game.GetWorld()
    ent:FireBullets({
        Attacker=Attacker,
        Damage=dmg,
        Force=dmg,
        Num=1,
        Tracer=1,
        TracerName=tracerName or "",
        Dir=dir,
        Spread=Vector(0,0,0),
        Src=pos,
        Callback=callback or nil
    })
    local initialTrace=util.TraceLine({
        start=pos,
        endpos=pos+dir*50000,
        filter={ent}
    })
    if not(initialTrace.Hit)then return end
    local AVec,IPos,TNorm,SMul=initialTrace.Normal,initialTrace.HitPos,initialTrace.HitNormal,SurfaceHardness[initialTrace.MatType]
    if(doBlasts)then
        util.BlastDamage(ent,Attacker,IPos+TNorm*2,dmg/3,dmg/4)
        timer.Simple(0,function()
            local Tr=util.QuickTrace(IPos+TNorm,-TNorm*20)
            if(Tr.Hit)then util.Decal("FadingScorch",Tr.HitPos+Tr.HitNormal,Tr.HitPos-Tr.HitNormal) end
        end)
    end
    if((wreckShit)and not(initialTrace.HitWorld))then
        local Phys=initialTrace.Entity:GetPhysicsObject()
        if((IsValid(Phys))and(Phys.GetMass))then
            local Mass,Thresh=Phys:GetMass(),dmg/2
            if(Mass<=Thresh)then
                constraint.RemoveAll(initialTrace.Entity)
                Phys:EnableMotion(true)
                Phys:Wake()
                Phys:ApplyForceOffset(-AVec*dmg*2,IPos)
            end
        end
    end
    ---
    if not(SMul)then SMul=.5 end
    local ApproachAngle=-math.deg(math.asin(TNorm:DotProduct(AVec)))
    local MaxRicAngle=60*SMul
    if(ApproachAngle>(MaxRicAngle*1.05))then -- all the way through (hot)
        local MaxDist,SearchPos,SearchDist,Penetrated=(dmg/SMul)*.15*(penMul or 1),IPos,5,false
        while((not(Penetrated))and(SearchDist<MaxDist))do
            SearchPos=IPos+AVec*SearchDist
            local PeneTrace=util.QuickTrace(SearchPos,-AVec*SearchDist)
            if((not(PeneTrace.StartSolid))and(PeneTrace.Hit))then
                Penetrated=true
            else
                SearchDist=SearchDist+5
            end
        end
        if(Penetrated)then
            ent:FireBullets({
                Attacker=Attacker,
                Damage=1,
                Force=1,
                Num=1,
                Tracer=0,
                TracerName="",
                Dir=-AVec,
                Spread=Vector(0,0,0),
                Src=SearchPos+AVec
            })
            if(doBlasts)then
                util.BlastDamage(ent,Attacker,SearchPos+AVec*2,dmg/2,dmg/4)
                timer.Simple(0,function()
                    local Tr=util.QuickTrace(SearchPos+AVec,-AVec*20)
                    if(Tr.Hit)then util.Decal("FadingScorch",Tr.HitPos+Tr.HitNormal,Tr.HitPos-Tr.HitNormal) end
                end)
            end
            local ThroughFrac=1-SearchDist/MaxDist
            JMod_RicPenBullet(ent,SearchPos+AVec,AVec,dmg*ThroughFrac*.7,doBlasts,wreckShit,(num or 0)+1,penMul,tracerName,callback)
        end
    elseif(ApproachAngle<(MaxRicAngle*.95))then -- ping whiiiizzzz
        if(SERVER)then sound.Play("snds_jack_gmod/ricochet_"..math.random(1,2)..".wav",IPos,60,math.random(90,100)) end
        local NewVec=AVec:Angle()
        NewVec:RotateAroundAxis(TNorm,180)
        NewVec=NewVec:Forward()
        JMod_RicPenBullet(ent,IPos+TNorm,-NewVec,dmg*.7,doBlasts,wreckShit,(num or 0)+1,penMul,tracerName,callback)
    end
end
function JMod_Owner(ent,newOwner)
    if not(IsValid(ent))then return end
    if not(IsValid(newOwner))then newOwner=game.GetWorld() end
    local OldOwner=ent.Owner
    if((OldOwner)and(OldOwner==newOwner))then return end
    ent.Owner=newOwner
    if not(CPPI)then return end
    if(ent.CPPISetOwner)then ent:CPPISetOwner(newOwner) end
end
function JMod_ShouldAllowControl(self,ply)
    if not(IsValid(ply))then return false end
    if not(IsValid(self.Owner))then return false end
    if(ply==self.Owner)then return true end
    local Allies=self.Owner.JModFriends or {}
    if(table.HasValue(Allies,ply))then return true end
    if(engine.ActiveGamemode()=="sandbox")then return false end
    return ply:Team()==self.Owner:Team()
end
function JMod_ShouldAttack(self,ent,vehiclesOnly)
    if not(IsValid(ent))then return false end
    if(ent:IsWorld())then return false end
    local Gaymode,PlayerToCheck,InVehicle=engine.ActiveGamemode(),nil,false
    if(ent:IsPlayer())then
        PlayerToCheck=ent
    elseif(ent:IsNPC())then
        local Class=ent:GetClass()
        if((self.WhitelistedNPCs)and(table.HasValue(self.WhitelistedNPCs,Class)))then return true end
        if((self.BlacklistedNPCs)and(table.HasValue(self.BlacklistedNPCs,Class)))then return false end
        if not(IsValid(self.Owner))then jprint("B") return ent:Health()>0 end
        if((ent.Disposition)and(ent:Disposition(self.Owner)==D_HT)and(ent.GetMaxHealth))then
            if(vehiclesOnly)then
                return ent:GetMaxHealth()>100
            else
                return ent:GetMaxHealth()>0
            end
        else
            return false
        end
    elseif(ent:IsVehicle())then
        PlayerToCheck=ent:GetDriver()
        InVehicle=true
    end
    if((IsValid(PlayerToCheck))and(PlayerToCheck.Alive))then
        if((vehiclesOnly)and not(InVehicle))then return false end
        if(PlayerToCheck.EZkillme)then return true end -- for testing
        if((self.Owner)and(PlayerToCheck==self.Owner))then return false end
        local Allies=(self.Owner and self.Owner.JModFriends)or {}
        if(table.HasValue(Allies,PlayerToCheck))then return false end
        local OurTeam=nil
        if(IsValid(self.Owner))then OurTeam=self.Owner:Team() end
        if(Gaymode=="sandbox")then return PlayerToCheck:Alive() end
        if(OurTeam)then return PlayerToCheck:Alive() and PlayerToCheck:Team()~=OurTeam end
        return PlayerToCheck:Alive()
    end
    return false
end

function JMod_EnemiesNearPoint(ent,pos,range,vehiclesOnly)
    for k,v in pairs(ents.FindInSphere(pos,range))do
        if(JMod_ShouldAttack(ent,v,vehiclesOnly))then return true end
    end
    return false
end

function JMod_EMP(pos,range)
    for k,ent in pairs(ents.FindInSphere(pos,range))do
        if((ent.SetState)and(ent.SetElectricity)and(ent.GetState)and(ent:GetState()>0))then
            ent:SetState(0)
        end
    end
end

function JMod_Colorify(ent)
    if(IsValid(ent.Owner))then
        if(engine.ActiveGamemode()=="sandbox")then
            local Col=ent.Owner:GetPlayerColor()
            ent:SetColor(Color(Col.x*255,Col.y*255,Col.z*255))
        else
            local Tem=ent.Owner:Team()
            if(Tem)then
                local Col=team.GetColor(Tem)
                if(Col)then ent:SetColor(Col) end
            end
        end
    end
end

local TriggerKeys={IN_ATTACK,IN_USE,IN_ATTACK2}
function JMod_ThrowablePickup(playa,item,hardstr,softstr)
    playa:PickupObject(item)
    local HookName="EZthrowable_"..item:EntIndex()
    hook.Add("KeyPress",HookName,function(ply,key)
        if not(IsValid(playa))then hook.Remove("KeyPress",HookName) return end
        if not(ply==playa)then return end
        if((IsValid(item))and(ply:Alive()))then
            local Phys=item:GetPhysicsObject()
            if(key==IN_ATTACK)then
                timer.Simple(0,function()
                    if(IsValid(Phys))then
                        Phys:ApplyForceCenter(ply:GetAimVector()*(hardstr or 600)*Phys:GetMass())
                        if(item.EZspinThrow)then
                            Phys:ApplyForceOffset(ply:GetAimVector()*Phys:GetMass()*50,Phys:GetMassCenter()+Vector(0,0,10))
                            Phys:ApplyForceOffset(-ply:GetAimVector()*Phys:GetMass()*50,Phys:GetMassCenter()-Vector(0,0,10))
                        end
                    end
                end)
            elseif(key==IN_ATTACK2)then
                local vec = ply:GetAimVector()
                vec.z = vec.z + 0.1
                timer.Simple(0,function()
                    if(IsValid(Phys))then Phys:ApplyForceCenter(vec*(softstr or 400)*Phys:GetMass()) end
                end)
            elseif key == IN_USE then
                if item.GetState and item:GetState() == JMOD_EZ_STATE_PRIMED then
                    JMod_Hint(playa, "grenade drop", item)
                end
            end
        end
        if(table.HasValue(TriggerKeys,key))then hook.Remove("KeyPress",HookName) end
    end)
end
