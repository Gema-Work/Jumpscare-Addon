SWEP.PrintName = "Zone Creator"
SWEP.Author = "Gēmā"
SWEP.Purpose = ""
SWEP.Instructions = "Left click : Open edit menu"

SWEP.ViewModel		= "models/weapons/c_toolgun.mdl"
SWEP.WorldModel		= "models/weapons/w_toolgun.mdl"
SWEP.UseHands		= true



SWEP.Primary.ClipSize = 1
SWEP.Primary.Delay = 2
SWEP.Primary.DefaultClip = 1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = 1
SWEP.Secondary.Delay = 0.5
SWEP.Secondary.DefaultClip = 1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"


SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Category = "Gema's Work"
 

--[[-- Draw Sphere
  function SWEP:PostDrawViewModel(vm,wep,ply)
    cam.Start3D()
      local dis = math.sqrt(self:GetDistance())
      local AllTalk = self:GetAllTalk()
      render.SetColorMaterial()
      render.DrawSphere(ply:GetPos(),AllTalk and -200 or -dis,20,20,AllTalk and Color(255,0,0,40) or Color(0,255,0,40))
    cam.End3D()
  end
--]]

function SWEP:Initialize()
	self:SetHoldType( "revolver" )
end

function SWEP:PrimaryAttack()
  if SERVER then 
    local ply = self:GetOwner() 
    local pos = ply:GetEyeTrace().HitPos

    net.Start("Screamer.Creator.OpenMenu")
      net.WriteVector(pos)
    net.Send(ply)
  end
end

if SERVER then
  util.AddNetworkString("Screamer.Creator.OpenMenu")
  util.AddNetworkString("Screamer.Creator.SpawnZone")
  util.AddNetworkString("Screamer.Creator.SetRadius")

  net.Receive("Screamer.Creator.SpawnZone", function(len, ply)
    local pos = net.ReadVector()
    local mat, sound, radius = net.ReadString(), net.ReadString(), net.ReadInt(11)

    local gves = ents.Create("screamer1")
    gves:SetPos(pos)

    gves:Spawn()
    gves:SetOwner(ply)
    timer.Simple(1, function()
      gves.mat = mat
      gves.sound = sound
      gves.radius = radius
    end)
    net.Start("Screamer.Creator.SetRadius")
      net.WriteEntity(gves)
      net.WriteInt(radius,11)
    net.Send(ply)

    undo.Create("screamer1")
        undo.AddEntity(gves)
        undo.SetPlayer(ply)
    undo.Finish()
  end)  
else  
  net.Receive("Screamer.Creator.OpenMenu", function()
    local pos = net.ReadVector()

    local ZoneMenu = vgui.Create("DFrame")
    ZoneMenu:SetSize(ScrW()*0.2,ScrH()*0.2)
    ZoneMenu:Center()
    ZoneMenu:SetTitle("")
    ZoneMenu:MakePopup()
    ZoneMenu.btnMinim:SetVisible(false)
    ZoneMenu.btnMaxim:SetVisible(false)

    local ImagesText = vgui.Create("DLabel", ZoneMenu)
    ImagesText:Dock(TOP)
    ImagesText:SetText("Image: ")

    local Images = vgui.Create("DComboBox", ZoneMenu)
    Images:Dock(TOP)
    Images:SetValue(gw_screamers_config.mats[1])
    Images.Choice = gw_screamers_config.mats[1]
    for k,v in pairs(gw_screamers_config.mats) do
      Images:AddChoice( v )
    end
    Images.OnSelect = function( self, index, value )
      Images.Choice = value
    end

    local SoundText = vgui.Create("DLabel", ZoneMenu)
    SoundText:Dock(TOP)
    SoundText:SetText("Sound: ")

    local Sounds = vgui.Create("DComboBox", ZoneMenu)
    Sounds:Dock(TOP)
    Sounds:SetValue(gw_screamers_config.sounds[1])
    Sounds.Choice = gw_screamers_config.sounds[1]
    for k,v in pairs(gw_screamers_config.sounds) do
      Sounds:AddChoice( v )
    end
    Sounds.OnSelect = function( self, index, value )
      Sounds.Choice = value
    end

    local Radius = vgui.Create("DNumSlider", ZoneMenu)
    Radius:Dock(TOP)
    Radius:SetText("Radius: ")
    Radius:SetMin( 50 )
    Radius:SetMax( 500 )
    Radius:SetValue( 300 )
    Radius.Choice = 300
    Radius.OnValueChanged = function( self, value )
      Radius.Choice = value
    end

    local CreateBtn = vgui.Create("DButton", ZoneMenu)
    CreateBtn:Dock(BOTTOM)
    CreateBtn:SetText("Create")
    CreateBtn.DoClick = function()
      net.Start("Screamer.Creator.SpawnZone")
        net.WriteVector(pos)
        net.WriteString(Images.Choice)
        net.WriteString(Sounds.Choice)
        net.WriteInt(Radius.Choice,11)
      net.SendToServer()
    end

  end) 

  net.Receive("Screamer.Creator.SetRadius", function()
    local ent,radius = net.ReadEntity(), net.ReadInt(11)
    timer.Simple(0.5, function()
      if IsValid(ent) then
        ent.radius = radius
      end
    end)
  end)
end

function SWEP:SecondaryAttack()

end

function SWEP:Reload()
end
