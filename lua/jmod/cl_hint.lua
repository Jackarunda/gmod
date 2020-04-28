-- Part of the code and inspiration from GIGABABAIT
-- Original addon: https://steamcommunity.com/sharedfiles/filedetails/?id=2058653864

CreateConVar("cl_jmod_hint_enabled", 1, FCVAR_ARCHIVE + FCVAR_USERINFO, "Whether to show hints on JMod entities.", 0, 1)
CreateConVar("cl_jmod_hint_legacy", 0, FCVAR_ARCHIVE + FCVAR_USERINFO, "Whether to force legacy/vanilla hints instead of the new fancy ones.", 0, 1)

surface.CreateFont("JModHintFont", {
    font = "BahnSchrift",
    size = 48,
    weight = 500,
    antialias = true,
})

local arUp = Material("hint/up.png", "smooth")
local arRight = Material("hint/right.png", "smooth")
local arDown = Material("hint/down.png", "smooth")
local arLeft = Material("hint/left.png", "smooth")
local start = SysTime()

net.Receive("JMod_Hint",function()
    local new = net.ReadBool()
    if not new then
        local str = net.ReadString()
        MsgC(Color(255,255,255), "[JMod] ", str, "\n")
        notification.AddLegacy(str, NOTIFY_HINT, 10)
        surface.PlaySound( "ambient/water/drip" .. math.random( 1, 4 ) .. ".wav" )
        return
    end
    
    local hinttable = net.ReadTable()
    local key = hinttable.Key
    local hinttype = hinttable.Type or "exclamation"
    local hinttext = hinttable.Text or "No Text Input"
    local hintPos = hinttable.Pos or Vector(0, 0, 0)
    local hinttime = hinttable.Time or nil
    local hintsound = hinttable.Sound or "snd_jack_hint.wav"
    local shouldmove = hinttable.ShouldMove or false
    local textcolor = hinttable.Color or Vector(255, 255, 255)
    local hintoffset = hinttable.Offset or Vector(0, 0, 0)
    local hintid = hinttable.Identifier or ""
    local hintPosScr
    local start = SysTime()
    local hint_mat
    local keytext
    local spacebarAdd = 0
    
    -- Only popup walk bind hint if the player doesn't have walk bound
    if key == "bind walk" and input.LookupBinding("+walk") ~= nil then
        return
    end

    -- Localization support
    local str = "jmod_hint_" .. string.Replace(key, " ", "_")
    if language.GetPhrase(str) ~= str then
        hinttext = language.GetPhrase("jmod_hint_" .. string.Replace(key, " ", "_"))
    end

    if string.sub(hinttype, 1, 3) == "key" then
        keytext = string.sub(hinttype, 5, string.len(hinttype))
        hinttype = "key"
    elseif hinttype == "spacebar" then
        spacebarAdd = 128
    end
    

    hint_mat = Material("hint/" .. hinttype .. ".png", "smooth")

    if hintsound ~= "" then
        EmitSound(Sound(hintsound), LocalPlayer():GetPos(), 1, CHAN_STATIC, 1, 75, 0, 100)
    end
    
    -- Remove old hook and timer if it already exists
    if timer.Exists("JMod_HintTimer_" .. hintid) then
        timer.Remove("JMod_HintTimer_" .. hintid)
    end
    if hinttime ~= nil then
        timer.Create("JMod_HintTimer_" .. hintid, hinttime + 1, 1, function()
            hook.Remove("HUDPaint", "JMod_HintPaint_" .. hintid)
        end)
    end
    
    MsgC(Color(255,255,255), "[JMod] ", Color(textcolor.x, textcolor.y, textcolor.z), hinttext, "\n")
    hook.Add("HUDPaint", "JMod_HintPaint_" .. hintid, function()
        if IsEntity(hintPos) and not IsValid(hintPos) then
            hook.Remove("HUDPaint", "JMod_HintPaint_" .. hintid)
            return
        end

        if IsEntity(hintPos) then
            hintPosScr = hintPos:GetPos() + hintoffset
        else
            hintPosScr = hintPos + hintoffset
        end

        cam.Start3D()
            hintPosScr = hintPosScr:ToScreen()
        cam.End3D()

        local offScreen = {
            above = hintPosScr.y < 0,
            below = hintPosScr.y > ScrH(),
            right = hintPosScr.x > ScrW(),
            left = hintPosScr.x < 0
        }

        hintPosScr.x = math.Clamp(hintPosScr.x, 120, ScrW() - 250)
        hintPosScr.y = math.Clamp(hintPosScr.y, 120, ScrH() - 250)
        
        local a = 255
        local diffT = SysTime() - start
        if hinttime and diffT >= hinttime then
            local vanishT = start + hinttime + 1
            a = Lerp(vanishT - SysTime(), 0, 255)
        elseif hinttime and SysTime() - start <= 1 then
            a = Lerp(SysTime() - start, 0, 255)
        end

        if shouldmove then
            if not offScreen.above and not offScreen.below and not offScreen.right and not offScreen.left then
                surface.SetDrawColor(255, 255, 255, a)
                surface.SetMaterial(hint_mat)
                surface.DrawTexturedRect(Lerp(SysTime() - start, ScrW() - 1300 - spacebarAdd, hintPosScr.x - spacebarAdd + string.len(hinttext) * -10), Lerp(SysTime() - start, ScrH() - 400, hintPosScr.y), 128 + spacebarAdd, 128)
                

                if hinttype == "key" then
                    surface.SetFont("JModHintFont")
                    surface.SetTextColor(0, 0, 0, a)
                    surface.SetTextPos(Lerp(SysTime() - start, ScrW() - 1250, hintPosScr.x + 50 + string.len(hinttext) * -10), Lerp(SysTime() - start, ScrH() - 360, hintPosScr.y + 35))
                    surface.DrawText(keytext)
                end

                draw.SimpleTextOutlined(hinttext, "JModHintFont", Lerp(SysTime() - start, ScrW() - 1150, hintPosScr.x + 150 + string.len(hinttext) * -10), Lerp(SysTime() - start, ScrH() - 360, hintPosScr.y + 45), Color(textcolor.x,textcolor.y,textcolor.z,a), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 2, Color(0, 0, 0, a))
            elseif offScreen.above then
                surface.SetDrawColor(255, 255, 255, a)
                surface.SetMaterial(hint_mat)
                surface.DrawTexturedRect(Lerp(SysTime() - start, ScrW() - 1300, hintPosScr.x), Lerp(SysTime() - start, ScrH() - 400, hintPosScr.y), 128 + spacebarAdd, 128)
                surface.SetMaterial(arUp)
                surface.DrawTexturedRect(Lerp(SysTime() - start, ScrW() - 1300, hintPosScr.x), Lerp(SysTime() - start, ScrH() - 400, hintPosScr.y - 120), 128, 128)

                if hinttype == "key" then
                    surface.SetFont("JModHintFont")
                    surface.SetTextColor(0, 0, 0, a)
                    surface.SetTextPos(Lerp(SysTime() - start, ScrW() - 1250, hintPosScr.x + 50), Lerp(SysTime() - start, ScrH() - 360, hintPosScr.y + 35))
                    surface.DrawText(keytext)
                end
            elseif offScreen.right then
                surface.SetDrawColor(255, 255, 255, a)
                surface.SetMaterial(hint_mat)
                surface.DrawTexturedRect(Lerp(SysTime() - start, ScrW() - 1300, hintPosScr.x), Lerp(SysTime() - start, ScrH() - 400, hintPosScr.y), 128 + spacebarAdd, 128)
                surface.SetMaterial(arRight)
                surface.DrawTexturedRect(Lerp(SysTime() - start, ScrW() - 1300, hintPosScr.x + 120), Lerp(SysTime() - start, ScrH() - 400, hintPosScr.y), 128, 128)

                if hinttype == "key" then
                    surface.SetFont("JModHintFont")
                    surface.SetTextColor(0, 0, 0, a)
                    surface.SetTextPos(Lerp(SysTime() - start, ScrW() - 1250, hintPosScr.x + 50), Lerp(SysTime() - start, ScrH() - 360, hintPosScr.y + 35))
                    surface.DrawText(keytext)
                end
            elseif offScreen.below then
                surface.SetDrawColor(255, 255, 255, a)
                surface.SetMaterial(hint_mat)
                surface.DrawTexturedRect(Lerp(SysTime() - start, ScrW() - 1300, hintPosScr.x), Lerp(SysTime() - start, ScrH() - 400, hintPosScr.y), 128 + spacebarAdd, 128)
                surface.SetMaterial(arDown)
                surface.DrawTexturedRect(Lerp(SysTime() - start, ScrW() - 1300, hintPosScr.x), Lerp(SysTime() - start, ScrH() - 400, hintPosScr.y + 120), 128, 128)

                if hinttype == "key" then
                    surface.SetFont("JModHintFont")
                    surface.SetTextColor(0, 0, 0, a)
                    surface.SetTextPos(Lerp(SysTime() - start, ScrW() - 1250, hintPosScr.x + 50), Lerp(SysTime() - start, ScrH() - 360, hintPosScr.y + 35))
                    surface.DrawText(keytext)
                end
            elseif offScreen.left then
                surface.SetDrawColor(255, 255, 255, a)
                surface.SetMaterial(hint_mat)
                surface.DrawTexturedRect(Lerp(SysTime() - start, ScrW() - 1300, hintPosScr.x), Lerp(SysTime() - start, ScrH() - 400, hintPosScr.y), 128 + spacebarAdd, 128)
                surface.SetMaterial(arLeft)
                surface.DrawTexturedRect(Lerp(SysTime() - start, ScrW() - 1300, hintPosScr.x - 120), Lerp(SysTime() - start, ScrH() - 400, hintPosScr.y), 128, 128)

                if hinttype == "key" then
                    surface.SetFont("JModHintFont")
                    surface.SetTextColor(0, 0, 0, a)
                    surface.SetTextPos(Lerp(SysTime() - start, ScrW() - 1250, hintPosScr.x + 50), Lerp(SysTime() - start, ScrH() - 360, hintPosScr.y + 35))
                    surface.DrawText(keytext)
                end
            end
        else
            surface.SetDrawColor(255, 255, 255, a)
            surface.SetMaterial(hint_mat)
            surface.DrawTexturedRect(ScrW() / 2 - 150 - spacebarAdd + string.len(hinttext) * -10, ScrH() / 2 + 200, 128 + spacebarAdd, 128)
            surface.SetFont("JModHintFont")

            if hinttype == "key" then
                surface.SetTextColor(0, 0, 0, a)
                surface.SetTextPos(ScrW() / 2 - 100 + string.len(hinttext) * -10, ScrH() / 2 + 230)
                surface.DrawText(keytext)
            end

            draw.SimpleTextOutlined(hinttext, "JModHintFont", ScrW() / 2 + string.len(hinttext) * -10, ScrH() / 2 + 230, Color(textcolor.x,textcolor.y,textcolor.z,a), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 2, Color(0, 0, 0, a))
        end
    end)
end)

local NeedAltKeyMsg = true
net.Receive("JMod_PlayerSpawn",function()
    local DoHints = tobool(net.ReadBit())
    if not input.LookupBinding("+walk") then
        chat.AddText(Color(255,0,0), "Your Walk key is not bound; JMod entities will be mostly unusable.")
        chat.AddText(Color(255,0,0), "Please bind it in Settings or with concommand 'bind alt +walk'.")
    end
end)

concommand.Add("jmod_wiki", function()
    gui.OpenURL("https://github.com/Jackarunda/gmod/wiki")
end)