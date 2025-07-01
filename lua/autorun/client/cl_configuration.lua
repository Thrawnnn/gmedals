-- Then font named "Font" compacted on one line.
surface.CreateFont("Font", {
    font = "Arial",
    extended = true,
    size = 20
})

local faded_black = Color(0, 0, 0, 200) -- The color black but with 200 Alpha

concommand.Add( "gmedal_configuration", function()
    if not (LocalPlayer():IsSuperAdmin()) then return notification.AddLegacy( "[gMedals] You Cannot access this menu!", NOTIFY_ERROR, 5) end
    gMedals.NewConfig = ReloadConfig()

	local DermaPanel = vgui.Create("Nexus:Frame") 
	DermaPanel:SetSize(ScrW() / 4, ScrH() / 3)
	DermaPanel:Center() 
	DermaPanel:SetTitle("GMedals Configuration Tool") 
--	DermaPanel:SetDraggable(true)
	DermaPanel:MakePopup() 

    local Scroll = vgui.Create( "Nexus:ScrollPanel", DermaPanel )
    Scroll:Dock( FILL )

    local ConfigButton = vgui.Create( "Nexus:Button", Scroll ) 
    ConfigButton:SetText( "List Current Configuration" )				
    ConfigButton:SetPos( ScrW() / 8, ScrH() / 37 )
    ConfigButton:SetSize( ScrW() / 10, ScrH() / 45 )

    ConfigButton.DoClick = function()
        surface.PlaySound("ui/menu_focus.wav")
        PrintTable(gMedals.NewConfig)
        notification.AddLegacy("Sent current configuration to client console!", 0, 5)
        DermaPanel:Remove()
    end

    local name = vgui.Create("Nexus:TextEntry", Scroll)
    name:SetPos( ScrW() / 75, ScrH() / 37 )
    name:SetSize( ScrW() / 13, ScrH() / 35 )
    name:SetPlaceholder("Medal Name:")
    name.OnChange = function( s )
		nameValue = s:GetText()
	end

    local desc = vgui.Create("Nexus:TextEntry", Scroll)
    desc:SetPos( ScrW() / 75, ScrH() / 13.5 )
    desc:SetSize( ScrW() / 13, ScrH() / 35 )
    desc:SetPlaceholder("Medal Description:")
    desc.OnChange = function( s )
		descValue = s:GetText()
	end

    local id = vgui.Create("Nexus:TextEntry", Scroll)
    id:SetPos( ScrW() / 75, ScrH() / 8.25 )
    id:SetSize( ScrW() / 13, ScrH() / 35 )
    id:SetPlaceholder("Medal Priority")
    id.OnChange = function( s )
		idValue = s:GetText()
	end

    local mat = vgui.Create("Nexus:TextEntry", Scroll)
    mat:SetPos( ScrW() / 75, ScrH() / 6 )
    mat:SetSize( ScrW() / 13, ScrH() / 35 )
    mat:SetPlaceholder("Medal Material: ")
    mat.OnChange = function( s )
		matValue = s:GetText()
	end

        
    local Mixer = vgui.Create("DColorMixer", Scroll)
    Mixer:SetPos( ScrW() / 75, ScrH() / 3.5 )
    Mixer:SetPalette(true)
    Mixer:SetAlphaBar(true)
    Mixer:SetWangs(true)
    Mixer:SetColor(Color(255,255,255))
    Mixer.ValueChanged = function(color)
        colorValue = Mixer:GetColor()
    end 

    DefaultColor = Scroll:Add( "Nexus:CheckBox" )
    DefaultColor:SetSize( ScrW() / 11.75, ScrH() / 45 )
    DefaultColor:SetPos( ScrW() / 8, ScrH() / 8.75 )
    DefaultColor:SetState(true)
    DefaultColor:SetText("Use Default Color?")
    function DefaultColor:OnStateChanged(bool)
        if bool == true then
            colorValue = Color(0,0,0,100)
        end
    end

    local coloredImage = Scroll:Add( "Nexus:CheckBox" )
    coloredImage:SetSize( ScrW() / 11.75, ScrH() / 45 )
    coloredImage:SetPos( ScrW() / 8, ScrH() / 5.5 )
    coloredImage:SetState(false)
    coloredImage:SetText("Colored Image?")
    function coloredImage:OnStateChanged(bool)
        if bool == true then
            colorValue = Color(255,255,255,200)
        end
        if DefaultColor:GetState() == true then
            DefaultColor:SetState(false)
        end
    end

    local ResetButton = vgui.Create( "Nexus:Button", Scroll ) 
    ResetButton:SetText( "Reset All Medals" )				
    ResetButton:SetColor(Color(200,0,0,255))
    ResetButton:SetPos( ScrW() / 8, ScrH() / 15 )			
    ResetButton:SetSize( ScrW() / 10, ScrH() / 45 )

    ResetButton.DoClick = function()
        surface.PlaySound("ui/menu_focus.wav")
        Mixer:SetColor(Color(255,255,255,255))
        mat:SetText("")
        id:SetText("")
        name:SetText("")
        desc:SetText("")
        DefaultColor:SetState(true)

        Derma_Query(
            "Are you sure you want to reset the Configuration? This will remove all custom medals.",
            "Confirmation:",
            "Yes",
            function()
                gMedals.NewConfig = ReloadConfig()
                net.Start('ResetConfig')
                net.SendToServer()
                notification.AddLegacy("Configuration Reset, restart the server to see the changes.", 0, 5)
                DermaPanel:Remove()
            end,
            "No",
            function() return notification.AddLegacy("Action Cancelled", 0, 5) end
        )
    end

    local comboBox = vgui.Create( "Nexus:ComboBox", Scroll )
    comboBox:SetPos( ScrW() / 8, ScrH() / 7 )			
    comboBox:SetSize( ScrW() / 10, ScrH() / 45 )
    comboBox:SetValue( "Destroy Medal" )

    comboBox.OnSelect = function( _, _, value )
        target = value -- sets the target for later use

        Derma_Query(
            "Are you sure you want to Destroy this medal?",
            "Confirmation:",
            "Yes",
            function()
                net.Start('REMOVE_MEDAL')
                    for k,v in ipairs(gMedals.NewConfig) do
                        if v.name == target then
                            targId = v.id
                            print(targId)
                            net.WriteInt(targId, 32)
                        end
                    end
                net.SendToServer()
                DermaPanel:Remove()
                notification.AddLegacy("Medal Removed, restart the server to see the changes.", 0, 5)
            end,
            "No",
            function() return notification.AddLegacy("Action Cancelled", 0, 5) end
        )
    end

    for k,v in ipairs(gMedals.NewConfig) do
        comboBox:AddChoice(v.name)
    end

    local ConfigButton = vgui.Create( "Nexus:Button", Scroll ) 
    ConfigButton:SetText( "Export New Medal" )				
    ConfigButton:SetPos( ScrW() / 75, ScrH() / 4.5 )					
    ConfigButton:SetSize( ScrW() / 10, ScrH() / 30 )

    ConfigButton.DoClick = function()
        surface.PlaySound("ui/menu_focus.wav")
        local defaultCol = Color(0,0,0,100)
        local color = colorValue or defaultCol
        local idval = idValue or 0
        local matVal = matValue or 'NIL'
        local nameVal = nameValue or 'NIL'
        local descVal = descValue or 'NIL'
        DermaPanel:Remove()
        net.Start('ADD_NEW_MEDAL')
            net.WriteString(nameVal)
            net.WriteString(descVal)
            net.WriteInt(idval, 32)
            net.WriteString(matVal)
            net.WriteColor(Color(color.r, color.g, color.b, color.a))
        net.SendToServer()

        notification.AddLegacy("Exported successfully, restart the server to see the new medal!", 0, 5)
    end

end )





