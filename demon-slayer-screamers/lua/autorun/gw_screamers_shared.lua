gw_screamers_config = {}

gw_screamers_config.mats = { -- Images of the screamer
    "gw_screamer/screamer1.png",
    "gw_screamer/screamer2.jpg",
    "gw_screamer/screamer3.png",
}

gw_screamers_config.sounds = { -- Sounds of the screamer
    "gw_sounds/scream.wav",
}

gw_screamers_config.duration = 1 -- Duration of the image and sound on the screen
gw_screamers_config.volume = 1.5 -- Volume of the scream




--[[----
    DONT TOUCH THIS
--]]----

if CLIENT then
    hook.Add("PostDrawHUD", "GW.DrawScreamer", function()
        if LocalPlayer():GetNWBool("GW.SCREAMER", false) then
            surface.SetDrawColor( 255, 255, 255, 255 )
            surface.SetMaterial( Material(LocalPlayer():GetNWString("GW.SCREAMER.Mat", gw_screamers_config.mats[1])) )
            surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )
        end
    end)

    hook.Add( "PostDrawTranslucentRenderables", "GM.DrawTraceCircle", function()
        if LocalPlayer():IsValid() && LocalPlayer():Alive() && IsValid(LocalPlayer():GetActiveWeapon()) then
            if LocalPlayer():GetActiveWeapon():GetClass() == "swep_screamers_creator" then
                render.SetColorMaterial()
                local pos = LocalPlayer():GetEyeTrace().HitPos
                render.DrawSphere( pos, 10, 30, 30, color_black )
            end
        end
    end )
end