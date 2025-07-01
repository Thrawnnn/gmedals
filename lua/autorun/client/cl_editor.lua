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
    ReloadGroups()
	local DermaPanel = vgui.Create("Nexus:Frame") 
	DermaPanel:SetSize(ScrW() / 4, ScrH() / 3)
	DermaPanel:Center() 
	DermaPanel:SetTitle("GMedals Editor - Group Selection") 
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

        for k, v in pairs(gMedals.Groups) do
            local DButton = DScrollPanel:Add("DImageButton")
            DButton:SetSize(100, 175)
            DButton:SetImage(v.mat or gMedals.FallBackImage)
        
            DButton:Dock(TOP)
            DButton:DockMargin(0, 0, 250, 5)
            DButton:SetToolTip(v.name)
        
            DButton.DoClick = function()
                DScrollPanel:Clear()  -- Clear previous buttons
                DermaPanel:SetTitle("GMedals Editor - " .. v.name)
                local selectedGroup = v.name
        
                for _, medal in pairs(gMedals.NewConfig) do
                    -- Check if the medal belongs to the selected group
                    if medal.group == selectedGroup or selectedGroup == "Default" then  -- Ensure correct comparison
                        local MedalButton = DScrollPanel:Add("DImageButton")
                        MedalButton:SetSize(100, 175)
                        MedalButton:SetImage(medal.editorMat or gMedals.FallBackImage)
        
                        MedalButton:Dock(TOP)
                        MedalButton:DockMargin(0, 0, 250, 5)
                        MedalButton:SetToolTip(medal.name .. " - " .. medal.desc)
        
                        MedalButton.DoClick = function()
                            surface.PlaySound(gMedals.ButtonSound)
        
                            if not target then
                                print("[gMedal Error!] No target selected!")
                                return
                            end
        
                            for _, n in player.Iterator() do
                                if n:Name() == target then
                                    if action == "Give Medal" then
                                        n:GiveMedal(medal.id)
        
                                        net.Start("SYNC_MEDALS_ADD")
                                            net.WriteUInt(medal.id, 9)
                                            net.WritePlayer(n)
                                        net.SendToServer()
        
                                        notification.AddLegacy("You have given " .. n:Name() .. " the " .. medal.name .. " medal.", 0, 5)
                                    elseif action == "Take Medal" then
                                        n:RemoveMedal(medal.id)
        
                                        net.Start("SYNC_MEDALS_REMOVE")
                                            net.WriteUInt(medal.id, 9)
                                            net.WritePlayer(n)
                                        net.SendToServer()
        
                                        notification.AddLegacy("You have removed the " .. medal.name .. " medal from " .. n:Name(), 1, 5)
                                    end
                                    break
                                end
                            end
                            DermaPanel:Remove()
                        end
                    end
                end
            end
    end    
end )