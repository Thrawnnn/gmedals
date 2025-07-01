-- Then font named "Font" compacted on one line.
surface.CreateFont("Font", {
    font = "Arial",
    extended = true,
    size = 20
})

local faded_black = Color(0, 0, 0, 200) -- The color black but with 200 Alpha

concommand.Add( "gmedal_edit", function()
    if not (LocalPlayer():IsSuperAdmin()) then return notification.AddLegacy( "[gMedals] You Cannot access this menu!", NOTIFY_ERROR, 5) end
    gMedals.NewConfig = ReloadConfig()
	local DermaPanel = vgui.Create("Nexus:Frame") 
	DermaPanel:SetSize(ScrW() / 4, ScrH() / 3)
	DermaPanel:Center() 
	DermaPanel:SetTitle("GMedals Editor") 
--	DermaPanel:SetDraggable(true) Broken funciton
	DermaPanel:MakePopup() 

    local DScrollPanel = vgui.Create( "Nexus:ScrollPanel", DermaPanel )
    DScrollPanel:Dock( FILL )

    local selection = vgui.Create( "Nexus:ComboBox", DermaPanel )
    selection:SetPos( ScrW() / 10, ScrH() / 10 )
    selection:SetSize( ScrW() / 7, ScrH() / 35 )
    selection:SetValue( "Give or take away?" )

    selection.OnSelect = function( _, _, value )
        action = value -- sets the target for later use
    end

    selection:AddChoice( "Give Medal" )
    selection:AddChoice( "Take Medal")

    
    local comboBox = vgui.Create( "Nexus:ComboBox", DermaPanel )
    comboBox:SetPos( ScrW() / 10, ScrH() / 20 )
    comboBox:SetSize( ScrW() / 7, ScrH() / 35 )
    comboBox:SetValue( "Choose your target:" )

    comboBox.OnSelect = function( _, _, value )
        target = value -- sets the target for later use
    end

    for _, t in ipairs( player.GetAll() ) do
        comboBox:AddChoice( t:Name() )
    end
    
    local ConfigButton = vgui.Create( "Nexus:Button", DermaPanel ) 
    ConfigButton:SetText( "Open Configuration Menu" )				
    ConfigButton:SetPos( ScrW() / 10, ScrH() / 6.65 )
    ConfigButton:SetSize( ScrW() / 7, ScrH() / 35 )

    ConfigButton.DoClick = function()
        surface.PlaySound("ui/menu_accept.wav")
        if not (LocalPlayer():IsSuperAdmin()) then return end
        LocalPlayer():ConCommand("gmedal_configuration")
        DermaPanel:Remove()
    end

    for k,v in ipairs(gMedals.NewConfig) do
        local DButton = DScrollPanel:Add( "DImageButton" )
        DButton:SetSize(100,175)
        DButton:SetImage( gMedals.NewConfig[k].editorMat or gMedals.FallBackImage ) -- make the image button the material for the award OR fallback to a default image.
    
        DButton:Dock( TOP )
        DButton:DockMargin( 0, 0, 250, 5 )
        DButton:SetToolTip(gMedals.NewConfig[k].name.." - "..gMedals.NewConfig[k].desc) -- sets the tooltip to have the name followed by the description, e.g 'Cadet - This player is a cadet!''

         DButton.DoClick = function()
            surface.PlaySound(gMedals.ButtonSound)
            
            if not target then
                print("[gMedal Error!] No target selected!")
            end

            for _,n in player.Iterator() do
                if n:Name() == target then
                    if action == "Give Medal" then
                        n:GiveMedal(gMedals.NewConfig[k].id)
                        

                        net.Start("SYNC_MEDALS_ADD")
                            net.WriteUInt(gMedals.NewConfig[k].id, 9)
                            net.WritePlayer(n)
                        net.SendToServer()

                        notification.AddLegacy("You have given "..n:Name().." the "..gMedals.NewConfig[k].name.." medal.", 0, 5)
                    elseif action == "Take Medal" then 
                        
                        n:RemoveMedal(gMedals.NewConfig[k].id)

                        net.Start("SYNC_MEDALS_REMOVE")
                            net.WriteUInt(gMedals.NewConfig[k].id, 9)
                            net.WritePlayer(n)
                        net.SendToServer()

                        notification.AddLegacy("You have removed ".." the "..gMedals.NewConfig[k].name.." medal from "..n:Name(), 1, 5)
                    end
                    break -- stop the loop when the targets found, just best practice for performance ratings :)
                end
            end
            DermaPanel:Remove()
        end
    end

end )