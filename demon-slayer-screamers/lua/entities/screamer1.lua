AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName = "Screamer zone"
ENT.Category = "Gema's screamers"


ENT.Spawnable = false
ENT.mat = gw_screamers_config.mats[1]
ENT.sound = gw_screamers_config.sounds[1]
ENT.radius = 300

if SERVER then
    for k,v in pairs(gw_screamers_config.sounds) do
        resource.AddFile( "sound/" .. v )
    end
    for k,v in pairs(gw_screamers_config.mats) do
        resource.AddFile( "materials/" .. v )
    end
    
    function ENT:Initialize()
        self:SetModel("models/hunter/plates/plate075x075.mdl")
        self:SetMaterial("Models/effects/vol_light001")
        self:PhysicsInit(SOLID_NONE)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)
        self:DrawShadow(false)
        


        local phys = self:GetPhysicsObject()
        if phys:IsValid() then
            phys:Wake()
            phys:EnableMotion(false)
        end

        timer.Simple(1, function()
            if IsValid( self ) then
                self.canCheckZone = true
            end
        end)
    
    end

    function ENT:Think()
        if self.canCheckZone then
            for _, ent in pairs(ents.FindInSphere(self:GetPos(), self.radius) ) do
                if IsValid( ent ) && ent:IsPlayer() then
                    self.canCheckZone = false

                    ent:SetNWString("GW.SCREAMER.Mat", self.mat)
                    ent:SetNWBool("GW.SCREAMER", true)
                    

                    ent:EmitSound(self.sound,75,50,gw_screamers_config.volume)

                    timer.Simple(gw_screamers_config.duration, function() 
                        if IsValid( ent ) then
                            ent:SetNWBool("GW.SCREAMER", false) 
                            ent:StopSound( self.sound )
                        end
                    end)

                    
                    timer.Simple(60, function()
                        if IsValid( self ) then
                            self.canCheckZone = true
                        end
                    end)
                end
            end
        end
    end

else

    function ENT:DrawTranslucent()
        local ply = LocalPlayer()
        if ply:IsValid() && ply:Alive() && IsValid(ply:GetActiveWeapon()) then
            if ply:GetActiveWeapon():GetClass() == "swep_screamers_creator" then
                cam.Start3D()
                render.SetColorMaterial()
                render.DrawSphere(self:GetPos(),10,20,20, color_black )

                render.SetColorMaterial()
                render.DrawSphere(self:GetPos(),-(self.radius or 300),20,20,Color(255,0,0,140))

                render.SetColorMaterial()
                render.DrawSphere(self:GetPos(),(self.radius or 300)-10,20,20,Color(55,0,200,140))
                cam.End3D()
            end
        end
    end

    function ENT:Draw()
        self:DrawModel()
    end
end